import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/firebase/firestore_guard.dart';

void main() {
  group('guardFirestoreCall', () {
    test('returns the value when the call succeeds', () async {
      expect(await guardFirestoreCall(() async => 42), 42);
    });

    test('maps a FirebaseException by its code', () async {
      await expectLater(
        guardFirestoreCall<void>(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        throwsA(
          isA<DataSourceException>().having(
            (e) => e.failure,
            'failure',
            isA<PermissionFailure>(),
          ),
        ),
      );
    });

    test('maps "unavailable" (offline) to NetworkFailure', () async {
      await expectLater(
        guardFirestoreCall<void>(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
          ),
        ),
        throwsA(
          isA<DataSourceException>().having(
            (e) => e.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        ),
      );
    });

    test('turns a call that never completes into NetworkFailure', () async {
      await expectLater(
        guardFirestoreCall<void>(
          () => Completer<void>().future,
          timeout: const Duration(milliseconds: 20),
        ),
        throwsA(
          isA<DataSourceException>().having(
            (e) => e.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        ),
      );
    });

    test('lets a DataSourceException through unchanged', () async {
      const original = DataSourceException(NotFoundFailure());
      await expectLater(
        guardFirestoreCall<void>(() async => throw original),
        throwsA(same(original)),
      );
    });

    test(
      'does NOT swallow genuine bugs: they must reach the reporter',
      () async {
        await expectLater(
          guardFirestoreCall<void>(() async => throw StateError('bug')),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
