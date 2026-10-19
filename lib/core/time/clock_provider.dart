import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'clock.dart';

part 'clock_provider.g.dart';

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();
