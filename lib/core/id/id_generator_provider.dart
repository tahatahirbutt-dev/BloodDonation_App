import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'id_generator.dart';

part 'id_generator_provider.g.dart';

/// Tests override this with a sequential fake.
@Riverpod(keepAlive: true)
IdGenerator idGenerator(Ref ref) => RandomIdGenerator();
