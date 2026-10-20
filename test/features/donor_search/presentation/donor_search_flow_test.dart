import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/blood_request/presentation/pages/post_request_page.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_search/data/datasources/in_memory_donor_directory_data_source.dart';
import 'package:blood_donation_app/features/donor_search/presentation/pages/donor_search_tab.dart';
import 'package:blood_donation_app/home/home_shell.dart';

import '../../../support/profile_fixtures.dart';
import '../../../support/pump_app.dart';
import '../../../support/request_fixtures.dart';

void main() {
  late InMemoryAuthDataSource auth;
  late InMemoryUserProfileDataSource profiles;
  late InMemoryDonorDirectoryDataSource directory;

  setUp(() {
    auth = InMemoryAuthDataSource();
    profiles = InMemoryUserProfileDataSource();
    directory = InMemoryDonorDirectoryDataSource();
  });

  Future<void> launch(WidgetTester tester) async {
    await seedVerifiedSignedInUser(auth);
    await profiles.upsert('uid-1', UserProfileMapper.toMap(sampleProfile()));
    await pumpApp(
      tester,
      auth: auth,
      profiles: profiles,
      directory: directory,
      now: testNow,
    );
  }

  String placeLabel(String id) {
    final place = LocationCatalog.all.firstWhere((l) => l.id == id);
    return '${place.name}, ${place.city}';
  }

  Future<void> choose(WidgetTester tester, Key field, String label) async {
    await tester.tap(find.byKey(field));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  void seedDonor(
    String uid,
    BloodGroup group,
    String locationId, {
    String? name,
  }) {
    directory.seed(
      uid,
      directoryEntry(
        name: name ?? 'Donor $uid',
        bloodGroup: group,
        locationId: locationId,
      ),
    );
  }

  Future<void> openSearch(WidgetTester tester) async {
    await tester.tap(find.byKey(HomeShell.donorsTabKey));
    await tester.pumpAndSettle();
  }

  Future<void> search(
    WidgetTester tester, {
    String group = 'B+',
    String center = 'g9_islamabad',
  }) async {
    await choose(tester, DonorSearchTab.bloodGroupFieldKey, group);
    await choose(tester, DonorSearchTab.centerFieldKey, placeLabel(center));
    await tester.tap(find.byKey(DonorSearchTab.searchButtonKey));
    await tester.pumpAndSettle();
  }

  testWidgets('lists compatible donors nearest first, without any phone '
      'number', (tester) async {
    seedDonor('near', BloodGroup.oNegative, 'g9_islamabad', name: 'Near Donor');
    seedDonor(
      'far',
      BloodGroup.bPositive,
      'afit_rawalpindi',
      name: 'Far Donor',
    );
    seedDonor(
      'wrong',
      BloodGroup.aPositive,
      'g9_islamabad',
      name: 'Wrong Group',
    );
    await launch(tester);
    await openSearch(tester);

    // AFIT is about 11 km from G-9, so the default 10 km would miss it.
    await tester.tap(find.byKey(DonorSearchTab.radiusKeyFor(25)));
    await tester.pumpAndSettle();
    await search(tester);

    expect(find.byKey(DonorSearchTab.resultKeyFor('near')), findsOneWidget);
    expect(find.byKey(DonorSearchTab.resultKeyFor('far')), findsOneWidget);
    expect(find.byKey(DonorSearchTab.resultKeyFor('wrong')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(DonorSearchTab.resultKeyFor('near'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(DonorSearchTab.resultKeyFor('far'))).dy,
      ),
    );
    expect(find.textContaining('+92'), findsNothing);
  });

  testWidgets('a smaller radius leaves out donors beyond it', (tester) async {
    seedDonor('near', BloodGroup.oNegative, 'g9_islamabad');
    seedDonor('far', BloodGroup.oNegative, 'afit_rawalpindi');
    await launch(tester);
    await openSearch(tester);

    await tester.tap(find.byKey(DonorSearchTab.radiusKeyFor(5)));
    await tester.pumpAndSettle();
    await search(tester);

    expect(find.byKey(DonorSearchTab.resultKeyFor('near')), findsOneWidget);
    expect(find.byKey(DonorSearchTab.resultKeyFor('far')), findsNothing);
  });

  testWidgets('shows an empty state and offers to post a request', (
    tester,
  ) async {
    await launch(tester);
    await openSearch(tester);

    await search(tester);

    expect(find.text('No matching donors nearby'), findsOneWidget);
    await tester.ensureVisible(find.byKey(DonorSearchTab.postRequestButtonKey));
    await tester.tap(find.byKey(DonorSearchTab.postRequestButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(PostRequestPage.submitButtonKey), findsOneWidget);
  });

  testWidgets('shows an error and lets the user search again', (tester) async {
    seedDonor('near', BloodGroup.oNegative, 'g9_islamabad');
    await launch(tester);
    await openSearch(tester);
    directory.failWith = const NetworkFailure();

    await search(tester);

    expect(
      find.text('No connection. Check your internet and try again.'),
      findsOneWidget,
    );

    directory.failWith = null;
    await tester.tap(find.byKey(DonorSearchTab.searchButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(DonorSearchTab.resultKeyFor('near')), findsOneWidget);
  });

  testWidgets('searching without choosing a blood group or place does not '
      'query', (tester) async {
    seedDonor('near', BloodGroup.oNegative, 'g9_islamabad');
    await launch(tester);
    await openSearch(tester);

    await tester.tap(find.byKey(DonorSearchTab.searchButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(DonorSearchTab.resultKeyFor('near')), findsNothing);
  });
}
