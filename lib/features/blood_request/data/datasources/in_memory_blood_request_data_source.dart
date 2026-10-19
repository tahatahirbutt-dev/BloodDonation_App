import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';

import 'blood_request_remote_data_source.dart';

/// RAM-backed [BloodRequestRemoteDataSource] for tests and for running
/// the app before Firebase is configured. It applies the same filtering,
/// ordering and limit as the Firestore queries, so a test that passes
/// here is exercising the same behaviour. Set [failWith] to make every
/// call fail.
final class InMemoryBloodRequestDataSource
    implements BloodRequestRemoteDataSource {
  final Map<String, Map<String, dynamic>> _documents = {};

  Failure? failWith;

  /// A copy of the stored document for [id], or null. For test assertions;
  /// it ignores [failWith] on purpose so a test can inspect state after
  /// simulating an outage.
  Map<String, dynamic>? documentById(String id) {
    final document = _documents[id];
    return document == null ? null : Map<String, dynamic>.of(document);
  }

  @override
  Future<void> create(String id, Map<String, dynamic> data) async {
    _throwIfFailing();
    _documents[id] = Map<String, dynamic>.of(data);
  }

  @override
  Future<List<RawDocument>> fetchOpen({
    required List<String> bloodGroups,
    required DateTime now,
    int limit = maxQueryLimit,
  }) async {
    _throwIfFailing();
    final matches =
        _documents.entries.where((entry) {
          final data = entry.value;
          final expiresAt = data['expiresAt'];
          return data['status'] == 'open' &&
              bloodGroups.contains(data['bloodGroup']) &&
              expiresAt is DateTime &&
              expiresAt.isAfter(now);
        }).toList()..sort(
          (a, b) => _time(
            a.value['expiresAt'],
          ).compareTo(_time(b.value['expiresAt'])),
        );
    return _toDocuments(matches, limit);
  }

  @override
  Future<List<RawDocument>> fetchByRequester(
    String uid, {
    int limit = maxQueryLimit,
  }) async {
    _throwIfFailing();
    final matches =
        _documents.entries
            .where((entry) => entry.value['requesterUid'] == uid)
            .toList()
          ..sort(
            (a, b) => _time(
              b.value['createdAt'],
            ).compareTo(_time(a.value['createdAt'])),
          );
    return _toDocuments(matches, limit);
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    _throwIfFailing();
    final document = _documents[id];
    if (document == null) throw const DataSourceException(NotFoundFailure());
    document['status'] = status;
  }

  /// Sorting must not crash on a malformed document (tests seed some on
  /// purpose); treat a missing or wrong-typed date as the oldest possible.
  static DateTime _time(Object? value) =>
      value is DateTime ? value : DateTime.fromMillisecondsSinceEpoch(0);

  static List<RawDocument> _toDocuments(
    List<MapEntry<String, Map<String, dynamic>>> entries,
    int limit,
  ) {
    return entries
        .take(limit)
        .map(
          (entry) =>
              RawDocument(entry.key, Map<String, dynamic>.of(entry.value)),
        )
        .toList(growable: false);
  }

  void _throwIfFailing() {
    final failure = failWith;
    if (failure != null) throw DataSourceException(failure);
  }
}
