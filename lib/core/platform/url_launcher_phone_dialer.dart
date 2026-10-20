import 'package:url_launcher/url_launcher.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';

import 'phone_dialer.dart';

/// [PhoneDialer] backed by the `tel:` URL scheme. It opens the dialer with
/// the number filled in; the user still has to press call, so there is no
/// accidental call and no CALL_PHONE permission is needed.
final class UrlLauncherPhoneDialer implements PhoneDialer {
  UrlLauncherPhoneDialer({
    Future<bool> Function(Uri uri)? launch,
    ErrorReporter reporter = const NoopErrorReporter(),
  }) : _launch = launch ?? _defaultLaunch,
       _reporter = reporter;

  static final RegExp _validNumber = RegExp(r'^\+?[0-9]{7,15}$');

  static const Failure _cannotOpen = ServerFailure(
    'Could not open the phone app. Copy the number instead.',
  );

  final Future<bool> Function(Uri uri) _launch;
  final ErrorReporter _reporter;

  static Future<bool> _defaultLaunch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<Result<void>> dial(String number) async {
    if (!_validNumber.hasMatch(number)) {
      return const Err<void>(
        ValidationFailure('This phone number is not valid.'),
      );
    }
    try {
      final opened = await _launch(Uri(scheme: 'tel', path: number));
      return opened ? const Success<void>(null) : const Err<void>(_cannotOpen);
    } catch (error, stackTrace) {
      _reporter.report(error, stackTrace);
      return const Err<void>(_cannotOpen);
    }
  }
}
