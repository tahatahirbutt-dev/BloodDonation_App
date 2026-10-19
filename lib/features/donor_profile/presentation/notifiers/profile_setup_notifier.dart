import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/save_user_profile.dart';
import '../../donor_profile_providers.dart';
import 'current_profile.dart';

part 'profile_setup_notifier.g.dart';

/// State of the profile form: idle (`AsyncData`), saving (`AsyncLoading`)
/// or failed (`AsyncError` carrying a typed `Failure`, possibly a
/// `ValidationFailure` that names the field to highlight).
@riverpod
class ProfileSetup extends _$ProfileSetup {
  @override
  FutureOr<void> build() {}

  Future<void> save(SaveUserProfileParams params) async {
    state = const AsyncLoading<void>();
    final result = await ref.read(saveUserProfileProvider).call(params);
    // The user may have left the screen while the save was in flight.
    if (!ref.mounted) return;
    state = asyncVoidFromResult(result);
    if (result is Success<UserProfile>) {
      // Re-read so the gate sees a profile and moves on to Home.
      ref.invalidate(currentProfileProvider(params.uid));
    }
  }
}
