import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

import '../entities/auth_user.dart';
import '../entities/email_address.dart';
import '../repositories/auth_repository.dart';

/// Validates the form input, then signs in. Wrong-password and
/// unknown-email both come back as the same failure message, so the app
/// can't be used to find out who has an account.
class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    final EmailAddress parsed;
    switch (EmailAddress.parse(email)) {
      case Success<EmailAddress>(:final value):
        parsed = value;
      case Err<EmailAddress>(:final failure):
        return Err<AuthUser>(failure);
    }

    if (password.isEmpty) {
      return const Err<AuthUser>(
        ValidationFailure('Enter your password.', field: 'password'),
      );
    }

    return _repository.signIn(email: parsed, password: password);
  }
}
