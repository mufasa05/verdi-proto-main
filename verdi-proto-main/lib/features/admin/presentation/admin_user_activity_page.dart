import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN USER ACTIVITY & SYSTEM AUDIT LOGS PAGE
// Dedicated Super Admin activity control tower tracking every action from all users.
// ─────────────────────────────────────────────────────────────────────────────

class AdminUserActivityPage extends ConsumerStatefulWidget {
  const AdminUserActivityPage({super.key});

  @override
  ConsumerState<AdminUserActivityPage> createState() =>
      _AdminUserActivityPageState();
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
      actionTitle: 'Marketplace Produce Batch Listed',
      actionDescription: 'Listed 2,500 kg Grade-A Sugar Beans at US\$ 1.20/kg with origin certification.',
      module: 'Marketplace',
      targetResource: 'Batch #VER-TR-1001',
      timestamp: '2m ago',
      exactTime: '14 Aug 2026 11:10:45 CAT',
      ipAddress: '197.221.14.82 (Harare)',
      device: 'Verdi Mobile App Android 14',
      status: 'Success',
      statusColor: green,
      icon: Icons.storefront_outlined,
      metadata: {
        'commodity': 'Sugar Beans',
        'quantity': '2,500 kg',
        'pricePerUnit': 'US\$ 1.20',
        'farmLocation': 'Mufasa Estate, Block 4',
        'geoCoords': '-17.8292, 31.0522',
        'integrityHash': '0x8f2a...c81e',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9020',
      userName: 'Tendai Mutasa',
      userId: 'USR-BUY-002',
      userRole: UserRole.buyer,
      userAvatar: 'TM',
      actionTitle: 'Escrow Payment Deposited',
      actionDescription: 'Deposited US\$ 3,000.00 into verified smart contract escrow for Order #ORD-8492.',
      module: 'Escrow & Payments',
      targetResource: 'Order #ORD-8492',
      timestamp: '6m ago',
      exactTime: '14 Aug 2026 11:06:12 CAT',
      ipAddress: '41.220.65.12 (Bulawayo)',
      device: 'Chrome 124 / macOS',
      status: 'Success',
      statusColor: green,
      icon: Icons.account_balance_wallet_outlined,
      metadata: {
        'orderId': '#ORD-8492',
        'amountUsd': '3,000.00',
        'paymentChannel': 'EcoCash USD Gateway',
        'escrowContract': '0x71a...99bf',
        'payoutState': 'LOCKED_UNTIL_DELIVERY',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9019',
      userName: 'Blessing Ndlovu',
      userId: 'USR-TRN-003',
      userRole: UserRole.transporter,
      userAvatar: 'BN',
      actionTitle: 'High-Precision GPS Telemetry Transmitted',
      actionDescription: 'Transmitted OBD-II route telemetry on Harare-Bulawayo corridor (Speed: 78.4 km/h).',
      module: 'Logistics & Fleet',
      targetResource: 'Truck TRK-9442',
      timestamp: '11m ago',
      exactTime: '14 Aug 2026 11:01:20 CAT',
      ipAddress: '197.221.19.4 (Cellular 4G)',
      device: 'Verdi In-Cab Telematics Unit',
      status: 'Success',
      statusColor: blue,
      icon: Icons.navigation_outlined,
      metadata: {
        'vehicleReg': 'TRK-9442 (12T Isuzu)',
        'driver': 'Tendai Moyo',
        'currentWaypoint': 'Chivhu Tollgate',
        'reeferTemp': '4.2°C',
        'distanceRemaining': '214 km',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9018',
      userName: 'GreenMill Processing Hub',
      userId: 'USR-VAL-007',
      userRole: UserRole.valueAdder,
      userAvatar: 'GM',
      actionTitle: 'Quality Intake & Brix Inspection Logged',
      actionDescription: 'Graded raw tomato intake batch #VAL-402 (Brix 4.8°Bx, Reject rate 1.2%).',
      module: 'Value Addition',
      targetResource: 'Intake Batch #VAL-402',
      timestamp: '24m ago',
      exactTime: '14 Aug 2026 10:48:02 CAT',
      ipAddress: '102.130.4.11 (Chinhoyi)',
      device: 'Factory Terminal Tablet',
      status: 'Success',
      statusColor: purple,
      icon: Icons.factory_outlined,
      metadata: {
        'intakeQuantity': '8,200 kg',
        'brixLevel': '4.8°Bx',
        'phLevel': '4.3',
        'batchDestination': 'Tomato Paste Line #1',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9017',
      userName: 'Dr. Farai Chigumba',
      userId: 'USR-GOV-004',
      userRole: UserRole.government,
      userAvatar: 'FC',
      actionTitle: 'E-Phyto Export Certificate Approved',
      actionDescription: 'Granted electronic phytosanitary certificate for 12T citrus consignment to EU.',
      module: 'Export & Regulatory',
      targetResource: 'Phyto #ZIM-PH-2026-88',
      timestamp: '42m ago',
      exactTime: '14 Aug 2026 10:30:19 CAT',
      ipAddress: '77.246.12.90 (Gov Intranet)',
      device: 'Ministry Workstation / Edge',
      status: 'Success',
      statusColor: green,
      icon: Icons.verified_outlined,
      metadata: {
        'phytosanitaryRef': 'ZIM-PH-2026-88',
        'destinationPort': 'Rotterdam Port (NL)',
        'satellitePurity': '100% EUDR Compliant',
        'quarantineOfficer': 'Chief Inspector Farai',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9016',
      userName: 'Chipo Sibanda',
      userId: 'USR-EXP-005',
      userRole: UserRole.expert,
      userAvatar: 'CS',
      actionTitle: 'AI Agronomy Advisory Chat Conducted',
      actionDescription: 'Provided customized biological pest management advice for Fall Armyworm outbreak.',
      module: 'AI Advisory',
      targetResource: 'Advisory Session #ADV-109',
      timestamp: '1h ago',
      exactTime: '14 Aug 2026 10:12:00 CAT',
      ipAddress: '41.77.20.101 (Mutare)',
      device: 'Verdi Agronomist Portal',
      status: 'Success',
      statusColor: green,
      icon: Icons.chat_bubble_outline,
      metadata: {
        'clientFarmer': 'Simba Agro Mazowe',
        'cropDiagnosed': 'Maize (Zea mays)',
        'recommendedTreatment': 'Bacillus thuringiensis (Bt spray)',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9015',
      userName: 'Simbarashe Dube',
      userId: 'USR-CON-008',
      userRole: UserRole.consumer,
      userAvatar: 'SD',
      actionTitle: 'Suspicious Multiple Login Attempts',
      actionDescription: '5 failed password attempts within 90 seconds from unrecognized IP subnet.',
      module: 'Security & Auth',
      targetResource: 'Account USR-008',
      timestamp: '1h 20m ago',
      exactTime: '14 Aug 2026 09:52:14 CAT',
      ipAddress: '185.220.101.5 (Tor Exit Node)',
      device: 'Automated Script / Python urllib',
      status: 'Security Alert',
      statusColor: red,
      icon: Icons.gpp_maybe_outlined,
      metadata: {
        'trigger': 'RATE_LIMIT_EXCEEDED',
        'actionTaken': 'AUTO_ACCOUNT_TEMPORARY_LOCK',
        'failedCount': '5 attempts',
        'riskScore': '94/100 (High Threat)',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9014',
      userName: 'Stanbic Agri Capital',
      userId: 'USR-FIN-006',
      userRole: UserRole.financier,
      userAvatar: 'SC',
      actionTitle: 'Seasonal Input Credit Line Disbursed',
      actionDescription: 'Approved and credited US\$ 15,000 seasonal facility for Chiredzi Sugarcane Scheme.',
      module: 'Finance & Lending',
      targetResource: 'Credit #FIN-CRED-881',
      timestamp: '2h ago',
      exactTime: '14 Aug 2026 09:15:30 CAT',
      ipAddress: '196.220.88.10 (Bank VPN)',
      device: 'Financier Underwriting Suite',
      status: 'Success',
      statusColor: green,
      icon: Icons.payments_outlined,
      metadata: {
        'creditFacility': 'Seasonal Revolving Input Fund',
        'tenorMonths': '9 months',
        'collateral': 'Warehouse Receipt WR-0912',
      },
    ),
    UserActivityEvent(
      id: 'ACT-9013',
      userName: 'Tinashe Zvobgo (Super Admin)',
      userId: 'USR-ADM-009',
      userRole: UserRole.admin,
      userAvatar: 'TZ',
      actionTitle: 'Global RBAC Permission Matrix Modified',
      actionDescription: 'Updated permission set for Transporter role to enable live GPS telemetry broadcast.',
      module: 'System Governance',
      targetResource: 'Role: Transporter',
      timestamp: '3h ago',
      exactTime: '14 Aug 2026 08:12:44 CAT',
      ipAddress: '10.0.0.1 (Admin Secure Subnet)',
      device: 'Verdi Sovereign Admin Console',
      status: 'Success',
      statusColor: orange,
      icon: Icons.admin_panel_settings_outlined,
      metadata: {
        'modifiedRole': 'UserRole.transporter',
        'grantedPermissions': ['CAN_BROADCAST_TELEMETRY', 'VIEW_FREIGHT_ORDERS', 'SIGN_DIGITAL_WAYBILL'],
        'dualSignOff': 'VERIFIED_BY_SECURITY_KEY',
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

  List<UserActivityEvent> get _filteredEvents {
    return _allEvents.where((e) {
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

  void _showEventDetailsModal(UserActivityEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: event.statusColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(event.icon, color: event.statusColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.actionTitle, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('ID: ${event.id} • ${event.exactTime}', style: const TextStyle(fontSize: 12, color: textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: event.statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: event.statusColor.withOpacity(0.4)),
                        ),
                        child: Text(event.status, style: TextStyle(color: event.statusColor, fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: cardBorder),
                  const SizedBox(height: 16),
                  _detailRow('Acting User', '${event.userName} (${event.userId})'),
                  _detailRow('User Role', event.userRole.name.toUpperCase()),
                  _detailRow('Platform Module', event.module),
                  _detailRow('Target Resource', event.targetResource),
                  _detailRow('Origin IP & Location', event.ipAddress),
                  _detailRow('Client Device', event.device),
                  const SizedBox(height: 16),
                  Text('Action Description:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
                    child: Text(event.actionDescription, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                  ),
                  const SizedBox(height: 20),
                  Text('Cryptographic Payload Metadata:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: event.metadata.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text('${entry.key}: ', style: const TextStyle(color: blue, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                              Expanded(child: Text('${entry.value}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Close Audit Entry'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cryptographic verification receipt generated for ${event.id}.'),
                                backgroundColor: green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.verified_outlined, size: 16),
                          label: const Text('Verify Signature'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textMuted, fontSize: 12.5)),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              ref.read(appStateProvider.notifier).setNavIndex(0);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'User Activity & System Audit Hub',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (_isLiveStreaming ? green : orange).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (_isLiveStreaming ? green : orange).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: _isLiveStreaming ? green : orange, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(_isLiveStreaming ? 'LIVE AUDIT' : 'STREAM PAUSED', style: TextStyle(color: _isLiveStreaming ? green : orange, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            Text('Omni-Channel Stakeholder Action & Mutation Stream', style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isLiveStreaming ? Icons.pause_circle_outline : Icons.play_circle_outline, color: Colors.white70),
            tooltip: _isLiveStreaming ? 'Pause Live Stream' : 'Resume Live Stream',
            onPressed: () => setState(() => _isLiveStreaming = !_isLiveStreaming),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white70),
            tooltip: 'Export Audit Log (CSV)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Exporting 1,428 system audit records to CSV...'),
                  backgroundColor: blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 22 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top KPI Grid ──
                  _buildKpiGrid(isDesktop),
                  const SizedBox(height: 20),

                  // ── Search & Multi-Filter Rail ──
                  _buildFilterBar(),
                  const SizedBox(height: 20),

                  // ── Activities Count & Actions ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Logged Actions (${events.length} shown)',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedRoleFilter = 'All Roles';
                            _selectedModuleFilter = 'All Modules';
                            _selectedStatusFilter = 'All Status';
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 14, color: blue),
                        label: const Text('Reset Filters', style: TextStyle(color: blue, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Activity Stream List ──
                  if (events.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: cardBorder)),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: textMuted),
                          const SizedBox(height: 12),
                          Text('No user activities match this filter criteria.', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 6),
                          const Text('Try clearing your search query or role/module filters.', style: TextStyle(color: textMuted, fontSize: 12.5)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final e = events[idx];
                        return _buildActivityCard(e);
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(bool isDesktop) {
    final kpis = [
      _KpiSummary('1,428', 'Total User Actions', '+84 this hour', Icons.analytics_outlined, green),
      _KpiSummary('86', 'Active Sessions', 'Across 8 provinces', Icons.people_alt_outlined, blue),
      _KpiSummary('US\$ 48.2k', 'Trade Volume Logged', '100% in escrow', Icons.account_balance_wallet_outlined, purple),
      _KpiSummary('0', 'Critical Security Breaches', 'All nodes safe', Icons.shield_outlined, green),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: isDesktop ? 2.1 : 1.7,
      ),
      itemBuilder: (context, i) {
        final k = kpis[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: k.color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Icon(k.icon, color: k.color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(k.label, style: const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(k.value, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 2),
              Text(k.sub, style: TextStyle(fontSize: 10.5, color: k.color, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
    final roles = ['All Roles', 'Farmer', 'Buyer', 'Transporter', 'ValueAdder', 'Government', 'Financier', 'Expert', 'Admin'];
    final modules = ['All Modules', 'Marketplace', 'Logistics', 'Escrow', 'Export', 'AI', 'Security', 'Finance'];
    final statuses = ['All Status', 'Success', 'Warning', 'Security Alert'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Search by user name, action, resource ID, or IP...',
              hintStyle: const TextStyle(color: textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: textMuted, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: textMuted, size: 16),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: bgDark,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: blue)),
            ),
          ),
          const SizedBox(height: 12),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDropdownFilter('Role: $_selectedRoleFilter', roles, (val) => setState(() => _selectedRoleFilter = val)),
                const SizedBox(width: 8),
                _buildDropdownFilter('Module: $_selectedModuleFilter', modules, (val) => setState(() => _selectedModuleFilter = val)),
                const SizedBox(width: 8),
                _buildDropdownFilter('Status: $_selectedStatusFilter', statuses, (val) => setState(() => _selectedStatusFilter = val)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, List<String> items, ValueChanged<String> onSelected) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: cardBorder)),
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bgDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, color: textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(UserActivityEvent e) {
    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: InkWell(
        onTap: () => _showEventDetailsModal(e),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: _roleColor(e.userRole).withOpacity(0.2),
                child: Text(
                  e.userAvatar,
                  style: TextStyle(color: _roleColor(e.userRole), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(e.userName, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _roleColor(e.userRole).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            e.userRole.name.toUpperCase(),
                            style: TextStyle(color: _roleColor(e.userRole), fontSize: 9.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        Text(e.timestamp, style: const TextStyle(color: textMuted, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(e.actionTitle, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFFE2E8F0))),
                    const SizedBox(height: 2),
                    Text(e.actionDescription, style: const TextStyle(color: textMuted, fontSize: 11.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),

                    // Tags row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _tag(Icons.layers_outlined, e.module, blue),
                        _tag(Icons.pin_outlined, e.targetResource, purple),
                        _tag(Icons.location_on_outlined, e.ipAddress.split(' ').first, textMuted),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              // Status pill & chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: e.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: e.statusColor.withOpacity(0.3)),
                    ),
                    child: Text(e.status, style: TextStyle(color: e.statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(6), border: Border.all(color: cardBorder)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return green;
      case UserRole.buyer:
        return blue;
      case UserRole.transporter:
        return orange;
      case UserRole.valueAdder:
        return purple;
      case UserRole.government:
        return const Color(0xFF0F766E);
      case UserRole.financier:
        return const Color(0xFFD97706);
      case UserRole.admin:
        return red;
      default:
        return textMuted;
    }
  }
}

class _KpiSummary {
  final String value, label, sub;
  final IconData icon;
  final Color color;
  const _KpiSummary(this.value, this.label, this.sub, this.icon, this.color);
}
