import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('a signed-out user lands on the sign-in screen', (tester) async {
    await pumpApp(
      tester,
      auth: InMemoryAuthDataSource(),
      profiles: InMemoryUserProfileDataSource(),
    );

    expect(find.byKey(SignInPage.submitButtonKey), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
