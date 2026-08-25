import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/state/auth_state.dart';
import '../../../state/app_state.dart';
import '../../agri_expert/data/agri_expert_models.dart';
import '../../agri_expert/state/agri_expert_state.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final role = state.role;
    final isAdmin = role == UserRole.admin;
    final isTransporter = role == UserRole.transporter;
    final isBuyerB2B = role == UserRole.buyer;
    final isEndUser = role == UserRole.consumer;
    final isExpert = role == UserRole.expert;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF070B12) : SettingsPage.background;
    final appbarBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : SettingsPage.dark;
    final tabBg = isDark ? const Color(0xFF0F172A) : Colors.white;

    if (isBuyerB2B) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          title: Text(
            'Commercial Procurement & Enterprise Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor),
          ),
          backgroundColor: appbarBg,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: tabBg,
              child: TabBar(
                controller: _tabController,
                labelColor: SettingsPage.blue,
                unselectedLabelColor: SettingsPage.muted,
                indicatorColor: SettingsPage.blue,
                tabs: const [
                  Tab(text: 'Commercial Sourcing & Escrow'),
                  Tab(text: 'General Preferences'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const _CommercialBuyerSettingsTab(),
            _GeneralSettingsTab(),
          ],
        ),
      );
    }

    if (isEndUser) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          title: Text(
            'Household & Consumer Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor),
          ),
          backgroundColor: appbarBg,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: tabBg,
              child: TabBar(
                controller: _tabController,
                labelColor: SettingsPage.green,
                unselectedLabelColor: SettingsPage.muted,
                indicatorColor: SettingsPage.green,
                tabs: const [
                  Tab(text: 'Household & Delivery Preferences'),
                  Tab(text: 'General Preferences'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const _ConsumerSettingsTab(),
            _GeneralSettingsTab(),
          ],
        ),
      );
    }

    if (isTransporter) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          title: Text(
            'Carrier Telematics & Platform Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor),
          ),
          backgroundColor: appbarBg,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: tabBg,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFFF9F1C),
                unselectedLabelColor: SettingsPage.muted,
                indicatorColor: const Color(0xFFFF9F1C),
                tabs: const [
                  Tab(text: 'Fleet Telematics & Hardware'),
                  Tab(text: 'General Preferences'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const _CarrierSettingsTab(),
            _GeneralSettingsTab(),
          ],
        ),
      );
    }

    if (isExpert) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          title: Text(
            'Agri-Expert Professional & Practice Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor),
          ),
          backgroundColor: appbarBg,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: tabBg,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF10B981),
                unselectedLabelColor: SettingsPage.muted,
                indicatorColor: const Color(0xFF10B981),
                tabs: const [
                  Tab(text: 'Professional Credentials & Inquiries'),
                  Tab(text: 'General Preferences'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const _AgriExpertSettingsTab(),
            _GeneralSettingsTab(),
          ],
        ),
      );
    }

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          title: Text(
            'Account & Platform Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor),
          ),
          backgroundColor: appbarBg,
          elevation: 0,
        ),
        body: _GeneralSettingsTab(),
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text(
          'Access & Administration Console',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor),
        ),
        backgroundColor: appbarBg,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: tabBg,
            child: TabBar(
              controller: _tabController,
              labelColor: SettingsPage.green,
              unselectedLabelColor: SettingsPage.muted,
              indicatorColor: SettingsPage.green,
              tabs: const [
                Tab(text: 'Access Control'),
                Tab(text: 'General Settings'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _AccessControlTab(),
          _GeneralSettingsTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCESS CONTROL TAB
// ─────────────────────────────────────────────────────────────────────────────
class _AccessControlTab extends ConsumerWidget {
  const _AccessControlTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
            children: [
              // Spatial context banner
              _SpatialBanner(),
              const SizedBox(height: 16),

              // AI Access Risk Alert Card
              if (isDemo) _AiAccessRiskCard(),
              if (isDemo) const SizedBox(height: 16),

              // User list
              Text('Active Users & Scope', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: SettingsPage.dark)),
              const SizedBox(height: 10),
              if (isDemo)
                ..._users.map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _UserAccessCard(user: u),
                ))
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(
                    child: Text(
                      'No officially registered users yet. Users will appear here automatically upon official registration.',
                      style: GoogleFonts.inter(fontSize: 13, color: SettingsPage.muted, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Module Access Matrix
              _AccessMatrixCard(),
              const SizedBox(height: 20),

              // Temporary Passkey Console
              _PasskeyConsoleCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static final List<_UserScope> _users = const [
    _UserScope(name: 'Inspector Moyo', role: 'Government Auditor', scope: 'Mashonaland Central Schemes', permission: 'Read/Write Reports', activeGrants: 2),
    _UserScope(name: 'Farmer John', role: 'Farm Operator', scope: 'Mvurwi North (Zone 1-4)', permission: 'Remote Irrigation Command', activeGrants: 1),
    _UserScope(name: 'Scout Ndlovu', role: 'Technician/Inspector', scope: 'Gutu Block and Drone Fleet', permission: 'Read-only Findings', activeGrants: 0),
  ];
}

class _SpatialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Permissions are strictly bound to organization, farm, scheme, field, and zone scopes. Auditable immutable logs updated automatically.',
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: SettingsPage.dark),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiAccessRiskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [SettingsPage.orange.withOpacity(0.06), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsPage.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: SettingsPage.orange, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.smart_toy, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('AI ACCESS RISK DETECTED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Confidence: ', style: TextStyle(color: SettingsPage.muted, fontSize: 12)),
                  Text('91%', style: TextStyle(color: SettingsPage.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Unused high-level administrative permission detected for "Scout Ndlovu" node.', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: SettingsPage.dark)),
          const SizedBox(height: 6),
          Text('Why this matters: Scout Ndlovu has read-write access to Mvurwi Scheme valves, but has not published an execution command in 30 days. Access role mismatch risk exists. Recommend cleanup to "Read-only Findings" scope.', style: GoogleFonts.inter(fontSize: 12.5, color: SettingsPage.muted)),
          const Divider(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final btnDismiss = OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: isNarrow ? const Size(double.infinity, 40) : null,
                ),
                child: const Text('Dismiss Alert', style: TextStyle(fontSize: 12, color: SettingsPage.muted)),
              );
              final btnConfirm = ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsPage.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: isNarrow ? const Size(double.infinity, 40) : null,
                ),
                child: const Text('Confirm Cleanup Suggestion', style: TextStyle(fontSize: 12)),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    btnDismiss,
                    const SizedBox(height: 8),
                    btnConfirm,
                  ],
                );
              }

              return Row(
                children: [
                  btnDismiss,
                  const Spacer(),
                  btnConfirm,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UserAccessCard extends StatelessWidget {
  final _UserScope user;
  const _UserAccessCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: SettingsPage.green.withOpacity(0.1),
                child: const Icon(Icons.person_outline, color: SettingsPage.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: SettingsPage.dark)),
                    Text(user.role, style: const TextStyle(color: SettingsPage.muted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text('${user.activeGrants} Active Grants', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(children: [
            const Text('Scope: ', style: TextStyle(color: SettingsPage.muted, fontSize: 12)),
            Expanded(child: Text(user.scope, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Text('Permission: ', style: TextStyle(color: SettingsPage.muted, fontSize: 12)),
            Expanded(child: Text(user.permission, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SettingsPage.blue))),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Edit Scope', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Revoke Permissions'),
                        content: Text('Are you sure you want to revoke all active grants for ${user.name}? This action is auditable.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Revoked permissions for ${user.name}. Logged.')));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: SettingsPage.red, foregroundColor: Colors.white),
                            child: const Text('Revoke'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: SettingsPage.red.withOpacity(0.1), foregroundColor: SettingsPage.red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Revoke Access', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccessMatrixCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Module Access Matrix', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: SettingsPage.dark)),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Module', style: TextStyle(fontSize: 11, color: SettingsPage.muted, fontWeight: FontWeight.w700))),
                Expanded(child: Center(child: Text('Farmer', style: TextStyle(fontSize: 11, color: SettingsPage.muted, fontWeight: FontWeight.w700)))),
                Expanded(child: Center(child: Text('Govt', style: TextStyle(fontSize: 11, color: SettingsPage.muted, fontWeight: FontWeight.w700)))),
                Expanded(child: Center(child: Text('Scout', style: TextStyle(fontSize: 11, color: SettingsPage.muted, fontWeight: FontWeight.w700)))),
              ],
            ),
          ),
          const Divider(height: 1),
          _MatrixRow(module: 'Farm Operations Hub', farmer: true, govt: true, scout: true),
          _MatrixRow(module: 'Satellite Intelligence', farmer: true, govt: true, scout: false),
          _MatrixRow(module: 'Drone Inspection Workspace', farmer: true, govt: false, scout: true),
          _MatrixRow(module: 'Irrigation Command Centre', farmer: true, govt: true, scout: false),
          _MatrixRow(module: 'Reports & Compliance Workspace', farmer: false, govt: true, scout: false),
          _MatrixRow(module: 'Access Control Console', farmer: false, govt: false, scout: false),
        ],
      ),
    );
  }
}

