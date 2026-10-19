import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/blood_request_remote_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/request_response_remote_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/mappers/blood_request_mapper.dart';
import 'package:blood_donation_app/features/blood_request/data/repositories/blood_request_repository_impl.dart';
import 'package:blood_donation_app/features/blood_request/data/repositories/request_response_repository_impl.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/blood_request.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/donor_response.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../../support/request_fixtures.dart';

class _RecordingReporter implements ErrorReporter {
  final List<Object> errors = [];

  @override
  void report(Object error, StackTrace stackTrace, {bool fatal = false}) {
    errors.add(error);
  }
}

/// Throws a raw, non-DataSourceException error: the "nobody anticipated
/// this" case the repositories must still contain.
class _ExplodingRequestSource implements BloodRequestRemoteDataSource {
  @override
  Future<void> create(String id, Map<String, dynamic> data) =>
      throw StateError('boom');

  @override
  Future<List<RawDocument>> fetchOpen({
    required List<String> bloodGroups,
    required DateTime now,
    int limit = 50,
  }) => throw StateError('boom');

  @override
  Future<List<RawDocument>> fetchByRequester(String uid, {int limit = 50}) =>
      throw StateError('boom');

  @override
  Future<void> updateStatus(String id, String status) =>
      throw StateError('boom');
}

class _ExplodingResponseSource implements RequestResponseRemoteDataSource {
  @override
  Future<Map<String, dynamic>?> fetch(String requestId, String donorUid) =>
      throw StateError('boom');

  @override
  Future<void> create(
    String requestId,
    String donorUid,
    Map<String, dynamic> data,
  ) => throw StateError('boom');

  @override
  Future<void> delete(String requestId, String donorUid) =>
      throw StateError('boom');

  @override
  Future<List<RawDocument>> fetchAll(String requestId, {int limit = 50}) =>
      throw StateError('boom');
}

