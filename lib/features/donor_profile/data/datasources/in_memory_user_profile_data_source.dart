import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';

import 'user_profile_remote_data_source.dart';

/// A drop-in [UserProfileRemoteDataSource] that keeps documents in RAM.
///
/// For tests and for running the app before Firebase is configured —
/// never as a production data source (everything is lost on restart).
/// Set [failWith] to make every call fail, to exercise error UI.
final class InMemoryUserProfileDataSource
    implements UserProfileRemoteDataSource {
  final Map<String, Map<String, dynamic>> _documents = {};

  Failure? failWith;

  @override
  Future<Map<String, dynamic>?> fetch(String uid) async {
    _throwIfFailing();
    final document = _documents[uid];
    // Copy out, so callers can't mutate the "database" by accident.
    return document == null ? null : Map<String, dynamic>.of(document);
  }

  @override
  Future<void> upsert(String uid, Map<String, dynamic> data) async {
    _throwIfFailing();
    _documents[uid] = Map<String, dynamic>.of(data);
  }

  void _throwIfFailing() {
    final failure = failWith;
    if (failure != null) throw DataSourceException(failure);
  }
}
