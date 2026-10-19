import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/repositories/request_response_repository_impl.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/donor_response.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/respond_to_request.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../../support/profile_fixtures.dart';
import '../../../support/request_fixtures.dart';

void main() {
  late InMemoryRequestResponseDataSource source;
  late RequestResponseRepositoryImpl repository;
  late DateTime now;
  late RespondToRequest respond;

  // The default donor: uid-1, B+, available, never donated, lives in G-9.
  final donor = sampleProfile();

  setUp(() {
    source = InMemoryRequestResponseDataSource();
    repository = RequestResponseRepositoryImpl(source);
    now = testNow;
    respond = RespondToRequest(repository, clock: () => now);
  });

  ValidationFailure blocked(Object? result) =>
      (result as Err<DonorResponse>).failure as ValidationFailure;

  group('a donor who can help', () {
    test(
      'shares name, phone, blood group and area, and stores the response',
      () async {
        final result = await respond(request: sampleRequest(), donor: donor);

        final response = (result as Success<DonorResponse>).value;
        expect(response.requestId, 'req-1');
        expect(response.donorUid, 'uid-1');
        expect(response.donorName, 'Taha Tahir');
        expect(response.phone.e164, '+923001234567');
        expect(response.bloodGroup, BloodGroup.bPositive);
        expect(response.location.id, 'g9_islamabad');
        expect(response.respondedAt, testNow);

        final stored = await repository.getMyResponse(
          requestId: 'req-1',
          donorUid: 'uid-1',
        );
        expect((stored as Success<DonorResponse?>).value, response);
      },
    );

    test('blockReason is null', () {
      expect(
        respond.blockReason(request: sampleRequest(), donor: donor),
        isNull,
      );
    });

    test(
      'responding twice keeps the first response and writes nothing new',
      () async {
        final first = await respond(request: sampleRequest(), donor: donor);

        now = testNow.add(const Duration(minutes: 30));
        final second = await respond(request: sampleRequest(), donor: donor);

        expect(
          (second as Success<DonorResponse>).value,
          (first as Success<DonorResponse>).value,
        );
        expect(second.value.respondedAt, testNow);
      },
    );

    test(
      'an AB+ patient can be helped by a B+ donor, an O+ patient cannot',
      () async {
        expect(
          respond.blockReason(
            request: sampleRequest(bloodGroup: BloodGroup.abPositive),
            donor: donor,
          ),
          isNull,
        );
        expect(
          respond.blockReason(
            request: sampleRequest(bloodGroup: BloodGroup.oPositive),
            donor: donor,
          ),
          isNotNull,
        );
      },
    );
  });

  group('is refused, with a clear reason, when', () {
    test('the request is closed', () async {
      final request = sampleRequest(status: RequestStatus.fulfilled);

      final failure = blocked(await respond(request: request, donor: donor));

      expect(failure.message, contains('no longer open'));
    });

    test('the request has expired', () async {
      final request = sampleRequest(
        expiresAt: testNow.subtract(const Duration(minutes: 1)),
      );

      final failure = blocked(await respond(request: request, donor: donor));

      expect(failure.message, contains('no longer open'));
    });

    test('it is the donor\'s own request', () async {
      final request = sampleRequest(requesterUid: 'uid-1');

      final failure = blocked(await respond(request: request, donor: donor));

      expect(failure.message, contains('own request'));
    });

    test('the blood group cannot be given to the patient', () async {
      final request = sampleRequest(bloodGroup: BloodGroup.oNegative);

      final failure = blocked(await respond(request: request, donor: donor));

      expect(failure.message, contains('B+'));
      expect(failure.message, contains('O-'));
    });

    test('the donor set themselves as unavailable', () async {
      final failure = blocked(
        await respond(
          request: sampleRequest(),
          donor: donor.copyWith(isAvailable: false),
        ),
      );

      expect(failure.message, contains('unavailable'));
    });

    test('the donor donated too recently', () async {
      final recent = sampleProfile(lastDonationDate: DateTime(2026, 2, 19));

      final failure = blocked(
        await respond(request: sampleRequest(), donor: recent),
      );

      // 19 Feb + 90 days = 20 May; from 1 Mar that is 80 days.
      expect(failure.message, contains('80 days'));
    });

    test(
      'a donor exactly 90 days after their last donation may respond',
      () async {
        // 90 days before 1 Mar 2026 is 1 Dec 2025.
        final ready = sampleProfile(lastDonationDate: DateTime(2025, 12, 1));

        expect(
          respond.blockReason(request: sampleRequest(), donor: ready),
          isNull,
        );
      },
    );

    test('nothing is stored when the response is refused', () async {
      await respond(
        request: sampleRequest(),
        donor: donor.copyWith(isAvailable: false),
      );

      final stored = await source.fetchAll('req-1');
      expect(stored, isEmpty);
    });
  });

  group('storage failures', () {
    test('are returned as typed failures', () async {
      source.failWith = const NetworkFailure();

      final result = await respond(request: sampleRequest(), donor: donor);

      expect((result as Err<DonorResponse>).failure, isA<NetworkFailure>());
    });
  });
}
