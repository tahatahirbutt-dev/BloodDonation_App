import 'package:equatable/equatable.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

/// A syntactically valid email, trimmed and lower-cased once at the
/// boundary so "Taha@Mail.com " and "taha@mail.com" are the same account.
///
/// Deliberately lenient (one "@", a dot in the domain): the real check is
/// that the verification email arrives.
final class EmailAddress extends Equatable {
  const EmailAddress._(this.value);

  final String value;

  static final RegExp _pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const int _maxLength = 254;

  static Result<EmailAddress> parse(String raw) {
    final cleaned = raw.trim().toLowerCase();
    if (cleaned.length > _maxLength || !_pattern.hasMatch(cleaned)) {
      return const Err<EmailAddress>(
        ValidationFailure('Enter a valid email address.', field: 'email'),
      );
    }
    return Success<EmailAddress>(EmailAddress._(cleaned));
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
