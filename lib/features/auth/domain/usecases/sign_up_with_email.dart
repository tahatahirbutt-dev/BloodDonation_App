import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

import '../entities/auth_user.dart';
import '../entities/email_address.dart';
import '../entities/password_policy.dart';
import '../repositories/auth_repository.dart';

/// Validates, creates the account, then sends the verification email.
///
/// If the account is created but the email fails to send, this still
/// succeeds: the account exists, and the verification screen has a
/// "resend" button. Failing here would strand a user whose account was
/// already created.
class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final EmailAddress parsed;
    switch (EmailAddress.parse(email)) {
      case Success<EmailAddress>(:final value):
        parsed = value;
      case Err<EmailAddress>(:final failure):
        return Err<AuthUser>(failure);
    }

    final weakness = PasswordPolicy.validateNew(password);
    if (weakness != null) return Err<AuthUser>(weakness);

    if (password != confirmPassword) {
      return const Err<AuthUser>(
        ValidationFailure('Passwords do not match.', field: 'confirmPassword'),
      );
    }

    switch (await _repository.signUp(email: parsed, password: password)) {
      case Err<AuthUser>(:final failure):
        return Err<AuthUser>(failure);
      case Success<AuthUser>(:final value):
        // Result intentionally ignored: see class comment.
        await _repository.sendVerificationEmail();
        return Success<AuthUser>(value);
    }
  }
}
