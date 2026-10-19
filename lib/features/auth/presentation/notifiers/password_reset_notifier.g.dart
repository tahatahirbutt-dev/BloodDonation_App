// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `AsyncData(false)` = nothing sent yet, `AsyncData(true)` = request
/// accepted, `AsyncLoading` / `AsyncError` as usual.

@ProviderFor(PasswordReset)
const passwordResetProvider = PasswordResetProvider._();

/// `AsyncData(false)` = nothing sent yet, `AsyncData(true)` = request
/// accepted, `AsyncLoading` / `AsyncError` as usual.
final class PasswordResetProvider
    extends $AsyncNotifierProvider<PasswordReset, bool> {
  /// `AsyncData(false)` = nothing sent yet, `AsyncData(true)` = request
  /// accepted, `AsyncLoading` / `AsyncError` as usual.
  const PasswordResetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordResetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordResetHash();

  @$internal
  @override
  PasswordReset create() => PasswordReset();
}

String _$passwordResetHash() => r'1dec99c58f196c426717724e24170979a9bfe22a';

/// `AsyncData(false)` = nothing sent yet, `AsyncData(true)` = request
/// accepted, `AsyncLoading` / `AsyncError` as usual.

abstract class _$PasswordReset extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
