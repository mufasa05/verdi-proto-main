import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
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

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  static const dark = Color(0xFF0F172A);
  static const green = Color(0xFF16A34A);
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFDC2626);
  static const cream = Color(0xFFF8FAFC);

  String _searchQuery = '';
  UserRole? _selectedRoleFilter;
  String _selectedStatusFilter = 'All';

  final List<UserItem> _users = [
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

  List<UserItem> get _filteredUsers {
    return _users.where((user) {
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
      builder: (context) => AlertDialog(
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
                  if (val != null) chosenRole = val;
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
              setState(() {
                _users.insert(
                  0,
                  UserItem(
                    id: 'USR-0${_users.length + 10}',
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    role: chosenRole,
                    status: 'Active',
                    location: locationCtrl.text.trim().isEmpty ? 'Harare, ZW' : locationCtrl.text.trim(),
                    joinedDate: 'Just Now',
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User "${nameCtrl.text.trim()}" created successfully! 🎉')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Create User'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _users.where((u) => u.status == 'Active').length;
    final pendingCount = _users.where((u) => u.status == 'Pending').length;
    final suspendedCount = _users.where((u) => u.status == 'Suspended').length;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: dark),
        title: Text(
          'User Management Center',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: dark, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _showAddUserModal,
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  if (isMobile) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildKpiCard('Total Users', '${_users.length}', Icons.groups, blue)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildKpiCard('Active', '$activeCount', Icons.check_circle, green)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildKpiCard('Pending', '$pendingCount', Icons.pending, orange)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildKpiCard('Suspended', '$suspendedCount', Icons.block, red)),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildKpiCard('Total Users', '${_users.length}', Icons.groups, blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKpiCard('Active', '$activeCount', Icons.check_circle, green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKpiCard('Pending', '$pendingCount', Icons.pending, orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKpiCard('Suspended', '$suspendedCount', Icons.block, red)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Filter Controls
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or user ID...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<UserRole?>(
                            value: _selectedRoleFilter,
                            decoration: InputDecoration(
                              labelText: 'Filter Role',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Roles')),
                              ...UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))),
                            ],
                            onChanged: (val) => setState(() => _selectedRoleFilter = val),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatusFilter,
                            decoration: InputDecoration(
                              labelText: 'Filter Status',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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

              const SizedBox(height: 16),

              // User List
              Text(
                'Registered Accounts (${_filteredUsers.length})',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: dark),
              ),
              const SizedBox(height: 10),

              if (_filteredUsers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No users match your filters', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: dark)),
                      Text('Try adjusting your search criteria.', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, idx) {
                    final user = _filteredUsers[idx];
                    return _buildUserCard(user);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserItem user) {
    final initials = user.name.split(' ').map((e) => e[0]).take(2).join();

    Color statusBg = green.withOpacity(0.1);
    Color statusFg = green;
    if (user.status == 'Pending') {
      statusBg = orange.withOpacity(0.1);
      statusFg = orange;
    } else if (user.status == 'Suspended') {
      statusBg = red.withOpacity(0.1);
      statusFg = red;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: dark.withOpacity(0.1),
          child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: dark)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: dark),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.status,
                style: TextStyle(color: statusFg, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('${user.email} • ${user.id}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(user.role.icon, size: 12, color: green),
                const SizedBox(width: 4),
                Text(user.role.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: dark)),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                const SizedBox(width: 2),
                Text(user.location, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
          onSelected: (action) {
            if (action == 'toggle_status') {
              setState(() {
                user.status = user.status == 'Active' ? 'Suspended' : 'Active';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User ${user.name} is now ${user.status}.')),
              );
            } else if (action == 'reset_pw') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset link sent to ${user.email}.')),
              );
            } else if (action == 'delete') {
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User ${user.name} removed.')),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(user.status == 'Active' ? Icons.block : Icons.check_circle_outline, size: 16, color: user.status == 'Active' ? red : green),
                  const SizedBox(width: 8),
                  Text(user.status == 'Active' ? 'Suspend Account' : 'Activate Account'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset_pw',
              child: Row(
                children: [
                  Icon(Icons.lock_reset, size: 16, color: blue),
                  SizedBox(width: 8),
                  Text('Reset Password'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 16, color: red),
                  SizedBox(width: 8),
                  Text('Delete User', style: TextStyle(color: red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
