import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

/// Converts between the domain [UserProfile] and the stored document.
///
/// Reading is defensive on purpose: a document can be hand-edited in the
/// console, written by an older app version, or reference a catalog
/// entry that was later removed. Any of those must become a typed
/// failure the UI can show — never a cast exception that crashes a screen.
abstract final class UserProfileMapper {
  static const Failure _unreadable = ServerFailure(
    'Your saved profile could not be read. Please re-enter your details.',
  );

  static Map<String, dynamic> toMap(UserProfile profile) {
    return <String, dynamic>{
      'name': profile.name,
      'phone': profile.phone.e164,
      // Persist the enum *name*, not the display label.
      'bloodGroup': profile.bloodGroup.name,
      'locationId': profile.location.id,
      // Denormalized for geo queries; always derived from the catalog.
      'latitude': profile.location.point.latitude,
      'longitude': profile.location.point.longitude,
      'geohash': profile.geohash,
      'lastDonationDate': profile.lastDonationDate,
      'isAvailable': profile.isAvailable,
      'isVisible': profile.isVisible,
      'createdAt': profile.createdAt,
    };
  }

  static Result<UserProfile> fromMap(String uid, Map<String, dynamic> map) {
    final name = map['name'];
    final rawPhone = map['phone'];
    final groupName = map['bloodGroup'];
    final locationId = map['locationId'];
    final createdAt = map['createdAt'];
    final lastDonation = map['lastDonationDate'];

    if (name is! String ||
        rawPhone is! String ||
        groupName is! String ||
        locationId is! String ||
        createdAt is! DateTime ||
        (lastDonation != null && lastDonation is! DateTime)) {
      return const Err<UserProfile>(_unreadable);
    }

    final bloodGroup = BloodGroup.values.asNameMap()[groupName];
    final location = LocationCatalog.findById(locationId);
    if (bloodGroup == null || location == null) {
      return const Err<UserProfile>(_unreadable);
    }

    final PhoneNumber phone;
    switch (PhoneNumber.parse(rawPhone)) {
      case Success<PhoneNumber>(:final value):
        phone = value;
      case Err<PhoneNumber>():
        return const Err<UserProfile>(_unreadable);
    }

    return Success<UserProfile>(
      UserProfile(
        uid: uid,
        name: name,
        phone: phone,
        bloodGroup: bloodGroup,
        location: location,
        lastDonationDate: lastDonation is DateTime ? lastDonation : null,
        // Privacy-safe defaults: if a flag is missing or malformed, the
        // person is treated as hidden/unavailable, never as visible.
        isAvailable: map['isAvailable'] == true,
        isVisible: map['isVisible'] == true,
        createdAt: createdAt,
      ),
    );
  }
}
