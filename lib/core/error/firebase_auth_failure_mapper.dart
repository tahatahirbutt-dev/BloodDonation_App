import 'failure.dart';

/// Maps a `FirebaseAuthException.code` to a typed [Failure] with a
/// message that is safe to show. Takes a plain String, like
/// `failureForFirebaseCode`, so it is unit-testable without Firebase.
///
/// Security note: unknown-account, wrong-password and the newer
/// `invalid-credential` all produce the SAME message, so the login form
/// can't be used to discover which emails are registered.
Failure failureForAuthCode(String code) {
  switch (code) {
    case 'invalid-email':
      return const ValidationFailure(
        'Enter a valid email address.',
        field: 'email',
      );
    case 'weak-password':
      return const ValidationFailure(
        'Use at least 8 characters, with a letter and a number.',
        field: 'password',
      );
    case 'email-already-in-use':
      return const ValidationFailure(
        'An account with this email already exists. Try signing in instead.',
        field: 'email',
      );
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return const PermissionFailure('Incorrect email or password.');
    case 'user-disabled':
      return const PermissionFailure('This account has been disabled.');
    case 'requires-recent-login':
    case 'user-token-expired':
    case 'invalid-user-token':
    case 'no-current-user':
      return const PermissionFailure('Please sign in again.');
    case 'too-many-requests':
      return const ServerFailure(
        'Too many attempts. Please wait a few minutes and try again.',
      );
    case 'network-request-failed':
      return const NetworkFailure();
    case 'operation-not-allowed':
      return const ServerFailure('Email sign-in is not available right now.');
    default:
      return const ServerFailure();
  }
}
