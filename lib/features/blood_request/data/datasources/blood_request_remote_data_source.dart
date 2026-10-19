import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';

/// Raw access to stored blood requests: maps and ids in and out, no
/// entities, no failures' meaning. Implementations (Firestore, in-memory)
/// must turn every SDK exception into a `DataSourceException`, and must
/// behave identically for the same data (they are interchangeable).
///
/// Values in the maps are plain Dart (`DateTime`, not `Timestamp`).
abstract interface class BloodRequestRemoteDataSource {
  Future<void> create(String id, Map<String, dynamic> data);

  /// Requests with `status == open`, `bloodGroup` in [bloodGroups] and
  /// `expiresAt` after [now], soonest-expiring first, at most [limit].
  /// Returns an empty list for an empty [bloodGroups].
  Future<List<RawDocument>> fetchOpen({
    required List<String> bloodGroups,
    required DateTime now,
    int limit = maxQueryLimit,
  });

  /// Requests posted by [uid], newest first, at most [limit].
  Future<List<RawDocument>> fetchByRequester(
    String uid, {
    int limit = maxQueryLimit,
  });

  /// Changes only the `status` field. Fails with a not-found failure if
  /// the request does not exist.
  Future<void> updateStatus(String id, String status);
}
