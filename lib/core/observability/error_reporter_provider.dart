import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'error_reporter.dart';

part 'error_reporter_provider.g.dart';

/// Defaults to a no-op so tests and previews never need Firebase.
/// `bootstrap()` overrides it with the Crashlytics implementation.
@Riverpod(keepAlive: true)
ErrorReporter errorReporter(Ref ref) => const NoopErrorReporter();
