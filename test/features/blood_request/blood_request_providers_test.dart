import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/id/id_generator_provider.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';
import 'package:blood_donation_app/features/blood_request/blood_request_providers.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/blood_request.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_status.dart';
import 'package:blood_donation_app/features/blood_request/domain/entities/request_urgency.dart';
import 'package:blood_donation_app/features/blood_request/domain/usecases/post_blood_request.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../support/fixed_clock.dart';
import '../../support/profile_fixtures.dart';
import '../../support/request_fixtures.dart';

// Requires generated code: run
//   dart run build_runner build --delete-conflicting-outputs
// before this file will compile.

void main() {
  test('forgetting to override the data sources fails loudly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(bloodRequestRemoteDataSourceProvider),
      throwsA(anything),
    );
    expect(
      () => container.read(requestResponseRemoteDataSourceProvider),
      throwsA(anything),
    );
  });

  test(
    'post, feed and respond work end to end through the provider graph',
    () async {
      final container = ProviderContainer(
        overrides: [
          bloodRequestRemoteDataSourceProvider.overrideWithValue(
            InMemoryBloodRequestDataSource(),
          ),
          requestResponseRemoteDataSourceProvider.overrideWithValue(
            InMemoryRequestResponseDataSource(),
          ),
          idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
          clockProvider.overrideWithValue(FixedClock(testNow)),
        ],
      );
      addTearDown(container.dispose);

      // Somebody else posts a request for a B+ patient...
      final posted = await container.read(postBloodRequestProvider)(
        const PostBloodRequestParams(
          requesterUid: 'ayesha',
          requesterName: 'Ayesha Khan',
          bloodGroup: BloodGroup.bPositive,
          unitsNeeded: 2,
          urgency: RequestUrgency.critical,
          hospitalId: 'pims_islamabad',
        ),
      );
      final request = (posted as Success<BloodRequest>).value;
      expect(request.id, 'id-1');

      // ...the default test donor (B+, uid-1) sees it...
      final donor = sampleProfile();
      final feed = await container.read(getNearbyRequestsProvider)(
        donor: donor,
      );
      expect(feed, isA<Success>());

      // ...and responds, which the requester can then read.
      final responded = await container.read(respondToRequestProvider)(
        request: request,
        donor: donor,
      );
      expect(responded, isA<Success>());

      final responses = await container.read(getRequestResponsesProvider)(
        request.id,
      );
      expect(
        (responses as Success<List<dynamic>>).value.single.donorName,
        'Taha Tahir',
      );

      final closed = await container.read(closeBloodRequestProvider)(
        requestId: request.id,
        status: RequestStatus.fulfilled,
      );
      expect(closed, isA<Success>());
    },
  );

  test('a failing data source reaches callers as a typed failure', () async {
    final source = InMemoryBloodRequestDataSource()
      ..failWith = const NetworkFailure();
    final container = ProviderContainer(
      overrides: [
        bloodRequestRemoteDataSourceProvider.overrideWithValue(source),
        requestResponseRemoteDataSourceProvider.overrideWithValue(
          InMemoryRequestResponseDataSource(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(getMyRequestsProvider)('uid-1');

    expect((result as Err<List<BloodRequest>>).failure, isA<NetworkFailure>());
  });
}
