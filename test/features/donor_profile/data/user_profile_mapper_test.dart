import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

UserProfile _sampleProfile({DateTime? lastDonationDate}) {
  final phone =
      (PhoneNumber.parse('03001234567') as Success<PhoneNumber>).value;
  return UserProfile(
    uid: 'uid-1',
    name: 'Taha Tahir',
    phone: phone,
    bloodGroup: BloodGroup.bPositive,
    location: LocationCatalog.all.firstWhere((l) => l.id == 'g9_islamabad'),
    lastDonationDate: lastDonationDate,
    isAvailable: true,
    isVisible: true,
    createdAt: DateTime(2026, 2, 3, 4, 5),
  );
}

void main() {
  group('toMap', () {
    test('stores enum name, catalog id and a 9-char geohash', () {
      final map = UserProfileMapper.toMap(_sampleProfile());

      expect(map['bloodGroup'], 'bPositive');
      expect(map['locationId'], 'g9_islamabad');
      expect(map['phone'], '+923001234567');
      expect(
        map['geohash'],
        isA<String>().having((s) => s.length, 'length', 9),
      );
      expect(map['latitude'], isA<double>());
      expect(map['longitude'], isA<double>());
    });
  });

  group('round trip', () {
    test('profile with a last donation date survives toMap -> fromMap', () {
      final original = _sampleProfile(lastDonationDate: DateTime(2026, 1, 1));
      final result = UserProfileMapper.fromMap(
        original.uid,
        UserProfileMapper.toMap(original),
      );

      expect(
        result,
        isA<Success<UserProfile>>().having((s) => s.value, 'value', original),
      );
    });

    test('profile that never donated survives too', () {
      final original = _sampleProfile();
      final result = UserProfileMapper.fromMap(
        original.uid,
        UserProfileMapper.toMap(original),
      );

      expect(
        result,
        isA<Success<UserProfile>>().having(
          (s) => s.value.lastDonationDate,
          'lastDonationDate',
          isNull,
        ),
      );
    });
  });

  group('fromMap on bad documents returns a failure, never throws', () {
    Map<String, dynamic> validMap() =>
        UserProfileMapper.toMap(_sampleProfile());

    void expectUnreadable(Map<String, dynamic> map) {
      expect(
        UserProfileMapper.fromMap('uid-1', map),
        isA<Err<UserProfile>>().having(
          (e) => e.failure,
          'failure',
          isA<ServerFailure>(),
        ),
      );
    }

    for (final key in [
      'name',
      'phone',
      'bloodGroup',
      'locationId',
      'createdAt',
    ]) {
      test('missing "$key"', () {
        expectUnreadable(validMap()..remove(key));
      });
    }

    test('unknown blood group', () {
      expectUnreadable(validMap()..['bloodGroup'] = 'zPositive');
    });

    test('location no longer in the catalog', () {
      expectUnreadable(validMap()..['locationId'] = 'removed_area');
    });

    test('malformed phone', () {
      expectUnreadable(validMap()..['phone'] = 'not-a-number');
    });

    test('wrong type for name', () {
      expectUnreadable(validMap()..['name'] = 42);
    });

    test('lastDonationDate of the wrong type', () {
      expectUnreadable(validMap()..['lastDonationDate'] = '2026-01-01');
    });
  });

  test('missing privacy flags default to hidden and unavailable', () {
    final map = UserProfileMapper.toMap(_sampleProfile())
      ..remove('isVisible')
      ..remove('isAvailable');

    final result = UserProfileMapper.fromMap('uid-1', map);

    expect(
      result,
      isA<Success<UserProfile>>()
          .having((s) => s.value.isVisible, 'isVisible', isFalse)
          .having((s) => s.value.isAvailable, 'isAvailable', isFalse),
    );
  });
}
