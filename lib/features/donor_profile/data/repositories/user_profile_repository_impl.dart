import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';
import 'package:blood_donation_app/features/donor_profile/domain/repositories/user_profile_repository.dart';

import '../datasources/user_profile_remote_data_source.dart';
import '../mappers/user_profile_mapper.dart';

/// Called for errors nobody anticipated (anything that is not a
/// `DataSourceException`). Wire this to Crashlytics/Sentry at app start.
typedef UnexpectedErrorReporter =
    void Function(Object error, StackTrace stackTrace);

/// The only place that turns data-layer exceptions into `Result`s.
final class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(
    this._remote, {
    UnexpectedErrorReporter? reportUnexpectedError,
  }) : _reportUnexpectedError =
           reportUnexpectedError ?? ((error, stackTrace) {});

  final UserProfileRemoteDataSource _remote;
  final UnexpectedErrorReporter _reportUnexpectedError;

  @override
  Future<Result<UserProfile?>> getProfile(String uid) async {
    try {
      final document = await _remote.fetch(uid);
      if (document == null) return const Success<UserProfile?>(null);

      return switch (UserProfileMapper.fromMap(uid, document)) {
        Success<UserProfile>(:final value) => Success<UserProfile?>(value),
        Err<UserProfile>(:final failure) => Err<UserProfile?>(failure),
      };
    } on DataSourceException catch (e) {
      return Err<UserProfile?>(e.failure);
    } catch (error, stackTrace) {
      _reportUnexpectedError(error, stackTrace);
      return const Err<UserProfile?>(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> saveProfile(UserProfile profile) async {
    try {
      await _remote.upsert(profile.uid, UserProfileMapper.toMap(profile));
      return const Success<void>(null);
    } on DataSourceException catch (e) {
      return Err<void>(e.failure);
    } catch (error, stackTrace) {
      _reportUnexpectedError(error, stackTrace);
      return const Err<void>(UnexpectedFailure());
    }
  }
}
