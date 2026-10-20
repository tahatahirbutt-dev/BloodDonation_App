import 'package:blood_donation_app/core/error/result.dart';

/// Opens the phone app with a number ready to call. An interface so UI code
/// never touches a platform plugin, and tests can record calls instead.
abstract interface class PhoneDialer {
  /// [number] is an international number such as `+923001234567`.
  /// Never throws: a refusal or a missing phone app is an [Err].
  Future<Result<void>> dial(String number);
}
