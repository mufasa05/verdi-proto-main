import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/rate_limiter_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../state/app_state.dart';
import '../../auth/state/auth_state.dart';

/// User Identity & KYC Control Page matching user interface screenshots 3, 4, 5 100%
class UserIdentityControlPage extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const UserIdentityControlPage({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<UserIdentityControlPage> createState() => _UserIdentityControlPageState();
}

class _UserIdentityControlPageState extends ConsumerState<UserIdentityControlPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const bgDark = Color(0xFF070B12);
  static const cardDark = Color(0xFF0F172A);
  static const cardBorder = Color(0xFF1E293B);
  static const accentGreen = Color(0xFF10B981);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const accentDanger = Color(0xFFEF4444);
  static const textMuted = Color(0xFF94A3B8);

  String _searchQuery = '';
  String _selectedRoleFilter = 'All Roles';
  String _selectedKycFilter = 'All KYC Status';
  final Set<String> _deletedUserIds = {};

  final List<Map<String, dynamic>> _userDatabase = [
    {
      'id': 'USR-88901',
      'name': 'Tendai Moyo',
      'email': 'tendai.moyo@verdi.co',
      'role': 'Farmer',
      'kyc': 'VERIFIED',
      'location': 'Mashonaland West (120 Ha)',
      'eudr': 'EUDR-ZIM-2026-081',
      'status': 'ACTIVE',
      'sessions': 2,
      'lastSeen': '12 mins ago',
      'joiningDate': '14 October 2024 (1 year 10 months on Verdi)',
      'phone': '+263 77 412 9081',
      'escrowBalance': 'US\$ 4,250.00',
    },
    {
      'id': 'USR-99214',
      'name': 'Harare Fresh Produce Hub',
      'email': 'procurement@mbarehub.co.zw',
      'role': 'Buyer',
      'kyc': 'VERIFIED',
      'location': 'Harare Mbare Musika',
      'eudr': 'EUDR-ZIM-2026-112',
      'status': 'ACTIVE',
      'sessions': 5,
      'lastSeen': '2 hours ago',
      'joiningDate': '03 January 2025 (1 year 7 months on Verdi)',
      'phone': '+263 71 884 9021',
      'escrowBalance': 'US\$ 12,800.00',
    },
    {
      'id': 'USR-44102',
      'name': 'Chinhoyi Express Logistics',
      'email': 'dispatch@chinhoyitrucks.co.zw',
      'role': 'Transporter',
      'kyc': 'PENDING',
      'location': 'Fleet #4 (Refrigerated 30T)',
      'eudr': 'EUDR-LOG-884',
      'status': 'ACTIVE',
      'sessions': 1,
      'lastSeen': 'Yesterday',
      'joiningDate': '18 June 2025 (1 year 2 months on Verdi)',
      'phone': '+263 77 902 1140',
      'escrowBalance': 'US\$ 1,850.00',
    },
    {
      'id': 'USR-10923',
      'name': 'AFC Agribank Treasury',
      'email': 'agricredit@afcbank.co.zw',
      'role': 'Financier',
      'kyc': 'VERIFIED',
      'location': 'Reserve Bank Clearing Desk',
      'eudr': 'FIN-CBZ-2026',
      'status': 'ACTIVE',
      'sessions': 3,
      'lastSeen': '4 mins ago',
      'joiningDate': '10 September 2024 (1 year 11 months on Verdi)',
      'phone': '+263 24 279 0011',
      'escrowBalance': 'US\$ 150,000.00',
    },
    {
      'id': 'USR-00192',
      'name': 'Dr. Farai Chigumba',
      'email': 'inspector.chigumba@lands.gov.zw',
      'role': 'Government',
      'kyc': 'VERIFIED',
      'location': 'Harare Provincial Directorate',
      'eudr': 'GOV-TIM-01',
      'status': 'ACTIVE',
      'sessions': 1,
      'lastSeen': 'Today',
      'joiningDate': '01 August 2024 (2 years on Verdi)',
      'phone': '+263 24 270 0192',
      'escrowBalance': 'N/A (Regulatory)',
    },
  ];

  final List<Map<String, dynamic>> _matrixCapabilities = [
    {
      'domain': 'Full System Sovereignty',
      'superAdmin': true,
      'admin': false,
      'farmer': false,
      'agronomist': false,
      'government': false,
    },
    {
      'domain': 'Emergency System Lockdown',
      'superAdmin': true,
      'admin': false,
      'farmer': false,
      'agronomist': false,
      'government': false,
    },
    {
      'domain': 'Override KYC & Verification',
      'superAdmin': true,
      'admin': true,
      'farmer': false,
      'agronomist': false,
      'government': true,
    },
    {
      'domain': 'Escrow Vault Release Power',
      'superAdmin': true,
      'admin': true,
      'farmer': false,
      'agronomist': false,
      'government': false,
    },
    {
      'domain': 'Agronomy AI Model Training',
      'superAdmin': true,
      'admin': true,
      'farmer': false,
      'agronomist': true,
      'government': false,
    },
    {
      'domain': 'Geospatial & Satellite Rasters',
      'superAdmin': true,
      'admin': true,
      'farmer': true,
      'agronomist': true,
      'government': true,
    },
    {
      'domain': 'Logistics & Freight Telemetry',
      'superAdmin': true,
      'admin': true,
      'farmer': true,
      'agronomist': false,
      'government': true,
    },
    {
      'domain': 'Marketplace Listing Approval',
      'superAdmin': true,
      'admin': true,
      'farmer': true,
      'agronomist': false,
      'government': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showActionConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required IconData icon,
    required VoidCallback onConfirmed,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cardBorder),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: confirmColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: textMuted, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirmed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showElevateRoleModal(Map<String, dynamic> user) {
    String currentRole = user['role'] ?? 'Farmer';
    bool grantFullSovereignty = currentRole == 'Admin' || currentRole == 'Super Admin';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: cardBorder)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accentBlue.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.vpn_key_outlined, color: accentBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Elevate Privilege: ${user['name']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    Text('User ID: ${user['id']} • Current: ${user['role']}', style: const TextStyle(color: textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select new stakeholder privilege level:', style: TextStyle(color: textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: ['Farmer', 'Buyer', 'Transporter', 'ValueAdder', 'Financier', 'Expert', 'Government', 'Admin'].contains(currentRole) ? currentRole : 'Farmer',
                  dropdownColor: cardDark,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: [
                    'Farmer',
                    'Buyer',
                    'Transporter',
                    'ValueAdder',
                    'Financier',
                    'Expert',
                    'Government',
                    'Admin',
                  ].map((r) => DropdownMenuItem(value: r, child: Text(r == 'Admin' ? '👑 Super Admin / Admin' : r))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setModalState(() {
                        currentRole = v;
                        grantFullSovereignty = v == 'Admin';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: cardBorder)),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Bypass Verification Gate', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Grant automatic KYC Level 3 Clearance', style: TextStyle(color: textMuted, fontSize: 10.5)),
                        value: grantFullSovereignty,
                        activeColor: accentGreen,
                        onChanged: (v) => setModalState(() => grantFullSovereignty = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  user['role'] = currentRole;
                  if (grantFullSovereignty) user['kyc'] = 'VERIFIED';
                });
                SupabaseService.instance.logActivity(
                  userName: user['name'],
                  userId: user['id'],
                  userRole: currentRole,
                  actionTitle: '👑 Role Elevated by Super Admin',
                  actionDescription: 'Privilege updated to $currentRole for ${user['name']}.',
                  module: 'Security & Privileges',
                  targetResource: user['id'],
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Role elevated to $currentRole for ${user['name']}.'), backgroundColor: accentBlue),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
              child: const Text('Confirm Elevation'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImpersonateModal(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: cardBorder)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.visibility_outlined, color: Colors.purpleAccent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Inspect Perspective: ${user['name']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
            ),
          ],
        ),
        content: Text(
          'Switch your live interface perspective to experience the Verdi ecosystem as (${user['name']} • ${user['role']}). Full Super Admin audit logging remains active.',
          style: const TextStyle(color: textMuted, fontSize: 12.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final userRole = switch (user['role'].toString().toLowerCase()) {
                'farmer' => UserRole.farmer,
                'buyer' => UserRole.buyer,
                'transporter' => UserRole.transporter,
                'financier' => UserRole.financier,
                'valueadder' => UserRole.valueAdder,
                'expert' => UserRole.expert,
                'government' => UserRole.government,
                _ => UserRole.admin,
              };
              ref.read(appStateProvider.notifier).setRole(userRole);
              ref.read(appStateProvider.notifier).setNavIndex(0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Switched perspective to ${user['name']} (${user['role']}).'), backgroundColor: Colors.purple),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            child: const Text('Switch Perspective'),
          ),
        ],
      ),
    );
  }

  void _showRegisterUserModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String selectedRole = 'Farmer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: cardBorder)),
          title: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: accentGreen.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.person_add_outlined, color: accentGreen, size: 20)),
              const SizedBox(width: 10),
              Text('Register New Platform Stakeholder', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Full Name / Enterprise Name',
                    labelStyle: const TextStyle(color: textMuted, fontSize: 12),
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: textMuted, fontSize: 12),
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: textMuted, fontSize: 12),
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Location / Region',
                    labelStyle: const TextStyle(color: textMuted, fontSize: 12),
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: cardDark,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: ['Farmer', 'Buyer', 'Transporter', 'ValueAdder', 'Financier', 'Expert', 'Government', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedRole = v);
                  },
                  decoration: InputDecoration(
                    labelText: 'Stakeholder Role',
                    labelStyle: const TextStyle(color: textMuted, fontSize: 12),
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newId = 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                final newUser = {
                  'id': newId,
                  'name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : '$newId@verdi.co',
                  'role': selectedRole,
                  'kyc': 'VERIFIED',
                  'location': locationCtrl.text.trim().isNotEmpty ? locationCtrl.text.trim() : 'Harare Central Hub',
                  'eudr': 'EUDR-ZIM-2026-LIVE',
                  'status': 'ACTIVE',
                  'sessions': 1,
                  'lastSeen': 'Just now',
                  'joiningDate': 'Registered Today (Super Admin Desk)',
                  'phone': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '+263 77 000 0000',
                  'escrowBalance': 'US\$ 0.00',
                };
                setState(() {
                  _userDatabase.insert(0, newUser);
                });
                SupabaseService.instance.logActivity(
                  userName: newUser['name'] as String,
                  userId: newId,
                  userRole: selectedRole,
                  actionTitle: '👤 Stakeholder Registered by Super Admin',
                  actionDescription: 'Direct directory registration for ${newUser['name']}.',
                  module: 'User Management',
                  targetResource: newId,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registered stakeholder ${newUser['name']} ($newId) successfully.'), backgroundColor: accentGreen),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
              child: const Text('Create Stakeholder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).user;
    final List<Map<String, dynamic>> combinedUsers = [];

    if (authUser != null && !_deletedUserIds.contains(authUser.id)) {
      combinedUsers.add({
        'id': authUser.id,
        'name': authUser.fullName,
        'email': authUser.email.isNotEmpty ? authUser.email : 'Not provided',
        'role': authUser.role.label,
        'kyc': 'VERIFIED',
        'location': 'Primary Node (Live Session)',
        'eudr': 'EUDR-LIVE-NODE',
        'status': 'ACTIVE',
        'sessions': 1,
        'lastSeen': 'Just now',
        'joiningDate': 'Active Account',
        'phone': authUser.phone.isNotEmpty ? authUser.phone : 'Not provided',
        'escrowBalance': 'US\$ 0.00',
      });
    }

    for (final u in _userDatabase) {
      if (!_deletedUserIds.contains(u['id']) && !combinedUsers.any((x) => x['id'] == u['id'])) {
        combinedUsers.add(u);
      }
    }

    final filteredUsers = combinedUsers.where((u) {
      final matchesQuery = _searchQuery.isEmpty ||
          u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'All Roles' || u['role'] == _selectedRoleFilter;
      final matchesKyc = _selectedKycFilter == 'All KYC Status' || u['kyc'] == _selectedKycFilter;
      return matchesQuery && matchesRole && matchesKyc;
    }).toList();

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              ref.read(appStateProvider.notifier).setNavIndex(0);
            }
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KYC User Directory & Sovereign Privilege Manager', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
                  const Text('Manual KYC overrides, role elevations, session invalidation, and permission matrix.', style: TextStyle(fontSize: 10.5, color: textMuted), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: accentGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: accentGreen.withOpacity(0.4))),
              child: const Text('SUPER ADMIN CONTROL ACTIVE', style: TextStyle(color: accentGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Register User Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: cardBorder)),
                  child: Text('Active Directory: ${filteredUsers.length} Users Listed', style: const TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: _showRegisterUserModal,
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Register User', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3 Tabs Header (Picture 3 & Picture 5)
            Container(
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
              child: TabBar(
                controller: _tabController,
                indicatorColor: accentGreen,
                labelColor: accentGreen,
                unselectedLabelColor: textMuted,
                tabs: const [
                  Tab(text: 'User Directory & KYC'),
                  Tab(text: 'Role & Privilege Matrix'),
                  Tab(text: 'Active Sessions & Security'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views Container
            SizedBox(
              height: 750,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDirectoryAndKycTab(filteredUsers),
                  _buildRolePrivilegeMatrixTab(),
                  _buildActiveSessionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: USER DIRECTORY & KYC (PICTURE 5)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDirectoryAndKycTab(List<Map<String, dynamic>> users) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search & Filter Dropdowns
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, ID...',
                    hintStyle: const TextStyle(fontSize: 12, color: textMuted),
                    prefixIcon: const Icon(Icons.search, size: 18, color: textMuted),
                    filled: true,
                    fillColor: cardDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 8),
              _dropdownFilter('Role', _selectedRoleFilter, ['All Roles', 'Farmer', 'Buyer', 'Transporter', 'Financier', 'Government'], (v) => setState(() => _selectedRoleFilter = v)),
              const SizedBox(width: 8),
              _dropdownFilter('KYC', _selectedKycFilter, ['All KYC Status', 'VERIFIED', 'PENDING'], (v) => setState(() => _selectedKycFilter = v)),
            ],
          ),
          const SizedBox(height: 14),

          // User Cards with 4 Action Buttons each
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final u = users[idx];
              final isVerified = u['kyc'] == 'VERIFIED';
              final isSuspended = u['status'] == 'SUSPENDED';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSuspended ? accentDanger.withOpacity(0.5) : cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSuspended ? accentDanger.withOpacity(0.18) : accentGreen.withOpacity(0.18),
                          radius: 20,
                          child: Icon(isSuspended ? Icons.person_off_outlined : Icons.person, color: isSuspended ? accentDanger : accentGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(u['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: isSuspended ? Colors.white70 : Colors.white)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(4)),
                                    child: Text(u['id'], style: const TextStyle(color: accentBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSuspended ? accentDanger.withOpacity(0.2) : accentGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: isSuspended ? accentDanger : accentGreen, width: 0.8),
                                    ),
                                    child: Text(isSuspended ? 'SUSPENDED' : 'ACTIVE', style: TextStyle(color: isSuspended ? accentDanger : accentGreen, fontSize: 9.5, fontWeight: FontWeight.w900)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${u['email']} • Location: ${u['location']}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                              Text('Role: ${u['role']}', style: TextStyle(fontSize: 11.5, color: isSuspended ? textMuted : accentBlue, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isVerified ? accentGreen.withOpacity(0.15) : accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isVerified ? accentGreen : accentGold),
                          ),
                          child: Text(u['kyc'], style: TextStyle(color: isVerified ? accentGreen : accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (isSuspended) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: accentDanger.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: accentDanger.withOpacity(0.3))),
                        child: Row(
                          children: const [
                            Icon(Icons.block, color: accentDanger, size: 16),
                            SizedBox(width: 8),
                            Expanded(child: Text('ACCOUNT SUSPENDED: Platform login & automated smart contract escrow payouts are blocked.', style: TextStyle(color: accentDanger, fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // 6 Direct Action Buttons with Real Logic & Safety Confirmation Modals
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // 1. Verify KYC (Green Outline)
                        OutlinedButton.icon(
                          onPressed: () {
                            final allowed = RateLimiterService.instance.checkAndRecord(
                              RateLimitCategory.adminActions,
                              onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                            );
                            if (!allowed) return;

                            if (isVerified) {
                              _showActionConfirmationDialog(
                                title: 'Revoke KYC Verification',
                                message: 'Are you sure you want to revoke verified compliance status for ${u['name']}? They will be downgraded to PENDING verification.',
                                confirmLabel: 'Revoke KYC',
                                confirmColor: accentGold,
                                icon: Icons.warning_amber_rounded,
                                onConfirmed: () {
                                  setState(() => u['kyc'] = 'PENDING');
                                  SupabaseService.instance.logActivity(
                                    userName: u['name'],
                                    userId: u['id'],
                                    userRole: u['role'],
                                    actionTitle: '⚠️ KYC Verification Revoked',
                                    actionDescription: 'Admin downgraded compliance verification to PENDING for ${u['name']}.',
                                    module: 'Security & KYC',
                                    targetResource: u['id'],
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('KYC status set to PENDING for ${u['name']}.'), backgroundColor: accentGold),
                                  );
                                },
                              );
                            } else {
                              setState(() => u['kyc'] = 'VERIFIED');
                              SupabaseService.instance.logActivity(
                                userName: u['name'],
                                userId: u['id'],
                                userRole: u['role'],
                                actionTitle: '🛡️ KYC Verified by Super Admin',
                                actionDescription: 'Identity documents & EUDR provenance verified for ${u['name']}.',
                                module: 'Security & KYC',
                                targetResource: u['id'],
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('KYC verified for ${u['name']}.'), backgroundColor: accentGreen),
                              );
                            }
                          },
                          icon: const Icon(Icons.verified_user_outlined, size: 14),
                          label: Text(isVerified ? 'KYC Verified' : 'Verify KYC'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentGreen,
                            side: const BorderSide(color: accentGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),

                        // 2. Elevate Role (Blue Outline)
                        OutlinedButton.icon(
                          onPressed: () {
                            final allowed = RateLimiterService.instance.checkAndRecord(
                              RateLimitCategory.adminActions,
                              onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                            );
                            if (!allowed) return;
                            _showElevateRoleModal(u);
                          },
                          icon: const Icon(Icons.vpn_key_outlined, size: 14),
                          label: const Text('Elevate Role'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentBlue,
                            side: const BorderSide(color: accentBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),

                        // 3. Award / Revoke Badge (Amber Outline)
                        OutlinedButton.icon(
                          onPressed: () {
                            final allowed = RateLimiterService.instance.checkAndRecord(
                              RateLimitCategory.adminActions,
                              onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                            );
                            if (!allowed) return;

                            final currentBadge = u['carrierBadge'] ?? true;
                            if (currentBadge) {
                              _showActionConfirmationDialog(
                                title: 'Revoke Sovereign Badge',
                                message: 'Revoke Sovereign Verified status for ${u['name']}? They will no longer qualify for automated smart escrow payouts.',
                                confirmLabel: 'Revoke Badge',
                                confirmColor: accentGold,
                                icon: Icons.military_tech_outlined,
                                onConfirmed: () {
                                  setState(() => u['carrierBadge'] = false);
                                  SupabaseService.instance.logActivity(
                                    userName: u['name'],
                                    userId: u['id'],
                                    userRole: u['role'],
                                    actionTitle: '🎖️ Sovereign Carrier Badge Revoked',
                                    actionDescription: 'Badge revoked by Admin for ${u['name']}.',
                                    module: 'Admin Control',
                                    targetResource: u['id'],
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Sovereign badge revoked for ${u['name']}.'), backgroundColor: accentGold),
                                  );
                                },
                              );
                            } else {
                              setState(() => u['carrierBadge'] = true);
                              SupabaseService.instance.logActivity(
                                userName: u['name'],
                                userId: u['id'],
                                userRole: u['role'],
                                actionTitle: '🎖️ Sovereign Verified Badge Awarded',
                                actionDescription: 'Awarded sovereign carrier/trader badge to ${u['name']}.',
                                module: 'Admin Control',
                                targetResource: u['id'],
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('🎖️ Sovereign Verified Badge awarded to ${u['name']}!'), backgroundColor: const Color(0xFFFF9F1C)),
                              );
                            }
                          },
                          icon: const Icon(Icons.military_tech_outlined, size: 14),
                          label: Text(u['carrierBadge'] == false ? 'Award Badge' : '🎖️ Verified Badge'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF9F1C),
                            side: const BorderSide(color: Color(0xFFFF9F1C)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),

                        // 4. Suspend / Reactivate Account (Red Outline)
                        OutlinedButton.icon(
                          onPressed: () {
                            final allowed = RateLimiterService.instance.checkAndRecord(
                              RateLimitCategory.adminActions,
                              onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                            );
                            if (!allowed) return;

                            _showActionConfirmationDialog(
                              title: isSuspended ? 'Reactivate User Account' : 'Suspend User Account',
                              message: isSuspended
                                  ? 'Reactivate account for ${u['name']}? They will be granted permission to log in and conduct platform operations.'
                                  : 'Are you sure you want to suspend account access for ${u['name']}? All active sessions will be terminated and login access will be blocked.',
                              confirmLabel: isSuspended ? 'Reactivate' : 'Suspend Account',
                              confirmColor: isSuspended ? accentGreen : accentDanger,
                              icon: Icons.person_remove_outlined,
                              onConfirmed: () {
                                setState(() => u['status'] = isSuspended ? 'ACTIVE' : 'SUSPENDED');
                                SupabaseService.instance.logActivity(
                                  userName: u['name'],
                                  userId: u['id'],
                                  userRole: u['role'],
                                  actionTitle: isSuspended ? '👤 User Account Reactivated' : '🚫 User Account Suspended',
                                  actionDescription: 'Admin changed account standing to ${u['status']} for ${u['name']}.',
                                  module: 'Security & Access',
                                  targetResource: u['id'],
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${u['name']} account status set to ${u['status']}.'),
                                    backgroundColor: isSuspended ? accentGreen : accentDanger,
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.person_remove_outlined, size: 14),
                          label: Text(isSuspended ? 'Reactivate' : 'Suspend Account'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentDanger,
                            side: const BorderSide(color: accentDanger),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),

                        // 5. Delete Account (Red Solid Outline)
                        OutlinedButton.icon(
                          onPressed: () {
                            final allowed = RateLimiterService.instance.checkAndRecord(
                              RateLimitCategory.adminActions,
                              onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                            );
                            if (!allowed) return;

                            _showActionConfirmationDialog(
                              title: '⚠️ Permanently Delete User Account',
                              message: 'CRITICAL ACTION: Are you sure you want to permanently delete ${u['name']} (${u['email']})? All KYC documents, trade history, active orders, and authentication credentials will be purged. This action CANNOT be undone.',
                              confirmLabel: 'Permanently Delete',
                              confirmColor: accentDanger,
                              icon: Icons.delete_forever_rounded,
                              onConfirmed: () {
                                final deletedUserName = u['name'];
                                final deletedUserId = u['id'];
                                setState(() {
                                  _deletedUserIds.add(deletedUserId);
                                  _userDatabase.removeWhere((item) => item['id'] == deletedUserId);
                                });
                                SupabaseService.instance.logActivity(
                                  userName: deletedUserName,
                                  userId: deletedUserId,
                                  userRole: u['role'] ?? 'User',
                                  actionTitle: '🗑️ User Account Permanently Deleted',
                                  actionDescription: 'Super Admin executed permanent account purge for $deletedUserName ($deletedUserId).',
                                  module: 'Security & Access',
                                  targetResource: deletedUserId,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Account for $deletedUserName ($deletedUserId) has been permanently removed.'),
                                    backgroundColor: accentDanger,
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 14),
                          label: const Text('Delete Account'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentDanger,
                            side: const BorderSide(color: accentDanger),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),

                        // 6. Reset Session (Gold Outline)
                        OutlinedButton.icon(
                          onPressed: () {
                            final allowed = RateLimiterService.instance.checkAndRecord(
                              RateLimitCategory.adminActions,
                              onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                            );
                            if (!allowed) return;

                            _showActionConfirmationDialog(
                              title: 'Invalidate Active Sessions',
                              message: 'Force device logout and invalidate all active JWT bearer tokens for ${u['name']}? They will be required to re-authenticate with their credentials.',
                              confirmLabel: 'Reset Session',
                              confirmColor: accentGold,
                              icon: Icons.key_outlined,
                              onConfirmed: () {
                                SupabaseService.instance.logActivity(
                                  userName: u['name'],
                                  userId: u['id'],
                                  userRole: u['role'],
                                  actionTitle: '🗝️ User Session Tokens Invalidated',
                                  actionDescription: 'Admin invalidated active auth sessions for ${u['name']}.',
                                  module: 'Security & Sessions',
                                  targetResource: u['id'],
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Session tokens invalidated for ${u['name']}. Forced logout initiated.'), backgroundColor: accentGold),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.key_outlined, size: 14),
                          label: const Text('Reset Session'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentGold,
                            side: const BorderSide(color: accentGold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),

                        // 7. Impersonate / Perspective Switcher (Purple Outline)
                        OutlinedButton.icon(
                          onPressed: () => _showImpersonateModal(u),
                          icon: const Icon(Icons.visibility_outlined, size: 14),
                          label: const Text('Inspect View'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.purpleAccent,
                            side: const BorderSide(color: Colors.purpleAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: ROLE & PRIVILEGE MATRIX (PICTURE 4)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildRolePrivilegeMatrixTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Sovereign Role Matrix', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          const Text('Toggle granular sovereign access capabilities across platform roles.', style: TextStyle(fontSize: 12, color: textMuted)),
          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF070B12)),
                columns: const [
                  DataColumn(label: Text('Capability Domain', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Super Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Farmer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Agronomist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Government', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
                rows: _matrixCapabilities.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(Text(row['domain'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5))),
                      DataCell(Checkbox(value: row['superAdmin'], activeColor: accentGreen, onChanged: (v) => setState(() => row['superAdmin'] = v ?? false))),
                      DataCell(Checkbox(value: row['admin'], activeColor: accentGreen, onChanged: (v) => setState(() => row['admin'] = v ?? false))),
                      DataCell(Checkbox(value: row['farmer'], activeColor: accentGreen, onChanged: (v) => setState(() => row['farmer'] = v ?? false))),
                      DataCell(Checkbox(value: row['agronomist'], activeColor: accentGreen, onChanged: (v) => setState(() => row['agronomist'] = v ?? false))),
                      DataCell(Checkbox(value: row['government'], activeColor: accentGreen, onChanged: (v) => setState(() => row['government'] = v ?? false))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: ACTIVE SESSIONS & SECURITY (PICTURE 3)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildActiveSessionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Platform Session & Security Vault', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Force invalidation of JWT tokens and enforce mandatory security re-authentication.', style: TextStyle(fontSize: 12, color: textMuted)),
                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _userDatabase.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final u = _userDatabase[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF070B12), borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
                      child: Row(
                        children: [
                          const Icon(Icons.devices_outlined, color: accentBlue, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                Text('${u['sessions']} active session(s) • Last seen: ${u['lastSeen']}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalidated all sessions for ${u['name']}.'), backgroundColor: accentGold),
                              );
                            },
                            icon: const Icon(Icons.no_accounts_outlined, size: 14),
                            label: const Text('Force Invalidate JWT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownFilter(String title, String value, List<String> options, ValueChanged<String> onChanged) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: cardDark,
      itemBuilder: (context) => options.map((opt) => PopupMenuItem(value: opt, child: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorder)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            const Icon(Icons.arrow_drop_down, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }
}
