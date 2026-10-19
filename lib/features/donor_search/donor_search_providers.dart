import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/observability/error_reporter_provider.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import 'data/datasources/donor_directory_remote_data_source.dart';
import 'data/repositories/donor_directory_repository_impl.dart';
import 'domain/repositories/donor_directory_repository.dart';
import 'domain/usecases/search_donors.dart';

part 'donor_search_providers.g.dart';

// Composition root for the donor-search feature. Generated with
// `dart run build_runner build --delete-conflicting-outputs`.

/// No default on purpose: `bootstrap()` overrides it with the Firestore
/// implementation and tests with the in-memory one.
@Riverpod(keepAlive: true)
DonorDirectoryRemoteDataSource donorDirectoryRemoteDataSource(Ref ref) {
  throw UnimplementedError(
    'Override donorDirectoryRemoteDataSourceProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
DonorDirectoryRepository donorDirectoryRepository(Ref ref) {
  return DonorDirectoryRepositoryImpl(
    ref.watch(donorDirectoryRemoteDataSourceProvider),
    reporter: ref.watch(errorReporterProvider),
  );
}

@riverpod
SearchDonors searchDonors(Ref ref) {
  return SearchDonors(
    ref.watch(donorDirectoryRepositoryProvider),
    clock: ref.watch(clockProvider).now,
  );
}
