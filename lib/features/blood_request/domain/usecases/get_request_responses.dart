import 'package:blood_donation_app/core/error/result.dart';

import '../entities/donor_response.dart';
import '../repositories/request_response_repository.dart';

/// The donors who offered to help with a request. Only the requester can
/// read these; for anyone else the repository returns a permission
/// failure.
class GetRequestResponses {
  const GetRequestResponses(this._repository);

  final RequestResponseRepository _repository;

  Future<Result<List<DonorResponse>>> call(String requestId) =>
      _repository.getResponses(requestId);
}
