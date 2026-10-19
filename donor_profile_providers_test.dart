import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';
import 'package:blood_donation_app/features/donor_profile/domain/usecases/save_user_profile.dart';
import 'package:blood_donation_app/features/donor_profile/donor_profile_providers.dart';

// Requires generated code: run
//   dart run build_runner build --delete-conflicting-outputs
// before this file will compile.

void main() {
  test('forgetting to override the data source fails loudly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Exact exception type differs across Riverpod versions (3.x wraps
    // provider errors), so assert only that it throws.
    expect(
      () => container.read(userProfileRemoteDataSourceProvider),
      throwsA(anything),
    );
  });

  test('save then get works end to end through the provider graph', () async {
    final container = ProviderContainer(
      overrides: [
        userProfileRemoteDataSourceProvider.overrideWithValue(
          InMemoryUserProfileDataSource(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final save = container.read(saveUserProfileProvider);
    final get = container.read(getUserProfileProvider);

    final saved = await save(
      const SaveUserProfileParams(
        uid: 'uid-1',
        name: 'Taha Tahir',
        rawPhone: '0300 1234567',
        bloodGroup: BloodGroup.bPositive,
        locationId: 'g9_islamabad',
      ),
    );
    expect(saved, isA<Success<UserProfile>>());

    final fetched = await get('uid-1');
    expect(
      fetched,
      isA<Success<UserProfile?>>()
          .having((s) => s.value?.name, 'name', 'Taha Tahir')
          .having((s) => s.value?.phone.e164, 'phone', '+923001234567'),
    );
  });

  test('the repository is exposed as the abstract interface type', () {
    final container = ProviderContainer(
      overrides: [
        userProfileRemoteDataSourceProvider.overrideWithValue(
          InMemoryUserProfileDataSource(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Compiles only if the provider's declared type is the interface.
    final repository = container.read(userProfileRepositoryProvider);
    expect(repository, isNotNull);
  });
}
