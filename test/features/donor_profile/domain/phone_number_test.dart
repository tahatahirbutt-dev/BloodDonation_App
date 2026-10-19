import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';

void main() {
  group('PhoneNumber.parse', () {
    const spellings = [
      '03001234567',
      '0300 1234567',
      '0300-1234567',
      '+92 300 1234567',
      '923001234567',
      '+92(300)1234567',
    ];

    for (final spelling in spellings) {
      test('normalizes "$spelling" to E.164', () {
        final result = PhoneNumber.parse(spelling);
        expect(result, isA<Success<PhoneNumber>>());
        expect((result as Success<PhoneNumber>).value.e164, '+923001234567');
      });
    }

    test('two spellings of one number are equal', () {
      final a = (PhoneNumber.parse('0300 1234567') as Success<PhoneNumber>);
      final b = (PhoneNumber.parse('+923001234567') as Success<PhoneNumber>);
      expect(a.value, b.value);
    });

    const invalid = [
      '',
      '12345',
      '0200 1234567', // not a mobile prefix
      '0300 123456', // one digit short
      '0300 12345678', // one digit long
      'abcdefghijk',
    ];

    for (final bad in invalid) {
      test('rejects "$bad" with a phone ValidationFailure', () {
        final result = PhoneNumber.parse(bad);
        expect(
          result,
          isA<Err<PhoneNumber>>().having(
            (e) => e.failure,
            'failure',
            isA<ValidationFailure>().having((f) => f.field, 'field', 'phone'),
          ),
        );
      });
    }
  });
}
