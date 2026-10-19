import 'package:blood_donation_app/core/error/result.dart';

import '../repositories/request_response_repository.dart';

/// "I can't make it after all": removes the donor's response, so the
/// requester stops seeing their number.
class WithdrawResponse {
  const WithdrawResponse(this._repository);

  final RequestResponseRepository _repository;

  Future<Result<void>> call({
    required String requestId,
    required String donorUid,
  }) => _repository.withdraw(requestId: requestId, donorUid: donorUid);
}
