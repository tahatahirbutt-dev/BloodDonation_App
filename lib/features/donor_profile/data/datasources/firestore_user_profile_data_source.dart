import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:blood_donation_app/core/firebase/firestore_guard.dart';

import 'donor_directory_projection.dart';
import 'firestore_value_converter.dart';
import 'user_profile_remote_data_source.dart';

/// Firestore-backed [UserProfileRemoteDataSource].
///
/// Takes [FirebaseFirestore] through the constructor instead of reading
/// `FirebaseFirestore.instance`, so tests can pass a fake and nothing in
/// the app reaches for a global.
///
/// Every call goes through [guardFirestoreCall]: SDK exceptions and
/// timeouts become a typed `DataSourceException`, never a raw
/// `FirebaseException` in a widget.
final class FirestoreUserProfileDataSource
    implements UserProfileRemoteDataSource {
  FirestoreUserProfileDataSource(
    this._firestore, {
    Duration timeout = defaultFirestoreTimeout,
  }) : _timeout = timeout;

  static const String usersCollection = 'users';
  static const String donorsCollection = 'donors';

  final FirebaseFirestore _firestore;
  final Duration _timeout;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(usersCollection).doc(uid);

  DocumentReference<Map<String, dynamic>> _donorDoc(String uid) =>
      _firestore.collection(donorsCollection).doc(uid);

  @override
  Future<Map<String, dynamic>?> fetch(String uid) {
    return guardFirestoreCall(() async {
      final snapshot = await _userDoc(uid).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return FirestoreValueConverter.decode(data);
    }, timeout: _timeout);
  }

  @override
  Future<void> upsert(String uid, Map<String, dynamic> data) {
    return guardFirestoreCall(() {
      // One atomic batch: the private profile and its public directory
      // entry can never disagree, even if the app dies mid-save.
      final batch = _firestore.batch()
        ..set(_userDoc(uid), FirestoreValueConverter.encode(data));

      final donor = DonorDirectoryProjection.fromProfileMap(data);
      if (donor == null) {
        // Hidden: make sure no stale public entry is left behind.
        batch.delete(_donorDoc(uid));
      } else {
        batch.set(_donorDoc(uid), FirestoreValueConverter.encode(donor));
      }
      return batch.commit();
    }, timeout: _timeout);
  }
}
