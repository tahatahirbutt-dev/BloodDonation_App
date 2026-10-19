import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../domain/entities/directory_donor.dart';

/// Converts a stored `donors/{uid}` document into a [DirectoryDonor],
/// defensively: anything malformed becomes a typed failure the repository
/// skips, never a cast error.
abstract final class DirectoryDonorMapper {
  static const Failure _unreadable = ServerFailure(
    'A donor entry could not be read.',
  );

  static Result<DirectoryDonor> fromMap(String uid, Map<String, dynamic> map) {
    final name = map['name'];
    final groupName = map['bloodGroup'];
    final locationId = map['locationId'];
    final isAvailable = map['isAvailable'];
    final eligibleFrom = map['eligibleFrom'];

    if (name is! String ||
        groupName is! String ||
        locationId is! String ||
        isAvailable is! bool ||
        (eligibleFrom != null && eligibleFrom is! DateTime)) {
      return const Err<DirectoryDonor>(_unreadable);
    }

    final bloodGroup = BloodGroup.values.asNameMap()[groupName];
    final location = LocationCatalog.findById(locationId);
    if (bloodGroup == null || location == null) {
      return const Err<DirectoryDonor>(_unreadable);
    }

    return Success<DirectoryDonor>(
      DirectoryDonor(
        uid: uid,
        name: name,
        bloodGroup: bloodGroup,
        location: location,
        isAvailable: isAvailable,
        eligibleFrom: eligibleFrom is DateTime ? eligibleFrom : null,
      ),
    );
  }
}
