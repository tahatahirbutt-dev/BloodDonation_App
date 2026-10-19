import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'error_reporter.dart';

/// Sends errors to Firebase Crashlytics (free on the Spark plan).
final class CrashlyticsErrorReporter implements ErrorReporter {
  CrashlyticsErrorReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  void report(Object error, StackTrace stackTrace, {bool fatal = false}) {
    // Fire-and-forget, and swallow our own failures: a broken reporter
    // must never crash the app it is supposed to protect.
    unawaited(
      _crashlytics
          .recordError(error, stackTrace, fatal: fatal)
          .catchError((Object _) {}),
    );
  }
}
