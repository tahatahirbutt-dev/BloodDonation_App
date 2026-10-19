import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:blood_donation_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';

import '../../../support/pump_app.dart';

void main() {
  late InMemoryAuthDataSource auth;
  late InMemoryUserProfileDataSource profiles;

  setUp(() {
    auth = InMemoryAuthDataSource();
    profiles = InMemoryUserProfileDataSource();
  });

  Future<void> switchToSignUp(WidgetTester tester) async {
    await tester.tap(find.byKey(SignInPage.toggleModeButtonKey));
    await tester.pumpAndSettle();
  }

  group('signing up', () {
    testWidgets('creates the account and lands on "Verify your email"', (
      tester,
    ) async {
      await pumpApp(tester, auth: auth, profiles: profiles);
      await switchToSignUp(tester);

      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'taha@example.com',
      );
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'Passw0rd1',
      );
      await tester.enterText(
        find.byKey(SignInPage.confirmPasswordFieldKey),
        'Passw0rd1',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.textContaining('taha@example.com'), findsOneWidget);
      expect(auth.verificationEmailsSent, 1);
    });

    testWidgets('a weak password is reported under the password field', (
      tester,
    ) async {
      await pumpApp(tester, auth: auth, profiles: profiles);
      await switchToSignUp(tester);

      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'taha@example.com',
      );
      await tester.enterText(find.byKey(SignInPage.passwordFieldKey), 'short');
      await tester.enterText(
        find.byKey(SignInPage.confirmPasswordFieldKey),
        'short',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text('Use at least 8 characters, with a letter and a number.'),
        findsOneWidget,
      );
      expect(find.text('Verify your email'), findsNothing);
      expect(auth.verificationEmailsSent, 0);
    });

    testWidgets('mismatched passwords are reported on the confirm field', (
      tester,
    ) async {
      await pumpApp(tester, auth: auth, profiles: profiles);
      await switchToSignUp(tester);

      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'taha@example.com',
      );
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'Passw0rd1',
      );
      await tester.enterText(
        find.byKey(SignInPage.confirmPasswordFieldKey),
        'Passw0rd2',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('an email that already has an account says so on the email '
        'field', (tester) async {
      await auth.signUp(email: 'taha@example.com', password: 'Passw0rd1');
      await auth.signOut();
      await pumpApp(tester, auth: auth, profiles: profiles);
      await switchToSignUp(tester);

      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'taha@example.com',
      );
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'Passw0rd1',
      );
      await tester.enterText(
        find.byKey(SignInPage.confirmPasswordFieldKey),
        'Passw0rd1',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'An account with this email already exists. Try signing in instead.',
        ),
        findsOneWidget,
      );
    });
  });

  group('signing in', () {
    testWidgets('wrong credentials show one generic message', (tester) async {
      await auth.signUp(email: 'taha@example.com', password: 'Passw0rd1');
      await auth.signOut();
      await pumpApp(tester, auth: auth, profiles: profiles);

      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'taha@example.com',
      );
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'WrongPass1',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.byKey(SignInPage.submitButtonKey), findsOneWidget);
    });

    testWidgets('an invalid email is reported without hitting the backend', (
      tester,
    ) async {
      await pumpApp(tester, auth: auth, profiles: profiles);

      await tester.enterText(find.byKey(SignInPage.emailFieldKey), 'nope');
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'Passw0rd1',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('a signed-out network failure becomes a message, not a crash', (
      tester,
    ) async {
      await pumpApp(tester, auth: auth, profiles: profiles);
      auth.failWith = const NetworkFailure();

      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'taha@example.com',
      );
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'Passw0rd1',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text('No connection. Check your internet and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('forgot password confirms without revealing whether the '
        'account exists', (tester) async {
      await pumpApp(tester, auth: auth, profiles: profiles);

      await tester.tap(find.byKey(SignInPage.forgotPasswordButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('Reset password'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('forgotPassword.email')),
        'nobody@example.com',
      );
      await tester.tap(find.text('Send link'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('If an account exists for that address'),
        findsOneWidget,
      );
    });
  });

  group('verifying the email', () {
    Future<void> signUpThroughTheForm(WidgetTester tester) async {
      await pumpApp(tester, auth: auth, profiles: profiles);
      await switchToSignUp(tester);
      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'taha@example.com',
      );
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'Passw0rd1',
      );
      await tester.enterText(
        find.byKey(SignInPage.confirmPasswordFieldKey),
        'Passw0rd1',
      );
      await tester.tap(find.byKey(SignInPage.submitButtonKey));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping "I\'ve verified" too early says not verified yet', (
      tester,
    ) async {
      await signUpThroughTheForm(tester);

      await tester.tap(find.byKey(VerifyEmailPage.checkButtonKey));
      await tester.pumpAndSettle();

      expect(find.textContaining('Not verified yet'), findsOneWidget);
      expect(find.text('Verify your email'), findsOneWidget);
    });

    testWidgets('after the link is opened, the app moves on to profile setup', (
      tester,
    ) async {
      await signUpThroughTheForm(tester);

      auth.markCurrentUserVerified();
      await tester.tap(find.byKey(VerifyEmailPage.checkButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsNothing);
      expect(find.text('Set up your profile'), findsOneWidget);
    });

    testWidgets('resend sends another email and then cools down', (
      tester,
    ) async {
      await signUpThroughTheForm(tester);
      expect(auth.verificationEmailsSent, 1);

      await tester.tap(find.byKey(VerifyEmailPage.resendButtonKey));
      await tester.pump();
      await tester.pump();

      expect(auth.verificationEmailsSent, 2);
      expect(find.textContaining('Resend email in'), findsOneWidget);

      // Dispose the page so its countdown timer is cancelled before the
      // test ends.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('"Use a different account" returns to sign-in', (tester) async {
      await signUpThroughTheForm(tester);

      await tester.tap(find.byKey(VerifyEmailPage.signOutButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(SignInPage.submitButtonKey), findsOneWidget);
    });
  });
}
