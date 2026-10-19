import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../entities/donor_directory_page.dart';

/// Read-only access to the public donor directory.
abstract interface class DonorDirectoryRepository {
  /// Available donors whose group is in [donorGroups] and whose geohash
  /// starts with any of [geohashPrefixes]. Unreadable entries are
  /// skipped. Duplicates (the same donor matched by two prefixes) are
  /// removed. Eligibility and exact distance are NOT applied here.
  Future<Result<DonorDirectoryPage>> findDonors({
    required List<BloodGroup> donorGroups,
    required List<String> geohashPrefixes,
  });
}
