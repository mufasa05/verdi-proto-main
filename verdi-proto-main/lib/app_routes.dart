import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:verdi/features/drone_inspection/presentation/drone_inspection_view.dart';
import 'package:verdi/features/farm_operations/presentation/farm_operations_page.dart';
import 'package:verdi/features/marketplace/presentation/marketplace_page.dart';
import 'package:verdi/features/orders/presentation/orders_page.dart';
import 'package:verdi/features/payments/presentation/payments_page.dart';
import 'package:verdi/features/traceability/presentation/traceability_page.dart';
import 'package:verdi/widgets/app_navigation_drawer.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/farm-operations',
    routes: [
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/marketplace',
          child: const MarketplacePage(),
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) =>
            ShellScaffold(currentRoute: '/orders', child: const OrdersPage()),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/payments',
          child: const PaymentsPage(),
        ),
      ),
      GoRoute(
        path: '/farm-operations',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/farm-operations',
          child: const FarmOperationsPage(),
        ),
      ),
      GoRoute(
        path: '/government-irrigation',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/farm-operations',
          child: const FarmOperationsPage(),
        ),
      ),
      GoRoute(
        path: '/farmer-irrigation',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/farm-operations',
          child: const FarmOperationsPage(),
        ),
      ),
      GoRoute(
        path: '/drone-inspection',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/drone-inspection',
          child: const DroneInspectionView(),
        ),
      ),
      GoRoute(
        path: '/traceability',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/traceability',
          child: const TraceabilityPage(),
        ),
      ),
      GoRoute(
        path: '/assistant',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/assistant',
          child: const PlaceholderScreen(
            title: 'AI Assistant',
            subtitle: 'Assistant page coming next.',
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/settings',
          child: const PlaceholderScreen(
            title: 'Settings',
            subtitle: 'Settings page coming next.',
          ),
        ),
      ),
      GoRoute(
        path: '/exports',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/exports',
          child: const PlaceholderScreen(
            title: 'Exports',
            subtitle: 'Exports page coming next.',
          ),
        ),
      ),
      GoRoute(
        path: '/logistics',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/logistics',
          child: const PlaceholderScreen(
            title: 'Logistics',
            subtitle: 'Logistics page coming next.',
          ),
        ),
      ),
      GoRoute(
        path: '/geospatial',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/geospatial',
          child: const FarmOperationsPage(),
        ),
      ),
      GoRoute(
        path: '/satellite',
        builder: (context, state) => ShellScaffold(
          currentRoute: '/satellite',
          child: const FarmOperationsPage(),
        ),
      ),
    ],
  );
}

class ShellScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const ShellScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      drawer: isDesktop
          ? null
          : AppNavigationDrawer(
              currentRoute: currentRoute,
              onNavigate: (route) => context.go(route),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 300,
              child: AppNavigationDrawer(
                currentRoute: currentRoute,
                onNavigate: (route) => context.go(route),
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
