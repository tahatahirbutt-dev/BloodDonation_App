import 'package:flutter/material.dart';

import 'package:blood_donation_app/core/error/failure.dart';

/// Error state for a section inside a screen that already has its own
/// Scaffold. Always offers "Try again" when [onRetry] is given. For a
/// whole screen use `ErrorView`.
class InlineErrorView extends StatelessWidget {
  const InlineErrorView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              failure is NetworkFailure ? Icons.wifi_off : Icons.error_outline,
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
              FilledButton(onPressed: retry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
