import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/blood_request.dart';

part 'my_requests.g.dart';

/// Everything [uid] has posted, newest first.
@riverpod
Future<List<BloodRequest>> myRequests(Ref ref, String uid) async {
  final result = await ref.watch(getMyRequestsProvider).call(uid);
  return switch (result) {
    Success<List<BloodRequest>>(:final value) => value,
    Err<List<BloodRequest>>(:final failure) => throw failure,
  };
}
