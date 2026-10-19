import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/id/id_generator_provider.dart';
import 'package:blood_donation_app/core/observability/error_reporter_provider.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';

import 'data/datasources/blood_request_remote_data_source.dart';
import 'data/datasources/request_response_remote_data_source.dart';
import 'data/repositories/blood_request_repository_impl.dart';
import 'data/repositories/request_response_repository_impl.dart';
import 'domain/repositories/blood_request_repository.dart';
import 'domain/repositories/request_response_repository.dart';
import 'domain/usecases/close_blood_request.dart';
import 'domain/usecases/get_my_requests.dart';
import 'domain/usecases/get_my_response.dart';
import 'domain/usecases/get_nearby_requests.dart';
import 'domain/usecases/get_request_responses.dart';
import 'domain/usecases/post_blood_request.dart';
import 'domain/usecases/respond_to_request.dart';
import 'domain/usecases/withdraw_response.dart';

part 'blood_request_providers.g.dart';

// The feature's composition root, same idea as donor_profile_providers.dart:
// the only file that knows which concrete classes satisfy the domain
// interfaces. Generated with
// `dart run build_runner build --delete-conflicting-outputs`.

/// No default on purpose: `bootstrap()` overrides it with the Firestore
/// implementation and tests override it with the in-memory one. Forgetting
/// fails loudly at startup instead of silently using the wrong store.
@Riverpod(keepAlive: true)
BloodRequestRemoteDataSource bloodRequestRemoteDataSource(Ref ref) {
  throw UnimplementedError(
    'Override bloodRequestRemoteDataSourceProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
RequestResponseRemoteDataSource requestResponseRemoteDataSource(Ref ref) {
  throw UnimplementedError(
    'Override requestResponseRemoteDataSourceProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
BloodRequestRepository bloodRequestRepository(Ref ref) {
  return BloodRequestRepositoryImpl(
    ref.watch(bloodRequestRemoteDataSourceProvider),
    reporter: ref.watch(errorReporterProvider),
  );
}

@Riverpod(keepAlive: true)
RequestResponseRepository requestResponseRepository(Ref ref) {
  return RequestResponseRepositoryImpl(
    ref.watch(requestResponseRemoteDataSourceProvider),
    reporter: ref.watch(errorReporterProvider),
  );
}

@riverpod
PostBloodRequest postBloodRequest(Ref ref) {
  return PostBloodRequest(
    ref.watch(bloodRequestRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
    clock: ref.watch(clockProvider).now,
  );
}

@riverpod
GetNearbyRequests getNearbyRequests(Ref ref) {
  return GetNearbyRequests(
    ref.watch(bloodRequestRepositoryProvider),
    clock: ref.watch(clockProvider).now,
  );
}

@riverpod
GetMyRequests getMyRequests(Ref ref) {
  return GetMyRequests(ref.watch(bloodRequestRepositoryProvider));
}

@riverpod
CloseBloodRequest closeBloodRequest(Ref ref) {
  return CloseBloodRequest(ref.watch(bloodRequestRepositoryProvider));
}

@riverpod
RespondToRequest respondToRequest(Ref ref) {
  return RespondToRequest(
    ref.watch(requestResponseRepositoryProvider),
    clock: ref.watch(clockProvider).now,
  );
}

@riverpod
WithdrawResponse withdrawResponse(Ref ref) {
  return WithdrawResponse(ref.watch(requestResponseRepositoryProvider));
}

@riverpod
GetMyResponse getMyResponse(Ref ref) {
  return GetMyResponse(ref.watch(requestResponseRepositoryProvider));
}

@riverpod
GetRequestResponses getRequestResponses(Ref ref) {
  return GetRequestResponses(ref.watch(requestResponseRepositoryProvider));
}
