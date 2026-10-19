import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blood_donation_app/features/auth/domain/entities/auth_user.dart';
import 'package:blood_donation_app/features/auth/domain/entities/email_address.dart';

EmailAddress _email([String raw = 'taha@example.com']) =>
    (EmailAddress.parse(raw) as Success<EmailAddress>).value;

/// Throws a plain bug from every call, to prove nothing escapes the
/// repository as an exception.
class _BuggyAuthDataSource implements AuthRemoteDataSource {
  @override
  Stream<AuthUser?> userChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<AuthUser> signUp({required String email, required String password}) =>
      throw StateError('bug');

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      throw StateError('bug');

  @override
  Future<void> sendVerificationEmail() => throw StateError('bug');

  @override
  Future<AuthUser> reload() => throw StateError('bug');

  @override
  Future<void> sendPasswordReset(String email) => throw StateError('bug');

  @override
  Future<void> signOut() => throw StateError('bug');
}

void main() {
  group('with a healthy data source', () {
    late InMemoryAuthDataSource source;
    late AuthRepositoryImpl repository;

    setUp(() {
      source = InMemoryAuthDataSource();
      repository = AuthRepositoryImpl(source);
    });

    test('signUp wraps the user in Success', () async {
      final result = await repository.signUp(
        email: _email(),
        password: 'Passw0rd1',
      );

      expect(result, isA<Success<AuthUser>>());
      expect((result as Success<AuthUser>).value.email, 'taha@example.com');
    });

    test(
      'a typed data-source failure becomes Err with the same failure',
      () async {
        source.failWith = const NetworkFailure();

        final result = await repository.signIn(
          email: _email(),
          password: 'Passw0rd1',
        );

        expect(result, isA<Err<AuthUser>>());
        expect((result as Err<AuthUser>).failure, const NetworkFailure());
      },
    );

    test('userChanges passes the data source stream through', () async {
      await expectLater(repository.userChanges(), emits(isNull));
    });
  });

  group('with a buggy data source', () {
    test(
      'returns UnexpectedFailure and reports the bug, never throws',
      () async {
        final reported = <Object>[];
        final repository = AuthRepositoryImpl(
          _BuggyAuthDataSource(),
          reportUnexpectedError: (error, stackTrace) => reported.add(error),
        );

        final signIn = await repository.signIn(
          email: _email(),
          password: 'Passw0rd1',
        );
        final signOut = await repository.signOut();
        final refresh = await repository.refreshUser();

        for (final result in <Result<Object?>>[signIn, signOut, refresh]) {
          expect(result, isA<Err<Object?>>());
          expect((result as Err<Object?>).failure, isA<UnexpectedFailure>());
        }
        expect(reported, hasLength(3));
        expect(reported, everyElement(isA<StateError>()));
      },
    );
  });
}
