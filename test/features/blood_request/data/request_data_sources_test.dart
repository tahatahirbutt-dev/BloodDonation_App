import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/blood_request_remote_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/firestore_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/firestore_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/request_response_remote_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/mappers/blood_request_mapper.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';

import '../../../support/request_fixtures.dart';

/// The same behavioural checks run against the in-memory and the
/// Firestore implementation, so the two are provably interchangeable
/// (Liskov): a screen tested on one behaves the same on the other.
void bloodRequestSourceContract(
  String name,
  BloodRequestRemoteDataSource Function() create,
) {
  group('$name as a BloodRequestRemoteDataSource', () {
    late BloodRequestRemoteDataSource source;

    setUp(() => source = create());

    Map<String, dynamic> map(
      String id, {
      String group = 'bPositive',
      String requester = 'other-uid',
      RequestStatus status = RequestStatus.open,
      DateTime? created,
      DateTime? expires,
    }) {
      final request = sampleRequest(
        id: id,
        requesterUid: requester,
        status: status,
        createdAt: created,
        expiresAt: expires,
      );
      return {...BloodRequestMapper.toMap(request), 'bloodGroup': group};
    }

    List<String> ids(List<RawDocument> docs) => docs.map((d) => d.id).toList();

    test(
      'create then fetchByRequester returns the data with DateTimes',
      () async {
        await source.create('r1', map('r1'));

        final docs = await source.fetchByRequester('other-uid');

        expect(ids(docs), ['r1']);
        expect(docs.single.data['requesterName'], 'Ayesha Khan');
        expect(docs.single.data['expiresAt'], isA<DateTime>());
        expect(docs.single.data['createdAt'], isA<DateTime>());
      },
    );

    test(
      'fetchByRequester returns only that person\'s requests, newest first',
      () async {
        await source.create(
          'old',
          map(
            'old',
            created: DateTime(2026, 1, 1),
            expires: DateTime(2026, 4, 1),
          ),
        );
        await source.create(
          'new',
          map(
            'new',
            created: DateTime(2026, 2, 1),
            expires: DateTime(2026, 4, 1),
          ),
        );
        await source.create('theirs', map('theirs', requester: 'someone-else'));

        expect(ids(await source.fetchByRequester('other-uid')), ['new', 'old']);
      },
    );

    test('fetchOpen filters by status, blood group and expiry', () async {
      await source.create('ok', map('ok'));
      await source.create(
        'closed',
        map('closed', status: RequestStatus.cancelled),
      );
      await source.create(
        'other-group',
        map('other-group', group: 'oNegative'),
      );
      await source.create(
        'expired',
        map(
          'expired',
          created: DateTime(2026, 2, 1),
          expires: testNow.subtract(const Duration(minutes: 1)),
        ),
      );

      final docs = await source.fetchOpen(
        bloodGroups: ['bPositive', 'abPositive'],
        now: testNow,
      );

      expect(ids(docs), ['ok']);
    });

    test('fetchOpen returns the soonest-expiring request first', () async {
      await source.create(
        'later',
        map('later', expires: testNow.add(const Duration(days: 2))),
      );
      await source.create(
        'sooner',
        map('sooner', expires: testNow.add(const Duration(hours: 3))),
      );

      final docs = await source.fetchOpen(
        bloodGroups: ['bPositive'],
        now: testNow,
      );

      expect(ids(docs), ['sooner', 'later']);
    });

    test('fetchOpen honours the limit', () async {
      for (var i = 0; i < 5; i++) {
        await source.create(
          'r$i',
          map('r$i', expires: testNow.add(Duration(hours: i + 1))),
        );
      }

      final docs = await source.fetchOpen(
        bloodGroups: ['bPositive'],
        now: testNow,
        limit: 3,
      );

      expect(ids(docs), ['r0', 'r1', 'r2']);
    });

    test('fetchOpen with no blood groups returns an empty list', () async {
      await source.create('ok', map('ok'));

      expect(await source.fetchOpen(bloodGroups: [], now: testNow), isEmpty);
    });

    test('updateStatus changes only the status', () async {
      await source.create('r1', map('r1'));

      await source.updateStatus('r1', 'fulfilled');

      final doc = (await source.fetchByRequester('other-uid')).single;
      expect(doc.data['status'], 'fulfilled');
      expect(doc.data['units'], 2);
      expect(doc.data['requesterName'], 'Ayesha Khan');
    });

    test('the default limit is the one the security rules require', () {
      expect(maxQueryLimit, 50);
    });
  });
}

