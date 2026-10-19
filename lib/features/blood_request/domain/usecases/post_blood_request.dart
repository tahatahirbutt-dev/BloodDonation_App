import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/geo/models/static_location.dart';
import 'package:blood_donation_app/core/id/id_generator.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../entities/blood_request.dart';
import '../entities/request_status.dart';
import '../entities/request_urgency.dart';
import '../repositories/blood_request_repository.dart';

/// Raw input from the "post a request" form.
final class PostBloodRequestParams {
  const PostBloodRequestParams({
    required this.requesterUid,
    required this.requesterName,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.urgency,
    required this.hospitalId,
    this.note = '',
  });

  final String requesterUid;
  final String requesterName;
  final BloodGroup bloodGroup;
  final int unitsNeeded;
  final RequestUrgency urgency;
  final String hospitalId;
  final String note;
}

/// Validates the form, stamps the request with an id and an expiry, and
/// saves it. Every rule lives here; the page only reports what this says.
class PostBloodRequest {
  PostBloodRequest(
    this._repository, {
    required IdGenerator idGenerator,
    DateTime Function()? clock,
  }) : _idGenerator = idGenerator,
       _clock = clock ?? DateTime.now;

  final BloodRequestRepository _repository;
  final IdGenerator _idGenerator;
  final DateTime Function() _clock;

  Future<Result<BloodRequest>> call(PostBloodRequestParams params) async {
    final now = _clock();

    if (params.unitsNeeded < BloodRequest.minUnits ||
        params.unitsNeeded > BloodRequest.maxUnits) {
      return const Err<BloodRequest>(
        ValidationFailure(
          'Choose between ${BloodRequest.minUnits} and '
          '${BloodRequest.maxUnits} units.',
          field: 'units',
        ),
      );
    }

    final hospital = LocationCatalog.findById(params.hospitalId);
    if (hospital == null ||
        (hospital.category != LocationCategory.hospital &&
            hospital.category != LocationCategory.bloodBank)) {
      return const Err<BloodRequest>(
        ValidationFailure(
          'Please choose the hospital or blood bank from the list.',
          field: 'hospital',
        ),
      );
    }

    final note = params.note.trim();
    if (note.length > BloodRequest.maxNoteLength) {
      return const Err<BloodRequest>(
        ValidationFailure(
          'Keep the note under ${BloodRequest.maxNoteLength} characters.',
          field: 'note',
        ),
      );
    }

    // Guard against accidental duplicates (for example a double post
    // after a flaky connection).
    switch (await _repository.getRequestsByRequester(params.requesterUid)) {
      case Success<List<BloodRequest>>(:final value):
        final openCount = value.where((r) => r.isOpenAt(now)).length;
        if (openCount >= BloodRequest.maxOpenPerRequester) {
          return const Err<BloodRequest>(
            ValidationFailure(
              'You already have ${BloodRequest.maxOpenPerRequester} open '
              'requests. Close one before posting another.',
            ),
          );
        }
      case Err<List<BloodRequest>>(:final failure):
        return Err<BloodRequest>(failure);
    }

    final request = BloodRequest(
      id: _idGenerator.newId(),
      requesterUid: params.requesterUid,
      requesterName: params.requesterName,
      bloodGroup: params.bloodGroup,
      unitsNeeded: params.unitsNeeded,
      urgency: params.urgency,
      hospital: hospital,
      note: note,
      status: RequestStatus.open,
      createdAt: now,
      expiresAt: now.add(params.urgency.validFor),
    );

    return switch (await _repository.create(request)) {
      Success<void>() => Success<BloodRequest>(request),
      Err<void>(:final failure) => Err<BloodRequest>(failure),
    };
  }
}
