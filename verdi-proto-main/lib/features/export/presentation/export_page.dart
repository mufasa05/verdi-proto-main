import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT PAGE — Intelligent Export & Global Trade Layer
// Covers: Corridor Management, ePhyto Certification, Exporter Registry,
//         Cold Chain Telemetry, Border Delay Intelligence, Compliance & HS Codes
// ─────────────────────────────────────────────────────────────────────────────

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const teal = Color(0xFF0F766E);
  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFFF1F5F9);

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> with TickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> get activeExporters => ref.watch(isDemoModeProvider) ? _exporters : [];
  List<Map<String, dynamic>> get activeConsignments => ref.watch(isDemoModeProvider) ? _consignments : [];
  List<Map<String, dynamic>> get activeBorderAlerts => ref.watch(isDemoModeProvider) ? _borderAlerts : [];

  // ── EXPORTERS REGISTRY ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _exporters = [
    {
      'id': 'EXP-001', 'company': 'Eastern Highlands Growers', 'contact': 'Tatenda Chigodora',
      'phone': '+263 77 201 3344', 'amaLicenseNo': 'AMA-ZIM-2024-0012',
      'amaExpiry': '31 Dec 2025', 'sazCert': 'CERT-SAZ-0092', 'status': 'Active',
      'corridors': 'Forbes → Beira', 'crops': 'Sugar Snaps, Baby Corn, Mange Tout',
      'markets': 'EU (Netherlands), UK', 'annualVolKg': 94000,
    },
    {
      'id': 'EXP-002', 'company': 'Mazowe Blueberries Ltd', 'contact': 'Rudo Makoni',
      'phone': '+263 71 490 8823', 'amaLicenseNo': 'AMA-ZIM-2023-0087',
      'amaExpiry': '30 Jun 2025', 'sazCert': 'CERT-SAZ-0104', 'status': 'Active',
      'corridors': 'Beitbridge → Durban', 'crops': 'Blueberries (Blue Ribbon, Bluecrop)',
      'markets': 'UK, Middle East', 'annualVolKg': 42000,
    },
    {
      'id': 'EXP-003', 'company': 'Mutare Fresh Holdings', 'contact': 'Farai Mupamhanga',
      'phone': '+263 78 112 5599', 'amaLicenseNo': 'AMA-ZIM-2024-0031',
      'amaExpiry': '15 Sep 2025', 'sazCert': 'CERT-SAZ-0118', 'status': 'Pending Renewal',
      'corridors': 'Forbes → Beira', 'crops': 'Avocados (Hass), Macadamia',
      'markets': 'UAE, Singapore', 'annualVolKg': 78000,
    },
    {
      'id': 'EXP-004', 'company': 'Zimbabwe Coffee Exporters', 'contact': 'Simba Moyo',
      'phone': '+263 77 999 0011', 'amaLicenseNo': 'AMA-ZIM-2023-0055',
      'amaExpiry': '28 Feb 2026', 'sazCert': 'CERT-SAZ-0077', 'status': 'Active',
      'corridors': 'Beitbridge → Durban → Singapore Air',
      'crops': 'Specialty Coffee (Washed, Natural Process)',
      'markets': 'Japan, Singapore, USA (Specialty)', 'annualVolKg': 22000,
    },
  ];

  // ── CONSIGNMENTS ────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _consignments = [
    {
      'id': 'CON-PEAS-9921', 'exporter': 'Eastern Highlands Growers',
      'crop': 'Sugar Snaps', 'hsCode': '0708.10', 'weightKg': 8400,
      'reefer': 'RFID: RFC-0041', 'tempC': '2°C', 'humidity': '92%',
      'border': 'Forbes Border Post', 'route': 'Mutare → Beira Port → Rotterdam',
      'ePhytoStatus': 'Pending Clearance', 'amaStatus': 'Valid',
      'sazStatus': 'Compliant', 'depDate': '16 Jul 2026', 'etaPort': '20 Jul 2026',
      'etaDest': '01 Aug 2026', 'borderDelayPrediction': '4–6 hrs (Forbes: Normal)',
    },
    {
      'id': 'CON-BLUE-3310', 'exporter': 'Mazowe Blueberries Ltd',
      'crop': 'Blueberries', 'hsCode': '0810.40', 'weightKg': 3600,
      'reefer': 'RFID: RFC-0022', 'tempC': '0°C', 'humidity': '88%',
      'border': 'Beitbridge Border Post', 'route': 'Bulawayo → Durban Port → London',
      'ePhytoStatus': 'Cleared', 'amaStatus': 'Valid',
      'sazStatus': 'Compliant', 'depDate': '14 Jul 2026', 'etaPort': '16 Jul 2026',
      'etaDest': '24 Jul 2026', 'borderDelayPrediction': '2–3 hrs (Beitbridge: Low Queue)',
    },
    {
      'id': 'CON-AVOC-5514', 'exporter': 'Mutare Fresh Holdings',
      'crop': 'Avocados (Hass)', 'hsCode': '0804.40', 'weightKg': 11200,
      'reefer': 'RFID: RFC-0065', 'tempC': '5°C', 'humidity': '85%',
      'border': 'Forbes Border Post', 'route': 'Mutare → Beira Port → Dubai Port',
      'ePhytoStatus': 'On Hold (AMA Pending)', 'amaStatus': 'Pending Renewal',
      'sazStatus': 'Compliant', 'depDate': '18 Jul 2026', 'etaPort': '22 Jul 2026',
      'etaDest': '30 Jul 2026', 'borderDelayPrediction': '12–18 hrs (Forbes: AMA Hold)',
    },
    {
      'id': 'CON-COFF-0012', 'exporter': 'Zimbabwe Coffee Exporters',
      'crop': 'Specialty Coffee (Washed)', 'hsCode': '0901.11', 'weightKg': 5000,
      'reefer': 'Dry Container', 'tempC': 'Ambient', 'humidity': '60%',
      'border': 'Beitbridge Border Post', 'route': 'Harare → Durban → Singapore',
      'ePhytoStatus': 'Cleared', 'amaStatus': 'Valid',
      'sazStatus': 'Compliant', 'depDate': '12 Jul 2026', 'etaPort': '14 Jul 2026',
      'etaDest': '28 Jul 2026', 'borderDelayPrediction': '1–2 hrs (Beitbridge: Peak)',
    },
  ];

  // ── BORDER INTELLIGENCE ─────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _borderAlerts = [
    {
      'border': 'Forbes Border Post', 'status': 'Normal Operations',
      'currentQueue': '14 trucks', 'avgDelay': '4 hrs 20 min', 'color': 'green',
      'intel': 'MoFNP documentary inspection team on-site. 3 high-inspection-frequency categories: organic, processed, stone fruit.',
      'riskLevel': 'Low',
    },
    {
      'border': 'Beitbridge Border Post', 'status': 'Moderate Congestion',
      'currentQueue': '31 trucks', 'avgDelay': '9 hrs 50 min', 'color': 'orange',
      'intel': 'SAPS extra personnel deployed for customs searches. Peak export season for Zimbabwean citrus. Recommend 06:00 departure from origin.',
      'riskLevel': 'Medium',
    },
    {
      'border': 'Plumtree Border Post', 'status': 'Low Traffic',
      'currentQueue': '6 trucks', 'avgDelay': '1 hr 15 min', 'color': 'green',
      'intel': 'Standard operations. Pre-registered manifests via ASYCUDA clearing quickly.',
      'riskLevel': 'Low',
    },
  ];

  // ── HS CODES ────────────────────────────────────────────────────────────────
  final List<Map<String, String>> _hsCodes = [
    {'hs': '0708.10', 'desc': 'Peas (shelled or unshelled)', 'eu': 'MRL: 0.01mg/kg Chlorpyrifos', 'uk': 'Border: Imported Goods Scheme', 'uae': 'Standard'},
    {'hs': '0810.40', 'desc': 'Cranberries, bilberries & blueberries', 'eu': 'MRL: 5mg/kg Spinosad', 'uk': 'Phytosanitary Certificate Required', 'uae': 'Standard'},
    {'hs': '0804.40', 'desc': 'Avocados', 'eu': 'MRL: 0.05mg/kg Thiamethoxam', 'uk': 'Border Inspection Post (BIP) Required', 'uae': 'Halal cert not required'},
    {'hs': '0901.11', 'desc': 'Coffee — not roasted, not decaffeinated', 'eu': 'Ochratoxin A max 3μg/kg', 'uk': 'HMRC Tariff: 0%', 'uae': 'COO Certificate Required'},
    {'hs': '0603.11', 'desc': 'Roses — fresh cut flowers', 'eu': 'Phytosanitary + EU Entry Point', 'uk': 'CITES check if CITES-listed', 'uae': 'Dubai COO Required'},
    {'hs': '1701.14', 'desc': 'Cane sugar', 'eu': 'EPA Protocol ACP Sugar', 'uk': 'Refined Sugar Preference', 'uae': 'Standard'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExportPage.background,
      appBar: AppBar(
        title: Text('Intelligent Export & Global Trade Layer',
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: ExportPage.dark, fontSize: 15)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: ExportPage.teal,
              unselectedLabelColor: ExportPage.muted,
              indicatorColor: ExportPage.teal,
              tabs: const [
                Tab(icon: Icon(Icons.flight_takeoff_outlined, size: 16), text: 'Overview'),
                Tab(icon: Icon(Icons.business_outlined, size: 16), text: 'Exporters'),
                Tab(icon: Icon(Icons.local_shipping_outlined, size: 16), text: 'Consignments'),
                Tab(icon: Icon(Icons.thermostat_outlined, size: 16), text: 'Cold Chain'),
                Tab(icon: Icon(Icons.traffic_outlined, size: 16), text: 'Border Intelligence'),
                Tab(icon: Icon(Icons.gavel_outlined, size: 16), text: 'Compliance & HS Codes'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildExportersTab(),
          _buildConsignmentsTab(),
          _buildColdChainTab(),
          _buildBorderIntelTab(),
          _buildComplianceTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: OVERVIEW DASHBOARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Export Corridors — National Overview', icon: Icons.flight_takeoff_outlined, color: ExportPage.teal),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 800 ? 3 : 2;
          final w = (c.maxWidth - 12 * (cols - 1)) / cols;
          return Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _KpiCard(width: w, label: 'Active Exporters', value: '${_exporters.where((e) => e['status'] == 'Active').length}', icon: Icons.business_outlined, color: ExportPage.teal),
              _KpiCard(width: w, label: 'Live Consignments', value: '${_consignments.length}', icon: Icons.local_shipping_outlined, color: ExportPage.blue),
              _KpiCard(width: w, label: 'Cleared for Dispatch', value: '${_consignments.where((c) => c['ePhytoStatus'] == 'Cleared').length}', icon: Icons.verified_outlined, color: ExportPage.green),
              _KpiCard(width: w, label: 'Forbes Queue Now', value: '14 trucks', icon: Icons.traffic_outlined, color: ExportPage.orange),
              _KpiCard(width: w, label: 'Beitbridge Queue Now', value: '31 trucks', icon: Icons.traffic_outlined, color: ExportPage.red),
              _KpiCard(width: w, label: 'Total Annual Vol.', value: '${(_exporters.fold(0, (s, e) => s + (e['annualVolKg'] as int)) / 1000).toStringAsFixed(0)} t/yr', icon: Icons.scale_outlined, color: ExportPage.purple),
            ],
          );
        }),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Export Corridor Status',
          child: Column(children: [
            _CorridorRow(label: 'Forbes Border Post → Port of Beira → EU/Asia', status: 'Operational', color: ExportPage.green,
                detail: 'ETA Rotterdam: 12 days. Last ePhyto: 16 Jul 2026. Avg delay: 4h 20m.'),
            const Divider(height: 12),
            _CorridorRow(label: 'Beitbridge Border Post → Port of Durban → UK/ME', status: 'Moderate Delay', color: ExportPage.orange,
                detail: 'ETA Durban: 2 days. Congestion elevated. Avg delay: 9h 50m.'),
            const Divider(height: 12),
            _CorridorRow(label: 'Plumtree Border Post → SA Rail Gateway', status: 'Low Traffic', color: ExportPage.green,
                detail: 'Avg delay: 1h 15m. Recommend for bulk grain export.'),
          ]),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Export Volume by Crop (Current Season)',
          child: Column(children: [
            _VolumeBar(label: 'Avocados (Hass)', volume: 78000, maxVol: 100000, color: ExportPage.green),
            const SizedBox(height: 10),
            _VolumeBar(label: 'Sugar Snaps / Mange Tout', volume: 94000, maxVol: 100000, color: ExportPage.teal),
            const SizedBox(height: 10),
            _VolumeBar(label: 'Blueberries', volume: 42000, maxVol: 100000, color: ExportPage.blue),
            const SizedBox(height: 10),
            _VolumeBar(label: 'Specialty Coffee', volume: 22000, maxVol: 100000, color: ExportPage.orange),
          ]),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: EXPORTERS REGISTRY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildExportersTab() {
    final compCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amaCtrl = TextEditingController();
    final cropsCtrl = TextEditingController();
    String corridor = 'Forbes → Beira';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Registered Exporters — AMA Licensed', icon: Icons.business_outlined, color: ExportPage.blue),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Register New Exporter',
          child: StatefulBuilder(builder: (ctx, setS) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;
                final companyField = TextField(controller: compCtrl, decoration: const InputDecoration(labelText: 'Company Name'));
                final contactField = TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Primary Contact'));
                final phoneField = TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'));
                final amaField = TextField(controller: amaCtrl, decoration: const InputDecoration(labelText: 'AMA License No.', hintText: 'AMA-ZIM-XXXX-XXXX'));
                final cropsField = TextField(controller: cropsCtrl, decoration: const InputDecoration(labelText: 'Export Crops'));
                final corridorField = DropdownButtonFormField<String>(
                  value: corridor,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Primary Export Corridor'),
                  items: ['Forbes → Beira', 'Beitbridge → Durban', 'Plumtree → SA Rail', 'Air Freight (HRE)'].map((c) =>
                      DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setS(() => corridor = v ?? corridor),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile) ...[
                      companyField,
                      const SizedBox(height: 12),
                      contactField,
                      const SizedBox(height: 12),
                      phoneField,
                      const SizedBox(height: 12),
                      amaField,
                      const SizedBox(height: 12),
                      cropsField,
                      const SizedBox(height: 12),
                      corridorField,
                    ] else ...[
                      Row(children: [
                        Expanded(child: companyField),
                        const SizedBox(width: 16),
                        Expanded(child: contactField),
                        const SizedBox(width: 16),
                        Expanded(child: phoneField),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: amaField),
                        const SizedBox(width: 16),
                        Expanded(child: cropsField),
                        const SizedBox(width: 16),
                        Expanded(child: corridorField),
                      ]),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (compCtrl.text.isEmpty || amaCtrl.text.isEmpty) return;
                        setState(() {
                          _exporters.add({
                            'id': 'EXP-${(_exporters.length + 1).toString().padLeft(3, '0')}',
                            'company': compCtrl.text.trim(), 'contact': contactCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(), 'amaLicenseNo': amaCtrl.text.trim(),
                            'amaExpiry': 'Pending Verification', 'sazCert': 'Pending',
                            'status': 'Pending Verification', 'corridors': corridor,
                            'crops': cropsCtrl.text.trim(), 'markets': 'TBD', 'annualVolKg': 0,
                          });
                        });
                        compCtrl.clear(); contactCtrl.clear(); phoneCtrl.clear(); amaCtrl.clear(); cropsCtrl.clear();
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Exporter registered. AMA verification queued.')));
                      },
                      icon: const Icon(Icons.add_business_outlined),
                      label: const Text('Register Exporter'),
                      style: ElevatedButton.styleFrom(backgroundColor: ExportPage.blue, foregroundColor: Colors.white),
                    ),
                  ],
                );
              },
            );
          }),
        ),
        const SizedBox(height: 24),
        if (activeExporters.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.business_outlined, size: 40, color: ExportPage.muted),
                  const SizedBox(height: 10),
                  Text('No registered exporters on live directory.', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: ExportPage.dark)),
                  const SizedBox(height: 4),
                  const Text('Registered AMA export license holders will populate here.', style: TextStyle(color: ExportPage.muted, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...activeExporters.map((e) {
            final isActive = e['status'] == 'Active';
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(e['company'], style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 15)),
                  _StatusChip(label: e['status'], color: isActive ? ExportPage.green : ExportPage.orange),
                ]),
                const SizedBox(height: 8),
                _DetailRow('Contact:', '${e['contact']}  •  ${e['phone']}'),
                _DetailRow('AMA License:', '${e['amaLicenseNo']}  (Expires: ${e['amaExpiry']})'),
                _DetailRow('SAZ Certificate:', '${e['sazCert']}'),
                _DetailRow('Corridors:', '${e['corridors']}'),
                _DetailRow('Export Crops:', '${e['crops']}'),
                _DetailRow('Markets:', '${e['markets']}'),
                _DetailRow('Annual Volume:', '${((e['annualVolKg'] as int) / 1000).toStringAsFixed(1)} tonnes / year'),
              ]),
            );
          }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: CONSIGNMENTS & ePHYTO TRACKING
  // ═══════════════════════════════════════════════════════════════
  Widget _buildConsignmentsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Live Consignments & ePhyto Certificate Tracker', icon: Icons.local_shipping_outlined, color: ExportPage.green),
        const SizedBox(height: 16),
        if (activeConsignments.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 40, color: ExportPage.muted),
                  const SizedBox(height: 10),
                  Text('No active export consignments.', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: ExportPage.dark)),
                  const SizedBox(height: 4),
                  const Text('Active cross-border reefer consignments and phytosanitary manifests will stream here.', style: TextStyle(color: ExportPage.muted, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...activeConsignments.map((c) {
          final cleared = c['ePhytoStatus'] == 'Cleared';
          final onHold = c['ePhytoStatus'].toString().contains('Hold') || c['ePhytoStatus'].toString().contains('Pending');
          final statusColor = cleared ? ExportPage.green : onHold ? ExportPage.orange : ExportPage.blue;
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cleared ? ExportPage.green.withOpacity(0.3) : const Color(0xFFE2E8F0))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['id'], style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 15)),
                  Text(c['exporter'], style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
                ]),
                _StatusChip(label: c['ePhytoStatus'], color: statusColor),
              ]),
              const Divider(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('CARGO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ExportPage.muted, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(c['crop'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('HS Code: ${c['hsCode']}  •  ${c['weightKg']} kg', style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
                  Text('Container: ${c['reefer']}', style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
                ])),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ROUTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ExportPage.muted, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(c['route'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Border: ${c['border']}', style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
                ])),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('SCHEDULE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ExportPage.muted, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('Departure: ${c['depDate']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('ETA Port: ${c['etaPort']}', style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
                  Text('ETA Dest: ${c['etaDest']}', style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
                ])),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: ExportPage.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.model_training_outlined, size: 16, color: ExportPage.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text('AI Border Prediction: ${c['borderDelayPrediction']}',
                      style: const TextStyle(fontSize: 12, color: ExportPage.blue, fontWeight: FontWeight.w600))),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                if (!cleared)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => c['ePhytoStatus'] = 'Cleared'),
                    icon: const Icon(Icons.verified_outlined, size: 14),
                    label: const Text('Issue ePhyto Certificate', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: ExportPage.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                if (!cleared) const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
                  label: const Text('Download Dossier PDF', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.track_changes_outlined, size: 14),
                  label: const Text('Track Live', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ]),
            ]),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: COLD CHAIN TELEMETRY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildColdChainTab() {
    final isDemo = ref.watch(isDemoModeProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Cold Chain IoT Telemetry — Reefer Monitoring', icon: Icons.thermostat_outlined, color: ExportPage.blue),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Active Reefer / Cold Chain Sensors',
          child: isDemo
              ? Column(children: [
                  _ReeferCard(rfid: 'RFC-0041', crop: 'Sugar Snaps', tempC: 2.1, humidity: 92, status: 'In Transit', tempTarget: '2°C ±0.5', battPct: 84, lastPing: '2 min ago', breach: false),
                  const Divider(height: 16),
                  _ReeferCard(rfid: 'RFC-0022', crop: 'Blueberries', tempC: 0.3, humidity: 88, status: 'Port Hold', tempTarget: '0°C ±0.5', battPct: 61, lastPing: '5 min ago', breach: false),
                  const Divider(height: 16),
                  _ReeferCard(rfid: 'RFC-0065', crop: 'Avocados (Hass)', tempC: 7.8, humidity: 82, status: '⚠️ Breach Detected', tempTarget: '5°C ±0.5', battPct: 45, lastPing: '14 min ago', breach: true),
                  const Divider(height: 16),
                  _ReeferCard(rfid: 'RFC-0018', crop: 'Mange Tout', tempC: 3.0, humidity: 90, status: 'Packhouse Loading', tempTarget: '2°C ±0.5', battPct: 97, lastPing: '1 min ago', breach: false),
                ])
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.thermostat_outlined, size: 36, color: ExportPage.muted),
                        const SizedBox(height: 8),
                        Text('No active cold chain sensors connected.', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: ExportPage.dark)),
                        const SizedBox(height: 4),
                        const Text('Reefer temperature and humidity streams will populate upon dispatch.', style: TextStyle(color: ExportPage.muted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Cold Chain Breach Incident Log',
          child: isDemo
              ? Column(children: [
                  _BreachItem(
                    rfid: 'RFC-0065', time: 'Today 09:22', tempRecorded: '7.8°C', target: '5.0°C',
                    location: 'Mutare Packhouse → Forbes (En Route)', action: 'Alert Raised. Exporter notified. Quality hold pending.',
                  ),
                  const SizedBox(height: 10),
                  _BreachItem(
                    rfid: 'RFC-0009', time: '14 Jul, 14:40', tempRecorded: '8.2°C', target: '2.0°C',
                    location: 'Forbes Border Post — Customs Hold', action: 'Consignment rejected. Partial write-off. Insurance claim initiated.',
                  ),
                ])
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 36, color: ExportPage.green),
                        const SizedBox(height: 8),
                        Text('Zero thermal breach incidents.', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: ExportPage.dark)),
                        const SizedBox(height: 4),
                        const Text('All cold chain shipments maintaining compliant temperature thresholds.', style: TextStyle(color: ExportPage.muted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: BORDER INTELLIGENCE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBorderIntelTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'AI-Powered Border Delay Prediction Engine', icon: Icons.traffic_outlined, color: ExportPage.orange),
        const SizedBox(height: 8),
        const Text(
          'Predictions powered by XGBoost model trained on ZIMRA clearance logs, seasonal vehicle counts, SAPS inspection schedules, and MoFNP documentary audit events.',
          style: TextStyle(fontSize: 12.5, color: ExportPage.muted),
        ),
        const SizedBox(height: 20),
        ..._borderAlerts.map((b) {
          final c = b['color'] == 'green' ? ExportPage.green : ExportPage.orange;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(b['border'], style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 15)),
                _StatusChip(label: b['status'], color: c),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _BorderStat(label: 'Queue Now', value: b['currentQueue'], icon: Icons.local_shipping_outlined),
                const SizedBox(width: 16),
                _BorderStat(label: 'Avg Delay', value: b['avgDelay'], icon: Icons.access_time_outlined),
                const SizedBox(width: 16),
                _BorderStat(label: 'Risk Level', value: b['riskLevel'], icon: Icons.shield_outlined),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: ExportPage.blue.withOpacity(0.04), borderRadius: BorderRadius.circular(10)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.insights_outlined, size: 16, color: ExportPage.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Intelligence: ${b['intel']}', style: const TextStyle(fontSize: 12, color: ExportPage.dark))),
                ]),
              ),
            ]),
          );
        }),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Departure Timing Recommendations (AI-Optimized)',
          child: Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(2)},
            children: [
              TableRow(decoration: BoxDecoration(color: ExportPage.orange.withOpacity(0.08)),
                  children: ['Origin', 'Border', 'Best Departure', 'Expected Clearance'].map((h) =>
                      Padding(padding: const EdgeInsets.all(10), child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))).toList()),
              ...['Mutare|Forbes (Beira)|04:00–05:00|~08:30 clearance (same day)', 'Harare|Beitbridge (Durban)|18:00–20:00|~06:00 next day clearance',
                'Bulawayo|Plumtree (SA Rail)|Any time|1–2h typical wait'].map((row) {
                final cells = row.split('|');
                return TableRow(children: cells.map((c) =>
                    Padding(padding: const EdgeInsets.all(10), child: Text(c, style: const TextStyle(fontSize: 12)))).toList());
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 6: COMPLIANCE & HS CODES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildComplianceTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Regulatory Compliance — MRL, HS Codes & Market Rules', icon: Icons.gavel_outlined, color: ExportPage.purple),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Document Checklist — Per Consignment',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Every export consignment from Zimbabwe must carry ALL of the following:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...[
              '✅  Phytosanitary Certificate (issued by DLPD/Plant Quarantine)',
              '✅  AMA Export License (Agricultural Marketing Authority)',
              '✅  SAZ Quality Compliance Certificate (Standards Association Zimbabwe)',
              '✅  Certificate of Origin (ZimTrade / Chamber of Mines)',
              '✅  Commercial Invoice + Packing List',
              '✅  Bill of Lading / Airway Bill',
              '✅  ASYCUDA++ Customs Entry (ZIMRA)',
              '✅  CITES Permit (if applicable — aloe, wildlife products)',
              '✅  Organic Certification (if applicable)',
            ].map((d) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(d, style: const TextStyle(fontSize: 13)))),
          ]),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Harmonized System (HS) Code Reference — Key Zimbabwean Exports',
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _hsCodes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final hs = _hsCodes[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: ExportPage.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(hs['hs']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: ExportPage.purple)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(hs['desc']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ]),
                  const SizedBox(height: 6),
                  _DetailRow('EU MRL / Rule:', hs['eu']!),
                  _DetailRow('UK Rule:', hs['uk']!),
                  _DetailRow('UAE Rule:', hs['uae']!),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'MRL Exceedance Alerts (Residue Testing)',
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: ExportPage.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: ExportPage.red.withOpacity(0.2))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.science_outlined, color: ExportPage.red),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MRL Breach: Chlorpyrifos on Sugar Snaps (CON-PEAS-9921)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Lab result: 0.018mg/kg. EU MRL: 0.01mg/kg. Consignment placed on temporary hold pending re-test. Exporter notified.', style: TextStyle(fontSize: 12, color: ExportPage.muted)),
                ])),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: ExportPage.green.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: ExportPage.green.withOpacity(0.2))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.science_outlined, color: ExportPage.green),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MRL Clear: Blueberries (CON-BLUE-3310)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('All pesticide residues below UK MPCB threshold. Batch cleared for UK retail distribution.', style: TextStyle(fontSize: 12, color: ExportPage.muted)),
                ])),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16, color: ExportPage.dark))),
    ]);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: ExportPage.dark)),
        const Divider(height: 20),
        child,
      ]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.width, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: ExportPage.muted)),
          Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: ExportPage.dark)),
        ])),
      ]),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _CorridorRow extends StatelessWidget {
  final String label;
  final String status;
  final String detail;
  final Color color;
  const _CorridorRow({required this.label, required this.status, required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(detail, style: const TextStyle(fontSize: 11, color: ExportPage.muted)),
      ])),
      _StatusChip(label: status, color: color),
    ]);
  }
}

