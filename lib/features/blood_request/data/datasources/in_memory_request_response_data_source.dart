import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';

import 'request_response_remote_data_source.dart';

/// RAM-backed [RequestResponseRemoteDataSource] for tests and offline
/// development. Set [failWith] to make every call fail.
final class InMemoryRequestResponseDataSource
    implements RequestResponseRemoteDataSource {
  // requestId -> donorUid -> document
  final Map<String, Map<String, Map<String, dynamic>>> _documents = {};

  Failure? failWith;

  @override
  Future<Map<String, dynamic>?> fetch(String requestId, String donorUid) async {
    _throwIfFailing();
    final document = _documents[requestId]?[donorUid];
    return document == null ? null : Map<String, dynamic>.of(document);
  }

  @override
  Future<void> create(
    String requestId,
    String donorUid,
    Map<String, dynamic> data,
  ) async {
    _throwIfFailing();
    _documents.putIfAbsent(requestId, () => {})[donorUid] =
        Map<String, dynamic>.of(data);
  }

  @override
  Future<void> delete(String requestId, String donorUid) async {
    _throwIfFailing();
    _documents[requestId]?.remove(donorUid);
  }

  @override
  Future<List<RawDocument>> fetchAll(
    String requestId, {
    int limit = maxQueryLimit,
  }) async {
    _throwIfFailing();
    final entries =
        (_documents[requestId]?.entries.toList() ??
              <MapEntry<String, Map<String, dynamic>>>[])
          ..sort(
            (a, b) => _time(
              a.value['respondedAt'],
            ).compareTo(_time(b.value['respondedAt'])),
          );
    return entries
        .take(limit)
        .map(
          (entry) =>
              RawDocument(entry.key, Map<String, dynamic>.of(entry.value)),
        )
        .toList(growable: false);
  }

  static DateTime _time(Object? value) =>
      value is DateTime ? value : DateTime.fromMillisecondsSinceEpoch(0);

  void _throwIfFailing() {
    final failure = failWith;
    if (failure != null) throw DataSourceException(failure);
  }
}
