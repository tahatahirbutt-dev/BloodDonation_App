import 'package:flutter/material.dart';

import 'package:blood_donation_app/core/error/failure.dart';

/// Full-screen error state (it brings its own Scaffold) with an optional
/// retry and an optional secondary action such as "Sign out", so a user
/// is never stuck on a screen with nowhere to go.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.failure,
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    super.key,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    final secondary = onSecondaryAction;
    final secondaryLabel = secondaryActionLabel;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  failure is NetworkFailure
                      ? Icons.wifi_off
                      : Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (retry != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: retry,
                    child: const Text('Try again'),
                  ),
                ],
                if (secondary != null && secondaryLabel != null) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: secondary, child: Text(secondaryLabel)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
