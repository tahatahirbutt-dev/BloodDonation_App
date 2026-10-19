import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/distance_calculator.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_search/data/datasources/in_memory_donor_directory_data_source.dart';
import 'package:blood_donation_app/features/donor_search/data/repositories/donor_directory_repository_impl.dart';
import 'package:blood_donation_app/features/donor_search/domain/entities/donor_search_result.dart';
import 'package:blood_donation_app/features/donor_search/domain/usecases/search_donors.dart';

import '../../../support/request_fixtures.dart';

void main() {
  late InMemoryDonorDirectoryDataSource directory;
  late SearchDonors search;

  setUp(() {
    directory = InMemoryDonorDirectoryDataSource();
    search = SearchDonors(
      DonorDirectoryRepositoryImpl(directory),
      clock: () => testNow,
    );
  });

  Future<DonorSearchResult> run({
    BloodGroup recipient = BloodGroup.bPositive,
    String center = 'g9_islamabad',
    double radiusKm = 50,
    String? excludeUid,
  }) async {
    final result = await search(
      recipientGroup: recipient,
      centerLocationId: center,
      radiusKm: radiusKm,
      excludeUid: excludeUid,
    );
    return (result as Success<DonorSearchResult>).value;
  }

  List<String> uids(DonorSearchResult result) =>
      result.matches.map((m) => m.donor.uid).toList();

  void seed(
    String uid,
    BloodGroup group,
    String locationId, {
    bool isAvailable = true,
    DateTime? eligibleFrom,
  }) {
    directory.seed(
      uid,
      directoryEntry(
        name: 'Donor $uid',
        bloodGroup: group,
        locationId: locationId,
        isAvailable: isAvailable,
        eligibleFrom: eligibleFrom,
      ),
    );
  }

  test('finds donors whose blood can go to the patient', () async {
    seed('b-pos', BloodGroup.bPositive, 'g9_islamabad');
    seed('o-neg', BloodGroup.oNegative, 'g9_islamabad');
    seed('a-pos', BloodGroup.aPositive, 'g9_islamabad'); // cannot give to B+
    seed('ab-pos', BloodGroup.abPositive, 'g9_islamabad'); // cannot give to B+

    final result = await run(recipient: BloodGroup.bPositive);

    expect(uids(result).toSet(), {'b-pos', 'o-neg'});
  });

  test('an O- patient can only be helped by O- donors', () async {
    seed('o-neg', BloodGroup.oNegative, 'g9_islamabad');
    seed('o-pos', BloodGroup.oPositive, 'g9_islamabad');

    expect(uids(await run(recipient: BloodGroup.oNegative)), ['o-neg']);
  });

  test('leaves out unavailable donors, the excluded uid and donors in their '
      '90-day wait', () async {
    seed('ok', BloodGroup.bPositive, 'g9_islamabad');
    seed('away', BloodGroup.bPositive, 'g9_islamabad', isAvailable: false);
    seed('me', BloodGroup.bPositive, 'g9_islamabad');
    seed(
      'waiting',
      BloodGroup.bPositive,
      'g9_islamabad',
      eligibleFrom: testNow.add(const Duration(days: 5)),
    );
    seed(
      'ready',
      BloodGroup.bPositive,
      'g9_islamabad',
      eligibleFrom: testNow.subtract(const Duration(days: 5)),
    );

    final result = await run(excludeUid: 'me');

    expect(uids(result).toSet(), {'ok', 'ready'});
  });

  test('sorts nearest first and reports the straight-line distance', () async {
    seed('far', BloodGroup.bPositive, 'afit_rawalpindi');
    seed('near', BloodGroup.bPositive, 'pims_islamabad');
    seed('same-spot', BloodGroup.bPositive, 'g9_islamabad');

    final result = await run();

    expect(uids(result).first, 'same-spot');
    expect(result.matches.first.distanceKm, closeTo(0, 1e-9));
    final distances = result.matches.map((m) => m.distanceKm).toList();
    expect(distances, [...distances]..sort());
    final g9 = LocationCatalog.all.firstWhere((l) => l.id == 'g9_islamabad');
    final afit = LocationCatalog.all.firstWhere(
      (l) => l.id == 'afit_rawalpindi',
    );
    expect(
      result.matches.last.distanceKm,
      DistanceCalculator.haversineKm(g9.point, afit.point),
    );
  });

  test(
    'the radius is an exact cut-off, not just a geohash neighbourhood',
    () async {
      for (final place in LocationCatalog.all) {
        seed('at-${place.id}', BloodGroup.bPositive, place.id);
      }
      final g9 = LocationCatalog.all.firstWhere((l) => l.id == 'g9_islamabad');

      for (final radius in [1.0, 5.0, 10.0, 25.0, 50.0]) {
        final expected = {
          for (final place in LocationCatalog.all)
            if (DistanceCalculator.haversineKm(g9.point, place.point) <= radius)
              'at-${place.id}',
        };

        final result = await run(radiusKm: radius);

        expect(uids(result).toSet(), expected, reason: 'radius $radius km');
      }
    },
  );

  test('searching around a hospital works too', () async {
    seed('near-pims', BloodGroup.bPositive, 'pims_islamabad');

    final result = await run(center: 'pims_islamabad', radiusKm: 5);

    expect(uids(result), ['near-pims']);
  });

  test('no donors is a success with an empty list', () async {
    final result = await run();

    expect(result.matches, isEmpty);
    expect(result.mayBeIncomplete, isFalse);
  });

  group('input checks', () {
    test('a radius outside 1..100 km is refused', () async {
      for (final radius in [0.0, 0.5, 101.0, double.nan, -3.0]) {
        final result = await search(
          recipientGroup: BloodGroup.bPositive,
          centerLocationId: 'g9_islamabad',
          radiusKm: radius,
        );

        expect(
          (result as Err<DonorSearchResult>).failure,
          isA<ValidationFailure>(),
          reason: '$radius',
        );
      }
    });

    test('an unknown centre is refused on the centre field', () async {
      final result = await search(
        recipientGroup: BloodGroup.bPositive,
        centerLocationId: 'nowhere',
        radiusKm: 10,
      );

      final failure =
          (result as Err<DonorSearchResult>).failure as ValidationFailure;
      expect(failure.field, 'center');
    });
  });

  test('a directory failure is returned as a typed failure', () async {
    directory.failWith = const NetworkFailure();

    final result = await search(
      recipientGroup: BloodGroup.bPositive,
      centerLocationId: 'g9_islamabad',
      radiusKm: 10,
    );

    expect((result as Err<DonorSearchResult>).failure, isA<NetworkFailure>());
  });
}
