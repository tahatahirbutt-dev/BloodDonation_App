import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/geo/geohash.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_urgency.dart';

import '../../../support/request_fixtures.dart';

void main() {
  group('RequestUrgency', () {
    test('is declared most urgent first, so index works as a sort key', () {
      expect(RequestUrgency.values, [
        RequestUrgency.critical,
        RequestUrgency.urgent,
        RequestUrgency.planned,
      ]);
    });

    test('a more urgent request stays open for a shorter time', () {
      expect(RequestUrgency.critical.validFor, const Duration(hours: 24));
      expect(RequestUrgency.urgent.validFor, const Duration(hours: 72));
      expect(RequestUrgency.planned.validFor, const Duration(days: 7));
    });

    test('no validity exceeds the 8 days the security rules allow', () {
      for (final urgency in RequestUrgency.values) {
        expect(urgency.validFor, lessThanOrEqualTo(const Duration(days: 8)));
      }
    });
  });

  group('BloodRequest', () {
    test('is open before its expiry and not at or after it', () {
      final request = sampleRequest(
        expiresAt: testNow.add(const Duration(minutes: 1)),
      );

      expect(request.isOpenAt(testNow), isTrue);
      expect(request.isOpenAt(request.expiresAt), isFalse);
      expect(
        request.isOpenAt(request.expiresAt.add(const Duration(hours: 1))),
        isFalse,
      );
      expect(request.isExpiredAt(request.expiresAt), isTrue);
    });

    test('a fulfilled or cancelled request is never open', () {
      for (final status in [RequestStatus.fulfilled, RequestStatus.cancelled]) {
        expect(sampleRequest(status: status).isOpenAt(testNow), isFalse);
      }
    });

    test('derives a 9-character geohash from the hospital', () {
      final request = sampleRequest(hospitalId: 'pims_islamabad');

      expect(request.geohash, hasLength(9));
      expect(
        request.geohash,
        Geohash.encode(
          request.hospital.point.latitude,
          request.hospital.point.longitude,
        ),
      );
    });

    test('copyWith changes only the status', () {
      final request = sampleRequest();

      final closed = request.copyWith(status: RequestStatus.fulfilled);

      expect(closed.status, RequestStatus.fulfilled);
      expect(closed.id, request.id);
      expect(closed.expiresAt, request.expiresAt);
      expect(closed.requesterUid, request.requesterUid);
    });

    test('two requests with the same data are equal', () {
      expect(sampleRequest(), sampleRequest());
      expect(sampleRequest(), isNot(sampleRequest(unitsNeeded: 3)));
    });
  });
}
