import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/firebase_failure_mapper.dart';

/// How long a single Firestore call may take before we give up on it.
///
/// Firestore's offline persistence makes *reads* fall back to cache, but a
/// *write* made offline stays pending and its Future does not complete
/// until the server acknowledges it. Without a timeout the UI would show a
/// spinner forever. On timeout the write is still queued by the SDK and
/// will sync when the connection returns; every write here is an
/// idempotent upsert keyed by uid, so that late sync is harmless.
const Duration defaultFirestoreTimeout = Duration(seconds: 10);

/// Runs one Firestore call and guarantees that only a
/// [DataSourceException] can escape for the failures we *expect*:
///
///  * `FirebaseException`  -> mapped by [failureForFirebaseCode]
///  * `TimeoutException`   -> [NetworkFailure]
///
/// Anything else (a genuine bug) is deliberately NOT swallowed here; it
/// propagates to the repository's catch-all, which reports it to
/// Crashlytics and returns an `UnexpectedFailure`.
Future<T> guardFirestoreCall<T>(
  Future<T> Function() action, {
  Duration timeout = defaultFirestoreTimeout,
}) async {
  try {
    return await action().timeout(timeout);
  } on DataSourceException {
    rethrow;
  } on FirebaseException catch (e) {
    throw DataSourceException(failureForFirebaseCode(e.code));
  } on TimeoutException {
    throw const DataSourceException(NetworkFailure());
  }
}
