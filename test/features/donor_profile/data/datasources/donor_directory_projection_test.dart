import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/features/donor_profile/data/datasources/donor_directory_projection.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';

import '../../../../support/profile_fixtures.dart';

void main() {
  group('DonorDirectoryProjection', () {
    test('returns null for a hidden profile', () {
      final map = UserProfileMapper.toMap(sampleProfile())
        ..['isVisible'] = false;

      expect(DonorDirectoryProjection.fromProfileMap(map), isNull);
    });

    test('a visible profile exposes only the public fields', () {
      final map = UserProfileMapper.toMap(sampleProfile());

      final projection = DonorDirectoryProjection.fromProfileMap(map)!;

      expect(
        projection.keys,
        unorderedEquals(<String>[
          'name',
          'bloodGroup',
          'locationId',
          'latitude',
          'longitude',
          'geohash',
          'isAvailable',
        ]),
      );
      expect(projection.containsKey('phone'), isFalse);
      expect(projection.containsKey('createdAt'), isFalse);
      expect(projection.containsKey('lastDonationDate'), isFalse);
    });

    test('publishes the date they become eligible, not the donation date', () {
      final map = UserProfileMapper.toMap(
        sampleProfile(lastDonationDate: DateTime(2026, 1, 10)),
      );

      final projection = DonorDirectoryProjection.fromProfileMap(map)!;

      // 10 Jan + 90 days = 10 Apr.
      expect(projection['eligibleFrom'], DateTime(2026, 4, 10));
      expect(projection.containsKey('lastDonationDate'), isFalse);
    });

    test('has no eligibleFrom for someone who has never donated', () {
      final map = UserProfileMapper.toMap(sampleProfile());

      final projection = DonorDirectoryProjection.fromProfileMap(map)!;

      expect(projection.containsKey('eligibleFrom'), isFalse);
    });

    test('isAvailable follows the profile, and defaults to false', () {
      final map = UserProfileMapper.toMap(sampleProfile())
        ..['isAvailable'] = false;
      expect(
        DonorDirectoryProjection.fromProfileMap(map)!['isAvailable'],
        isFalse,
      );

      map.remove('isAvailable');
      expect(
        DonorDirectoryProjection.fromProfileMap(map)!['isAvailable'],
        isFalse,
      );
    });

    test('is fed by the real mapper output (contract check)', () {
      // If the mapper renames a key, this fails here instead of silently
      // publishing an empty directory entry.
      final map = UserProfileMapper.toMap(sampleProfile());
      final projection = DonorDirectoryProjection.fromProfileMap(map)!;

      expect(projection['name'], 'Taha Tahir');
      expect(projection['bloodGroup'], 'bPositive');
      expect(projection['locationId'], 'g9_islamabad');
      expect(projection['geohash'], isA<String>());
    });
  });
}
