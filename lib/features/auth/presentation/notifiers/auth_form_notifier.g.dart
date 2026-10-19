// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_form_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State of the sign-in / sign-up form: idle (`AsyncData`), submitting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`).
/// On success the auth session changes and the gate swaps the screen, so
/// no navigation happens here.

@ProviderFor(AuthForm)
const authFormProvider = AuthFormProvider._();

/// State of the sign-in / sign-up form: idle (`AsyncData`), submitting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`).
/// On success the auth session changes and the gate swaps the screen, so
/// no navigation happens here.
final class AuthFormProvider extends $AsyncNotifierProvider<AuthForm, void> {
  /// State of the sign-in / sign-up form: idle (`AsyncData`), submitting
  /// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`).
  /// On success the auth session changes and the gate swaps the screen, so
  /// no navigation happens here.
  const AuthFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authFormHash();

  @$internal
  @override
  AuthForm create() => AuthForm();
}

String _$authFormHash() => r'8a99fccfa8030c0d7bd81bdadc582a49c708af24';

/// State of the sign-in / sign-up form: idle (`AsyncData`), submitting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`).
/// On success the auth session changes and the gate swaps the screen, so
/// no navigation happens here.

abstract class _$AuthForm extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
