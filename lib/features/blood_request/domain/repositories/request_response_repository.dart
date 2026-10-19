import 'package:blood_donation_app/core/error/result.dart';

import '../entities/donor_response.dart';

/// Storage for donors' "I can help" responses. Kept apart from
/// `BloodRequestRepository` so a screen that only needs one of the two
/// depends on only that one.
abstract interface class RequestResponseRepository {
  /// `Success(null)` = this donor has not responded (a normal state).
  Future<Result<DonorResponse?>> getMyResponse({
    required String requestId,
    required String donorUid,
  });

  Future<Result<void>> respond(DonorResponse response);

  /// Removing a response that does not exist succeeds.
  Future<Result<void>> withdraw({
    required String requestId,
    required String donorUid,
  });

  /// Responses to [requestId], oldest first, at most 50. Only the
  /// requester is allowed to read these.
  Future<Result<List<DonorResponse>>> getResponses(String requestId);
}
