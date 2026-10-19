import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../entities/blood_request.dart';
import '../entities/request_status.dart';

/// Storage for blood requests. Implementations must return typed
/// failures instead of throwing, and any two implementations must be
/// interchangeable.
abstract interface class BloodRequestRepository {
  Future<Result<void>> create(BloodRequest request);

  /// Requests that are open and not yet expired at [now], for patients
  /// whose blood group is in [bloodGroups]. Soonest-expiring first, at
  /// most `maxQueryLimit` (50) results. An empty [bloodGroups] returns an
  /// empty list. A document that cannot be read is skipped rather than
  /// failing the whole list.
  Future<Result<List<BloodRequest>>> getOpenRequests({
    required List<BloodGroup> bloodGroups,
    required DateTime now,
  });

  /// Everything [uid] has posted, newest first, at most 50.
  Future<Result<List<BloodRequest>>> getRequestsByRequester(String uid);

  Future<Result<void>> updateStatus({
    required String requestId,
    required RequestStatus status,
  });
}
