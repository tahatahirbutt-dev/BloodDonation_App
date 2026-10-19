import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/repositories/blood_request_repository_impl.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/blood_request.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_urgency.dart';
import 'package:blood_donation_app/features/blood_request/domain/repositories/blood_request_repository.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/post_blood_request.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../../support/request_fixtures.dart';

/// Delegates reads to a real repository but fails every create.
class _CreateFails implements BloodRequestRepository {
  _CreateFails(this._inner);

  final BloodRequestRepository _inner;

  @override
  Future<Result<void>> create(BloodRequest request) async =>
      const Err<void>(NetworkFailure());

  @override
  Future<Result<List<BloodRequest>>> getOpenRequests({
    required List<BloodGroup> bloodGroups,
    required DateTime now,
  }) => _inner.getOpenRequests(bloodGroups: bloodGroups, now: now);

  @override
  Future<Result<List<BloodRequest>>> getRequestsByRequester(String uid) =>
      _inner.getRequestsByRequester(uid);

  @override
  Future<Result<void>> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) => _inner.updateStatus(requestId: requestId, status: status);
}

PostBloodRequestParams params({
  int units = 2,
  String hospitalId = 'pims_islamabad',
  String note = '',
  RequestUrgency urgency = RequestUrgency.critical,
}) {
  return PostBloodRequestParams(
    requesterUid: 'uid-1',
    requesterName: 'Taha Tahir',
    bloodGroup: BloodGroup.aNegative,
    unitsNeeded: units,
    urgency: urgency,
    hospitalId: hospitalId,
    note: note,
  );
}

ValidationFailure validationFailureOf(Result<Object?> result) =>
    (result as Err<Object?>).failure as ValidationFailure;

void main() {
  late InMemoryBloodRequestDataSource source;
  late BloodRequestRepositoryImpl repository;
  late PostBloodRequest postRequest;

  setUp(() {
    source = InMemoryBloodRequestDataSource();
    repository = BloodRequestRepositoryImpl(source);
    postRequest = PostBloodRequest(
      repository,
      idGenerator: SequentialIdGenerator(),
      clock: () => testNow,
    );
  });

  test('posts a valid request: id, status and expiry are set', () async {
    final result = await postRequest(params(note: '  Ward 4  '));

    final request = (result as Success<BloodRequest>).value;
    expect(request.id, 'id-1');
    expect(request.requesterUid, 'uid-1');
    expect(request.requesterName, 'Taha Tahir');
    expect(request.bloodGroup, BloodGroup.aNegative);
    expect(request.unitsNeeded, 2);
    expect(request.status, RequestStatus.open);
    expect(request.note, 'Ward 4'); // trimmed
    expect(request.createdAt, testNow);
    expect(request.expiresAt, testNow.add(const Duration(hours: 24)));
  });

  test('the expiry follows the urgency', () async {
    final planned = await postRequest(params(urgency: RequestUrgency.planned));

    expect(
      (planned as Success<BloodRequest>).value.expiresAt,
      testNow.add(const Duration(days: 7)),
    );
  });

  test('the request is really stored', () async {
    await postRequest(params());

    final stored = await repository.getRequestsByRequester('uid-1');

    expect((stored as Success<List<BloodRequest>>).value.single.id, 'id-1');
  });

  group('validation', () {
    test('units below 1 or above 10 are rejected on the units field', () async {
      for (final units in [0, 11, -3]) {
        final failure = validationFailureOf(
          await postRequest(params(units: units)),
        );
        expect(failure.field, 'units', reason: '$units units');
      }
      expect(await source.fetchByRequester('uid-1'), isEmpty);
    });

    test('1 and 10 units are accepted', () async {
      expect(await postRequest(params(units: 1)), isA<Success<BloodRequest>>());
      expect(
        await postRequest(params(units: 10)),
        isA<Success<BloodRequest>>(),
      );
    });

    test('an unknown hospital id is rejected on the hospital field', () async {
      final failure = validationFailureOf(
        await postRequest(params(hospitalId: 'nowhere')),
      );

      expect(failure.field, 'hospital');
    });

    test('a residential area is not a hospital', () async {
      final failure = validationFailureOf(
        await postRequest(params(hospitalId: 'g9_islamabad')),
      );

      expect(failure.field, 'hospital');
    });

    test('a blood bank is accepted as the place to donate', () async {
      expect(
        await postRequest(params(hospitalId: 'afit_rawalpindi')),
        isA<Success<BloodRequest>>(),
      );
    });

    test('a note over 200 characters is rejected on the note field', () async {
      final failure = validationFailureOf(
        await postRequest(params(note: 'x' * 201)),
      );

      expect(failure.field, 'note');
    });

    test(
      'a note of exactly 200 characters (after trimming) is accepted',
      () async {
        expect(
          await postRequest(params(note: ' ${'x' * 200} ')),
          isA<Success<BloodRequest>>(),
        );
      },
    );
  });

  group('open request limit', () {
    test('a fourth open request is refused with a clear message', () async {
      for (var i = 0; i < BloodRequest.maxOpenPerRequester; i++) {
        expect(await postRequest(params()), isA<Success<BloodRequest>>());
      }

      final result = await postRequest(params());

      final failure = validationFailureOf(result);
      expect(failure.field, isNull);
      expect(failure.message, contains('open'));
      expect((await source.fetchByRequester('uid-1')), hasLength(3));
    });

    test(
      'closed and expired requests do not count towards the limit',
      () async {
        await seedRequest(
          source,
          sampleRequest(
            id: 'a',
            requesterUid: 'uid-1',
            status: RequestStatus.cancelled,
          ),
        );
        await seedRequest(
          source,
          sampleRequest(
            id: 'b',
            requesterUid: 'uid-1',
            status: RequestStatus.fulfilled,
          ),
        );
        await seedRequest(
          source,
          sampleRequest(
            id: 'c',
            requesterUid: 'uid-1',
            expiresAt: testNow.subtract(const Duration(minutes: 1)),
          ),
        );

        expect(await postRequest(params()), isA<Success<BloodRequest>>());
        expect(await postRequest(params()), isA<Success<BloodRequest>>());
        expect(await postRequest(params()), isA<Success<BloodRequest>>());
      },
    );

    test("someone else's open requests do not count", () async {
      for (var i = 0; i < 5; i++) {
        await seedRequest(
          source,
          sampleRequest(id: 'x$i', requesterUid: 'other'),
        );
      }

      expect(await postRequest(params()), isA<Success<BloodRequest>>());
    });
  });

  group('failures', () {
    test('a storage failure while checking the limit is returned', () async {
      source.failWith = const NetworkFailure();

      final result = await postRequest(params());

      expect((result as Err<BloodRequest>).failure, isA<NetworkFailure>());
    });

    test('a storage failure while saving is returned', () async {
      final failing = PostBloodRequest(
        _CreateFails(repository),
        idGenerator: SequentialIdGenerator(),
        clock: () => testNow,
      );

      final result = await failing(params());

      expect((result as Err<BloodRequest>).failure, isA<NetworkFailure>());
    });
  });
}
