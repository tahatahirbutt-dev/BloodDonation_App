import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/donor_response.dart';

part 'request_responses.g.dart';

/// The donors who offered to help with [requestId] (requester's view).
@riverpod
Future<List<DonorResponse>> requestResponses(Ref ref, String requestId) async {
  final result = await ref.watch(getRequestResponsesProvider).call(requestId);
  return switch (result) {
    Success<List<DonorResponse>>(:final value) => value,
    Err<List<DonorResponse>>(:final failure) => throw failure,
  };
}
