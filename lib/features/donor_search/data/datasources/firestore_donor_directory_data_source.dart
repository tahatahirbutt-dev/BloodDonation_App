import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/firebase/firestore_guard.dart';
import 'package:blood_donation_app/core/firebase/firestore_value_converter.dart';

import 'donor_directory_remote_data_source.dart';

/// Firestore-backed [DonorDirectoryRemoteDataSource]. Reads the `donors`
/// collection that the profile feature writes.
///
/// A geohash "starts with" query is a range query: `>= prefix` and
/// `< prefix + '~'` ('~' sorts after every geohash character). It needs
/// the composite index declared in `firestore.indexes.json`.
final class FirestoreDonorDirectoryDataSource
    implements DonorDirectoryRemoteDataSource {
  FirestoreDonorDirectoryDataSource(
    this._firestore, {
    Duration timeout = defaultFirestoreTimeout,
  }) : _timeout = timeout;

  /// Must equal `FirestoreUserProfileDataSource.donorsCollection`; a test
  /// asserts it, so the two features cannot drift apart.
  static const String collectionName = 'donors';

  final FirebaseFirestore _firestore;
  final Duration _timeout;

  @override
  Future<List<RawDocument>> fetchByGeohashPrefix({
    required List<String> bloodGroups,
    required String prefix,
    int limit = maxQueryLimit,
  }) {
    // Firestore rejects `whereIn` with an empty list.
    if (bloodGroups.isEmpty) return Future.value(const <RawDocument>[]);

    return guardFirestoreCall(() async {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('isAvailable', isEqualTo: true)
          .where('bloodGroup', whereIn: bloodGroups)
          .where('geohash', isGreaterThanOrEqualTo: prefix)
          .where('geohash', isLessThan: '$prefix~')
          .limit(limit)
          .get();
      return snapshot.docs
          .map(
            (doc) =>
                RawDocument(doc.id, FirestoreValueConverter.decode(doc.data())),
          )
          .toList(growable: false);
    }, timeout: _timeout);
  }
}
