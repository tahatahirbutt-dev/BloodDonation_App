import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/distance_calculator.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../entities/blood_request.dart';
import '../entities/request_feed_item.dart';
import '../repositories/blood_request_repository.dart';

/// The donor's feed: open requests this donor's blood could go to,
/// excluding their own, within [defaultRadiusKm], most urgent first and
/// then nearest first.
class GetNearbyRequests {
  GetNearbyRequests(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Covers the whole Islamabad + Rawalpindi area in v1, so a donor in one
  /// city still sees an emergency in the other. Lower it as the app grows.
  static const double defaultRadiusKm = 50;

  final BloodRequestRepository _repository;
  final DateTime Function() _clock;

  Future<Result<List<RequestFeedItem>>> call({
    required UserProfile donor,
    double radiusKm = defaultRadiusKm,
  }) async {
    final now = _clock();

    final result = await _repository.getOpenRequests(
      bloodGroups: donor.bloodGroup.compatibleRecipientGroups,
      now: now,
    );

    switch (result) {
      case Err<List<BloodRequest>>(:final failure):
        return Err<List<RequestFeedItem>>(failure);
      case Success<List<BloodRequest>>(:final value):
        final items =
            <RequestFeedItem>[
              for (final request in value)
                if (request.requesterUid != donor.uid && request.isOpenAt(now))
                  RequestFeedItem(
                    request: request,
                    distanceKm: DistanceCalculator.haversineKm(
                      donor.location.point,
                      request.hospital.point,
                    ),
                  ),
            ].where((item) => item.distanceKm <= radiusKm).toList()..sort(
              _byUrgencyThenDistance,
            );
        return Success<List<RequestFeedItem>>(items);
    }
  }

  static int _byUrgencyThenDistance(RequestFeedItem a, RequestFeedItem b) {
    final byUrgency = a.request.urgency.index.compareTo(
      b.request.urgency.index,
    );
    if (byUrgency != 0) return byUrgency;
    final byDistance = a.distanceKm.compareTo(b.distanceKm);
    if (byDistance != 0) return byDistance;
    return b.request.createdAt.compareTo(a.request.createdAt);
  }
}
