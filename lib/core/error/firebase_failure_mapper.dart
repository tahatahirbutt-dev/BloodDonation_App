import 'failure.dart';

/// Maps a Firebase error *code string* (FirebaseException.code) to a
/// typed [Failure]. Takes a plain String on purpose: no Firebase import,
/// so the mapping is unit-testable in pure Dart and the Firestore data
/// source stays a one-liner: `throw DataSourceException(failureForFirebaseCode(e.code))`.
Failure failureForFirebaseCode(String code) {
  switch (code) {
    case 'unavailable':
    case 'deadline-exceeded':
    case 'network-request-failed':
      return const NetworkFailure();
    case 'permission-denied':
    case 'unauthenticated':
      return const PermissionFailure();
    case 'not-found':
      return const NotFoundFailure();
    case 'failed-precondition':
      // Most often: a Firestore index that is still being built after a
      // deploy. It resolves on its own within a few minutes.
      return const ServerFailure(
        'This feature is still being set up. Please try again in a few minutes.',
      );
    case 'resource-exhausted':
      return const ServerFailure(
        'Too many requests right now. Please wait a moment and try again.',
      );
    default:
      return const ServerFailure();
  }
}
