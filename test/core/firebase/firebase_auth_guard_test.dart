import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/firebase/firebase_auth_guard.dart';

Matcher _throwsFailure(Failure expected) => throwsA(
  isA<DataSourceException>().having((e) => e.failure, 'failure', expected),
);

void main() {
  group('guardAuthCall', () {
    test('returns the value when the call succeeds', () async {
      expect(await guardAuthCall(() async => 7), 7);
    });

    test('maps a FirebaseAuthException with the AUTH mapper', () async {
      await expectLater(
        guardAuthCall<void>(
          () async => throw FirebaseAuthException(code: 'wrong-password'),
        ),
        _throwsFailure(const PermissionFailure('Incorrect email or password.')),
      );
    });

    test('maps network-request-failed to NetworkFailure', () async {
      await expectLater(
        guardAuthCall<void>(
          () async =>
              throw FirebaseAuthException(code: 'network-request-failed'),
        ),
        _throwsFailure(const NetworkFailure()),
      );
    });

    test('maps a plain FirebaseException with the Firebase mapper', () async {
      await expectLater(
        guardAuthCall<void>(
          () async => throw FirebaseException(
            plugin: 'firebase_auth',
            code: 'unavailable',
          ),
        ),
        _throwsFailure(const NetworkFailure()),
      );
    });

    test('turns a call that never completes into NetworkFailure', () async {
      await expectLater(
        guardAuthCall<void>(
          () => Completer<void>().future,
          timeout: const Duration(milliseconds: 20),
        ),
        _throwsFailure(const NetworkFailure()),
      );
    });

    test('lets a DataSourceException through unchanged', () async {
      const original = DataSourceException(NotFoundFailure());
      await expectLater(
        guardAuthCall<void>(() async => throw original),
        throwsA(same(original)),
      );
    });

    test('does NOT swallow genuine bugs', () async {
      await expectLater(
        guardAuthCall<void>(() async => throw StateError('bug')),
        throwsA(isA<StateError>()),
      );
    });
  });
}
