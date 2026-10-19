import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/data/raw_document.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/firebase/firestore_value_converter.dart';
import 'package:blood_donation_app/core/geo/geohash.dart';
import 'package:blood_donation_app/core/geo/location_catalog.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/firestore_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';
import 'package:blood_donation_app/features/donor_search/data/datasources/donor_directory_remote_data_source.dart';
import 'package:blood_donation_app/features/donor_search/data/datasources/firestore_donor_directory_data_source.dart';
import 'package:blood_donation_app/features/donor_search/data/datasources/in_memory_donor_directory_data_source.dart';
import 'package:blood_donation_app/features/donor_search/data/mappers/directory_donor_mapper.dart';
import 'package:blood_donation_app/features/donor_search/data/repositories/donor_directory_repository_impl.dart';
import 'package:blood_donation_app/features/donor_search/domain/entities/directory_donor.dart';
import 'package:blood_donation_app/features/donor_search/domain/entities/donor_directory_page.dart';

import '../../../support/request_fixtures.dart';

class _RecordingReporter implements ErrorReporter {
  final List<Object> errors = [];

  @override
  void report(Object error, StackTrace stackTrace, {bool fatal = false}) {
    errors.add(error);
  }
}

class _ExplodingDirectory implements DonorDirectoryRemoteDataSource {
  @override
  Future<List<RawDocument>> fetchByGeohashPrefix({
    required List<String> bloodGroups,
    required String prefix,
    int limit = maxQueryLimit,
  }) => throw StateError('boom');
}

/// Same behavioural checks for the in-memory and the Firestore directory.
void directorySourceContract(
  String name,
  Future<DonorDirectoryRemoteDataSource> Function(
    Map<String, Map<String, dynamic>> seed,
  )
  create,
) {
  group('$name as a DonorDirectoryRemoteDataSource', () {
    Future<DonorDirectoryRemoteDataSource> sourceWith(
      Map<String, Map<String, dynamic>> docs,
    ) => create(docs);

    Map<String, dynamic> entry(
      String locationId, {
      BloodGroup group = BloodGroup.oNegative,
      bool available = true,
    }) => directoryEntry(
      name: 'Donor',
      bloodGroup: group,
      locationId: locationId,
      isAvailable: available,
    );

    String prefixOf(String locationId, [int length = 4]) {
      final p = LocationCatalog.all.firstWhere((l) => l.id == locationId).point;
      return Geohash.encode(p.latitude, p.longitude, precision: length);
    }

    test('returns donors whose geohash starts with the prefix', () async {
      final source = await sourceWith({
        'g9': entry('g9_islamabad'),
        'afit': entry('afit_rawalpindi'),
      });

      final docs = await source.fetchByGeohashPrefix(
        bloodGroups: ['oNegative'],
        prefix: Geohash.encode(
          LocationCatalog.all
              .firstWhere((l) => l.id == 'g9_islamabad')
              .point
              .latitude,
          LocationCatalog.all
              .firstWhere((l) => l.id == 'g9_islamabad')
              .point
              .longitude,
          precision: 7,
        ),
      );

      expect(docs.map((d) => d.id), ['g9']);
    });

    test('a short prefix returns everyone in that big cell', () async {
      final source = await sourceWith({
        'g9': entry('g9_islamabad'),
        'afit': entry('afit_rawalpindi'),
      });

      final docs = await source.fetchByGeohashPrefix(
        bloodGroups: ['oNegative'],
        prefix: prefixOf('g9_islamabad', 3),
      );

      // Both are in the same 156 km cell around Islamabad/Rawalpindi.
      expect(docs.map((d) => d.id).toSet(), {'g9', 'afit'});
    });

    test('filters by blood group and availability', () async {
      final source = await sourceWith({
        'o-neg': entry('g9_islamabad'),
        'b-pos': entry('g9_islamabad', group: BloodGroup.bPositive),
        'away': entry('g9_islamabad', available: false),
      });

      final docs = await source.fetchByGeohashPrefix(
        bloodGroups: ['oNegative'],
        prefix: prefixOf('g9_islamabad', 3),
      );

      expect(docs.map((d) => d.id), ['o-neg']);
    });

    test('honours the limit', () async {
      final source = await sourceWith({
        for (var i = 0; i < 5; i++) 'd$i': entry('g9_islamabad'),
      });

      final docs = await source.fetchByGeohashPrefix(
        bloodGroups: ['oNegative'],
        prefix: prefixOf('g9_islamabad', 3),
        limit: 2,
      );

      expect(docs, hasLength(2));
    });

    test('no blood groups returns an empty list', () async {
      final source = await sourceWith({'g9': entry('g9_islamabad')});

      final docs = await source.fetchByGeohashPrefix(
        bloodGroups: [],
        prefix: prefixOf('g9_islamabad', 3),
      );

      expect(docs, isEmpty);
    });

    test('decoded values are plain DateTimes', () async {
      final source = await sourceWith({
        'g9': directoryEntry(
          name: 'Donor',
          bloodGroup: BloodGroup.oNegative,
          locationId: 'g9_islamabad',
          eligibleFrom: DateTime(2026, 5, 20),
        ),
      });

      final docs = await source.fetchByGeohashPrefix(
        bloodGroups: ['oNegative'],
        prefix: prefixOf('g9_islamabad', 3),
      );

      expect(docs.single.data['eligibleFrom'], DateTime(2026, 5, 20));
    });
  });
}

