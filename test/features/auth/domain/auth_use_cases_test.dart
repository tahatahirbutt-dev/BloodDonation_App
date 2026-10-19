import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/auth/domain/entities/auth_user.dart';
import 'package:blood_donation_app/features/auth/domain/entities/email_address.dart';
import 'package:blood_donation_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:blood_donation_app/features/auth/domain/usecases/send_password_reset.dart';
import 'package:blood_donation_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:blood_donation_app/features/auth/domain/usecases/sign_up_with_email.dart';

const _user = AuthUser(
  uid: 'uid-1',
  email: 'taha@example.com',
  isEmailVerified: false,
);

/// Records calls and returns whatever the test configures.
class _FakeAuthRepository implements AuthRepository {
  Result<AuthUser> signUpResult = const Success<AuthUser>(_user);
  Result<AuthUser> signInResult = const Success<AuthUser>(_user);
  Result<void> sendVerificationResult = const Success<void>(null);

  final List<String> signUpEmails = [];
  final List<String> signInEmails = [];
  final List<String> signInPasswords = [];
  final List<String> resetEmails = [];
  int verificationEmailCalls = 0;

  @override
  Future<Result<AuthUser>> signUp({
    required EmailAddress email,
    required String password,
  }) async {
    signUpEmails.add(email.value);
    return signUpResult;
  }

  @override
  Future<Result<AuthUser>> signIn({
    required EmailAddress email,
    required String password,
  }) async {
    signInEmails.add(email.value);
    signInPasswords.add(password);
    return signInResult;
  }

  @override
  Future<Result<void>> sendVerificationEmail() async {
    verificationEmailCalls++;
    return sendVerificationResult;
  }

  @override
  Future<Result<void>> sendPasswordReset(EmailAddress email) async {
    resetEmails.add(email.value);
    return const Success<void>(null);
  }

  @override
  Stream<AuthUser?> userChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<Result<AuthUser>> refreshUser() async =>
      const Success<AuthUser>(_user);

  @override
  Future<Result<void>> signOut() async => const Success<void>(null);
}

Failure _failureOf<T>(Result<T> result) => (result as Err<T>).failure;

Matcher _validationOn(String field) =>
    isA<ValidationFailure>().having((f) => f.field, 'field', field);

void main() {
  late _FakeAuthRepository repository;

  setUp(() => repository = _FakeAuthRepository());

  group('SignInWithEmail', () {
    test('rejects an invalid email without calling the repository', () async {
      final result = await SignInWithEmail(repository)(
        email: 'nope',
        password: 'whatever1',
      );

      expect(_failureOf(result), _validationOn('email'));
      expect(repository.signInEmails, isEmpty);
    });

    test('rejects an empty password without calling the repository', () async {
      final result = await SignInWithEmail(repository)(
        email: 'taha@example.com',
        password: '',
      );

      expect(_failureOf(result), _validationOn('password'));
      expect(repository.signInEmails, isEmpty);
    });

    test('passes the normalized email to the repository', () async {
      await SignInWithEmail(repository)(
        email: '  Taha@Example.com ',
        password: 'whatever1',
      );

      expect(repository.signInEmails, ['taha@example.com']);
    });

    test(
      'does NOT apply the new-password policy to existing accounts',
      () async {
        final result = await SignInWithEmail(repository)(
          email: 'taha@example.com',
          password:
              'x', // would fail PasswordPolicy, but may be an old password
        );

        expect(result, isA<Success<AuthUser>>());
        expect(repository.signInPasswords, ['x']);
      },
    );

    test('returns the repository failure unchanged', () async {
      repository.signInResult = const Err<AuthUser>(
        PermissionFailure('Incorrect email or password.'),
      );

      final result = await SignInWithEmail(repository)(
        email: 'taha@example.com',
        password: 'whatever1',
      );

      expect(
        _failureOf(result),
        const PermissionFailure('Incorrect email or password.'),
      );
    });
  });

  group('SignUpWithEmail', () {
    Future<Result<AuthUser>> signUp({
      String email = 'taha@example.com',
      String password = 'Passw0rd1',
      String confirm = 'Passw0rd1',
    }) {
      return SignUpWithEmail(repository)(
        email: email,
        password: password,
        confirmPassword: confirm,
      );
    }

    test('rejects an invalid email', () async {
      expect(_failureOf(await signUp(email: 'nope')), _validationOn('email'));
      expect(repository.signUpEmails, isEmpty);
    });

    test('rejects a weak password', () async {
      final result = await signUp(password: 'short1', confirm: 'short1');

      expect(_failureOf(result), _validationOn('password'));
      expect(repository.signUpEmails, isEmpty);
    });

    test('rejects mismatched passwords on the confirm field', () async {
      final result = await signUp(confirm: 'Different1');

      expect(_failureOf(result), _validationOn('confirmPassword'));
      expect(repository.signUpEmails, isEmpty);
    });

    test(
      'creates the account, then sends exactly one verification email',
      () async {
        final result = await signUp();

        expect(result, isA<Success<AuthUser>>());
        expect(repository.signUpEmails, ['taha@example.com']);
        expect(repository.verificationEmailCalls, 1);
      },
    );

    test('still succeeds when the verification email fails to send', () async {
      repository.sendVerificationResult = const Err<void>(
        ServerFailure('Could not send.'),
      );

      final result = await signUp();

      // The account exists; the user can tap "Resend email" on the next
      // screen. Failing here would strand them.
      expect(result, isA<Success<AuthUser>>());
    });

    test('a failed sign-up sends no verification email', () async {
      repository.signUpResult = const Err<AuthUser>(
        ValidationFailure('Exists.', field: 'email'),
      );

      final result = await signUp();

      expect(_failureOf(result), _validationOn('email'));
      expect(repository.verificationEmailCalls, 0);
    });
  });

  group('SendPasswordReset', () {
    test('rejects an invalid email', () async {
      final result = await SendPasswordReset(repository)('nope');

      expect(_failureOf(result), _validationOn('email'));
      expect(repository.resetEmails, isEmpty);
    });

    test('sends to the normalized address', () async {
      final result = await SendPasswordReset(repository)(' Taha@Example.com');

      expect(result, isA<Success<void>>());
      expect(repository.resetEmails, ['taha@example.com']);
    });
  });
}
