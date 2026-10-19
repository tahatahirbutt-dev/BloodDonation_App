import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';

import '../../domain/entities/donor_response.dart';
import '../../domain/repositories/request_response_repository.dart';
import '../datasources/request_response_remote_data_source.dart';
import '../mappers/donor_response_mapper.dart';

/// The only place that turns data-layer exceptions into `Result`s for
/// donor responses.
final class RequestResponseRepositoryImpl implements RequestResponseRepository {
  RequestResponseRepositoryImpl(
    this._remote, {
    ErrorReporter reporter = const NoopErrorReporter(),
  }) : _reporter = reporter;

  final RequestResponseRemoteDataSource _remote;
  final ErrorReporter _reporter;

  @override
  Future<Result<DonorResponse?>> getMyResponse({
    required String requestId,
    required String donorUid,
  }) {
    return _guard<DonorResponse?>(() async {
      final document = await _remote.fetch(requestId, donorUid);
      if (document == null) return null;
      return switch (DonorResponseMapper.fromMap(
        requestId,
        donorUid,
        document,
      )) {
        Success<DonorResponse>(:final value) => value,
        Err<DonorResponse>(:final failure) => throw DataSourceException(
          failure,
        ),
      };
    });
  }

  @override
  Future<Result<void>> respond(DonorResponse response) {
    return _guard<void>(() async {
      await _remote.create(
        response.requestId,
        response.donorUid,
        DonorResponseMapper.toMap(response),
      );
    });
  }

  @override
  Future<Result<void>> withdraw({
    required String requestId,
    required String donorUid,
  }) {
    return _guard<void>(() => _remote.delete(requestId, donorUid));
  }

  @override
  Future<Result<List<DonorResponse>>> getResponses(String requestId) {
    return _guard<List<DonorResponse>>(() async {
      final documents = await _remote.fetchAll(requestId);
      return _readAll(requestId, documents);
    });
  }

  List<DonorResponse> _readAll(String requestId, List<RawDocument> documents) {
    final responses = <DonorResponse>[];
    for (final document in documents) {
      switch (DonorResponseMapper.fromMap(
        requestId,
        document.id,
        document.data,
      )) {
        case Success<DonorResponse>(:final value):
          responses.add(value);
        case Err<DonorResponse>():
          _reporter.report(
            StateError('Skipped unreadable response "${document.id}".'),
            StackTrace.current,
          );
      }
    }
    return responses;
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
