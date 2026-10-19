import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../domain/entities/blood_request.dart';
import '../../domain/entities/request_status.dart';
import '../../domain/entities/request_urgency.dart';

/// Converts between [BloodRequest] and its stored document.
///
/// Reading is defensive, like `UserProfileMapper`: a document can be
/// hand-edited, written by another app version, or point at a catalog
/// entry that no longer exists. Any of those becomes a typed failure the
/// repository can skip or report, never a cast error on a screen.
abstract final class BloodRequestMapper {
  static const Failure _unreadable = ServerFailure(
    'A blood request could not be read.',
  );

  static Map<String, dynamic> toMap(BloodRequest request) {
    return <String, dynamic>{
      'requesterUid': request.requesterUid,
      'requesterName': request.requesterName,
      // Enum *names*, not display labels.
      'bloodGroup': request.bloodGroup.name,
      'units': request.unitsNeeded,
      'urgency': request.urgency.name,
      'hospitalId': request.hospital.id,
      // Denormalized from the catalog for geographic queries and so the
      // security rules can reject coordinates outside the twin cities.
      'latitude': request.hospital.point.latitude,
      'longitude': request.hospital.point.longitude,
      'geohash': request.geohash,
      'note': request.note,
      'status': request.status.name,
      'createdAt': request.createdAt,
      'expiresAt': request.expiresAt,
    };
  }

  static Result<BloodRequest> fromMap(String id, Map<String, dynamic> map) {
    final requesterUid = map['requesterUid'];
    final requesterName = map['requesterName'];
    final groupName = map['bloodGroup'];
    final units = map['units'];
    final urgencyName = map['urgency'];
    final hospitalId = map['hospitalId'];
    final note = map['note'];
    final statusName = map['status'];
    final createdAt = map['createdAt'];
    final expiresAt = map['expiresAt'];

    if (requesterUid is! String ||
        requesterName is! String ||
        groupName is! String ||
        units is! int ||
        urgencyName is! String ||
        hospitalId is! String ||
        statusName is! String ||
        createdAt is! DateTime ||
        expiresAt is! DateTime ||
        (note != null && note is! String)) {
      return const Err<BloodRequest>(_unreadable);
    }

    final bloodGroup = BloodGroup.values.asNameMap()[groupName];
    final urgency = RequestUrgency.values.asNameMap()[urgencyName];
    final status = RequestStatus.values.asNameMap()[statusName];
    final hospital = LocationCatalog.findById(hospitalId);
    if (bloodGroup == null ||
        urgency == null ||
        status == null ||
        hospital == null) {
      return const Err<BloodRequest>(_unreadable);
    }

    return Success<BloodRequest>(
      BloodRequest(
        id: id,
        requesterUid: requesterUid,
        requesterName: requesterName,
        bloodGroup: bloodGroup,
        unitsNeeded: units,
        urgency: urgency,
        hospital: hospital,
        note: note is String ? note : '',
        status: status,
        createdAt: createdAt,
        expiresAt: expiresAt,
      ),
    );
  }
}
