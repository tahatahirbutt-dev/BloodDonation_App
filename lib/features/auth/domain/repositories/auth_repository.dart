import 'package:blood_donation_app/core/error/result.dart';

import '../entities/auth_user.dart';
import '../entities/email_address.dart';

/// What the domain needs from an authentication provider. The Firebase
/// implementation lives in the data layer; a fake lives in tests. Adding
/// Google sign-in later means adding a method here and an implementation
/// behind it, with no change to callers of the existing methods.
abstract interface class AuthRepository {
  /// Emits the current user (or null) as soon as it is known, then again
  /// on every sign-in, sign-out or token/profile change.
  Stream<AuthUser?> userChanges();

  Future<Result<AuthUser>> signUp({
    required EmailAddress email,
    required String password,
  });

  Future<Result<AuthUser>> signIn({
    required EmailAddress email,
    required String password,
  });

  Future<Result<void>> sendVerificationEmail();

  /// Re-reads the account from the server AND refreshes its ID token, so
  /// a just-verified email is visible to the app and to security rules.
  Future<Result<AuthUser>> refreshUser();

  /// Must not reveal whether the address has an account.
  Future<Result<void>> sendPasswordReset(EmailAddress email);

  Future<Result<void>> signOut();
}
