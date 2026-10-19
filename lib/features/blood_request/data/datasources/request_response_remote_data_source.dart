import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';

/// Raw access to the `responses` stored under each blood request. Same
/// contract as `BloodRequestRemoteDataSource`: maps in and out, every SDK
/// exception converted to a `DataSourceException`.
abstract interface class RequestResponseRemoteDataSource {
  /// `null` = this donor has not responded to this request.
  Future<Map<String, dynamic>?> fetch(String requestId, String donorUid);

  Future<void> create(
    String requestId,
    String donorUid,
    Map<String, dynamic> data,
  );

  /// Deleting something that does not exist is not an error.
  Future<void> delete(String requestId, String donorUid);

  /// Every response to [requestId], oldest first, at most [limit]. The
  /// document id is the donor's uid.
  Future<List<RawDocument>> fetchAll(
    String requestId, {
    int limit = maxQueryLimit,
  });
}
