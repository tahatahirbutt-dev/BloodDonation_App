import 'package:blood_donation_app/core/error/failure.dart';

/// Rules for a NEW password (sign-up). Sign-in never applies these: a
/// returning user must be able to log in with whatever they set earlier.
abstract final class PasswordPolicy {
  static const int minLength = 8;
  static const int maxLength = 128;

  /// `null` means the password is acceptable.
  static Failure? validateNew(String password) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);

    if (password.length < minLength || !hasLetter || !hasDigit) {
      return const ValidationFailure(
        'Use at least 8 characters, with a letter and a number.',
        field: 'password',
      );
    }
    if (password.length > maxLength) {
      return const ValidationFailure(
        'Password is too long (128 characters at most).',
        field: 'password',
      );
    }
    return null;
  }
}
