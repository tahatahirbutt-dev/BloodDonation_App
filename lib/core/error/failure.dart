import 'package:equatable/equatable.dart';

/// Typed failures that cross layer boundaries. Raw exceptions and raw
/// strings never leave the data layer: repositories catch at the I/O
/// boundary (Firebase, Hive, platform channels) and return one of these.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Safe to show to the user as-is. Never put stack traces, document
  /// paths, or other internals in here — log those separately.
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'The server had a problem. Please try again.',
  ]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No connection. Check your internet and try again.',
  ]);
}

final class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Could not read saved data on this device.',
  ]);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'You do not have permission to do that.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find that.']);
}

/// Bad user input. [field] lets a form attach the message to the right
/// text field instead of showing a generic snackbar.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.field});

  final String? field;

  @override
  List<Object?> get props => [message, field];
}

/// Last-resort bucket for errors nobody anticipated. Seeing this in
/// Crashlytics means a repository is missing a catch — fix the
/// repository, don't widen this.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
