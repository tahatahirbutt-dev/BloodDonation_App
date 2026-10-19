import 'package:equatable/equatable.dart';

import 'blood_request.dart';

/// One row of a donor's feed: a request plus how far it is from them.
final class RequestFeedItem extends Equatable {
  const RequestFeedItem({required this.request, required this.distanceKm});

  final BloodRequest request;

  /// Straight-line distance. Roads are typically ~25% longer, so the UI
  /// labels it "about" and "in a straight line".
  final double distanceKm;

  @override
  List<Object?> get props => [request, distanceKm];
}
