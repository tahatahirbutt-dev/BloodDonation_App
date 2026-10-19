import 'package:flutter/material.dart';

/// Full-screen loading state (it brings its own Scaffold).
class LoadingView extends StatelessWidget {
  const LoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (text != null) ...[const SizedBox(height: 16), Text(text)],
          ],
        ),
      ),
    );
  }
}
