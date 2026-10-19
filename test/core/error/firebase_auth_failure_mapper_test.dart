import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/firebase_auth_failure_mapper.dart';

void main() {
  group('failureForAuthCode', () {
    test('invalid-email points at the email field', () {
      expect(
        failureForAuthCode('invalid-email'),
        isA<ValidationFailure>().having((f) => f.field, 'field', 'email'),
      );
    });

    test('email-already-in-use points at the email field', () {
      expect(
        failureForAuthCode('email-already-in-use'),
        isA<ValidationFailure>().having((f) => f.field, 'field', 'email'),
      );
    });

    test('weak-password points at the password field', () {
      expect(
        failureForAuthCode('weak-password'),
        isA<ValidationFailure>().having((f) => f.field, 'field', 'password'),
      );
    });

    test('unknown account and wrong password are indistinguishable', () {
      // Security property: the login form must not reveal which emails
      // have an account.
      final results = <Failure>[
        failureForAuthCode('user-not-found'),
        failureForAuthCode('wrong-password'),
        failureForAuthCode('invalid-credential'),
        failureForAuthCode('invalid-login-credentials'),
      ];

      for (final result in results) {
        expect(result, isA<PermissionFailure>());
        expect(result, results.first);
        expect(result.message, 'Incorrect email or password.');
      }
    });

    test('user-disabled is a PermissionFailure', () {
      expect(failureForAuthCode('user-disabled'), isA<PermissionFailure>());
    });

    test('session problems ask the user to sign in again', () {
      for (final code in [
        'requires-recent-login',
        'user-token-expired',
        'invalid-user-token',
        'no-current-user',
      ]) {
        expect(
          failureForAuthCode(code),
          const PermissionFailure('Please sign in again.'),
        );
      }
    });

    test('too-many-requests is a ServerFailure that says to wait', () {
      final failure = failureForAuthCode('too-many-requests');

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('wait'));
    });

    test('network-request-failed is a NetworkFailure', () {
      expect(
        failureForAuthCode('network-request-failed'),
        const NetworkFailure(),
      );
    });

    test('unknown codes fall back to the default ServerFailure', () {
      expect(failureForAuthCode('something-new'), const ServerFailure());
    });
  });
}
