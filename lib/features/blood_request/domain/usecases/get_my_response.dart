import 'package:blood_donation_app/core/error/result.dart';

import '../entities/donor_response.dart';
import '../repositories/request_response_repository.dart';

/// This donor's response to one request, or `Success(null)` if none.
class GetMyResponse {
  const GetMyResponse(this._repository);

  final RequestResponseRepository _repository;

  Future<Result<DonorResponse?>> call({
    required String requestId,
    required String donorUid,
  }) => _repository.getMyResponse(requestId: requestId, donorUid: donorUid);
}
