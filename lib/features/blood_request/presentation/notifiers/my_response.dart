import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/donor_response.dart';

part 'my_response.g.dart';

/// This donor's own response to [requestId]; `null` data = none yet.
@riverpod
Future<DonorResponse?> myResponse(
  Ref ref,
  String requestId,
  String donorUid,
) async {
  final result = await ref
      .watch(getMyResponseProvider)
      .call(requestId: requestId, donorUid: donorUid);
  return switch (result) {
    Success<DonorResponse?>(:final value) => value,
    Err<DonorResponse?>(:final failure) => throw failure,
  };
}
