import 'package:flutter/material.dart';

import '../../../../../state/app_state.dart';

class DashboardNavigationRail extends StatelessWidget {
  final UserRole currentRole;

  const DashboardNavigationRail({
    super.key,
    required this.currentRole,
  });

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    // Use the extension getter — handles all 10 stakeholder roles
    final roleLabel = currentRole.label;

    return Container(
      width: 88,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: 0,
        labelType: NavigationRailLabelType.all,
        minWidth: 88,
        leading: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(currentRole.icon, color: green, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                roleLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: dark),
              ),
            ],
          ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: Text('Shop'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: Text('Logistics'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: Text('Analytics'),
          ),
        ],
      ),
    );
  }
}