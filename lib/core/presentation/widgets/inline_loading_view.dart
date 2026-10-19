import 'package:flutter/material.dart';

/// Loading state for a section inside a screen that already has its own
/// Scaffold (a tab, a list). For a whole screen use `LoadingView`.
class InlineLoadingView extends StatelessWidget {
  const InlineLoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (text != null) ...[
              const SizedBox(height: 16),
              Text(text, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
