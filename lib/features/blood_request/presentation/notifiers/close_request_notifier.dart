import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/request_status.dart';
import 'my_requests.dart';

part 'close_request_notifier.g.dart';

/// The requester marking their request fulfilled or cancelled.
@riverpod
class CloseRequest extends _$CloseRequest {
  @override
  FutureOr<void> build() {}

  /// Returns true only when the status was changed, so the page knows it
  /// may close itself.
  Future<bool> close({
    required String requestId,
    required String requesterUid,
    required RequestStatus status,
  }) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(closeBloodRequestProvider)
        .call(requestId: requestId, status: status);
    if (!ref.mounted) return false;
    state = asyncVoidFromResult(result);
    if (result is Success<void>) {
      ref.invalidate(myRequestsProvider(requesterUid));
      return true;
    }
    return false;
  }
}
