import 'dart:async';

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/firebase_auth_failure_mapper.dart';

import '../../domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

/// A drop-in [AuthRemoteDataSource] that keeps accounts in RAM, for tests
/// and for running the app before Firebase is configured. Never use it as
/// a production data source.
///
/// Set [failWith] to make every call fail, to exercise error UI.
final class InMemoryAuthDataSource implements AuthRemoteDataSource {
  final Map<String, _Account> _accounts = {};
  final StreamController<AuthUser?> _changes =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _current;
  int _nextId = 1;

  Failure? failWith;

  /// How many verification emails "went out".
  int verificationEmailsSent = 0;

  /// Simulates the user tapping the link in the verification email.
  void markCurrentUserVerified() {
    final current = _current;
    if (current == null) return;
    _accounts[current.email]?.verified = true;
  }

  @override
  Stream<AuthUser?> userChanges() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    _throwIfFailing();
    if (_accounts.containsKey(email)) {
      throw DataSourceException(failureForAuthCode('email-already-in-use'));
    }
    final account = _Account(uid: 'uid-${_nextId++}', password: password);
    _accounts[email] = account;
    return _signInAs(email, account);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    _throwIfFailing();
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw DataSourceException(failureForAuthCode('invalid-credential'));
    }
    return _signInAs(email, account);
  }

  @override
  Future<void> sendVerificationEmail() async {
    _throwIfFailing();
    if (_current == null) {
      throw DataSourceException(failureForAuthCode('no-current-user'));
    }
    verificationEmailsSent++;
  }

  @override
  Future<AuthUser> reload() async {
    _throwIfFailing();
    final current = _current;
    final account = current == null ? null : _accounts[current.email];
    if (current == null || account == null) {
      throw DataSourceException(failureForAuthCode('no-current-user'));
    }
    return _signInAs(current.email, account);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    _throwIfFailing();
    // Same outcome whether or not the account exists.
  }

  @override
  Future<void> signOut() async {
    _throwIfFailing();
    _current = null;
    _changes.add(null);
  }

  AuthUser _signInAs(String email, _Account account) {
    final user = AuthUser(
      uid: account.uid,
      email: email,
      isEmailVerified: account.verified,
    );
    _current = user;
    _changes.add(user);
    return user;
  }

  void _throwIfFailing() {
    final failure = failWith;
    if (failure != null) throw DataSourceException(failure);
  }
}

class _Account {
  _Account({required this.uid, required this.password});

  final String uid;
  final String password;
  bool verified = false;
}
