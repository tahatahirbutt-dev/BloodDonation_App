import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/distance_calculator.dart';
import 'package:blood_donation_app/core/geo/geohash_cover.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../entities/donor_directory_page.dart';
import '../entities/donor_match.dart';
import '../entities/donor_search_result.dart';
import '../repositories/donor_directory_repository.dart';

/// "Which donors could give blood to a [recipientGroup] patient within
/// [radiusKm] of the catalog location [centerLocationId]?"
///
/// Steps: work out which donor groups are compatible, turn the radius into
/// geohash prefixes, ask the directory, then apply the exact rules the
/// database cannot (real distance, availability, the 90-day interval) and
/// sort nearest first.
class SearchDonors {
  SearchDonors(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const double minRadiusKm = 1;
  static const double maxRadiusKm = 100;

  final DonorDirectoryRepository _repository;
  final DateTime Function() _clock;

  Future<Result<DonorSearchResult>> call({
    required BloodGroup recipientGroup,
    required String centerLocationId,
    required double radiusKm,
    String? excludeUid,
  }) async {
    if (radiusKm.isNaN || radiusKm < minRadiusKm || radiusKm > maxRadiusKm) {
      return const Err<DonorSearchResult>(
        ValidationFailure('Choose a search radius between 1 and 100 km.'),
      );
    }

    final center = LocationCatalog.findById(centerLocationId);
    if (center == null) {
      return const Err<DonorSearchResult>(
        ValidationFailure('Choose where to search from.', field: 'center'),
      );
    }

    final now = _clock();
    final result = await _repository.findDonors(
      donorGroups: recipientGroup.compatibleDonorGroups,
      geohashPrefixes: GeohashCover.prefixesFor(center.point, radiusKm),
    );

    switch (result) {
      case Err<DonorDirectoryPage>(:final failure):
        return Err<DonorSearchResult>(failure);
      case Success<DonorDirectoryPage>(:final value):
        final matches =
            <DonorMatch>[
                for (final donor in value.donors)
                  if (donor.uid != excludeUid &&
                      donor.isAvailable &&
                      donor.isEligibleOn(now))
                    DonorMatch(
                      donor: donor,
                      distanceKm: DistanceCalculator.haversineKm(
                        center.point,
                        donor.location.point,
                      ),
                    ),
              ].where((match) => match.distanceKm <= radiusKm).toList()
              ..sort((a, b) {
                final byDistance = a.distanceKm.compareTo(b.distanceKm);
                return byDistance != 0
                    ? byDistance
                    : a.donor.name.compareTo(b.donor.name);
              });

        return Success<DonorSearchResult>(
          DonorSearchResult(
            matches: matches,
            mayBeIncomplete: value.mayBeIncomplete,
          ),
        );
    }
  }
}
