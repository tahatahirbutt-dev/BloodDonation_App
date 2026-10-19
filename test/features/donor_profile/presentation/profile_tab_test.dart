import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/presentation/pages/profile_tab.dart';
import 'package:blood_donation_app/home/home_shell.dart';

import '../../../support/profile_fixtures.dart';
import '../../../support/pump_app.dart';
import '../../../support/request_fixtures.dart';

void main() {
  late InMemoryAuthDataSource auth;
  late InMemoryUserProfileDataSource profiles;

  setUp(() {
    auth = InMemoryAuthDataSource();
    profiles = InMemoryUserProfileDataSource();
  });

  Future<void> launchOnProfileTab(WidgetTester tester) async {
    await seedVerifiedSignedInUser(auth);
    await profiles.upsert('uid-1', UserProfileMapper.toMap(sampleProfile()));
    await pumpApp(tester, auth: auth, profiles: profiles, now: testNow);
    await tester.tap(find.byKey(HomeShell.profileTabKey));
    await tester.pumpAndSettle();
  }

  Future<bool?> storedFlag(String field) async =>
      (await profiles.fetch('uid-1'))?[field] as bool?;

  testWidgets('switching availability off is saved', (tester) async {
    await launchOnProfileTab(tester);
    expect(await storedFlag('isAvailable'), isTrue);

    await tester.tap(find.byKey(ProfileTab.availableSwitchKey));
    await tester.pumpAndSettle();

    expect(await storedFlag('isAvailable'), isFalse);
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(ProfileTab.availableSwitchKey))
          .value,
      isFalse,
    );
  });

  testWidgets('switching visibility off is saved', (tester) async {
    await launchOnProfileTab(tester);

    await tester.tap(find.byKey(ProfileTab.visibleSwitchKey));
    await tester.pumpAndSettle();

    expect(await storedFlag('isVisible'), isFalse);
  });

  testWidgets('a failed save shows a message and keeps the old value', (
    tester,
  ) async {
    await launchOnProfileTab(tester);
    profiles.failWith = const NetworkFailure();

    await tester.tap(find.byKey(ProfileTab.availableSwitchKey));
    await tester.pumpAndSettle();

    expect(
      find.text('No connection. Check your internet and try again.'),
      findsOneWidget,
    );
    profiles.failWith = null;
    expect(await storedFlag('isAvailable'), isTrue);
  });
}
