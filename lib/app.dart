import 'package:flutter/material.dart';

import 'app_gate.dart';

/// Root widget. Theming and the gate live here; routing between screens is
/// decided by [AppGate] from the auth and profile state.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const AppGate(),
    );
  }
}
