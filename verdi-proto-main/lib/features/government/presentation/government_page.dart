import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NATIONAL AGRICULTURAL ADMINISTRATION CONSOLE
// Interactive 7-Tab Public Sector Portal matching exact government wireframes:
//  1. Food Security (GMB Grain Stocks, Strategic Reserves, Dam Telemetry, Grain Entry)
//  2. Farmer Registry (Register New Farmer Form + National Farmer Ledger)
//  3. Farm Registration (Register Farm Parcel GIS Form + Registered Parcels Ledger)
//  4. Extension Officers (KPI Stat Cards + Register Extension Officer Form + Roster)
//  5. Subsidies & Advisory (Issue E-Voucher Form + Broadcast Advisory Form + Ledgers)
//  6. Biosecurity (Report Outbreak Form + Quarantine Enforcement Alerts)
//  7. Trade & Prices (Commodity Price Table + Update Price + ePhyto Customs Portal)
// ─────────────────────────────────────────────────────────────────────────────

class GovernmentPage extends ConsumerStatefulWidget {
  final int initialTab;
  const GovernmentPage({super.key, this.initialTab = 0});

  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF15803D);
  static const dark = Color(0xFF0F172A);
  static const slate = Color(0xFF334155);
  static const muted = Color(0xFF475569);
  static const teal = Color(0xFF0D9488);
  static const purple = Color(0xFF7C3AED);
  static const red = Color(0xFFEF4444);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<GovernmentPage> createState() => _GovernmentPageState();
}

