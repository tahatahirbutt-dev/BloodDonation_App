import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';
import 'package:blood_donation_app/features/donor_profile/domain/repositories/user_profile_repository.dart';
import 'package:blood_donation_app/features/donor_profile/domain/usecases/save_user_profile.dart';

/// Hand-written fake: proves the use case only depends on the interface
/// (Liskov) and keeps tests free of any mocking package.
class _FakeUserProfileRepository implements UserProfileRepository {
  UserProfile? existing;
  Failure? getFailure;
  Failure? saveFailure;
  UserProfile? saved;

  @override
  Future<Result<UserProfile?>> getProfile(String uid) async {
    final failure = getFailure;
    if (failure != null) return Err<UserProfile?>(failure);
    return Success<UserProfile?>(existing);
  }

  @override
  Future<Result<void>> saveProfile(UserProfile profile) async {
    final failure = saveFailure;
    if (failure != null) return Err<void>(failure);
    saved = profile;
    return const Success<void>(null);
  }
}

void main() {
  final fixedNow = DateTime(2026, 6, 15, 10);
  late _FakeUserProfileRepository repository;
  late SaveUserProfile saveUserProfile;

  SaveUserProfileParams params({
    String name = 'Taha Tahir',
    String phone = '0300 1234567',
    String locationId = 'g9_islamabad',
    DateTime? lastDonationDate,
  }) {
    return SaveUserProfileParams(
      uid: 'uid-1',
      name: name,
      rawPhone: phone,
      bloodGroup: BloodGroup.bPositive,
      locationId: locationId,
      lastDonationDate: lastDonationDate,
    );
  }

  Failure failureOf(Result<Object?> result) => switch (result) {
    Err(:final failure) => failure,
    Success() => fail('expected a failure but got Success'),
  };

  setUp(() {
    repository = _FakeUserProfileRepository();
    saveUserProfile = SaveUserProfile(repository, clock: () => fixedNow);
  });

  test(
    'saves a valid profile, trimming the name and normalizing the phone',
    () async {
      final result = await saveUserProfile(params(name: '  Taha Tahir  '));

      expect(result, isA<Success<UserProfile>>());
      final saved = repository.saved;
      expect(saved, isNotNull);
      expect(saved!.name, 'Taha Tahir');
      expect(saved.phone.e164, '+923001234567');
      expect(saved.location.id, 'g9_islamabad');
      expect(saved.createdAt, fixedNow);
      expect(saved.geohash, hasLength(9));
    },
  );

  test('editing keeps the original createdAt', () async {
    final original = DateTime(2026, 1, 2);
    final firstSave = await SaveUserProfile(repository, clock: () => original)(
      params(),
    );
    expect(firstSave, isA<Success<UserProfile>>());
    repository.existing = repository.saved;

    await saveUserProfile(params(name: 'Taha T.'));

    expect(repository.saved!.name, 'Taha T.');
    expect(repository.saved!.createdAt, original);
  });

  group('validation', () {
    test('rejects a too-short name', () async {
      final failure = failureOf(await saveUserProfile(params(name: ' A ')));
      expect(
        failure,
        isA<ValidationFailure>().having((f) => f.field, 'field', 'name'),
      );
      expect(repository.saved, isNull);
    });

    test('rejects an invalid phone', () async {
      final failure = failureOf(await saveUserProfile(params(phone: '123')));
      expect(
        failure,
        isA<ValidationFailure>().having((f) => f.field, 'field', 'phone'),
      );
    });

    test('rejects an unknown location id', () async {
      final failure = failureOf(
        await saveUserProfile(params(locationId: 'atlantis')),
      );
      expect(
        failure,
        isA<ValidationFailure>().having((f) => f.field, 'field', 'location'),
      );
    });

    test('rejects a hospital as a home area', () async {
      final hospitalId = LocationCatalog.all
          .firstWhere((l) => l.id == 'afit_rawalpindi')
          .id;
      final failure = failureOf(
        await saveUserProfile(params(locationId: hospitalId)),
      );
      expect(
        failure,
        isA<ValidationFailure>().having((f) => f.field, 'field', 'location'),
      );
    });

    test('rejects a last-donation date in the future', () async {
      final failure = failureOf(
        await saveUserProfile(params(lastDonationDate: DateTime(2026, 6, 16))),
      );
      expect(
        failure,
        isA<ValidationFailure>().having(
          (f) => f.field,
          'field',
          'lastDonationDate',
        ),
      );
    });

    test('accepts a last-donation date of today', () async {
      final result = await saveUserProfile(
        params(lastDonationDate: DateTime(2026, 6, 15, 23)),
      );
      expect(result, isA<Success<UserProfile>>());
      expect(repository.saved!.lastDonationDate, DateTime(2026, 6, 15));
    });
  });

  group('repository failures', () {
    test('propagates a failure from reading the existing profile', () async {
      repository.getFailure = const NetworkFailure();
      final failure = failureOf(await saveUserProfile(params()));
      expect(failure, const NetworkFailure());
      expect(repository.saved, isNull);
    });

    test('propagates a failure from saving', () async {
      repository.saveFailure = const ServerFailure();
      final failure = failureOf(await saveUserProfile(params()));
      expect(failure, const ServerFailure());
    });
  });
}
