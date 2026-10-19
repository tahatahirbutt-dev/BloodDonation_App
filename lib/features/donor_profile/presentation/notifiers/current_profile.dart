import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';

import '../../domain/entities/user_profile.dart';
import '../../donor_profile_providers.dart';

part 'current_profile.g.dart';

/// The signed-in user's profile. `null` data means "signed in but has not
/// completed profile setup yet", which the gate turns into the setup
/// screen. A failure becomes an `AsyncError` carrying the typed `Failure`
/// so the screen can show a real message and a retry button.
@riverpod
Future<UserProfile?> currentProfile(Ref ref, String uid) async {
  final result = await ref.watch(getUserProfileProvider).call(uid);
  return switch (result) {
    Success<UserProfile?>(:final value) => value,
    Err<UserProfile?>(:final failure) => throw failure,
  };
}
