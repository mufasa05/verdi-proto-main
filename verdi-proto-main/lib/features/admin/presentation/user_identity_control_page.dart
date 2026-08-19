import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sovereign Control Console: User & Identity Management
class UserIdentityControlPage extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const UserIdentityControlPage({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<UserIdentityControlPage> createState() => _UserIdentityControlPageState();
}

class _UserIdentityControlPageState extends ConsumerState<UserIdentityControlPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  String _searchQuery = '';
  final String _selectedRoleFilter = 'All Roles';
  final String _selectedKycFilter = 'All KYC Status';

  final List<Map<String, dynamic>> _userDatabase = [
    {
      'id': 'USR-88901',
      'name': 'Kudakwashe Moyo',
      'email': 'kudakwashe.moyo@verdi.co',
      'role': 'Farmer',
      'kyc': 'VERIFIED',
      'location': 'Mufasa Estate, Chiredzi (120 Ha)',
      'eudr': 'EUDR-ZIM-2026-081',
      'status': 'ACTIVE',
      'joiningDate': '14 October 2024 (1 year 10 months on Verdi)',
      'phone': '+263 77 412 9081',
      'escrowBalance': 'US\$ 4,250.00',
    },
    {
      'id': 'USR-99214',
      'name': 'Tendai Mutasa',
      'email': 'tendai.mutasa@mbarehub.co.zw',
      'role': 'Buyer',
      'kyc': 'VERIFIED',
      'location': 'Harare Mbare Musika',
      'eudr': 'EUDR-ZIM-2026-112',
      'status': 'ACTIVE',
      'joiningDate': '03 January 2025 (1 year 7 months on Verdi)',
      'phone': '+263 71 884 9021',
      'escrowBalance': 'US\$ 12,800.00',
    },
    {
      'id': 'USR-44102',
      'name': 'Blessing Ndlovu',
      'email': 'b.ndlovu@chinhoyitrucks.co.zw',
      'role': 'Transporter',
      'kyc': 'PENDING',
      'location': 'Chinhoyi Fleet (12T Isuzu)',
      'eudr': 'EUDR-LOG-884',
      'status': 'ACTIVE',
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
      'joiningDate': '01 August 2024 (2 years on Verdi)',
      'phone': '+263 24 270 0192',
      'escrowBalance': 'N/A (Regulatory)',
    },
  ];

  final Map<String, Map<String, bool>> _rolePermissions = {
    'Farmer': {'canListProduce': true, 'canBuyProduce': true, 'canBookTransport': true, 'canAccessAnalytics': false, 'canAccessAdmin': false},
    'Buyer': {'canListProduce': false, 'canBuyProduce': true, 'canBookTransport': true, 'canAccessAnalytics': true, 'canAccessAdmin': false},
    'Transporter': {'canListProduce': false, 'canBuyProduce': false, 'canBookTransport': true, 'canAccessAnalytics': false, 'canAccessAdmin': false},
    'Admin': {'canListProduce': true, 'canBuyProduce': true, 'canBookTransport': true, 'canAccessAnalytics': true, 'canAccessAdmin': true},
  };

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

  void _showUserDetailsModal(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: cardBorder)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: accentGreen.withOpacity(0.2),
              child: Text(user['name'].substring(0, 1), style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  Text('${user['id']} • ${user['role']}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
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
              _detailItem('📅 Date Joined Verdi', user['joiningDate'] ?? '15 August 2024'),
              _detailItem('🛡️ KYC Status', user['kyc']),
              _detailItem('📞 Verified Phone', user['phone'] ?? '+263 77 123 4567'),
              _detailItem('✉️ Email Address', user['email']),
              _detailItem('📍 Farm / Location', user['location']),
              _detailItem('💳 Escrow Balance', user['escrowBalance'] ?? 'US\$ 0.00'),
              _detailItem('📜 EUDR Polygon Code', user['eudr']),
              _detailItem('⚡ Account Standing', user['status']),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: textMuted))),
          if (user['kyc'] == 'PENDING')
            ElevatedButton(
              onPressed: () {
                setState(() => user['kyc'] = 'VERIFIED');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('KYC for ${user['name']} APPROVED.'), backgroundColor: accentGreen),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
              child: const Text('Approve KYC'),
            ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: textMuted)),
          Flexible(
            child: Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _userDatabase.where((u) {
      final matchesQuery = _searchQuery.isEmpty ||
          u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'All Roles' || u['role'] == _selectedRoleFilter;
      final matchesKyc = _selectedKycFilter == 'All KYC Status' || u['kyc'] == _selectedKycFilter;
      return matchesQuery && matchesRole && matchesKyc;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Header Bar
        Container(
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
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

        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDirectoryTab(filteredUsers),
              _buildKycDeskTab(),
              _buildPrivilegeMatrixTab(),
            ],
          ),
        ),
      ],
    );
  }

  // 1. Directory Tab
  Widget _buildDirectoryTab(List<Map<String, dynamic>> users) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search & Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search directory by name, email, ID...',
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
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final u = users[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: accentGreen.withOpacity(0.18),
                      child: Text(u['name'].substring(0, 1), style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(u['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: u['kyc'] == 'VERIFIED' ? accentGreen.withOpacity(0.15) : accentGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(u['kyc'], style: TextStyle(color: u['kyc'] == 'VERIFIED' ? accentGreen : accentGold, fontSize: 9.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${u['id']} • ${u['role']} • ${u['location']}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                          Text('📅 Joined: ${u['joiningDate'] ?? '15 Aug 2024'}', style: const TextStyle(fontSize: 10.5, color: textMuted)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showUserDetailsModal(u),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                      child: const Text('View Profile'),
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

  // 2. KYC Desk Tab
  Widget _buildKycDeskTab() {
    final pendingList = _userDatabase.where((u) => u['kyc'] == 'PENDING').toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KYC Verification Queue & Audit Desk', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Review submitted National IDs, Farm GPS polygons, and bank account verifications.', style: const TextStyle(fontSize: 12, color: textMuted)),
          const SizedBox(height: 14),

          if (pendingList.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
              child: Column(
                children: [
                  const Icon(Icons.verified_user_rounded, color: accentGreen, size: 40),
                  const SizedBox(height: 8),
                  Text('KYC Queue Clear', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('All stakeholder accounts have undergone verification.', style: TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final u = pendingList[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.pending_actions, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            Text('${u['id']} · ${u['role']} · ${u['location']}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                            Text('National ID & Farm Polygon submitted.', style: const TextStyle(fontSize: 11, color: accentGold)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => u['kyc'] = 'VERIFIED');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Approved KYC for ${u['name']}.'), backgroundColor: accentGreen),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                        child: const Text('Approve KYC'),
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

  // 3. Privilege Matrix Tab
  Widget _buildPrivilegeMatrixTab() {
    final permissions = ['canListProduce', 'canBuyProduce', 'canBookTransport', 'canAccessAnalytics', 'canAccessAdmin'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Interactive Role Privilege Matrix', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Review and configure module permissions across all stakeholder roles.', style: const TextStyle(fontSize: 12, color: textMuted)),
          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF0B0F17)),
              columns: const [
                DataColumn(label: Text('Role', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('List Produce', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Buy Produce', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Book Fleet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Admin Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
              rows: _rolePermissions.keys.map((role) {
                final perms = _rolePermissions[role]!;
                return DataRow(
                  cells: [
                    DataCell(Text(role, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ...permissions.map((pKey) {
                      final val = perms[pKey] ?? false;
                      return DataCell(
                        Checkbox(
                          value: val,
                          activeColor: accentGreen,
                          onChanged: (newVal) {
                            setState(() {
                              perms[pKey] = newVal ?? false;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
