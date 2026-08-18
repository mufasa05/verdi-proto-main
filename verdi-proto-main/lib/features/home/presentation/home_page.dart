import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../../data/mock_app_data.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';
import '../../auth/state/auth_state.dart';
import '../../admin/presentation/admin_dashboard_page.dart';
import '../../admin/presentation/user_identity_control_page.dart';
import '../../admin/presentation/admin_user_activity_page.dart';
import '../../admin/presentation/admin_system_health_page.dart';
import '../../logistics/presentation/transporter_telemetry_page.dart';
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
                  // TRANSPORTER FREIGHT MISSION CONTROL HERO (Transporter Only)
                  // ───────────────────────────────────────────────────────────
                  if (role == UserRole.transporter) ...[
                    const _TransporterHeroCommandBanner(),
                    const SizedBox(height: 24),
                  ],

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
                  HomeInsightStrip(role: role),
                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // CARGO BIDDING & FREIGHT MATCH RADAR (Transporter Only)
                  // ───────────────────────────────────────────────────────────
                  if (role == UserRole.transporter) ...[
                    _buildSectionTitle(
                      'CARGO BIDDING & FREIGHT MATCH RADAR',
                      'Live crop pickup requests from farmers & co-ops',
                      Icons.radar,
                      const Color(0xFFF97316),
                    ),
                    const SizedBox(height: 12),
                    const _CargoBiddingRadarSection(),
                    const SizedBox(height: 24),
                  ],

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
                  // ACTIVE WAYBILLS & SAFETY CHECKLIST (Transporter Only)
                  // ───────────────────────────────────────────────────────────
                  if (role == UserRole.transporter) ...[
                    _buildSectionTitle(
                      'ACTIVE FREIGHT WAYBILLS',
                      'Shipments currently assigned & in transit',
                      Icons.navigation_outlined,
                      const Color(0xFF0284C7),
                    ),
                    const SizedBox(height: 12),
                    const _ActiveWaybillsSection(),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'DRIVER PRE-TRIP SAFETY CHECKLIST',
                      'Vehicle readiness & logbook verification',
                      Icons.fact_check_outlined,
                      const Color(0xFF16A34A),
                    ),
                    const SizedBox(height: 12),
                    const _PreTripSafetyChecklistSection(),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'MY FLEET',
                      'Registered vehicles & quick registration',
                      Icons.local_shipping_outlined,
                      const Color(0xFFF97316),
                    ),
                    const SizedBox(height: 12),
                    const _FleetSection(),
                    const SizedBox(height: 24),
                  ],

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
                    subtitle: ref.watch(isDemoModeProvider)
                        ? 'Tomatoes \$1.54/kg ↑12% • White Maize \$280/Ton'
                        : 'Live market price telemetry baseline',
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF16A34A),
                    isExpanded: _isMarketPulseExpanded,
                    onToggle: () => setState(() => _isMarketPulseExpanded = !_isMarketPulseExpanded),
                    actionButtonLabel: 'View Trade Hub',
                    onAction: () => ref.read(appStateProvider.notifier).setNavIndex(19),
                    child: _buildMarketPulseContent(ref),
                  ),
                  const SizedBox(height: 10),

                  // Accordion 2: Recent Activity (Admin Only)
                  if (role == UserRole.admin) ...[
                    _AccordionTile(
                      title: 'Recent Platform Activity',
                      subtitle: ref.watch(isDemoModeProvider)
                          ? '3 chronological system items recorded recently'
                          : 'System audit log timeline',
                      icon: Icons.history_rounded,
                      iconColor: const Color(0xFF2563EB),
                      isExpanded: _isRecentActivityExpanded,
                      onToggle: () => setState(() => _isRecentActivityExpanded = !_isRecentActivityExpanded),
                      actionButtonLabel: 'View All Logs',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminUserActivityPage()),
                        );
                      },
                      child: _buildRecentActivityContent(ref),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Accordion 3: Nearby Logistics
                  _AccordionTile(
                    title: 'Nearby Logistics Hub',
                    subtitle: ref.watch(isDemoModeProvider)
                        ? '4 fleet transport trucks available in Chiredzi'
                        : '0 active transport trucks in range',
                    icon: Icons.local_shipping_outlined,
                    iconColor: const Color(0xFFF97316),
                    isExpanded: _isLogisticsExpanded,
                    onToggle: () => setState(() => _isLogisticsExpanded = !_isLogisticsExpanded),
                    actionButtonLabel: 'Open Logistics Hub',
                    onAction: () => ref.read(appStateProvider.notifier).setNavIndex(5),
                    child: _buildLogisticsContent(ref),
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

  Widget _buildMarketPulseContent(WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildMarketPulseRow('Tomatoes (Auction)', '\$1.54 / kg', '+12.4%', true),
        _buildMarketPulseRow('White Maize (Bulk)', '\$280.00 / Ton', '+4.2%', true),
        _buildMarketPulseRow('Soybeans (Grade A)', '\$410.00 / Ton', '-1.5%', false),
        _buildMarketPulseRow('Hass Avocados (Export)', '\$3.20 / kg', '+8.0%', true),
        _buildMarketPulseRow('Sugar Beans (Certified)', '\$1.20 / kg', '+5.5%', true),
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

  Widget _buildRecentActivityContent(WidgetRef ref) {
    final liveEvents = ref.watch(platformActivityProvider);
    final displayEvents = liveEvents.take(4).toList();

    if (displayEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history_toggle_off, size: 16, color: HomePage.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No live platform activities recorded yet. User actions will stream here in real time.',
                style: GoogleFonts.inter(fontSize: 12, color: HomePage.muted, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        ...displayEvents.map((evt) {
          final color = switch (evt.userRole) {
            UserRole.farmer => const Color(0xFF16A34A),
            UserRole.transporter => const Color(0xFFF97316),
            UserRole.buyer => const Color(0xFF2563EB),
            UserRole.admin => const Color(0xFF7C3AED),
            UserRole.financier => const Color(0xFF0F766E),
            _ => const Color(0xFF2563EB),
          };
          final icon = switch (evt.module.toLowerCase()) {
            'marketplace' => Icons.storefront_outlined,
            'logistics' => Icons.local_shipping_outlined,
            'payments' => Icons.payments_outlined,
            'geospatial' => Icons.map_outlined,
            _ => Icons.radar_outlined,
          };
          return _buildActivityItem(
            '${evt.userName}: ${evt.actionTitle}',
            evt.actionDescription,
            evt.timestamp,
            icon,
            color,
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserActivityPage()),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined, size: 15),
            label: Text('Open Full Platform Activity (${liveEvents.length} Live Records)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFF93C5FD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String desc, String time, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminUserActivityPage()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: HomePage.dark)),
                  Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: HomePage.muted)),
                ],
              ),
            ),
            Text(time, style: GoogleFonts.inter(fontSize: 10.5, color: HomePage.muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsContent(WidgetRef ref) {
    final trucks = ref.watch(trucksListProvider);
    final available = trucks.where((t) => t.status != 'Offline').take(3).toList();

    if (available.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined, size: 16, color: HomePage.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No transport trucks currently active in this region. Add a vehicle in the Logistics module to enable live dispatches.',
                style: GoogleFonts.inter(fontSize: 12, color: HomePage.muted, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        ...available.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: Color(0xFFF97316), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t.driver} • ${t.vehicle}', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: HomePage.dark)),
                        Text('${t.from} • ETA ${t.eta} • Rating ★${t.rating}', style: GoogleFonts.inter(fontSize: 11, color: HomePage.muted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(t.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                  ),
                ],
              ),
            )),
      ],
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
    final isDemo = ref.watch(isDemoModeProvider);
    final orders = ref.watch(ordersListProvider);
    final sessions = ref.watch(liveUserSessionsProvider);
    final onlineCount = sessions.where((s) => s.isOnline).length;
    final double liveGmv = orders.fold(0.0, (sum, o) {
      final val = double.tryParse(o.total.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      return sum + val;
    });

    if (role == UserRole.admin) {
      if (!isDemo) {
        return [
          _PriorityCard(
            badgeLabel: 'SYSTEM HEALTH',
            badgeColor: const Color(0xFF16A34A),
            title: '8 Microservices Operational',
            subtitle: 'Core API gateway, PostgreSQL & Sentinel spatial services online',
            buttonLabel: 'System Health',
            onTap: () => notifier.setNavIndex(27),
          ),
          _PriorityCard(
            badgeLabel: 'SURVEILLANCE',
            badgeColor: const Color(0xFF7C3AED),
            title: '$onlineCount Live Session${onlineCount > 1 ? "s" : ""} Monitored',
            subtitle: 'Real-time stakeholder audit bus streaming live mutations',
            buttonLabel: 'Inspect Logs',
            onTap: () => notifier.setNavIndex(26),
          ),
          _PriorityCard(
            badgeLabel: 'TRADE ESCROW',
            badgeColor: const Color(0xFF2563EB),
            title: '${orders.length} Live Trade Orders',
            subtitle: orders.isEmpty ? 'Trade pipeline active — ready for buyer orders' : 'US\$ ${liveGmv.toStringAsFixed(0)} logged in smart contract escrow',
            buttonLabel: 'Inspect Trade',
            onTap: () => notifier.setNavIndex(23),
          ),
        ];
      }
      return [
        _PriorityCard(
          badgeLabel: 'CRITICAL AUDIT',
          badgeColor: const Color(0xFFDC2626),
          title: 'Escrow Dispute #ORD-1004',
          subtitle: 'US\$ 144.00 locked — consignee weight variance flagged',
          buttonLabel: 'Review Dispute',
          onTap: () => notifier.setNavIndex(23),
        ),
        _PriorityCard(
          badgeLabel: 'SURVEILLANCE',
          badgeColor: const Color(0xFF7C3AED),
          title: '86 Active Sessions',
          subtitle: 'Multi-role presence across 8 provinces with 24ms mesh latency',
          buttonLabel: 'View Stream',
          onTap: () => notifier.setNavIndex(26),
        ),
        _PriorityCard(
          badgeLabel: 'INFRASTRUCTURE',
          badgeColor: const Color(0xFF16A34A),
          title: 'All Systems 100% OK',
          subtitle: 'SADC cross-border gateways and satellite feeds synchronized',
          buttonLabel: 'Health Telemetry',
          onTap: () => notifier.setNavIndex(27),
        ),
      ];
    }

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

    if (role == UserRole.transporter) {
      return [
        _PriorityCard(
          badgeLabel: 'CARGO READY',
          badgeColor: const Color(0xFF16A34A),
          title: '12.5T Tomatoes Pickup Ready',
          subtitle: 'Chiredzi Smallholder Co-op to Mbare Market, Harare',
          buttonLabel: 'Accept Load',
          onTap: () => notifier.setNavIndex(5),
        ),
        _PriorityCard(
          badgeLabel: 'WAYBILL SIGN',
          badgeColor: const Color(0xFF2563EB),
          title: 'e-Waybill WB-882 Pending',
          subtitle: 'Consignment delivery receipt requires driver verification',
          buttonLabel: 'Sign e-Waybill',
          onTap: () => notifier.setNavIndex(15),
        ),
        _PriorityCard(
          badgeLabel: 'ROUTE ALERT',
          badgeColor: const Color(0xFFEA580C),
          title: 'Beitbridge Highway Delay',
          subtitle: 'Heavy rain & customs slowdown expected (+2 hrs)',
          buttonLabel: 'View Forecast',
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
            childAspectRatio: isDesktop ? 2.2 : (constraints.maxWidth < 380 ? 1.5 : 1.75),
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

    if (role == UserRole.transporter) {
      return [
        const _QuickActionConfig('View Active Dispatch', 'Cargo transport job', Icons.navigation_outlined, Color(0xFF16A34A), 5),
        _QuickActionConfig(
          'Update GPS Telemetry',
          'Live GPS & Route tracking',
          Icons.pin_drop_outlined,
          const Color(0xFF2563EB),
          5,
          onCustomTap: (context, ref) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransporterTelemetryPage()),
            );
          },
        ),
        const _QuickActionConfig('Check Driver Wallet', 'Freight payouts & earnings', Icons.account_balance_wallet_outlined, Color(0xFF7C3AED), 16),
        const _QuickActionConfig('Fleet Cargo Loads', 'Available freight loads', Icons.local_shipping_outlined, Color(0xFFF97316), 5),
      ];
    }

    if (role == UserRole.valueAdder) {
      return const [
        _QuickActionConfig('Start Batch Run', 'Value addition hub', Icons.factory_outlined, Color(0xFF16A34A), 25),
        _QuickActionConfig('Grade Raw Intake', 'Quality & Brix inspection', Icons.assignment_turned_in_outlined, Color(0xFF2563EB), 25),
        _QuickActionConfig('Bulk Crop Sourcing', 'Procure raw produce', Icons.storefront_outlined, Color(0xFFF97316), 1),
        _QuickActionConfig('Traceability Certs', 'Batch verification', Icons.verified_outlined, Color(0xFF7C3AED), 15),
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
                builder: (_) => const AdminSystemHealthPage(),
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

// ─────────────────────────────────────────────────────────────────────────────
// MY FLEET — Transporter Vehicle Registration Section
// ─────────────────────────────────────────────────────────────────────────────

/// Simple immutable model for a registered vehicle.
class _VehicleEntry {
  final String plate;
  final String type;
  final String capacity;
  final String operator;
  final String contact;

  const _VehicleEntry({
    required this.plate,
    required this.type,
    required this.capacity,
    required this.operator,
    required this.contact,
  });

  IconData get typeIcon => switch (type) {
        'Refrigerated Van' => Icons.ac_unit_outlined,
        'Motorbike' => Icons.two_wheeler_outlined,
        'Pickup' => Icons.airport_shuttle_outlined,
        _ => Icons.local_shipping_outlined, // Truck (default)
      };

  Color get typeColor => switch (type) {
        'Refrigerated Van' => const Color(0xFF0284C7),
        'Motorbike' => const Color(0xFFF97316),
        'Pickup' => const Color(0xFF7C3AED),
        _ => const Color(0xFF16A34A),
      };
}

/// Scrollable fleet card list + "Register Vehicle" add card.
class _FleetSection extends StatefulWidget {
  const _FleetSection();

  @override
  State<_FleetSection> createState() => _FleetSectionState();
}

class _FleetSectionState extends State<_FleetSection> {
  final List<_VehicleEntry> _vehicles = [];

  void _openRegisterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegisterVehicleSheet(
        onSave: (entry) {
          setState(() => _vehicles.add(entry));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${entry.plate} registered to your fleet!'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Registered vehicle cards
          ..._vehicles.map((v) => _VehicleCard(vehicle: v)),

          // "Add Vehicle" card — always shown at the end
          GestureDetector(
            onTap: _openRegisterSheet,
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF16A34A),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF16A34A), size: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Register\nVehicle',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF16A34A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add to fleet',
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single fleet vehicle card widget.
class _VehicleCard extends StatelessWidget {
  final _VehicleEntry vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: vehicle.typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(vehicle.typeIcon, color: vehicle.typeColor, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  vehicle.capacity,
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            vehicle.plate,
            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            vehicle.type,
            style: GoogleFonts.inter(fontSize: 10.5, color: vehicle.typeColor, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vehicle.operator,
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet form for registering a new vehicle.
class _RegisterVehicleSheet extends StatefulWidget {
  final void Function(_VehicleEntry entry) onSave;
  const _RegisterVehicleSheet({required this.onSave});

  @override
  State<_RegisterVehicleSheet> createState() => _RegisterVehicleSheetState();
}

class _RegisterVehicleSheetState extends State<_RegisterVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _plateCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String _selectedType = 'Truck';

  static const _vehicleTypes = ['Truck', 'Pickup', 'Refrigerated Van', 'Motorbike'];

  @override
  void dispose() {
    _plateCtrl.dispose();
    _capacityCtrl.dispose();
    _operatorCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_VehicleEntry(
      plate: _plateCtrl.text.trim().toUpperCase(),
      type: _selectedType,
      capacity: '${_capacityCtrl.text.trim()} T',
      operator: _operatorCtrl.text.trim(),
      contact: _contactCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: Color(0xFFF97316), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Register Vehicle',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                      Text('Add this vehicle to your fleet',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vehicle Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: _dec('Vehicle Type', Icons.directions_car_outlined),
                        items: _vehicleTypes
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedType = v!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 14),
                      // Plate Number
                      TextFormField(
                        controller: _plateCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _dec('Registration Plate (e.g. ABC 1234 ZW)', Icons.pin_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter plate number' : null,
                      ),
                      const SizedBox(height: 14),
                      // Capacity
                      TextFormField(
                        controller: _capacityCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _dec('Load Capacity (tonnes)', Icons.inventory_2_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter capacity' : null,
                      ),
                      const SizedBox(height: 14),
                      // Operator / Driver Name
                      TextFormField(
                        controller: _operatorCtrl,
                        decoration: _dec('Operator / Driver Name', Icons.person_outline),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter operator name' : null,
                      ),
                      const SizedBox(height: 14),
                      // Contact Number
                      TextFormField(
                        controller: _contactCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _dec('Contact Number', Icons.phone_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter contact number' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Register Vehicle to Fleet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSPORTER MISSION CONTROL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// High-contrast Midnight Slate & Safety Amber Hero Command Banner
class _TransporterHeroCommandBanner extends ConsumerWidget {
  const _TransporterHeroCommandBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.55),
                const Color(0xFF0F172A).withValues(alpha: 0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: const Color(0xFFF97316).withOpacity(0.4), width: 1.2),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF97316).withOpacity(0.4)),
                ),
                child: const Icon(Icons.navigation_outlined, color: Color(0xFFF97316), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'FREIGHT DISPATCH COMMAND',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDemo ? const Color(0xFFF97316) : const Color(0xFF0284C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDemo ? 'DEMO SIMULATION' : 'LIVE ACCOUNT',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDemo ? 'Harare ➔ Chiredzi ➔ Beitbridge Corridor' : 'Logistics fleet ready for active cargo dispatch',
                      style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 18),

          // 4 Key Performance Telemetry Indicators
          Row(
            children: [
              Expanded(
                child: _buildBannerKpi(
                  label: 'Gross Freight',
                  value: isDemo ? '\$1,420.00' : '\$0.00',
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _buildBannerKpi(
                  label: 'Active Waybills',
                  value: isDemo ? '2 Jobs' : '0 Jobs',
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFFF97316),
                ),
              ),
              Expanded(
                child: _buildBannerKpi(
                  label: 'Distance Run',
                  value: isDemo ? '680 km' : '0 km',
                  icon: Icons.alt_route_outlined,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildBannerKpi({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ],
    );
  }
}

/// Cargo Bidding & Freight Match Radar Feed
class _CargoBiddingRadarSection extends ConsumerWidget {
  const _CargoBiddingRadarSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    if (!isDemo) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.radar_outlined, color: Color(0xFFF97316), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Freight Loads in Range',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'New crop pickup requests from farmers & cooperatives will populate dynamically in your region.',
                    style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B), height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Demo Data: 4 Cargo Load Requests
    return Column(
      children: [
        _buildBiddingCard(
          context,
          cargoTitle: '12.5 Tonnes Fresh Tomatoes',
          route: 'Chiredzi East Co-op ──▶ Mbare Market, Harare (420 km)',
          fee: '\$380.00',
          ratePerKm: '\$0.90/km',
          deadline: 'Pickup by 14:00 Today',
          badgeColor: const Color(0xFF16A34A),
          requesterName: 'Chiredzi East Farmers Co-operative',
          requesterContactPerson: 'Mr. Farai Musonza (Logistics Director)',
          requesterPhone: '+263 77 412 9081',
          requesterRating: '4.9 ★ (142 completed trips)',
          coopRegId: 'ZIM-COP-884920',
          pickupFacility: 'Block B, Chiredzi East Packhouse, Lowveld Region',
          pickupManager: 'Sekuru Blessing (+263 71 293 8472)',
          dropoffFacility: 'Stall 44, Fresh Produce Terminal, Mbare Market, Harare',
          dropoffManager: 'Kudzai Mbare Trading (+263 77 301 9284)',
          cargoPackaging: '625 Ventilated Plastic Crates on 10 Euro-Pallets',
          tempRequirement: '12°C - 15°C (Perishable Fresh Produce)',
          escrowStatus: '100% Locked in Verdi Escrow Vault (\$380.00)',
        ),
        const SizedBox(height: 12),
        _buildBiddingCard(
          context,
          cargoTitle: '28.0 Tonnes White Maize Grain',
          route: 'Mvurwi Grain Silo ──▶ Bulawayo Milling Plant (540 km)',
          fee: '\$720.00',
          ratePerKm: '\$1.33/km',
          deadline: 'Pickup Tomorrow 08:00',
          badgeColor: const Color(0xFF0284C7),
          requesterName: 'Mvurwi Grain Producers Association',
          requesterContactPerson: 'Mrs. Sarah Chimwanda (Depot Manager)',
          requesterPhone: '+263 73 392 1045',
          requesterRating: '4.85 ★ (98 completed trips)',
          coopRegId: 'ZIM-AGR-542190',
          pickupFacility: 'Mvurwi Grain Silo 4, Depot Road, Mashonaland Central',
          pickupManager: 'Tinashe Silo Ops (+263 77 112 3901)',
          dropoffFacility: 'Bulawayo Milling Plant, Belmont Industrial Site, Bulawayo',
          dropoffManager: 'Receiving Bay 2 (+263 71 884 9201)',
          cargoPackaging: '560 Bulk Woven Polypropylene Bags (50kg each)',
          tempRequirement: 'Dry Bulk Ventilation (Max 12% Moisture Content)',
          escrowStatus: '100% Locked in Verdi Escrow Vault (\$720.00)',
        ),
        const SizedBox(height: 12),
        _buildBiddingCard(
          context,
          cargoTitle: '8.0 Tonnes Export Macadamia Nuts',
          route: 'Chipinge Estate ──▶ Beira Port Export Terminal (290 km)',
          fee: '\$640.00',
          ratePerKm: '\$2.20/km',
          deadline: 'Pickup Today 16:30',
          badgeColor: const Color(0xFF8B5CF6),
          requesterName: 'Highland Nut Exporters Ltd',
          requesterContactPerson: 'Mr. Tendai Mutare (Export Controller)',
          requesterPhone: '+263 77 904 1122',
          requesterRating: '4.95 ★ (210 completed export trips)',
          coopRegId: 'EXP-MAC-99120',
          pickupFacility: 'Highland Processing Plant, Chipinge East, Manicaland',
          pickupManager: 'Edmore Dispatch (+263 77 881 2044)',
          dropoffFacility: 'Port of Beira Logistics Dock 4, Mozambique Transit Corridor',
          dropoffManager: 'Customs Logistics (+258 84 991 0022)',
          cargoPackaging: '160 Sealed Moisture-Proof Vacuum Drums',
          tempRequirement: 'Low Humidity Dry Transit (Phytosanitary Sealed)',
          escrowStatus: '100% Locked in Verdi Escrow Vault (\$640.00)',
        ),
        const SizedBox(height: 12),
        _buildBiddingCard(
          context,
          cargoTitle: '18.5 Tonnes Grade A Irish Potatoes',
          route: 'Nyanga Valley Co-op ──▶ Gweru Wholesale Depot (380 km)',
          fee: '\$490.00',
          ratePerKm: '\$1.29/km',
          deadline: 'Pickup Tomorrow 06:00',
          badgeColor: const Color(0xFFD97706),
          requesterName: 'Nyanga Highlands Farmers Co-op',
          requesterContactPerson: 'Mrs. Grace Chipo (Co-op Chair)',
          requesterPhone: '+263 71 554 9900',
          requesterRating: '4.8 ★ (76 completed trips)',
          coopRegId: 'ZIM-COP-33819',
          pickupFacility: 'Central Sorting Shed, Nyanga Valley, Manicaland',
          pickupManager: 'Takudzwa Farm Manager (+263 77 441 0928)',
          dropoffFacility: 'Gweru Wholesale Agricultural Depot, Midlands',
          dropoffManager: 'Depot Receiving Bay (+263 73 990 1283)',
          cargoPackaging: '1,230 Mesh Sacks (15kg per sack)',
          tempRequirement: 'Cool Ambient Ventilation Required (Covered Tarpaulin)',
          escrowStatus: '100% Locked in Verdi Escrow Vault (\$490.00)',
        ),
      ],
    );
  }

  Widget _buildBiddingCard(
    BuildContext context, {
    required String cargoTitle,
    required String route,
    required String fee,
    required String ratePerKm,
    required String deadline,
    required Color badgeColor,
    required String requesterName,
    required String requesterContactPerson,
    required String requesterPhone,
    required String requesterRating,
    required String coopRegId,
    required String pickupFacility,
    required String pickupManager,
    required String dropoffFacility,
    required String dropoffManager,
    required String cargoPackaging,
    required String tempRequirement,
    required String escrowStatus,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'LOAD READY',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 10, color: Color(0xFF16A34A)),
                    const SizedBox(width: 3),
                    Text(
                      'VERIFIED REQUESTER',
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                fee,
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: const Color(0xFF16A34A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            cargoTitle,
            style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.alt_route_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  route,
                  style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Requester Summary Line
          Row(
            children: [
              const Icon(Icons.business_outlined, size: 13, color: Color(0xFF16A34A)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Requester: $requesterName • $requesterRating',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$deadline  •  $ratePerKm',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
              ),
              const Spacer(),
              // Secondary View Details Button
              OutlinedButton.icon(
                onPressed: () {
                  _showCargoRequesterDetailModal(
                    context,
                    cargoTitle: cargoTitle,
                    route: route,
                    fee: fee,
                    ratePerKm: ratePerKm,
                    deadline: deadline,
                    requesterName: requesterName,
                    requesterContactPerson: requesterContactPerson,
                    requesterPhone: requesterPhone,
                    requesterRating: requesterRating,
                    coopRegId: coopRegId,
                    pickupFacility: pickupFacility,
                    pickupManager: pickupManager,
                    dropoffFacility: dropoffFacility,
                    dropoffManager: dropoffManager,
                    cargoPackaging: cargoPackaging,
                    tempRequirement: tempRequirement,
                    escrowStatus: escrowStatus,
                  );
                },
                icon: const Icon(Icons.info_outline_rounded, size: 15),
                label: const Text('View Info', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 8),
              // Primary Accept Button
              ElevatedButton.icon(
                onPressed: () {
                  _showCargoRequesterDetailModal(
                    context,
                    cargoTitle: cargoTitle,
                    route: route,
                    fee: fee,
                    ratePerKm: ratePerKm,
                    deadline: deadline,
                    requesterName: requesterName,
                    requesterContactPerson: requesterContactPerson,
                    requesterPhone: requesterPhone,
                    requesterRating: requesterRating,
                    coopRegId: coopRegId,
                    pickupFacility: pickupFacility,
                    pickupManager: pickupManager,
                    dropoffFacility: dropoffFacility,
                    dropoffManager: dropoffManager,
                    cargoPackaging: cargoPackaging,
                    tempRequirement: tempRequirement,
                    escrowStatus: escrowStatus,
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Accept Load', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCargoRequesterDetailModal(
    BuildContext context, {
    required String cargoTitle,
    required String route,
    required String fee,
    required String ratePerKm,
    required String deadline,
    required String requesterName,
    required String requesterContactPerson,
    required String requesterPhone,
    required String requesterRating,
    required String coopRegId,
    required String pickupFacility,
    required String pickupManager,
    required String dropoffFacility,
    required String dropoffManager,
    required String cargoPackaging,
    required String tempRequirement,
    required String escrowStatus,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drag Handle & Close
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'LOAD SPECIFICATIONS & REQUESTER DOSSIER',
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: const Color(0xFF16A34A), letterSpacing: 0.8),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Load Title & Escrow Lock Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cargoTitle,
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$route • $ratePerKm',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fee,
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF16A34A)),
                      ),
                      Text(
                        'Escrow Vault Guaranteed',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF16A34A), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [
                    // Section 1: Requester Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFF16A34A).withOpacity(0.15),
                                child: const Icon(Icons.business_center_rounded, color: Color(0xFF16A34A), size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            requesterName,
                                            style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF0284C7)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$requesterContactPerson • Reg ID: $coopRegId',
                                      style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF475569)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      requesterRating,
                                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFD97706), fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('📞 Calling $requesterContactPerson ($requesterPhone)...')),
                                    );
                                  },
                                  icon: const Icon(Icons.phone_outlined, size: 16),
                                  label: Text('Call ($requesterPhone)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('💬 Opening WhatsApp Chat with $requesterName...')),
                                    );
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                  label: const Text('WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Origin & Pickup Location Details
                    _buildModalSectionHeader('PICKUP ORIGIN & LOADING BAY', Icons.location_on_outlined, const Color(0xFF16A34A)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Pickup Facility', pickupFacility),
                    _buildDetailRow('On-Site Dispatcher', pickupManager),
                    _buildDetailRow('Pickup Window', deadline),

                    const SizedBox(height: 16),

                    // Section 3: Dropoff & Destination Details
                    _buildModalSectionHeader('DELIVERY DESTINATION & OFFLOADING', Icons.flag_outlined, const Color(0xFF0284C7)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Destination Point', dropoffFacility),
                    _buildDetailRow('Recipient Contact', dropoffManager),

                    const SizedBox(height: 16),

                    // Section 4: Cargo & Handling Specifications
                    _buildModalSectionHeader('CARGO SPECIFICATIONS & HANDLING', Icons.inventory_2_outlined, const Color(0xFFD97706)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Packaging / Unit Type', cargoPackaging),
                    _buildDetailRow('Temperature Requirement', tempRequirement),

                    const SizedBox(height: 16),

                    // Section 5: Financial Escrow Security
                    _buildModalSectionHeader('PAYMENT ESCROW & FREIGHT TERMS', Icons.lock_clock_outlined, const Color(0xFF8B5CF6)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Vault Lock Status', escrowStatus),
                    _buildDetailRow('Payout Terms', '50% Instant Mobile Money Advance on Loading Scan • 50% Balance on e-POD Signoff'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Successfully Accepted Load for $cargoTitle! Waybill generated.'),
                            backgroundColor: const Color(0xFF16A34A),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text('Accept & Lock Load ($fee)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF0F172A), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Active Freight Waybills Section
class _ActiveWaybillsSection extends ConsumerWidget {
  const _ActiveWaybillsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    if (!isDemo) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined, color: Color(0xFF0284C7), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Waybills Assigned',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Waybills and cargo shipment tracking will activate automatically when a freight load is accepted.',
                    style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B), height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'WAYBILL #WB-2024-882',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'IN TRANSIT',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '12.5T Fresh Tomatoes Delivery',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            'Driver: Tafadzwa M. • Truck Plate: ABC 1234 ZW',
            style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Stage Progress Indicator
          Row(
            children: [
              _buildStageDot('Loading', true),
              _buildStageLine(true),
              _buildStageDot('In Transit', true),
              _buildStageLine(false),
              _buildStageDot('Delivered', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageDot(String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
            shape: BoxShape.circle,
          ),
          child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 9.5, fontWeight: isDone ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF475569)),
        ),
      ],
    );
  }

  Widget _buildStageLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 3,
        color: isDone ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      ),
    );
  }
}

/// Driver Pre-Trip Safety Inspection Checklist Widget
class _PreTripSafetyChecklistSection extends StatefulWidget {
  const _PreTripSafetyChecklistSection();

  @override
  State<_PreTripSafetyChecklistSection> createState() => _PreTripSafetyChecklistSectionState();
}

class _PreTripSafetyChecklistSectionState extends State<_PreTripSafetyChecklistSection> {
  bool _tiresChecked = true;
  bool _brakesChecked = true;
  bool _coldChainTempChecked = true;
  bool _fuelChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: Color(0xFF16A34A), size: 20),
              const SizedBox(width: 8),
              Text(
                'Pre-Departure Inspection',
                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const Spacer(),
              Text(
                '${(_tiresChecked ? 1 : 0) + (_brakesChecked ? 1 : 0) + (_coldChainTempChecked ? 1 : 0) + (_fuelChecked ? 1 : 0)}/4 Verified',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildCheckRow('Tire Pressure & Tread Inspection', _tiresChecked, (v) => setState(() => _tiresChecked = v!)),
          _buildCheckRow('Brake System & Fluid Levels', _brakesChecked, (v) => setState(() => _brakesChecked = v!)),
          _buildCheckRow('Refrigeration Unit Target Temp (-2°C)', _coldChainTempChecked, (v) => setState(() => _coldChainTempChecked = v!)),
          _buildCheckRow('Diesel Tank Full (Range > 500 km)', _fuelChecked, (v) => setState(() => _fuelChecked = v!)),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: CheckboxListTile(
        title: Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), fontWeight: FontWeight.w600)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF16A34A),
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
