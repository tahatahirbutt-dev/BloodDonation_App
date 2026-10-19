import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';

/// Raw, read-only access to the public donor directory. Maps and ids in
/// and out; every SDK exception must become a `DataSourceException`.
abstract interface class DonorDirectoryRemoteDataSource {
  /// Available donors (`isAvailable == true`) whose `bloodGroup` is in
  /// [bloodGroups] and whose `geohash` starts with [prefix], at most
  /// [limit]. The document id is the donor's uid. Returns an empty list
  /// for an empty [bloodGroups].
  Future<List<RawDocument>> fetchByGeohashPrefix({
    required List<String> bloodGroups,
    required String prefix,
    int limit = maxQueryLimit,
  });
}
