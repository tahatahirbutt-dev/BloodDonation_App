import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';
import 'package:blood_donation_app/core/platform/url_launcher_phone_dialer.dart';

class _RecordingReporter implements ErrorReporter {
  final List<Object> errors = [];

  @override
  void report(Object error, StackTrace stackTrace, {bool fatal = false}) {
    errors.add(error);
  }
}

void main() {
  test('opens a tel: link for a valid number', () async {
    Uri? opened;
    final dialer = UrlLauncherPhoneDialer(
      launch: (uri) async {
        opened = uri;
        return true;
      },
    );

    final result = await dialer.dial('+923001234567');

    expect(result, isA<Success<void>>());
    expect(opened.toString(), 'tel:+923001234567');
  });

  test('returns a failure when no app can handle the link', () async {
    final dialer = UrlLauncherPhoneDialer(launch: (_) async => false);

    final result = await dialer.dial('+923001234567');

    expect((result as Err<void>).failure, isA<ServerFailure>());
  });

  test('turns a platform error into a failure and reports it', () async {
    final reporter = _RecordingReporter();
    final dialer = UrlLauncherPhoneDialer(
      launch: (_) => throw StateError('channel error'),
      reporter: reporter,
    );

    final result = await dialer.dial('+923001234567');

    expect((result as Err<void>).failure, isA<ServerFailure>());
    expect(reporter.errors, hasLength(1));
  });

  for (final bad in [
    '',
    'abc',
    '0300-123',
    '+92 300 1234567',
    'tel:+92300',
    '+1234567890123456',
  ]) {
    test('refuses "$bad" without launching anything', () async {
      var launched = false;
      final dialer = UrlLauncherPhoneDialer(
        launch: (_) async {
          launched = true;
          return true;
        },
      );

      final result = await dialer.dial(bad);

      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(launched, isFalse);
    });
  }
}
