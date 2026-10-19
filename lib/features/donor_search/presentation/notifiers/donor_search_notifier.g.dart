// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State of the donor-search tab. `AsyncData(null)` = no search run yet,
/// `AsyncLoading` = searching, `AsyncData(result)` = done, `AsyncError`
/// = a typed `Failure`.

@ProviderFor(DonorSearch)
const donorSearchProvider = DonorSearchProvider._();

/// State of the donor-search tab. `AsyncData(null)` = no search run yet,
/// `AsyncLoading` = searching, `AsyncData(result)` = done, `AsyncError`
/// = a typed `Failure`.
final class DonorSearchProvider
    extends $AsyncNotifierProvider<DonorSearch, DonorSearchResult?> {
  /// State of the donor-search tab. `AsyncData(null)` = no search run yet,
  /// `AsyncLoading` = searching, `AsyncData(result)` = done, `AsyncError`
  /// = a typed `Failure`.
  const DonorSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'donorSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$donorSearchHash();

  @$internal
  @override
  DonorSearch create() => DonorSearch();
}

String _$donorSearchHash() => r'35abef32af49e947448d2811c3cd45bf5bb35092';

/// State of the donor-search tab. `AsyncData(null)` = no search run yet,
/// `AsyncLoading` = searching, `AsyncData(result)` = done, `AsyncError`
/// = a typed `Failure`.

abstract class _$DonorSearch extends $AsyncNotifier<DonorSearchResult?> {
  FutureOr<DonorSearchResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<DonorSearchResult?>, DonorSearchResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DonorSearchResult?>, DonorSearchResult?>,
              AsyncValue<DonorSearchResult?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
