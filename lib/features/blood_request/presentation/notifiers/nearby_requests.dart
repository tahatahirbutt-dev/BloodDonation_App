import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../blood_request_providers.dart';
import '../../domain/entities/request_feed_item.dart';

part 'nearby_requests.g.dart';

/// The donor's feed. A failure becomes an `AsyncError` carrying the typed
/// `Failure`, so the screen can show a real message and a retry button.
/// Keyed by the profile, so changing availability or blood group
/// naturally produces a fresh feed.
@riverpod
Future<List<RequestFeedItem>> nearbyRequests(Ref ref, UserProfile donor) async {
  final result = await ref.watch(getNearbyRequestsProvider).call(donor: donor);
  return switch (result) {
    Success<List<RequestFeedItem>>(:final value) => value,
    Err<List<RequestFeedItem>>(:final failure) => throw failure,
  };
}
