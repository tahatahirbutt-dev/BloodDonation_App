import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/presentation/pages/profile_setup_page.dart';
import 'package:blood_donation_app/home/home_shell.dart';

import '../../../support/profile_fixtures.dart';
import '../../../support/pump_app.dart';

void main() {
  late InMemoryAuthDataSource auth;
  late InMemoryUserProfileDataSource profiles;

  setUp(() {
    auth = InMemoryAuthDataSource();
    profiles = InMemoryUserProfileDataSource();
  });

  /// Opens a dropdown field and picks the item showing [label].
  Future<void> choose(WidgetTester tester, Key field, String label) async {
    await tester.tap(find.byKey(field));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> fillValidForm(
    WidgetTester tester, {
    String name = 'Taha Tahir',
    String phone = '0300 1234567',
    bool pickBloodGroup = true,
    bool pickArea = true,
  }) async {
    await tester.enterText(find.byKey(ProfileSetupPage.nameFieldKey), name);
    await tester.enterText(find.byKey(ProfileSetupPage.phoneFieldKey), phone);
    if (pickBloodGroup) {
      await choose(tester, ProfileSetupPage.bloodGroupFieldKey, 'B+');
    }
    if (pickArea) {
      await choose(
        tester,
        ProfileSetupPage.areaFieldKey,
        'G-9 Markaz, Islamabad',
      );
    }
  }

  Future<void> openProfileTab(WidgetTester tester) async {
    await tester.tap(find.byKey(HomeShell.profileTabKey));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(ProfileSetupPage.saveButtonKey));
    await tester.pumpAndSettle();
  }

  group('profile setup', () {
    testWidgets('a verified user with no profile is sent to the setup form', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);

      await pumpApp(tester, auth: auth, profiles: profiles);

      expect(find.text('Set up your profile'), findsOneWidget);
    });

    testWidgets('a complete form saves the profile and opens Home', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await pumpApp(tester, auth: auth, profiles: profiles);

      await fillValidForm(tester);
      await save(tester);

      expect(find.text('Set up your profile'), findsNothing);
      expect(find.byKey(HomeShell.signOutButtonKey), findsOneWidget);

      await openProfileTab(tester);
      expect(find.text('Taha Tahir'), findsOneWidget);
      expect(find.textContaining('B+'), findsOneWidget);

      // And it really reached the data source, with the phone in E.164.
      final stored = await profiles.fetch('uid-1');
      expect(stored?['phone'], '+923001234567');
      expect(stored?['bloodGroup'], 'bPositive');
    });

    testWidgets('a missing blood group is flagged on its field', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await pumpApp(tester, auth: auth, profiles: profiles);

      await fillValidForm(tester, pickBloodGroup: false);
      await save(tester);

      expect(find.text('Select your blood group.'), findsOneWidget);
      expect(await profiles.fetch('uid-1'), isNull);
    });

    testWidgets('a missing area is flagged on its field', (tester) async {
      await seedVerifiedSignedInUser(auth);
      await pumpApp(tester, auth: auth, profiles: profiles);

      await fillValidForm(tester, pickArea: false);
      await save(tester);

      expect(
        find.text('Please choose your area from the list.'),
        findsOneWidget,
      );
      expect(await profiles.fetch('uid-1'), isNull);
    });

    testWidgets('a too-short name is flagged under the name field', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await pumpApp(tester, auth: auth, profiles: profiles);

      await fillValidForm(tester, name: 'T');
      await save(tester);

      expect(
        find.text('Name must be between 2 and 60 characters.'),
        findsOneWidget,
      );
      expect(await profiles.fetch('uid-1'), isNull);
    });

    testWidgets('an invalid phone number is flagged under the phone field', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await pumpApp(tester, auth: auth, profiles: profiles);

      await fillValidForm(tester, phone: '123');
      await save(tester);

      expect(
        find.text('Enter a valid Pakistani mobile number, e.g. 0300 1234567.'),
        findsOneWidget,
      );
      expect(await profiles.fetch('uid-1'), isNull);
    });

    testWidgets('a storage failure while saving shows a message and keeps '
        'the form', (tester) async {
      await seedVerifiedSignedInUser(auth);
      await pumpApp(tester, auth: auth, profiles: profiles);
      await fillValidForm(tester);

      profiles.failWith = const NetworkFailure();
      await save(tester);

      expect(
        find.text('No connection. Check your internet and try again.'),
        findsOneWidget,
      );
      expect(find.text('Set up your profile'), findsOneWidget);
    });

    testWidgets('signing out from the setup form returns to sign-in', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await pumpApp(tester, auth: auth, profiles: profiles);

      await tester.tap(find.byKey(ProfileSetupPage.signOutButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(SignInPage.submitButtonKey), findsOneWidget);
    });
  });

  group('home', () {
    testWidgets('shows the saved profile and the eligibility date', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await profiles.upsert(
        'uid-1',
        UserProfileMapper.toMap(
          sampleProfile(lastDonationDate: DateTime(2026, 2, 1)),
        ),
      );

      await pumpApp(
        tester,
        auth: auth,
        profiles: profiles,
        now: DateTime(2026, 3, 1),
      );

      // The feed is the landing tab; it explains the waiting period too.
      expect(find.text('No blood requests yet'), findsOneWidget);
      expect(find.textContaining('2 May 2026'), findsOneWidget);

      await openProfileTab(tester);
      expect(find.text('Taha Tahir'), findsOneWidget);
      // 1 Feb 2026 + 90 days = 2 May 2026.
      expect(find.textContaining('2 May 2026'), findsOneWidget);
    });

    testWidgets('says so when the donor is eligible', (tester) async {
      await seedVerifiedSignedInUser(auth);
      await profiles.upsert('uid-1', UserProfileMapper.toMap(sampleProfile()));

      await pumpApp(tester, auth: auth, profiles: profiles);
      await openProfileTab(tester);

      expect(
        find.textContaining('Eligible to donate by interval'),
        findsOneWidget,
      );
    });

    testWidgets('sign out returns to the sign-in screen', (tester) async {
      await seedVerifiedSignedInUser(auth);
      await profiles.upsert('uid-1', UserProfileMapper.toMap(sampleProfile()));
      await pumpApp(tester, auth: auth, profiles: profiles);

      await tester.tap(find.byKey(HomeShell.signOutButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(SignInPage.submitButtonKey), findsOneWidget);
    });
  });

  group('when the profile cannot be loaded', () {
    testWidgets('shows the failure with Try again, and Try again recovers', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await profiles.upsert('uid-1', UserProfileMapper.toMap(sampleProfile()));
      profiles.failWith = const NetworkFailure();

      await pumpApp(tester, auth: auth, profiles: profiles);

      expect(
        find.text('No connection. Check your internet and try again.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      profiles.failWith = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byKey(HomeShell.signOutButtonKey), findsOneWidget);
      await openProfileTab(tester);
      expect(find.text('Taha Tahir'), findsOneWidget);
    });

    testWidgets('a user stuck on the error screen can still sign out', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      profiles.failWith = const ServerFailure();

      await pumpApp(tester, auth: auth, profiles: profiles);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byKey(SignInPage.submitButtonKey), findsOneWidget);
    });

    testWidgets('a corrupted stored profile becomes a readable error', (
      tester,
    ) async {
      await seedVerifiedSignedInUser(auth);
      await profiles.upsert('uid-1', {'name': 42}); // wrong shape on purpose

      await pumpApp(tester, auth: auth, profiles: profiles);

      expect(
        find.text(
          'Your saved profile could not be read. Please re-enter your details.',
        ),
        findsOneWidget,
      );
    });
  });
}
