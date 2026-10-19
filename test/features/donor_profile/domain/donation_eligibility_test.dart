import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/features/donor_profile/domain/entities/donation_eligibility.dart';

void main() {
  group('DonationEligibility.evaluate', () {
    test('never donated -> eligible', () {
      final result = DonationEligibility.evaluate(
        lastDonationDate: null,
        now: DateTime(2026, 6, 15),
      );
      expect(result, isA<EligibleToDonate>());
    });

    // 1 Jan 2026 + 90 days = 1 Apr 2026 (31 + 28 + 31).
    test('one day before the interval ends -> not yet eligible', () {
      final result = DonationEligibility.evaluate(
        lastDonationDate: DateTime(2026, 1, 1),
        now: DateTime(2026, 3, 31, 23, 59),
      );
      expect(
        result,
        isA<NotYetEligible>()
            .having((r) => r.daysRemaining, 'daysRemaining', 1)
            .having(
              (r) => r.nextEligibleDate,
              'nextEligibleDate',
              DateTime(2026, 4, 1),
            ),
      );
    });

    test('exactly on day 90 -> eligible', () {
      final result = DonationEligibility.evaluate(
        lastDonationDate: DateTime(2026, 1, 1),
        now: DateTime(2026, 4, 1),
      );
      expect(result, isA<EligibleToDonate>());
    });

    test('time of day on the donation date does not shift the result', () {
      final result = DonationEligibility.evaluate(
        lastDonationDate: DateTime(2026, 1, 1, 23, 30),
        now: DateTime(2026, 4, 1, 0, 5),
      );
      expect(result, isA<EligibleToDonate>());
    });

    test('donated today -> full interval remaining', () {
      final result = DonationEligibility.evaluate(
        lastDonationDate: DateTime(2026, 6, 15),
        now: DateTime(2026, 6, 15, 9),
      );
      expect(
        result,
        isA<NotYetEligible>().having(
          (r) => r.daysRemaining,
          'daysRemaining',
          DonationEligibility.minimumIntervalDays,
        ),
      );
    });
  });
}
