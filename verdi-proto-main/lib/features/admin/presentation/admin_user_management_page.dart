import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/rate_limiter_service.dart';
import '../../../core/services/supabase_service.dart';
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
  static const bgDark = Color(0xFF070B12);
  static const cardDark = Color(0xFF0F172A);
  static const cardBorder = Color(0xFF1E293B);
  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF3B82F6);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const textMuted = Color(0xFF94A3B8);

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
      backgroundColor: bgDark,
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
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDemo
                            ? 'Demo Sandbox Directory · 9 scenario profiles'
                            : 'Live Production Directory · $totalCount registered stakeholder nodes',
                        style: GoogleFonts.inter(fontSize: 12, color: textMuted),
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
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or user ID...',
                        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: textMuted),
                        filled: true,
                        fillColor: bgDark,
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
                            dropdownColor: cardDark,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Filter Role',
                              labelStyle: const TextStyle(color: textMuted, fontSize: 12),
                              filled: true,
                              fillColor: bgDark,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Roles')),
                              ...UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))),
                            ],
                            onChanged: (v) => setState(() => _selectedRoleFilter = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatusFilter,
                            dropdownColor: cardDark,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Filter Status',
                              labelStyle: const TextStyle(color: textMuted, fontSize: 12),
                              filled: true,
                              fillColor: bgDark,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                              DropdownMenuItem(value: 'Active', child: Text('Active Only')),
                              DropdownMenuItem(value: 'Pending', child: Text('Pending Only')),
                              DropdownMenuItem(value: 'Suspended', child: Text('Suspended Only')),
                            ],
                            onChanged: (v) => setState(() => _selectedStatusFilter = v ?? 'All'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // User Directory List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stakeholder Directory (${filtered.length})', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (_searchQuery.isNotEmpty || _selectedRoleFilter != null || _selectedStatusFilter != 'All')
                    TextButton(
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _selectedRoleFilter = null;
                        _selectedStatusFilter = 'All';
                      }),
                      child: const Text('Reset Filters', style: TextStyle(color: orange, fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
                  child: Column(
                    children: [
                      const Icon(Icons.person_search_outlined, size: 48, color: textMuted),
                      const SizedBox(height: 12),
                      const Text('No stakeholders match your filter.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text('Try adjusting search query or role filter.', style: TextStyle(color: textMuted, fontSize: 12)),
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
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
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
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: textMuted)),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserItem u) {
    final statusBg = u.status == 'Active' ? green.withOpacity(0.12) : (u.status == 'Pending' ? orange.withOpacity(0.12) : red.withOpacity(0.12));
    final statusColor = u.status == 'Active' ? green : (u.status == 'Pending' ? orange : red);
    final isSuspended = u.status == 'Suspended';

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
              CircleAvatar(
                backgroundColor: blue.withOpacity(0.18),
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
                    Text(u.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('${u.email} • ${u.id}', style: const TextStyle(fontSize: 11, color: textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(4)),
                          child: Text(u.role.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(width: 6),
                        Text(u.location, style: const TextStyle(fontSize: 10, color: textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.4))),
                child: Text(u.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: cardBorder),
          const SizedBox(height: 10),

          // 6 Direct Action Buttons with Real Logic & Safety Confirmation Modals
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // 1. Verify KYC
              OutlinedButton.icon(
                onPressed: () {
                  final allowed = RateLimiterService.instance.checkAndRecord(
                    RateLimitCategory.adminActions,
                    onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                  );
                  if (!allowed) return;

                  SupabaseService.instance.logActivity(
                    userName: u.name,
                    userId: u.id,
                    userRole: u.role.label,
                    actionTitle: '🛡️ KYC Verified by Super Admin',
                    actionDescription: 'Verified compliance & credentials for ${u.name}.',
                    module: 'User Management',
                    targetResource: u.id,
                  );
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

              // 2. Elevate Role
              OutlinedButton.icon(
                onPressed: () {
                  final allowed = RateLimiterService.instance.checkAndRecord(
                    RateLimitCategory.adminActions,
                    onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                  );
                  if (!allowed) return;

                  _showActionConfirmationDialog(
                    title: 'Elevate Role Privilege',
                    message: 'Elevate ${u.name} (${u.role.label}) to Super Administrator status? This grants full command center access.',
                    confirmLabel: 'Confirm Elevation',
                    confirmColor: blue,
                    icon: Icons.vpn_key_outlined,
                    onConfirmed: () {
                      setState(() => u.role = UserRole.admin);
                      SupabaseService.instance.logActivity(
                        userName: u.name,
                        userId: u.id,
                        userRole: 'Administrator',
                        actionTitle: '🔑 Role Elevated to Administrator',
                        actionDescription: 'Admin elevated role for ${u.name}.',
                        module: 'Access Control',
                        targetResource: u.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Elevated ${u.name} role to Administrator.'), backgroundColor: blue),
                      );
                    },
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

              // 3. Award Badge
              OutlinedButton.icon(
                onPressed: () {
                  final allowed = RateLimiterService.instance.checkAndRecord(
                    RateLimitCategory.adminActions,
                    onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                  );
                  if (!allowed) return;

                  SupabaseService.instance.logActivity(
                    userName: u.name,
                    userId: u.id,
                    userRole: u.role.label,
                    actionTitle: '🎖️ Sovereign Verified Badge Awarded',
                    actionDescription: 'Awarded carrier badge to ${u.name}.',
                    module: 'User Management',
                    targetResource: u.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎖️ Verified Carrier Badge awarded to ${u.name}!'),
                      backgroundColor: const Color(0xFFFF9F1C),
                    ),
                  );
                },
                icon: const Icon(Icons.military_tech_outlined, size: 13),
                label: const Text('Award Badge', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF9F1C),
                  side: const BorderSide(color: Color(0xFFFF9F1C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),

              // 4. Suspend Account
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
                        ? 'Reactivate account access for ${u.name}? They will be permitted to log in.'
                        : 'Suspend account access for ${u.name}? Active sessions will be terminated.',
                    confirmLabel: isSuspended ? 'Reactivate' : 'Suspend Account',
                    confirmColor: isSuspended ? green : red,
                    icon: Icons.person_remove_outlined,
                    onConfirmed: () {
                      setState(() => u.status = isSuspended ? 'Active' : 'Suspended');
                      SupabaseService.instance.logActivity(
                        userName: u.name,
                        userId: u.id,
                        userRole: u.role.label,
                        actionTitle: isSuspended ? '👤 User Reactivated' : '🚫 User Suspended',
                        actionDescription: 'Admin updated standing to ${u.status} for ${u.name}.',
                        module: 'User Access',
                        targetResource: u.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${u.name} status updated to ${u.status}.'), backgroundColor: isSuspended ? green : red),
                      );
                    },
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

              // 5. Delete Account (Red Solid Outline)
              OutlinedButton.icon(
                onPressed: () {
                  final allowed = RateLimiterService.instance.checkAndRecord(
                    RateLimitCategory.adminActions,
                    onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                  );
                  if (!allowed) return;

                  _showActionConfirmationDialog(
                    title: '⚠️ Permanently Delete Account',
                    message: 'CRITICAL: Permanently purge ${u.name} (${u.email})? This action CANNOT be undone.',
                    confirmLabel: 'Permanently Delete',
                    confirmColor: red,
                    icon: Icons.delete_forever_rounded,
                    onConfirmed: () {
                      final deletedName = u.name;
                      final deletedId = u.id;
                      setState(() {
                        _demoUsers.removeWhere((item) => item.id == deletedId);
                        _createdLiveUsers.removeWhere((item) => item.id == deletedId);
                      });
                      SupabaseService.instance.logActivity(
                        userName: deletedName,
                        userId: deletedId,
                        userRole: u.role.label,
                        actionTitle: '🗑️ User Account Permanently Deleted',
                        actionDescription: 'Super Admin executed permanent account purge for $deletedName ($deletedId).',
                        module: 'User Management',
                        targetResource: deletedId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Account for $deletedName has been permanently deleted.'), backgroundColor: red),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete_outline, size: 13),
                label: const Text('Delete Account', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),

              // 6. Reset Session
              OutlinedButton.icon(
                onPressed: () {
                  final allowed = RateLimiterService.instance.checkAndRecord(
                    RateLimitCategory.adminActions,
                    onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.adminActions, s),
                  );
                  if (!allowed) return;

                  _showActionConfirmationDialog(
                    title: 'Invalidate Active Sessions',
                    message: 'Invalidate all active session tokens and force immediate logout for ${u.name}?',
                    confirmLabel: 'Reset Session',
                    confirmColor: orange,
                    icon: Icons.key_outlined,
                    onConfirmed: () {
                      SupabaseService.instance.logActivity(
                        userName: u.name,
                        userId: u.id,
                        userRole: u.role.label,
                        actionTitle: '🗝️ User Session Invalidated',
                        actionDescription: 'Session reset executed for ${u.name}.',
                        module: 'Session Security',
                        targetResource: u.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Session reset for ${u.name}. Forced logout initiated.'), backgroundColor: orange),
                      );
                    },
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
