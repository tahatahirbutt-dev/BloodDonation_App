import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/firebase/firestore_guard.dart';
import 'package:blood_donation_app/core/firebase/firestore_value_converter.dart';

import 'blood_request_remote_data_source.dart';

/// Firestore-backed [BloodRequestRemoteDataSource]. Same conventions as
/// the profile data source: the SDK arrives through the constructor, and
/// every call goes through [guardFirestoreCall].
///
/// The two queries below need composite indexes, declared in
/// `firestore.indexes.json` (deploy with `firebase deploy --only
/// firestore`). Until an index finishes building, the query fails with
/// `failed-precondition`, which the failure mapper turns into a "still
/// being set up" message.
final class FirestoreBloodRequestDataSource
    implements BloodRequestRemoteDataSource {
  FirestoreBloodRequestDataSource(
    this._firestore, {
    Duration timeout = defaultFirestoreTimeout,
  }) : _timeout = timeout;

  static const String collectionName = 'bloodRequests';

  final FirebaseFirestore _firestore;
  final Duration _timeout;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(collectionName);

  @override
  Future<void> create(String id, Map<String, dynamic> data) {
    return guardFirestoreCall(
      () => _requests.doc(id).set(FirestoreValueConverter.encode(data)),
      timeout: _timeout,
    );
  }

  @override
  Future<List<RawDocument>> fetchOpen({
    required List<String> bloodGroups,
    required DateTime now,
    int limit = maxQueryLimit,
  }) {
    // Firestore rejects `whereIn` with an empty list.
    if (bloodGroups.isEmpty) return Future.value(const <RawDocument>[]);

    return guardFirestoreCall(() async {
      final snapshot = await _requests
          .where('status', isEqualTo: 'open')
          .where('bloodGroup', whereIn: bloodGroups)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .limit(limit)
          .get();
      return _toDocuments(snapshot);
    }, timeout: _timeout);
  }

  @override
  Future<List<RawDocument>> fetchByRequester(
    String uid, {
    int limit = maxQueryLimit,
  }) {
    return guardFirestoreCall(() async {
      final snapshot = await _requests
          .where('requesterUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return _toDocuments(snapshot);
    }, timeout: _timeout);
  }

  @override
  Future<void> updateStatus(String id, String status) {
    return guardFirestoreCall(
      () => _requests.doc(id).update({'status': status}),
      timeout: _timeout,
    );
  }

  static List<RawDocument> _toDocuments(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(
          (doc) =>
              RawDocument(doc.id, FirestoreValueConverter.decode(doc.data())),
        )
        .toList(growable: false);
  }
}
