import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/error_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/loading_view.dart';

import '../../domain/entities/user_profile.dart';
import '../notifiers/current_profile.dart';
import 'profile_setup_page.dart';

/// Decides what a signed-in, verified user sees: Home if a profile
/// exists, profile setup if not, and an error screen with retry (and a
/// way out) if the profile cannot be loaded.
///
/// Takes [uid] and [onSignOut] instead of an auth type, and a
/// [homeBuilder] instead of a concrete home screen, so this feature stays
/// independent of both the auth feature and the request features. The app
/// gate supplies the real home.
class ProfileGate extends ConsumerWidget {
  const ProfileGate({
    required this.uid,
    required this.onSignOut,
    required this.homeBuilder,
    super.key,
  });

  final String uid;
  final VoidCallback onSignOut;
  final Widget Function(BuildContext context, UserProfile profile) homeBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(currentProfileProvider(uid));

    return profileState.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const LoadingView(message: 'Loading your profile…'),
      error: (error, _) => ErrorView(
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(currentProfileProvider(uid)),
        secondaryActionLabel: 'Sign out',
        onSecondaryAction: onSignOut,
      ),
      data: (profile) => profile == null
          ? ProfileSetupPage(uid: uid, onSignOut: onSignOut)
          : homeBuilder(context, profile),
    );
  }
}
