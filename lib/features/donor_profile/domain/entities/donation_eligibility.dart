/// Whether a donor has waited long enough since their last donation.
///
/// This is only the *interval* rule. It says nothing about health —
/// the blood bank's own screening always decides. The UI should word it
/// as "eligible by interval", never "cleared to donate".
sealed class DonationEligibility {
  const DonationEligibility();

  /// Minimum gap between whole-blood donations. 90 days is the working
  /// figure for v1; confirm against the guidance of the blood banks you
  /// partner with (some use a longer interval for women) and change it
  /// here, in one place.
  static const int minimumIntervalDays = 90;

  /// [now] is a parameter, not `DateTime.now()`, so tests never depend
  /// on the real clock. Works on calendar days: time-of-day and DST are
  /// ignored, so "90 days later" always means the same date.
  static DonationEligibility evaluate({
    required DateTime? lastDonationDate,
    required DateTime now,
  }) {
    if (lastDonationDate == null) return const EligibleToDonate();

    final next = DateTime.utc(
      lastDonationDate.year,
      lastDonationDate.month,
      lastDonationDate.day + minimumIntervalDays,
    );
    final today = DateTime.utc(now.year, now.month, now.day);

    if (!today.isBefore(next)) return const EligibleToDonate();

    return NotYetEligible(
      nextEligibleDate: DateTime(next.year, next.month, next.day),
      daysRemaining: next.difference(today).inDays,
    );
  }
}

final class EligibleToDonate extends DonationEligibility {
  const EligibleToDonate();
}

final class NotYetEligible extends DonationEligibility {
  const NotYetEligible({
    required this.nextEligibleDate,
    required this.daysRemaining,
  });

  /// Local, date-only.
  final DateTime nextEligibleDate;
  final int daysRemaining;
}
