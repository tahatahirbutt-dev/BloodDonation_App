import 'package:blood_donation_app/core/time/clock.dart';

/// A [Clock] frozen at one instant, so time-based text in widgets is the
/// same on every run.
final class FixedClock implements Clock {
  const FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
