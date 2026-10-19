// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// No default on purpose: `bootstrap()` overrides it with the Firestore
/// implementation and tests with the in-memory one.

@ProviderFor(donorDirectoryRemoteDataSource)
const donorDirectoryRemoteDataSourceProvider =
    DonorDirectoryRemoteDataSourceProvider._();

/// No default on purpose: `bootstrap()` overrides it with the Firestore
/// implementation and tests with the in-memory one.

final class DonorDirectoryRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          DonorDirectoryRemoteDataSource,
          DonorDirectoryRemoteDataSource,
          DonorDirectoryRemoteDataSource
        >
    with $Provider<DonorDirectoryRemoteDataSource> {
  /// No default on purpose: `bootstrap()` overrides it with the Firestore
  /// implementation and tests with the in-memory one.
  const DonorDirectoryRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorDirectoryRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorDirectoryRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<DonorDirectoryRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DonorDirectoryRemoteDataSource create(Ref ref) {
    return donorDirectoryRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonorDirectoryRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonorDirectoryRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$donorDirectoryRemoteDataSourceHash() =>
    r'cde7002889e924a40c62caba04ec92ff7d7f09a8';

@ProviderFor(donorDirectoryRepository)
const donorDirectoryRepositoryProvider = DonorDirectoryRepositoryProvider._();

final class DonorDirectoryRepositoryProvider
    extends
        $FunctionalProvider<
          DonorDirectoryRepository,
          DonorDirectoryRepository,
          DonorDirectoryRepository
        >
    with $Provider<DonorDirectoryRepository> {
  const DonorDirectoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorDirectoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorDirectoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DonorDirectoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DonorDirectoryRepository create(Ref ref) {
    return donorDirectoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DonorDirectoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DonorDirectoryRepository>(value),
    );
  }
}

String _$donorDirectoryRepositoryHash() =>
    r'f32088467a59950a4ff9014cef61b46f182df25b';

@ProviderFor(searchDonors)
const searchDonorsProvider = SearchDonorsProvider._();

final class SearchDonorsProvider
    extends $FunctionalProvider<SearchDonors, SearchDonors, SearchDonors>
    with $Provider<SearchDonors> {
  const SearchDonorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchDonorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchDonorsHash();

  @$internal
  @override
  $ProviderElement<SearchDonors> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchDonors create(Ref ref) {
    return searchDonors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchDonors value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchDonors>(value),
    );
  }
}

String _$searchDonorsHash() => r'b21f903a38e8294230f3c40bbf3fdc3aa0f3ddb3';
