import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/mappers/donor_response_mapper.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/donor_response.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_urgency.dart';
import 'package:blood_donation_app/features/blood_request/presentation/pages/my_request_detail_page.dart';
import 'package:blood_donation_app/features/blood_request/presentation/pages/post_request_page.dart';
import 'package:blood_donation_app/features/blood_request/presentation/pages/request_detail_page.dart';
import 'package:blood_donation_app/features/blood_request/presentation/widgets/request_card.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/home/home_shell.dart';

import '../../../support/profile_fixtures.dart';
import '../../../support/pump_app.dart';
import '../../../support/request_fixtures.dart';

void main() {
  late InMemoryAuthDataSource auth;
  late InMemoryUserProfileDataSource profiles;
  late InMemoryBloodRequestDataSource requests;
  late InMemoryRequestResponseDataSource responses;

  setUp(() {
    auth = InMemoryAuthDataSource();
    profiles = InMemoryUserProfileDataSource();
    requests = InMemoryBloodRequestDataSource();
    responses = InMemoryRequestResponseDataSource();
  });

  /// Signs in 'uid-1' (a B+ donor living in G-9) with a saved profile and
  /// opens the app on the request feed.
  Future<void> launch(
    WidgetTester tester, {
    DateTime? lastDonationDate,
    bool isAvailable = true,
  }) async {
    await seedVerifiedSignedInUser(auth);
    final profile = sampleProfile(lastDonationDate: lastDonationDate);
    await profiles.upsert(
      'uid-1',
      UserProfileMapper.toMap(
        isAvailable ? profile : profile.copyWith(isAvailable: false),
      ),
    );
    await pumpApp(
      tester,
      auth: auth,
      profiles: profiles,
      requests: requests,
      responses: responses,
      ids: SequentialIdGenerator(),
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

  Future<void> openTab(WidgetTester tester, Key tab) async {
    await tester.tap(find.byKey(tab));
    await tester.pumpAndSettle();
  }

  Future<void> openRequest(WidgetTester tester, String id) async {
    await tester.tap(find.byKey(RequestCard.keyFor(id)));
    await tester.pumpAndSettle();
  }

  group('the feed', () {
    testWidgets('shows requests this donor can help and hides the rest', (
      tester,
    ) async {
      await seedRequest(requests, sampleRequest(id: 'for-me'));
      await seedRequest(
        requests,
        sampleRequest(id: 'wrong-group', bloodGroup: BloodGroup.aPositive),
      );
      await seedRequest(
        requests,
        sampleRequest(id: 'mine', requesterUid: 'uid-1'),
      );
      await seedRequest(
        requests,
        sampleRequest(id: 'closed', status: RequestStatus.fulfilled),
      );

      await launch(tester);

      expect(find.byKey(RequestCard.keyFor('for-me')), findsOneWidget);
      expect(find.byKey(RequestCard.keyFor('wrong-group')), findsNothing);
      expect(find.byKey(RequestCard.keyFor('mine')), findsNothing);
      expect(find.byKey(RequestCard.keyFor('closed')), findsNothing);
    });

    testWidgets('lists the most urgent request first', (tester) async {
      await seedRequest(
        requests,
        sampleRequest(id: 'planned', urgency: RequestUrgency.planned),
      );
      await seedRequest(
        requests,
        sampleRequest(id: 'critical', urgency: RequestUrgency.critical),
      );

      await launch(tester);

      final critical = tester.getTopLeft(
        find.byKey(RequestCard.keyFor('critical')),
      );
      final planned = tester.getTopLeft(
        find.byKey(RequestCard.keyFor('planned')),
      );
      expect(critical.dy, lessThan(planned.dy));
    });

    testWidgets('has an empty state', (tester) async {
      await launch(tester);

      expect(find.text('No blood requests yet'), findsOneWidget);
    });

    testWidgets('shows an error with Try again, and recovers', (tester) async {
      await seedRequest(requests, sampleRequest());
      requests.failWith = const NetworkFailure();

      await launch(tester);

      expect(
        find.text('No connection. Check your internet and try again.'),
        findsOneWidget,
      );

      requests.failWith = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byKey(RequestCard.keyFor('req-1')), findsOneWidget);
    });
  });

  group('helping with a request', () {
    testWidgets('I can help asks first, then shares the number', (
      tester,
    ) async {
      await seedRequest(requests, sampleRequest());
      await launch(tester);
      await openRequest(tester, 'req-1');

      await tester.tap(find.byKey(RequestDetailPage.respondButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('Share your number?'), findsOneWidget);

      await tester.tap(find.byKey(RequestDetailPage.confirmShareKey));
      await tester.pumpAndSettle();

      expect(find.textContaining('You offered to help.'), findsOneWidget);
      final stored = await responses.fetch('req-1', 'uid-1');
      expect(stored, isNotNull);
      expect(stored!['donorName'], 'Taha Tahir');
      expect('${stored['phone']}', contains('3001234567'));
    });

    testWidgets('cancelling the dialog shares nothing', (tester) async {
      await seedRequest(requests, sampleRequest());
      await launch(tester);
      await openRequest(tester, 'req-1');

      await tester.tap(find.byKey(RequestDetailPage.respondButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(RequestDetailPage.cancelShareKey));
      await tester.pumpAndSettle();

      expect(await responses.fetch('req-1', 'uid-1'), isNull);
      expect(find.byKey(RequestDetailPage.respondButtonKey), findsOneWidget);
    });

    testWidgets('withdrawing removes the response', (tester) async {
      await seedRequest(requests, sampleRequest());
      await launch(tester);
      await openRequest(tester, 'req-1');
      await tester.tap(find.byKey(RequestDetailPage.respondButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(RequestDetailPage.confirmShareKey));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(RequestDetailPage.withdrawButtonKey));
      await tester.pumpAndSettle();

      expect(await responses.fetch('req-1', 'uid-1'), isNull);
      expect(find.byKey(RequestDetailPage.respondButtonKey), findsOneWidget);
    });

    testWidgets('a donor still in the 90-day wait cannot respond', (
      tester,
    ) async {
      await seedRequest(requests, sampleRequest());
      await launch(tester, lastDonationDate: DateTime(2026, 2, 1));
      await openRequest(tester, 'req-1');

      final button = tester.widget<FilledButton>(
        find.byKey(RequestDetailPage.respondButtonKey),
      );
      expect(button.onPressed, isNull);
      expect(find.textContaining('You can donate again in'), findsOneWidget);
    });

    testWidgets('an unavailable donor cannot respond', (tester) async {
      await seedRequest(requests, sampleRequest());
      await launch(tester, isAvailable: false);
      await openRequest(tester, 'req-1');

      final button = tester.widget<FilledButton>(
        find.byKey(RequestDetailPage.respondButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('a storage failure keeps the donor on the request with a '
        'message', (tester) async {
      await seedRequest(requests, sampleRequest());
      await launch(tester);
      await openRequest(tester, 'req-1');
      responses.failWith = const NetworkFailure();

      await tester.tap(find.byKey(RequestDetailPage.respondButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(RequestDetailPage.confirmShareKey));
      await tester.pumpAndSettle();

      expect(
        find.text('No connection. Check your internet and try again.'),
        findsWidgets,
      );
      expect(find.textContaining('You offered to help.'), findsNothing);
    });
  });

  group('posting a request', () {
    testWidgets('a valid request appears under My requests', (tester) async {
      await launch(tester);

      await tester.tap(find.byKey(HomeShell.postRequestButtonKey));
      await tester.pumpAndSettle();
      await choose(tester, PostRequestPage.bloodGroupFieldKey, 'A+');
      await choose(
        tester,
        PostRequestPage.hospitalFieldKey,
        placeLabel('pims_islamabad'),
      );
      await tester.tap(find.byKey(PostRequestPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text('Request posted. Donors who can help will respond.'),
        findsOneWidget,
      );
      expect(find.byKey(RequestCard.keyFor('id-1')), findsOneWidget);
      final stored = requests.documentById('id-1');
      expect(stored, isNotNull);
      expect(stored!['requesterUid'], 'uid-1');
      expect(stored['bloodGroup'], BloodGroup.aPositive.name);
    });

    testWidgets('blood group and hospital are required', (tester) async {
      await launch(tester);
      await tester.tap(find.byKey(HomeShell.postRequestButtonKey));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(PostRequestPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(PostRequestPage.submitButtonKey), findsOneWidget);
      expect(requests.documentById('id-1'), isNull);
    });

    testWidgets('a storage failure keeps the form open', (tester) async {
      await launch(tester);
      await tester.tap(find.byKey(HomeShell.postRequestButtonKey));
      await tester.pumpAndSettle();
      await choose(tester, PostRequestPage.bloodGroupFieldKey, 'A+');
      await choose(
        tester,
        PostRequestPage.hospitalFieldKey,
        placeLabel('pims_islamabad'),
      );
      requests.failWith = const NetworkFailure();

      await tester.tap(find.byKey(PostRequestPage.submitButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text('No connection. Check your internet and try again.'),
        findsOneWidget,
      );
      expect(find.byKey(PostRequestPage.submitButtonKey), findsOneWidget);
    });
  });

  group('my requests', () {
    Future<void> seedOwnRequestWithOffer() async {
      await seedRequest(
        requests,
        sampleRequest(
          id: 'mine',
          requesterUid: 'uid-1',
          requesterName: 'Taha Tahir',
        ),
      );
      final response = DonorResponseFixture.offer(requestId: 'mine');
      await responses.create(
        'mine',
        response.donorUid,
        DonorResponseMapper.toMap(response),
      );
    }

    testWidgets('has an empty state', (tester) async {
      await launch(tester);

      await openTab(tester, HomeShell.myRequestsTabKey);

      expect(find.text('You have not posted any requests'), findsOneWidget);
    });

    testWidgets('shows who offered to help, with their number', (tester) async {
      await seedOwnRequestWithOffer();
      await launch(tester);

      await openTab(tester, HomeShell.myRequestsTabKey);
      await openRequest(tester, 'mine');

      expect(find.text('Bilal Khan'), findsOneWidget);
      expect(find.textContaining('3111234567'), findsOneWidget);
    });

    testWidgets('the copy button puts the number on the clipboard', (
      tester,
    ) async {
      await seedOwnRequestWithOffer();
      await launch(tester);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await openTab(tester, HomeShell.myRequestsTabKey);
      await openRequest(tester, 'mine');

      await tester.tap(find.byKey(MyRequestDetailPage.copyKeyFor('bilal-uid')));
      await tester.pumpAndSettle();

      expect(copied, contains('3111234567'));
      expect(find.text('Number copied'), findsOneWidget);
    });

    testWidgets('marking a request fulfilled closes it', (tester) async {
      await seedOwnRequestWithOffer();
      await launch(tester);
      await openTab(tester, HomeShell.myRequestsTabKey);
      await openRequest(tester, 'mine');

      await tester.tap(find.byKey(MyRequestDetailPage.fulfilButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(MyRequestDetailPage.confirmKey));
      await tester.pumpAndSettle();

      final stored = requests.documentById('mine');
      expect(stored!['status'], RequestStatus.fulfilled.name);
      expect(find.byKey(MyRequestDetailPage.fulfilButtonKey), findsNothing);
    });

    testWidgets('cancelling a request closes it', (tester) async {
      await seedOwnRequestWithOffer();
      await launch(tester);
      await openTab(tester, HomeShell.myRequestsTabKey);
      await openRequest(tester, 'mine');

      await tester.tap(find.byKey(MyRequestDetailPage.cancelRequestButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(MyRequestDetailPage.confirmKey));
      await tester.pumpAndSettle();

      expect(
        requests.documentById('mine')!['status'],
        RequestStatus.cancelled.name,
      );
    });

    testWidgets('going back from the confirmation changes nothing', (
      tester,
    ) async {
      await seedOwnRequestWithOffer();
      await launch(tester);
      await openTab(tester, HomeShell.myRequestsTabKey);
      await openRequest(tester, 'mine');

      await tester.tap(find.byKey(MyRequestDetailPage.fulfilButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(MyRequestDetailPage.backKey));
      await tester.pumpAndSettle();

      expect(requests.documentById('mine')!['status'], RequestStatus.open.name);
    });

    testWidgets('shows an error with Try again when loading fails', (
      tester,
    ) async {
      await launch(tester);
      requests.failWith = const NetworkFailure();

      await openTab(tester, HomeShell.myRequestsTabKey);

      expect(
        find.text('No connection. Check your internet and try again.'),
        findsOneWidget,
      );
      requests.failWith = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('You have not posted any requests'), findsOneWidget);
    });
  });

  testWidgets('signing out while a request is open returns to sign-in', (
    tester,
  ) async {
    await seedRequest(requests, sampleRequest());
    await launch(tester);
    await openRequest(tester, 'req-1');

    // The detail page covers the shell's app bar, so sign out through the
    // session itself, as an expired token would.
    await auth.signOut();
    await tester.pumpAndSettle();

    expect(find.byKey(SignInPage.submitButtonKey), findsOneWidget);
    expect(find.byKey(RequestDetailPage.respondButtonKey), findsNothing);
  });
}

/// A ready-made offer from another donor, for the requester's screens.
abstract final class DonorResponseFixture {
  static DonorResponse offer({required String requestId}) {
    final map = <String, dynamic>{
      'donorUid': 'bilal-uid',
      'donorName': 'Bilal Khan',
      'phone': '+923111234567',
      'bloodGroup': BloodGroup.oNegative.name,
      'locationId': 'f7_islamabad',
      'respondedAt': testNow.subtract(const Duration(minutes: 5)),
    };
    final result = DonorResponseMapper.fromMap(requestId, 'bilal-uid', map);
    return (result as Success<DonorResponse>).value;
  }
}
