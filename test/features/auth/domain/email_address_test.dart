import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/auth/domain/entities/email_address.dart';

void main() {
  group('EmailAddress.parse', () {
    test('trims and lower-cases, so spellings of one address are equal', () {
      final a =
          (EmailAddress.parse('  Taha@Example.COM ') as Success<EmailAddress>)
              .value;
      final b =
          (EmailAddress.parse('taha@example.com') as Success<EmailAddress>)
              .value;

      expect(a.value, 'taha@example.com');
      expect(a, b);
    });

    for (final bad in <String>[
      '',
      '   ',
      'plainaddress',
      'missing@tld',
      '@no-local.com',
      'two@@example.com',
      'spa ce@example.com',
    ]) {
      test('rejects "$bad" with a failure on the email field', () {
        final result = EmailAddress.parse(bad);

        expect(result, isA<Err<EmailAddress>>());
        expect(
          (result as Err<EmailAddress>).failure,
          isA<ValidationFailure>().having((f) => f.field, 'field', 'email'),
        );
      });
    }

    test('rejects an address longer than 254 characters', () {
      final tooLong = '${'a' * 250}@example.com';

      expect(EmailAddress.parse(tooLong), isA<Err<EmailAddress>>());
    });
  });
}
