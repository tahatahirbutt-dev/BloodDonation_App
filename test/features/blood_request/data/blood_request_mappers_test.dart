import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/features/blood_request/data/mappers/blood_request_mapper.dart';
import 'package:blood_donation_app/features/blood_request/data/mappers/donor_response_mapper.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/blood_request.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/donor_response.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_urgency.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/phone_number.dart';

import '../../../support/request_fixtures.dart';

void main() {
  group('BloodRequestMapper', () {
    test('round-trips a request', () {
      final request = sampleRequest(
        bloodGroup: BloodGroup.abNegative,
        unitsNeeded: 4,
        urgency: RequestUrgency.critical,
        hospitalId: 'holy_family_rawalpindi',
        note: 'Ward 2',
      );

      final result = BloodRequestMapper.fromMap(
        request.id,
        BloodRequestMapper.toMap(request),
      );

      expect((result as Success<BloodRequest>).value, request);
    });

    test('stores enum names and the derived location fields', () {
      final request = sampleRequest(
        bloodGroup: BloodGroup.abNegative,
        urgency: RequestUrgency.planned,
        status: RequestStatus.cancelled,
      );

      final map = BloodRequestMapper.toMap(request);

      expect(map['bloodGroup'], 'abNegative');
      expect(map['urgency'], 'planned');
      expect(map['status'], 'cancelled');
      expect(map['hospitalId'], 'pims_islamabad');
      expect(map['latitude'], request.hospital.point.latitude);
      expect(map['longitude'], request.hospital.point.longitude);
      expect(map['geohash'], request.geohash);
      expect(map.keys, hasLength(13)); // matches the security rules' key list
    });

    test('a missing note reads as an empty note', () {
      final map = BloodRequestMapper.toMap(sampleRequest())..remove('note');

      final result = BloodRequestMapper.fromMap('req-1', map);

      expect((result as Success<BloodRequest>).value.note, '');
    });

    Map<String, dynamic> valid() => BloodRequestMapper.toMap(sampleRequest());

    final corruptions = <String, void Function(Map<String, dynamic>)>{
      'a missing requester': (m) => m.remove('requesterUid'),
      'units that are not an int': (m) => m['units'] = '2',
      'an unknown blood group': (m) => m['bloodGroup'] = 'zNegative',
      'an unknown urgency': (m) => m['urgency'] = 'whenever',
      'an unknown status': (m) => m['status'] = 'paused',
      'a hospital removed from the catalog': (m) => m['hospitalId'] = 'gone',
      'a date that is not a DateTime': (m) => m['expiresAt'] = 'tomorrow',
      'a note that is not text': (m) => m['note'] = 42,
    };
    for (final entry in corruptions.entries) {
      test('${entry.key} becomes a failure, not an exception', () {
        final map = valid();
        entry.value(map);

        final result = BloodRequestMapper.fromMap('req-1', map);

        expect((result as Err<BloodRequest>).failure, isA<ServerFailure>());
      });
    }
  });

  group('DonorResponseMapper', () {
    DonorResponse sample() => DonorResponse(
      requestId: 'req-1',
      donorUid: 'bob',
      donorName: 'Bilal Khan',
      phone: (PhoneNumber.parse('0301 1234567') as Success<PhoneNumber>).value,
      bloodGroup: BloodGroup.oNegative,
      location: LocationCatalog.all.firstWhere((l) => l.id == 'g9_islamabad'),
      respondedAt: DateTime(2026, 3, 1, 12, 30),
    );

    test('round-trips a response', () {
      final response = sample();

      final result = DonorResponseMapper.fromMap(
        'req-1',
        'bob',
        DonorResponseMapper.toMap(response),
      );

      expect((result as Success<DonorResponse>).value, response);
    });

    test(
      'stores the phone in E.164 and exactly the fields the rules allow',
      () {
        final map = DonorResponseMapper.toMap(sample());

        expect(map['phone'], '+923011234567');
        expect(
          map.keys,
          unorderedEquals(<String>[
            'donorUid',
            'donorName',
            'phone',
            'bloodGroup',
            'locationId',
            'respondedAt',
          ]),
        );
      },
    );

    final corruptions = <String, void Function(Map<String, dynamic>)>{
      'a missing name': (m) => m.remove('donorName'),
      'a malformed phone': (m) => m['phone'] = '12345',
      'an unknown blood group': (m) => m['bloodGroup'] = 'nope',
      'an unknown area': (m) => m['locationId'] = 'gone',
      'a date that is not a DateTime': (m) => m['respondedAt'] = 1,
    };
    for (final entry in corruptions.entries) {
      test('${entry.key} becomes a failure, not an exception', () {
        final map = DonorResponseMapper.toMap(sample());
        entry.value(map);

        final result = DonorResponseMapper.fromMap('req-1', 'bob', map);

        expect((result as Err<DonorResponse>).failure, isA<ServerFailure>());
      });
    }
  });
}