void requestResponseSourceContract(
  String name,
  RequestResponseRemoteDataSource Function() create,
) {
  group('$name as a RequestResponseRemoteDataSource', () {
    late RequestResponseRemoteDataSource source;

    setUp(() => source = create());

    Map<String, dynamic> data(String uid, DateTime at) => {
      'donorUid': uid,
      'donorName': 'Donor $uid',
      'phone': '+923011234567',
      'bloodGroup': 'oNegative',
      'locationId': 'g9_islamabad',
      'respondedAt': at,
    };

    test('fetch returns null when the donor has not responded', () async {
      expect(await source.fetch('r1', 'bob'), isNull);
    });

    test('create then fetch returns the data with a DateTime', () async {
      await source.create('r1', 'bob', data('bob', testNow));

      final stored = await source.fetch('r1', 'bob');

      expect(stored?['donorName'], 'Donor bob');
      expect(stored?['respondedAt'], isA<DateTime>());
    });

    test('responses to different requests do not mix', () async {
      await source.create('r1', 'bob', data('bob', testNow));

      expect(await source.fetch('r2', 'bob'), isNull);
      expect(await source.fetchAll('r2'), isEmpty);
    });

    test(
      'fetchAll returns every response, oldest first, with the donor uid as id',
      () async {
        await source.create(
          'r1',
          'late',
          data('late', testNow.add(const Duration(hours: 1))),
        );
        await source.create('r1', 'early', data('early', testNow));

        final docs = await source.fetchAll('r1');

        expect(docs.map((d) => d.id), ['early', 'late']);
      },
    );

    test('fetchAll honours the limit', () async {
      for (var i = 0; i < 4; i++) {
        await source.create(
          'r1',
          'd$i',
          data('d$i', testNow.add(Duration(minutes: i))),
        );
      }

      expect(await source.fetchAll('r1', limit: 2), hasLength(2));
    });

    test(
      'delete removes only that donor\'s response, and is harmless twice',
      () async {
        await source.create('r1', 'bob', data('bob', testNow));
        await source.create('r1', 'carol', data('carol', testNow));

        await source.delete('r1', 'bob');
        await source.delete('r1', 'bob');

        expect(await source.fetch('r1', 'bob'), isNull);
        expect(await source.fetch('r1', 'carol'), isNotNull);
      },
    );
  });
}

void main() {
  bloodRequestSourceContract(
    'InMemoryBloodRequestDataSource',
    InMemoryBloodRequestDataSource.new,
  );
  bloodRequestSourceContract(
    'FirestoreBloodRequestDataSource',
    () => FirestoreBloodRequestDataSource(FakeFirebaseFirestore()),
  );

  requestResponseSourceContract(
    'InMemoryRequestResponseDataSource',
    InMemoryRequestResponseDataSource.new,
  );
  requestResponseSourceContract(
    'FirestoreRequestResponseDataSource',
    () => FirestoreRequestResponseDataSource(FakeFirebaseFirestore()),
  );

  group('in-memory sources', () {
    test('updateStatus on a missing request is NotFound', () async {
      final source = InMemoryBloodRequestDataSource();

      await expectLater(
        source.updateStatus('missing', 'cancelled'),
        throwsA(
          isA<DataSourceException>().having(
            (e) => e.failure,
            'failure',
            isA<NotFoundFailure>(),
          ),
        ),
      );
    });

    test('failWith makes every call fail with that failure', () async {
      final requests = InMemoryBloodRequestDataSource()
        ..failWith = const NetworkFailure();
      final responses = InMemoryRequestResponseDataSource()
        ..failWith = const NetworkFailure();
      final isNetwork = throwsA(
        isA<DataSourceException>().having(
          (e) => e.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      );

      await expectLater(requests.create('r', {}), isNetwork);
      await expectLater(
        requests.fetchOpen(bloodGroups: ['bPositive'], now: testNow),
        isNetwork,
      );
      await expectLater(requests.fetchByRequester('u'), isNetwork);
      await expectLater(requests.updateStatus('r', 'cancelled'), isNetwork);
      await expectLater(responses.fetch('r', 'u'), isNetwork);
      await expectLater(responses.create('r', 'u', {}), isNetwork);
      await expectLater(responses.delete('r', 'u'), isNetwork);
      await expectLater(responses.fetchAll('r'), isNetwork);
    });

    test('mutating a returned map does not change the stored data', () async {
      final source = InMemoryBloodRequestDataSource();
      await seedRequest(source, sampleRequest());

      final first = (await source.fetchByRequester('other-uid')).single;
      first.data['units'] = 99;

      final again = (await source.fetchByRequester('other-uid')).single;
      expect(again.data['units'], 2);
    });
  });

  group('Firestore sources', () {
    test('requests are stored in "bloodRequests" with Timestamps', () async {
      final firestore = FakeFirebaseFirestore();
      final source = FirestoreBloodRequestDataSource(firestore);
      await seedRequest(source, sampleRequest(id: 'r1'));

      final stored =
          (await firestore.collection('bloodRequests').doc('r1').get()).data()!;

      expect(stored['createdAt'], isA<Timestamp>());
      expect(stored['expiresAt'], isA<Timestamp>());
      expect(stored['status'], 'open');
    });

    test(
      'responses live under their request: bloodRequests/{id}/responses/{uid}',
      () async {
        final firestore = FakeFirebaseFirestore();
        final source = FirestoreRequestResponseDataSource(firestore);

        await source.create('r1', 'bob', {
          'donorUid': 'bob',
          'respondedAt': testNow,
        });

        final doc = await firestore.doc('bloodRequests/r1/responses/bob').get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['respondedAt'], isA<Timestamp>());
      },
    );
  });
}