void main() {
  group('BloodRequestRepositoryImpl', () {
    late InMemoryBloodRequestDataSource source;
    late _RecordingReporter reporter;
    late BloodRequestRepositoryImpl repository;

    setUp(() {
      source = InMemoryBloodRequestDataSource();
      reporter = _RecordingReporter();
      repository = BloodRequestRepositoryImpl(source, reporter: reporter);
    });

    test(
      'create then getRequestsByRequester round-trips the request',
      () async {
        final request = sampleRequest();

        expect(await repository.create(request), isA<Success<void>>());
        final result = await repository.getRequestsByRequester('other-uid');

        expect((result as Success<List<BloodRequest>>).value, [request]);
      },
    );

    test(
      'getOpenRequests passes the blood group names and time to the source',
      () async {
        await seedRequest(
          source,
          sampleRequest(id: 'b', bloodGroup: BloodGroup.bPositive),
        );
        await seedRequest(
          source,
          sampleRequest(id: 'o', bloodGroup: BloodGroup.oNegative),
        );

        final result = await repository.getOpenRequests(
          bloodGroups: [BloodGroup.bPositive, BloodGroup.abPositive],
          now: testNow,
        );

        expect((result as Success<List<BloodRequest>>).value.map((r) => r.id), [
          'b',
        ]);
      },
    );

    test('updateStatus stores the status name', () async {
      await seedRequest(source, sampleRequest());

      await repository.updateStatus(
        requestId: 'req-1',
        status: RequestStatus.fulfilled,
      );

      final stored = (await source.fetchByRequester('other-uid')).single;
      expect(stored.data['status'], 'fulfilled');
    });

    test(
      'a corrupt document is skipped and reported, the rest still load',
      () async {
        await seedRequest(source, sampleRequest(id: 'good'));
        // Right owner and dates, but a blood group nobody knows.
        await source.create('bad', {
          ...BloodRequestMapper.toMap(sampleRequest(id: 'bad')),
          'bloodGroup': 'zNegative',
        });

        final result = await repository.getRequestsByRequester('other-uid');

        expect((result as Success<List<BloodRequest>>).value.map((r) => r.id), [
          'good',
        ]);
        expect(reporter.errors, hasLength(1));
        expect(reporter.errors.single.toString(), contains('bad'));
      },
    );

    test(
      'a DataSourceException becomes its failure, without reporting',
      () async {
        source.failWith = const NetworkFailure();

        final result = await repository.getRequestsByRequester('uid');

        expect(
          (result as Err<List<BloodRequest>>).failure,
          isA<NetworkFailure>(),
        );
        expect(reporter.errors, isEmpty);
      },
    );

    test(
      'an unexpected error becomes UnexpectedFailure and is reported',
      () async {
        final exploding = BloodRequestRepositoryImpl(
          _ExplodingRequestSource(),
          reporter: reporter,
        );

        final results = [
          await exploding.create(sampleRequest()),
          await exploding.getOpenRequests(
            bloodGroups: [BloodGroup.bPositive],
            now: testNow,
          ),
          await exploding.getRequestsByRequester('uid'),
          await exploding.updateStatus(
            requestId: 'r',
            status: RequestStatus.cancelled,
          ),
        ];

        for (final result in results) {
          expect((result as Err<Object?>).failure, isA<UnexpectedFailure>());
        }
        expect(reporter.errors, hasLength(4));
        expect(reporter.errors.first, isA<StateError>());
      },
    );
  });

  group('RequestResponseRepositoryImpl', () {
    late InMemoryRequestResponseDataSource source;
    late _RecordingReporter reporter;
    late RequestResponseRepositoryImpl repository;

    setUp(() {
      source = InMemoryRequestResponseDataSource();
      reporter = _RecordingReporter();
      repository = RequestResponseRepositoryImpl(source, reporter: reporter);
    });

    Map<String, dynamic> raw(String uid, {Object? phone = '+923011234567'}) => {
      'donorUid': uid,
      'donorName': 'Donor $uid',
      'phone': phone,
      'bloodGroup': 'oNegative',
      'locationId': 'g9_islamabad',
      'respondedAt': testNow,
    };

    test('getMyResponse returns Success(null) when there is none', () async {
      final result = await repository.getMyResponse(
        requestId: 'r1',
        donorUid: 'bob',
      );

      expect((result as Success<DonorResponse?>).value, isNull);
    });

    test('a corrupt own response is a failure, not an exception', () async {
      await source.create('r1', 'bob', raw('bob', phone: 'not-a-number'));

      final result = await repository.getMyResponse(
        requestId: 'r1',
        donorUid: 'bob',
      );

      expect((result as Err<DonorResponse?>).failure, isA<ServerFailure>());
    });

    test('a corrupt response in a list is skipped and reported', () async {
      await source.create('r1', 'good', raw('good'));
      await source.create('r1', 'bad', raw('bad', phone: 'x'));

      final result = await repository.getResponses('r1');

      expect(
        (result as Success<List<DonorResponse>>).value.map((r) => r.donorUid),
        ['good'],
      );
      expect(reporter.errors, hasLength(1));
    });

    test('failures from the source come back typed', () async {
      source.failWith = const PermissionFailure();

      expect(
        ((await repository.getResponses('r1')) as Err<List<DonorResponse>>)
            .failure,
        isA<PermissionFailure>(),
      );
      expect(
        ((await repository.withdraw(requestId: 'r1', donorUid: 'bob'))
                as Err<void>)
            .failure,
        isA<PermissionFailure>(),
      );
    });

    test(
      'an unexpected error becomes UnexpectedFailure and is reported',
      () async {
        final exploding = RequestResponseRepositoryImpl(
          _ExplodingResponseSource(),
          reporter: reporter,
        );

        final results = <Result<Object?>>[
          await exploding.getMyResponse(requestId: 'r', donorUid: 'u'),
          await exploding.getResponses('r'),
          await exploding.withdraw(requestId: 'r', donorUid: 'u'),
        ];

        for (final result in results) {
          expect((result as Err<Object?>).failure, isA<UnexpectedFailure>());
        }
        expect(reporter.errors, hasLength(3));
      },
    );
  });
}