class _VolumeBar extends StatelessWidget {
  final String label;
  final int volume;
  final int maxVol;
  final Color color;
  const _VolumeBar({required this.label, required this.volume, required this.maxVol, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = (volume / maxVol).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Text('${(volume / 1000).toStringAsFixed(0)} t/yr', style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: pct, minHeight: 8, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color),
      )),
    ]);
  }
}

class _ReeferCard extends StatelessWidget {
  final String rfid;
  final String crop;
  final double tempC;
  final int humidity;
  final String status;
  final String tempTarget;
  final int battPct;
  final String lastPing;
  final bool breach;

  const _ReeferCard({
    required this.rfid, required this.crop, required this.tempC, required this.humidity,
    required this.status, required this.tempTarget, required this.battPct, required this.lastPing, required this.breach,
  });

  @override
  Widget build(BuildContext context) {
    final c = breach ? ExportPage.red : ExportPage.green;
    return Row(children: [
      Container(width: 4, height: 60, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(rfid, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 8),
          _StatusChip(label: status, color: c),
          const Spacer(),
          Text('🔋 $battPct%', style: const TextStyle(fontSize: 11, color: ExportPage.muted)),
          const SizedBox(width: 8),
          Text('Ping: $lastPing', style: const TextStyle(fontSize: 11, color: ExportPage.muted)),
        ]),
        const SizedBox(height: 4),
        Text(crop, style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
        Row(children: [
          const Icon(Icons.thermostat_outlined, size: 14, color: ExportPage.blue),
          Text(' $tempC°C (Target: $tempTarget)', style: TextStyle(fontSize: 12, color: breach ? ExportPage.red : ExportPage.dark, fontWeight: breach ? FontWeight.bold : FontWeight.normal)),
          const SizedBox(width: 16),
          const Icon(Icons.water_drop_outlined, size: 14, color: ExportPage.blue),
          Text(' $humidity% RH', style: const TextStyle(fontSize: 12)),
        ]),
      ])),
    ]);
  }
}

class _BreachItem extends StatelessWidget {
  final String rfid;
  final String time;
  final String tempRecorded;
  final String target;
  final String location;
  final String action;

  const _BreachItem({required this.rfid, required this.time, required this.tempRecorded,
      required this.target, required this.location, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: ExportPage.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: ExportPage.red.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$rfid — Temp Breach', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ExportPage.red)),
          Text(time, style: const TextStyle(fontSize: 11, color: ExportPage.muted)),
        ]),
        const SizedBox(height: 6),
        Text('Recorded: $tempRecorded  (Target: $target)', style: const TextStyle(fontSize: 12)),
        Text('Location: $location', style: const TextStyle(fontSize: 12, color: ExportPage.muted)),
        Text('Action: $action', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _BorderStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _BorderStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: ExportPage.background, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 13, color: ExportPage.muted), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10, color: ExportPage.muted))]),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14)),
      ]),
    ));
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12, color: ExportPage.muted, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ]),
    );
  }
}
