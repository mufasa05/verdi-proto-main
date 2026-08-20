import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';

class AdminUserManagementPage extends ConsumerStatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  ConsumerState<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class UserItem {
  final String id;
  String name;
  String email;
  UserRole role;
  String status; // 'Active', 'Pending', 'Suspended'
  String location;
  String joinedDate;

  UserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.location,
    required this.joinedDate,
  });
}

class _AdminUserManagementPageState extends ConsumerState<AdminUserManagementPage> {
  static const dark = Color(0xFF0F172A);
  static const green = Color(0xFF16A34A);
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFDC2626);
  static const cream = Color(0xFFF8FAFC);

  String _searchQuery = '';
  UserRole? _selectedRoleFilter;
  String _selectedStatusFilter = 'All';

  final List<UserItem> _demoUsers = [
    UserItem(id: 'USR-001', name: 'Kudakwashe Moyo', email: 'kuda.moyo@farmnet.co.zw', role: UserRole.farmer, status: 'Active', location: 'Harare, ZW', joinedDate: '12 Jan 2024'),
    UserItem(id: 'USR-002', name: 'Tendai Mutasa', email: 'tendai.m@agritrade.co.zw', role: UserRole.buyer, status: 'Active', location: 'Bulawayo, ZW', joinedDate: '04 Feb 2024'),
    UserItem(id: 'USR-003', name: 'Blessing Ndlovu', email: 'b.ndlovu@expresslogistics.co.zw', role: UserRole.transporter, status: 'Active', location: 'Gweru, ZW', joinedDate: '18 Mar 2024'),
    UserItem(id: 'USR-004', name: 'Dr. Farai Chigumba', email: 'farai.agri@gov.zw', role: UserRole.government, status: 'Active', location: 'Harare, ZW', joinedDate: '01 Nov 2023'),
    UserItem(id: 'USR-005', name: 'Chipo Sibanda', email: 'chipo.expert@verdi.co', role: UserRole.expert, status: 'Pending', location: 'Mutare, ZW', joinedDate: '10 Jul 2024'),
    UserItem(id: 'USR-006', name: 'Stanbic Agri Capital', email: 'loans@stanbic.co.zw', role: UserRole.financier, status: 'Active', location: 'Harare, ZW', joinedDate: '15 Dec 2023'),
    UserItem(id: 'USR-007', name: 'GreenMill Processing', email: 'info@greenmill.co.zw', role: UserRole.valueAdder, status: 'Active', location: 'Chinhoyi, ZW', joinedDate: '22 Feb 2024'),
    UserItem(id: 'USR-008', name: 'Simbarashe Dube', email: 'simba.dube@gmail.com', role: UserRole.consumer, status: 'Suspended', location: 'Masvingo, ZW', joinedDate: '05 May 2024'),
    UserItem(id: 'USR-009', name: 'Tinashe Zvobgo', email: 'admin.tinashe@verdi.co', role: UserRole.admin, status: 'Active', location: 'Harare, ZW', joinedDate: '01 Oct 2023'),
  ];

  final List<UserItem> _createdLiveUsers = [];

  List<UserItem> _getUsers(bool isDemo) {
    if (isDemo) return _demoUsers;

    final sessions = ref.watch(liveUserSessionsProvider);
    final List<UserItem> liveList = [];

    for (final s in sessions) {
      liveList.add(
        UserItem(
          id: s.id,
          name: s.name,
          email: '${s.name.toLowerCase().replaceAll(' ', '.')}@verdi.live',
          role: s.role,
          status: s.isOnline ? 'Active' : 'Offline',
          location: s.location,
          joinedDate: 'Live Stakeholder',
        ),
      );
    }

    for (final u in _createdLiveUsers) {
      if (!liveList.any((e) => e.id == u.id)) {
        liveList.add(u);
      }
    }

    if (liveList.isEmpty) {
      liveList.add(
        UserItem(
          id: 'USR-ADM-CREATOR',
          name: 'Verdi Creator (Super Admin)',
          email: 'creator@verdi.ag',
          role: UserRole.admin,
          status: 'Active',
          location: 'Harare Command Station',
          joinedDate: 'Sovereign Root Node',
        ),
      );
    }

    return liveList;
  }

  List<UserItem> get _filteredUsers {
    final isDemo = ref.watch(isDemoModeProvider);
    final users = _getUsers(isDemo);

    return users.where((user) {
      final matchesQuery = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == null || user.role == _selectedRoleFilter;
      final matchesStatus = _selectedStatusFilter == 'All' || user.status == _selectedStatusFilter;
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  void _showAddUserModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    UserRole chosenRole = UserRole.farmer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add New Platform User', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location / Region', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: chosenRole,
                  decoration: const InputDecoration(labelText: 'Stakeholder Role', border: OutlineInputBorder()),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.label));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => chosenRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                final isDemo = ref.read(isDemoModeProvider);
                final newUser = UserItem(
                  id: 'USR-LIVE-${DateTime.now().millisecondsSinceEpoch % 10000}',
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  role: chosenRole,
                  status: 'Active',
                  location: locationCtrl.text.trim().isEmpty ? 'Harare, ZW' : locationCtrl.text.trim(),
                  joinedDate: 'Just now',
                );

                setState(() {
                  if (isDemo) {
                    _demoUsers.insert(0, newUser);
                  } else {
                    _createdLiveUsers.insert(0, newUser);
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account for ${newUser.name} created successfully!'), backgroundColor: green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    final isDemo = ref.watch(isDemoModeProvider);
    final allUsers = _getUsers(isDemo);

    final totalCount = allUsers.length;
    final activeCount = allUsers.where((u) => u.status == 'Active').length;
    final pendingCount = allUsers.where((u) => u.status == 'Pending' || u.status == 'Offline').length;
    final suspendedCount = allUsers.where((u) => u.status == 'Suspended').length;

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Management Center',
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: dark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDemo
                            ? 'Demo Sandbox Directory · 9 scenario profiles'
                            : 'Live Production Directory · $totalCount registered stakeholder nodes',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddUserModal,
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Add User', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // KPI Metric Cards
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Total Users', '$totalCount', Icons.group_outlined, blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Active', '$activeCount', Icons.check_circle_outline, green)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Pending', '$pendingCount', Icons.pending_outlined, orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Suspended', '$suspendedCount', Icons.block_outlined, red)),
                ],
              ),

              const SizedBox(height: 20),

              // Search & Filter Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or user ID...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: cream,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<UserRole?>(
                            value: _selectedRoleFilter,
                            decoration: const InputDecoration(labelText: 'Filter Role', border: OutlineInputBorder()),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Roles')),
                              ...UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))),
                            ],
                            onChanged: (val) => setState(() => _selectedRoleFilter = val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatusFilter,
                            decoration: const InputDecoration(labelText: 'Filter Status', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                              DropdownMenuItem(value: 'Active', child: Text('Active')),
                              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                            ],
                            onChanged: (val) => setState(() => _selectedStatusFilter = val ?? 'All'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Registered Accounts (${filtered.length})',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: dark),
              ),

              const SizedBox(height: 12),

              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('No Users Found', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: dark)),
                      const SizedBox(height: 4),
                      const Text('Try adjusting your search filters or add a new user.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final u = filtered[idx];
                    return _buildUserCard(u);
                  },
                ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserItem u) {
    final statusBg = u.status == 'Active' ? green.withOpacity(0.1) : (u.status == 'Pending' ? orange.withOpacity(0.1) : red.withOpacity(0.1));
    final statusColor = u.status == 'Active' ? green : (u.status == 'Pending' ? orange : red);
    final isSuspended = u.status == 'Suspended';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: blue.withOpacity(0.12),
                foregroundColor: blue,
                child: Text(
                  u.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: dark)),
                    const SizedBox(height: 2),
                    Text('${u.email} • ${u.id}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(4)),
                          child: Text(u.role.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: dark)),
                        ),
                        const SizedBox(width: 6),
                        Text(u.location, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                child: Text(u.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 4 Action Buttons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('KYC verification confirmed for ${u.name}.'), backgroundColor: green),
                  );
                },
                icon: const Icon(Icons.verified_user_outlined, size: 13),
                label: const Text('Verify KYC', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => u.role = UserRole.admin);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Elevated ${u.name} role to Administrator.'), backgroundColor: blue),
                  );
                },
                icon: const Icon(Icons.vpn_key_outlined, size: 13),
                label: const Text('Elevate Role', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: blue,
                  side: const BorderSide(color: blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => u.status = isSuspended ? 'Active' : 'Suspended');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${u.name} status updated to ${u.status}.'), backgroundColor: red),
                  );
                },
                icon: const Icon(Icons.person_remove_outlined, size: 13),
                label: Text(isSuspended ? 'Reactivate' : 'Suspend Account', style: const TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Session reset for ${u.name}.'), backgroundColor: orange),
                  );
                },
                icon: const Icon(Icons.key_outlined, size: 13),
                label: const Text('Reset Session', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: orange,
                  side: const BorderSide(color: orange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
