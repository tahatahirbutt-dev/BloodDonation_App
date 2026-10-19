import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/donation_eligibility.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../entities/blood_request.dart';
import '../entities/donor_response.dart';
import '../repositories/request_response_repository.dart';

/// The donor taps "I can help". Checks that the offer makes sense, then
/// shares the donor's name and phone with the requester through a
/// response document.
///
/// These checks are for a clear message. The security rules enforce the
/// same conditions on the server, so a tampered client cannot skip them.
class RespondToRequest {
  RespondToRequest(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final RequestResponseRepository _repository;
  final DateTime Function() _clock;

  /// Why this donor cannot respond right now, or `null` if they can.
  /// The page uses it to disable the button with an explanation; [call]
  /// uses the same check, so the two can never disagree.
  ValidationFailure? blockReason({
    required BloodRequest request,
    required UserProfile donor,
  }) {
    final now = _clock();

    if (!request.isOpenAt(now)) {
      return const ValidationFailure('This request is no longer open.');
    }
    if (donor.uid == request.requesterUid) {
      return const ValidationFailure('You cannot respond to your own request.');
    }
    if (!donor.bloodGroup.canDonateTo(request.bloodGroup)) {
      return ValidationFailure(
        'Your blood group (${donor.bloodGroup.label}) cannot donate to '
        'a ${request.bloodGroup.label} patient.',
      );
    }
    if (!donor.isAvailable) {
      return const ValidationFailure(
        'You are set as unavailable. Turn availability on in your '
        'profile first.',
      );
    }
    final eligibility = donor.eligibilityAt(now);
    if (eligibility is NotYetEligible) {
      return ValidationFailure(
        'You can donate again in ${eligibility.daysRemaining} days.',
      );
    }
    return null;
  }

  Future<Result<DonorResponse>> call({
    required BloodRequest request,
    required UserProfile donor,
  }) async {
    final blocked = blockReason(request: request, donor: donor);
    if (blocked != null) return Err<DonorResponse>(blocked);

    final now = _clock();

    // Already responded? Return that response instead of writing again,
    // so a double tap is harmless.
    switch (await _repository.getMyResponse(
      requestId: request.id,
      donorUid: donor.uid,
    )) {
      case Success<DonorResponse?>(:final value):
        if (value != null) return Success<DonorResponse>(value);
      case Err<DonorResponse?>(:final failure):
        return Err<DonorResponse>(failure);
    }

    final response = DonorResponse(
      requestId: request.id,
      donorUid: donor.uid,
      donorName: donor.name,
      phone: donor.phone,
      bloodGroup: donor.bloodGroup,
      location: donor.location,
      respondedAt: now,
    );

    return switch (await _repository.respond(response)) {
      Success<void>() => Success<DonorResponse>(response),
      Err<void>(:final failure) => Err<DonorResponse>(failure),
    };
  }
}
