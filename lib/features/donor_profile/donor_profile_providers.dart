import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/observability/error_reporter_provider.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import 'data/datasources/user_profile_remote_data_source.dart';
import 'data/repositories/user_profile_repository_impl.dart';
import 'domain/repositories/user_profile_repository.dart';
import 'domain/usecases/get_user_profile.dart';
import 'domain/usecases/save_user_profile.dart';

part 'donor_profile_providers.g.dart';

// This file is the feature's composition root: the only place that knows
// which concrete classes satisfy the domain interfaces. Everything above
// it (notifiers, widgets) reads the abstractions. Generated with
// `dart run build_runner build --delete-conflicting-outputs`.

/// Deliberately has no default. `main()` must override it with the
/// Firestore implementation (or the in-memory one while developing), and
/// tests override it with a fake. Forgetting fails loudly at startup
/// instead of silently running against the wrong store.
@Riverpod(keepAlive: true)
UserProfileRemoteDataSource userProfileRemoteDataSource(Ref ref) {
  throw UnimplementedError(
    'Override userProfileRemoteDataSourceProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) {
  final reporter = ref.watch(errorReporterProvider);
  return UserProfileRepositoryImpl(
    ref.watch(userProfileRemoteDataSourceProvider),
    // Unexpected repository errors (anything that is not a typed
    // DataSourceException) go to Crashlytics in production.
    reportUnexpectedError: (error, stackTrace) =>
        reporter.report(error, stackTrace),
  );
}

@riverpod
SaveUserProfile saveUserProfile(Ref ref) {
  return SaveUserProfile(
    ref.watch(userProfileRepositoryProvider),
    clock: ref.watch(clockProvider).now,
  );
}

@riverpod
GetUserProfile getUserProfile(Ref ref) {
  return GetUserProfile(ref.watch(userProfileRepositoryProvider));
}
