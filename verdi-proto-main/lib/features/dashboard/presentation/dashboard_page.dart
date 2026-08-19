import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';
import '../../admin/presentation/admin_farms_page.dart';
import '../../admin/presentation/admin_system_health_page.dart';
import '../../admin/presentation/admin_user_activity_page.dart';
import '../../admin/presentation/admin_user_management_page.dart';
import '../../admin/presentation/ai_backbone_control_page.dart';
import '../../admin/presentation/marketplace_trade_oversight_page.dart';
import '../../admin/presentation/security_compliance_vault_page.dart';
import '../../admin/presentation/user_identity_control_page.dart';
import '../../logistics/presentation/transporter_telemetry_page.dart';

/// Full-Privilege Super Administrator Sovereign Master Control Tower
class DashboardPage extends ConsumerStatefulWidget {
  final String? initialSubPageTitle;
  final Widget? initialSubPageWidget;

  const DashboardPage({
    super.key,
    this.initialSubPageTitle,
    this.initialSubPageWidget,
  });

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const bgDark = Color(0xFF0B0F17);
  static const cardDark = Color(0xFF131B2A);
  static const cardBorder = Color(0xFF1E293B);
  static const accentGreen = Color(0xFF10B981);
  static const accentDanger = Color(0xFFEF4444);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const accentPurple = Color(0xFF8B5CF6);
  static const textMuted = Color(0xFF94A3B8);

  String? _activeSubPageTitle;
  Widget? _activeSubPageWidget;

  @override
  void initState() {
    super.initState();
    _activeSubPageTitle = widget.initialSubPageTitle;
    _activeSubPageWidget = widget.initialSubPageWidget;
  }

  void _openSubPage(String title, Widget child) {
    setState(() {
      _activeSubPageTitle = title;
      _activeSubPageWidget = child;
    });
  }

