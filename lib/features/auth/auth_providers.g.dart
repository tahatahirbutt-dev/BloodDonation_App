// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// No default on purpose: `bootstrap()` overrides it with the Firebase
/// implementation and tests override it with a fake. Forgetting fails
/// loudly instead of silently using the wrong backend.

@ProviderFor(authRemoteDataSource)
const authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

/// No default on purpose: `bootstrap()` overrides it with the Firebase
/// implementation and tests override it with a fake. Forgetting fails
/// loudly instead of silently using the wrong backend.

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  /// No default on purpose: `bootstrap()` overrides it with the Firebase
  /// implementation and tests override it with a fake. Forgetting fails
  /// loudly instead of silently using the wrong backend.
  const AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'9caa4a5b43fb55720705417dbfe511dd8300f4f5';

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'32fd4d3f304560d462bd6f860bd7d5f30a1e77ec';

@ProviderFor(signInWithEmail)
const signInWithEmailProvider = SignInWithEmailProvider._();

final class SignInWithEmailProvider
    extends
        $FunctionalProvider<SignInWithEmail, SignInWithEmail, SignInWithEmail>
    with $Provider<SignInWithEmail> {
  const SignInWithEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithEmailHash();

  @$internal
  @override
  $ProviderElement<SignInWithEmail> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInWithEmail create(Ref ref) {
    return signInWithEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithEmail value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithEmail>(value),
    );
  }
}

String _$signInWithEmailHash() => r'10c3dcfa5bcfafcc21056691bd92486f58e7aa3b';

@ProviderFor(signUpWithEmail)
const signUpWithEmailProvider = SignUpWithEmailProvider._();

final class SignUpWithEmailProvider
    extends
        $FunctionalProvider<SignUpWithEmail, SignUpWithEmail, SignUpWithEmail>
    with $Provider<SignUpWithEmail> {
  const SignUpWithEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpWithEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpWithEmailHash();

  @$internal
  @override
  $ProviderElement<SignUpWithEmail> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignUpWithEmail create(Ref ref) {
    return signUpWithEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpWithEmail value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpWithEmail>(value),
    );
  }
}

String _$signUpWithEmailHash() => r'043ba52f93860ffdb09536b33d9e02ab9ff53ded';

@ProviderFor(sendPasswordReset)
const sendPasswordResetProvider = SendPasswordResetProvider._();

final class SendPasswordResetProvider
    extends
        $FunctionalProvider<
          SendPasswordReset,
          SendPasswordReset,
          SendPasswordReset
        >
    with $Provider<SendPasswordReset> {
  const SendPasswordResetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendPasswordResetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendPasswordResetHash();

  @$internal
  @override
  $ProviderElement<SendPasswordReset> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SendPasswordReset create(Ref ref) {
    return sendPasswordReset(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendPasswordReset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendPasswordReset>(value),
    );
  }
}

String _$sendPasswordResetHash() => r'2a1cbfff3cac90110d5bbe48aed5e2a7d02ce02c';
