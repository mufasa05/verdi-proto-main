import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_screen.dart';
import 'splash_welcome_page.dart';
import '../state/auth_state.dart';

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
      return const SplashWelcomePage();
    }

    // AuthScreen is kept in the tree and manages its own step state.
    // We do NOT recreate it on every rebuild to avoid resetting _currentStep.
    return const AuthScreen();
  }
}
