import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/auth/domain/entities/auth_user.dart';

Matcher _throwsFailure(Object expectedFailure) => throwsA(
  isA<DataSourceException>().having(
    (e) => e.failure,
    'failure',
    expectedFailure is Matcher ? expectedFailure : equals(expectedFailure),
  ),
);

void main() {
  late InMemoryAuthDataSource source;

  setUp(() => source = InMemoryAuthDataSource());

  test('signUp creates an UNVERIFIED, signed-in user', () async {
    final user = await source.signUp(
      email: 'taha@example.com',
      password: 'Passw0rd1',
    );

    expect(user.email, 'taha@example.com');
    expect(user.isEmailVerified, isFalse);
  });

  test('signing up twice with one email fails on the email field', () async {
    await source.signUp(email: 'taha@example.com', password: 'Passw0rd1');

    await expectLater(
      source.signUp(email: 'taha@example.com', password: 'Passw0rd1'),
      _throwsFailure(
        isA<ValidationFailure>().having((f) => f.field, 'field', 'email'),
      ),
    );
  });

  test(
    'signIn with a wrong password and an unknown email fail identically',
    () async {
      await source.signUp(email: 'taha@example.com', password: 'Passw0rd1');

      final wrongPassword = source.signIn(
        email: 'taha@example.com',
        password: 'Nope12345',
      );
      final unknownEmail = source.signIn(
        email: 'who@example.com',
        password: 'Passw0rd1',
      );

      await expectLater(
        wrongPassword,
        _throwsFailure(const PermissionFailure('Incorrect email or password.')),
      );
      await expectLater(
        unknownEmail,
        _throwsFailure(const PermissionFailure('Incorrect email or password.')),
      );
    },
  );

  test(
    'verification is only visible after reload, like the real SDK',
    () async {
      await source.signUp(email: 'taha@example.com', password: 'Passw0rd1');

      source.markCurrentUserVerified();
      final events = <AuthUser?>[];
      final subscription = source.userChanges().listen(events.add);
      await pumpEventQueue();

      // Clicking the email link does not, by itself, change what the app
      // sees: the first event is still the unverified user.
      expect(events.single!.isEmailVerified, isFalse);

      final reloaded = await source.reload();
      await pumpEventQueue();

      expect(reloaded.isEmailVerified, isTrue);
      expect(events.last!.isEmailVerified, isTrue);
      await subscription.cancel();
    },
  );

  test('sendVerificationEmail counts and needs a signed-in user', () async {
    await expectLater(
      source.sendVerificationEmail(),
      _throwsFailure(isA<PermissionFailure>()),
    );

    await source.signUp(email: 'taha@example.com', password: 'Passw0rd1');
    await source.sendVerificationEmail();

    expect(source.verificationEmailsSent, 1);
  });

  test(
    'userChanges starts with the current user, then follows sign-out',
    () async {
      final events = <AuthUser?>[];
      final subscription = source.userChanges().listen(events.add);
      await pumpEventQueue();
      expect(events, [null]);

      await source.signUp(email: 'taha@example.com', password: 'Passw0rd1');
      await source.signOut();
      await pumpEventQueue();

      expect(events.length, 3);
      expect(events[1], isNotNull);
      expect(events.last, isNull);
      await subscription.cancel();
    },
  );

  test('failWith makes every call fail with that failure', () async {
    source.failWith = const NetworkFailure();

    await expectLater(
      source.signIn(email: 'a@b.co', password: 'x'),
      _throwsFailure(const NetworkFailure()),
    );
    await expectLater(source.signOut(), _throwsFailure(const NetworkFailure()));
  });
}
