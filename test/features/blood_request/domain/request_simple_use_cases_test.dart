import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/mappers/donor_response_mapper.dart';
import 'package:blood_donation_app/features/blood_request/data/repositories/blood_request_repository_impl.dart';
import 'package:blood_donation_app/features/blood_request/data/repositories/request_response_repository_impl.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/blood_request.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/donor_response.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/close_blood_request.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/get_my_requests.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/get_my_response.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/get_request_responses.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/withdraw_response.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';

import '../../../support/request_fixtures.dart';

DonorResponse response(String donorUid, DateTime at) {
  return DonorResponse(
    requestId: 'req-1',
    donorUid: donorUid,
    donorName: 'Donor $donorUid',
    phone: (PhoneNumber.parse('0301 1234567') as Success<PhoneNumber>).value,
    bloodGroup: BloodGroup.oNegative,
    location: LocationCatalog.all.firstWhere((l) => l.id == 'g9_islamabad'),
    respondedAt: at,
  );
}

void main() {
  group('CloseBloodRequest', () {
    late InMemoryBloodRequestDataSource source;
    late BloodRequestRepositoryImpl repository;
    late CloseBloodRequest close;

    setUp(() {
      source = InMemoryBloodRequestDataSource();
      repository = BloodRequestRepositoryImpl(source);
      close = CloseBloodRequest(repository);
    });

    Future<RequestStatus> statusOf(String id) async {
      final result = await repository.getRequestsByRequester('other-uid');
      return (result as Success<List<BloodRequest>>).value
          .firstWhere((r) => r.id == id)
          .status;
    }

    test('marks an open request fulfilled', () async {
      await seedRequest(source, sampleRequest());

      final result = await close(
        requestId: 'req-1',
        status: RequestStatus.fulfilled,
      );

      expect(result, isA<Success<void>>());
      expect(await statusOf('req-1'), RequestStatus.fulfilled);
    });

    test('marks an open request cancelled', () async {
      await seedRequest(source, sampleRequest());

      await close(requestId: 'req-1', status: RequestStatus.cancelled);

      expect(await statusOf('req-1'), RequestStatus.cancelled);
    });

    test('refuses to "close" a request as open, and changes nothing', () async {
      await seedRequest(source, sampleRequest());

      final result = await close(
        requestId: 'req-1',
        status: RequestStatus.open,
      );

      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(await statusOf('req-1'), RequestStatus.open);
    });

    test('closing a request that does not exist is NotFound', () async {
      final result = await close(
        requestId: 'missing',
        status: RequestStatus.cancelled,
      );

      expect((result as Err<void>).failure, isA<NotFoundFailure>());
    });

    test('a storage failure is returned', () async {
      await seedRequest(source, sampleRequest());
      source.failWith = const NetworkFailure();

      final result = await close(
        requestId: 'req-1',
        status: RequestStatus.cancelled,
      );

      expect((result as Err<void>).failure, isA<NetworkFailure>());
    });
  });

  group('GetMyRequests', () {
    test('returns only my requests, newest first', () async {
      final source = InMemoryBloodRequestDataSource();
      final getMine = GetMyRequests(BloodRequestRepositoryImpl(source));
      await seedRequest(
        source,
        sampleRequest(
          id: 'old',
          requesterUid: 'me',
          createdAt: DateTime(2026, 2, 1),
        ),
      );
      await seedRequest(
        source,
        sampleRequest(
          id: 'new',
          requesterUid: 'me',
          createdAt: DateTime(2026, 2, 20),
        ),
      );
      await seedRequest(
        source,
        sampleRequest(id: 'theirs', requesterUid: 'them'),
      );

      final result = await getMine('me');

      expect((result as Success<List<BloodRequest>>).value.map((r) => r.id), [
        'new',
        'old',
      ]);
    });
  });

  group('response use cases', () {
    late InMemoryRequestResponseDataSource source;
    late RequestResponseRepositoryImpl repository;

    setUp(() {
      source = InMemoryRequestResponseDataSource();
      repository = RequestResponseRepositoryImpl(source);
    });

    Future<void> store(DonorResponse r) =>
        source.create(r.requestId, r.donorUid, DonorResponseMapper.toMap(r));

    test('GetMyResponse returns the donor\'s response, or null', () async {
      final get = GetMyResponse(repository);
      await store(response('bob', testNow));

      final mine = await get(requestId: 'req-1', donorUid: 'bob');
      final none = await get(requestId: 'req-1', donorUid: 'carol');

      expect((mine as Success<DonorResponse?>).value?.donorUid, 'bob');
      expect((none as Success<DonorResponse?>).value, isNull);
    });

    test(
      'GetRequestResponses returns everyone who offered, oldest first',
      () async {
        final get = GetRequestResponses(repository);
        await store(response('late', testNow.add(const Duration(hours: 2))));
        await store(response('early', testNow));

        final result = await get('req-1');

        expect(
          (result as Success<List<DonorResponse>>).value.map((r) => r.donorUid),
          ['early', 'late'],
        );
      },
    );

    test(
      'GetRequestResponses on a request with no responses is empty',
      () async {
        final result = await GetRequestResponses(repository)('req-1');

        expect((result as Success<List<DonorResponse>>).value, isEmpty);
      },
    );

    test('WithdrawResponse removes only that donor\'s response', () async {
      await store(response('bob', testNow));
      await store(response('carol', testNow));

      final result = await WithdrawResponse(repository)(
        requestId: 'req-1',
        donorUid: 'bob',
      );

      expect(result, isA<Success<void>>());
      expect(await source.fetch('req-1', 'bob'), isNull);
      expect(await source.fetch('req-1', 'carol'), isNotNull);
    });

    test('withdrawing a response that does not exist still succeeds', () async {
      final result = await WithdrawResponse(repository)(
        requestId: 'req-1',
        donorUid: 'nobody',
      );

      expect(result, isA<Success<void>>());
    });

    test('failures come back typed', () async {
      source.failWith = const PermissionFailure();

      final result = await GetRequestResponses(repository)('req-1');

      expect(
        (result as Err<List<DonorResponse>>).failure,
        isA<PermissionFailure>(),
      );
    });
  });
}
