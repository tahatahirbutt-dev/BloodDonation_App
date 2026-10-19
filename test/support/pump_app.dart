import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donation_app/app.dart';
import 'package:blood_donation_app/core/id/id_generator.dart';
import 'package:blood_donation_app/core/id/id_generator_provider.dart';
import 'package:blood_donation_app/core/providers/retry_policy.dart';
import 'package:blood_donation_app/core/time/clock_provider.dart';
import 'package:blood_donation_app/features/auth/auth_providers.dart';
import 'package:blood_donation_app/features/auth/data/datasources/in_memory_auth_data_source.dart';
import 'package:blood_donation_app/features/blood_request/blood_request_providers.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_blood_request_data_source.dart';
import 'package:blood_donation_app/features/blood_request/data/datasources/in_memory_request_response_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/data/datasources/in_memory_user_profile_data_source.dart';
import 'package:blood_donation_app/features/donor_profile/donor_profile_providers.dart';
import 'package:blood_donation_app/features/donor_search/data/datasources/in_memory_donor_directory_data_source.dart';
import 'package:blood_donation_app/features/donor_search/donor_search_providers.dart';

import 'fixed_clock.dart';

/// Pumps the whole app on in-memory data sources: the real gate, pages,
/// notifiers, use cases and repositories, with no Firebase anywhere.
///
/// The request, response and directory sources are optional; pass your own
/// to seed data or to make them fail.
Future<void> pumpApp(
  WidgetTester tester, {
  required InMemoryAuthDataSource auth,
  required InMemoryUserProfileDataSource profiles,
  InMemoryBloodRequestDataSource? requests,
  InMemoryRequestResponseDataSource? responses,
  InMemoryDonorDirectoryDataSource? directory,
  IdGenerator? ids,
  DateTime? now,
}) async {
  // A tall viewport so long forms never need scrolling in tests.
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: noAutoRetry,
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(auth),
        userProfileRemoteDataSourceProvider.overrideWithValue(profiles),
        bloodRequestRemoteDataSourceProvider.overrideWithValue(
          requests ?? InMemoryBloodRequestDataSource(),
        ),
        requestResponseRemoteDataSourceProvider.overrideWithValue(
          responses ?? InMemoryRequestResponseDataSource(),
        ),
        donorDirectoryRemoteDataSourceProvider.overrideWithValue(
          directory ?? InMemoryDonorDirectoryDataSource(),
        ),
        if (ids != null) idGeneratorProvider.overrideWithValue(ids),
        if (now != null) clockProvider.overrideWithValue(FixedClock(now)),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Creates an account that is already verified and signed in, as if the
/// user had completed sign-up on an earlier run.
Future<void> seedVerifiedSignedInUser(
  InMemoryAuthDataSource auth, {
  String email = 'taha@example.com',
  String password = 'Passw0rd1',
}) async {
  await auth.signUp(email: email, password: password);
  auth.markCurrentUserVerified();
  await auth.reload();
}
