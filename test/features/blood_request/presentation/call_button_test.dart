import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/platform/phone_dialer.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/presentation/pages/my_request_detail_page.dart';
import 'package:blood_donation_app/features/blood_request/presentation/widgets/request_card.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/home/home_shell.dart';

import '../../../support/profile_fixtures.dart';
import '../../../support/pump_app.dart';
import '../../../support/request_fixtures.dart';

final class _FakePhoneDialer implements PhoneDialer {
  final List<String> dialled = [];
  Failure? failWith;

  @override
  Future<Result<void>> dial(String number) async {
    final failure = failWith;
    if (failure != null) return Err<void>(failure);
    dialled.add(number);
    return const Success<void>(null);
  }
}

void main() {
  late InMemoryAuthDataSource auth;
  late InMemoryUserProfileDataSource profiles;
  late InMemoryBloodRequestDataSource requests;
  late InMemoryRequestResponseDataSource responses;
  late _FakePhoneDialer dialer;

  setUp(() {
    auth = InMemoryAuthDataSource();
    profiles = InMemoryUserProfileDataSource();
    requests = InMemoryBloodRequestDataSource();
    responses = InMemoryRequestResponseDataSource();
    dialer = _FakePhoneDialer();
  });

  Future<void> openMyRequestWithOffer(WidgetTester tester) async {
    await seedVerifiedSignedInUser(auth);
    await profiles.upsert('uid-1', UserProfileMapper.toMap(sampleProfile()));
    await seedRequest(
      requests,
      sampleRequest(
        id: 'mine',
        requesterUid: 'uid-1',
        requesterName: 'Taha Tahir',
      ),
    );
    await responses.create('mine', 'bilal-uid', <String, dynamic>{
      'donorUid': 'bilal-uid',
      'donorName': 'Bilal Khan',
      'phone': '+923111234567',
      'bloodGroup': BloodGroup.oNegative.name,
      'locationId': 'f7_islamabad',
      'respondedAt': testNow.subtract(const Duration(minutes: 5)),
    });
    await pumpApp(
      tester,
      auth: auth,
      profiles: profiles,
      requests: requests,
      responses: responses,
      phoneDialer: dialer,
      now: testNow,
    );
    await tester.tap(find.byKey(HomeShell.myRequestsTabKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(RequestCard.keyFor('mine')));
    await tester.pumpAndSettle();
  }

  testWidgets('the call button opens the dialer with the donor\'s number', (
    tester,
  ) async {
    await openMyRequestWithOffer(tester);

    await tester.tap(find.byKey(MyRequestDetailPage.callKeyFor('bilal-uid')));
    await tester.pumpAndSettle();

    expect(dialer.dialled, ['+923111234567']);
  });

  testWidgets('shows a message when the phone app cannot be opened', (
    tester,
  ) async {
    await openMyRequestWithOffer(tester);
    dialer.failWith = const ServerFailure(
      'Could not open the phone app. Copy the number instead.',
    );

    await tester.tap(find.byKey(MyRequestDetailPage.callKeyFor('bilal-uid')));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not open the phone app. Copy the number instead.'),
      findsOneWidget,
    );
  });
}
