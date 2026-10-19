import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/observability/error_reporter.dart';
import 'package:blood_donation_app/core/observability/error_reporter_provider.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/donor_profile_providers.dart';

class _RecordingReporter implements ErrorReporter {
  final List<Object> errors = [];

  @override
  void report(Object error, StackTrace stackTrace, {bool fatal = false}) {
    errors.add(error);
  }
}

class _BuggyDataSource implements UserProfileRemoteDataSource {
  @override
  Future<Map<String, dynamic>?> fetch(String uid) async =>
      throw StateError('simulated bug');

  @override
  Future<void> upsert(String uid, Map<String, dynamic> data) async =>
      throw StateError('simulated bug');
}

void main() {
  test('an unexpected repository error reaches the ErrorReporter, and the '
      'caller still gets a typed failure', () async {
    final reporter = _RecordingReporter();
    final container = ProviderContainer(
      overrides: [
        errorReporterProvider.overrideWithValue(reporter),
        userProfileRemoteDataSourceProvider.overrideWithValue(
          _BuggyDataSource(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(userProfileRepositoryProvider)
        .getProfile('u1');

    expect(result, isA<Err>());
    expect((result as Err).failure, isA<UnexpectedFailure>());
    expect(reporter.errors, hasLength(1));
    expect(reporter.errors.single, isA<StateError>());
  });
}
