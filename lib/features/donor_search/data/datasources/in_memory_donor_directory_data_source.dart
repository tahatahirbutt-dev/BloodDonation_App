import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';

import 'donor_directory_remote_data_source.dart';

/// RAM-backed [DonorDirectoryRemoteDataSource] for tests and offline
/// development, applying the same filters and ordering as the Firestore
/// query. Fill it with [seed]. Set [failWith] to make every call fail.
final class InMemoryDonorDirectoryDataSource
    implements DonorDirectoryRemoteDataSource {
  final Map<String, Map<String, dynamic>> _documents = {};

  Failure? failWith;

  /// Adds or replaces the directory entry for [uid].
  void seed(String uid, Map<String, dynamic> data) {
    _documents[uid] = Map<String, dynamic>.of(data);
  }

  @override
  Future<List<RawDocument>> fetchByGeohashPrefix({
    required List<String> bloodGroups,
    required String prefix,
    int limit = maxQueryLimit,
  }) async {
    final failure = failWith;
    if (failure != null) throw DataSourceException(failure);

    final matches =
        _documents.entries.where((entry) {
          final data = entry.value;
          final geohash = data['geohash'];
          return data['isAvailable'] == true &&
              bloodGroups.contains(data['bloodGroup']) &&
              geohash is String &&
              geohash.startsWith(prefix);
        }).toList()..sort(
          (a, b) => '${a.value['geohash']}'.compareTo('${b.value['geohash']}'),
        );

    return matches
        .take(limit)
        .map(
          (entry) =>
              RawDocument(entry.key, Map<String, dynamic>.of(entry.value)),
        )
        .toList(growable: false);
  }
}
