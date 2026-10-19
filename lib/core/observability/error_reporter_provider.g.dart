// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_reporter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Defaults to a no-op so tests and previews never need Firebase.
/// `bootstrap()` overrides it with the Crashlytics implementation.

@ProviderFor(errorReporter)
const errorReporterProvider = ErrorReporterProvider._();

/// Defaults to a no-op so tests and previews never need Firebase.
/// `bootstrap()` overrides it with the Crashlytics implementation.

final class ErrorReporterProvider
    extends $FunctionalProvider<ErrorReporter, ErrorReporter, ErrorReporter>
    with $Provider<ErrorReporter> {
  /// Defaults to a no-op so tests and previews never need Firebase.
  /// `bootstrap()` overrides it with the Crashlytics implementation.
  const ErrorReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorReporterHash();

  @$internal
  @override
  $ProviderElement<ErrorReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ErrorReporter create(Ref ref) {
    return errorReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorReporter>(value),
    );
  }
}

String _$errorReporterHash() => r'43e5017bd90b8e2c186794d98ca52d8369f59ef3';
