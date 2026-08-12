import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_screen.dart';
import 'splash_welcome_page.dart';
import '../state/auth_state.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import '../../../app_shell.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Run initialize once on startup — this restores any saved session.
    Future.microtask(() async {
      // Purge legacy/old session data on first launch under new auth system.
      // This ensures previously stored mock sessions are cleared completely.
      final prefs = await SharedPreferences.getInstance();
      final migratedKey = 'verdi.auth.migrated_v2';
      if (prefs.getBool(migratedKey) != true) {
        await prefs.remove('verdi.auth.session');
        await prefs.remove('verdi.auth.token');
        await prefs.remove('verdi.auth.last_email');
        // Clear the old registered users store (v1) if present
        await prefs.remove('verdi.auth.registered_users_db');
        await prefs.setBool(migratedKey, true);
      }

      await ref.read(authStateProvider.notifier).initialize();
      if (mounted) {
        setState(() => _initialized = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only watch isAuthenticated so we don't rebuild when isLoading flips
    // (which caused _currentStep to reset on every network call).
    final isAuthenticated = ref.watch(
      authStateProvider.select((s) => s.isAuthenticated),
    );
    final isLoading = ref.watch(
      authStateProvider.select((s) => s.isLoading),
    );

    // Show spinner only during the very first initialization check
    if (!_initialized && isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isAuthenticated) {
      if (kIsWeb) {
        return const AppShell();
      }
      return const SplashWelcomePage();
    }

    // AuthScreen is kept in the tree and manages its own step state.
    // We do NOT recreate it on every rebuild to avoid resetting _currentStep.
    return const AuthScreen();
  }
}
