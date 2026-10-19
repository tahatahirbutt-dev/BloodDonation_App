import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blood_donation_app/core/error/result.dart';
import 'package:blood_donation_app/core/presentation/failure_ui.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/save_user_profile.dart';
import '../../donor_profile_providers.dart';
import 'current_profile.dart';

part 'profile_preferences_notifier.g.dart';

/// The two switches on the profile tab: "available to donate" and
/// "show me in donor search". Saves through the same `SaveUserProfile`
/// use case as the setup form, so there is still one set of rules. Idle
/// (`AsyncData`), saving (`AsyncLoading`) or failed (`AsyncError` with a
/// typed `Failure`).
@riverpod
class ProfilePreferences extends _$ProfilePreferences {
  @override
  FutureOr<void> build() {}

  Future<void> updatePreferences(
    UserProfile profile, {
    bool? isAvailable,
    bool? isVisible,
  }) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(saveUserProfileProvider)
        .call(
          SaveUserProfileParams(
            uid: profile.uid,
            name: profile.name,
            rawPhone: profile.phone.e164,
            bloodGroup: profile.bloodGroup,
            locationId: profile.location.id,
            lastDonationDate: profile.lastDonationDate,
            isAvailable: isAvailable ?? profile.isAvailable,
            isVisible: isVisible ?? profile.isVisible,
          ),
        );
    if (!ref.mounted) return;
    state = asyncVoidFromResult(result);
    if (result is Success<UserProfile>) {
      // Re-read so every screen sees the new flags.
      ref.invalidate(currentProfileProvider(profile.uid));
    }
  }
}
