import 'dart:async' show unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/app.dart';
import 'package:blood_donation_app/core/observability/crashlytics_error_reporter.dart';
import 'package:blood_donation_app/core/observability/error_reporter_provider.dart';
import 'package:blood_donation_app/core/providers/retry_policy.dart';
import 'package:blood_donation_app/features/auth/auth_providers.dart';
import 'package:blood_donation_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:blood_donation_app/features/blood_request/blood_request_providers.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/firestore_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/firestore_request_response_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/firestore_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/donor_profile_providers.dart';
import 'package:blood_donation_app/features/donor_search/data/datasources/firestore_donor_directory_data_source.dart';
import 'package:blood_donation_app/features/donor_search/donor_search_providers.dart';

import 'friendly_error_widget.dart';
import 'startup_failure_app.dart';

/// The one place that touches Firebase at startup and builds the real
/// dependency graph. Order matters:
///
///  1. Initialize Firebase. If this fails, show [StartupFailureApp] with
///     a retry button instead of crashing.
///  2. Hook Crashlytics into Flutter's and the platform's error channels,
///     so nothing that throws goes unrecorded.
///  3. Run the app with the real implementations injected.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // No options argument: on Android this reads google-services.json.
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    // Crashlytics is unavailable (it needs Firebase), so log locally.
    debugPrint('Firebase init failed: $error\n$stackTrace');
    runApp(StartupFailureApp(onRetry: bootstrap));
    return;
  }

  final crashlytics = FirebaseCrashlytics.instance;
  try {
    // Keep debug-session noise out of the production crash dashboard.
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  } catch (error) {
    debugPrint('Could not configure Crashlytics: $error');
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details); // still prints in the debug console
    unawaited(crashlytics.recordFlutterFatalError(details));
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(crashlytics.recordError(error, stackTrace, fatal: true));
    return true; // handled: do not let it kill the process
  };

  if (!kDebugMode) {
    ErrorWidget.builder = (_) => const FriendlyErrorWidget();
  }

  runApp(
    ProviderScope(
      // Failures reach the screen immediately, with a Retry button,
      // instead of being retried silently behind a spinner.
      retry: noAutoRetry,
      overrides: [
        errorReporterProvider.overrideWithValue(
          CrashlyticsErrorReporter(crashlytics),
        ),
        authRemoteDataSourceProvider.overrideWithValue(
          FirebaseAuthDataSource(FirebaseAuth.instance),
        ),
        userProfileRemoteDataSourceProvider.overrideWithValue(
          FirestoreUserProfileDataSource(FirebaseFirestore.instance),
        ),
        bloodRequestRemoteDataSourceProvider.overrideWithValue(
          FirestoreBloodRequestDataSource(FirebaseFirestore.instance),
        ),
        requestResponseRemoteDataSourceProvider.overrideWithValue(
          FirestoreRequestResponseDataSource(FirebaseFirestore.instance),
        ),
        donorDirectoryRemoteDataSourceProvider.overrideWithValue(
          FirestoreDonorDirectoryDataSource(FirebaseFirestore.instance),
        ),
      ],
      child: const App(),
    ),
  );
}
