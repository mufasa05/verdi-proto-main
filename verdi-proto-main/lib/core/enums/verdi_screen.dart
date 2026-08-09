import 'package:flutter/material.dart';

/// Strongly-typed screen navigation enum for Verdi OS.
/// Maps 1-to-1 with the `pages` list in `app_shell.dart`.
enum VerdiScreen {
  home(0, 'Home', Icons.home_outlined, Icons.home_rounded),
  marketplace(1, 'Marketplace', Icons.storefront_outlined, Icons.storefront_rounded),
  chats(2, 'Chats & AI', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
  analytics(3, 'Analytics', Icons.insights_outlined, Icons.insights_rounded),
  orders(4, 'Orders & Sales', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
  logistics(5, 'Logistics', Icons.local_shipping_outlined, Icons.local_shipping_rounded),
  payments(6, 'Payments', Icons.payments_outlined, Icons.payments_rounded),
  notifications(7, 'Notifications', Icons.notifications_outlined, Icons.notifications_rounded),
  govIrrigation(8, 'Gov Irrigation', Icons.water_drop_outlined, Icons.water_drop_rounded),
  irrigation(9, 'Smart Irrigation', Icons.water_drop_outlined, Icons.water_drop_rounded),
  drone(10, 'Drone Inspection', Icons.flight_takeoff_outlined, Icons.flight_takeoff_rounded),
  farmOps(11, 'Farm Operations', Icons.agriculture_outlined, Icons.agriculture_rounded),
  dashboard(12, 'Control Tower', Icons.dashboard_outlined, Icons.dashboard_rounded),
  geospatial(13, 'Geospatial', Icons.map_outlined, Icons.map_rounded),
  cropHealth(14, 'Crop Health', Icons.eco_outlined, Icons.eco_rounded),
  traceability(15, 'Traceability', Icons.qr_code_outlined, Icons.qr_code_rounded),
  finance(16, 'Finance', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded),
  weather(17, 'Weather', Icons.cloud_outlined, Icons.cloud_rounded),
  government(18, 'Ministry Portal', Icons.account_balance_outlined, Icons.account_balance_rounded),
  trade(19, 'Trade Control', Icons.swap_horiz_outlined, Icons.swap_horiz_rounded),
  satellites(20, 'Satellites', Icons.satellite_alt_outlined, Icons.satellite_alt_rounded),
  settings(21, 'Settings', Icons.settings_outlined, Icons.settings_rounded),
  export(22, 'Export & Trade', Icons.local_shipping_outlined, Icons.local_shipping_rounded),
  admin(23, 'Admin Command Center', Icons.admin_panel_settings_outlined, Icons.admin_panel_settings_rounded);

  final int pageIndex;
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const VerdiScreen(this.pageIndex, this.title, this.icon, this.activeIcon);

  static VerdiScreen fromIndex(int idx) {
    return VerdiScreen.values.firstWhere(
      (s) => s.pageIndex == idx,
      orElse: () => VerdiScreen.home,
    );
  }
}
