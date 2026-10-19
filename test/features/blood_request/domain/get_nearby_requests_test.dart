import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/geo/distance_calculator.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/repositories/blood_request_repository_impl.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_feed_item.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_urgency.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/get_nearby_requests.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../../support/profile_fixtures.dart';
import '../../../support/request_fixtures.dart';

void main() {
  late InMemoryBloodRequestDataSource source;
  late GetNearbyRequests getNearby;

  // The default test donor: uid-1, B+, living in G-9.
  final donor = sampleProfile();

  setUp(() {
    source = InMemoryBloodRequestDataSource();
    getNearby = GetNearbyRequests(
      BloodRequestRepositoryImpl(source),
      clock: () => testNow,
    );
  });

  Future<List<RequestFeedItem>> feed({double? radiusKm}) async {
    final result = radiusKm == null
        ? await getNearby(donor: donor)
        : await getNearby(donor: donor, radiusKm: radiusKm);
    return (result as Success<List<RequestFeedItem>>).value;
  }

  List<String> ids(List<RequestFeedItem> items) =>
      items.map((item) => item.request.id).toList();

  test('shows requests for patients this donor can give to', () async {
    await seedRequest(
      source,
      sampleRequest(id: 'b-pos', bloodGroup: BloodGroup.bPositive),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'ab-pos', bloodGroup: BloodGroup.abPositive),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'o-pos', bloodGroup: BloodGroup.oPositive),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'a-pos', bloodGroup: BloodGroup.aPositive),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'b-neg', bloodGroup: BloodGroup.bNegative),
    );

    // B+ blood can go to B+ and AB+ patients only.
    expect(ids(await feed()).toSet(), {'b-pos', 'ab-pos'});
  });

  test('leaves out the donor\'s own, closed and expired requests', () async {
    await seedRequest(source, sampleRequest(id: 'open'));
    await seedRequest(source, sampleRequest(id: 'own', requesterUid: 'uid-1'));
    await seedRequest(
      source,
      sampleRequest(id: 'done', status: RequestStatus.fulfilled),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'gone', status: RequestStatus.cancelled),
    );
    await seedRequest(
      source,
      sampleRequest(
        id: 'old',
        expiresAt: testNow.subtract(const Duration(seconds: 1)),
      ),
    );

    expect(ids(await feed()), ['open']);
  });

  test('the most urgent request comes first, whatever its distance', () async {
    await seedRequest(
      source,
      sampleRequest(
        id: 'planned-near',
        urgency: RequestUrgency.planned,
        hospitalId: 'pims_islamabad',
      ),
    );
    await seedRequest(
      source,
      sampleRequest(
        id: 'urgent',
        urgency: RequestUrgency.urgent,
        hospitalId: 'holy_family_rawalpindi',
      ),
    );
    await seedRequest(
      source,
      sampleRequest(
        id: 'critical-far',
        urgency: RequestUrgency.critical,
        hospitalId: 'afit_rawalpindi',
      ),
    );

    expect(ids(await feed()), ['critical-far', 'urgent', 'planned-near']);
  });

  test('within the same urgency the nearest request comes first', () async {
    await seedRequest(
      source,
      sampleRequest(id: 'pims', hospitalId: 'pims_islamabad'),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'holy', hospitalId: 'holy_family_rawalpindi'),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'afit', hospitalId: 'afit_rawalpindi'),
    );

    final items = await feed();

    final distances = items.map((i) => i.distanceKm).toList();
    expect(distances, [...distances]..sort());
    expect(items, hasLength(3));
  });

  test(
    'reports the straight-line distance from the donor to the hospital',
    () async {
      final request = sampleRequest(id: 'pims', hospitalId: 'pims_islamabad');
      await seedRequest(source, request);

      final items = await feed();

      expect(
        items.single.distanceKm,
        DistanceCalculator.haversineKm(
          donor.location.point,
          request.hospital.point,
        ),
      );
    },
  );

  test('a small radius drops far requests', () async {
    await seedRequest(
      source,
      sampleRequest(id: 'pims', hospitalId: 'pims_islamabad'),
    );
    await seedRequest(
      source,
      sampleRequest(id: 'afit', hospitalId: 'afit_rawalpindi'),
    );

    expect(ids(await feed(radiusKm: 0.5)), isEmpty);
    expect(ids(await feed(radiusKm: 500)).toSet(), {'pims', 'afit'});
  });

  test('an empty feed is a success, not an error', () async {
    expect(await feed(), isEmpty);
  });

  test('a storage failure is returned as a typed failure', () async {
    source.failWith = const NetworkFailure();

    final result = await getNearby(donor: donor);

    expect(
      (result as Err<List<RequestFeedItem>>).failure,
      isA<NetworkFailure>(),
    );
  });
}
