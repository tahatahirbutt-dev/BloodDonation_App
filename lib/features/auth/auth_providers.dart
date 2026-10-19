import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/observability/error_reporter_provider.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/send_password_reset.dart';
import 'domain/usecases/sign_in_with_email.dart';
import 'domain/usecases/sign_up_with_email.dart';

part 'auth_providers.g.dart';

// Composition root of the auth feature: the only file that knows which
// concrete classes satisfy the domain interfaces.

/// No default on purpose: `bootstrap()` overrides it with the Firebase
/// implementation and tests override it with a fake. Forgetting fails
/// loudly instead of silently using the wrong backend.
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  throw UnimplementedError(
    'Override authRemoteDataSourceProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final reporter = ref.watch(errorReporterProvider);
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    reportUnexpectedError: (error, stackTrace) =>
        reporter.report(error, stackTrace),
  );
}

@riverpod
SignInWithEmail signInWithEmail(Ref ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
}

@riverpod
SignUpWithEmail signUpWithEmail(Ref ref) {
  return SignUpWithEmail(ref.watch(authRepositoryProvider));
}

@riverpod
SendPasswordReset sendPasswordReset(Ref ref) {
  return SendPasswordReset(ref.watch(authRepositoryProvider));
}
