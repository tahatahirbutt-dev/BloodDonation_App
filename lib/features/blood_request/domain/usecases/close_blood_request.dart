import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

import '../entities/request_status.dart';
import '../repositories/blood_request_repository.dart';

/// The requester closes their own request: "fulfilled" (got the blood) or
/// "cancelled" (no longer needed). A request is never reopened, so the
/// only valid targets are those two.
class CloseBloodRequest {
  const CloseBloodRequest(this._repository);

  final BloodRequestRepository _repository;

  Future<Result<void>> call({
    required String requestId,
    required RequestStatus status,
  }) {
    if (status == RequestStatus.open) {
      return Future.value(
        const Err<void>(
          ValidationFailure(
            'A request can only be marked fulfilled or cancelled.',
          ),
        ),
      );
    }
    return _repository.updateStatus(requestId: requestId, status: status);
  }
}
