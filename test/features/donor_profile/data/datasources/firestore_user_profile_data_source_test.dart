import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/firestore_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../../../support/profile_fixtures.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreUserProfileDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = FirestoreUserProfileDataSource(firestore);
  });

  Future<Map<String, dynamic>?> read(String collection, String uid) async {
    final snapshot = await firestore.collection(collection).doc(uid).get();
    return snapshot.exists ? snapshot.data() : null;
  }

  group('upsert', () {
    test('writes the full private profile with Timestamps', () async {
      final profile = sampleProfile(lastDonationDate: DateTime(2026, 1, 10));

      await dataSource.upsert('uid-1', UserProfileMapper.toMap(profile));

      final stored = (await read('users', 'uid-1'))!;
      expect(stored['phone'], '+923001234567');
      expect(stored['createdAt'], isA<Timestamp>());
      expect(stored['lastDonationDate'], isA<Timestamp>());
    });

    test('publishes a public entry WITHOUT private fields', () async {
      final profile = sampleProfile(lastDonationDate: DateTime(2026, 1, 10));

      await dataSource.upsert('uid-1', UserProfileMapper.toMap(profile));

      final donor = (await read('donors', 'uid-1'))!;
      expect(
        donor.keys,
        unorderedEquals(<String>[
          'name',
          'bloodGroup',
          'locationId',
          'latitude',
          'longitude',
          'geohash',
          'isAvailable',
          'eligibleFrom',
        ]),
      );
      expect(donor['eligibleFrom'], Timestamp.fromDate(DateTime(2026, 4, 10)));
    });

    test(
      'hiding a profile removes the public entry but keeps the profile',
      () async {
        final map = UserProfileMapper.toMap(sampleProfile());
        await dataSource.upsert('uid-1', map);
        expect(await read('donors', 'uid-1'), isNotNull);

        await dataSource.upsert('uid-1', {...map, 'isVisible': false});

        expect(await read('donors', 'uid-1'), isNull);
        expect(await read('users', 'uid-1'), isNotNull);
      },
    );

    test(
      'never creates a public entry for a profile saved as hidden',
      () async {
        final map = {
          ...UserProfileMapper.toMap(sampleProfile()),
          'isVisible': false,
        };

        await dataSource.upsert('uid-1', map);

        expect(await read('donors', 'uid-1'), isNull);
      },
    );
  });

  group('fetch', () {
    test('returns null when there is no document', () async {
      expect(await dataSource.fetch('nobody'), isNull);
    });

    test('round-trips a profile through the real mapper', () async {
      final profile = sampleProfile(lastDonationDate: DateTime(2026, 1, 10));
      await dataSource.upsert('uid-1', UserProfileMapper.toMap(profile));

      final fetched = await dataSource.fetch('uid-1');
      final result = UserProfileMapper.fromMap('uid-1', fetched!);

      expect(result, isA<Success<UserProfile>>());
      expect((result as Success<UserProfile>).value, profile);
    });

    test('hands the mapper DateTime, never Timestamp', () async {
      await dataSource.upsert(
        'uid-1',
        UserProfileMapper.toMap(sampleProfile()),
      );

      final fetched = (await dataSource.fetch('uid-1'))!;

      expect(fetched['createdAt'], isA<DateTime>());
    });
  });
}
