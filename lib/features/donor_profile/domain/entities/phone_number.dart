import 'package:equatable/equatable.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

/// A Pakistani mobile number, always stored in E.164 (+923XXXXXXXXX).
///
/// Normalizing once at the boundary means Firebase Auth, Firestore and
/// the "call donor" button all see the same string, and two spellings of
/// one number can never become two different users.
final class PhoneNumber extends Equatable {
  const PhoneNumber._(this.e164);

  final String e164;

  // 03XXXXXXXXX, 923XXXXXXXXX or +923XXXXXXXXX.
  static final RegExp _pattern = RegExp(r'^(?:\+92|92|0)(3\d{9})$');

  static Result<PhoneNumber> parse(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    final match = _pattern.firstMatch(cleaned);
    if (match == null) {
      return const Err<PhoneNumber>(
        ValidationFailure(
          'Enter a valid Pakistani mobile number, e.g. 0300 1234567.',
          field: 'phone',
        ),
      );
    }
    return Success<PhoneNumber>(PhoneNumber._('+92${match.group(1)}'));
  }

  @override
  List<Object?> get props => [e164];

  @override
  String toString() => e164;
}
