import 'package:flutter/material.dart';

/// Replaces Flutter's grey "error box" in release builds, so one widget
/// that throws while building shows a small message in its own spot and
/// the rest of the screen keeps working.
class FriendlyErrorWidget extends StatelessWidget {
  const FriendlyErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Something went wrong showing this part of the screen.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}