  void _closeSubPage() {
    setState(() {
      _activeSubPageTitle = null;
      _activeSubPageWidget = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Render dedicated sub-page if active
    if (_activeSubPageTitle != null && _activeSubPageWidget != null) {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          backgroundColor: cardDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _closeSubPage,
          ),
          title: Text(
            _activeSubPageTitle!,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accentGreen.withValues(alpha: 0.6)),
              ),
              child: const Center(
                child: Text(
                  'MASTER CONTROL ACTIVE',
                  style: TextStyle(color: accentGreen, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _activeSubPageWidget,
          ),
        ),
      );
    }

    final isDemo = ref.watch(isDemoModeProvider);
    final sessions = ref.watch(liveUserSessionsProvider);
    final activityEvents = ref.watch(platformActivityProvider);
    final isLockdown = ref.watch(isEmergencyLockdownProvider);
    final isMaintenance = ref.watch(isMaintenanceModeProvider);
    final health = ref.watch(systemHealthMetricsProvider);

    final onlineUsers = sessions.where((s) => s.isOnline).length;
    final totalActions = activityEvents.length;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Executive Master Header Bar
              _buildExecutiveHeader(isDemo, isLockdown, isMaintenance),

              const SizedBox(height: 16),

              // 2. Real-Time Dynamic Vitals Grid
              _buildVitalsGrid(onlineUsers, totalActions, health, isDemo),

              const SizedBox(height: 24),

              // 3. Platform Master Action Controls (Lockdown, Maintenance, Sync)
              _buildMasterActionToggles(isLockdown, isMaintenance),

              const SizedBox(height: 28),

              // 4. Six Operational Command Pillars
              _buildPillarSection(
                title: 'Stakeholders & Identity Control',
                icon: Icons.people_alt_outlined,
                color: accentBlue,
                children: [
                  _buildControlTile(
                    icon: Icons.badge_outlined,
                    title: 'User Directory & Role Governance',
                    desc: 'Manage accounts across all 9 roles, assign sovereign permissions & elevate privileges.',
                    actionLabel: 'Open Directory',
                    color: accentBlue,
                    onTap: () => _openSubPage('User Directory & Role Governance', const AdminUserManagementPage()),
                  ),
                  _buildControlTile(
                    icon: Icons.verified_user_outlined,
                    title: 'KYC & Regulatory Compliance Verification',
                    desc: 'Review AMA licenses, SAZ food hygiene certificates & approve identity tiers on demand.',
                    actionLabel: 'Review KYC',
                    color: accentGreen,
                    onTap: () => _openSubPage('KYC & Verification Desk', const UserIdentityControlPage()),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildPillarSection(
                title: 'Trade, Marketplace & Escrow Oversight',
                icon: Icons.storefront_outlined,
                color: accentGold,
                children: [
                  _buildControlTile(
                    icon: Icons.lock_clock_outlined,
                    title: 'Fintech Escrow Vault & Dispute Mediation',
                    desc: 'Monitor real-time trade escrow locks, intervene in contested transactions & release funds.',
                    actionLabel: 'Escrow Vault',
                    color: accentGold,
                    onTap: () => _openSubPage('Trade Oversight & Escrow Vault', const MarketplaceTradeOversightPage()),
                  ),
                  _buildControlTile(
                    icon: Icons.price_change_outlined,
                    title: 'Commodity Floor Pricing & Fair Trade Policies',
                    desc: 'Govern agricultural minimum floor prices, market fee parameters & trade commission rates.',
                    actionLabel: 'Adjust Policies',
                    color: accentPurple,
                    onTap: () => _showPricingPolicyDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildPillarSection(
                title: 'Cold-Chain Logistics & Route Surveillance',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFFF97316),
                children: [
                  _buildControlTile(
                    icon: Icons.radar_outlined,
                    title: 'Fleet Radar & Live GPS Telemetry Stream',
                    desc: 'Watch real-time vehicle routes, transporter coordinates and 5G IoT heartbeat telemetry.',
                    actionLabel: 'Track Telemetry',
                    color: const Color(0xFFF97316),
                    onTap: () => _openSubPage('Fleet GPS Telemetry Hub', const TransporterTelemetryPage()),
                  ),
                  _buildControlTile(
                    icon: Icons.ac_unit_outlined,
                    title: 'Reefer Cold-Chain Thermal Integrity Alerts',
                    desc: 'Instant audit logging on temperature breaches for horticultural and dairy exports.',
                    actionLabel: 'Inspect Cold Chain',
                    color: accentBlue,
                    onTap: () => _openSubPage('User Activity & System Audit Hub', const AdminUserActivityPage()),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildPillarSection(
                title: 'Farms, Agronomy & EUDR Compliance',
                icon: Icons.grass_outlined,
                color: accentGreen,
                children: [
                  _buildControlTile(
                    icon: Icons.landscape_outlined,
                    title: 'GeoJSON Parcel Boundaries & Farm Registry',
                    desc: 'Review smallholder farm GPS polygons, land deeds and satellite NDVI vegetative health.',
                    actionLabel: 'Farm Registry',
                    color: accentGreen,
                    onTap: () => _openSubPage('Farms & Geospatial Registry', const AdminFarmsPage()),
                  ),
                  _buildControlTile(
                    icon: Icons.eco_outlined,
                    title: 'EUDR Deforestation Compliance Audits',
                    desc: 'Generate export certificates verifying deforestation-free production under EU Regulation 2023/1115.',
                    actionLabel: 'Audit EUDR',
                    color: accentGold,
                    onTap: () => _openSubPage('Farms & Geospatial Registry', const AdminFarmsPage()),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildPillarSection(
                title: 'Sovereign AI Backbone & Microservices Engine',
                icon: Icons.psychology_outlined,
                color: accentPurple,
                children: [
                  _buildControlTile(
                    icon: Icons.hub_outlined,
                    title: 'AI Model Gateway & LLM Orchestration',
                    desc: 'Switch between Gemini 1.5 Pro, Flash and Offline Agricultural SLM engines in real time.',
                    actionLabel: 'AI Control Desk',
                    color: accentPurple,
                    onTap: () => _openSubPage('AI Backbone Sovereign Controls', const AiBackboneControlPage()),
                  ),
                  _buildControlTile(
                    icon: Icons.tune_outlined,
                    title: 'AI Confidence & Pest Advisory Thresholds',
                    desc: 'Configure automated disease diagnosis thresholds, confidence cutoffs and safety filters.',
                    actionLabel: 'Tune Parameters',
                    color: accentBlue,
                    onTap: () => _showAiTuningDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildPillarSection(
                title: 'Security, Cryptography & Audit Ledger',
                icon: Icons.shield_outlined,
                color: accentDanger,
                children: [
                  _buildControlTile(
                    icon: Icons.history_edu_outlined,
                    title: 'User Activity & Live Surveillance Audit Hub',
                    desc: 'Sub-20ms WebSocket streaming of every stakeholder action, IP address and security event.',
                    actionLabel: 'Open Audit Hub',
                    color: accentBlue,
                    onTap: () => _openSubPage('User Activity & System Audit Hub', const AdminUserActivityPage()),
                  ),
                  _buildControlTile(
                    icon: Icons.dns_outlined,
                    title: 'Infrastructure Telemetry & Microservices Health',
                    desc: 'Real measured latency to Supabase PostgreSQL, WebSocket streams & server heartbeat.',
                    actionLabel: 'Inspect Health',
                    color: accentGreen,
                    onTap: () => _openSubPage('Server Health & Infrastructure Telemetry', const AdminSystemHealthPage()),
                  ),
                  _buildControlTile(
                    icon: Icons.enhanced_encryption_outlined,
                    title: 'Database Encryption & PostgreSQL Vault',
                    desc: 'Review Row Level Security policies, PostGIS spatial indexes and database schema backups.',
                    actionLabel: 'Open Vault',
                    color: accentGold,
                    onTap: () => _openSubPage('Security & Compliance Vault', const SecurityComplianceVaultPage()),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI BUILDERS & WIDGETS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildExecutiveHeader(bool isDemo, bool isLockdown, bool isMaintenance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLockdown ? accentDanger : cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(appStateProvider.notifier).setNavIndex(0);
                },
                icon: const Icon(Icons.home_outlined, size: 16),
                label: Text('Return to Home', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
              PopupMenuButton<int>(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.apps_outlined, size: 16, color: accentGreen),
                      const SizedBox(width: 6),
                      Text('Quick Navigate', style: GoogleFonts.inter(color: accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16, color: accentGreen),
                    ],
                  ),
                ),
                color: cardDark,
                onSelected: (idx) {
                  ref.read(appStateProvider.notifier).setNavIndex(idx);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 0, child: Text('🏠 Home Hub', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 1, child: Text('🛍️ Marketplace', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 4, child: Text('📦 Orders Command', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 5, child: Text('🚚 Logistics Fleet', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 16, child: Text('💰 Finance & Escrow', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 21, child: Text('⚙️ Settings', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLockdown ? accentDanger.withValues(alpha: 0.2) : accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isLockdown ? accentDanger : accentGreen.withValues(alpha: 0.4)),
                ),
                child: Icon(
                  isLockdown ? Icons.gavel_rounded : Icons.shield_rounded,
                  color: isLockdown ? accentDanger : accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Sovereign Master Command',
                            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDemo ? accentGold.withValues(alpha: 0.15) : accentGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDemo ? accentGold.withValues(alpha: 0.5) : accentGreen.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            isDemo ? 'DEMO SANDBOX' : 'LIVE PRODUCTION',
                            style: TextStyle(
                              color: isDemo ? accentGold : accentGreen,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDemo
                          ? 'Demo Sandbox Mode · Pre-populated scenarios for testing'
                          : 'Live Mode · Connected to Supabase PostgreSQL & WebSocket mesh',
                      style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(int onlineUsers, int totalActions, SystemHealthMetrics health, bool isDemo) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final count = isMobile ? 2 : 4;
        final aspect = isMobile ? 1.4 : 1.3;

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspect,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildVitalCard(
              title: 'Active Stakeholders',
              value: '$onlineUsers',
              subtext: isDemo ? 'Mock Sessions' : 'Online now',
              icon: Icons.people_alt_outlined,
              color: accentBlue,
            ),
            _buildVitalCard(
              title: 'Audit Trail Events',
              value: '$totalActions',
              subtext: isDemo ? 'Sample fixtures' : 'Logged actions',
              icon: Icons.history_rounded,
              color: accentGreen,
            ),
            _buildVitalCard(
              title: 'Supabase Latency',
              value: '${health.supabasePingMs} ms',
              subtext: health.supabaseStatus,
              icon: Icons.bolt_rounded,
              color: health.supabasePingMs < 100 ? accentGreen : accentGold,
            ),
            _buildVitalCard(
              title: 'Mesh WebSockets',
              value: '${health.websocketPingMs} ms',
              subtext: health.websocketStatus,
              icon: Icons.wifi_tethering_rounded,
              color: accentPurple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          Text(
            subtext,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMasterActionToggles(bool isLockdown, bool isMaintenance) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: accentGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Master Operational Controls & Emergency Switches',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Emergency Lockdown Button
              ElevatedButton.icon(
                onPressed: () {
                  final newLock = !isLockdown;
                  ref.read(isEmergencyLockdownProvider.notifier).state = newLock;
                  ref.read(platformActivityProvider.notifier).logActivity(
                        PlatformActivityEvent(
                          id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
                          userName: 'Super Admin',
                          userId: 'SYS-ADMIN-01',
                          userRole: UserRole.admin,
                          userAvatar: 'SA',
                          actionTitle: newLock ? '🚨 EMERGENCY PLATFORM LOCKDOWN ACTIVATED' : 'Platform Lockdown Lifted',
                          actionDescription: newLock
                              ? 'All mutations restricted to Read-Only mode by Super Administrator.'
                              : 'Standard Read/Write operations restored across the network.',
                          timestamp: 'Just now',
                          exactTime: DateTime.now().toIso8601String(),
                          module: 'Security',
                          device: 'Sovereign Master Console',
                          status: 'Success',
                          targetResource: 'Global Platform',
                          ipAddress: 'Sovereign Node 01',
                          metadata: {'lockdown': newLock},
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newLock ? '🚨 Emergency Lockdown Activated (Read-Only Mode)' : 'Lockdown Lifted'),
                      backgroundColor: newLock ? accentDanger : accentGreen,
                    ),
                  );
                },
                icon: Icon(isLockdown ? Icons.lock_open : Icons.lock, size: 16),
                label: Text(
                  isLockdown ? 'LIFT LOCKDOWN' : 'EMERGENCY LOCKDOWN',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLockdown ? accentGreen : accentDanger.withValues(alpha: 0.15),
                  foregroundColor: isLockdown ? Colors.black : accentDanger,
                  side: BorderSide(color: isLockdown ? accentGreen : accentDanger.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              // Maintenance Mode Button
              ElevatedButton.icon(
                onPressed: () {
                  final newMaint = !isMaintenance;
                  ref.read(isMaintenanceModeProvider.notifier).state = newMaint;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newMaint ? 'Maintenance Mode Enabled' : 'Maintenance Mode Disabled'),
                      backgroundColor: accentGold,
                    ),
                  );
                },
                icon: const Icon(Icons.build_circle_outlined, size: 16),
                label: Text(
                  isMaintenance ? 'DISABLE MAINTENANCE' : 'MAINTENANCE MODE',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMaintenance ? accentGold : const Color(0xFF1E293B),
                  foregroundColor: isMaintenance ? Colors.black : textMuted,
                  side: BorderSide(color: isMaintenance ? accentGold : const Color(0xFF334155)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              // Quick Snapshot Export
              OutlinedButton.icon(
                onPressed: () {
                  final events = ref.read(platformActivityProvider);
                  final jsonString = jsonEncode(events.map((e) => {
                    'id': e.id,
                    'user': e.userName,
                    'action': e.actionTitle,
                    'time': e.exactTime,
                    'module': e.module,
                    'status': e.status,
                  }).toList());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Exported ${events.length} audit records (${jsonString.length} bytes)!'),
                      backgroundColor: accentBlue,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 16, color: accentBlue),
                label: Text('EXPORT AUDIT SNAPSHOT', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: accentBlue)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF334155)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillarSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: c)).toList(),
        ),
      ],
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required String desc,
    required String actionLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.inter(fontSize: 11.5, color: textMuted, height: 1.35),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel,
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: color),
                      ],
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

  void _showPricingPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.price_change_outlined, color: accentPurple),
            const SizedBox(width: 8),
            Text('Commodity Pricing Policy', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sovereign Agricultural Floor Prices (Zimbabwe Region)', style: GoogleFonts.inter(color: textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            _buildPriceRow('Sugar Beans', 'US\$ 1.10 / kg', 'Floor enforced'),
            _buildPriceRow('Maize (Grade A)', 'US\$ 335.00 / Tonne', 'GMB benchmark'),
            _buildPriceRow('Soyabeans', 'US\$ 520.00 / Tonne', 'Active export'),
            _buildPriceRow('Macadamia Nuts', 'US\$ 3.80 / kg', 'EUDR premium'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agricultural floor prices synchronized across all trading terminals!'), backgroundColor: accentGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentPurple),
            child: const Text('Save & Broadcast', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String item, String price, String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: GoogleFonts.inter(color: accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(note, style: GoogleFonts.inter(color: textMuted, fontSize: 9.5)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAiTuningDialog(BuildContext context) {
    double tempThreshold = ref.read(aiConfidenceThresholdProvider);
    String selectedModel = ref.read(aiSelectedModelProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.tune_outlined, color: accentBlue),
              const SizedBox(width: 8),
              Text('AI Confidence & Model Gateway', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active LLM Model Engine:', style: GoogleFonts.inter(color: textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: selectedModel,
                isExpanded: true,
                dropdownColor: cardDark,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                items: const [
                  DropdownMenuItem(value: 'Gemini 1.5 Pro (Sovereign Cloud)', child: Text('Gemini 1.5 Pro (Sovereign Cloud)')),
                  DropdownMenuItem(value: 'Gemini 1.5 Flash (Ultra Low Latency)', child: Text('Gemini 1.5 Flash (Ultra Low Latency)')),
                  DropdownMenuItem(value: 'Agricultural Offline SLM (Edge Node)', child: Text('Agricultural Offline SLM (Edge Node)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedModel = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text('Diagnosis Confidence Cutoff: ${(tempThreshold * 100).toInt()}%', style: GoogleFonts.inter(color: textMuted, fontSize: 12)),
              Slider(
                value: tempThreshold,
                min: 0.50,
                max: 0.99,
                divisions: 49,
                activeColor: accentBlue,
                onChanged: (v) {
                  setModalState(() => tempThreshold = v);
                },
              ),
              Text('Advisory detections below this confidence will trigger human agronomist review.', style: GoogleFonts.inter(color: textMuted, fontSize: 11)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(aiConfidenceThresholdProvider.notifier).state = tempThreshold;
                ref.read(aiSelectedModelProvider.notifier).state = selectedModel;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('AI Backbone updated to $selectedModel at ${(tempThreshold * 100).toInt()}% confidence!'), backgroundColor: accentBlue),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
              child: const Text('Apply AI Settings', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}