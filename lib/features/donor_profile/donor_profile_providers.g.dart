// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deliberately has no default. `main()` must override it with the
/// Firestore implementation (or the in-memory one while developing), and
/// tests override it with a fake. Forgetting fails loudly at startup
/// instead of silently running against the wrong store.

@ProviderFor(userProfileRemoteDataSource)
const userProfileRemoteDataSourceProvider =
    UserProfileRemoteDataSourceProvider._();

/// Deliberately has no default. `main()` must override it with the
/// Firestore implementation (or the in-memory one while developing), and
/// tests override it with a fake. Forgetting fails loudly at startup
/// instead of silently running against the wrong store.

final class UserProfileRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          UserProfileRemoteDataSource,
          UserProfileRemoteDataSource,
          UserProfileRemoteDataSource
        >
    with $Provider<UserProfileRemoteDataSource> {
  /// Deliberately has no default. `main()` must override it with the
  /// Firestore implementation (or the in-memory one while developing), and
  /// tests override it with a fake. Forgetting fails loudly at startup
  /// instead of silently running against the wrong store.
  const UserProfileRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<UserProfileRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileRemoteDataSource create(Ref ref) {
    return userProfileRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileRemoteDataSource>(value),
    );
  }
}

String _$userProfileRemoteDataSourceHash() =>
    r'ff32ead8839701ec5c7206d25ad6d35713c8aa86';

@ProviderFor(userProfileRepository)
const userProfileRepositoryProvider = UserProfileRepositoryProvider._();

final class UserProfileRepositoryProvider
    extends
        $FunctionalProvider<
          UserProfileRepository,
          UserProfileRepository,
          UserProfileRepository
        >
    with $Provider<UserProfileRepository> {
  const UserProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileRepository create(Ref ref) {
    return userProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileRepository>(value),
    );
  }
}

String _$userProfileRepositoryHash() =>
    r'e8e15cafa7e39a48aad4ec87e1c37b47cfb57af7';

@ProviderFor(saveUserProfile)
const saveUserProfileProvider = SaveUserProfileProvider._();

final class SaveUserProfileProvider
    extends
        $FunctionalProvider<SaveUserProfile, SaveUserProfile, SaveUserProfile>
    with $Provider<SaveUserProfile> {
  const SaveUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveUserProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveUserProfileHash();

  @$internal
  @override
  $ProviderElement<SaveUserProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveUserProfile create(Ref ref) {
    return saveUserProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveUserProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveUserProfile>(value),
    );
  }
}

String _$saveUserProfileHash() => r'1271a265f51c8f33fba43fb5557a9508ddca04f5';

@ProviderFor(getUserProfile)
const getUserProfileProvider = GetUserProfileProvider._();

final class GetUserProfileProvider
    extends $FunctionalProvider<GetUserProfile, GetUserProfile, GetUserProfile>
    with $Provider<GetUserProfile> {
  const GetUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getUserProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getUserProfileHash();

  @$internal
  @override
  $ProviderElement<GetUserProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetUserProfile create(Ref ref) {
    return getUserProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetUserProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetUserProfile>(value),
    );
  }
}

String _$getUserProfileHash() => r'8aeb8a91aadc31c5c66f7e6efcf00c03f0f4cf5c';
