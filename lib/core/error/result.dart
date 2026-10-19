import 'failure.dart';

/// Explicit success-or-failure return type for anything that can fail
/// at a layer boundary. No exceptions for expected failures, and no
/// third-party Either package — sealed classes plus Dart 3 pattern
/// matching give the same exhaustiveness guarantees.
///
/// ```dart
/// switch (await repository.getProfile(uid)) {
///   case Success(:final value): ...
///   case Err(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Err<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
