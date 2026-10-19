import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';

import '../../domain/entities/donor_response.dart';

/// Converts between [DonorResponse] and its stored document. The document
/// id is the donor's uid, so `donorUid` is also stored as a field: the
/// security rules compare it to the signed-in user.
abstract final class DonorResponseMapper {
  static const Failure _unreadable = ServerFailure(
    'A donor response could not be read.',
  );

  static Map<String, dynamic> toMap(DonorResponse response) {
    return <String, dynamic>{
      'donorUid': response.donorUid,
      'donorName': response.donorName,
      'phone': response.phone.e164,
      'bloodGroup': response.bloodGroup.name,
      'locationId': response.location.id,
      'respondedAt': response.respondedAt,
    };
  }

  static Result<DonorResponse> fromMap(
    String requestId,
    String donorUid,
    Map<String, dynamic> map,
  ) {
    final donorName = map['donorName'];
    final rawPhone = map['phone'];
    final groupName = map['bloodGroup'];
    final locationId = map['locationId'];
    final respondedAt = map['respondedAt'];

    if (donorName is! String ||
        rawPhone is! String ||
        groupName is! String ||
        locationId is! String ||
        respondedAt is! DateTime) {
      return const Err<DonorResponse>(_unreadable);
    }

    final bloodGroup = BloodGroup.values.asNameMap()[groupName];
    final location = LocationCatalog.findById(locationId);
    if (bloodGroup == null || location == null) {
      return const Err<DonorResponse>(_unreadable);
    }

    final PhoneNumber phone;
    switch (PhoneNumber.parse(rawPhone)) {
      case Success<PhoneNumber>(:final value):
        phone = value;
      case Err<PhoneNumber>():
        return const Err<DonorResponse>(_unreadable);
    }

    return Success<DonorResponse>(
      DonorResponse(
        requestId: requestId,
        donorUid: donorUid,
        donorName: donorName,
        phone: phone,
        bloodGroup: bloodGroup,
        location: location,
        respondedAt: respondedAt,
      ),
    );
  }
}
