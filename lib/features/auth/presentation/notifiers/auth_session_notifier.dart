import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

import '../../auth_providers.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_session_notifier.g.dart';

/// Who is signed in right now. `null` data means signed out.
///
/// Kept alive for the whole app. `build` resolves on the first event from
/// the auth stream (so the gate shows a spinner, not a flash of the login
/// screen, while the saved session is restored) and later events update
/// the state in place.
@Riverpod(keepAlive: true)
class AuthSession extends _$AuthSession {
  static const Duration _startupTimeout = Duration(seconds: 10);

  @override
  Future<AuthUser?> build() {
    final repository = ref.watch(authRepositoryProvider);
    final firstEvent = Completer<AuthUser?>();

    final subscription = repository.userChanges().listen(
      (user) {
        if (!firstEvent.isCompleted) {
          firstEvent.complete(user);
          return;
        }
        if (ref.mounted) state = AsyncData<AuthUser?>(user);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!firstEvent.isCompleted) {
          firstEvent.completeError(error, stackTrace);
          return;
        }
        if (ref.mounted) state = AsyncError<AuthUser?>(error, stackTrace);
      },
    );
    ref.onDispose(subscription.cancel);

    // If the stream never produces a first event, show an error with a
    // retry instead of an endless spinner.
    return firstEvent.future.timeout(
      _startupTimeout,
      onTimeout: () => throw const NetworkFailure(),
    );
  }

  /// Re-reads the account from the server and publishes the result, so
  /// the gate moves on as soon as the email is verified.
  Future<Result<AuthUser>> refreshVerification() async {
    final result = await ref.read(authRepositoryProvider).refreshUser();
    if (ref.mounted && result is Success<AuthUser>) {
      state = AsyncData<AuthUser?>(result.value);
    }
    return result;
  }

  Future<Result<void>> resendVerificationEmail() {
    return ref.read(authRepositoryProvider).sendVerificationEmail();
  }

  Future<Result<void>> signOut() {
    return ref.read(authRepositoryProvider).signOut();
  }
}
