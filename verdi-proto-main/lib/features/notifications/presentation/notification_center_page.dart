import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdi/state/app_state.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends ConsumerState<NotificationCenterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSourceFilter = 'All';

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const background = Color(0xFFF8FAFC);

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
    final role = ref.watch(appStateProvider).role;
    final isTransporter = role == UserRole.transporter;
    final isAdmin = role == UserRole.admin;
    final isExpert = role == UserRole.expert;
    final isReadOnly = role != UserRole.farmer && role != UserRole.admin && role != UserRole.transporter && role != UserRole.expert;

    final roleAccentColor = isAdmin
        ? const Color(0xFF7C3AED)
        : (isTransporter
            ? const Color(0xFF2563EB)
            : (isExpert
                ? const Color(0xFF10B981)
                : green));

    final sourceFilters = isAdmin
        ? ['All', 'Security & KYC', 'Escrow Vault', 'API Gateway', 'Satellite Telemetry', 'System Health']
        : (isTransporter
            ? ['All', 'Route Hazards', 'Telematics', 'Cold Chain', 'Weighbridge & Tolls', 'Escrow Payout']
            : (isExpert
                ? ['All', 'Disease Outbreaks', 'Farmer Consultations', 'Soil & Lab Tests', 'Field Rx Prescriptions', 'Advisory Payouts']
                : ['All', 'Irrigation', 'Satellite', 'Crop Health', 'System']));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          isAdmin
              ? 'Security & Infrastructure Notification Center'
              : (isTransporter
                  ? 'Transporter Road & Dispatch Alerts'
                  : (isExpert
                      ? 'Agri-Expert Diagnostic & Clinical Advisory Alerts'
                      : 'Alerts & Exceptions Board')),
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: dark, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: roleAccentColor,
              unselectedLabelColor: muted,
              indicatorColor: roleAccentColor,
              tabs: const [
                Tab(text: 'Critical'),
                Tab(text: 'Warning'),
                Tab(text: 'Info'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter chip rail
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: sourceFilters.map((f) {
                        final isSelected = _selectedSourceFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f, style: TextStyle(color: isSelected ? Colors.white : dark, fontSize: 12, fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedSourceFilter = f);
                            },
                            selectedColor: roleAccentColor,
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Main alerts list in tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAlertList(context, 'Critical', isReadOnly, role, roleAccentColor),
                      _buildAlertList(context, 'Warning', isReadOnly, role, roleAccentColor),
                      _buildAlertList(context, 'Info', isReadOnly, role, roleAccentColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertList(BuildContext context, String severity, bool isReadOnly, UserRole role, Color roleAccentColor) {
    final isDemo = ref.watch(isDemoModeProvider);
    final alertList = role == UserRole.admin
        ? (isDemo ? _adminAlerts : <_AlertEntry>[])
        : (role == UserRole.transporter
            ? (isDemo ? _transporterAlerts : <_AlertEntry>[])
            : (role == UserRole.expert
                ? (isDemo ? _expertAlerts : <_AlertEntry>[])
                : (isDemo ? _allAlerts : <_AlertEntry>[])));
    // Filter alerts by severity and source
    final alerts = alertList.where((a) {
      final matchesSeverity = a.severity == severity;
      final matchesSource = _selectedSourceFilter == 'All' || a.source == _selectedSourceFilter;
      return matchesSeverity && matchesSource;
    }).toList();

    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off_outlined, size: 64, color: muted.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                'All clear!',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: dark),
              ),
              Text(
                'No $severity alerts match the selected filters.',
                style: const TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, i) {
        final alert = alerts[i];
        final alertColor = alert.severity == 'Critical'
            ? red
            : (alert.severity == 'Warning' ? orange : green);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: alertColor.withValues(alpha: 0.2))),
          color: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: alertColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(alert.icon, color: alertColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            alert.source,
                            style: TextStyle(color: alertColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(alert.time, style: const TextStyle(color: muted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  alert.title,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: dark),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.details,
                  style: const TextStyle(fontSize: 13, color: muted),
                ),
                const Divider(height: 24),

                // AI operational risk analysis block
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: blue.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 290;
                          final titleRow = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.smart_toy_outlined, color: blue, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'AI Operational Analysis',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: blue),
                              ),
                            ],
                          );
                          final confidenceTag = Text(
                            '${alert.confidence}% confidence',
                            style: const TextStyle(color: blue, fontSize: 11, fontWeight: FontWeight.bold),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleRow,
                                const SizedBox(height: 4),
                                confidenceTag,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              titleRow,
                              const Spacer(),
                              confidenceTag,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Probable cause: ${alert.probableCause}',
                        style: const TextStyle(fontSize: 12, color: dark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Likely impact: ${alert.likelyImpact}',
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Owner suggestion: ${alert.ownerSuggestion}',
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Actions strip
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 340;
                    final btnOpen = OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening detailed record for: ${alert.title}')),
                        );
                      },
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Open Record', style: TextStyle(fontSize: 12)),
                    );
                    final btnResolve = ElevatedButton(
                      onPressed: isReadOnly
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Alert "${alert.title}" acknowledged & action logged.'),
                                  backgroundColor: roleAccentColor,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: roleAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(role == UserRole.expert ? 'Take Action' : 'Resolve', style: const TextStyle(fontSize: 12)),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          btnOpen,
                          const SizedBox(height: 8),
                          btnResolve,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: btnOpen),
                        const SizedBox(width: 8),
                        Expanded(child: btnResolve),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const List<_AlertEntry> _allAlerts = [
    _AlertEntry(
      title: 'Main Pressure Pump #2 irregular flow rate',
      details: 'Pump output drops below 3.0 bar. Localised temperature rising.',
      time: '3m ago',
      severity: 'Critical',
      source: 'Irrigation',
      icon: Icons.water_drop_outlined,
      confidence: 94,
      probableCause: 'High friction in pump housing impeller due to sand debris.',
      likelyImpact: 'Complete line pressure loss within 2 hours if left unresolved.',
      ownerSuggestion: 'Technician Moyo (Irrigation crew)',
    ),
    _AlertEntry(
      title: 'Vegetation index dip in Zone 2',
      details: 'Satellite moisture stress signature drops by 0.12 in northern quadrant.',
      time: '12m ago',
      severity: 'Warning',
      source: 'Satellite',
      icon: Icons.satellite_alt_outlined,
      confidence: 88,
      probableCause: 'Blocked solenoid valve cluster preventing auto watering cycles.',
      likelyImpact: 'Severe root stress in Tomato plot if moisture dip continues.',
      ownerSuggestion: 'Agronomist Chingama',
    ),
    _AlertEntry(
      title: 'Satellite NDVI Vegetative Health Anomaly',
      details: 'Sentinel-2 multispectral pass indicates localized leaf biomass drop in Maize block.',
      time: '1h ago',
      severity: 'Critical',
      source: 'Satellite',
      icon: Icons.satellite_alt_outlined,
      confidence: 85,
      probableCause: 'Localized moisture stress spreading from western sector boundary.',
      likelyImpact: 'Potential 10% yield reduction if irrigation cycle is delayed.',
      ownerSuggestion: 'Field Scout Ndlovu',
    ),
    _AlertEntry(
      title: 'Sub-surface moisture sensor offline',
      details: 'Solenoid valve sensor #14 loses connectivity over LoRa gateway.',
      time: '2h ago',
      severity: 'Info',
      source: 'System',
      icon: Icons.wifi_off_outlined,
      confidence: 96,
      probableCause: 'Low battery level on terminal sensor node (remaining 3%).',
      likelyImpact: 'Loss of micro-moisture data in Zone 4 (irrelevant to auto schedule).',
      ownerSuggestion: 'Admin (System Maintainer)',
    ),
  ];

  static const List<_AlertEntry> _adminAlerts = [
    _AlertEntry(
      title: 'High API Rate Spike Flagged on Public Gateway',
      details: 'Traffic surge of 18.4k req/sec detected from external IP range. Automated DDoS mitigation activated.',
      time: '4m ago',
      severity: 'Critical',
      source: 'API Gateway',
      icon: Icons.security_outlined,
      confidence: 98,
      probableCause: 'Potential unauthorized scraping bot hitting marketplace produce listings.',
      likelyImpact: 'Sub-second latency increase for mobile clients if burst continues.',
      ownerSuggestion: 'Super Admin / DevOps Security Desk',
    ),
    _AlertEntry(
      title: 'Escrow Dispute Initiated for Order #ORD-1004',
      details: 'Buyer and supplier requested mediator resolution. Escrow amount US\$ 144.00 locked in vault.',
      time: '15m ago',
      severity: 'Critical',
      source: 'Escrow Vault',
      icon: Icons.gavel_outlined,
      confidence: 95,
      probableCause: 'Consignee flagged weight discrepancy upon weighbridge arrival.',
      likelyImpact: 'Funds held in smart escrow until sovereign admin dispute review.',
      ownerSuggestion: 'Admin Escrow Arbitration Officer',
    ),
    _AlertEntry(
      title: 'Sentinel-2 Satellite Telemetry Ingestion Latency (320ms)',
      details: 'Copernicus Hub data ingestion pipeline experiencing elevated queuing latency.',
      time: '42m ago',
      severity: 'Warning',
      source: 'Satellite Telemetry',
      icon: Icons.satellite_alt_outlined,
      confidence: 92,
      probableCause: 'Upstream cloud processing queue during European pass window.',
      likelyImpact: 'NDVI vegetative health maps refreshed with 4-minute delay.',
      ownerSuggestion: 'Sentinel Geospatial Pipeline Maintainer',
    ),
    _AlertEntry(
      title: 'Exporter AMA License Pending Sovereign Renewal',
      details: 'Mutare Fresh Holdings AMA Export License (AMA-ZIM-2024-0031) expires in 7 days.',
      time: '1h ago',
      severity: 'Warning',
      source: 'Security & KYC',
      icon: Icons.badge_outlined,
      confidence: 96,
      probableCause: 'Annual Agricultural Marketing Authority renewal cycle due.',
      likelyImpact: 'Cross-border consignment dispatch blocked after expiry date.',
      ownerSuggestion: 'KYC & Exporter Certification Desk',
    ),
    _AlertEntry(
      title: 'Daily Automated Escrow Settlement Reconciliation Complete',
      details: '100% automated ledger reconciliation matched across all EcoCash, OneMoney & RTGS transactions.',
      time: '2h ago',
      severity: 'Info',
      source: 'System Health',
      icon: Icons.account_balance_outlined,
      confidence: 100,
      probableCause: 'Scheduled midnight treasury batch execution.',
      likelyImpact: 'All stakeholder balances verified and audited on immutable log.',
      ownerSuggestion: 'Verdi Treasury Ledger Engine',
    ),
    _AlertEntry(
      title: 'New Exporter KYC Registration Approved',
      details: 'Eastern Highlands Growers verified with valid SAZ and AMA export credentials.',
      time: '3h ago',
      severity: 'Info',
      source: 'Security & KYC',
      icon: Icons.verified_user_outlined,
      confidence: 99,
      probableCause: 'Admin verification and document authenticity clearance.',
      likelyImpact: 'Exporter unlocked for EUDR-compliant Forbes corridor dispatches.',
      ownerSuggestion: 'National Exporter Registry Desk',
    ),
  ];

  static const List<_AlertEntry> _transporterAlerts = [
    _AlertEntry(
      title: 'A5 Highway Mud & Flash Flood Hazard',
      details: 'Heavy rainfall near Chivhu has caused localized flooding and severe washaway on Highway A5 bridge approach.',
      time: '5m ago',
      severity: 'Critical',
      source: 'Route Hazards',
      icon: Icons.flood_outlined,
      confidence: 96,
      probableCause: '120mm flash cloudburst overflowing river drainage basin.',
      likelyImpact: 'Potential 2-3 hour transit delay; high hydroplaning and jackknife risk for heavy 12T rigs.',
      ownerSuggestion: 'Corridor Dispatcher / Traffic Police Advisory',
    ),
    _AlertEntry(
      title: 'Refrigerated Cargo Temp Spike (8.9°C)',
      details: 'Thermostat sensor on Truck TRK-9442 reefer container flags temperature rising above target 4.0°C.',
      time: '18m ago',
      severity: 'Critical',
      source: 'Cold Chain',
      icon: Icons.ac_unit_outlined,
      confidence: 92,
      probableCause: 'Auxiliary diesel compressor belt slippage in cooling bay.',
      likelyImpact: 'Spoilage risk for 4,000 kg export-grade berries if temp remains elevated > 45 mins.',
      ownerSuggestion: 'Lead Driver T. Moyo / Reefer Service Bay',
    ),
    _AlertEntry(
      title: 'Norton Weighbridge Backlog (45m Delay)',
      details: 'Automated axle scale queue backed up by 1.8 km due to high transit volume.',
      time: '34m ago',
      severity: 'Warning',
      source: 'Weighbridge & Tolls',
      icon: Icons.scale_outlined,
      confidence: 89,
      probableCause: 'Single lane operation during system calibration.',
      likelyImpact: 'ETA for Harare-Bulawayo haul pushed back from 14:00 to 14:47 CAT.',
      ownerSuggestion: 'ZINARA Highway Toll Control',
    ),
    _AlertEntry(
      title: 'Rear Right Dual Tire Pressure Low (74 PSI)',
      details: 'Telematics TPMS sensor flags 16 PSI drop below recommended 90 PSI operating threshold.',
      time: '1h ago',
      severity: 'Warning',
      source: 'Telematics',
      icon: Icons.tire_repair_outlined,
      confidence: 94,
      probableCause: 'Slow puncture or valve stem leak on rear axle #2.',
      likelyImpact: 'Increased fuel burn by 6% and risk of highway tread blowout at cruise speeds.',
      ownerSuggestion: 'Driver Checkpoint at Next Service Oasis',
    ),
    _AlertEntry(
      title: 'Fuel Advance Escrow Released (US\$ 380.00)',
      details: 'Smart contract escrow for Harare-Bulawayo Freight #FR-902 released to driver wallet upon loading verification.',
      time: '2h ago',
      severity: 'Info',
      source: 'Escrow Payout',
      icon: Icons.account_balance_wallet_outlined,
      confidence: 99,
      probableCause: 'Consignor QR handover confirmed at Harare Mbare Depot.',
      likelyImpact: 'Driver fuel card & toll pass automatically topped up for the trip.',
      ownerSuggestion: 'Verdi Escrow Settlement Engine',
    ),
    _AlertEntry(
      title: 'e-Phyto Agricultural Cross-Border Transit Seal',
      details: 'Electronic phytosanitary clearance certificate verified and linked to consignment manifest.',
      time: '3h ago',
      severity: 'Info',
      source: 'Weighbridge & Tolls',
      icon: Icons.verified_outlined,
      confidence: 98,
      probableCause: 'Ministry of Agriculture digital inspection approval.',
      likelyImpact: 'Green-lane express bypass enabled at national inspection stations.',
      ownerSuggestion: 'National Plant Quarantine Inspector',
    ),
  ];

  static const List<_AlertEntry> _expertAlerts = [
    _AlertEntry(
      title: 'Suspected Fall Armyworm (Spodoptera frugiperda) Outbreak',
      details: 'Rapid larval infestation reported across 14 smallholder maize plots in Mazowe Valley North quadrant.',
      time: '6m ago',
      severity: 'Critical',
      source: 'Disease Outbreaks',
      icon: Icons.bug_report_outlined,
      confidence: 96,
      probableCause: 'Extended humid micro-climate accelerating Spodoptera egg hatching cycles.',
      likelyImpact: 'Up to 40% foliar canopy destruction within 72h if bio-pesticide spray schedule is delayed.',
      ownerSuggestion: 'Issue Emergency Regional Spray Advisory & Deploy Scout Team',
    ),
    _AlertEntry(
      title: 'Emergency Tele-Agronomy Call Request — Severe Tomato Blight',
      details: 'Commercial grower T. Shumba (Goromonzi Greenhouses) requested urgent diagnostic video consultation.',
      time: '18m ago',
      severity: 'Critical',
      source: 'Farmer Consultations',
      icon: Icons.videocam_outlined,
      confidence: 92,
      probableCause: 'Early symptoms of Alternaria solani (Early Blight) from uncalibrated drip humidity.',
      likelyImpact: 'Rapid airborne spore dispersion to adjacent 2,500 tomato vines if fungicide spray delayed.',
      ownerSuggestion: 'Accept Tele-Consultation Call & Issue Digital Rx Pad',
    ),
    _AlertEntry(
      title: 'Severe Soil Acidification & Bacterial Wilt Culture Confirmed',
      details: 'Harare Agronomy Lab returned positive Ralstonia solanacearum culture from Marondera Block C.',
      time: '45m ago',
      severity: 'Critical',
      source: 'Soil & Lab Tests',
      icon: Icons.biotech_outlined,
      confidence: 95,
      probableCause: 'Contaminated irrigation runoff and soil pH dropped below 5.1.',
      likelyImpact: 'Vascular wilt mortality in Solanaceae crops; strict biological quarantine protocol required.',
      ownerSuggestion: 'Issue Immediate Dolomitic Lime & Field Quarantine Protocol',
    ),
    _AlertEntry(
      title: 'Soil Fertility & Phosphorus Lockout Diagnostic (Marondera North)',
      details: 'Composite soil test results indicate critical Phosphorus (P) lockout and low organic carbon (0.8%).',
      time: '1h ago',
      severity: 'Warning',
      source: 'Soil & Lab Tests',
      icon: Icons.science_outlined,
      confidence: 91,
      probableCause: 'Continuous single-crop maize cultivation without calcium/magnesium lime buffering.',
      likelyImpact: 'Stunted root development and delayed flowering for upcoming season crop.',
      ownerSuggestion: 'Generate Custom NPK 7:14:7 + Agricultural Lime Prescription',
    ),
    _AlertEntry(
      title: 'On-Site GPS Farm Fertility & Drip Audit Scheduled (Sunrise Citrus)',
      details: 'Enterprise client Sunrise Citrus Estate confirmed on-site GPS soil & drip irrigation fertility audit.',
      time: '2h ago',
      severity: 'Warning',
      source: 'Farmer Consultations',
      icon: Icons.pin_drop_outlined,
      confidence: 89,
      probableCause: 'Scheduled pre-blossom seasonal nutritional and fertigation assessment.',
      likelyImpact: '3.5h on-site field survey and spectral drone vegetation mapping required.',
      ownerSuggestion: 'Prepare Soil Core Sampler & EC/pH Field Diagnostic Kit',
    ),
    _AlertEntry(
      title: 'Digital Prescription #RX-8820 Awaiting Agronomist Sign-Off',
      details: 'Recommendation for Copper Oxychloride + Mancozeb treatment in Shamva Valley awaits expert signature.',
      time: '3h ago',
      severity: 'Warning',
      source: 'Field Rx Prescriptions',
      icon: Icons.receipt_long_outlined,
      confidence: 94,
      probableCause: 'Standard preventative spray cycle for downy mildew in high-density cucurbits.',
      likelyImpact: 'Farmer cannot redeem subsidized inputs at partner agro-dealers until digitally signed.',
      ownerSuggestion: 'Review Dosage Calculations & Digitally Sign Rx',
    ),
    _AlertEntry(
      title: 'Consultation Escrow Fee Released (US\$ 45.00)',
      details: 'Smart contract consultation escrow released to expert wallet for completed 45-minute video diagnostic.',
      time: '4h ago',
      severity: 'Info',
      source: 'Advisory Payouts',
      icon: Icons.account_balance_wallet_outlined,
      confidence: 99,
      probableCause: 'Farmer accepted advisory diagnosis and rated consultation 5/5 stars.',
      likelyImpact: 'Funds credited to Nostro wallet balance; automated tax receipt issued.',
      ownerSuggestion: 'Verdi Escrow Payout Engine',
    ),
    _AlertEntry(
      title: 'Agronomy Clinical Guide Approved by Agritex Review Board',
      details: 'Your paper "Integrated Pest Management for Tuta Absoluta" has been published to national farmer feed.',
      time: '6h ago',
      severity: 'Info',
      source: 'Farmer Consultations',
      icon: Icons.menu_book_outlined,
      confidence: 100,
      probableCause: 'Agritex national peer-review panel verification complete.',
      likelyImpact: 'Accessible to over 14,200 registered commercial and smallholder farmers.',
      ownerSuggestion: 'National Extension Directorate',
    ),
    _AlertEntry(
      title: 'State Accreditation Credential (AGX-ZW-9942) Synchronized',
      details: 'National Ministry of Lands, Agriculture, Fisheries, Water & Rural Development credentials verified.',
      time: '1d ago',
      severity: 'Info',
      source: 'Soil & Lab Tests',
      icon: Icons.verified_outlined,
      confidence: 100,
      probableCause: 'Annual professional licensing and sovereign register validation.',
      likelyImpact: 'Full sovereign consultation signing authority enabled across all 10 provinces.',
      ownerSuggestion: 'Ministry Accreditation Desk',
    ),
  ];
}

class _AlertEntry {
  final String title;
  final String details;
  final String time;
  final String severity;
  final String source;
  final IconData icon;
  final int confidence;
  final String probableCause;
  final String likelyImpact;
  final String ownerSuggestion;

  const _AlertEntry({
    required this.title,
    required this.details,
    required this.time,
    required this.severity,
    required this.source,
    required this.icon,
    required this.confidence,
    required this.probableCause,
    required this.likelyImpact,
    required this.ownerSuggestion,
  });
}
