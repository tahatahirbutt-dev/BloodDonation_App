/// "What time is it?" as an interface, so screens that show time-based
/// text (such as donation eligibility) can be tested with a fixed time
/// instead of the real clock.
abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
