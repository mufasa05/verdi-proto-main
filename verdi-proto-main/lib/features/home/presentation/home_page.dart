import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/mock_app_data.dart';
import '../../../state/app_state.dart';
import '../../auth/state/auth_state.dart';
import '../../admin/presentation/admin_dashboard_page.dart';
import '../../admin/presentation/infrastructure_modules_control_page.dart';
import '../../admin/presentation/user_identity_control_page.dart';
import 'widgets/home_header.dart';
import 'widgets/home_insight_strip.dart';
import 'widgets/ask_verdi_fab.dart';

/// Clean Command Center Home Page.
/// Reduces clutter by 60% with a strict 3-Section layout:
/// Section 1: Priority Queue (Urgent 24h Action items)
/// Section 2: Quick Actions Grid (2x2 Grid customized by UserRole)
/// Section 3: Collapsible Accordions (Market Pulse, Activity, Logistics)
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const cream = Color(0xFFF8FAFC);
  static const muted = Color(0xFF64748B);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isMarketPulseExpanded = false;
  bool _isRecentActivityExpanded = false;
  bool _isLogisticsExpanded = false;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(appStateProvider.select((s) => s.role));
    final userName = ref.watch(authStateProvider.select((a) => a.user?.fullName ?? MockAppData.farmerName));
    final roleLabel = role.label;

    return Scaffold(
      backgroundColor: HomePage.cream,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AskVerdiFab(
        onNavigate: (screen) {
          ref.read(appStateProvider.notifier).setNavIndex(screen.pageIndex);
        },
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: MediaQuery.of(context).size.width < 600
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───────────────────────────────────────────────────────────
                  // TOP HEADER
                  // ───────────────────────────────────────────────────────────
                  HomeHeader(
                    greeting: _greeting(),
                    farmerName: userName,
                    location: MockAppData.location,
                    roleLabel: roleLabel,
                  ),
                  const SizedBox(height: 20),

                  // ───────────────────────────────────────────────────────────
                  // INTELLIGENCE CENTER (For All Roles)
                  // ───────────────────────────────────────────────────────────
                  _buildSectionTitle(
                    'INTELLIGENCE CENTER',
                    'AI-driven suggestions & platform observations',
                    Icons.psychology_outlined,
                    const Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: 12),
                  const HomeInsightStrip(),
                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // SECTION 1: PRIORITY QUEUE (Full Width - Max 4 Cards)
                  // ───────────────────────────────────────────────────────────
                  _buildSectionTitle(
                    'PRIORITY QUEUE',
                    'Requires action in the next 24 hours',
                    Icons.warning_amber_rounded,
                    const Color(0xFFDC2626),
                  ),
                  const SizedBox(height: 12),
                  _PriorityQueueSection(role: role),
                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // SECTION 2: QUICK ACTIONS (2x2 Grid - Role Specific)
                  // ───────────────────────────────────────────────────────────
                  _buildSectionTitle(
                    'QUICK ACTIONS',
                    'Operational shortcuts for $roleLabel role',
                    Icons.bolt,
                    HomePage.green,
                  ),
                  const SizedBox(height: 12),
                  _RoleQuickActionsGrid(role: role),
                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // SECTION 3: COLLAPSIBLE ACCORDIONS
                  // ───────────────────────────────────────────────────────────
                  _buildSectionTitle(
                    'PLATFORM SUMMARY & MODULE DRAWERS',
                    'Expand for live market, activity timeline, and logistics',
                    Icons.grid_view_rounded,
                    HomePage.dark,
                  ),
                  const SizedBox(height: 12),

                  // Accordion 1: Market Pulse
                  _AccordionTile(
                    title: 'Market Pulse',
                    subtitle: 'Tomatoes \$1.54/kg ↑12% • White Maize \$280/Ton',
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF16A34A),
                    isExpanded: _isMarketPulseExpanded,
                    onToggle: () => setState(() => _isMarketPulseExpanded = !_isMarketPulseExpanded),
                    actionButtonLabel: 'View Trade Hub',
                    onAction: () => ref.read(appStateProvider.notifier).setNavIndex(19),
                    child: _buildMarketPulseContent(),
                  ),
                  const SizedBox(height: 10),

                  // Accordion 2: Recent Activity
                  _AccordionTile(
                    title: 'Recent Platform Activity',
                    subtitle: '3 chronological system items recorded recently',
                    icon: Icons.history_rounded,
                    iconColor: const Color(0xFF2563EB),
                    isExpanded: _isRecentActivityExpanded,
                    onToggle: () => setState(() => _isRecentActivityExpanded = !_isRecentActivityExpanded),
                    actionButtonLabel: 'View All Logs',
                    onAction: () => ref.read(appStateProvider.notifier).setNavIndex(11),
                    child: _buildRecentActivityContent(),
                  ),
                  const SizedBox(height: 10),

                  // Accordion 3: Nearby Logistics
                  _AccordionTile(
                    title: 'Nearby Logistics Hub',
                    subtitle: '4 fleet transport trucks available in Chiredzi',
                    icon: Icons.local_shipping_outlined,
                    iconColor: const Color(0xFFF97316),
                    isExpanded: _isLogisticsExpanded,
                    onToggle: () => setState(() => _isLogisticsExpanded = !_isLogisticsExpanded),
                    actionButtonLabel: 'Open Logistics Hub',
                    onAction: () => ref.read(appStateProvider.notifier).setNavIndex(5),
                    child: _buildLogisticsContent(),
                  ),

                  const SizedBox(height: 90), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: HomePage.dark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '•  $subtitle',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: HomePage.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketPulseContent() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildMarketPulseRow('Tomatoes (Auction)', '\$1.54 / kg', '+12.4%', true),
        _buildMarketPulseRow('White Maize (Bulk)', '\$280.00 / Ton', '+4.2%', true),
        _buildMarketPulseRow('Soybeans (Grade A)', '\$410.00 / Ton', '-1.5%', false),
        _buildMarketPulseRow('Hass Avocados (Export)', '\$3.20 / kg', '+8.0%', true),
      ],
    );
  }

  Widget _buildMarketPulseRow(String name, String price, String change, bool isUp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: HomePage.dark)),
          Row(
            children: [
              Text(price, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: HomePage.dark)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isUp ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUp ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityContent() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildActivityItem('Solenoid Valve 2 activated', 'Automated moisture maintenance triggered in Zone 4', '12m ago', Icons.water_drop_outlined, const Color(0xFF2563EB)),
        _buildActivityItem('Drone inspection uploaded', '12 crop health zones processed with multispectral overlays', '1h ago', Icons.airplay, const Color(0xFF7C3AED)),
        _buildActivityItem('Export certificate generated', 'Traceability cert verified for export batch EXP-002', '4h ago', Icons.verified_outlined, const Color(0xFF16A34A)),
      ],
    );
  }

  Widget _buildActivityItem(String title, String desc, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: HomePage.dark)),
                Text(desc, style: GoogleFonts.inter(fontSize: 11, color: HomePage.muted)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 10.5, color: HomePage.muted)),
        ],
      ),
    );
  }

  Widget _buildLogisticsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildTruckRow('Tafadzwa M.', 'Heavy Cargo Truck (12 Tonnes)', '\$0.20/km', 'Ready in 20 mins'),
        _buildTruckRow('Moses K.', 'Flatbed Trailer (24 Tonnes)', '\$0.35/km', 'Ready in 35 mins'),
        _buildTruckRow('Chipo D.', 'Refrigerated Van (4 Tonnes)', '\$0.15/km', 'Ready in 10 mins'),
      ],
    );
  }

  Widget _buildTruckRow(String driver, String type, String rate, String eta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(driver, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: HomePage.dark)),
              Text(type, style: GoogleFonts.inter(fontSize: 11, color: HomePage.muted)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rate, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A))),
              Text(eta, style: GoogleFonts.inter(fontSize: 10.5, color: HomePage.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 WIDGET: PRIORITY QUEUE (Max 4 Cards)
// ─────────────────────────────────────────────────────────────────────────────
class _PriorityQueueSection extends ConsumerWidget {
  final UserRole role;

  const _PriorityQueueSection({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = _getPriorityCards(context, ref, role);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 750;

        return isDesktop
            ? Row(
                children: cards
                    .map((c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: c,
                          ),
                        ))
                    .toList(),
              )
            : Column(
                children: cards
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: c,
                        ))
                    .toList(),
              );
      },
    );
  }

  List<Widget> _getPriorityCards(BuildContext context, WidgetRef ref, UserRole role) {
    final notifier = ref.read(appStateProvider.notifier);

    if (role == UserRole.expert) {
      return [
        _PriorityCard(
          badgeLabel: 'HIGH PRIO',
          badgeColor: const Color(0xFFDC2626),
          title: '2 Pending Advisory Reports',
          subtitle: 'Field diagnostics for Chiredzi East tomato growers',
          buttonLabel: 'Start Report',
          onTap: () => notifier.setNavIndex(2),
        ),
        _PriorityCard(
          badgeLabel: 'CRITICAL',
          badgeColor: const Color(0xFFEA580C),
          title: '1 Critical Alert Raised',
          subtitle: 'Solenoid Valve 2 pressure drop below 2.0 bar',
          buttonLabel: 'Inspect Alert',
          onTap: () => notifier.setNavIndex(7),
        ),
        _PriorityCard(
          badgeLabel: 'HIGH DEMAND',
          badgeColor: const Color(0xFF16A34A),
          title: '3 Buyer Tomato Requests',
          subtitle: 'High demand reported near your zone in Chiredzi',
          buttonLabel: 'View Buyers',
          onTap: () => notifier.setNavIndex(1),
        ),
        _PriorityCard(
          badgeLabel: '92% DRAFT',
          badgeColor: const Color(0xFF2563EB),
          title: 'Resume Irrigation Schedule',
          subtitle: 'East Block Maize draft schedule ready for review',
          buttonLabel: 'Resume Draft',
          onTap: () => notifier.setNavIndex(9),
        ),
      ];
    }

    if (role == UserRole.farmer) {
      return [
        _PriorityCard(
          badgeLabel: 'URGENT',
          badgeColor: const Color(0xFFDC2626),
          title: 'Zone 4 Moisture Low (28%)',
          subtitle: 'Maize crop needs 45 min smart irrigation cycle',
          buttonLabel: 'Start Irrigation',
          onTap: () => notifier.setNavIndex(9),
        ),
        _PriorityCard(
          badgeLabel: 'PRICE ALERT',
          badgeColor: const Color(0xFF16A34A),
          title: 'Tomatoes Up +12.4%',
          subtitle: 'Harare Mbare auction prices at \$1.54/kg peak',
          buttonLabel: 'View Prices',
          onTap: () => notifier.setNavIndex(19),
        ),
        _PriorityCard(
          badgeLabel: 'WEATHER',
          badgeColor: const Color(0xFF2563EB),
          title: '18mm Heavy Rain Expected',
          subtitle: 'Precipitation expected over Chiredzi in 24 hours',
          buttonLabel: 'Weather Radar',
          onTap: () => notifier.setNavIndex(17),
        ),
      ];
    }

    // Default / Buyer / Other roles fallback cards
    return [
      _PriorityCard(
        badgeLabel: 'ACTION NEEDED',
        badgeColor: const Color(0xFF2563EB),
        title: 'Active Orders & Dispatch',
        subtitle: '1 shipment in transit via Verdi Logistics',
        buttonLabel: 'Track Shipment',
        onTap: () => notifier.setNavIndex(4),
      ),
      _PriorityCard(
        badgeLabel: 'MARKET DEMAND',
        badgeColor: const Color(0xFF16A34A),
        title: 'Fresh Produce In Stock',
        subtitle: '500kg NPK Fertilizer and Seeds ready for pickup',
        buttonLabel: 'Open Store',
        onTap: () => notifier.setNavIndex(1),
      ),
    ];
  }
}

