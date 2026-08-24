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
        cardColor: Colors.white,
        canvasColor: Colors.white,
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
        dividerColor: const Color(0xFFE2E8F0),
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
        scaffoldBackgroundColor: const Color(0xFF070B12),
        canvasColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF0F172A),
        dialogBackgroundColor: const Color(0xFF0F172A),
        cardTheme: const CardThemeData(
          color: Color(0xFF0F172A),
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        dividerColor: const Color(0xFF1E293B),
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
