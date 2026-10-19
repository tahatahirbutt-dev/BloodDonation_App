import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/mappers/user_profile_mapper.dart';
import 'package:blood_donation_app/features/donor_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';

import '../../../../test/support/profile_fixtures.dart';

final class _FakeRemote implements UserProfileRemoteDataSource {
  Map<String, dynamic>? document;
  Object? fetchError;
  Object? upsertError;
  Map<String, dynamic>? saved;

  @override
  Future<Map<String, dynamic>?> fetch(String uid) async {
    final error = fetchError;
    if (error != null) throw error;
    return document;
  }

  @override
  Future<void> upsert(String uid, Map<String, dynamic> data) async {
    final error = upsertError;
    if (error != null) throw error;
    saved = data;
  }
}

void main() {
  test('returns null when the remote document does not exist', () async {
    final result = await UserProfileRepositoryImpl(
      _FakeRemote(),
    ).getProfile('uid-1');
    expect(result, const Success<UserProfile?>(null));
  });

  test('maps a remote document to a profile', () async {
    final remote = _FakeRemote()
      ..document = UserProfileMapper.toMap(sampleProfile());
    final result = await UserProfileRepositoryImpl(remote).getProfile('uid-1');
    expect(result, isA<Success<UserProfile?>>());
  });

  test('converts data-source failures to Err', () async {
    final remote = _FakeRemote()
      ..fetchError = const DataSourceException(NetworkFailure());
    final result = await UserProfileRepositoryImpl(remote).getProfile('uid-1');
    expect(
      result,
      isA<Err<UserProfile?>>().having(
        (error) => error.failure,
        'failure',
        isA<NetworkFailure>(),
      ),
    );
  });

  test('reports unexpected failures and returns UnexpectedFailure', () async {
    final remote = _FakeRemote()..fetchError = StateError('boom');
    Object? reported;
    final result = await UserProfileRepositoryImpl(
      remote,
      reportUnexpectedError: (error, stackTrace) => reported = error,
    ).getProfile('uid-1');
    expect(reported, isA<StateError>());
    expect(
      result,
      isA<Err<UserProfile?>>().having(
        (e) => e.failure,
        'failure',
        isA<UnexpectedFailure>(),
      ),
    );
  });

  test('maps and saves a profile', () async {
    final remote = _FakeRemote();
    final result = await UserProfileRepositoryImpl(
      remote,
    ).saveProfile(sampleProfile());
    expect(result, const Success<void>(null));
    expect(remote.saved, UserProfileMapper.toMap(sampleProfile()));
  });
}
