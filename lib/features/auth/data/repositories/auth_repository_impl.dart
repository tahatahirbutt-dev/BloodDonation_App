import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/email_address.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// The only place that turns auth data-source exceptions into `Result`s.
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remote, {
    void Function(Object error, StackTrace stackTrace)? reportUnexpectedError,
  }) : _reportUnexpectedError =
           reportUnexpectedError ?? ((error, stackTrace) {});

  final AuthRemoteDataSource _remote;
  final void Function(Object error, StackTrace stackTrace)
  _reportUnexpectedError;

  @override
  Stream<AuthUser?> userChanges() => _remote.userChanges();

  @override
  Future<Result<AuthUser>> signUp({
    required EmailAddress email,
    required String password,
  }) {
    return _run(() => _remote.signUp(email: email.value, password: password));
  }

  @override
  Future<Result<AuthUser>> signIn({
    required EmailAddress email,
    required String password,
  }) {
    return _run(() => _remote.signIn(email: email.value, password: password));
  }

  @override
  Future<Result<void>> sendVerificationEmail() {
    return _run<void>(_remote.sendVerificationEmail);
  }

  @override
  Future<Result<AuthUser>> refreshUser() => _run(_remote.reload);

  @override
  Future<Result<void>> sendPasswordReset(EmailAddress email) {
    return _run<void>(() => _remote.sendPasswordReset(email.value));
  }

  @override
  Future<Result<void>> signOut() => _run<void>(_remote.signOut);

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on DataSourceException catch (e) {
      return Err<T>(e.failure);
    } catch (error, stackTrace) {
      _reportUnexpectedError(error, stackTrace);
      return Err<T>(const UnexpectedFailure());
    }
  }
}
