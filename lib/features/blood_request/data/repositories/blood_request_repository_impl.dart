import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../domain/entities/blood_request.dart';
import '../../domain/entities/request_status.dart';
import '../../domain/repositories/blood_request_repository.dart';
import '../datasources/blood_request_remote_data_source.dart';
import '../mappers/blood_request_mapper.dart';

/// The only place that turns data-layer exceptions into `Result`s for
/// blood requests. A document that cannot be read is skipped (and
/// reported) instead of failing the whole list, so one bad record can
/// never blank a donor's feed.
final class BloodRequestRepositoryImpl implements BloodRequestRepository {
  BloodRequestRepositoryImpl(
    this._remote, {
    ErrorReporter reporter = const NoopErrorReporter(),
  }) : _reporter = reporter;

  final BloodRequestRemoteDataSource _remote;
  final ErrorReporter _reporter;

  @override
  Future<Result<void>> create(BloodRequest request) {
    return _guard<void>(() async {
      await _remote.create(request.id, BloodRequestMapper.toMap(request));
    });
  }

  @override
  Future<Result<List<BloodRequest>>> getOpenRequests({
    required List<BloodGroup> bloodGroups,
    required DateTime now,
  }) {
    return _guard<List<BloodRequest>>(() async {
      final documents = await _remote.fetchOpen(
        bloodGroups: [for (final group in bloodGroups) group.name],
        now: now,
      );
      return _readAll(documents);
    });
  }

  @override
  Future<Result<List<BloodRequest>>> getRequestsByRequester(String uid) {
    return _guard<List<BloodRequest>>(() async {
      final documents = await _remote.fetchByRequester(uid);
      return _readAll(documents);
    });
  }

  @override
  Future<Result<void>> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) {
    return _guard<void>(() => _remote.updateStatus(requestId, status.name));
  }

  List<BloodRequest> _readAll(List<RawDocument> documents) {
    final requests = <BloodRequest>[];
    for (final document in documents) {
      switch (BloodRequestMapper.fromMap(document.id, document.data)) {
        case Success<BloodRequest>(:final value):
          requests.add(value);
        case Err<BloodRequest>():
          _reporter.report(
            StateError('Skipped unreadable blood request "${document.id}".'),
            StackTrace.current,
          );
      }
    }
    return requests;
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on DataSourceException catch (e) {
      return Err<T>(e.failure);
    } catch (error, stackTrace) {
      _reporter.report(error, stackTrace);
      return Err<T>(const UnexpectedFailure());
    }
  }
}
