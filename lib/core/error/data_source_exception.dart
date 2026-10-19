import 'failure.dart';

/// Thrown only *inside* the data layer: a data source catches its SDK's
/// exceptions, converts them to a [Failure], and throws this. The
/// repository catches it and returns `Err(failure)` — so no SDK exception
/// type (FirebaseException, HiveError, ...) ever reaches the domain.
final class DataSourceException implements Exception {
  const DataSourceException(this.failure);

  final Failure failure;

  @override
  String toString() => 'DataSourceException(${failure.message})';
}
