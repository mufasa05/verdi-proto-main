import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:verdi/features/admin/presentation/admin_dashboard_page.dart';
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
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
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
        builder: (context, state) => const _SimplePage(title: 'AI Assistant'),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const _SimplePage(title: 'Settings'),
      ),
      GoRoute(
        path: '/exports',
        builder: (context, state) => const _SimplePage(title: 'Exports'),
      ),
      GoRoute(
        path: '/logistics',
        builder: (context, state) => const _SimplePage(title: 'Logistics'),
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

class _SimplePage extends StatelessWidget {
  final String title;

  const _SimplePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
