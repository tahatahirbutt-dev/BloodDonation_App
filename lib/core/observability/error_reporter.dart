/// Where unexpected errors go. Pure Dart so the domain/data layers can
/// depend on it without importing Firebase.
///
/// Two implementations: `CrashlyticsErrorReporter` in production and
/// [NoopErrorReporter] in tests and as the safe default. A swap is one
/// provider override, with no caller changes.
abstract interface class ErrorReporter {
  /// Must never throw: reporting an error must not become a new error.
  void report(Object error, StackTrace stackTrace, {bool fatal = false});
}

final class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  void report(Object error, StackTrace stackTrace, {bool fatal = false}) {}
}
