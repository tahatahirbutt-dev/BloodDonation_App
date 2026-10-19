import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/error/result.dart';

import 'notifiers/auth_session_notifier.dart';

/// Signs out and, only if that fails, tells the user why. On success the
/// session stream emits `null` and the gate swaps in the sign-in screen,
/// so nothing else needs to happen here.
Future<void> signOutWithFeedback(BuildContext context, WidgetRef ref) async {
  // Grab the messenger before the await: the context may be gone after.
  final messenger = ScaffoldMessenger.of(context);
  final result = await ref.read(authSessionProvider.notifier).signOut();
  if (result case Err<void>(:final failure)) {
    messenger.showSnackBar(SnackBar(content: Text(failure.message)));
  }
}
