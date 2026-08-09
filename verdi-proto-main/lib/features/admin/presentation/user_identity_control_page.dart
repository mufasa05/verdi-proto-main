import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dedicated Sovereign Control Console: User & Identity Management
class UserIdentityControlPage extends StatefulWidget {
  const UserIdentityControlPage({super.key});

  @override
  State<UserIdentityControlPage> createState() => _UserIdentityControlPageState();
}

class _UserIdentityControlPageState extends State<UserIdentityControlPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentDanger = Color(0xFFEF4444);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  String _searchQuery = '';
  String _selectedRoleFilter = 'All Roles';
  String _selectedKycFilter = 'All KYC Status';

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
      'lastLogin': '12 mins ago',
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
      'lastLogin': '2 hours ago',
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
      'lastLogin': 'Yesterday',
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
      'lastLogin': '4 mins ago',
    },
    {
      'id': 'USR-00192',
      'name': 'Dr. K. Shumba (Ministry of Lands)',
      'email': 'inspector.shumba@lands.gov.zw',
      'role': 'Government Inspector',
      'kyc': 'VERIFIED',
      'location': 'National Agronomy Inspectorate',
      'eudr': 'GOV-ZIM-001',
      'status': 'ACTIVE',
      'sessions': 1,
      'lastLogin': 'Just now',
    },
    {
      'id': 'USR-33019',
      'name': 'Bvuma Coffee Estates',
      'email': 'admin@bvumacoffee.co.zw',
      'role': 'Farmer',
      'kyc': 'FLAGGED',
      'location': 'Eastern Highlands Chipinge',
      'eudr': 'EUDR-REJECT-91',
      'status': 'SUSPENDED',
      'sessions': 0,
      'lastLogin': '5 days ago',
    },
  ];

  final Map<String, Map<String, bool>> _rolePermissionMatrix = {
    'Full System Sovereignty': {'Super Admin': true, 'Admin': false, 'Farmer': false, 'Agronomist': false, 'Government': false},
    'Emergency Lockdown Trigger': {'Super Admin': true, 'Admin': false, 'Farmer': false, 'Agronomist': false, 'Government': false},
    'KYC Override & Privilege Elevation': {'Super Admin': true, 'Admin': true, 'Farmer': false, 'Agronomist': false, 'Government': false},
    'Marketplace Price Floor Publishing': {'Super Admin': true, 'Admin': true, 'Farmer': false, 'Agronomist': false, 'Government': true},
    'Agronomy AI Prompt Guardrail Edit': {'Super Admin': true, 'Admin': true, 'Farmer': false, 'Agronomist': true, 'Government': false},
    'Export Audit Trail & EUDR Certificate': {'Super Admin': true, 'Admin': true, 'Farmer': true, 'Agronomist': true, 'Government': true},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Controls ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KYC User Directory & Sovereign Privilege Manager',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manual KYC overrides, role elevations, session invalidation, and permission matrix.',
                    style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showCreateUserModal,
              icon: const Icon(Icons.person_add_outlined, size: 16),
              label: const Text('Register User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // --- Sub-Tabs ---
        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
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

        const SizedBox(height: 20),

        SizedBox(
          height: 900,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserDirectoryTab(),
              _buildRoleMatrixTab(),
              _buildSessionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: USER DIRECTORY ---
  Widget _buildUserDirectoryTab() {
    final filteredUsers = _userDatabase.where((u) {
      final matchesSearch = u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'All Roles' || u['role'] == _selectedRoleFilter;
      final matchesKyc = _selectedKycFilter == 'All KYC Status' || u['kyc'] == _selectedKycFilter;
      return matchesSearch && matchesRole && matchesKyc;
    }).toList();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Filter Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search user by ID, name, or email...',
                  hintStyle: const TextStyle(color: textMuted),
                  filled: true,
                  fillColor: cardDark,
                  prefixIcon: const Icon(Icons.search, color: textMuted, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedRoleFilter,
              dropdownColor: cardDark,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: ['All Roles', 'Farmer', 'Buyer', 'Transporter', 'Financier', 'Government Inspector', 'Admin']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedRoleFilter = v); },
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedKycFilter,
              dropdownColor: cardDark,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: ['All KYC Status', 'VERIFIED', 'PENDING', 'FLAGGED']
                  .map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedKycFilter = v); },
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (filteredUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
            child: const Center(child: Text('No matching user records found.', style: TextStyle(color: textMuted))),
          )
        else
          for (int i = 0; i < filteredUsers.length; i++) ...[
            _buildUserCard(filteredUsers[i]),
            if (i != filteredUsers.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final kyc = user['kyc'];
    Color kycColor = accentGold;
    if (kyc == 'VERIFIED') kycColor = accentGreen;
    if (kyc == 'FLAGGED') kycColor = accentDanger;

    final isSuspended = user['status'] == 'SUSPENDED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSuspended ? accentDanger.withValues(alpha: 0.6) : cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSuspended ? accentDanger : accentGreen).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(isSuspended ? Icons.person_off : Icons.person, color: isSuspended ? accentDanger : accentGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user['name'], style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: accentBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text(user['id'], style: const TextStyle(color: accentBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text('${user['email']} • ${user['location']} • Role: ${user['role']}', style: const TextStyle(color: textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kycColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: kycColor.withValues(alpha: 0.5)),
                ),
                child: Text(kyc, style: TextStyle(color: kycColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => user['kyc'] = 'VERIFIED'),
                icon: const Icon(Icons.verified_user_outlined, size: 14, color: accentGreen),
                label: const Text('Verify KYC', style: TextStyle(color: accentGreen, fontSize: 11)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: accentGreen)),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => user['role'] = 'Admin'),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 14, color: accentBlue),
                label: const Text('Elevate Role', style: TextStyle(color: accentBlue, fontSize: 11)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: accentBlue)),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  user['status'] = isSuspended ? 'ACTIVE' : 'SUSPENDED';
                  if (!isSuspended) user['kyc'] = 'FLAGGED';
                }),
                icon: Icon(isSuspended ? Icons.check_circle_outline : Icons.person_remove_outlined, size: 14, color: isSuspended ? accentGreen : accentDanger),
                label: Text(isSuspended ? 'Reactivate Account' : 'Suspend Account', style: TextStyle(color: isSuspended ? accentGreen : accentDanger, fontSize: 11)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: isSuspended ? accentGreen : accentDanger)),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password & session reset link sent to ${user['email']}'), backgroundColor: accentGreen),
                  );
                },
                icon: const Icon(Icons.vpn_key_outlined, size: 14, color: accentGold),
                label: const Text('Reset Session', style: TextStyle(color: accentGold, fontSize: 11)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: accentGold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 2: ROLE & PERMISSION MATRIX ---
  Widget _buildRoleMatrixTab() {
    final roles = ['Super Admin', 'Admin', 'Farmer', 'Agronomist', 'Government'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text('Platform Sovereign Role Matrix', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Toggle granular sovereign access capabilities across platform roles.', style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 16),

          Table(
            border: TableBorder.all(color: cardBorder),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF0F172A)),
                children: [
                  const Padding(padding: EdgeInsets.all(10), child: Text('Capability Domain', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 12))),
                  for (final r in roles)
                    Padding(padding: const EdgeInsets.all(10), child: Text(r, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
              for (final entry in _rolePermissionMatrix.entries)
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(10), child: Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 12))),
                    for (final r in roles)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Checkbox(
                          value: entry.value[r] ?? false,
                          activeColor: accentGreen,
                          onChanged: (val) {
                            if (r == 'Super Admin') return; // Cannot strip Super Admin
                            setState(() {
                              entry.value[r] = val ?? false;
                            });
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 3: ACTIVE SESSIONS ---
  Widget _buildSessionsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform Session & Security Vault', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Force invalidation of JWT tokens and enforce mandatory multi-factor authentication.', style: TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All user sessions invalidated platform-wide.'), backgroundColor: accentDanger),
                  );
                },
                icon: const Icon(Icons.power_settings_new, size: 16),
                label: const Text('Force Logout All Users'),
                style: ElevatedButton.styleFrom(backgroundColor: accentDanger, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          for (final user in _userDatabase) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: cardBorder)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.devices, color: accentBlue, size: 18),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['name'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('${user['sessions']} active session(s) • Last seen: ${user['lastLogin']}', style: const TextStyle(color: textMuted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => user['sessions'] = 0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalidated session for ${user['name']}'), backgroundColor: accentGold),
                      );
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: accentGold)),
                    child: const Text('Invalidate Session', style: TextStyle(color: accentGold, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateUserModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'Farmer';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: Text('Register Platform User', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Full Name', labelStyle: TextStyle(color: textMuted))),
            const SizedBox(height: 10),
            TextField(controller: emailCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Email Address', labelStyle: TextStyle(color: textMuted))),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: role,
              dropdownColor: cardDark,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Role', labelStyle: TextStyle(color: textMuted)),
              items: ['Farmer', 'Buyer', 'Transporter', 'Financier', 'Government Inspector', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) { if (v != null) role = v; },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _userDatabase.add({
                    'id': 'USR-${10000 + _userDatabase.length}',
                    'name': nameCtrl.text,
                    'email': emailCtrl.text,
                    'role': role,
                    'kyc': 'VERIFIED',
                    'location': 'Harare Central Hub',
                    'eudr': 'EUDR-NEW-2026',
                    'status': 'ACTIVE',
                    'sessions': 1,
                    'lastLogin': 'Just now',
                  });
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Register User'),
          ),
        ],
      ),
    );
  }
}
