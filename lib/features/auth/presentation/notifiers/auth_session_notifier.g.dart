// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Who is signed in right now. `null` data means signed out.
///
/// Kept alive for the whole app. `build` resolves on the first event from
/// the auth stream (so the gate shows a spinner, not a flash of the login
/// screen, while the saved session is restored) and later events update
/// the state in place.

@ProviderFor(AuthSession)
const authSessionProvider = AuthSessionProvider._();

/// Who is signed in right now. `null` data means signed out.
///
/// Kept alive for the whole app. `build` resolves on the first event from
/// the auth stream (so the gate shows a spinner, not a flash of the login
/// screen, while the saved session is restored) and later events update
/// the state in place.
final class AuthSessionProvider
    extends $AsyncNotifierProvider<AuthSession, AuthUser?> {
  /// Who is signed in right now. `null` data means signed out.
  ///
  /// Kept alive for the whole app. `build` resolves on the first event from
  /// the auth stream (so the gate shows a spinner, not a flash of the login
  /// screen, while the saved session is restored) and later events update
  /// the state in place.
  const AuthSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionHash();

  @$internal
  @override
  AuthSession create() => AuthSession();
}

String _$authSessionHash() => r'af84651a9d0784bfcce66546e276b911d54b860a';

/// Who is signed in right now. `null` data means signed out.
///
/// Kept alive for the whole app. `build` resolves on the first event from
/// the auth stream (so the gate shows a spinner, not a flash of the login
/// screen, while the saved session is restored) and later events update
/// the state in place.

abstract class _$AuthSession extends $AsyncNotifier<AuthUser?> {
  FutureOr<AuthUser?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AuthUser?>, AuthUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthUser?>, AuthUser?>,
              AsyncValue<AuthUser?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
