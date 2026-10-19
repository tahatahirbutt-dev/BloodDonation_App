import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/entities/donor_response.dart';
import 'my_response.dart';

part 'respond_action_notifier.g.dart';

/// The donor's "I can help" and "withdraw" actions on one request.
/// Idle (`AsyncData`), working (`AsyncLoading`) or failed (`AsyncError`
/// with a typed `Failure`). On success the donor's stored response is
/// re-read so the detail page flips between its two states.
@riverpod
class RespondAction extends _$RespondAction {
  @override
  FutureOr<void> build(String requestId) {}

  Future<void> respond({
    required BloodRequest request,
    required UserProfile donor,
  }) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(respondToRequestProvider)
        .call(request: request, donor: donor);
    if (!ref.mounted) return;
    state = asyncVoidFromResult(result);
    if (result is Success<DonorResponse>) {
      ref.invalidate(myResponseProvider(requestId, donor.uid));
    }
  }

  Future<void> withdraw({required String donorUid}) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(withdrawResponseProvider)
        .call(requestId: requestId, donorUid: donorUid);
    if (!ref.mounted) return;
    state = asyncVoidFromResult(result);
    if (result is Success<void>) {
      ref.invalidate(myResponseProvider(requestId, donorUid));
    }
  }
}
