import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';

import '../../domain/entities/auth_user.dart';
import 'auth_session_notifier.dart';

part 'email_verification_notifier.g.dart';

/// Drives the "verify your email" screen. The data value is an optional
/// info message for the user (null = nothing to say).
@riverpod
class EmailVerification extends _$EmailVerification {
  @override
  FutureOr<String?> build() => null;

  Future<void> resend() async {
    state = const AsyncLoading<String?>();
    final result = await ref
        .read(authSessionProvider.notifier)
        .resendVerificationEmail();
    if (!ref.mounted) return;
    state = switch (result) {
      Success<void>() => const AsyncData<String?>(
        'Verification email sent. Check your inbox and spam folder.',
      ),
      Err<void>(:final failure) => AsyncError<String?>(
        failure,
        StackTrace.current,
      ),
    };
  }

  /// "I've verified my email": re-read the account. If it is verified the
  /// session updates and the gate moves on, otherwise say so.
  Future<void> check() async {
    state = const AsyncLoading<String?>();
    final result = await ref
        .read(authSessionProvider.notifier)
        .refreshVerification();
    if (!ref.mounted) return;
    state = switch (result) {
      Success<AuthUser>(:final value) when !value.isEmailVerified =>
        const AsyncData<String?>(
          'Not verified yet. Open the link in the email we sent, '
          'then tap this button again.',
        ),
      Success<AuthUser>() => const AsyncData<String?>(null),
      Err<AuthUser>(:final failure) => AsyncError<String?>(
        failure,
        StackTrace.current,
      ),
    };
  }
}
