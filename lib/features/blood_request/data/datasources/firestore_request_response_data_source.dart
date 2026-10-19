import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/firebase/firestore_guard.dart';
import 'package:blood_donation_app/core/firebase/firestore_value_converter.dart';

import 'firestore_blood_request_data_source.dart';
import 'request_response_remote_data_source.dart';

/// Firestore-backed [RequestResponseRemoteDataSource]. Responses live
/// under their request: `bloodRequests/{requestId}/responses/{donorUid}`,
/// which lets the security rules tie "who may read this" to the parent
/// request's requester.
final class FirestoreRequestResponseDataSource
    implements RequestResponseRemoteDataSource {
  FirestoreRequestResponseDataSource(
    this._firestore, {
    Duration timeout = defaultFirestoreTimeout,
  }) : _timeout = timeout;

  static const String subcollectionName = 'responses';

  final FirebaseFirestore _firestore;
  final Duration _timeout;

  CollectionReference<Map<String, dynamic>> _responses(String requestId) =>
      _firestore
          .collection(FirestoreBloodRequestDataSource.collectionName)
          .doc(requestId)
          .collection(subcollectionName);

  @override
  Future<Map<String, dynamic>?> fetch(String requestId, String donorUid) {
    return guardFirestoreCall(() async {
      final snapshot = await _responses(requestId).doc(donorUid).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return FirestoreValueConverter.decode(data);
    }, timeout: _timeout);
  }

  @override
  Future<void> create(
    String requestId,
    String donorUid,
    Map<String, dynamic> data,
  ) {
    return guardFirestoreCall(
      () => _responses(
        requestId,
      ).doc(donorUid).set(FirestoreValueConverter.encode(data)),
      timeout: _timeout,
    );
  }

  @override
  Future<void> delete(String requestId, String donorUid) {
    return guardFirestoreCall(
      () => _responses(requestId).doc(donorUid).delete(),
      timeout: _timeout,
    );
  }

  @override
  Future<List<RawDocument>> fetchAll(
    String requestId, {
    int limit = maxQueryLimit,
  }) {
    return guardFirestoreCall(() async {
      final snapshot = await _responses(
        requestId,
      ).orderBy('respondedAt').limit(limit).get();
      return snapshot.docs
          .map(
            (doc) =>
                RawDocument(doc.id, FirestoreValueConverter.decode(doc.data())),
          )
          .toList(growable: false);
    }, timeout: _timeout);
  }
}
