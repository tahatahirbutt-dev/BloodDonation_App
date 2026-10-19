import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';

void main() {
  const emailError = ValidationFailure('Bad email.', field: 'email');
  const networkError = NetworkFailure();

  group('failureFromError', () {
    test('passes a Failure through', () {
      expect(failureFromError(networkError), networkError);
    });

    test('turns anything else into UnexpectedFailure, never a crash', () {
      expect(failureFromError(StateError('bug')), const UnexpectedFailure());
      expect(failureFromError('a string'), const UnexpectedFailure());
    });
  });

  group('failureOf', () {
    test('is null for data and loading', () {
      expect(failureOf<void>(const AsyncData<void>(null)), isNull);
      expect(failureOf<void>(const AsyncLoading<void>()), isNull);
    });

    test('returns the typed failure from an AsyncError', () {
      final value = AsyncError<void>(networkError, StackTrace.empty);

      expect(failureOf<void>(value), networkError);
    });
  });

  group('fieldErrorFor', () {
    test('returns the message only for the targeted field', () {
      expect(fieldErrorFor(emailError, 'email'), 'Bad email.');
      expect(fieldErrorFor(emailError, 'password'), isNull);
    });

    test('ignores non-validation failures and null', () {
      expect(fieldErrorFor(networkError, 'email'), isNull);
      expect(fieldErrorFor(null, 'email'), isNull);
    });
  });

  group('bannerFailure', () {
    test('hides a validation failure that is shown under its field', () {
      expect(bannerFailure(emailError, {'email'}), isNull);
    });

    test('keeps a validation failure for a field with no inline slot', () {
      expect(bannerFailure(emailError, {'password'}), emailError);
    });

    test('keeps every other failure, and null stays null', () {
      expect(bannerFailure(networkError, {'email'}), networkError);
      expect(bannerFailure(null, {'email'}), isNull);
    });
  });

  group('asyncVoidFromResult', () {
    test('Success becomes AsyncData', () {
      final value = asyncVoidFromResult<int>(const Success<int>(1));

      expect(value, isA<AsyncData<void>>());
    });

    test('Err becomes AsyncError carrying the Failure', () {
      final value = asyncVoidFromResult<int>(const Err<int>(networkError));

      expect(value, isA<AsyncError<void>>());
      expect(failureOf<void>(value), networkError);
    });
  });
}
