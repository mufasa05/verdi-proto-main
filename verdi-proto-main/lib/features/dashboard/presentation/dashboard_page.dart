import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../admin/presentation/ai_backbone_control_page.dart';
import '../../admin/presentation/infrastructure_modules_control_page.dart';
import '../../admin/presentation/marketplace_trade_oversight_page.dart';
import '../../admin/presentation/security_compliance_vault_page.dart';
import '../../admin/presentation/user_identity_control_page.dart';
import '../../admin/presentation/admin_user_activity_page.dart';
import '../../admin/presentation/admin_system_health_page.dart';
import '../../admin/presentation/admin_user_management_page.dart';

/// Full-Privilege Super Administrator Sovereign Command Center & Dedicated Sub-Page Router
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

class _DashboardPageState extends ConsumerState<DashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const bgDark = Color(0xFF0B0F17);
  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentDanger = Color(0xFFEF4444);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  // Sub-page navigation state
  String? _activeSubPageTitle;
  Widget? _activeSubPageWidget;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _activeSubPageTitle = widget.initialSubPageTitle;
    _activeSubPageWidget = widget.initialSubPageWidget;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
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
                  'SUPER ADMIN CONTROL ACTIVE',
                  style: TextStyle(color: accentGreen, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _activeSubPageWidget,
          ),
        ),
      );
    }

    // Default Sovereign Command Center View
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Sovereignty Banner ---
              _buildHeaderBanner(),

              const SizedBox(height: 16),

              // --- 5 Top Navigation Tabs ---
              Container(
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: accentGreen,
                  indicatorWeight: 3,
                  labelColor: accentGreen,
                  unselectedLabelColor: textMuted,
                  tabs: const [
                    Tab(text: 'All privileges'),
                    Tab(text: 'Critical controls'),
                    Tab(text: 'Role comparison'),
                    Tab(text: 'Audit trail'),
                    Tab(text: 'Governance policy'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Top 4 Metric KPI Cards ---
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  if (isMobile) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildMetricCard('47', 'Modules controlled', accentGreen)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildMetricCard('11', 'Roles they manage', accentGreen)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildMetricCard('3', 'Max accounts allowed', accentDanger)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildMetricCard('100%', 'Data visibility', accentGreen)),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildMetricCard('47', 'Modules controlled', accentGreen)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('11', 'Roles they manage', accentGreen)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('3', 'Max accounts allowed', accentDanger)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('100%', 'Data visibility', accentGreen)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- Tab View Content ---
              switch (_tabController.index) {
                0 => _buildAllPrivilegesTab(),
                1 => _buildCriticalControlsTab(),
                2 => _buildRoleComparisonTab(),
                3 => _buildAuditTrailTab(),
                4 => _buildGovernancePolicyTab(),
                _ => _buildAllPrivilegesTab(),
              },
            ],
          ),
        ),
      ),
    );
  }

  // --- Header Sovereignty Banner Widget ---
  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Return Navigation Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Return / Back Button to Home
              ElevatedButton.icon(
                onPressed: () {
                  if (_activeSubPageTitle != null) {
                    _closeSubPage();
                  } else if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                  } else {
                    ref.read(appStateProvider.notifier).setNavIndex(0); // Return to Home
                  }
                },
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(
                  _activeSubPageTitle != null ? 'Return to Admin Hub' : 'Return to Home',
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
              // Access Other Options Quick Jump Dropdown
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
                      Text('Access Other Options', style: GoogleFonts.inter(color: accentGreen, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  PopupMenuItem(value: 0, child: Text('🏠 Home Operational Hub', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 1, child: Text('🛍️ Marketplace', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 2, child: Text('💬 My Chats', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 4, child: Text('📦 Orders Command Center', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 5, child: Text('🚚 Fleet & Transport Hub', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 6, child: Text('💳 Payments & Settlements', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 16, child: Text('💰 Finance Module', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
                  PopupMenuItem(value: 21, child: Text('⚙️ Settings & Configuration', style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentGreen.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.shield_outlined, color: accentGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Super administrator',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Highest privilege role in Verdi OS · Full system sovereignty · All domains · All modules',
                      style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: Colors.white70, size: 20),
                color: cardDark,
                onSelected: (val) {
                  if (val == 'lock') {
                    _openSubPage('Emergency Safety & Lockdown Desk', const InfrastructureModulesControlPage());
                  } else if (val == 'kyc') {
                    _openSubPage('KYC User Directory & Sovereign Privilege Manager', const UserIdentityControlPage());
                  } else if (val == 'telemetry') {
                    _openSubPage('Server Health & Infrastructure Telemetry', const AdminSystemHealthPage());
                  } else if (val == 'audit') {
                    _openSubPage('User Activity & System Audit Hub', const AdminUserActivityPage());
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'audit',
                    child: Text('User Activities & System Audit Hub', style: TextStyle(color: accentBlue)),
                  ),
                  PopupMenuItem(
                    value: 'lock',
                    child: Text('Emergency Safety & Lockdown Desk', style: TextStyle(color: accentDanger)),
                  ),
                  PopupMenuItem(
                    value: 'kyc',
                    child: Text('User KYC & Sovereign Privilege Manager', style: TextStyle(color: Colors.white)),
                  ),
                  PopupMenuItem(
                    value: 'telemetry',
                    child: Text('Server Telemetry & Infrastructure', style: TextStyle(color: accentGreen)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildBadge('⚠️ Restricted to 1-3 people maximum', accentDanger),
              _buildBadge('All 47 modules', accentGreen),
              _buildBadge('Read + Write + Delete + Configure', accentBlue),
              _buildBadge('Full audit trail on every action', accentGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final isTablet = constraints.maxWidth < 1100;
        final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
        final childAspectRatio = isMobile ? 2.6 : (isTablet ? 2.3 : 2.1);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: children,
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: ALL PRIVILEGES (EVERY CARD MAPS TO DEDICATED CONTROL SUITE)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildAllPrivilegesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.people_outline, 'User & Identity Management'),
        _buildResponsiveGrid([
          _buildControlCard(
            icon: Icons.person_add_outlined,
            title: 'Create any user account',
            desc: 'Register farmers, buyers, officers, admins across all roles',
            onTap: () => _openSubPage('Platform User Account Directory', const AdminUserManagementPage()),
          ),
          _buildControlCard(
            icon: Icons.manage_accounts_outlined,
            title: 'Edit any user profile',
            desc: 'Update identity, contacts, classification, and linked entities',
            onTap: () => _openSubPage('Platform User Account Directory', const AdminUserManagementPage()),
          ),
          _buildControlCard(
            icon: Icons.person_remove_outlined,
            title: 'Suspend or delete any account',
            desc: 'Immediate suspension or permanent deletion with audit log',
            isDanger: true,
            onTap: () => _openSubPage('Platform User Account Directory', const AdminUserManagementPage()),
          ),
          _buildControlCard(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Assign & revoke all roles',
            desc: 'Grant or strip any role including admin and ministry viewer',
            onTap: () => _openSubPage('KYC User Directory & Sovereign Privilege Manager', const UserIdentityControlPage()),
          ),
          _buildControlCard(
            icon: Icons.vpn_key_outlined,
            title: 'Force password & session reset',
            desc: 'Instantly invalidate sessions for any user platform-wide',
            onTap: () => _openSubPage('KYC User Directory & Sovereign Privilege Manager', const UserIdentityControlPage()),
          ),
          _buildControlCard(
            icon: Icons.verified_user_outlined,
            title: 'Verify or reject KYC manually',
            desc: 'Override automated KYC decisions for any user',
            onTap: () => _openSubPage('KYC User Directory & Sovereign Privilege Manager', const UserIdentityControlPage()),
          ),
        ]),

        const SizedBox(height: 28),

        _buildSectionHeader(Icons.settings_outlined, 'Platform Infrastructure & Modules'),
        _buildResponsiveGrid([
          _buildControlCard(
            icon: Icons.toggle_on_outlined,
            title: 'Enable & disable modules',
            desc: 'Turn any of the 47 modules on or off dynamically',
            onTap: () => _openSubPage('47-Module Switchboard Suite', const InfrastructureModulesControlPage()),
          ),
          _buildControlCard(
            icon: Icons.power_settings_new_outlined,
            title: 'System Kill-Switches & Lockdown',
            desc: 'Emergency halt on AI models, escrow checkouts, and database writes',
            isDanger: true,
            onTap: () => _openSubPage('Emergency Safety & Lockdown Desk', const InfrastructureModulesControlPage()),
          ),
          _buildControlCard(
            icon: Icons.monitor_heart_outlined,
            title: 'View system health & telemetry',
            desc: 'Full infrastructure monitoring — uptime, errors, latency',
            onTap: () => _openSubPage('Server Health & Infrastructure Telemetry', const AdminSystemHealthPage()),
          ),
        ]),

        const SizedBox(height: 28),

        _buildSectionHeader(Icons.psychology_outlined, 'AI Systems & Backbone'),
        _buildResponsiveGrid([
          _buildControlCard(
            icon: Icons.smart_toy_outlined,
            title: 'Configure AI assistant behaviour',
            desc: 'Set AI persona, language defaults, prompt guardrails, and scope',
            onTap: () => _openSubPage('AI Persona & Backbone Control Studio', const AiBackboneControlPage()),
          ),
          _buildControlCard(
            icon: Icons.tune_outlined,
            title: 'Tune AI backbone models',
            desc: 'Adjust forecasting thresholds, risk scoring weights, and alert triggers',
            onTap: () => _openSubPage('AI Persona & Backbone Control Studio', const AiBackboneControlPage()),
          ),
          _buildControlCard(
            icon: Icons.power_settings_new_outlined,
            title: 'Kill-switch AI systems',
            desc: 'Immediately disable AI backbone or assistant in an emergency',
            isDanger: true,
            onTap: () => _openSubPage('AI Emergency Kill-Switch Studio', const AiBackboneControlPage()),
          ),
          _buildControlCard(
            icon: Icons.cloud_outlined,
            title: 'Manage API keys & integrations',
            desc: 'Connect, rotate, and revoke all third-party API credentials',
            onTap: () => _openSubPage('API Secret Vault & Rotation Desk', const SecurityComplianceVaultPage()),
          ),
          _buildControlCard(
            icon: Icons.satellite_alt_outlined,
            title: 'Configure satellite data sources',
            desc: 'Add, remove, and calibrate satellite feed providers',
            onTap: () => _openSubPage('Satellite Raster Embeddings & Vector DB', const AiBackboneControlPage()),
          ),
          _buildControlCard(
            icon: Icons.monitor_heart_outlined,
            title: 'View system health & performance',
            desc: 'Full infrastructure monitoring — uptime, errors, latency',
            onTap: () => _openSubPage('Server Health & Infrastructure Telemetry', const AdminSystemHealthPage()),
          ),
        ]),

        const SizedBox(height: 28),

        _buildSectionHeader(Icons.security_outlined, 'Security & Compliance'),
        _buildResponsiveGrid([
          _buildControlCard(
            icon: Icons.receipt_long_outlined,
            title: 'Access full audit logs',
            desc: 'Every action by every user across all time — immutable records',
            onTap: () => _openSubPage('User Activity & System Audit Hub', const AdminUserActivityPage()),
          ),
          _buildControlCard(
            icon: Icons.lock_outlined,
            title: 'Platform-wide emergency lockdown',
            desc: 'Freeze all transactions and logins instantly — security incidents',
            isDanger: true,
            onTap: () => _openSubPage('Emergency Safety & Lockdown Desk', const InfrastructureModulesControlPage()),
          ),
          _buildControlCard(
            icon: Icons.bug_report_outlined,
            title: 'Access security incident reports',
            desc: 'Breach alerts, fraud flags, anomaly detection outputs',
            onTap: () => _openSubPage('Security Incident & Threat Desk', const SecurityComplianceVaultPage()),
          ),
          _buildControlCard(
            icon: Icons.policy_outlined,
            title: 'Manage compliance rules',
            desc: 'Configure EUDR, GDPR, national data law compliance settings',
            onTap: () => _openSubPage('EUDR & Sovereign Compliance Desk', const SecurityComplianceVaultPage()),
          ),
          _buildControlCard(
            icon: Icons.key_outlined,
            title: 'Manage encryption & data keys',
            desc: 'Rotate encryption keys, manage secrets vault',
            onTap: () => _openSubPage('API Secret Vault & Encryption Desk', const SecurityComplianceVaultPage()),
          ),
          _buildControlCard(
            icon: Icons.do_not_disturb_on_outlined,
            title: 'Block or whitelist IP addresses',
            desc: 'Network-level access control across all platform entry points',
            onTap: () => _openSubPage('IP Firewall & Network Access Control', const SecurityComplianceVaultPage()),
          ),
        ]),

        const SizedBox(height: 28),

        _buildSectionHeader(Icons.storefront_outlined, 'Marketplace & Trade Floor Oversight'),
        _buildResponsiveGrid([
          _buildControlCard(
            icon: Icons.check_circle_outline,
            title: 'Approve or reject any listing',
            desc: 'Override marketplace listing status for any commodity',
            onTap: () => _openSubPage('Marketplace Trade Floor & Price Policy Oversight', const MarketplaceTradeOversightPage()),
          ),
          _buildControlCard(
            icon: Icons.price_change_outlined,
            title: 'Set & publish floor prices',
            desc: 'Set policy-based floor or ceiling prices per commodity',
            onTap: () => _openSubPage('Marketplace Trade Floor & Price Policy Oversight', const MarketplaceTradeOversightPage()),
          ),
          _buildControlCard(
            icon: Icons.gavel_outlined,
            title: 'Resolve trade disputes',
            desc: 'Final arbitration authority on buyer-seller disputes',
            onTap: () => _openSubPage('Marketplace Trade Floor & Price Policy Oversight', const MarketplaceTradeOversightPage()),
          ),
        ]),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: CRITICAL CONTROLS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCriticalControlsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.warning_amber_rounded, 'High-Risk Sovereign Override Controls', isDanger: true),
        _buildResponsiveGrid([
          _buildControlCard(
            icon: Icons.lock_outlined,
            title: 'Platform-wide emergency lockdown',
            desc: 'Freeze all transactions and logins instantly — security incidents',
            isDanger: true,
            onTap: () => _openSubPage('Emergency Safety & Lockdown Desk', const InfrastructureModulesControlPage()),
          ),
          _buildControlCard(
            icon: Icons.power_settings_new_outlined,
            title: 'Kill-switch AI systems',
            desc: 'Immediately disable AI backbone or assistant in an emergency',
            isDanger: true,
            onTap: () => _openSubPage('AI Emergency Kill-Switch Studio', const AiBackboneControlPage()),
          ),
          _buildControlCard(
            icon: Icons.person_remove_outlined,
            title: 'Suspend or delete any account',
            desc: 'Immediate suspension or permanent deletion with audit log',
            isDanger: true,
            onTap: () => _openSubPage('Platform User Account Directory', const AdminUserManagementPage()),
          ),
        ]),
      ],
    );
  }

  Widget _buildRoleComparisonTab() {
    return const UserIdentityControlPage();
  }

  Widget _buildAuditTrailTab() {
    return const AdminUserActivityPage();
  }

  Widget _buildGovernancePolicyTab() {
    return Container(
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verdi OS Sovereign Governance Framework', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          const Text(
            '1. Super Administrator Account Limit: Maximum of 3 active Super Admin accounts allowed per national jurisdiction.\n'
            '2. Dual-Authorization Protocol: High-risk financial reversals and database purges require dual-key sign-off.\n'
            '3. EUDR Compliance Engine: All export trade permits must carry a valid satellite polygon audit receipt.\n'
            '4. Immutable Audit Logs: Every sovereign override action is permanently recorded with cryptographic hashes.',
            style: TextStyle(color: textMuted, height: 1.6),
          ),
        ],
      ),
    );
  }

  // --- Helper Layout Components ---
  Widget _buildSectionHeader(IconData icon, String title, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: isDanger ? accentDanger : accentGreen, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDanger ? accentDanger : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDanger ? accentDanger.withValues(alpha: 0.8) : cardBorder,
              width: isDanger ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDanger ? accentDanger : accentGreen).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: isDanger ? accentDanger : accentGreen, size: 18),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, color: textMuted.withValues(alpha: 0.5), size: 12),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDanger ? accentDanger : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}