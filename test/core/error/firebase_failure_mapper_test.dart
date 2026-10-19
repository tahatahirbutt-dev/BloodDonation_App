import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/firebase_failure_mapper.dart';

void main() {
  group('failureForFirebaseCode', () {
    const networkCodes = [
      'unavailable',
      'deadline-exceeded',
      'network-request-failed',
    ];
    for (final code in networkCodes) {
      test('"$code" -> NetworkFailure', () {
        expect(failureForFirebaseCode(code), isA<NetworkFailure>());
      });
    }

    for (final code in ['permission-denied', 'unauthenticated']) {
      test('"$code" -> PermissionFailure', () {
        expect(failureForFirebaseCode(code), isA<PermissionFailure>());
      });
    }

    test('"not-found" -> NotFoundFailure', () {
      expect(failureForFirebaseCode('not-found'), isA<NotFoundFailure>());
    });

    test('"resource-exhausted" -> ServerFailure with a wait message', () {
      final failure = failureForFirebaseCode('resource-exhausted');

      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('wait'));
    });

    test(
      '"failed-precondition" -> ServerFailure explaining it is being set up',
      () {
        final failure = failureForFirebaseCode('failed-precondition');

        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('still being set up'));
      },
    );

    test('an unknown code falls back to a generic ServerFailure', () {
      expect(failureForFirebaseCode('some-future-code'), isA<ServerFailure>());
      expect(failureForFirebaseCode(''), isA<ServerFailure>());
    });

    test('no failure message leaks the raw Firebase code', () {
      for (final code in [...networkCodes, 'permission-denied', 'not-found']) {
        expect(failureForFirebaseCode(code).message, isNot(contains(code)));
      }
    });
  });
}
