import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/features/auth/domain/entities/password_policy.dart';

void main() {
  group('PasswordPolicy.validateNew', () {
    test('accepts 8+ characters with a letter and a number', () {
      expect(PasswordPolicy.validateNew('Passw0rd1'), isNull);
      expect(PasswordPolicy.validateNew('abcdefg1'), isNull);
    });

    for (final weak in <String>[
      'abc1', // too short
      'abcdefgh', // no digit
      '12345678', // no letter
      '',
    ]) {
      test('rejects "$weak" on the password field', () {
        expect(
          PasswordPolicy.validateNew(weak),
          isA<ValidationFailure>().having((f) => f.field, 'field', 'password'),
        );
      });
    }

    test('rejects a password longer than 128 characters', () {
      final tooLong = 'a1' * 65; // 130 characters

      final failure = PasswordPolicy.validateNew(tooLong);

      expect(failure, isA<ValidationFailure>());
      expect(failure!.message, contains('too long'));
    });

    test('accepts exactly 128 characters', () {
      expect(PasswordPolicy.validateNew('a1' * 64), isNull);
    });
  });
}