class _MatrixRow extends StatelessWidget {
  final String module;
  final bool farmer;
  final bool govt;
  final bool scout;

  const _MatrixRow({required this.module, required this.farmer, required this.govt, required this.scout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(module, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
          Expanded(child: Icon(farmer ? Icons.check_circle : Icons.cancel, color: farmer ? SettingsPage.green : SettingsPage.red, size: 18)),
          Expanded(child: Icon(govt ? Icons.check_circle : Icons.cancel, color: govt ? SettingsPage.green : SettingsPage.red, size: 18)),
          Expanded(child: Icon(scout ? Icons.check_circle : Icons.cancel, color: scout ? SettingsPage.green : SettingsPage.red, size: 18)),
        ],
      ),
    );
  }
}

class _PasskeyConsoleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temporary Passkey Grants', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: SettingsPage.dark)),
          const SizedBox(height: 6),
          const Text('Generate safe passkeys to unlock specific schemes or projects for temporary roles without exposing organization data.', style: TextStyle(color: SettingsPage.muted, fontSize: 12)),
          const Divider(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 340;
              final btnGenerate = ElevatedButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Generate Temp Passkey'),
                      content: const Text('Passkey valid for 4 hours will be generated for the Odzi canal upgrade crew.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Temporary passkey [VERDI-9988-X] generated and logged.')));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: SettingsPage.green, foregroundColor: Colors.white),
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.vpn_key_outlined, size: 16),
                label: const Text('Generate Key', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: SettingsPage.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              );
              final btnActive = OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Active Keys (1)', style: TextStyle(fontSize: 12)),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    btnGenerate,
                    const SizedBox(height: 8),
                    btnActive,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: btnGenerate),
                  const SizedBox(width: 8),
                  Expanded(child: btnActive),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL SETTINGS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _GeneralSettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appStateProvider).role;
    final isAdmin = role == UserRole.admin;
    final isFarmerOrExpert = role == UserRole.farmer || role == UserRole.expert;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () => _showProfileEditor(context, ref),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: SettingsPage.green.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.badge_outlined, color: SettingsPage.green, size: 20),
                  ),
                  title: const Text('Enterprise Profile & Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Manage legal company name, VAT/Tax ID, phone number, and KYC tier.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.palette_outlined, color: Color(0xFF6366F1), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appearance & Theme Mode',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const Text(
                                  'Select your visual theme preference for all platform modules.',
                                  style: TextStyle(fontSize: 11.5, color: SettingsPage.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildThemeButton(
                            context: context,
                            ref: ref,
                            title: 'Light Mode',
                            icon: Icons.light_mode_rounded,
                            mode: ThemeMode.light,
                            currentMode: ref.watch(themeModeProvider),
                          ),
                          const SizedBox(width: 8),
                          _buildThemeButton(
                            context: context,
                            ref: ref,
                            title: 'Dark Mode',
                            icon: Icons.dark_mode_rounded,
                            mode: ThemeMode.dark,
                            currentMode: ref.watch(themeModeProvider),
                          ),
                          const SizedBox(width: 8),
                          _buildThemeButton(
                            context: context,
                            ref: ref,
                            title: 'System Auto',
                            icon: Icons.brightness_auto_rounded,
                            mode: ThemeMode.system,
                            currentMode: ref.watch(themeModeProvider),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () => _showNotificationPreferencesDialog(context),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_active_outlined, color: Colors.blue, size: 20),
                  ),
                  title: const Text('Notification & SMS Channels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Configure instant WhatsApp dispatch alerts, SMS order receipts, and e-waybill emails.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () => _showSecurityDialog(context),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.security_outlined, color: Colors.purple, size: 20),
                  ),
                  title: const Text('Security & Two-Factor Authentication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Manage 2FA authenticator, biometric passkey login, and active device sessions.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ),
              if (isFarmerOrExpert) ...[
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    onTap: () => _showLoraGatewayDialog(context),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.sensors_outlined, color: Colors.teal, size: 20),
                    ),
                    title: const Text('LoRa Telemetry Gateway', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Configure physical soil sensors, flow-meters, and water pressure valves.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () => _showLanguageLocationDialog(context),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.language_outlined, color: Colors.amber, size: 20),
                  ),
                  title: const Text('Language, Currency & Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Select preferred local language (English, Shona, Ndebele) and primary currency.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ),
              if (!isAdmin) ...[
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Request Access Modification'),
                          content: const Text(
                            'To request access control changes, revoking access, or stakeholder privilege modifications, please draft an email to our support team at:\n\nsupport@verdi.ag',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.support_agent_outlined, color: Colors.orange, size: 20),
                    ),
                    title: const Text('Request Access Modification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Send a privilege upgrade or revocation request to support.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(appStateProvider.notifier).setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? SettingsPage.green.withOpacity(0.12) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? SettingsPage.green : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? SettingsPage.green : const Color(0xFF64748B),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? SettingsPage.green : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoraGatewayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.sensors, color: SettingsPage.green),
                  SizedBox(width: 8),
                  Text('LoRa Telemetry Gateways'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _gatewayStatusTile('Harare North Gateway', 'Online', true),
                    _gatewayStatusTile('Masvingo Scheme Hub', 'Online', true),
                    _gatewayStatusTile('Chiredzi South Node', 'Offline', false),
                    const Divider(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Active Sensors & Flow-meters', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    _sensorTile('Soil Probe A-12', 'Moisture: 38%', true, (val) {}),
                    _sensorTile('Soil Probe A-13', 'Moisture: 42%', true, (val) {}),
                    _sensorTile('Flow-meter F-01', 'Rate: 1.2 L/s', false, (val) {}),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _gatewayStatusTile(String name, String status, bool online) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text('Status: $status', style: TextStyle(color: online ? SettingsPage.green : SettingsPage.red, fontSize: 11)),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: online ? SettingsPage.green : SettingsPage.red,
        ),
      ),
    );
  }

  Widget _sensorTile(String name, String val, bool isActive, ValueChanged<bool?> onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(val, style: const TextStyle(color: SettingsPage.muted, fontSize: 11)),
            ],
          ),
          Switch(
            value: isActive,
            onChanged: (v) {},
            activeColor: SettingsPage.green,
          ),
        ],
      ),
    );
  }

  void _showLanguageLocationDialog(BuildContext context) {
    String selectedLang = 'English';
    String selectedRegion = 'Harare';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Language & Location Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedLang,
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Shona', child: Text('Shona (Chishona)')),
                      DropdownMenuItem(value: 'Ndebele', child: Text('Ndebele (IsiNdebele)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedLang = val);
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Region', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRegion,
                    items: const [
                      DropdownMenuItem(value: 'Harare', child: Text('Harare')),
                      DropdownMenuItem(value: 'Bulawayo', child: Text('Bulawayo')),
                      DropdownMenuItem(value: 'Mutare', child: Text('Mutare')),
                      DropdownMenuItem(value: 'Masvingo', child: Text('Masvingo')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedRegion = val);
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsPage.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNotificationPreferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool whatsapp = true;
          bool sms = true;
          bool emailWaybill = true;
          bool priceAlerts = true;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.notifications_active, color: Colors.blue),
                SizedBox(width: 8),
                Text('Notification Channels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('WhatsApp Instant Order Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Receive real-time harvest dispatch and waybill status on WhatsApp.', style: TextStyle(fontSize: 11, color: SettingsPage.muted)),
                    value: whatsapp,
                    activeColor: SettingsPage.green,
                    onChanged: (v) => setState(() => whatsapp = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('SMS Payment & Escrow Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Direct SMS alerts for EcoCash/RTGS deposits and releases.', style: TextStyle(fontSize: 11, color: SettingsPage.muted)),
                    value: sms,
                    activeColor: SettingsPage.green,
                    onChanged: (v) => setState(() => sms = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Automated e-Waybill & PDF Invoices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Email certified tax invoice PDFs upon delivery confirmation.', style: TextStyle(fontSize: 11, color: SettingsPage.muted)),
                    value: emailWaybill,
                    activeColor: SettingsPage.green,
                    onChanged: (v) => setState(() => emailWaybill = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('National Market Pulse Price Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Daily morning price indices for major commodity auction floors.', style: TextStyle(fontSize: 11, color: SettingsPage.muted)),
                    value: priceAlerts,
                    activeColor: SettingsPage.green,
                    onChanged: (v) => setState(() => priceAlerts = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification channels updated successfully.'), backgroundColor: Colors.blue),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text('Save Preferences'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool twoFactor = true;
          bool biometricPasskey = true;
          bool sessionAudit = true;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.security, color: Colors.purple),
                SizedBox(width: 8),
                Text('Security & Authentication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Two-Factor Authentication (2FA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Require OTP on high-value trade contract and payout disbursements.', style: TextStyle(fontSize: 11, color: SettingsPage.muted)),
                    value: twoFactor,
                    activeColor: Colors.purple,
                    onChanged: (v) => setState(() => twoFactor = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Biometric Passkey Login (WebAuthn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Enable fingerprint / FaceID passwordless signing on authorized devices.', style: TextStyle(fontSize: 11, color: SettingsPage.muted)),
                    value: biometricPasskey,
                    activeColor: Colors.purple,
                    onChanged: (v) => setState(() => biometricPasskey = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Session Anomaly & Geolocation Shield', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Instant alert and lockdown if login IP originates outside registered corridor.', style: TextStyle(fontSize: 11, color: SettingsPage.muted)),
                    value: sessionAudit,
                    activeColor: Colors.purple,
                    onChanged: (v) => setState(() => sessionAudit = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Security parameters updated and logged.'), backgroundColor: Colors.purple),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                child: const Text('Update Security'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showProfileEditor(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    final user = authState.user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: '+263 77 412 9081');
    final companyController = TextEditingController(text: 'Southern Fresh & Agri Trade Syndicate');
    final vatController = TextEditingController(text: 'VAT-ZIM-994201-B');
    final addressController = TextEditingController(text: '14 Avondale West / Workington Hub, Harare');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: SettingsPage.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.badge_outlined, color: SettingsPage.green, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Enterprise Profile Preferences',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KYC Verification Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF86EFAC))),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Color(0xFF16A34A), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Tier-3 Enterprise KYC Verified • SADC Cross-Border Sourcing Approved', style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Full Name / Representative', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  prefixIcon: const Icon(Icons.person_outline, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              const Text('Business Email Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  prefixIcon: const Icon(Icons.email_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              const Text('Direct Mobile / WhatsApp Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: '+263 ...',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              const Text('Company / Legal Trading Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: companyController,
                decoration: InputDecoration(
                  hintText: 'Enter trading entity name',
                  prefixIcon: const Icon(Icons.business_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              const Text('Tax / VAT Registration Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: vatController,
                decoration: InputDecoration(
                  hintText: 'VAT-ZIM-...',
                  prefixIcon: const Icon(Icons.receipt_long_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              const Text('Physical / Receiving Warehouse Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Enter physical delivery address',
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              if (name.isEmpty || email.isEmpty) return;

              Navigator.pop(context);
              
              await ref.read(authStateProvider.notifier).updateProfile(
                fullName: name,
                email: email,
                role: user.role,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enterprise profile & identity updated successfully.'), backgroundColor: SettingsPage.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _UserScope {
  final String name;
  final String role;
  final String scope;
  final String permission;
  final int activeGrants;

  const _UserScope({
    required this.name,
    required this.role,
    required this.scope,
    required this.permission,
    required this.activeGrants,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSPORTER CARRIER SETTINGS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _CarrierSettingsTab extends ConsumerWidget {
  const _CarrierSettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const amber = Color(0xFFFF9F1C);
    const green = Color(0xFF16A34A);
    const dark = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: amber.withOpacity(0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.sensors, color: amber, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('In-Cab Telematics Hardware & Sensor Pairing', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: dark)),
                          const Text('Configure hardware gateways connected to your vehicle assets.', style: TextStyle(color: muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _settingItem('OBD-II CAN-Bus Telematics Gateway', 'AEB-2910 • 4G LTE Live GPS Stream', 'PAIRED', green),
                const Divider(height: 20),
                _settingItem('Reefer Temperature Probe #1 (Chamber)', 'Target: +2°C to +6°C • Current: +3.4°C', 'CALIBRATED', const Color(0xFF00B4D8)),
                const Divider(height: 20),
                _settingItem('SADC Corridor Transit Permit', 'EUDR-LOG-ZIM-2026-88 • Beira & Chirundu Corridors', 'ACTIVE', amber),
                const Divider(height: 20),
                _settingItem('Freight Escrow Payout Wallet', 'EcoCash USD Gateway (Direct Settlement)', 'CONNECTED', green),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sovereign Verified Carrier Status', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: dark)),
                const SizedBox(height: 6),
                const Text('Your account is eligible for automatic smart contract escrow release upon e-POD signoff.', style: TextStyle(color: muted, fontSize: 12)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: amber.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.military_tech_outlined, color: amber, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '🎖️ Gold Sovereign Carrier Ribbon Active (28 Completed Trips)',
                          style: TextStyle(color: amber, fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingItem(String title, String subtitle, String badge, Color badgeColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeColor.withOpacity(0.4)),
          ),
          child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMMERCIAL BUYER (B2B) SETTINGS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _CommercialBuyerSettingsTab extends ConsumerStatefulWidget {
  const _CommercialBuyerSettingsTab();

  @override
  ConsumerState<_CommercialBuyerSettingsTab> createState() => _CommercialBuyerSettingsTabState();
}

class _CommercialBuyerSettingsTabState extends ConsumerState<_CommercialBuyerSettingsTab> {
  bool _autoRejectColdChain = true;
  bool _requireWeighbridge = true;
  bool _autoReleaseEscrow = true;
  final String _selectedLotSize = '5 Metric Tonnes (Standard)';
  final String _selectedMoisture = 'Max 12.5% (Export Grade)';
  final String _selectedWarehouse = 'Workington Central Depot (Bay 4, Harare)';
  final String _selectedEscrowBank = 'Stanbic Corporate USD Escrow';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Enterprise Profile Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business_center, color: Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Southern Fresh Wholesalers Ltd',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Commercial Wholesale & Procurement Entity • VAT-ZIM-994201-B',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Procurement & Quality Tolerances
          _buildSectionHeader(Icons.fact_check_outlined, 'Procurement Quality & Intake Tolerances', const Color(0xFF2563EB)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Minimum Sourcing Lot Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: Text(_selectedLotSize, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: const Icon(Icons.tune, color: Color(0xFF2563EB), size: 20),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Max Grain Moisture Content Threshold', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: Text(_selectedMoisture, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: const Icon(Icons.water_drop_outlined, color: Color(0xFF2563EB), size: 20),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-Reject on Reefer Cold-Chain Deviation (> 8°C)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: const Text('Instantly flag consignment when telemetry breaches perishable food threshold', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  value: _autoRejectColdChain,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => setState(() => _autoRejectColdChain = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Receiving Warehouse Logistics
          _buildSectionHeader(Icons.warehouse_outlined, 'Receiving Warehouse & Offloading Bays', const Color(0xFF2563EB)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Primary Receiving Warehouse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: Text(_selectedWarehouse, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: const Icon(Icons.location_city_outlined, color: Color(0xFF2563EB), size: 20),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mandatory Inbound Weighbridge Calibration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: const Text('Require calibrated scale weigh slip before offload seal release', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  value: _requireWeighbridge,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => setState(() => _requireWeighbridge = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Commercial Escrow & Settlement Terms
          _buildSectionHeader(Icons.account_balance_outlined, 'Commercial Escrow & Corporate Settlements', const Color(0xFF2563EB)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Corporate Settlement Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: Text(_selectedEscrowBank, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: const Icon(Icons.credit_card, color: Color(0xFF2563EB), size: 20),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Smart Contract Escrow Auto-Settlement upon e-POD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: const Text('Funds release automatically to supplier when digital consignment receipt is signed', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  value: _autoReleaseEscrow,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => setState(() => _autoReleaseEscrow = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// END-USER CONSUMER SETTINGS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _ConsumerSettingsTab extends ConsumerStatefulWidget {
  const _ConsumerSettingsTab();

  @override
  ConsumerState<_ConsumerSettingsTab> createState() => _ConsumerSettingsTabState();
}

class _ConsumerSettingsTabState extends ConsumerState<_ConsumerSettingsTab> {
  bool _notifyPromos = true;
  bool _notifyChats = true;
  bool _notifyDriverArrival = true;

  String _selectedPaymentMethod = 'EcoCash Wallet (077 412 9081)';
  String _selectedAddress = '14 Avondale West, Harare (Home Delivery)';

  final List<String> _addresses = [
    '14 Avondale West, Harare (Home Delivery)',
    'Shop 4, Borrowdale Village, Harare (Office)',
    'Farm Gate Hub 2, Mazowe Highway (Pickup Point)',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile & Role Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.person, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer / End-User Profile', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      const Text('Direct Farm-to-Table Grocery & Household Consumer', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Delivery Addresses
          _buildSectionHeader(Icons.location_on_outlined, 'Delivery Addresses'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ..._addresses.map((addr) => RadioListTile<String>(
                  title: Text(addr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  value: addr,
                  groupValue: _selectedAddress,
                  activeColor: const Color(0xFF10B981),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAddress = val);
                  },
                )),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add new delivery address dialog opened.'), backgroundColor: Color(0xFF10B981)),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New Delivery Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF10B981), side: const BorderSide(color: Color(0xFF10B981))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Payment Methods
          _buildSectionHeader(Icons.account_balance_wallet_outlined, 'Payment Methods'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildPaymentTile('EcoCash Wallet (077 412 9081)', Icons.phone_android, const Color(0xFF16A34A)),
                _buildPaymentTile('InnBucks QR Code', Icons.qr_code_2, const Color(0xFFF59E0B)),
                _buildPaymentTile('Cash on Delivery', Icons.payments_outlined, const Color(0xFF3B82F6)),
                _buildPaymentTile('Visa / Mastercard (•••• 8812)', Icons.credit_card, const Color(0xFF6366F1)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Push Notifications & Alerts
          _buildSectionHeader(Icons.notifications_active_outlined, 'Push Notification Alerts'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Flash Sales & Fresh Harvest Deals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: const Text('Instant pop-up alerts when nearby farmers offer discounts', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  value: _notifyPromos,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _notifyPromos = v),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                SwitchListTile(
                  title: const Text('Direct Messages from Transporters & Farmers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: const Text('Receive immediate in-app chat notifications and ETA updates', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  value: _notifyChats,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _notifyChats = v),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                SwitchListTile(
                  title: const Text('InDrive Delivery Arrival Pop-Ups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  subtitle: const Text('Sound alert when transporter is within 5 minutes of your gate', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  value: _notifyDriverArrival,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _notifyDriverArrival = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Preferred Currency
          _buildSectionHeader(Icons.currency_exchange, 'Currency Display'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: AppCurrency.values.map((c) {
                final isSel = state.currency == c;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => notifier.setCurrency(c),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF10B981).withOpacity(0.12) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Text(c.flag, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(c.code, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? const Color(0xFF10B981) : const Color(0xFF0F172A), fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // 6. Appearance & Theme Mode
          _buildSectionHeader(Icons.palette_outlined, 'Appearance & Theme Mode'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildConsumerThemeButton(
                  title: 'Light Mode',
                  icon: Icons.light_mode_rounded,
                  mode: ThemeMode.light,
                  currentMode: ref.watch(themeModeProvider),
                  onSelect: (m) => notifier.setThemeMode(m),
                ),
                const SizedBox(width: 8),
                _buildConsumerThemeButton(
                  title: 'Dark Mode',
                  icon: Icons.dark_mode_rounded,
                  mode: ThemeMode.dark,
                  currentMode: ref.watch(themeModeProvider),
                  onSelect: (m) => notifier.setThemeMode(m),
                ),
                const SizedBox(width: 8),
                _buildConsumerThemeButton(
                  title: 'System Auto',
                  icon: Icons.brightness_auto_rounded,
                  mode: ThemeMode.system,
                  currentMode: ref.watch(themeModeProvider),
                  onSelect: (m) => notifier.setThemeMode(m),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildConsumerThemeButton({
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required ValueChanged<ThemeMode> onSelect,
  }) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981).withOpacity(0.12) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF10B981) : const Color(0xFF64748B),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF10B981)),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(String name, IconData icon, Color color) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
      value: name,
      groupValue: _selectedPaymentMethod,
      activeColor: const Color(0xFF10B981),
      contentPadding: EdgeInsets.zero,
      onChanged: (val) {
        if (val != null) setState(() => _selectedPaymentMethod = val);
      },
    );
  }
}

class _AgriExpertSettingsTab extends ConsumerStatefulWidget {
  const _AgriExpertSettingsTab();

  @override
  ConsumerState<_AgriExpertSettingsTab> createState() => _AgriExpertSettingsTabState();
}

class _AgriExpertSettingsTabState extends ConsumerState<_AgriExpertSettingsTab> {
  final _hourlyCtrl = TextEditingController();
  final _visitCtrl = TextEditingController();
  final _retainerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(agriExpertProvider).profile;
    _hourlyCtrl.text = profile.hourlyRateUsd.toStringAsFixed(0);
    _visitCtrl.text = profile.farmVisitRateUsd.toStringAsFixed(0);
    _retainerCtrl.text = profile.monthlyRetainerRateUsd.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _hourlyCtrl.dispose();
    _visitCtrl.dispose();
    _retainerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final persona = appState.expertPersona;
    final expertState = ref.watch(agriExpertProvider);
    final profile = expertState.profile;
    final isStateVerified = persona == ExpertPersona.governmentExtension || profile.isVerifiedByState;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Active Persona & Inquiries
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: persona.color.withOpacity(0.12),
                        child: Icon(persona.icon, color: persona.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(persona.label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                                const SizedBox(width: 8),
                                if (isStateVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('VERIFIED BY STATE', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            Text('Classification status: Immutable Registered Role', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showInquiryModal(context, persona),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Change Inquiry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Practice Rates
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Advisory Service Rates (USD)', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Set your public rates displayed to farmers on the marketplace.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hourlyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Hourly Rate', prefixText: '\$ ', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _visitCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Farm Visit Rate', prefixText: '\$ ', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _retainerCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monthly Precision Retainer', prefixText: '\$ ', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final h = double.tryParse(_hourlyCtrl.text.trim()) ?? profile.hourlyRateUsd;
                      final v = double.tryParse(_visitCtrl.text.trim()) ?? profile.farmVisitRateUsd;
                      final r = double.tryParse(_retainerCtrl.text.trim()) ?? profile.monthlyRetainerRateUsd;
                      ref.read(agriExpertProvider.notifier).updateRates(hourlyRate: h, farmVisitRate: v, monthlyRetainer: r);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Advisory rates updated successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Advisory Rates', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInquiryModal(BuildContext context, ExpertPersona current) {
    final reasonCtrl = TextEditingController();
    ExpertPersona req = ExpertPersona.governmentExtension;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Submit Persona Change Inquiry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ExpertPersona>(
                value: req,
                items: ExpertPersona.values.where((p) => p != current).map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
                onChanged: (v) => setS(() => req = v ?? req),
                decoration: const InputDecoration(labelText: 'Requested Persona', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Justification for Verification Board', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final inquiry = PersonaChangeInquiry(
                  id: 'INQ-${DateTime.now().millisecondsSinceEpoch % 1000}',
                  expertId: 'EXP-01',
                  expertName: 'Dr. Nyasha Sibanda',
                  currentPersona: current,
                  requestedPersona: req,
                  justification: reasonCtrl.text.trim(),
                  accreditationRef: 'ZAPB-INQ-2026',
                  submittedAt: 'Just now',
                );
                ref.read(agriExpertProvider.notifier).submitPersonaChangeInquiry(inquiry);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inquiry submitted to National Verification Board.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}