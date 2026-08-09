import 'package:flutter/material.dart';

class VerdiDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const VerdiDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

const verdiDestinations = [
  VerdiDestination(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  VerdiDestination(
    label: 'Weather',
    icon: Icons.cloud_outlined,
    selectedIcon: Icons.cloud,
  ),
  VerdiDestination(
    label: 'Marketplace',
    icon: Icons.storefront_outlined,
    selectedIcon: Icons.storefront,
  ),
  VerdiDestination(
    label: 'Logistics',
    icon: Icons.local_shipping_outlined,
    selectedIcon: Icons.local_shipping,
  ),
  VerdiDestination(
    label: 'Trade',
    icon: Icons.swap_horiz_outlined,
    selectedIcon: Icons.swap_horiz,
  ),
  VerdiDestination(
    label: 'Finance',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
  ),
  VerdiDestination(
    label: 'AI Assistant',
    icon: Icons.psychology_alt_outlined,
    selectedIcon: Icons.psychology_alt,
  ),
  VerdiDestination(
    label: 'Analytics',
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
  ),
  VerdiDestination(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];