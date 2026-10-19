import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';

import '../../auth_providers.dart';

part 'auth_form_notifier.g.dart';

/// State of the sign-in / sign-up form: idle (`AsyncData`), submitting
/// (`AsyncLoading`) or failed (`AsyncError` carrying a typed `Failure`).
/// On success the auth session changes and the gate swaps the screen, so
/// no navigation happens here.
@riverpod
class AuthForm extends _$AuthForm {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) {
    return _run(
      () => ref
          .read(signInWithEmailProvider)
          .call(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _run(
      () => ref
          .read(signUpWithEmailProvider)
          .call(
            email: email,
            password: password,
            confirmPassword: confirmPassword,
          ),
    );
  }

  Future<void> _run<T>(Future<Result<T>> Function() action) async {
    state = const AsyncLoading<void>();
    final result = await action();
    // The user may have left the screen while the request was in flight.
    if (!ref.mounted) return;
    state = asyncVoidFromResult(result);
  }
}
