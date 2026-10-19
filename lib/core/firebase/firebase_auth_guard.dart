import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/firebase_auth_failure_mapper.dart';
import 'package:blood_donation_app/core/error/firebase_failure_mapper.dart';

/// Auth calls go over the network and can be slower than Firestore reads,
/// so the budget is a little larger.
const Duration defaultAuthTimeout = Duration(seconds: 15);

/// Auth counterpart of `guardFirestoreCall`: expected failures become a
/// typed `DataSourceException`; genuine bugs propagate to the
/// repository's catch-all and from there to Crashlytics.
Future<T> guardAuthCall<T>(
  Future<T> Function() action, {
  Duration timeout = defaultAuthTimeout,
}) async {
  try {
    return await action().timeout(timeout);
  } on DataSourceException {
    rethrow;
    // FirebaseAuthException extends FirebaseException, so it must be
    // caught first.
  } on FirebaseAuthException catch (e) {
    throw DataSourceException(failureForAuthCode(e.code));
  } on FirebaseException catch (e) {
    throw DataSourceException(failureForFirebaseCode(e.code));
  } on TimeoutException {
    throw const DataSourceException(NetworkFailure());
  }
}
