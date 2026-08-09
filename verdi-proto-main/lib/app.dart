import 'package:flutter/material.dart';
import 'features/auth/presentation/auth_gate.dart';

class VerdiApp extends StatelessWidget {
  const VerdiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verdi',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF16A34A),
        snackBarTheme: const SnackBarThemeData(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actionTextColor: Colors.transparent,
          contentTextStyle: TextStyle(color: Colors.transparent, fontSize: 0),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
