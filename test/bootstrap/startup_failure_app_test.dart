import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/bootstrap/startup_failure_app.dart';

void main() {
  testWidgets('shows the failure message and calls onRetry when tapped', (
    tester,
  ) async {
    var retries = 0;

    await tester.pumpWidget(StartupFailureApp(onRetry: () => retries++));

    expect(find.text('The app could not start'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(retries, 1);
  });
}