class _GovernmentPageState extends ConsumerState<GovernmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;

  // ── 1. FARMER REGISTRY STATE & FORM CONTROLLERS ───────────────────────────
  final _farmerNameCtrl = TextEditingController();
  final _farmerNatIdCtrl = TextEditingController();
  final _farmerDistrictCtrl = TextEditingController();
  final _farmerWardCtrl = TextEditingController();
  final _farmerCropsCtrl = TextEditingController();
  String _farmerProvince = 'Manicaland';
  String _farmerWallet = 'EcoCash';

  String _farmerSearchQuery = '';
  String _farmerProvinceFilter = 'All Provinces';

  final List<Map<String, dynamic>> _farmers = [
    {
      'id': 'ZIM-FID-9821',
      'name': 'Tendai Chigodora',
      'nationalId': '63-221984 B16',
      'province': 'Manicaland',
      'district': 'Mutare District',
      'ward': 'Ward 12',
      'crops': 'Maize, Horticulture',
      'landHa': 4.5,
      'wallet': 'EcoCash (\$240.50)',
      'status': 'Verified',
    },
    {
      'id': 'ZIM-FID-5512',
      'name': 'Nomsa Ndlovu',
      'nationalId': '63-401822 B24',
      'province': 'Matabeleland South',
      'district': 'Plumtree West',
      'ward': 'Ward 3',
      'crops': 'Sorghum, Groundnuts',
      'landHa': 2.2,
      'wallet': 'OneMoney (\$150.00)',
      'status': 'Verified',
    },
    {
      'id': 'ZIM-FID-3091',
      'name': 'Farai Mupamhanga',
      'nationalId': '63-519017 B41',
      'province': 'Mashonaland Central',
      'district': 'Mazowe Valley',
      'ward': 'Ward 7',
      'crops': 'Blueberries, Coffee',
      'landHa': 12.0,
      'wallet': 'CBZ Agro Card',
      'status': 'Pending Verification',
    },
    {
      'id': 'ZIM-FID-7712',
      'name': 'Rutendo Chiremba',
      'nationalId': '63-779022 B55',
      'province': 'Manicaland',
      'district': 'Nyanga North',
      'ward': 'Ward 2',
      'crops': 'Stone Fruit, Tea',
      'landHa': 8.1,
      'wallet': 'Steward Bank',
      'status': 'Verified',
    },
  ];

  // ── 2. FARM PARCEL STATE & FORM CONTROLLERS ────────────────────────────────
  final _parcelNatIdCtrl = TextEditingController();
  final _parcelGpsCtrl = TextEditingController();
  final _parcelSoilCtrl = TextEditingController();
  final _parcelWaterCtrl = TextEditingController();
  String _parcelLandUse = 'Mixed Horticulture';

  final List<Map<String, dynamic>> _farms = [
    {
      'parcelId': 'PARCEL-MAN-0012',
      'farmerName': 'Tendai Chigodora',
      'farmerId': 'ZIM-FID-9821',
      'boundary': 'GIS Polygon: -18.9712, 32.6711 (4.5 Ha)',
      'soilType': 'Sandy Loam',
      'elevation': '820m ASL',
      'waterSource': 'Borehole + River Divert',
      'landUse': 'Mixed Horticulture',
      'province': 'Manicaland',
      'ndvi': '0.74 (Healthy)',
      'registeredBy': 'Ext. Officer E. Moyo on 12 Mar 2025',
    },
    {
      'parcelId': 'PARCEL-MAT-0034',
      'farmerName': 'Nomsa Ndlovu',
      'farmerId': 'ZIM-FID-5512',
      'boundary': 'GIS Polygon: -20.5233, 27.8901 (2.2 Ha)',
      'soilType': 'Red Clay',
      'elevation': '990m ASL',
      'waterSource': 'Seasonal Rain + Borehole',
      'landUse': 'Dryland Grain',
      'province': 'Matabeleland South',
      'ndvi': '0.61 (Moderate)',
      'registeredBy': 'Ext. Officer S. Sibanda on 05 Jan 2025',
    },
  ];

  // ── 3. EXTENSION OFFICERS STATE & FORM CONTROLLERS ─────────────────────────
  final _officerNameCtrl = TextEditingController();
  final _officerPhoneCtrl = TextEditingController();
  final _officerDistrictCtrl = TextEditingController();
  final _officerWardsCtrl = TextEditingController();
  String _officerProvince = 'Manicaland';
  String _officerSpec = 'Horticulture & Export Crops';

  final List<Map<String, dynamic>> _officers = [
    {
      'id': 'EXT-0021',
      'name': 'Evelyn Moyo',
      'province': 'Manicaland',
      'district': 'Mutare',
      'wards': 'Ward 12, 13, 14',
      'farmersSupported': 142,
      'phone': '+263 77 201 3344',
      'status': 'Active',
      'verified': true,
      'specialization': 'Horticulture & Export Crops',
    },
    {
      'id': 'EXT-0022',
      'name': 'Solomon Sibanda',
      'province': 'Matabeleland South',
      'district': 'Plumtree',
      'wards': 'Ward 3, 4, 5',
      'farmersSupported': 87,
      'phone': '+263 71 490 8823',
      'status': 'Active',
      'verified': true,
      'specialization': 'Dryland Grain & Livestock',
    },
    {
      'id': 'EXT-0023',
      'name': 'Tatenda Mushonga',
      'province': 'Mashonaland Central',
      'district': 'Mazowe',
      'wards': 'Ward 7, 8',
      'farmersSupported': 210,
      'phone': '+263 78 112 5599',
      'status': 'Active',
      'verified': true,
      'specialization': 'Irrigation & Soil Health',
    },
    {
      'id': 'EXT-0024',
      'name': 'Alice Dube',
      'province': 'Midlands',
      'district': 'Gweru',
      'wards': 'Ward 2',
      'farmersSupported': 56,
      'phone': '+263 77 340 1122',
      'status': 'On Leave',
      'verified': true,
      'specialization': 'Livestock & Veterinary Liaison',
    },
  ];

  // ── 4. BIOSECURITY STATE & FORM CONTROLLERS ────────────────────────────────
  final _outbreakPestCtrl = TextEditingController();
  final _outbreakLocCtrl = TextEditingController();
  final _outbreakOfficerCtrl = TextEditingController();
  String _outbreakType = 'Crop';
  String _outbreakSeverity = 'High';

  final List<Map<String, dynamic>> _outbreaks = [
    {
      'id': 'OUT-102',
      'pest': 'Fall Armyworm Infestation',
      'type': 'Crop',
      'location': 'Domboshava Fields',
      'severity': 'Critical',
      'date': 'Today, 08:30',
      'status': 'Quarantine Ordered',
      'affectedHa': 340,
      'officer': 'Evelyn Moyo',
    },
    {
      'id': 'OUT-103',
      'pest': 'Foot and Mouth Disease Alert',
      'type': 'Livestock',
      'location': 'Gwanda Southern Corridors',
      'severity': 'High',
      'date': 'Yesterday, 14:15',
      'status': 'Vaccination Dispatched',
      'affectedHa': 0,
      'officer': 'Alice Dube',
    },
    {
      'id': 'OUT-104',
      'pest': 'Tobacco Mosaic Virus',
      'type': 'Crop',
      'location': 'Rusape East',
      'severity': 'Moderate',
      'date': '2 days ago',
      'status': 'Monitoring Active',
      'affectedHa': 85,
      'officer': 'Tatenda Mushonga',
    },
  ];

  // ── 5. TRADE & PRICES STATE & FORM CONTROLLERS ─────────────────────────────
  final List<Map<String, dynamic>> _prices = [
    {'commodity': 'Maize (white)', 'province': 'Harare', 'wholesale': '\$210/t', 'retail': '\$0.25/kg', 'change': '+3.2%', 'up': true},
    {'commodity': 'Tomatoes', 'province': 'Mutare', 'wholesale': '\$320/t', 'retail': '\$0.38/kg', 'change': '-1.5%', 'up': false},
    {'commodity': 'Sugar Beans', 'province': 'Bulawayo', 'wholesale': '\$580/t', 'retail': '\$0.65/kg', 'change': '+5.8%', 'up': true},
    {'commodity': 'Sorghum', 'province': 'Gwanda', 'wholesale': '\$180/t', 'retail': '\$0.22/kg', 'change': '+0.4%', 'up': true},
    {'commodity': 'Blueberries', 'province': 'Nyanga', 'wholesale': '\$4200/t', 'retail': '\$5.20/kg', 'change': '+12.1%', 'up': true},
    {'commodity': 'Avocados', 'province': 'Mutare', 'wholesale': '\$850/t', 'retail': '\$1.10/kg', 'change': '-2.0%', 'up': false},
  ];

  final List<Map<String, dynamic>> _consignments = [
    {
      'id': 'EXP-PEAS-9921',
      'crop': 'Sugar Snap Peas',
      'exporter': 'Eastern Highlands Growers',
      'weightKg': 8400,
      'destination': 'Rotterdam, Netherlands (EU)',
      'border': 'Forbes Border Post',
      'amaStatus': 'Valid',
      'phytoStatus': 'Pending Clearance',
      'hash': '0x7e8b91a0c4f2e9198d02ab41fa9c',
    },
    {
      'id': 'EXP-BLUE-3310',
      'crop': 'Fresh Blueberries',
      'exporter': 'Mazowe Berry Estates',
      'weightKg': 4200,
      'destination': 'London Heathrow, UK',
      'border': 'Beitbridge Border Post',
      'amaStatus': 'Valid',
      'phytoStatus': 'Cleared & Sealed',
      'hash': '0x3a91c89012beef71940bcad18299',
    },
  ];

  // ── 6. FOOD SECURITY RESERVES ───────────────────────────────────────────────
  final int _maizeReserveTons = 420000;
  final int _wheatReserveTons = 180000;
  final int _sorghumReserveTons = 82000;

  // ── 7. SUBSIDIES STATE ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _vouchers = [
    {'id': 'VCH-882', 'farmer': 'Tendai Chigodora', 'inputs': 'Maize Seed (25kg), Compound D Fertilizer (50kg)', 'value': '\$42.00', 'status': 'Distributed'},
    {'id': 'VCH-883', 'farmer': 'Nomsa Ndlovu', 'inputs': 'Sorghum Seed (10kg), Ammonium Nitrate (50kg)', 'value': '\$28.50', 'status': 'Redeemed'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 6),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _farmerNameCtrl.dispose();
    _farmerNatIdCtrl.dispose();
    _farmerDistrictCtrl.dispose();
    _farmerWardCtrl.dispose();
    _farmerCropsCtrl.dispose();
    _parcelNatIdCtrl.dispose();
    _parcelGpsCtrl.dispose();
    _parcelSoilCtrl.dispose();
    _parcelWaterCtrl.dispose();
    _officerNameCtrl.dispose();
    _officerPhoneCtrl.dispose();
    _officerDistrictCtrl.dispose();
    _officerWardsCtrl.dispose();
    _outbreakPestCtrl.dispose();
    _outbreakLocCtrl.dispose();
    _outbreakOfficerCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090D16) : GovernmentPage.background;
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : GovernmentPage.dark;
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 1,
        title: Text(
          'National Agricultural Administration Console',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Console',
            onPressed: _refresh,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: GovernmentPage.green))
                : Icon(Icons.refresh_rounded, color: textColor),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: surfaceColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: GovernmentPage.green,
              indicatorWeight: 3,
              labelColor: GovernmentPage.green,
              unselectedLabelColor: labelColor,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(icon: Icon(Icons.grid_view_rounded, size: 16), text: 'Food Security'),
                Tab(icon: Icon(Icons.person_pin_outlined, size: 16), text: 'Farmer Registry'),
                Tab(icon: Icon(Icons.map_outlined, size: 16), text: 'Farm Registration'),
                Tab(icon: Icon(Icons.support_agent_outlined, size: 16), text: 'Extension Officers'),
                Tab(icon: Icon(Icons.subtitles_outlined, size: 16), text: 'Subsidies & Advisory'),
                Tab(icon: Icon(Icons.bug_report_outlined, size: 16), text: 'Biosecurity'),
                Tab(icon: Icon(Icons.price_change_outlined, size: 16), text: 'Trade & Prices'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodSecurityTab(isDark, surfaceColor, textColor),
          _buildFarmerRegistryTab(isDark, surfaceColor, textColor),
          _buildFarmRegistrationTab(isDark, surfaceColor, textColor),
          _buildExtensionOfficersTab(isDark, surfaceColor, textColor),
          _buildSubsidiesTab(isDark, surfaceColor, textColor),
          _buildBiosecurityTab(isDark, surfaceColor, textColor),
          _buildTradeTab(isDark, surfaceColor, textColor),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: FOOD SECURITY & STRATEGIC GRAIN RESERVES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFoodSecurityTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('🛡️ Strategic National Food Security & Grain Reserves', textColor),
        const SizedBox(height: 12),

        // Grain Stocks Grid
        LayoutBuilder(builder: (context, c) {
          final isNarrow = c.maxWidth < 650;
          return Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _buildGrainKpi(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Strategic Maize (GMB)',
                tons: _maizeReserveTons,
                target: 500000,
                color: GovernmentPage.green,
                surfaceColor: surfaceColor,
                textColor: textColor,
                isDark: isDark,
              ),
              _buildGrainKpi(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Strategic Wheat Reserve',
                tons: _wheatReserveTons,
                target: 200000,
                color: GovernmentPage.orange,
                surfaceColor: surfaceColor,
                textColor: textColor,
                isDark: isDark,
              ),
              _buildGrainKpi(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Sorghum & Small Grains',
                tons: _sorghumReserveTons,
                target: 100000,
                color: GovernmentPage.purple,
                surfaceColor: surfaceColor,
                textColor: textColor,
                isDark: isDark,
              ),
            ],
          );
        }),

        const SizedBox(height: 20),
        _buildSectionHeader('🌊 National Dam Reservoirs & Water Telemetry', textColor),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildDamRow('Lake Kariba Basin', 64.2, '41.2B m³', '1,200 m³/s', 'Optimal', textColor, isDark),
              const Divider(height: 1),
              _buildDamRow('Mazowe Dam Complex', 89.5, '38.4M m³', '420 m³/s', 'Surplus High', textColor, isDark),
              const Divider(height: 1),
              _buildDamRow('Lake Mutirikwi (Masvingo)', 72.8, '1.38B m³', '650 m³/s', 'Stable', textColor, isDark),
              const Divider(height: 1),
              _buildDamRow('Osborne Dam (Manicaland)', 81.0, '401M m³', '280 m³/s', 'Stable', textColor, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrainKpi({
    required double width,
    required String title,
    required int tons,
    required int target,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required bool isDark,
  }) {
    final pct = (tons / target).clamp(0.0, 1.0);
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: GovernmentPage.muted)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${(tons / 1000).toStringAsFixed(0)}k', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: textColor)),
              const SizedBox(width: 4),
              Text('/ ${(target / 1000).toStringAsFixed(0)}k metric tons', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: pct, backgroundColor: Colors.grey.shade200, color: color, minHeight: 6, borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }

  Widget _buildDamRow(String name, double pct, String volume, String discharge, String status, Color textColor, bool isDark) {
    return ListTile(
      leading: const Icon(Icons.water_drop_rounded, color: GovernmentPage.blue),
      title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor)),
      subtitle: Text('Volume: $volume · Discharge: $discharge · Status: $status', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
        child: Text('$pct% Full', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: GovernmentPage.green)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: FARMER REGISTRY (MATCHING EXACT USER SCREENSHOT 1)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFarmerRegistryTab(bool isDark, Color surfaceColor, Color textColor) {
    final filtered = _farmers.where((f) {
      final matchesSearch = (f['name'] as String).toLowerCase().contains(_farmerSearchQuery.toLowerCase()) ||
          (f['nationalId'] as String).toLowerCase().contains(_farmerSearchQuery.toLowerCase()) ||
          (f['id'] as String).toLowerCase().contains(_farmerSearchQuery.toLowerCase());
      final matchesProv = _farmerProvinceFilter == 'All Provinces' || f['province'] == _farmerProvinceFilter;
      return matchesSearch && matchesProv;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('📱 National Farmer Registry', textColor),
        const SizedBox(height: 12),

        // CARD 1: REGISTER NEW FARMER FORM CARD (MATCHING SCREENSHOT 1)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register New Farmer — Unique Digital National ID',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
              ),
              const SizedBox(height: 16),

              // Inputs Row 1: Full Name & National ID Number
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _farmerNameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _farmerNatIdCtrl,
                      decoration: const InputDecoration(labelText: 'National ID Number', border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Inputs Row 2: Province, District / Region, Ward Number
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _farmerProvince,
                      decoration: const InputDecoration(labelText: 'Province', border: UnderlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Manicaland', child: Text('Manicaland')),
                        DropdownMenuItem(value: 'Matabeleland South', child: Text('Matabeleland South')),
                        DropdownMenuItem(value: 'Mashonaland Central', child: Text('Mashonaland Central')),
                        DropdownMenuItem(value: 'Midlands', child: Text('Midlands')),
                        DropdownMenuItem(value: 'Harare', child: Text('Harare')),
                      ],
                      onChanged: (v) => setState(() => _farmerProvince = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _farmerDistrictCtrl,
                      decoration: const InputDecoration(labelText: 'District / Region', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _farmerWardCtrl,
                      decoration: const InputDecoration(labelText: 'Ward Number', border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Inputs Row 3: Primary Crops & Mobile Wallet
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _farmerCropsCtrl,
                      decoration: const InputDecoration(labelText: 'Primary Crops', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _farmerWallet,
                      decoration: const InputDecoration(labelText: 'Mobile Wallet', border: UnderlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'EcoCash', child: Text('EcoCash')),
                        DropdownMenuItem(value: 'OneMoney', child: Text('OneMoney')),
                        DropdownMenuItem(value: 'ZB Mobile', child: Text('ZB Mobile')),
                        DropdownMenuItem(value: 'CBZ Agro Card', child: Text('CBZ Agro Card')),
                        DropdownMenuItem(value: 'Steward Bank', child: Text('Steward Bank')),
                      ],
                      onChanged: (v) => setState(() => _farmerWallet = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovernmentPage.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  if (_farmerNameCtrl.text.isNotEmpty) {
                    setState(() {
                      _farmers.insert(0, {
                        'id': 'ZIM-FID-${1000 + _farmers.length}',
                        'name': _farmerNameCtrl.text.trim(),
                        'nationalId': _farmerNatIdCtrl.text.trim().isEmpty ? '63-999821 B00' : _farmerNatIdCtrl.text.trim(),
                        'province': _farmerProvince,
                        'district': _farmerDistrictCtrl.text.trim().isEmpty ? 'Mutare District' : _farmerDistrictCtrl.text.trim(),
                        'ward': _farmerWardCtrl.text.trim().isEmpty ? 'Ward 12' : 'Ward ${_farmerWardCtrl.text.trim()}',
                        'crops': _farmerCropsCtrl.text.trim().isEmpty ? 'Maize, Horticulture' : _farmerCropsCtrl.text.trim(),
                        'landHa': 4.5,
                        'wallet': '$_farmerWallet (\$0.00)',
                        'status': 'Verified',
                      });
                      _farmerNameCtrl.clear();
                      _farmerNatIdCtrl.clear();
                      _farmerDistrictCtrl.clear();
                      _farmerWardCtrl.clear();
                      _farmerCropsCtrl.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('National Farmer ID Generated & Registered!'), backgroundColor: GovernmentPage.green),
                    );
                  }
                },
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Generate National Farmer ID & Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CARD 2: NATIONAL FARMER LEDGER (MATCHING SCREENSHOT 1)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'National Farmer Ledger (${filtered.length} Records)',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
              ),
              const SizedBox(height: 14),

              // Search Bar & Province Filter Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _farmerSearchQuery = val),
                      style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'Search farmer by name, ID, or NatID...',
                        hintStyle: GoogleFonts.inter(color: GovernmentPage.muted, fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF090D16) : GovernmentPage.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _farmerProvinceFilter,
                    items: const [
                      DropdownMenuItem(value: 'All Provinces', child: Text('All Provinces')),
                      DropdownMenuItem(value: 'Manicaland', child: Text('Manicaland')),
                      DropdownMenuItem(value: 'Matabeleland South', child: Text('Matabeleland South')),
                      DropdownMenuItem(value: 'Mashonaland Central', child: Text('Mashonaland Central')),
                    ],
                    onChanged: (v) => setState(() => _farmerProvinceFilter = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Farmer Ledger Items
              for (int i = 0; i < filtered.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: GovernmentPage.green.withValues(alpha: 0.15),
                        child: const Icon(Icons.person_rounded, color: GovernmentPage.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(filtered[i]['name'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: textColor)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text(filtered[i]['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.green)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${filtered[i]['id']} · NatID: ${filtered[i]['nationalId']}\n'
                              '${filtered[i]['province']}, ${filtered[i]['district']}, ${filtered[i]['ward']} · Land: ${filtered[i]['landHa']} ha\n'
                              'Crops: ${filtered[i]['crops']} · Wallet: ${filtered[i]['wallet']}',
                              style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.badge_outlined, color: GovernmentPage.blue),
                        tooltip: 'View Sovereign ID Card',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: FARM PARCEL REGISTRATION (MATCHING EXACT USER SCREENSHOT 2)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFarmRegistrationTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('🗺️ Farm Parcel Registration — GIS Boundary & Soil Ledger', textColor),
        const SizedBox(height: 12),

        // CARD 1: REGISTER NEW FARM PARCEL FORM CARD (MATCHING SCREENSHOT 2)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register New Farm Parcel (GIS Boundary)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 16),

              // Inputs Row 1: Farmer National ID & GPS Boundary
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _parcelNatIdCtrl,
                      decoration: const InputDecoration(labelText: 'Farmer National ID', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _parcelGpsCtrl,
                      decoration: const InputDecoration(labelText: 'GPS Boundary / Coordinates', border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Inputs Row 2: Soil Type, Water Source, Land Use Classification
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _parcelSoilCtrl,
                      decoration: const InputDecoration(labelText: 'Soil Type', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _parcelWaterCtrl,
                      decoration: const InputDecoration(labelText: 'Water Source', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _parcelLandUse,
                      decoration: const InputDecoration(labelText: 'Land Use Classification', border: UnderlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Mixed Horticulture', child: Text('Mixed Horticulture')),
                        DropdownMenuItem(value: 'Dryland Grain', child: Text('Dryland Grain')),
                        DropdownMenuItem(value: 'Export Horticulture', child: Text('Export Horticulture')),
                        DropdownMenuItem(value: 'Livestock Rangeland', child: Text('Livestock Rangeland')),
                      ],
                      onChanged: (v) => setState(() => _parcelLandUse = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Button (Teal filled button)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovernmentPage.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  setState(() {
                    _farms.insert(0, {
                      'parcelId': 'PARCEL-MAN-00${80 + _farms.length}',
                      'farmerName': 'Tendai Chigodora',
                      'farmerId': _parcelNatIdCtrl.text.trim().isEmpty ? 'ZIM-FID-9821' : _parcelNatIdCtrl.text.trim(),
                      'boundary': _parcelGpsCtrl.text.trim().isEmpty ? 'GIS Polygon: -18.9712, 32.6711 (4.5 Ha)' : _parcelGpsCtrl.text.trim(),
                      'soilType': _parcelSoilCtrl.text.trim().isEmpty ? 'Sandy Loam' : _parcelSoilCtrl.text.trim(),
                      'elevation': '820m ASL',
                      'waterSource': _parcelWaterCtrl.text.trim().isEmpty ? 'Borehole + River Divert' : _parcelWaterCtrl.text.trim(),
                      'landUse': _parcelLandUse,
                      'province': 'Manicaland',
                      'ndvi': '0.74 (Healthy)',
                      'registeredBy': 'Ext. Officer E. Moyo on 12 Mar 2025',
                    });
                    _parcelNatIdCtrl.clear();
                    _parcelGpsCtrl.clear();
                    _parcelSoilCtrl.clear();
                    _parcelWaterCtrl.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Farm Parcel Registered & NDVI Scan Queued!'), backgroundColor: GovernmentPage.teal),
                  );
                },
                icon: const Icon(Icons.travel_explore_rounded, size: 18),
                label: const Text('Register Farm Parcel & Queue NDVI Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CARD 2: REGISTERED FARM PARCELS LEDGER (MATCHING SCREENSHOT 2)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registered Farm Parcels Ledger (${_farms.length} Parcels)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 14),

              for (int i = 0; i < _farms.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_farms[i]['parcelId'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: textColor)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(_farms[i]['ndvi'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: GovernmentPage.green)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.satellite_alt_rounded, color: GovernmentPage.teal, size: 18),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Farmer: ${_farms[i]['farmerName']} (${_farms[i]['farmerId']})\n'
                        '${_farms[i]['boundary']}\n'
                        'Soil: ${_farms[i]['soilType']} · Elevation: ${_farms[i]['elevation']} · Water: ${_farms[i]['waterSource']}\n'
                        'Land Use: ${_farms[i]['landUse']} · Province: ${_farms[i]['province']}\n'
                        'Registered by: ${_farms[i]['registeredBy']}',
                        style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4: EXTENSION OFFICERS (MATCHING EXACT USER SCREENSHOT 3)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildExtensionOfficersTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('🎧 Extension Officers Management', textColor),
        const SizedBox(height: 12),

        // TOP 4 STAT KPI CARDS (MATCHING SCREENSHOT 3)
        LayoutBuilder(builder: (context, c) {
          final isNarrow = c.maxWidth < 650;
          final cardW = isNarrow ? (c.maxWidth - 12) / 2 : (c.maxWidth - 36) / 4;
          return Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _buildOfficerKpiCard('Total Officers', '${_officers.length}', Icons.badge_outlined, GovernmentPage.purple, surfaceColor, textColor, isDark, cardW),
              _buildOfficerKpiCard('Farmers Supported', '495', Icons.people_outline, GovernmentPage.green, surfaceColor, textColor, isDark, cardW),
              _buildOfficerKpiCard('Training Sessions', '28', Icons.school_outlined, GovernmentPage.blue, surfaceColor, textColor, isDark, cardW),
              _buildOfficerKpiCard('Active Officers', '${_officers.where((o) => o['status'] == 'Active').length}', Icons.check_circle_outline, GovernmentPage.teal, surfaceColor, textColor, isDark, cardW),
            ],
          );
        }),

        const SizedBox(height: 20),

        // CARD 1: REGISTER NEW EXTENSION OFFICER FORM CARD (MATCHING SCREENSHOT 3)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register New Extension Officer', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 16),

              // Row 1: Full Name & Phone Number
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _officerNameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _officerPhoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Province, District Assignment, Wards
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _officerProvince,
                      decoration: const InputDecoration(labelText: 'Province', border: UnderlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Manicaland', child: Text('Manicaland')),
                        DropdownMenuItem(value: 'Matabeleland South', child: Text('Matabeleland South')),
                        DropdownMenuItem(value: 'Mashonaland Central', child: Text('Mashonaland Central')),
                        DropdownMenuItem(value: 'Midlands', child: Text('Midlands')),
                      ],
                      onChanged: (v) => setState(() => _officerProvince = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _officerDistrictCtrl,
                      decoration: const InputDecoration(labelText: 'District Assignment', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _officerWardsCtrl,
                      decoration: const InputDecoration(labelText: 'Wards (comma separated)', border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 3: Specialization
              DropdownButtonFormField<String>(
                value: _officerSpec,
                decoration: const InputDecoration(labelText: 'Specialization', border: UnderlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Horticulture & Export Crops', child: Text('Horticulture & Export Crops')),
                  DropdownMenuItem(value: 'Dryland Grain & Livestock', child: Text('Dryland Grain & Livestock')),
                  DropdownMenuItem(value: 'Irrigation & Soil Health', child: Text('Irrigation & Soil Health')),
                  DropdownMenuItem(value: 'Livestock & Veterinary Liaison', child: Text('Livestock & Veterinary Liaison')),
                ],
                onChanged: (v) => setState(() => _officerSpec = v!),
              ),
              const SizedBox(height: 20),

              // Action Button (Purple button)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovernmentPage.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  if (_officerNameCtrl.text.isNotEmpty) {
                    setState(() {
                      _officers.insert(0, {
                        'id': 'EXT-00${25 + _officers.length}',
                        'name': _officerNameCtrl.text.trim(),
                        'province': _officerProvince,
                        'district': _officerDistrictCtrl.text.trim().isEmpty ? 'Mutare' : _officerDistrictCtrl.text.trim(),
                        'wards': _officerWardsCtrl.text.trim().isEmpty ? 'Ward 12, 13' : _officerWardsCtrl.text.trim(),
                        'farmersSupported': 100,
                        'phone': _officerPhoneCtrl.text.trim().isEmpty ? '+263 77 201 3344' : _officerPhoneCtrl.text.trim(),
                        'status': 'Active',
                        'verified': true,
                        'specialization': _officerSpec,
                      });
                      _officerNameCtrl.clear();
                      _officerPhoneCtrl.clear();
                      _officerDistrictCtrl.clear();
                      _officerWardsCtrl.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Extension Officer Registered & Deployed!'), backgroundColor: GovernmentPage.purple),
                    );
                  }
                },
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Register Extension Officer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CARD 2: EXTENSION OFFICER FIELD ROSTER (MATCHING SCREENSHOT 3)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Extension Officer Field Roster (${_officers.length} Officers)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 14),

              for (int i = 0; i < _officers.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: GovernmentPage.purple.withValues(alpha: 0.15),
                        child: Text((_officers[i]['name'] as String).substring(0, 1), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: GovernmentPage.purple)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_officers[i]['name'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: textColor)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text(_officers[i]['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.green)),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: GovernmentPage.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text('Verified by State', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.orange)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${_officers[i]['id']} · ${_officers[i]['phone']} · Specialization: ${_officers[i]['specialization']}\n'
                              'District: ${_officers[i]['district']} (${_officers[i]['wards']}) · Farmers: ${_officers[i]['farmersSupported']}',
                              style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.phone_outlined, color: GovernmentPage.green)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfficerKpiCard(String label, String value, IconData icon, Color color, Color surfaceColor, Color textColor, bool isDark, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: GovernmentPage.muted)),
              Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 5: SUBSIDIES & ADVISORY
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSubsidiesTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('💳 State Input Subsidies & E-Voucher Issuance', textColor),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issue State Input Subsidies (E-Voucher)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 14),

              for (final vch in _vouchers)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.confirmation_number_outlined, color: GovernmentPage.orange),
                  title: Text('${vch['id']} · ${vch['farmer']} (${vch['value']})', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor)),
                  subtitle: Text('Inputs: ${vch['inputs']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: GovernmentPage.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(vch['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.orange)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 6: BIOSECURITY (MATCHING EXACT USER SCREENSHOT 4)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBiosecurityTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('☣️ Pest, Disease & Biosecurity Control', textColor),
        const SizedBox(height: 12),

        // CARD 1: REPORT NEW PEST / DISEASE OUTBREAK FORM CARD (MATCHING SCREENSHOT 4)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report New Pest / Disease Outbreak (Geo-tagged)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 16),

              // Row 1: Disease or Pest Name & Geo-tagged Location
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _outbreakPestCtrl,
                      decoration: const InputDecoration(labelText: 'Disease or Pest Name', border: UnderlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _outbreakLocCtrl,
                      decoration: const InputDecoration(labelText: 'Geo-tagged Location', border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Type, Severity Level, Responding Officer
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _outbreakType,
                      decoration: const InputDecoration(labelText: 'Type', border: UnderlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Crop', child: Text('Crop')),
                        DropdownMenuItem(value: 'Livestock', child: Text('Livestock')),
                        DropdownMenuItem(value: 'Forestry', child: Text('Forestry')),
                      ],
                      onChanged: (v) => setState(() => _outbreakType = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _outbreakSeverity,
                      decoration: const InputDecoration(labelText: 'Severity Level', border: UnderlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                        DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                      ],
                      onChanged: (v) => setState(() => _outbreakSeverity = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _outbreakOfficerCtrl,
                      decoration: const InputDecoration(labelText: 'Responding Officer', border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Button (Red button)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GovernmentPage.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  if (_outbreakPestCtrl.text.isNotEmpty) {
                    setState(() {
                      _outbreaks.insert(0, {
                        'id': 'OUT-${105 + _outbreaks.length}',
                        'pest': _outbreakPestCtrl.text.trim(),
                        'type': _outbreakType,
                        'location': _outbreakLocCtrl.text.trim().isEmpty ? 'Domboshava Fields' : _outbreakLocCtrl.text.trim(),
                        'severity': _outbreakSeverity,
                        'date': 'Today, 08:30',
                        'status': 'Quarantine Ordered',
                        'affectedHa': 340,
                        'officer': _outbreakOfficerCtrl.text.trim().isEmpty ? 'Evelyn Moyo' : _outbreakOfficerCtrl.text.trim(),
                      });
                      _outbreakPestCtrl.clear();
                      _outbreakLocCtrl.clear();
                      _outbreakOfficerCtrl.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quarantine Alert Raised & Dispatched!'), backgroundColor: GovernmentPage.red),
                    );
                  }
                },
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: const Text('Raise Quarantine Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // BIOSECURITY OUTBREAK ALERT CARDS (MATCHING SCREENSHOT 4)
        for (final out in _outbreaks)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: out['severity'] == 'Critical' || out['severity'] == 'High' ? const Color(0xFFFEF2F2) : surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: out['severity'] == 'Critical' ? const Color(0xFFFCA5A5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(out['pest'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: textColor)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: GovernmentPage.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text(out['type'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.blue)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: GovernmentPage.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text(out['severity'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Location: ${out['location']} · Date: ${out['date']} · Status: ${out['status']}\n'
                  'Affected Area: ${out['affectedHa']} Ha · Officer: ${out['officer']}',
                  style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600, height: 1.4),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GovernmentPage.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Enforcing Quarantine for ${out['pest']}!'), backgroundColor: GovernmentPage.red),
                    );
                  },
                  icon: const Icon(Icons.emergency_outlined, size: 14),
                  label: const Text('Enforce Quarantine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 7: TRADE & PRICES (MATCHING EXACT USER SCREENSHOT 5)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTradeTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('📈 Trade Corridors, Price Monitoring & ePhyto Customs', textColor),
        const SizedBox(height: 12),

        // CARD 1: NATIONAL COMMODITY PRICE MONITOR TABLE CARD (MATCHING SCREENSHOT 5)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('National Commodity Price Monitor (Real-Time)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GovernmentPage.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => _showUpdatePriceModal(context),
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Update Commodity Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // PRICE TABLE HEADER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Commodity', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: textColor))),
                    Expanded(flex: 2, child: Text('Province', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: textColor))),
                    Expanded(flex: 2, child: Text('Wholesale', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: textColor))),
                    Expanded(flex: 2, child: Text('Retail', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: textColor))),
                    Expanded(flex: 2, child: Text('Change', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: textColor))),
                  ],
                ),
              ),

              // PRICE TABLE ROWS
              for (int i = 0; i < _prices.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(_prices[i]['commodity'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: textColor))),
                      Expanded(flex: 2, child: Text(_prices[i]['province'] as String, style: GoogleFonts.inter(fontSize: 12, color: GovernmentPage.muted, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(_prices[i]['wholesale'] as String, style: GoogleFonts.inter(fontSize: 12, color: GovernmentPage.muted, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(_prices[i]['retail'] as String, style: GoogleFonts.inter(fontSize: 12, color: GovernmentPage.muted, fontWeight: FontWeight.w600))),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon((_prices[i]['up'] as bool) ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 15, color: (_prices[i]['up'] as bool) ? GovernmentPage.green : GovernmentPage.red),
                            const SizedBox(width: 4),
                            Text(_prices[i]['change'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: (_prices[i]['up'] as bool) ? GovernmentPage.green : GovernmentPage.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _prices.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CARD 2: ePHYTO DIGITAL CERTIFICATION & BORDER CLEARANCE PORTAL (MATCHING SCREENSHOT 5)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ePhyto Digital Certification & Border Clearance Portal (Beitbridge | Forbes)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 6),
              Text('Verify AMA exporter licenses, SAZ compliance dossiers, and clear shipments for the South Corridor (Beitbridge → Durban) and East Corridor (Forbes → Beira).', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              for (final csn in _consignments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: GovernmentPage.blue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${csn['id']} · ${csn['crop']} (${csn['weightKg']} kg)', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor)),
                            Text('Exporter: ${csn['exporter']} · Border: ${csn['border']} · Destination: ${csn['destination']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
                        onPressed: () {
                          setState(() => csn['phytoStatus'] = 'Cleared & Sealed');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ePhyto ${csn['id']} Cleared!'), backgroundColor: GovernmentPage.green));
                        },
                        child: Text(csn['phytoStatus'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── UPDATE COMMODITY PRICE MODAL ──────────────────────────────────────────
  void _showUpdatePriceModal(BuildContext context) {
    final commCtrl = TextEditingController();
    final provCtrl = TextEditingController(text: 'Harare');
    final wsCtrl = TextEditingController();
    final rtCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Commodity Price Monitor', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: commCtrl, decoration: const InputDecoration(labelText: 'Commodity Name')),
            TextField(controller: provCtrl, decoration: const InputDecoration(labelText: 'Province')),
            TextField(controller: wsCtrl, decoration: const InputDecoration(labelText: 'Wholesale Price (e.g. \$250/t)')),
            TextField(controller: rtCtrl, decoration: const InputDecoration(labelText: 'Retail Price (e.g. \$0.30/kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.teal, foregroundColor: Colors.white),
            onPressed: () {
              if (commCtrl.text.isNotEmpty) {
                setState(() {
                  _prices.insert(0, {
                    'commodity': commCtrl.text.trim(),
                    'province': provCtrl.text.trim(),
                    'wholesale': wsCtrl.text.trim().isEmpty ? '\$250/t' : wsCtrl.text.trim(),
                    'retail': rtCtrl.text.trim().isEmpty ? '\$0.30/kg' : rtCtrl.text.trim(),
                    'change': '+2.0%',
                    'up': true,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commodity Price Updated!'), backgroundColor: GovernmentPage.teal));
              }
            },
            child: const Text('Save Price'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: textColor));
  }
}