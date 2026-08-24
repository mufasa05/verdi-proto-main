import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'state/app_state.dart';

class VerdiApp extends ConsumerWidget {
  const VerdiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verdi',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF16A34A),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actionTextColor: Colors.transparent,
          contentTextStyle: TextStyle(color: Colors.transparent, fontSize: 0),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF16A34A),
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E293B),
          elevation: 0,
        ),
        dividerColor: const Color(0xFF334155),
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
