import 'package:blood_donation_app/core/data/query_limits.dart';
import 'package:blood_donation_app/core/error/data_source_exception.dart';
import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/blood_group.dart';

import '../../domain/entities/directory_donor.dart';
import '../../domain/entities/donor_directory_page.dart';
import '../../domain/repositories/donor_directory_repository.dart';
import '../datasources/donor_directory_remote_data_source.dart';
import '../mappers/directory_donor_mapper.dart';

/// Runs one directory query per geohash prefix, in parallel, then merges
/// them. The only place that turns data-layer exceptions into `Result`s
/// for the directory.
final class DonorDirectoryRepositoryImpl implements DonorDirectoryRepository {
  DonorDirectoryRepositoryImpl(
    this._remote, {
    ErrorReporter reporter = const NoopErrorReporter(),
  }) : _reporter = reporter;

  final DonorDirectoryRemoteDataSource _remote;
  final ErrorReporter _reporter;

  @override
  Future<Result<DonorDirectoryPage>> findDonors({
    required List<BloodGroup> donorGroups,
    required List<String> geohashPrefixes,
  }) async {
    try {
      final groupNames = [for (final group in donorGroups) group.name];

      final perPrefix = await Future.wait([
        for (final prefix in geohashPrefixes)
          _remote.fetchByGeohashPrefix(bloodGroups: groupNames, prefix: prefix),
      ]);

      var mayBeIncomplete = false;
      final byUid = <String, DirectoryDonor>{};
      for (final documents in perPrefix) {
        if (documents.length >= maxQueryLimit) mayBeIncomplete = true;
        for (final document in documents) {
          switch (DirectoryDonorMapper.fromMap(document.id, document.data)) {
            case Success<DirectoryDonor>(:final value):
              byUid[value.uid] = value;
            case Err<DirectoryDonor>():
              _reporter.report(
                StateError('Skipped unreadable donor entry "${document.id}".'),
                StackTrace.current,
              );
          }
        }
      }

      return Success<DonorDirectoryPage>(
        DonorDirectoryPage(
          donors: byUid.values.toList(growable: false),
          mayBeIncomplete: mayBeIncomplete,
        ),
      );
    } on DataSourceException catch (e) {
      return Err<DonorDirectoryPage>(e.failure);
    } catch (error, stackTrace) {
      _reporter.report(error, stackTrace);
      return const Err<DonorDirectoryPage>(UnexpectedFailure());
    }
  }
}
