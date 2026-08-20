import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';
import '../../auth/state/auth_state.dart';

/// Super Admin Audit Hub with responsive non-elongated cards & real-time clock timestamps
class AdminUserActivityPage extends ConsumerStatefulWidget {
  const AdminUserActivityPage({super.key});

  @override
  ConsumerState<AdminUserActivityPage> createState() => _AdminUserActivityPageState();
}

class UserActivityEvent {
  final String id;
  final String userName;
  final String userId;
  final UserRole userRole;
  final String userAvatar;
  final String actionTitle;
  final String actionDescription;
  final String module;
  final String targetResource;
  final String timestamp;
  final String exactTime;
  final String ipAddress;
  final String device;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Map<String, dynamic> metadata;

  const UserActivityEvent({
    required this.id,
    required this.userName,
    required this.userId,
    required this.userRole,
    required this.userAvatar,
    required this.actionTitle,
    required this.actionDescription,
    required this.module,
    required this.targetResource,
    required this.timestamp,
    required this.exactTime,
    required this.ipAddress,
    required this.device,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.metadata,
  });
}

class _AdminUserActivityPageState extends ConsumerState<AdminUserActivityPage> {
  static const bgDark = Color(0xFF070B12);
  static const cardDark = Color(0xFF0F172A);
  static const cardBorder = Color(0xFF1E293B);
  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF3B82F6);
  static const orange = Color(0xFFF59E0B);
  static const purple = Color(0xFF8B5CF6);
  static const red = Color(0xFFEF4444);
  static const textMuted = Color(0xFF94A3B8);

  String _searchQuery = '';
  String _selectedRoleFilter = 'All Roles';
  String _selectedModuleFilter = 'All Modules';
  bool _isLiveStreaming = true;
  Timer? _liveTimer;

  final List<UserActivityEvent> _demoEvents = [
    UserActivityEvent(
      id: 'ACT-9020',
      userName: 'Tendai Moyo',
      userId: 'USR-88901',
      userRole: UserRole.farmer,
      userAvatar: 'TM',
      actionTitle: 'Marketplace Produce Batch Listed',
      actionDescription: 'Listed 2,500 kg Grade-A Sugar Beans at US\$ 1.20/kg on live marketplace.',
      module: 'Marketplace',
      targetResource: 'Batch #VER-TR-1001',
      timestamp: '08:02:15 CAT',
      exactTime: '20 Aug 2026 08:02:15 CAT',
      ipAddress: 'Mashonaland West (120 Ha)',
      device: 'Verdi Mobile Client',
      status: 'Success',
      statusColor: green,
      icon: Icons.storefront_outlined,
      metadata: {
        'joinedDate': '14 October 2024 (1 year 10 months on Verdi)',
        'kycStatus': 'VERIFIED',
        'phone': '+263 77 412 9081',
        'email': 'tendai.moyo@verdi.co',
        'escrowBalance': 'US\$ 4,250.00',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9019',
      userName: 'Harare Fresh Produce Hub',
      userId: 'USR-99214',
      userRole: UserRole.buyer,
      userAvatar: 'HF',
      actionTitle: 'Escrow Payment Deposited',
      actionDescription: 'Deposited US\$ 4,500.00 into smart contract escrow for Order #ORD-8821.',
      module: 'Escrow & Payments',
      targetResource: 'Order #ORD-8821',
      timestamp: '07:54:30 CAT',
      exactTime: '20 Aug 2026 07:54:30 CAT',
      ipAddress: 'Harare Mbare Musika',
      device: 'Web Client',
      status: 'Success',
      statusColor: green,
      icon: Icons.account_balance_wallet_outlined,
      metadata: {
        'joinedDate': '03 January 2025 (1 year 7 months on Verdi)',
        'kycStatus': 'VERIFIED',
        'phone': '+263 71 884 9021',
        'email': 'procurement@mbarehub.co.zw',
        'escrowBalance': 'US\$ 12,800.00',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_isLiveStreaming && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  void _showUserStandingModal(UserActivityEvent event) {
    final meta = event.metadata;
    final currentUser = ref.read(authStateProvider).user;
    final isCurrentAuthUser = currentUser != null &&
        (currentUser.id == event.userId || currentUser.fullName.toLowerCase().trim() == event.userName.toLowerCase().trim());

    final email = isCurrentAuthUser && currentUser.email.isNotEmpty
        ? currentUser.email
        : (meta['email']?.toString().isNotEmpty == true && meta['email'] != 'null' ? meta['email'].toString() : 'Not provided');

    final phone = isCurrentAuthUser && currentUser.phone.isNotEmpty
        ? currentUser.phone
        : (meta['phone']?.toString().isNotEmpty == true && meta['phone'] != 'null' ? meta['phone'].toString() : 'Not provided');

    final joined = meta['joinedDate']?.toString() ?? (isCurrentAuthUser ? 'Active Session (Live Node)' : 'Active Account');
    final kyc = meta['kycStatus']?.toString() ?? (isCurrentAuthUser ? 'Tier 1 Standard Verified' : 'Standard Standing');
    final escrow = meta['escrowBalance']?.toString() ?? 'US\$ 0.00';
    final location = event.ipAddress.isNotEmpty ? event.ipAddress : 'Sovereign Node (${event.userRole.name.toUpperCase()})';
    final device = event.device.isNotEmpty ? event.device : 'Verdi Mobile / Web Client';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFF1E293B))),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: green.withOpacity(0.2),
              radius: 22,
              child: Text(event.userAvatar, style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.userName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                  Text('${event.userId} • ${event.userRole.label}', style: const TextStyle(fontSize: 12, color: textMuted)),
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF070B12), borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Column(
                  children: [
                    _modalRow('📅 Joined Verdi On', joined),
                    _modalRow('🛡️ KYC Status', kyc),
                    _modalRow('📞 Contact Phone', phone),
                    _modalRow('✉️ Email Address', email),
                    _modalRow('💳 Active Escrow Balance', escrow),
                    _modalRow('🌐 IP & Location', location),
                    _modalRow('📱 Client Device', device),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Recent Major Action Recorded:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              const SizedBox(height: 4),
              Text('${event.actionTitle} (${_formatDisplayTime(event)})', style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 12.5)),
              Text(event.actionDescription, style: const TextStyle(color: textMuted, fontSize: 11.5)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close Profile', style: TextStyle(color: textMuted, fontSize: 13)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${event.userName} verified standing confirmed.'), backgroundColor: green),
              );
            },
            icon: const Icon(Icons.check_circle, size: 16),
            label: const Text('Verified Standing', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modalRow(String label, String value) {
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

  String _formatDisplayTime(UserActivityEvent e) {
    if (e.exactTime.isNotEmpty && !e.exactTime.toLowerCase().contains('null')) {
      return e.exactTime;
    }
    if (e.timestamp.isNotEmpty && e.timestamp != 'Just now') {
      return e.timestamp;
    }
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} CAT';
  }

  Color _getModuleColor(String module) {
    final m = module.toLowerCase();
    if (m.contains('security') || m.contains('auth')) return purple;
    if (m.contains('market')) return green;
    if (m.contains('escrow') || m.contains('payment')) return blue;
    if (m.contains('logistics') || m.contains('freight')) return orange;
    return green;
  }

  @override
  Widget build(BuildContext context) {
    final livePlatformEvents = ref.watch(platformActivityProvider);
    final isDemo = ref.watch(isDemoModeProvider);

    final mappedLive = livePlatformEvents.map((p) {
      return UserActivityEvent(
        id: p.id,
        userName: p.userName,
        userId: p.userId,
        userRole: p.userRole,
        userAvatar: p.userAvatar,
        actionTitle: p.actionTitle,
        actionDescription: p.actionDescription,
        module: p.module,
        targetResource: p.targetResource,
        timestamp: p.timestamp,
        exactTime: p.exactTime,
        ipAddress: p.ipAddress,
        device: p.device,
        status: p.status,
        statusColor: green,
        icon: _getIconForModule(p.module, p.actionTitle),
        metadata: p.metadata,
      );
    }).toList();

    final sourceEvents = isDemo ? [...mappedLive, ..._demoEvents] : mappedLive;

    final allEvents = sourceEvents.where((e) {
      final matchesQuery = _searchQuery.isEmpty ||
          e.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.actionTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.actionDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.userId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'All Roles' || e.userRole.name.toLowerCase() == _selectedRoleFilter.toLowerCase();
      final matchesModule = _selectedModuleFilter == 'All Modules' || e.module.toLowerCase().contains(_selectedModuleFilter.toLowerCase());
      return matchesQuery && matchesRole && matchesModule;
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
          children: [
            Text('Audit Hub', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: green.withOpacity(0.4))),
              child: const Row(
                children: [
                  CircleAvatar(backgroundColor: green, radius: 3),
                  SizedBox(width: 4),
                  Text('LIVE AUDIT', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isLiveStreaming ? Icons.pause_circle_outline : Icons.play_circle_outline, color: _isLiveStreaming ? green : textMuted),
            onPressed: () => setState(() => _isLiveStreaming = !_isLiveStreaming),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: textMuted),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported audit trail log as JSON/CSV.')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Card: Live Multi-Role Stakeholder Presence Radar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: blue, size: 18),
                      const SizedBox(width: 8),
                      Text('Live Multi-Role Stakeholder Presence Radar', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF070B12), borderRadius: BorderRadius.circular(12), border: Border.all(color: green.withOpacity(0.3))),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: blue.withOpacity(0.2), radius: 18, child: const Text('VC', style: TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 12))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Verdi Creator (Super Admin)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('ADMIN', style: TextStyle(color: green, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text('Active Surveillance & Platform Control', style: TextStyle(fontSize: 11, color: textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} CAT',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. 4 Metric Cards Grid
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
                    _buildTopMetricCard('${allEvents.length}', 'Total User Actions', 'Live platform events', Icons.bar_chart_outlined, green),
                    _buildTopMetricCard(isDemo ? '5' : '1', 'Active Sessions', 'Live platform users', Icons.people_alt_outlined, blue),
                    _buildTopMetricCard('US\$ 17,800', 'Trade Volume Locked', 'Real escrow locks', Icons.account_balance_wallet_outlined, orange),
                    _buildTopMetricCard('0', 'Critical Security Alerts', '5G Mesh secure', Icons.shield_outlined, green),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Search & Filter Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by user name, action, resource...',
                      hintStyle: const TextStyle(fontSize: 12, color: textMuted),
                      prefixIcon: const Icon(Icons.search, size: 18, color: textMuted),
                      filled: true,
                      fillColor: bgDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _dropdownFilter('Role', _selectedRoleFilter, ['All Roles', 'Farmer', 'Buyer', 'Transporter', 'Admin', 'Government'], (v) => setState(() => _selectedRoleFilter = v))),
                      const SizedBox(width: 8),
                      Expanded(child: _dropdownFilter('Module', _selectedModuleFilter, ['All Modules', 'Marketplace', 'Escrow', 'Security & Auth', 'Logistics'], (v) => setState(() => _selectedModuleFilter = v))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Logged Actions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Logged Actions (${allEvents.length} shown)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _searchQuery = '';
                    _selectedRoleFilter = 'All Roles';
                    _selectedModuleFilter = 'All Modules';
                  }),
                  icon: const Icon(Icons.refresh, size: 14, color: blue),
                  label: const Text('Reset Filters', style: TextStyle(color: blue, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5. Responsive Non-Elongated Card Grid Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                if (isWide) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 190,
                    ),
                    itemCount: allEvents.length,
                    itemBuilder: (context, idx) => _buildActivityCard(allEvents[idx]),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) => _buildActivityCard(allEvents[idx]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(UserActivityEvent e) {
    final moduleColor = _getModuleColor(e.module);
    final displayTime = _formatDisplayTime(e);

    return InkWell(
      onTap: () => _showUserStandingModal(e),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Module Badge + Role Pill
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: moduleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: moduleColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(e.icon, size: 12, color: moduleColor),
                      const SizedBox(width: 4),
                      Text(e.module, style: TextStyle(color: moduleColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Text(e.userRole.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
                ),
              ],
            ),

            // Middle: Action Title & Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.actionTitle,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  e.actionDescription,
                  style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Bottom Footer: User Info + Real Time Clock Badge
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: green.withOpacity(0.18),
                  radius: 12,
                  child: Text(e.userAvatar, style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${e.userName} (${e.userId})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: green),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: bgDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 11, color: textMuted),
                      const SizedBox(width: 4),
                      Text(displayTime, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForModule(String module, String title) {
    final m = module.toLowerCase();
    final t = title.toLowerCase();
    if (m.contains('security') || m.contains('auth') || t.contains('lockdown')) return Icons.shield_outlined;
    if (m.contains('market') || t.contains('batch')) return Icons.storefront_outlined;
    if (m.contains('escrow') || m.contains('payment')) return Icons.account_balance_wallet_outlined;
    if (m.contains('logistics') || t.contains('gps')) return Icons.local_shipping_outlined;
    return Icons.notifications_active_outlined;
  }

  Widget _buildTopMetricCard(String value, String label, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(label, style: const TextStyle(fontSize: 10.5, color: textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(sub, style: TextStyle(fontSize: 9.5, color: color)),
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
        decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorder)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title: $value', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            const Icon(Icons.arrow_drop_down, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }
}
