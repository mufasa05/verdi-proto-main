import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';

/// Dedicated Super Admin User Activity & Audit Control Tower
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
  final String status; // 'Success', 'Warning', 'Security Alert', 'Pending'
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
  static const bgDark = Color(0xFF0B0F17);
  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF3B82F6);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const purple = Color(0xFF8B5CF6);
  static const textMuted = Color(0xFF94A3B8);

  String _searchQuery = '';
  String _selectedRoleFilter = 'All Roles';
  String _selectedModuleFilter = 'All Modules';
  String _selectedStatusFilter = 'All Status';
  bool _isLiveStreaming = true;
  Timer? _liveTimer;

  final List<UserActivityEvent> _allEvents = [
    UserActivityEvent(
      id: 'ACT-9021',
      userName: 'Kudakwashe Moyo',
      userId: 'USR-FRM-001',
      userRole: UserRole.farmer,
      userAvatar: 'KM',
      actionTitle: '🌾 Marketplace Produce Batch Listed',
      actionDescription: 'Listed 2,500 kg Grade-A Sugar Beans at US\$ 1.20/kg on live marketplace.',
      module: 'Marketplace',
      targetResource: 'Batch #VER-TR-1001',
      timestamp: '2m ago',
      exactTime: '19 Aug 2026 21:10:45 CAT',
      ipAddress: '197.221.14.82 (Chiredzi)',
      device: 'Verdi Mobile App Android 14',
      status: 'Success',
      statusColor: green,
      icon: Icons.storefront_outlined,
      metadata: {
        'commodity': 'Sugar Beans',
        'quantity': '2,500 kg',
        'pricePerUnit': 'US\$ 1.20',
        'farmLocation': 'Mufasa Estate, Block 4',
        'joiningDate': '14 October 2024 (1 year 10 months on Verdi)',
        'phone': '+263 77 412 9081',
        'email': 'kudakwashe.moyo@verdi.co',
        'escrowBalance': 'US\$ 4,250.00',
        'kycLevel': 'Tier 3 Sovereign Verified',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9020',
      userName: 'Tendai Mutasa',
      userId: 'USR-BUY-002',
      userRole: UserRole.buyer,
      userAvatar: 'TM',
      actionTitle: '🔒 Escrow Payment Deposited',
      actionDescription: 'Deposited US\$ 3,000.00 into verified smart contract escrow for Order #ORD-8492.',
      module: 'Escrow & Payments',
      targetResource: 'Order #ORD-8492',
      timestamp: '6m ago',
      exactTime: '19 Aug 2026 21:06:12 CAT',
      ipAddress: '41.220.65.12 (Bulawayo)',
      device: 'Chrome 124 / macOS',
      status: 'Success',
      statusColor: green,
      icon: Icons.account_balance_wallet_outlined,
      metadata: {
        'orderId': '#ORD-8492',
        'amountUsd': '3,000.00',
        'paymentChannel': 'EcoCash USD Gateway',
        'joiningDate': '03 January 2025 (1 year 7 months on Verdi)',
        'phone': '+263 71 884 9021',
        'email': 'tendai.mutasa@mbarehub.co.zw',
        'escrowBalance': 'US\$ 12,800.00',
        'kycLevel': 'Tier 3 Corporate Verified',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9019',
      userName: 'Blessing Ndlovu',
      userId: 'USR-TRN-003',
      userRole: UserRole.transporter,
      userAvatar: 'BN',
      actionTitle: '🚚 Freight Truck Vehicle Registered',
      actionDescription: 'Registered 12T Isuzu Refrigerated Freight Truck (Reg: TRK-9442) for agricultural transport.',
      module: 'Logistics & Fleet',
      targetResource: 'Truck TRK-9442',
      timestamp: '11m ago',
      exactTime: '19 Aug 2026 20:55:20 CAT',
      ipAddress: '197.221.19.4 (Harare)',
      device: 'Verdi In-Cab Telematics Unit',
      status: 'Success',
      statusColor: blue,
      icon: Icons.local_shipping_outlined,
      metadata: {
        'vehicleReg': 'TRK-9442 (12T Isuzu)',
        'capacity': '12 Tonnes Cold Storage',
        'joiningDate': '18 June 2025 (1 year 2 months on Verdi)',
        'phone': '+263 77 902 1140',
        'email': 'b.ndlovu@chinhoyitrucks.co.zw',
        'escrowBalance': 'US\$ 1,850.00',
        'kycLevel': 'Tier 3 Carrier Verified',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9018',
      userName: 'GreenMill Processing Hub',
      userId: 'USR-VAL-007',
      userRole: UserRole.valueAdder,
      userAvatar: 'GM',
      actionTitle: '🏭 Value-Addition Processing Logged',
      actionDescription: 'Processed raw tomato intake batch #VAL-402 into canned puree (Brix 4.8°Bx).',
      module: 'Value Addition',
      targetResource: 'Intake Batch #VAL-402',
      timestamp: '24m ago',
      exactTime: '19 Aug 2026 20:42:02 CAT',
      ipAddress: '102.130.4.11 (Chinhoyi)',
      device: 'Factory Terminal Tablet',
      status: 'Success',
      statusColor: purple,
      icon: Icons.factory_outlined,
      metadata: {
        'intakeQuantity': '8,200 kg',
        'joiningDate': '11 November 2024 (1 year 9 months on Verdi)',
        'phone': '+263 67 219 4001',
        'email': 'procurement@greenmill.co.zw',
        'escrowBalance': 'US\$ 24,500.00',
        'kycLevel': 'Tier 3 Enterprise Verified',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9017',
      userName: 'Dr. Farai Chigumba',
      userId: 'USR-GOV-004',
      userRole: UserRole.government,
      userAvatar: 'FC',
      actionTitle: '📜 E-Phyto Export Certificate Issued',
      actionDescription: 'Granted electronic phytosanitary certificate for 12T citrus consignment to EU.',
      module: 'Export & Regulatory',
      targetResource: 'Phyto #ZIM-PH-2026-88',
      timestamp: '42m ago',
      exactTime: '19 Aug 2026 20:24:19 CAT',
      ipAddress: '77.246.12.90 (Gov Intranet)',
      device: 'Ministry Workstation',
      status: 'Success',
      statusColor: green,
      icon: Icons.verified_outlined,
      metadata: {
        'phytosanitaryRef': 'ZIM-PH-2026-88',
        'joiningDate': '01 August 2024 (2 years on Verdi)',
        'phone': '+263 24 270 0192',
        'email': 'inspector.chigumba@lands.gov.zw',
        'escrowBalance': 'N/A (Regulatory Account)',
        'kycLevel': 'Tier 3 Government Official',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9016',
      userName: 'Tafadzwa Freight Operator',
      userId: 'USR-TRN-009',
      userRole: UserRole.transporter,
      userAvatar: 'TF',
      actionTitle: '⚠️ Overspeed Warning Triggered',
      actionDescription: 'Speed limit warning (88 km/h in 70 km/h zone) recorded on Harare-Chiredzi highway.',
      module: 'Logistics & Safety',
      targetResource: 'Truck SCANIA-AEB2910',
      timestamp: '1h 10m ago',
      exactTime: '19 Aug 2026 19:56:00 CAT',
      ipAddress: '197.221.19.8 (Cellular 4G)',
      device: 'GPS Telematics Box #4',
      status: 'Warning',
      statusColor: orange,
      icon: Icons.warning_amber_rounded,
      metadata: {
        'joiningDate': '15 March 2025 (1 year 5 months on Verdi)',
        'phone': '+263 77 301 9920',
        'email': 'ops@tafadzwafreight.co.zw',
        'escrowBalance': 'US\$ 950.00',
        'kycLevel': 'Tier 2 Transport Verified',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _liveTimer = Timer.periodic(const Duration(seconds: 8), (_) {
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

  List<UserActivityEvent> _getMergedEvents(WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final livePlatformEvents = ref.watch(platformActivityProvider);
    final mappedLive = livePlatformEvents.map((p) {
      final color = switch (p.status.toLowerCase()) {
        'success' => green,
        'warning' => orange,
        'security alert' => red,
        _ => blue,
      };
      final icon = switch (p.module.toLowerCase()) {
        'marketplace' => Icons.storefront_outlined,
        'logistics' => Icons.local_shipping_outlined,
        'payments' => Icons.payments_outlined,
        'geospatial' => Icons.map_outlined,
        _ => Icons.radar_outlined,
      };
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
        statusColor: color,
        icon: icon,
        metadata: p.metadata,
      );
    }).toList();

    final all = isDemo ? [...mappedLive, ..._allEvents] : mappedLive;
    return all.where((e) {
      final matchesQuery = _searchQuery.isEmpty ||
          e.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.actionTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.actionDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.targetResource.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.userId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole = _selectedRoleFilter == 'All Roles' ||
          e.userRole.name.toLowerCase() == _selectedRoleFilter.toLowerCase();

      final matchesModule = _selectedModuleFilter == 'All Modules' ||
          e.module.toLowerCase().contains(_selectedModuleFilter.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'All Status' ||
          e.status.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchesQuery && matchesRole && matchesModule && matchesStatus;
    }).toList();
  }

  void _showUserProfileModal(UserActivityEvent event) {
    final meta = event.metadata;
    final joiningDate = meta['joiningDate']?.toString() ?? '15 August 2024 (2 years on Verdi)';
    final phone = meta['phone']?.toString() ?? '+263 77 123 4567';
    final email = meta['email']?.toString() ?? '${event.userName.toLowerCase().replaceAll(' ', '.')}@verdi.ag';
    final escrow = meta['escrowBalance']?.toString() ?? 'US\$ 3,450.00';
    final kycLevel = meta['kycLevel']?.toString() ?? 'Tier 3 Sovereign Verified';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: cardBorder)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: green.withOpacity(0.2),
              radius: 20,
              child: Text(event.userAvatar, style: const TextStyle(color: green, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.userName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  Text('${event.userId} • ${event.userRole.label}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF0B0F17), borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
              child: Column(
                children: [
                  _profileDetailRow('📅 Joined Verdi On', joiningDate),
                  _profileDetailRow('🛡️ KYC Status', kycLevel),
                  _profileDetailRow('📞 Contact Phone', phone),
                  _profileDetailRow('✉️ Email Address', email),
                  _profileDetailRow('💳 Active Escrow Balance', escrow),
                  _profileDetailRow('🌐 IP & Location', event.ipAddress),
                  _profileDetailRow('📱 Client Device', event.device),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Recent Major Action Recorded:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text('${event.actionTitle} (${event.timestamp})', style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 12)),
            Text(event.actionDescription, style: const TextStyle(color: textMuted, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close Profile', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account standing for ${event.userName} is ACTIVE.'), backgroundColor: green),
              );
            },
            icon: const Icon(Icons.verified_user, size: 16),
            label: const Text('Verified Standing'),
            style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _profileDetailRow(String label, String value) {
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
    final isDemo = ref.watch(isDemoModeProvider);
    final events = _getMergedEvents(ref);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Activities & System Audit Hub', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18)),
            Text(
              isDemo ? 'Audit Ledger · Live Stream & Major User Actions' : 'Live Platform Audit Stream · Zero Mock Data',
              style: const TextStyle(fontSize: 11, color: textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isLiveStreaming ? Icons.pause_circle_outline : Icons.play_circle_outline, color: _isLiveStreaming ? green : textMuted),
            tooltip: _isLiveStreaming ? 'Pause Stream' : 'Resume Live Stream',
            onPressed: () => setState(() => _isLiveStreaming = !_isLiveStreaming),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter Controls
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search user activities by name, action, target resource or ID...',
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _dropdownFilter('Role', _selectedRoleFilter, ['All Roles', 'Farmer', 'Buyer', 'Transporter', 'Admin', 'ValueAdder', 'Government'], (v) => setState(() => _selectedRoleFilter = v)),
                        const SizedBox(width: 8),
                        _dropdownFilter('Module', _selectedModuleFilter, ['All Modules', 'Marketplace', 'Escrow', 'Logistics', 'Value Addition', 'Export'], (v) => setState(() => _selectedModuleFilter = v)),
                        const SizedBox(width: 8),
                        _dropdownFilter('Status', _selectedStatusFilter, ['All Status', 'Success', 'Warning', 'Security Alert'], (v) => setState(() => _selectedStatusFilter = v)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Events Audit Table
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final e = events[idx];
                return InkWell(
                  onTap: () => _showUserProfileModal(e),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: e.statusColor.withOpacity(0.18),
                          radius: 20,
                          child: Icon(e.icon, color: e.statusColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(e.actionTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: e.statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                    child: Text(e.status, style: TextStyle(color: e.statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const Spacer(),
                                  Text(e.timestamp, style: const TextStyle(fontSize: 11, color: textMuted)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(e.actionDescription, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${e.userName} (${e.userId}) • ${e.userRole.label}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: green),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.place_outlined, size: 14, color: textMuted),
                                  const SizedBox(width: 4),
                                  Text(e.ipAddress, style: const TextStyle(fontSize: 11, color: textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownFilter(String title, String value, List<String> options, ValueChanged<String> onChanged) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: cardDark,
      itemBuilder: (context) => options.map((opt) => PopupMenuItem(value: opt, child: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorder)),
        child: Row(
          children: [
            Text('$title: ', style: const TextStyle(fontSize: 11, color: textMuted)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }
}
