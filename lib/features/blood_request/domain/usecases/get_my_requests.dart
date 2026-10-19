import 'package:blood_donation_app/core/error/result.dart';

import '../entities/blood_request.dart';
import '../repositories/blood_request_repository.dart';

/// Everything the signed-in user has posted, newest first.
class GetMyRequests {
  const GetMyRequests(this._repository);

  final BloodRequestRepository _repository;

  Future<Result<List<BloodRequest>>> call(String uid) =>
      _repository.getRequestsByRequester(uid);
}
