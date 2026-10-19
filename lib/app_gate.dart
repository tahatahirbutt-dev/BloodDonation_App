import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/presentation/failure_ui.dart';
import 'package:blood_donation_app/core/presentation/widgets/error_view.dart';
import 'package:blood_donation_app/core/presentation/widgets/loading_view.dart';
import 'package:blood_donation_app/features/auth/presentation/notifiers/auth_session_notifier.dart';
import 'package:blood_donation_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:blood_donation_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:blood_donation_app/features/auth/presentation/sign_out_action.dart';
import 'package:blood_donation_app/features/donor_profile/presentation/pages/profile_gate.dart';
import 'package:blood_donation_app/home/home_shell.dart';

/// The app's router: one screen per state, no navigation stack to get out
/// of sync. Signed out -> sign in. Unverified -> verify email. Verified ->
/// profile gate (setup or home). Loading and error states are explicit.
///
/// This is the only place that knows both features, so they stay
/// independent of each other.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    // Detail and form screens are pushed on top of the gate. If the
    // session ends while one is open (sign-out, revoked account), close
    // them all so the sign-in screen is what the user sees.
    ref.listen(authSessionProvider, (previous, next) {
      if (next.hasValue && next.value == null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return session.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const LoadingView(message: 'Starting…'),
      error: (error, _) => ErrorView(
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(authSessionProvider),
      ),
      data: (user) {
        if (user == null) return const SignInPage();
        if (!user.isEmailVerified) return VerifyEmailPage(user: user);
        return ProfileGate(
          uid: user.uid,
          onSignOut: () => signOutWithFeedback(context, ref),
          homeBuilder: (context, profile) => HomeShell(
            profile: profile,
            onSignOut: () => signOutWithFeedback(context, ref),
          ),
        );
      },
    );
  }
}
