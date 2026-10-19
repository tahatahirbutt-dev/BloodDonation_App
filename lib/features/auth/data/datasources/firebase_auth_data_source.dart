import 'package:firebase_auth/firebase_auth.dart';

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/firebase/firebase_auth_guard.dart';

import '../../domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

/// Firebase Authentication (email/password, free on the Spark plan).
/// [FirebaseAuth] is injected, never read from `.instance` here.
final class FirebaseAuthDataSource implements AuthRemoteDataSource {
  FirebaseAuthDataSource(this._auth, {Duration timeout = defaultAuthTimeout})
    : _timeout = timeout;

  final FirebaseAuth _auth;
  final Duration _timeout;

  static const DataSourceException _signedOut = DataSourceException(
    PermissionFailure('Please sign in again.'),
  );

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      isEmailVerified: user.emailVerified,
    );
  }

  AuthUser _requireUser(User? user) {
    final mapped = _toAuthUser(user);
    // The SDK reports success but gives no user: treat as a server fault
    // instead of asserting non-null.
    if (mapped == null) throw const DataSourceException(ServerFailure());
    return mapped;
  }

  @override
  Stream<AuthUser?> userChanges() => _auth.userChanges().map(_toAuthUser);

  @override
  Future<AuthUser> signUp({required String email, required String password}) {
    return guardAuthCall(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    }, timeout: _timeout);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    return guardAuthCall(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    }, timeout: _timeout);
  }

  @override
  Future<void> sendVerificationEmail() {
    return guardAuthCall(() async {
      final user = _auth.currentUser;
      if (user == null) throw _signedOut;
      await user.sendEmailVerification();
    }, timeout: _timeout);
  }

  @override
  Future<AuthUser> reload() {
    return guardAuthCall(() async {
      final user = _auth.currentUser;
      if (user == null) throw _signedOut;
      await user.reload();
      // Force a new ID token so the `email_verified` claim that Firestore
      // security rules read is up to date straight away.
      await user.getIdToken(true);
      return _requireUser(_auth.currentUser);
    }, timeout: _timeout);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return guardAuthCall(() async {
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (e) {
        // Do not reveal whether an account exists for this address.
        if (e.code != 'user-not-found') rethrow;
      }
    }, timeout: _timeout);
  }

  @override
  Future<void> signOut() {
    return guardAuthCall(_auth.signOut, timeout: _timeout);
  }
}