void main() {
  directorySourceContract('InMemoryDonorDirectoryDataSource', (docs) async {
    final source = InMemoryDonorDirectoryDataSource();
    docs.forEach(source.seed);
    return source;
  });

  directorySourceContract('FirestoreDonorDirectoryDataSource', (docs) async {
    final firestore = FakeFirebaseFirestore();
    for (final entry in docs.entries) {
      await firestore
          .collection(FirestoreDonorDirectoryDataSource.collectionName)
          .doc(entry.key)
          .set(FirestoreValueConverter.encode(entry.value));
    }
    return FirestoreDonorDirectoryDataSource(firestore);
  });

  test('both features agree on the name of the donors collection', () {
    expect(
      FirestoreDonorDirectoryDataSource.collectionName,
      FirestoreUserProfileDataSource.donorsCollection,
    );
  });

  group('DirectoryDonorMapper', () {
    Map<String, dynamic> valid() => directoryEntry(
      name: 'Bilal Khan',
      bloodGroup: BloodGroup.oNegative,
      locationId: 'g9_islamabad',
      eligibleFrom: DateTime(2026, 5, 20),
    );

    test('reads a valid entry', () {
      final result = DirectoryDonorMapper.fromMap('bob', valid());

      final donor = (result as Success<DirectoryDonor>).value;
      expect(donor.uid, 'bob');
      expect(donor.name, 'Bilal Khan');
      expect(donor.bloodGroup, BloodGroup.oNegative);
      expect(donor.location.id, 'g9_islamabad');
      expect(donor.isAvailable, isTrue);
      expect(donor.eligibleFrom, DateTime(2026, 5, 20));
    });

    test('eligibleFrom is optional', () {
      final map = valid()..remove('eligibleFrom');

      final result = DirectoryDonorMapper.fromMap('bob', map);

      expect((result as Success<DirectoryDonor>).value.eligibleFrom, isNull);
    });

    final corruptions = <String, void Function(Map<String, dynamic>)>{
      'a missing name': (m) => m.remove('name'),
      'an unknown blood group': (m) => m['bloodGroup'] = 'nope',
      'an unknown area': (m) => m['locationId'] = 'gone',
      'availability that is not a bool': (m) => m['isAvailable'] = 'yes',
      'eligibleFrom that is not a date': (m) => m['eligibleFrom'] = 'soon',
    };
    for (final entry in corruptions.entries) {
      test('${entry.key} becomes a failure, not an exception', () {
        final map = valid();
        entry.value(map);

        final result = DirectoryDonorMapper.fromMap('bob', map);

        expect((result as Err<DirectoryDonor>).failure, isA<ServerFailure>());
      });
    }
  });

  group('DonorDirectoryRepositoryImpl', () {
    late InMemoryDonorDirectoryDataSource source;
    late _RecordingReporter reporter;
    late DonorDirectoryRepositoryImpl repository;

    setUp(() {
      source = InMemoryDonorDirectoryDataSource();
      reporter = _RecordingReporter();
      repository = DonorDirectoryRepositoryImpl(source, reporter: reporter);
    });

    Map<String, dynamic> entry(String locationId) => directoryEntry(
      name: 'Donor',
      bloodGroup: BloodGroup.oNegative,
      locationId: locationId,
    );

    String prefix(String id, int length) {
      final p = LocationCatalog.all.firstWhere((l) => l.id == id).point;
      return Geohash.encode(p.latitude, p.longitude, precision: length);
    }

    test(
      'merges the results of several prefixes and removes duplicates',
      () async {
        source
          ..seed('g9', entry('g9_islamabad'))
          ..seed('pims', entry('pims_islamabad'));

        final result = await repository.findDonors(
          donorGroups: [BloodGroup.oNegative],
          // The same cell twice, plus a second prefix that matches too.
          geohashPrefixes: [
            prefix('g9_islamabad', 3),
            prefix('g9_islamabad', 3),
            prefix('pims_islamabad', 3),
          ],
        );

        final page = (result as Success<DonorDirectoryPage>).value;
        expect(page.donors.map((d) => d.uid).toSet(), {'g9', 'pims'});
        expect(page.donors, hasLength(2));
        expect(page.mayBeIncomplete, isFalse);
      },
    );

    test(
      'flags the page as possibly incomplete when a query hits the cap',
      () async {
        for (var i = 0; i < maxQueryLimit; i++) {
          source.seed('d$i', entry('g9_islamabad'));
        }

        final result = await repository.findDonors(
          donorGroups: [BloodGroup.oNegative],
          geohashPrefixes: [prefix('g9_islamabad', 3)],
        );

        expect(
          (result as Success<DonorDirectoryPage>).value.mayBeIncomplete,
          isTrue,
        );
      },
    );

    test('an unreadable entry is skipped and reported', () async {
      source
        ..seed('good', entry('g9_islamabad'))
        ..seed('bad', {...entry('g9_islamabad'), 'name': 42});

      final result = await repository.findDonors(
        donorGroups: [BloodGroup.oNegative],
        geohashPrefixes: [prefix('g9_islamabad', 3)],
      );

      expect(
        (result as Success<DonorDirectoryPage>).value.donors.map((d) => d.uid),
        ['good'],
      );
      expect(reporter.errors, hasLength(1));
    });

    test('a DataSourceException becomes its failure', () async {
      source.failWith = const NetworkFailure();

      final result = await repository.findDonors(
        donorGroups: [BloodGroup.oNegative],
        geohashPrefixes: ['ttt'],
      );

      expect(
        (result as Err<DonorDirectoryPage>).failure,
        isA<NetworkFailure>(),
      );
      expect(reporter.errors, isEmpty);
    });

    test(
      'an unexpected error becomes UnexpectedFailure and is reported',
      () async {
        final exploding = DonorDirectoryRepositoryImpl(
          _ExplodingDirectory(),
          reporter: reporter,
        );

        final result = await exploding.findDonors(
          donorGroups: [BloodGroup.oNegative],
          geohashPrefixes: ['ttt'],
        );

        expect(
          (result as Err<DonorDirectoryPage>).failure,
          isA<UnexpectedFailure>(),
        );
        expect(reporter.errors, hasLength(1));
      },
    );

    test('DataSourceException is what the in-memory source throws', () async {
      source.failWith = const ServerFailure();

      await expectLater(
        source.fetchByGeohashPrefix(bloodGroups: ['oNegative'], prefix: 'ttt'),
        throwsA(isA<DataSourceException>()),
      );
    });
  });
}
