import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';

/// Dedicated Sovereign Control Console: User & Identity Management
class UserIdentityControlPage extends ConsumerStatefulWidget {
  const UserIdentityControlPage({super.key});

  @override
  ConsumerState<UserIdentityControlPage> createState() => _UserIdentityControlPageState();
}

class _UserIdentityControlPageState extends ConsumerState<UserIdentityControlPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  String _searchQuery = '';
  String _selectedRoleFilter = 'All Roles';
  final String _selectedKycFilter = 'All KYC Status';

  final List<Map<String, dynamic>> _demoDatabase = [
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
      'role': 'Government',
      'kyc': 'VERIFIED',
      'location': 'Harare Provincial Directorate',
      'eudr': 'GOV-TIM-01',
      'status': 'ACTIVE',
      'sessions': 1,
      'lastLogin': 'Today',
    },
  ];

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

  List<Map<String, dynamic>> _getUserDatabase(bool isDemo) {
    if (isDemo) return _demoDatabase;

    final sessions = ref.watch(liveUserSessionsProvider);
    final List<Map<String, dynamic>> liveList = [];

    for (final s in sessions) {
      liveList.add({
        'id': s.id,
        'name': s.name,
        'email': '${s.name.toLowerCase().replaceAll(' ', '.')}@verdi.live',
        'role': s.role.label,
        'kyc': 'VERIFIED',
        'location': s.location,
        'eudr': 'EUDR-LIVE-${s.role.name.toUpperCase()}',
        'status': s.isOnline ? 'ACTIVE' : 'OFFLINE',
        'sessions': s.isOnline ? 1 : 0,
        'lastLogin': s.lastHeartbeat,
      });
    }

    if (liveList.isEmpty) {
      liveList.add({
        'id': 'USR-ADM-CREATOR',
        'name': 'Verdi Creator (Super Admin)',
        'email': 'creator@verdi.ag',
        'role': 'Admin',
        'kyc': 'VERIFIED',
        'location': 'Harare Command Station',
        'eudr': 'SOVEREIGN-ROOT',
        'status': 'ACTIVE',
        'sessions': 1,
        'lastLogin': 'Just now',
      });
    }

    return liveList;
  }

  List<Map<String, dynamic>> get _filteredUsers {
    final isDemo = ref.watch(isDemoModeProvider);
    final users = _getUserDatabase(isDemo);

    return users.where((u) {
      final nameMatches = u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final roleMatches = _selectedRoleFilter == 'All Roles' || u['role'] == _selectedRoleFilter;
      final kycMatches = _selectedKycFilter == 'All KYC Status' || u['kyc'] == _selectedKycFilter;
      return nameMatches && roleMatches && kycMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(isDemoModeProvider);
    final users = _getUserDatabase(isDemo);
    final filtered = _filteredUsers;

    final totalUsers = users.length;
    final verifiedKyc = users.where((u) => u['kyc'] == 'VERIFIED').length;
    final pendingKyc = users.where((u) => u['kyc'] == 'PENDING').length;
    final activeSessions = users.where((u) => u['status'] == 'ACTIVE').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Metric Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isMobile ? 1.5 : 1.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildMetricCard('$totalUsers', 'Total Stakeholders', Icons.people_outline, accentBlue),
                _buildMetricCard('$verifiedKyc', 'Verified KYC Tiers', Icons.verified_user_outlined, accentGreen),
                _buildMetricCard('$pendingKyc', 'Pending Verification', Icons.pending_actions_outlined, accentGold),
                _buildMetricCard('$activeSessions', 'Live Active Sessions', Icons.online_prediction_outlined, accentGreen),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Tab Navigation
        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: accentGreen,
            labelColor: accentGreen,
            unselectedLabelColor: textMuted,
            tabs: const [
              Tab(text: 'Stakeholder Directory'),
              Tab(text: 'KYC Verification Desk'),
              Tab(text: 'Role Privilege Matrix'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Views
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDirectoryTab(filtered),
              _buildKycTab(users),
              _buildPrivilegeMatrixTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectoryTab(List<Map<String, dynamic>> users) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search by name, ID, or email...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: textMuted, size: 18),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRoleFilter,
                  dropdownColor: cardDark,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'All Roles', child: Text('All Roles')),
                    DropdownMenuItem(value: 'Farmer', child: Text('Farmer')),
                    DropdownMenuItem(value: 'Buyer', child: Text('Buyer')),
                    DropdownMenuItem(value: 'Transporter', child: Text('Transporter')),
                    DropdownMenuItem(value: 'Financier', child: Text('Financier')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (v) => setState(() => _selectedRoleFilter = v ?? 'All Roles'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (users.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
              child: const Text('No stakeholder accounts match the query.', style: TextStyle(color: textMuted)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final u = users[idx];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: accentBlue.withOpacity(0.15),
                        child: Text(
                          u['name'].toString().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(),
                          style: const TextStyle(color: accentBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u['name'], style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('${u['role']} • ${u['id']} • ${u['location']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: u['kyc'] == 'VERIFIED' ? accentGreen.withOpacity(0.15) : accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          u['kyc'],
                          style: TextStyle(
                            color: u['kyc'] == 'VERIFIED' ? accentGreen : accentGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildKycTab(List<Map<String, dynamic>> users) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: users.map((u) {
          final isVerified = u['kyc'] == 'VERIFIED';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                Icon(isVerified ? Icons.verified : Icons.pending, color: isVerified ? accentGreen : accentGold, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                      Text('${u['role']} • ${u['eudr']}', style: const TextStyle(color: textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('KYC record for ${u['name']} verified and approved!'), backgroundColor: accentGreen),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? Colors.transparent : accentGreen,
                    foregroundColor: isVerified ? accentGreen : Colors.white,
                    side: isVerified ? const BorderSide(color: accentGreen) : BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: Text(isVerified ? 'VERIFIED' : 'APPROVE KYC', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrivilegeMatrixTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sovereign Role-Based Access Control (RBAC)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Privileges are cryptographically enforced across the database and Flutter terminals.', style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          _rbacRow('Super Administrator', 'Full R/W/D + Financial Escrow Override + Telemetry Broadcast', accentGreen),
          _rbacRow('Government Inspector', 'Phytosanitary Sign-off + EUDR Regulatory Audit + Parcel Inspection', accentBlue),
          _rbacRow('Financier', 'Credit Underwriting + Escrow Vault Collateralization + Loan Approval', accentGold),
          _rbacRow('Transporter', 'OBD-II Telemetry Broadcast + Digital Waybill Sign-off + Logistics Hub', const Color(0xFFF97316)),
          _rbacRow('Farmer', 'Produce Batch Listing + AI Agronomy + Weather Alerts + Parcel Management', accentGreen),
          _rbacRow('Buyer', 'Marketplace Order Placement + Smart Escrow Funding + Logistics Request', accentPurple),
        ],
      ),
    );
  }

  Widget _rbacRow(String role, String perm, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(role, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(perm, style: const TextStyle(color: Colors.white70, fontSize: 11.5))),
        ],
      ),
    );
  }

  static const accentPurple = Color(0xFF8B5CF6);

  Widget _buildMetricCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: textMuted, fontSize: 10.5)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}
