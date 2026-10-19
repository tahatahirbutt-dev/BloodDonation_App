import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';

import '../../auth_providers.dart';

part 'password_reset_notifier.g.dart';

/// `AsyncData(false)` = nothing sent yet, `AsyncData(true)` = request
/// accepted, `AsyncLoading` / `AsyncError` as usual.
@riverpod
class PasswordReset extends _$PasswordReset {
  @override
  FutureOr<bool> build() => false;

  Future<void> send(String email) async {
    state = const AsyncLoading<bool>();
    final result = await ref.read(sendPasswordResetProvider).call(email);
    if (!ref.mounted) return;
    state = switch (result) {
      Success<void>() => const AsyncData<bool>(true),
      Err<void>(:final failure) => AsyncError<bool>(
        failure,
        StackTrace.current,
      ),
    };
  }
}
