import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'features/admin/presentation/admin_dashboard_page.dart';
import 'features/admin/presentation/admin_user_activity_page.dart';
import 'features/admin/presentation/admin_system_health_page.dart';
import 'features/ai_assistant/presentation/ai_assistant_page.dart';
import 'features/analytics/presentation/analytics_page.dart';
import 'features/crop_health/presentation/crop_health_page.dart';
import 'features/dashboard/presentation/dashboard_page.dart';
import 'features/drone_inspection/presentation/drone_inspection_view.dart';
import 'features/farm_operations/presentation/farm_operations_page.dart';
import 'features/finance/presentation/finance_page.dart';
import 'features/geospatial/presentation/geospatial_page.dart';
import 'features/government/presentation/government_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/irrigation/presentation/farmer_irrigation_view.dart';
import 'features/irrigation/presentation/government_irrigation_view.dart';
import 'features/logistics/presentation/logistics_page.dart';
import 'features/marketplace/presentation/marketplace_page.dart';
import 'features/notifications/presentation/notification_center_page.dart';
import 'features/orders/presentation/orders_page.dart';
import 'features/payments/presentation/payments_page.dart';
import 'features/satellite/presentation/satellites_page.dart';
import 'features/settings/presentation/settings_page.dart';
import 'features/export/presentation/export_page.dart';
import 'features/trade/presentation/trade_page.dart';
import 'features/traceability/presentation/traceability_page.dart';
import 'features/weather/data/mock_weather_repository.dart';
import 'features/weather/presentation/weather_page.dart';
import 'features/weather/presentation/weather_provider.dart';
import 'features/news/presentation/news_page.dart';
import 'features/processing/presentation/value_adder_processing_page.dart';
import 'features/assistant/presentation/widgets/global_voice_agent_overlay.dart';
import 'core/enums/verdi_screen.dart';
import 'state/app_state.dart';
import 'features/auth/state/auth_state.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final pages = [
      const HomePage(), // index 0: Home
      const MarketplacePage(), // index 1: Marketplace
      const AssistantPage(), // index 2: Chats (AI Assistant)
      const AnalyticsPage(), // index 3: Analytics
      const OrdersPage(), // index 4: Orders
      const LogisticsPage(), // index 5: Logistics
      const PaymentsPage(), // index 6: Payments
      const NotificationCenterPage(), // index 7: Notifications
      const GovernmentIrrigationView(), // index 8: Irrigation
      const FarmerIrrigationView(), // index 9: Farmer Irrigation
      const DroneInspectionView(), // index 10: Drone Inspection
      const FarmOperationsPage(), // index 11: Farm Operations
      const DashboardPage(), // index 12: Dashboard
      const GeospatialPage(), // index 13: Geospatial
      const CropHealthPage(), // index 14: Crop Health
      const TraceabilityPage(), // index 15: Traceability
      const FinancePage(), // index 16: Finance
      const WeatherPage(), // index 17: Weather
      const GovernmentPage(), // index 18: Government
      const TradePage(), // index 19: Trade
      const SatellitesPage(), // index 20: Satellite
      const SettingsPage(), // index 21: Settings
      const ExportPage(), // index 22: Export & Trade Layer
      const AdminDashboardPage(), // index 23: Admin Command Center
      const NewsPage(), // index 24: Southern African Agri-News
      const ValueAdderProcessingPage(), // index 25: Value Addition Hub
      const AdminUserActivityPage(), // index 26: User Activities & System Audit Logs
      const AdminSystemHealthPage(), // index 27: System Health & Infrastructure Telemetry
    ];

    return ChangeNotifierProvider<WeatherProvider>(
      create: (_) {
        final provider = WeatherProvider(repository: MockWeatherRepository());
        provider.loadWeather();
        return provider;
      },
      child: Builder(
        builder: (context) {
          final alertCount =
              context.watch<WeatherProvider>().weather?.alerts.length ?? 0;
          final sidebar = Sidebar(
            selectedIndex: state.navIndex,
            notificationBadge: alertCount > 0 ? '$alertCount' : null,
            onSelect: (index) {
              notifier.setNavIndex(index);
              if (!isDesktop) {
                Navigator.pop(context); // Close drawer on mobile
              }
            },
          );

          if (isDesktop) {
            return GlobalVoiceAgentOverlay(
              child: Scaffold(
                body: Row(
                  children: [
                    sidebar,
                    const VerticalDivider(width: 1, color: Colors.black12),
                    Expanded(
                      child: IndexedStack(index: state.navIndex, children: pages),
                    ),
                  ],
                ),
              ),
            );
          }

          final currentScreenTitle = VerdiScreen.fromIndex(state.navIndex).title;

          return GlobalVoiceAgentOverlay(
            child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  if (state.navIndex != 0) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () => notifier.setNavIndex(0),
                      tooltip: 'Return to Home',
                    ),
                    const SizedBox(width: 2),
                  ],
                  Expanded(
                    child: Text(
                      currentScreenTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        notifier.setNavIndex(7); // Go to notifications/alerts
                      },
                      icon: const Icon(Icons.notifications_none_outlined),
                    ),
                    if (alertCount > 0)
                      Positioned(
                        right: 6,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            '$alertCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Builder(
                  builder: (scaffoldContext) => IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: 'All Modules',
                    onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                  ),
                ),
              ],
            ),
            drawer: Drawer(child: sidebar),
            body: IndexedStack(index: state.navIndex, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: state.navIndex > 3 ? 0 : state.navIndex,
              onDestinationSelected: (idx) {
                if (idx == 3) {
                  // Open full drawer menu for all modules
                  Scaffold.of(context).openDrawer();
                } else {
                  notifier.setNavIndex(idx);
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'Market',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Modules',
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}

class Sidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? notificationBadge;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.notificationBadge,
  });

  static const _sidebarItems = [
    _SidebarMenuItem(index: 0, label: 'Home', icon: LucideIcons.home),
    _SidebarMenuItem(index: 1, label: 'Marketplace', icon: LucideIcons.store),
    _SidebarMenuItem(
      index: 2,
      label: 'My Chats',
      icon: LucideIcons.messageCircle,
      badge: '3',
    ),
    _SidebarMenuItem(index: 3, label: 'Analytics', icon: LucideIcons.barChart3),
    _SidebarMenuItem(index: 4, label: 'Orders', icon: LucideIcons.shoppingCart),
    _SidebarMenuItem(index: 5, label: 'Fleet & Transport Hub', icon: LucideIcons.truck),
    _SidebarMenuItem(index: 6, label: 'Payments', icon: LucideIcons.creditCard),
    _SidebarMenuItem(index: 7, label: 'Notifications', icon: LucideIcons.bell),
    _SidebarMenuItem(
      index: 10,
      label: 'Drone Inspection',
      icon: LucideIcons.airplay,
    ),
    _SidebarMenuItem(
      index: 11,
      label: 'Farm Operations',
      icon: LucideIcons.hammer,
    ),
    _SidebarMenuItem(index: 13, label: 'Geospatial', icon: LucideIcons.map),
    _SidebarMenuItem(index: 14, label: 'Crop Health', icon: LucideIcons.leaf),
    _SidebarMenuItem(index: 15, label: 'Traceability', icon: LucideIcons.link),
    _SidebarMenuItem(index: 16, label: 'Finance', icon: LucideIcons.dollarSign),
    _SidebarMenuItem(index: 17, label: 'Weather', icon: LucideIcons.cloud),
    _SidebarMenuItem(
      index: 18,
      label: 'Government',
      icon: LucideIcons.building2,
    ),
    _SidebarMenuItem(index: 19, label: 'Trade', icon: LucideIcons.briefcase),
    _SidebarMenuItem(
      index: 20,
      label: 'Satellite',
      icon: LucideIcons.satellite,
    ),
    _SidebarMenuItem(index: 21, label: 'Settings', icon: LucideIcons.settings),
    _SidebarMenuItem(index: 22, label: 'Export', icon: LucideIcons.packageOpen),
    _SidebarMenuItem(index: 23, label: 'Admin Command Center', icon: LucideIcons.shieldAlert),
    _SidebarMenuItem(index: 24, label: 'News', icon: LucideIcons.newspaper),
    _SidebarMenuItem(index: 25, label: 'Value Addition Hub', icon: LucideIcons.factory),
    _SidebarMenuItem(index: 26, label: 'User Activities & Logs', icon: LucideIcons.history),
    _SidebarMenuItem(index: 27, label: 'System Health & Services', icon: LucideIcons.activity),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appStateProvider).role;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final userName = user?.fullName ?? 'Operator';
    final userEmail = user?.email ?? 'operator@verdi.co';

    // Filter items based on stakeholder role visibility rules:
    final filteredItems = _sidebarItems.where((item) {
      if (role == UserRole.admin) return true;

      // Shared/Universal modules
      if (item.index == 0 ||
          item.index == 1 ||
          item.index == 2 ||
          item.index == 7 ||
          item.index == 21 ||
          item.index == 24) {
        return true;
      }

      switch (role) {
        case UserRole.farmer:
        case UserRole.expert:
          return item.index == 10 ||
              item.index == 13 ||
              item.index == 14 ||
              item.index == 17 ||
              item.index == 20;

        case UserRole.transporter:
          return item.index == 4 || item.index == 5 || item.index == 15;

        case UserRole.buyer:
          return item.index == 4 || item.index == 15 || item.index == 19;

        case UserRole.financier:
          return item.index == 6 || item.index == 16;

        case UserRole.government:
          return item.index == 3 || item.index == 17 || item.index == 18 || item.index == 20;

        case UserRole.valueAdder:
          return item.index == 4 || item.index == 6 || item.index == 16 || item.index == 25;

        case UserRole.consumer:
          return item.index == 4;

        default:
          return false;
      }
    }).toList();

    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      role.icon,
                      color: const Color(0xFF16A34A),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${role.label} • $userEmail',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                // Active Mode Status Badge (Configured on Auth Screen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: ref.watch(isDemoModeProvider)
                        ? const Color(0xFF16A34A).withValues(alpha: 0.08)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ref.watch(isDemoModeProvider)
                          ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ref.watch(isDemoModeProvider) ? Icons.science_outlined : Icons.cloud_done_outlined,
                        size: 18,
                        color: ref.watch(isDemoModeProvider)
                            ? const Color(0xFF16A34A)
                            : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(isDemoModeProvider) ? 'Mode: Offline Demo' : 'Mode: Live Real Network',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: ref.watch(isDemoModeProvider)
                                    ? const Color(0xFF16A34A)
                                    : Colors.blue.shade900,
                              ),
                            ),
                            Text(
                              ref.watch(isDemoModeProvider) ? 'Configured at Login' : 'Connected to live database',
                              style: GoogleFonts.inter(fontSize: 9.5, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: filteredItems
                  .map(
                    (item) => _buildMenuItem(
                      context,
                      index: item.index,
                      label: item.label,
                      icon: item.icon,
                      badge: item.index == 7 ? notificationBadge : item.badge,
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.stars, color: Colors.amber, size: 28),
                            SizedBox(width: 8),
                            Text('Verdi Pro Benefits'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Unlock premium features for advanced farming & logistics:',
                            ),
                            SizedBox(height: 12),
                            _ProFeature(
                              icon: Icons.analytics_outlined,
                              text: 'Unlimited deep analytics reports',
                            ),
                            _ProFeature(
                              icon: Icons.map_outlined,
                              text: 'Priority regional buyer map routing',
                            ),
                            _ProFeature(
                              icon: Icons.support_agent,
                              text: '24/7 Premium agent support',
                            ),
                            _ProFeature(
                              icon: Icons.flash_on,
                              text:
                                  'Instantly request matching logistics dispatch',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Verdi Pro activated successfully! 🎉',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Activate - \$9.99/mo'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16A34A), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Unlock Verdi Pro',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Get unlimited deep insights',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade100,
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Need help? Contact support',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'support@verdi.co • +263 78 323 7918',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = selectedIndex == index;
    final activeBgColor = const Color(0xFF16A34A).withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? activeBgColor : Colors.transparent,
        border: isSelected
            ? const Border(left: BorderSide(color: Color(0xFF16A34A), width: 3))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        onTap: () => onSelect(index),
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B),
          size: 20,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF16A34A)
                : const Color(0xFF0F172A),
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _SidebarMenuItem {
  final int index;
  final String label;
  final IconData icon;
  final String? badge;

  const _SidebarMenuItem({
    required this.index,
    required this.label,
    required this.icon,
    this.badge,
  });
}

class _ProFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF16A34A)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
