import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:blood_donation_app/features/donor_profile/donor_profile_providers.dart';

void main() {
  test('repository provider composes the overridden remote data source', () {
    final remote = InMemoryUserProfileDataSource();
    final container = ProviderContainer(
      overrides: [
        userProfileRemoteDataSourceProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(userProfileRepositoryProvider),
      isA<UserProfileRepositoryImpl>(),
    );
  });

  test(
    'use-case providers expose instances backed by the repository provider',
    () {
      final remote = InMemoryUserProfileDataSource();
      final container = ProviderContainer(
        overrides: [
          userProfileRemoteDataSourceProvider.overrideWithValue(remote),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(saveUserProfileProvider), isNotNull);
      expect(container.read(getUserProfileProvider), isNotNull);
    },
  );
}