class _PriorityCard extends StatelessWidget {
  final String badgeLabel;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _PriorityCard({
    required this.badgeLabel,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeLabel,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: badgeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                buttonLabel,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 WIDGET: QUICK ACTIONS GRID (2x2 Grid - Role Specific)
// ─────────────────────────────────────────────────────────────────────────────
class _RoleQuickActionsGrid extends ConsumerWidget {
  final UserRole role;

  const _RoleQuickActionsGrid({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _getRoleActions(role);
    final notifier = ref.read(appStateProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isDesktop ? 2.2 : 1.8,
          ),
          itemBuilder: (context, i) {
            final act = actions[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  if (act.onCustomTap != null) {
                    act.onCustomTap!(context, ref);
                  } else {
                    notifier.setNavIndex(act.navIndex);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: act.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(act.icon, color: act.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              act.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              act.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<_QuickActionConfig> _getRoleActions(UserRole role) {
    if (role == UserRole.expert) {
      return const [
        _QuickActionConfig('Start Advisory Session', 'Agronomy & client chat', Icons.lightbulb_outline, Color(0xFF16A34A), 2),
        _QuickActionConfig('Scan Crop Health', 'AI disease scanner', Icons.energy_savings_leaf_outlined, Color(0xFF7C3AED), 14),
        _QuickActionConfig('Generate Field Report', 'Farm operations log', Icons.description_outlined, Color(0xFF2563EB), 11),
        _QuickActionConfig('Message 142 Farmers', 'Alerts & broad notices', Icons.forum_outlined, Color(0xFFF97316), 7),
      ];
    }

    if (role == UserRole.farmer) {
      return const [
        _QuickActionConfig('Start Smart Irrigation', 'Field A Maize watering', Icons.water_drop_outlined, Color(0xFF2563EB), 9),
        _QuickActionConfig('Check Produce Prices', 'Harare Mbare rates', Icons.trending_up, Color(0xFF16A34A), 19),
        _QuickActionConfig('Order Farm Inputs', 'Fertilizer & seeds', Icons.shopping_bag_outlined, Color(0xFFF97316), 1),
        _QuickActionConfig('View Weather Radar', 'Rainfall forecasts', Icons.cloud_outlined, Color(0xFF0F766E), 17),
      ];
    }

    if (role == UserRole.buyer) {
      return const [
        _QuickActionConfig('Browse Marketplace', 'Source raw produce', Icons.storefront_outlined, Color(0xFF16A34A), 1),
        _QuickActionConfig('Track Active Orders', 'Shipment status', Icons.local_shipping_outlined, Color(0xFF2563EB), 4),
        _QuickActionConfig('Escrow Payments', 'Secured transactions', Icons.shield_outlined, Color(0xFF7C3AED), 6),
        _QuickActionConfig('Verified Suppliers', 'Directory & ratings', Icons.people_outline, Color(0xFFF97316), 1),
      ];
    }

    if (role == UserRole.driver || role == UserRole.transporter) {
      return const [
        _QuickActionConfig('View Active Dispatch', 'Cargo transport job', Icons.navigation_outlined, Color(0xFF16A34A), 5),
        _QuickActionConfig('Update GPS Telemetry', 'Live GPS & Route tracking', Icons.pin_drop_outlined, Color(0xFF2563EB), 10),
        _QuickActionConfig('Check Driver Wallet', 'Freight payouts & earnings', Icons.account_balance_wallet_outlined, Color(0xFF7C3AED), 16),
        _QuickActionConfig('Fleet Cargo Loads', 'Available freight loads', Icons.local_shipping_outlined, Color(0xFFF97316), 5),
      ];
    }

    if (role == UserRole.government) {
      return const [
        _QuickActionConfig('Approve E-Vouchers', 'State subsidies', Icons.confirmation_number_outlined, Color(0xFF16A34A), 18),
        _QuickActionConfig('Irrigation Schemes', 'National water dams', Icons.waves_outlined, Color(0xFF2563EB), 8),
        _QuickActionConfig('ePhyto Clearances', 'Export compliance', Icons.verified_outlined, Color(0xFF7C3AED), 22),
        _QuickActionConfig('National Grain Quotas', 'GMB reserves', Icons.account_balance_outlined, Color(0xFFF97316), 18),
      ];
    }

    if (role == UserRole.admin) {
      return [
        const _QuickActionConfig('Admin Command Center', 'System control panel', Icons.admin_panel_settings_outlined, Color(0xFFDC2626), 23),
        _QuickActionConfig(
          'System Health Status',
          'Microservice status',
          Icons.memory_outlined,
          const Color(0xFF2563EB),
          23,
          onCustomTap: (context, ref) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDashboardPage(
                  initialSubPageTitle: 'Server Health & Infrastructure Telemetry',
                  initialSubPageWidget: InfrastructureModulesControlPage(),
                ),
              ),
            );
          },
        ),
        _QuickActionConfig(
          'Manage User Roles',
          'RBAC configuration',
          Icons.group_outlined,
          const Color(0xFF16A34A),
          23,
          onCustomTap: (context, ref) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDashboardPage(
                  initialSubPageTitle: 'KYC User Directory & Sovereign Privilege Manager',
                  initialSubPageWidget: UserIdentityControlPage(),
                ),
              ),
            );
          },
        ),
        const _QuickActionConfig('Platform Metrics', 'Yield & revenue analytics', Icons.insights_outlined, Color(0xFF7C3AED), 3),
      ];
    }

    // Default fallback
    return const [
      _QuickActionConfig('Marketplace Store', 'Buy & sell produce', Icons.storefront_outlined, Color(0xFF16A34A), 1),
      _QuickActionConfig('AI Voice Assistant', 'Hands-free voice AI', Icons.record_voice_over_outlined, Color(0xFF2563EB), 2),
      _QuickActionConfig('Farm Performance', 'Analytics dashboard', Icons.insights_outlined, Color(0xFF7C3AED), 3),
      _QuickActionConfig('Help & Settings', 'Preferences', Icons.settings_outlined, Color(0xFFF97316), 21),
    ];
  }
}

class _QuickActionConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int navIndex;
  final void Function(BuildContext context, WidgetRef ref)? onCustomTap;

  const _QuickActionConfig(this.title, this.subtitle, this.icon, this.color, this.navIndex, {this.onCustomTap});
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 WIDGET: COLLAPSIBLE ACCORDION TILE
// ─────────────────────────────────────────────────────────────────────────────
class _AccordionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String actionButtonLabel;
  final VoidCallback onAction;
  final Widget child;

  const _AccordionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isExpanded,
    required this.onToggle,
    required this.actionButtonLabel,
    required this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: iconColor.withOpacity(0.12),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: iconColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionButtonLabel,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
