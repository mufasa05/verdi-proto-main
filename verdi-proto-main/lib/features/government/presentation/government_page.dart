import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UNIFIED NATIONAL AGRI-COMMAND CONSOLE (SOVEREIGN GOVERNMENT ROLE)
// 3 Consolidated High-Value Tabs:
//  1. National Food Security & Water Reserves (GMB, Dams, Outbreak Quarantine)
//  2. Farmer Registry & E-Voucher Subsidies (Parcels + Satellite NDVI + Officer + Subsidies)
//  3. Trade, Customs & ePhyto Clearances (Consignments, Digital ePhyto, Price Index)
// ─────────────────────────────────────────────────────────────────────────────

class GovernmentPage extends ConsumerStatefulWidget {
  final int initialTab;
  const GovernmentPage({super.key, this.initialTab = 0});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF2563EB);
  static const teal = Color(0xFF0D9488);
  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<GovernmentPage> createState() => _GovernmentPageState();
}

class _GovernmentPageState extends ConsumerState<GovernmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;

  String _farmerSearchQuery = '';
  final String _farmerProvinceFilter = 'All Provinces';
  final Set<String> _expandedFarmers = <String>{};

  // ── 1. STRATEGIC FOOD & WATER RESERVES STATE ───────────────────────────────
  final int _maizeReserveTons = 420000;
  final int _wheatReserveTons = 185000;
  final int _sorghumReserveTons = 82000;

  final List<Map<String, dynamic>> _damTelemetry = [
    {'name': 'Lake Kariba Basin', 'capacityPct': 64.2, 'volumeM3': '41.2B m³', 'discharge': '1,200 m³/s', 'status': 'Optimal'},
    {'name': 'Mazowe Dam Complex', 'capacityPct': 89.5, 'volumeM3': '38.4M m³', 'discharge': '420 m³/s', 'status': 'Surplus High'},
    {'name': 'Lake Mutirikwi (Masvingo)', 'capacityPct': 72.8, 'volumeM3': '1.38B m³', 'discharge': '650 m³/s', 'status': 'Stable'},
    {'name': 'Osborne Dam (Manicaland)', 'capacityPct': 81.0, 'volumeM3': '401M m³', 'discharge': '280 m³/s', 'status': 'Stable'},
  ];

  final List<Map<String, dynamic>> _outbreaks = [
    {
      'id': 'OUT-102',
      'pest': 'Fall Armyworm Infestation',
      'type': 'Crop Alert',
      'location': 'Domboshava & Mazowe Corridors',
      'severity': 'Critical',
      'date': 'Today, 08:30',
      'status': 'Active Quarantine',
      'affectedHa': 340,
      'officer': 'Evelyn Moyo (Ext-0021)',
    },
    {
      'id': 'OUT-103',
      'pest': 'Foot and Mouth Disease Vector',
      'type': 'Livestock Alert',
      'location': 'Gwanda Southern Rangelands',
      'severity': 'High',
      'date': 'Yesterday, 14:15',
      'status': 'Ring Vaccination Dispatched',
      'affectedHa': 0,
      'officer': 'Alice Dube (Ext-0024)',
    },
  ];

  // ── 2. UNIFIED FARMER REGISTRY (WITH PARCELS, NDVI & SUBSIDIES) ────────────
  final List<Map<String, dynamic>> _farmers = [
    {
      'id': 'ZIM-FID-9821',
      'name': 'Tendai Chigodora',
      'nationalId': '63-221984 B16',
      'phone': '+263 77 219 0041',
      'province': 'Manicaland',
      'ward': 'Mutare District · Ward 12',
      'status': 'Verified Smallholder',
      'parcelId': 'PARCEL-MAN-0012',
      'boundary': '-18.9712, 32.6711 (4.5 Ha)',
      'soilType': 'Sandy Loam',
      'ndviScore': '0.76 (Optimal)',
      'officerName': 'Evelyn Moyo',
      'officerPhone': '+263 77 201 3344',
      'officerLastVisit': 'Today',
      'voucherId': 'VCH-8821',
      'voucherPackage': 'Maize Seed (25kg) + Compound D (50kg)',
      'voucherValue': '\$42.00',
      'voucherStatus': 'Approved & Distributed',
    },
    {
      'id': 'ZIM-FID-5512',
      'name': 'Nomsa Ndlovu',
      'nationalId': '63-401822 B24',
      'phone': '+263 71 882 1093',
      'province': 'Matabeleland South',
      'ward': 'Plumtree West · Ward 3',
      'status': 'Verified Smallholder',
      'parcelId': 'PARCEL-MAT-0034',
      'boundary': '-20.5233, 27.8901 (2.2 Ha)',
      'soilType': 'Red Clay Loam',
      'ndviScore': '0.62 (Moderate)',
      'officerName': 'Solomon Sibanda',
      'officerPhone': '+263 71 490 8823',
      'officerLastVisit': 'Yesterday',
      'voucherId': 'VCH-5512',
      'voucherPackage': 'Sorghum Seed (10kg) + Ammonium Nitrate (50kg)',
      'voucherValue': '\$28.50',
      'voucherStatus': 'Pending Ministry Disbursement',
    },
    {
      'id': 'ZIM-FID-3091',
      'name': 'Farai Mupamhanga',
      'nationalId': '63-519017 B41',
      'phone': '+263 78 440 9182',
      'province': 'Mashonaland Central',
      'ward': 'Mazowe Valley · Ward 7',
      'status': 'Commercial Outgrower',
      'parcelId': 'PARCEL-MAC-0077',
      'boundary': '-17.5010, 30.8802 (12.0 Ha)',
      'soilType': 'Dark Fertile Loam',
      'ndviScore': '0.84 (Exceptional)',
      'officerName': 'Tatenda Mushonga',
      'officerPhone': '+263 78 112 5599',
      'officerLastVisit': '3 days ago',
      'voucherId': 'VCH-3091',
      'voucherPackage': 'Solar Drip Irrigation Subsidized Kit',
      'voucherValue': '\$120.00',
      'voucherStatus': 'Approved & Distributed',
    },
    {
      'id': 'ZIM-FID-7712',
      'name': 'Rutendo Chiremba',
      'nationalId': '63-779022 B55',
      'phone': '+263 77 912 3004',
      'province': 'Manicaland',
      'ward': 'Nyanga North · Ward 2',
      'status': 'Verified Smallholder',
      'parcelId': 'PARCEL-NYA-0081',
      'boundary': '-18.2104, 32.7420 (8.1 Ha)',
      'soilType': 'Volcanic Humus',
      'ndviScore': '0.79 (Optimal)',
      'officerName': 'Evelyn Moyo',
      'officerPhone': '+263 77 201 3344',
      'officerLastVisit': 'Last week',
      'voucherId': 'VCH-7712',
      'voucherPackage': 'Horticulture Seedling Pack + Lime',
      'voucherValue': '\$35.00',
      'voucherStatus': 'Pending Ministry Disbursement',
    },
  ];

  // ── 3. TRADE, CUSTOMS & ePHYTO CLEARANCES ──────────────────────────────────
  final List<Map<String, dynamic>> _consignments = [
    {
      'id': 'EXP-PEAS-9921',
      'crop': 'Sugar Snap Peas',
      'exporter': 'Eastern Highlands Growers Coop',
      'weightKg': 8400,
      'destination': 'Rotterdam, Netherlands (EU)',
      'border': 'Forbes Border Post',
      'amaLicense': 'Valid (AMA-2026/08)',
      'sazStatus': 'ISO 22000 Certified',
      'phytoStatus': 'Pending Digital Sign-Off',
      'hash': '0x7e8b91a0c4f2e9198d02ab41fa9c',
    },
    {
      'id': 'EXP-BLUE-3310',
      'crop': 'Fresh Blueberries',
      'exporter': 'Mazowe Berry Estates',
      'weightKg': 4200,
      'destination': 'London Heathrow, UK',
      'border': 'Beitbridge Border Post',
      'amaLicense': 'Valid (AMA-2026/14)',
      'sazStatus': 'GlobalGAP Compliant',
      'phytoStatus': 'Cleared & Sealed',
      'hash': '0x3a91c89012beef71940bcad18299',
    },
    {
      'id': 'EXP-AVOC-5514',
      'crop': 'Hass Avocados',
      'exporter': 'Manicaland Fresh Produce Ltd',
      'weightKg': 12500,
      'destination': 'Jebel Ali Port, Dubai (UAE)',
      'border': 'Forbes Border Post',
      'amaLicense': 'Valid (AMA-2026/22)',
      'sazStatus': 'Eurofins Residue Tested',
      'phytoStatus': 'Pending Digital Sign-Off',
      'hash': '0x99182ab3041fa728c001fbe39401',
    },
  ];

  final List<Map<String, dynamic>> _prices = [
    {'commodity': 'White Maize GMB Grade A', 'wholesale': '\$220.00 / t', 'retail': '\$0.26 / kg', 'trend': '+2.4%', 'up': true},
    {'commodity': 'Soybeans (Crushing Quality)', 'wholesale': '\$580.00 / t', 'retail': '\$0.72 / kg', 'trend': '+4.1%', 'up': true},
    {'commodity': 'Red Sorghum Grain', 'wholesale': '\$185.00 / t', 'retail': '\$0.23 / kg', 'trend': '-0.5%', 'up': false},
    {'commodity': 'Sugar Beans (Dry)', 'wholesale': '\$950.00 / t', 'retail': '\$1.15 / kg', 'trend': '+1.8%', 'up': true},
    {'commodity': 'Fresh Blueberries (Export Grade)', 'wholesale': '\$4,500.00 / t', 'retail': '\$5.40 / kg', 'trend': '+8.6%', 'up': true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090D16) : GovernmentPage.background;
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : GovernmentPage.dark;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, size: 18, color: GovernmentPage.green),
                const SizedBox(width: 8),
                Text(
                  'National Agri-Command Console',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Text(
              'Ministry of Lands, Agriculture & Water Governance',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: GovernmentPage.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export Sovereign Dossier',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating National Food Security & Trade Audit PDF...'),
                  backgroundColor: GovernmentPage.green,
                ),
              );
            },
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: 'Refresh Telemetry',
            onPressed: _refresh,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: GovernmentPage.green),
                  )
                : const Icon(Icons.refresh_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: surfaceColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: GovernmentPage.green,
              indicatorWeight: 3,
              labelColor: GovernmentPage.green,
              unselectedLabelColor: GovernmentPage.muted,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.shield_outlined, size: 16),
                  text: 'Food & Water Security',
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.people_alt_outlined, size: 16),
                  text: 'Farmer & Subsidy Registry',
                ),
                Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.verified_outlined, size: 16),
                  text: 'Trade, Customs & ePhyto',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodAndWaterTab(isDark, surfaceColor, textColor),
          _buildFarmerRegistryTab(isDark, surfaceColor, textColor),
          _buildTradeAndCustomsTab(isDark, surfaceColor, textColor),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: NATIONAL FOOD & WATER RESERVES (STRATEGIC COMMAND)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFoodAndWaterTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Emergency Pest / Biosecurity Banner
        if (_outbreaks.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: GovernmentPage.red, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Sovereign Biosecurity Alerts (${_outbreaks.length})',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GovernmentPage.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showEmergencyQuarantineModal(context),
                      icon: const Icon(Icons.emergency_outlined, size: 14),
                      label: const Text('Dispatch Response', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final out in _outbreaks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: GovernmentPage.red, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            '${out['pest']} in ${out['location']} — Status: ${out['status']} (${out['officer']})',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF7F1D1D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 2. Grain Reserves KPI Cockpit
        Text(
          'National Strategic Grain Reserves (GMB Telemetry)',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, c) {
          final isNarrow = c.maxWidth < 650;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildGrainMeter(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Strategic Maize (GMB)',
                currentTons: _maizeReserveTons,
                targetTons: 500000,
                daysSupply: 284,
                color: GovernmentPage.green,
                isDark: isDark,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
              _buildGrainMeter(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Strategic Wheat Reserve',
                currentTons: _wheatReserveTons,
                targetTons: 200000,
                daysSupply: 240,
                color: GovernmentPage.orange,
                isDark: isDark,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
              _buildGrainMeter(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Sorghum & Millets',
                currentTons: _sorghumReserveTons,
                targetTons: 100000,
                daysSupply: 195,
                color: GovernmentPage.purple,
                isDark: isDark,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
            ],
          );
        }),

        const SizedBox(height: 20),

        // 3. National Dam & Irrigation Scheme Telemetry
        Text(
          'National Water Dams & Irrigation Allocation',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.black12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _damTelemetry.length; i++) ...[
                if (i > 0) Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : Colors.black12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GovernmentPage.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: GovernmentPage.blue, size: 20),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _damTelemetry[i]['name'] as String,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: textColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: GovernmentPage.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_damTelemetry[i]['capacityPct']}% Full',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: GovernmentPage.green),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text('Volume: ${_damTelemetry[i]['volumeM3']} · Discharge: ${_damTelemetry[i]['discharge']}',
                            style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
                      ],
                    ),
                  ),
                  trailing: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: GovernmentPage.blue),
                    onPressed: () {
                      _showDamScheduleModal(context, _damTelemetry[i]['name'] as String);
                    },
                    icon: const Icon(Icons.tune_rounded, size: 15),
                    label: const Text('Adjust Flow', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrainMeter({
    required double width,
    required String title,
    required int currentTons,
    required int targetTons,
    required int daysSupply,
    required Color color,
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
  }) {
    final pct = (currentTons / targetTons).clamp(0.0, 1.0);
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warehouse_outlined, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: GovernmentPage.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${(currentTons / 1000).toStringAsFixed(0)}k',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
              ),
              const SizedBox(width: 4),
              Text(
                '/ ${(targetTons / 1000).toStringAsFixed(0)}k metric tons',
                style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Days of Supply: ', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
              Text('$daysSupply days', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: UNIFIED FARMER REGISTRY & E-VOUCHER SUBSIDY DISBURSEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFarmerRegistryTab(bool isDark, Color surfaceColor, Color textColor) {
    final filtered = _farmers.where((f) {
      final nameMatches = (f['name'] as String).toLowerCase().contains(_farmerSearchQuery.toLowerCase()) ||
          (f['nationalId'] as String).toLowerCase().contains(_farmerSearchQuery.toLowerCase()) ||
          (f['id'] as String).toLowerCase().contains(_farmerSearchQuery.toLowerCase());
      final provMatches = _farmerProvinceFilter == 'All Provinces' || f['province'] == _farmerProvinceFilter;
      return nameMatches && provMatches;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search & Filter Header
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _farmerSearchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search by Farmer Name, ID, or National ID...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF1E293B) : Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF1E293B) : Colors.black12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovernmentPage.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showRegisterFarmerModal(context),
              icon: const Icon(Icons.person_add_outlined, size: 16),
              label: const Text('Register Farmer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Farmer Master-Detail Cards
        Text(
          'Registered Smallholders & Subsidy Records (${filtered.length})',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: GovernmentPage.muted),
        ),
        const SizedBox(height: 10),

        for (final farmer in filtered) _buildFarmerMasterCard(farmer, isDark, surfaceColor, textColor),
      ],
    );
  }

  Widget _buildFarmerMasterCard(Map<String, dynamic> farmer, bool isDark, Color surfaceColor, Color textColor) {
    final farmerId = farmer['id'] as String;
    final isExpanded = _expandedFarmers.contains(farmerId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.black12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedFarmers.remove(farmerId);
                } else {
                  _expandedFarmers.add(farmerId);
                }
              });
            },
            leading: CircleAvatar(
              backgroundColor: GovernmentPage.green.withValues(alpha: 0.12),
              child: Text(
                (farmer['name'] as String).substring(0, 1),
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: GovernmentPage.green),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    farmer['name'] as String,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: GovernmentPage.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    farmer['status'] as String,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: GovernmentPage.teal),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${farmer['id']} · ${farmer['nationalId']} · ${farmer['ward']}',
              style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: GovernmentPage.muted,
            ),
          ),

          if (isExpanded) ...[
            Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : Colors.black12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Parcel & Satellite NDVI health
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.satellite_alt_outlined, size: 18, color: GovernmentPage.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Land Parcel & Satellite Vegetation Health',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                            const SizedBox(height: 2),
                            Text('${farmer['parcelId']} · Boundary: ${farmer['boundary']} · Soil: ${farmer['soilType']}',
                                style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
                            const SizedBox(height: 4),
                            Text('Satellite NDVI Score: ${farmer['ndviScore']}',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: GovernmentPage.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Extension Officer Liaison
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.support_agent_outlined, size: 18, color: GovernmentPage.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Assigned Extension Officer',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                            const SizedBox(height: 2),
                            Text('${farmer['officerName']} (${farmer['officerPhone']}) · Last field inspection: ${farmer['officerLastVisit']}',
                                style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. E-Voucher State Subsidy
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.confirmation_number_outlined, size: 18, color: GovernmentPage.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('E-Voucher Subsidy: ${farmer['voucherPackage']}',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
                              Text('Value: ${farmer['voucherValue']} · Status: ${farmer['voucherStatus']}',
                                  style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
                            ],
                          ),
                        ),
                        if (farmer['voucherStatus'] != 'Approved & Distributed')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GovernmentPage.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {
                              setState(() {
                                farmer['voucherStatus'] = 'Approved & Distributed';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('E-Voucher ${farmer['voucherId']} Approved for ${farmer['name']}!'),
                                  backgroundColor: GovernmentPage.green,
                                ),
                              );
                            },
                            child: const Text('Disburse Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: TRADE, CUSTOMS & ePHYTO CLEARANCES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTradeAndCustomsTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Export Consignments & ePhyto Digital Clearances
        Text(
          'Active Border Consignments & ePhyto Clearances',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
        ),
        const SizedBox(height: 10),

        for (final item in _consignments)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: GovernmentPage.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: GovernmentPage.blue, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item['crop']} (${item['weightKg']} kg)',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
                          Text('Exporter: ${item['exporter']} · Border: ${item['border']}',
                              style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['phytoStatus'] == 'Cleared & Sealed'
                            ? GovernmentPage.green.withValues(alpha: 0.1)
                            : GovernmentPage.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['phytoStatus'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item['phytoStatus'] == 'Cleared & Sealed'
                              ? GovernmentPage.green
                              : GovernmentPage.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Destination: ${item['destination']}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                Text('Compliance: ${item['amaLicense']} · ${item['sazStatus']}',
                    style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Audit Seal: ${item['hash']}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, color: GovernmentPage.muted),
                      ),
                    ),
                    if (item['phytoStatus'] != 'Cleared & Sealed')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GovernmentPage.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          _signEphytoCertificate(context, item);
                        },
                        icon: const Icon(Icons.verified_outlined, size: 14),
                        label: const Text('Digitally Sign ePhyto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // 2. National Commodity Price Monitoring Index
        Text(
          'National Commodity Price Index (Wholesale vs Retail)',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.black12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _prices.length; i++) ...[
                if (i > 0) Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : Colors.black12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(_prices[i]['commodity'] as String,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: textColor)),
                  subtitle: Text('Wholesale: ${_prices[i]['wholesale']} · Retail: ${_prices[i]['retail']}',
                      style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_prices[i]['up'] as bool)
                          ? GovernmentPage.green.withValues(alpha: 0.1)
                          : GovernmentPage.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _prices[i]['trend'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (_prices[i]['up'] as bool) ? GovernmentPage.green : GovernmentPage.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── MODAL WORKFLOWS ────────────────────────────────────────────────────────
  void _showEmergencyQuarantineModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dispatch Sovereign Biosecurity Quarantine'),
        content: const Text(
          'This action will dispatch emergency Ring-Fence Quarantine orders to Mashonaland Central and Matabeleland South extension commands. Mobile SMS bulletins will broadcast to 3,400 registered farmers in the zone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency Biosecurity Quarantine Dispatched!'),
                  backgroundColor: GovernmentPage.red,
                ),
              );
            },
            child: const Text('Confirm Dispatch'),
          ),
        ],
      ),
    );
  }

  void _showDamScheduleModal(BuildContext context, String damName) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Adjust Discharge: $damName'),
        content: const Text(
          'Configure daily irrigation allocation quotas. Current downstream scheme pressure is within nominal agricultural tolerance.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.blue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$damName discharge adjusted successfully.'),
                  backgroundColor: GovernmentPage.blue,
                ),
              );
            },
            child: const Text('Apply Allocation'),
          ),
        ],
      ),
    );
  }

  void _showRegisterFarmerModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final natIdCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register Smallholder Farmer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Legal Name')),
            TextField(controller: natIdCtrl, decoration: const InputDecoration(labelText: 'National ID (e.g. 63-123456 A78)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _farmers.insert(0, {
                    'id': 'ZIM-FID-${1000 + _farmers.length}',
                    'name': nameCtrl.text.trim(),
                    'nationalId': natIdCtrl.text.trim().isEmpty ? '63-000000 X00' : natIdCtrl.text.trim(),
                    'phone': '+263 77 000 0000',
                    'province': 'Harare Province',
                    'ward': 'District 1 · Ward 1',
                    'status': 'Verified Smallholder',
                    'parcelId': 'PARCEL-HAR-${1000 + _farmers.length}',
                    'boundary': '-17.8248, 31.0530 (3.0 Ha)',
                    'soilType': 'Clay Loam',
                    'ndviScore': '0.70 (Good)',
                    'officerName': 'Evelyn Moyo',
                    'officerPhone': '+263 77 201 3344',
                    'officerLastVisit': 'Today',
                    'voucherId': 'VCH-${1000 + _farmers.length}',
                    'voucherPackage': 'Maize Seed (25kg) + Fertilizer (50kg)',
                    'voucherValue': '\$42.00',
                    'voucherStatus': 'Approved & Distributed',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Farmer ${nameCtrl.text.trim()} Registered Successfully!'),
                    backgroundColor: GovernmentPage.green,
                  ),
                );
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void _signEphytoCertificate(BuildContext context, Map<String, dynamic> item) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Digitally Sign ePhyto: ${item['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop: ${item['crop']} (${item['weightKg']} kg)'),
            Text('Exporter: ${item['exporter']}'),
            Text('Destination: ${item['destination']}'),
            const SizedBox(height: 10),
            const Text(
              'Digital signature with cryptographic key will seal this consignment for border clearance at Forbes/Beitbridge.',
              style: TextStyle(fontSize: 12, color: GovernmentPage.muted),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                item['phytoStatus'] = 'Cleared & Sealed';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Consignment ${item['id']} Cleared & ePhyto Certificate Issued!'),
                  backgroundColor: GovernmentPage.green,
                ),
              );
            },
            child: const Text('Sign & Issue ePhyto'),
          ),
        ],
      ),
    );
  }
}