import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'features/admin/presentation/admin_dashboard_page.dart';
import 'features/admin/presentation/admin_user_activity_page.dart';
import 'features/admin/presentation/admin_system_health_page.dart';
import 'features/chat/presentation/chats_page.dart';
import 'features/assistant/presentation/ai_copilot_page.dart';
import 'features/analytics/presentation/analytics_page.dart';
import 'features/dashboard/presentation/dashboard_page.dart';
import 'features/drone_inspection/presentation/drone_inspection_view.dart';
import 'features/farm_operations/presentation/farm_operations_page.dart';
import 'features/finance/presentation/finance_page.dart';
import 'features/geospatial/presentation/geospatial_page.dart';
import 'features/government/presentation/government_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/irrigation/presentation/farmer_irrigation_view.dart';
import 'features/irrigation/presentation/government_irrigation_view.dart';
import 'features/logistics/presentation/verdi_logistics_master_page.dart';
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
import 'features/agri_expert/presentation/agri_expert_master_page.dart';
import 'features/community/presentation/agri_community_page.dart';
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
      const ChatsPage(), // index 2: My Chats (Direct Stakeholder Messaging)
      const AnalyticsPage(), // index 3: Analytics
      const OrdersPage(), // index 4: Orders
      const VerdiLogisticsMasterPage(), // index 5: Verdi Logistics Carrier OS
      const PaymentsPage(), // index 6: Payments
      const NotificationCenterPage(), // index 7: Notifications
      const GovernmentIrrigationView(), // index 8: Irrigation
      const FarmerIrrigationView(), // index 9: Farmer Irrigation
      const DroneInspectionView(), // index 10: Drone Inspection
      const FarmOperationsPage(), // index 11: Farm Operations & Agronomy Hub
      const DashboardPage(), // index 12: Dashboard
      const GeospatialPage(), // index 13: Geospatial
      const FarmOperationsPage(), // index 14: Crop Health (Merged into Farm Operations & Agronomy Hub)
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
      const AiCopilotPage(), // index 28: Sovereign AI Agronomist Copilot
      const AgriExpertMasterPage(), // index 29: Agri-Expert Master Console
      const AgriCommunityPage(), // index 30: Agri-Community Hub
    ];

    final isTransporter = state.role == UserRole.transporter;
    final isExpert = state.role == UserRole.expert;
    final effectiveNavIndex = (isTransporter && state.navIndex == 0)
        ? 5
        : (isExpert && state.navIndex == 0)
            ? 29
            : state.navIndex;

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

          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (isDesktop) {
            return GlobalVoiceAgentOverlay(
              child: Scaffold(
                backgroundColor: isDark ? const Color(0xFF070B12) : const Color(0xFFF8FAFC),
                body: Row(
                  children: [
                    sidebar,
                    VerticalDivider(width: 1, color: isDark ? const Color(0xFF1E293B) : Colors.black12),
                    Expanded(
                      child: IndexedStack(index: effectiveNavIndex, children: pages),
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
              leading: state.navIndex != 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => notifier.setNavIndex(0),
                      tooltip: 'Return to Home',
                    )
                  : Builder(
                      builder: (scaffoldContext) => IconButton(
                        icon: const Icon(Icons.menu),
                        tooltip: 'All Modules',
                        onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                      ),
                    ),
              title: Text(
                currentScreenTitle,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold),
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
                      tooltip: 'Notifications',
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
                if (state.navIndex != 0)
                  Builder(
                    builder: (scaffoldContext) => IconButton(
                      icon: const Icon(Icons.grid_view_outlined),
                      tooltip: 'All Modules',
                      onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                    ),
                  ),
              ],
            ),
            drawer: Drawer(child: sidebar),
            body: IndexedStack(index: effectiveNavIndex, children: pages),
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
    _SidebarMenuItem(index: 5, label: 'Verdi Logistics OS', icon: LucideIcons.truck),
    _SidebarMenuItem(index: 6, label: 'Payments', icon: LucideIcons.creditCard),
    _SidebarMenuItem(index: 7, label: 'Notifications', icon: LucideIcons.bell),
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
    _SidebarMenuItem(index: 29, label: 'Agri-Expert Console', icon: LucideIcons.stethoscope),
    _SidebarMenuItem(index: 30, label: 'Community Hub', icon: LucideIcons.users),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final role = appState.role;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final userName = user?.fullName ?? 'Operator';
    final userEmail = user?.email ?? 'operator@verdi.co';

    if (role == UserRole.transporter) {
      return _buildTransporterSidebar(context, ref, appState, authState);
    }

    final isCreatorAdmin = user?.id == 'admin_creator' || user?.email == 'creator@verdi.ag';

    // Filter items based on stakeholder role visibility rules:
    final filteredItems = _sidebarItems.where((item) {
      if (role == UserRole.admin) return true;
      if (isCreatorAdmin && item.index == 23) return true;

      // Exclude Marketplace (1) and Chats (2) for Financier role for focused institutional operating view
      if (role == UserRole.financier && (item.index == 1 || item.index == 2)) {
        return false;
      }

      // Shared/Universal modules: Home, Marketplace, My Chats, Settings, Community Hub
      if (item.index == 0 ||
          item.index == 1 ||
          item.index == 2 ||
          item.index == 21 ||
          item.index == 30) {
        return true;
      }

      switch (role) {
        case UserRole.farmer:
          return item.index == 7 ||
              item.index == 11 ||
              item.index == 13 ||
              item.index == 17 ||
              item.index == 20 ||
              item.index == 24;

        case UserRole.expert:
          return item.index == 29 ||
              item.index == 7 ||
              item.index == 11 ||
              item.index == 14 ||
              item.index == 17 ||
              item.index == 20 ||
              item.index == 24;

        case UserRole.buyer:
          // Commercial Buyer (B2B): Analytics (3), Orders (4), Payments (6), Traceability (15), Trade (19)
          return item.index == 3 || item.index == 4 || item.index == 6 || item.index == 15 || item.index == 19;

        case UserRole.consumer:
          // Consumer (End-User): Orders (4), Payments (6)
          return item.index == 4 || item.index == 6;

        case UserRole.financier:
          return item.index == 3 || item.index == 6 || item.index == 16;

        case UserRole.government:
          return item.index == 3 || item.index == 7 || item.index == 17 || item.index == 18 || item.index == 20 || item.index == 24;

        case UserRole.valueAdder:
          return item.index == 3 || item.index == 4 || item.index == 6 || item.index == 16 || item.index == 25;

        default:
          return false;
      }
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final sidebarDivider = isDark ? const Color(0xFF1E293B) : Colors.black12;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: 260,
      color: sidebarBg,
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
                          color: primaryTextColor,
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
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Active Mode Status Badge (Configured on Auth Screen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: ref.watch(isDemoModeProvider)
                        ? (isDark ? const Color(0xFF16A34A).withOpacity(0.18) : const Color(0xFF16A34A).withOpacity(0.08))
                        : (isDark ? const Color(0xFF1E293B) : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ref.watch(isDemoModeProvider)
                          ? (isDark ? const Color(0xFF16A34A).withOpacity(0.4) : const Color(0xFF16A34A).withOpacity(0.3))
                          : (isDark ? const Color(0xFF334155) : Colors.blue.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ref.watch(isDemoModeProvider) ? Icons.science_outlined : Icons.cloud_done_outlined,
                        size: 18,
                        color: ref.watch(isDemoModeProvider)
                            ? const Color(0xFF16A34A)
                            : (isDark ? const Color(0xFF60A5FA) : Colors.blue.shade700),
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
                                    : (isDark ? Colors.white : Colors.blue.shade900),
                              ),
                            ),
                            Text(
                              ref.watch(isDemoModeProvider) ? 'Configured at Login' : 'Connected to live database',
                              style: GoogleFonts.inter(fontSize: 9.5, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
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
          Divider(height: 1, color: sidebarDivider),
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
          Divider(height: 1, color: sidebarDivider),
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
                            child: const Text('Upgrade to Pro'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16A34A), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                      child: Icon(
                        Icons.help_outline,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help? Contact support',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'support@verdi.co • +263 78 323 7918',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.red.shade400 : Colors.red.shade600,
                      side: BorderSide(color: isDark ? Colors.red.shade900 : Colors.red.shade200),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedIndex == index;
    final activeBgColor = isDark
        ? const Color(0xFF16A34A).withOpacity(0.2)
        : const Color(0xFF16A34A).withValues(alpha: 0.15);

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
          color: isSelected
              ? const Color(0xFF16A34A)
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          size: 20,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF16A34A)
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
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

  Widget _buildTransporterSidebar(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
    AuthState authState,
  ) {
    final user = authState.user;
    final userName = user?.fullName ?? 'Carrier Fleet Operator';
    final effectiveIndex = (selectedIndex == 0) ? 5 : selectedIndex;

    const bgDark = Color(0xFF060B14);
    const cardDark = Color(0xFF0D1626);
    const cardBorder = Color(0xFF1E293B);
    const amber = Color(0xFFFF9F1C);
    const cyan = Color(0xFF00F0FF);
    const textMuted = Color(0xFF94A3B8);

    final transporterItems = [
      const _SidebarMenuItem(index: 5, label: 'Carrier Console', icon: LucideIcons.truck),
      const _SidebarMenuItem(index: 4, label: 'Waybills & Dispatches', icon: LucideIcons.fileText),
      const _SidebarMenuItem(index: 6, label: 'Fuel & Toll Settlements', icon: LucideIcons.creditCard),
      const _SidebarMenuItem(index: 7, label: 'Fleet Telemetry Alerts', icon: LucideIcons.bell),
    ];

    return Container(
      width: 265,
      decoration: const BoxDecoration(
        color: bgDark,
        border: Border(right: BorderSide(color: cardBorder, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transporter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: amber.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: amber.withOpacity(0.4)),
                      ),
                      child: const Icon(LucideIcons.truck, color: amber, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'SADC CARRIER FLEET',
                                style: TextStyle(color: Color(0xFF10B981), fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Mode Status Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ref.watch(isDemoModeProvider) ? amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ref.watch(isDemoModeProvider) ? Icons.science_outlined : Icons.cloud_done_outlined,
                        size: 16,
                        color: ref.watch(isDemoModeProvider) ? amber : Colors.blue.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(isDemoModeProvider) ? 'Mode: Offline Demo' : 'Mode: Live Real Network',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: ref.watch(isDemoModeProvider) ? amber : Colors.blue.shade300,
                              ),
                            ),
                            Text(
                              ref.watch(isDemoModeProvider) ? 'Telemetry Sandbox' : 'Connected to Fleet GPS',
                              style: const TextStyle(fontSize: 9, color: textMuted),
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
          const Divider(height: 1, color: cardBorder),
          const SizedBox(height: 12),

          // Primary Navigation Menu
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                for (final item in transporterItems) ...[
                  _buildTransporterMenuItem(
                    context,
                    index: item.index,
                    label: item.label,
                    icon: item.icon,
                    isSelected: effectiveIndex == item.index,
                    badge: item.index == 7 ? notificationBadge : item.badge,
                  ),
                ],
                const SizedBox(height: 14),

                // Special Glassmorphism "More Options" Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _showTransporterMoreOptionsModal(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0D1626).withOpacity(0.9),
                              const Color(0xFF1E293B).withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cyan.withOpacity(0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cyan.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: cyan.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.layoutGrid, color: cyan, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'More Options',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Cargo, Trace & Settings',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: cyan),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: cardBorder),

          // Transporter Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // In-Transit Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.satellite, size: 14, color: cyan),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Carrier GPS Telemetry Active',
                          style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Sign Out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout, size: 15),
                    label: const Text('Sign Out', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4)),
                      backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
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

  Widget _buildTransporterMenuItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    String? badge,
  }) {
    const amber = Color(0xFFFF9F1C);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? amber.withOpacity(0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: amber.withOpacity(0.4)) : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        onTap: () => onSelect(index),
        leading: Icon(
          icon,
          color: isSelected ? amber : const Color(0xFF94A3B8),
          size: 18,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? amber : Colors.white,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF060B14),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _showTransporterMoreOptionsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF060B14).withOpacity(0.94),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, spreadRadius: 5),
                BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.15), blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F0FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.layoutGrid, color: Color(0xFF00F0FF), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Transporter Command Desk', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                            const Text('Extended carrier modules & utility tools', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF1E293B), height: 1),
                const SizedBox(height: 16),

                _buildTransporterModalOption(
                  icon: LucideIcons.store,
                  iconColor: const Color(0xFFFF9F1C),
                  title: 'Freight & Commodity Marketplace',
                  subtitle: 'Source backhaul cargo loads, farmgate harvest lots & grain tenders',
                  badge: 'CARGO SOURCE',
                  badgeColor: const Color(0xFFFF9F1C),
                  onTap: () {
                    Navigator.pop(dialogCtx);
                    onSelect(1); // Marketplace
                  },
                ),
                const SizedBox(height: 12),

                _buildTransporterModalOption(
                  icon: LucideIcons.link,
                  iconColor: const Color(0xFF00F0FF),
                  title: 'Cargo Traceability & Chain of Custody',
                  subtitle: 'Audit temperature logs, digital seals, e-POD & bill of lading proofs',
                  badge: 'COLD-CHAIN',
                  badgeColor: const Color(0xFF00F0FF),
                  onTap: () {
                    Navigator.pop(dialogCtx);
                    onSelect(15); // Traceability
                  },
                ),
                const SizedBox(height: 12),

                _buildTransporterModalOption(
                  icon: LucideIcons.messageCircle,
                  iconColor: const Color(0xFF10B981),
                  title: 'Carrier Support & Dispatch Comms',
                  subtitle: 'Direct real-time driver coordination, farmer comms & dispatch channels',
                  badge: '3 LIVE',
                  badgeColor: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(dialogCtx);
                    onSelect(2); // Chats
                  },
                ),
                const SizedBox(height: 12),

                _buildTransporterModalOption(
                  icon: LucideIcons.settings,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Carrier Profile, Truck KYC & Fleet Settings',
                  subtitle: 'Manage SADC cross-border permits, driver licenses & GPS telematics tokens',
                  badge: 'FLEET KYC',
                  badgeColor: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.pop(dialogCtx);
                    onSelect(21); // Settings
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransporterModalOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1626),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: badgeColor.withOpacity(0.4)),
                          ),
                          child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
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
