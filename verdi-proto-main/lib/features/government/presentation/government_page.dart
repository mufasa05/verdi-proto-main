import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state/app_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SOVEREIGN GOVERNMENT AGRI-COMMAND CONSOLE
// Covers all 7 core public sector capabilities on a single page with tab switching:
//  1. Food Security (GMB Grain Stocks, Strategic Reserves, Dam Telemetry, Grain Entry)
//  2. Farmer Registry (Search, Verification, Farmer Registration)
//  3. Farm Registration (GIS Land Parcels, Soil Types, NDVI Scores, Parcel Entry)
//  4. Extension Officers (District Deployment, Field Visits, Officer Entry)
//  5. Subsidies & Advisory (E-Voucher Issuance, SMS Broadcast Advisories)
//  6. Biosecurity & Outbreaks (Quarantine Alerts, Disease Reports, Outbreak Entry)
//  7. Trade & Prices (Export Consignments, ePhyto Signing, Price Index Entry)
// ─────────────────────────────────────────────────────────────────────────────

class GovernmentPage extends ConsumerStatefulWidget {
  final int initialTab;
  const GovernmentPage({super.key, this.initialTab = 0});

  static const green = Color(0xFF15803D); // High-contrast green
  static const dark = Color(0xFF0F172A); // High-contrast dark
  static const charcoal = Color(0xFF1E293B); // Dark slate for high readability text
  static const bodyText = Color(0xFF334155); // High contrast body text
  static const muted = Color(0xFF64748B); // Muted grey
  static const orange = Color(0xFFC2410C); // Deep high-contrast orange
  static const red = Color(0xFFB91C1C); // Deep high-contrast red
  static const blue = Color(0xFF1D4ED8); // Deep high-contrast blue
  static const teal = Color(0xFF0F766E); // Deep high-contrast teal
  static const purple = Color(0xFF6D28D9); // Deep high-contrast purple
  static const background = Color(0xFFF1F5F9); // Crisp light background

  @override
  ConsumerState<GovernmentPage> createState() => _GovernmentPageState();
}

class _GovernmentPageState extends ConsumerState<GovernmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;

  String _farmerSearchQuery = '';
  final String _farmerProvinceFilter = 'All Provinces';

  // ── 1. FOOD SECURITY STATE ──────────────────────────────────────────────────
  int _maizeReserveTons = 420000;
  int _wheatReserveTons = 185000;
  int _sorghumReserveTons = 82000;

  final List<Map<String, dynamic>> _dams = [
    {'name': 'Lake Kariba Basin', 'capacityPct': 64.2, 'volumeM3': '41.2B m³', 'discharge': '1,200 m³/s', 'status': 'Optimal'},
    {'name': 'Mazowe Dam Complex', 'capacityPct': 89.5, 'volumeM3': '38.4M m³', 'discharge': '420 m³/s', 'status': 'Surplus High'},
    {'name': 'Lake Mutirikwi (Masvingo)', 'capacityPct': 72.8, 'volumeM3': '1.38B m³', 'discharge': '650 m³/s', 'status': 'Stable'},
    {'name': 'Osborne Dam (Manicaland)', 'capacityPct': 81.0, 'volumeM3': '401M m³', 'discharge': '280 m³/s', 'status': 'Stable'},
  ];

  // ── 2. FARMER REGISTRY STATE ────────────────────────────────────────────────
  final List<Map<String, dynamic>> _farmers = [
    {
      'id': 'ZIM-FID-9821',
      'name': 'Tendai Chigodora',
      'nationalId': '63-221984 B16',
      'phone': '+263 77 219 0041',
      'province': 'Manicaland',
      'district': 'Mutare District',
      'ward': 'Ward 12',
      'status': 'Verified',
      'crops': 'Maize, Horticulture',
      'landHa': 4.5,
      'bankStatus': 'CBZ Account Linked',
    },
    {
      'id': 'ZIM-FID-5512',
      'name': 'Nomsa Ndlovu',
      'nationalId': '63-401822 B24',
      'phone': '+263 71 882 1093',
      'province': 'Matabeleland South',
      'district': 'Plumtree West',
      'ward': 'Ward 3',
      'status': 'Verified',
      'crops': 'Sorghum, Groundnuts',
      'landHa': 2.2,
      'bankStatus': 'ZB Mobile Linked',
    },
    {
      'id': 'ZIM-FID-3091',
      'name': 'Farai Mupamhanga',
      'nationalId': '63-519017 B41',
      'phone': '+263 78 440 9182',
      'province': 'Mashonaland Central',
      'district': 'Mazowe Valley',
      'ward': 'Ward 7',
      'status': 'Pending Verification',
      'crops': 'Blueberries, Coffee',
      'landHa': 12.0,
      'bankStatus': 'No Account Linked',
    },
    {
      'id': 'ZIM-FID-7712',
      'name': 'Rutendo Chiremba',
      'nationalId': '63-779022 B55',
      'phone': '+263 77 912 3004',
      'province': 'Manicaland',
      'district': 'Nyanga North',
      'ward': 'Ward 2',
      'status': 'Verified',
      'crops': 'Stone Fruit, Tea',
      'landHa': 8.1,
      'bankStatus': 'Steward Account Linked',
    },
  ];

  // ── 3. FARM PARCELS STATE ───────────────────────────────────────────────────
  final List<Map<String, dynamic>> _farms = [
    {
      'parcelId': 'PARCEL-MAN-0012',
      'farmerId': 'ZIM-FID-9821',
      'farmerName': 'Tendai Chigodora',
      'boundary': 'GIS Polygon: -18.9712, 32.6711 (4.5 Ha)',
      'soilType': 'Sandy Loam',
      'province': 'Manicaland',
      'ndvi': '0.74 (Healthy)',
      'waterSource': 'Borehole + River Divert',
      'registeredBy': 'Ext. Officer E. Moyo',
    },
    {
      'parcelId': 'PARCEL-MAT-0034',
      'farmerId': 'ZIM-FID-5512',
      'farmerName': 'Nomsa Ndlovu',
      'boundary': 'GIS Polygon: -20.5233, 27.8901 (2.2 Ha)',
      'soilType': 'Red Clay',
      'province': 'Matabeleland South',
      'ndvi': '0.61 (Moderate)',
      'waterSource': 'Seasonal Rain + Borehole',
      'registeredBy': 'Ext. Officer S. Sibanda',
    },
    {
      'parcelId': 'PARCEL-MAC-0077',
      'farmerId': 'ZIM-FID-3091',
      'farmerName': 'Farai Mupamhanga',
      'boundary': 'GIS Polygon: -17.5010, 30.8802 (12.0 Ha)',
      'soilType': 'Dark Fertile Loam',
      'province': 'Mashonaland Central',
      'ndvi': '0.82 (Excellent)',
      'waterSource': 'Mazowe River Irrigation Scheme',
      'registeredBy': 'Ext. Officer T. Mushonga',
    },
  ];

  // ── 4. EXTENSION OFFICERS STATE ─────────────────────────────────────────────
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
      'status': 'On Field Visit',
      'specialization': 'Livestock & Veterinary Liaison',
    },
  ];

  // ── 5. SUBSIDIES & ADVISORIES STATE ─────────────────────────────────────────
  final List<Map<String, dynamic>> _vouchers = [
    {'id': 'VCH-882', 'farmer': 'Tendai Chigodora', 'inputs': 'Maize Seed (25kg), Compound D Fertilizer (50kg)', 'value': '\$42.00', 'status': 'Distributed', 'season': '2026 A'},
    {'id': 'VCH-883', 'farmer': 'Nomsa Ndlovu', 'inputs': 'Sorghum Seed (10kg), Ammonium Nitrate (50kg)', 'value': '\$28.50', 'status': 'Pending Approval', 'season': '2026 A'},
    {'id': 'VCH-884', 'farmer': 'Farai Mupamhanga', 'inputs': 'Drip Irrigation Kit (1 unit), Micronutrient Pack', 'value': '\$120.00', 'status': 'Distributed', 'season': '2026 A'},
  ];

  final List<Map<String, String>> _advisories = [
    {
      'id': 'ADV-101',
      'subject': 'Frost Risk Warning',
      'region': 'Nyanga & High-Altitude Zones',
      'message': 'Temperatures expected to drop below 3°C tonight. Irrigate vulnerable crops early.',
      'date': 'Today, 07:00',
      'sentBy': 'Ext. Officer E. Moyo',
    }
  ];

  // ── 6. BIOSECURITY & OUTBREAKS STATE ───────────────────────────────────────
  final List<Map<String, dynamic>> _outbreaks = [
    {
      'id': 'OUT-102',
      'pest': 'Fall Armyworm Infestation',
      'type': 'Crop Pest',
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
      'type': 'Livestock Vector',
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
      'type': 'Crop Virus',
      'location': 'Rusape East',
      'severity': 'Moderate',
      'date': '2 days ago',
      'status': 'Monitoring Active',
      'affectedHa': 85,
      'officer': 'Tatenda Mushonga',
    },
  ];

  // ── 7. TRADE & PRICES STATE ────────────────────────────────────────────────
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

  final List<Map<String, dynamic>> _prices = [
    {'commodity': 'White Maize GMB Grade A', 'province': 'Harare', 'wholesale': '\$220/t', 'retail': '\$0.26/kg', 'change': '+2.4%', 'up': true},
    {'commodity': 'Soybeans (Crushing Quality)', 'province': 'Mazowe', 'wholesale': '\$580/t', 'retail': '\$0.72/kg', 'change': '+4.1%', 'up': true},
    {'commodity': 'Red Sorghum Grain', 'province': 'Gwanda', 'wholesale': '\$185/t', 'retail': '\$0.23/kg', 'change': '-0.5%', 'up': false},
    {'commodity': 'Sugar Beans (Dry)', 'province': 'Bulawayo', 'wholesale': '\$950/t', 'retail': '\$1.15/kg', 'change': '+1.8%', 'up': true},
    {'commodity': 'Fresh Blueberries (Export Grade)', 'province': 'Nyanga', 'wholesale': '\$4500/t', 'retail': '\$5.40/kg', 'change': '+8.6%', 'up': true},
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
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090D16) : GovernmentPage.background;
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : GovernmentPage.dark;
    final isDemo = ref.watch(isDemoModeProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, size: 20, color: GovernmentPage.green),
                const SizedBox(width: 8),
                Text(
                  'National AgOS Administration Console',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Text(
              'Ministry of Lands, Agriculture, Water & Sovereign Food Security',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Data',
            onPressed: _refresh,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: GovernmentPage.green),
                  )
                : Icon(Icons.refresh_outlined, color: isDark ? Colors.white : GovernmentPage.charcoal),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: surfaceColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              // HIGH CONTRAST COLORS FOR TAB READABILITY
              indicatorColor: GovernmentPage.green,
              indicatorWeight: 3,
              labelColor: GovernmentPage.green,
              unselectedLabelColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B), // Dark slate text for ultra-crisp contrast
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(icon: Icon(Icons.shield_outlined, size: 16), text: 'Food Security'),
                Tab(icon: Icon(Icons.person_pin_outlined, size: 16), text: 'Farmer Registry'),
                Tab(icon: Icon(Icons.map_outlined, size: 16), text: 'Farm Registration'),
                Tab(icon: Icon(Icons.support_agent_outlined, size: 16), text: 'Extension Officers'),
                Tab(icon: Icon(Icons.wallet_outlined, size: 16), text: 'Subsidies & Advisory'),
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
          _buildFoodSecurityTab(isDark, surfaceColor, textColor, isDemo),
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
  // TAB 1: FOOD SECURITY & STRATEGIC GRAIN/WATER RESERVES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFoodSecurityTab(bool isDark, Color surfaceColor, Color textColor, bool isDemo) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'National Food Security & Water Dashboard',
                icon: Icons.shield_outlined,
                color: GovernmentPage.green,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovernmentPage.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showAddGrainReserveModal(context),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Input Grain Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Grain Reserve Gauges
        LayoutBuilder(builder: (context, c) {
          final isNarrow = c.maxWidth < 650;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildGrainCard(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Strategic Maize (GMB)',
                currentTons: _maizeReserveTons,
                targetTons: 500000,
                color: GovernmentPage.green,
                isDark: isDark,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
              _buildGrainCard(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Strategic Wheat Reserve',
                currentTons: _wheatReserveTons,
                targetTons: 200000,
                color: GovernmentPage.orange,
                isDark: isDark,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
              _buildGrainCard(
                width: isNarrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                title: 'Sorghum & Millets',
                currentTons: _sorghumReserveTons,
                targetTons: 100000,
                color: GovernmentPage.purple,
                isDark: isDark,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
            ],
          );
        }),

        const SizedBox(height: 20),

        // Dam & Water Reservoirs Section
        Row(
          children: [
            Expanded(
              child: Text(
                'National Water Dams & Irrigation Allocation',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddDamModal(context),
              icon: const Icon(Icons.add, size: 16, color: GovernmentPage.blue),
              label: const Text('Add Dam Telemetry', style: TextStyle(color: GovernmentPage.blue, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _dams.length; i++) ...[
                if (i > 0) Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GovernmentPage.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: GovernmentPage.blue, size: 20),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dams[i]['name'] as String,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: GovernmentPage.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_dams[i]['capacityPct']}% Capacity',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: GovernmentPage.green),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Volume: ${_dams[i]['volumeM3']} · Discharge: ${_dams[i]['discharge']} · Status: ${_dams[i]['status']}',
                      style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600),
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

  Widget _buildGrainCard({
    required double width,
    required String title,
    required int currentTons,
    required int targetTons,
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
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: GovernmentPage.bodyText)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${(currentTons / 1000).toStringAsFixed(0)}k', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
              const SizedBox(width: 4),
              Text('/ ${(targetTons / 1000).toStringAsFixed(0)}k metric tons', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: FARMER REGISTRY & VERIFICATION
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
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _farmerSearchQuery = val),
                style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Search by Name, Farmer ID, or National ID...',
                  hintStyle: GoogleFonts.inter(color: GovernmentPage.bodyText, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: GovernmentPage.charcoal),
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
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
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Register Farmer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text('National Smallholder Farmer Registry (${filtered.length})', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: textColor)),
        const SizedBox(height: 10),

        for (final farmer in filtered)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: GovernmentPage.green.withValues(alpha: 0.15),
                child: Text((farmer['name'] as String).substring(0, 1), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: GovernmentPage.green)),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(farmer['name'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: GovernmentPage.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(farmer['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.teal)),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ID: ${farmer['id']} · National ID: ${farmer['nationalId']} · ${farmer['district']}, ${farmer['province']} · Crops: ${farmer['crops']} (${farmer['landHa']} Ha)',
                  style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: FARM PARCELS & GIS REGISTRATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFarmRegistrationTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'GIS Land Parcels & Satellite Vegetation Index',
                icon: Icons.map_outlined,
                color: GovernmentPage.purple,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovernmentPage.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showAddParcelModal(context),
              icon: const Icon(Icons.add_location_alt_outlined, size: 16),
              label: const Text('Register Land Parcel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        for (final farm in _farms)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.landscape_rounded, color: GovernmentPage.purple, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(farm['parcelId'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: textColor))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: GovernmentPage.purple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('NDVI: ${farm['ndvi']}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: GovernmentPage.purple)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Owner: ${farm['farmerName']} (${farm['farmerId']})', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
                Text('Boundary: ${farm['boundary']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                Text('Soil Type: ${farm['soilType']} · Water: ${farm['waterSource']} · Registered by: ${farm['registeredBy']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4: EXTENSION OFFICERS MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildExtensionOfficersTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'Field Extension Officers Directory',
                icon: Icons.support_agent_outlined,
                color: GovernmentPage.blue,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: GovernmentPage.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showAddOfficerModal(context),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Deploy Extension Officer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        for (final off in _officers)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: GovernmentPage.blue.withValues(alpha: 0.15),
                  child: Text((off['name'] as String).substring(0, 1), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: GovernmentPage.blue)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('${off['name']} (${off['id']})', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: GovernmentPage.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(off['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.blue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Province: ${off['province']} · District: ${off['district']} (${off['wards']})', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                      Text('Specialization: ${off['specialization']} · Farmers Supported: ${off['farmersSupported']} · Phone: ${off['phone']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 5: SUB-SIDIES (E-VOUCHERS) & BROADCAST ADVISORIES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSubsidiesTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Subsidies Action Header
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'State Input Subsidies & E-Vouchers',
                icon: Icons.wallet_outlined,
                color: GovernmentPage.orange,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _showAddVoucherModal(context),
              icon: const Icon(Icons.card_giftcard, size: 16),
              label: const Text('Issue E-Voucher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        for (final vch in _vouchers)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, color: GovernmentPage.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${vch['id']} · ${vch['farmer']} (${vch['value']})', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor)),
                      Text('Inputs: ${vch['inputs']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: GovernmentPage.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(vch['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.orange)),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Broadcast Advisories Section
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'Broadcast Mobile Advisories to Farmers',
                icon: Icons.campaign_outlined,
                color: GovernmentPage.teal,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _showBroadcastAdvisoryModal(context),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Broadcast Advisory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        for (final adv in _advisories)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.record_voice_over_outlined, color: GovernmentPage.teal, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${adv['subject']} (${adv['region']})', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor))),
                    Text(adv['date']!, style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(adv['message']!, style: GoogleFonts.inter(fontSize: 12, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Issued by: ${adv['sentBy']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 6: BIOSECURITY & PEST OUTBREAK EMERGENCY CONTROL
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBiosecurityTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'National Biosecurity & Outbreak Control',
                icon: Icons.bug_report_outlined,
                color: GovernmentPage.red,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _showAddOutbreakModal(context),
              icon: const Icon(Icons.warning_amber_rounded, size: 16),
              label: const Text('Report Outbreak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        for (final out in _outbreaks)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.coronavirus_outlined, color: GovernmentPage.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${out['pest']} (${out['type']})', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: textColor))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: GovernmentPage.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('Severity: ${out['severity']}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: GovernmentPage.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Location: ${out['location']} · Affected Area: ${out['affectedHa']} Ha', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
                Text('Status: ${out['status']} · Responding Officer: ${out['officer']} · Reported: ${out['date']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 7: TRADE & COMMODITY PRICE MONITORING
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTradeTab(bool isDark, Color surfaceColor, Color textColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Export Consignments Header
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'Export Consignments & ePhyto Clearances',
                icon: Icons.verified_outlined,
                color: GovernmentPage.blue,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _showAddConsignmentModal(context),
              icon: const Icon(Icons.local_shipping_outlined, size: 16),
              label: const Text('Log Consignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        for (final item in _consignments)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${item['crop']} (${item['weightKg']} kg)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: textColor))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
                      onPressed: () {
                        setState(() => item['phytoStatus'] = 'Cleared & Sealed');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ePhyto ${item['id']} Cleared!'), backgroundColor: GovernmentPage.green));
                      },
                      child: Text(item['phytoStatus'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text('Exporter: ${item['exporter']} · Border: ${item['border']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                Text('Destination: ${item['destination']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Commodity Price Index Header
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: 'National Commodity Price Monitoring Index',
                icon: Icons.price_change_outlined,
                color: GovernmentPage.green,
                textColor: textColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _showAddPriceModal(context),
              icon: const Icon(Icons.add_chart, size: 16),
              label: const Text('Input Commodity Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _prices.length; i++) ...[
                if (i > 0) Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(_prices[i]['commodity'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: textColor)),
                  subtitle: Text('Province: ${_prices[i]['province']} · Wholesale: ${_prices[i]['wholesale']} · Retail: ${_prices[i]['retail']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.bodyText, fontWeight: FontWeight.w600)),
                  trailing: Text(_prices[i]['change'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: (_prices[i]['up'] as bool) ? GovernmentPage.green : GovernmentPage.red)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA INPUT MODALS (MODAL WORKFLOWS FOR EVERY SINGLE TAB)
  // ═══════════════════════════════════════════════════════════════════════════

  // 1. Modal: Input Grain Delivery
  void _showAddGrainReserveModal(BuildContext context) {
    final qtyCtrl = TextEditingController();
    String crop = 'Maize';
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Input GMB Grain Stock Delivery', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: crop,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Maize', child: Text('Maize (White GMB Grade A)')),
                  DropdownMenuItem(value: 'Wheat', child: Text('Wheat (Hard Red Grain)')),
                  DropdownMenuItem(value: 'Sorghum', child: Text('Sorghum & Millets')),
                ],
                onChanged: (v) => setDlgState(() => crop = v!),
              ),
              TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity (Metric Tons)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                if (qty > 0) {
                  setState(() {
                    if (crop == 'Maize') _maizeReserveTons += qty;
                    if (crop == 'Wheat') _wheatReserveTons += qty;
                    if (crop == 'Sorghum') _sorghumReserveTons += qty;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $qty Tons of $crop to GMB Reserve!'), backgroundColor: GovernmentPage.green));
                }
              },
              child: const Text('Save Grain Delivery'),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Modal: Add Dam Telemetry
  void _showAddDamModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final capCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Dam Telemetry', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Dam / Water Basin Name')),
            TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity Percentage (e.g. 75.5)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.blue, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _dams.add({
                    'name': nameCtrl.text.trim(),
                    'capacityPct': double.tryParse(capCtrl.text.trim()) ?? 75.0,
                    'volumeM3': '250M m³',
                    'discharge': '350 m³/s',
                    'status': 'Optimal',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dam Telemetry Saved!'), backgroundColor: GovernmentPage.blue));
              }
            },
            child: const Text('Save Telemetry'),
          ),
        ],
      ),
    );
  }

  // 3. Modal: Register Farmer
  void _showRegisterFarmerModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final natIdCtrl = TextEditingController();
    final provCtrl = TextEditingController(text: 'Manicaland');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Register Smallholder Farmer', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Legal Name')),
            TextField(controller: natIdCtrl, decoration: const InputDecoration(labelText: 'National ID (e.g. 63-123456 A78)')),
            TextField(controller: provCtrl, decoration: const InputDecoration(labelText: 'Province')),
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
                    'province': provCtrl.text.trim(),
                    'district': 'Central District',
                    'ward': 'Ward 1',
                    'status': 'Verified',
                    'crops': 'Maize, Groundnuts',
                    'landHa': 3.5,
                    'bankStatus': 'CBZ Account Linked',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Farmer ${nameCtrl.text.trim()} Registered!'), backgroundColor: GovernmentPage.green));
              }
            },
            child: const Text('Register Farmer'),
          ),
        ],
      ),
    );
  }

  // 4. Modal: Register Land Parcel
  void _showAddParcelModal(BuildContext context) {
    final parcelCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();
    final boundCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Register GIS Land Parcel', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: parcelCtrl, decoration: const InputDecoration(labelText: 'Parcel ID (e.g. PARCEL-HAR-09)')),
            TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'Farmer Owner Name')),
            TextField(controller: boundCtrl, decoration: const InputDecoration(labelText: 'GPS Polygon / Area Ha')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.purple, foregroundColor: Colors.white),
            onPressed: () {
              if (parcelCtrl.text.isNotEmpty) {
                setState(() {
                  _farms.insert(0, {
                    'parcelId': parcelCtrl.text.trim(),
                    'farmerId': 'ZIM-FID-999',
                    'farmerName': ownerCtrl.text.trim().isEmpty ? 'Tendai Chigodora' : ownerCtrl.text.trim(),
                    'boundary': boundCtrl.text.trim().isEmpty ? 'GIS Polygon: -18.2, 32.1 (5.0 Ha)' : boundCtrl.text.trim(),
                    'soilType': 'Loam',
                    'province': 'Manicaland',
                    'ndvi': '0.78 (Optimal)',
                    'waterSource': 'Borehole',
                    'registeredBy': 'Ministry GIS Officer',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GIS Land Parcel Registered!'), backgroundColor: GovernmentPage.purple));
              }
            },
            child: const Text('Save Parcel'),
          ),
        ],
      ),
    );
  }

  // 5. Modal: Deploy Extension Officer
  void _showAddOfficerModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final distCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deploy Extension Officer', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Officer Full Name')),
            TextField(controller: distCtrl, decoration: const InputDecoration(labelText: 'District & Wards')),
            TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Specialization (e.g. Agronomy/Livestock)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.blue, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _officers.insert(0, {
                    'id': 'EXT-${100 + _officers.length}',
                    'name': nameCtrl.text.trim(),
                    'province': 'Manicaland',
                    'district': distCtrl.text.trim().isEmpty ? 'Mutare' : distCtrl.text.trim(),
                    'wards': 'Ward 1, 2',
                    'farmersSupported': 120,
                    'phone': '+263 77 111 2222',
                    'status': 'Active',
                    'specialization': specCtrl.text.trim().isEmpty ? 'General Extension' : specCtrl.text.trim(),
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extension Officer Deployed!'), backgroundColor: GovernmentPage.blue));
              }
            },
            child: const Text('Deploy Officer'),
          ),
        ],
      ),
    );
  }

  // 6. Modal: Issue E-Voucher Subsidy
  void _showAddVoucherModal(BuildContext context) {
    final farmerCtrl = TextEditingController();
    final inputCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Issue State E-Voucher Subsidy', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: farmerCtrl, decoration: const InputDecoration(labelText: 'Farmer Name')),
            TextField(controller: inputCtrl, decoration: const InputDecoration(labelText: 'Input Package (e.g. Maize Seed 25kg)')),
            TextField(controller: valCtrl, decoration: const InputDecoration(labelText: 'Subsidy Value (\$45.00)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.orange, foregroundColor: Colors.white),
            onPressed: () {
              if (farmerCtrl.text.isNotEmpty) {
                setState(() {
                  _vouchers.insert(0, {
                    'id': 'VCH-${900 + _vouchers.length}',
                    'farmer': farmerCtrl.text.trim(),
                    'inputs': inputCtrl.text.trim().isEmpty ? 'Maize Seed (25kg) + Fertilizer' : inputCtrl.text.trim(),
                    'value': valCtrl.text.trim().isEmpty ? '\$45.00' : valCtrl.text.trim(),
                    'status': 'Distributed',
                    'season': '2026 A',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-Voucher Subsidy Issued!'), backgroundColor: GovernmentPage.orange));
              }
            },
            child: const Text('Issue Voucher'),
          ),
        ],
      ),
    );
  }

  // 7. Modal: Broadcast Advisory
  void _showBroadcastAdvisoryModal(BuildContext context) {
    final subjCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Broadcast Advisory to Farmers', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjCtrl, decoration: const InputDecoration(labelText: 'Advisory Subject')),
            TextField(controller: regCtrl, decoration: const InputDecoration(labelText: 'Target Region / Province')),
            TextField(controller: msgCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Message Body')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.teal, foregroundColor: Colors.white),
            onPressed: () {
              if (subjCtrl.text.isNotEmpty) {
                setState(() {
                  _advisories.insert(0, {
                    'id': 'ADV-${100 + _advisories.length}',
                    'subject': subjCtrl.text.trim(),
                    'region': regCtrl.text.trim().isEmpty ? 'All Provinces' : regCtrl.text.trim(),
                    'message': msgCtrl.text.trim().isEmpty ? 'Urgent agricultural advisory notice.' : msgCtrl.text.trim(),
                    'date': 'Just Now',
                    'sentBy': 'Ministry Command',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Advisory Broadcasted to Farmers!'), backgroundColor: GovernmentPage.teal));
              }
            },
            child: const Text('Broadcast Now'),
          ),
        ],
      ),
    );
  }

  // 8. Modal: Report Biosecurity Outbreak
  void _showAddOutbreakModal(BuildContext context) {
    final pestCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final haCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Report Biosecurity Outbreak', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: pestCtrl, decoration: const InputDecoration(labelText: 'Pest / Disease Name (e.g. Fall Armyworm)')),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location / District')),
            TextField(controller: haCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Affected Hectares')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.red, foregroundColor: Colors.white),
            onPressed: () {
              if (pestCtrl.text.isNotEmpty) {
                setState(() {
                  _outbreaks.insert(0, {
                    'id': 'OUT-${100 + _outbreaks.length}',
                    'pest': pestCtrl.text.trim(),
                    'type': 'Crop Emergency',
                    'location': locCtrl.text.trim().isEmpty ? 'Harare West' : locCtrl.text.trim(),
                    'severity': 'Critical',
                    'date': 'Just Now',
                    'status': 'Quarantine Ordered',
                    'affectedHa': int.tryParse(haCtrl.text.trim()) ?? 150,
                    'officer': 'Ministry Biosecurity Command',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biosecurity Outbreak Reported & Quarantine Initiated!'), backgroundColor: GovernmentPage.red));
              }
            },
            child: const Text('Report & Quarantine'),
          ),
        ],
      ),
    );
  }

  // 9. Modal: Log Export Consignment
  void _showAddConsignmentModal(BuildContext context) {
    final cropCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log Export Consignment', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cropCtrl, decoration: const InputDecoration(labelText: 'Crop / Commodity')),
            TextField(controller: expCtrl, decoration: const InputDecoration(labelText: 'Exporter Name')),
            TextField(controller: destCtrl, decoration: const InputDecoration(labelText: 'Destination (e.g. Rotterdam, EU)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.blue, foregroundColor: Colors.white),
            onPressed: () {
              if (cropCtrl.text.isNotEmpty) {
                setState(() {
                  _consignments.insert(0, {
                    'id': 'EXP-${1000 + _consignments.length}',
                    'crop': cropCtrl.text.trim(),
                    'exporter': expCtrl.text.trim().isEmpty ? 'Zimbabwe Produce Export' : expCtrl.text.trim(),
                    'weightKg': 6500,
                    'destination': destCtrl.text.trim().isEmpty ? 'EU Port' : destCtrl.text.trim(),
                    'border': 'Forbes Border Post',
                    'amaStatus': 'Valid',
                    'phytoStatus': 'Pending Clearance',
                    'hash': '0x7e8b91a0c4f2e9198d02ab41fa9c',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export Consignment Logged!'), backgroundColor: GovernmentPage.blue));
              }
            },
            child: const Text('Log Consignment'),
          ),
        ],
      ),
    );
  }

  // 10. Modal: Input Commodity Price
  void _showAddPriceModal(BuildContext context) {
    final commCtrl = TextEditingController();
    final provCtrl = TextEditingController();
    final wsCtrl = TextEditingController();
    final rtCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Input Commodity Price Update', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: commCtrl, decoration: const InputDecoration(labelText: 'Commodity Name')),
            TextField(controller: provCtrl, decoration: const InputDecoration(labelText: 'Province / Location')),
            TextField(controller: wsCtrl, decoration: const InputDecoration(labelText: 'Wholesale Price (e.g. \$250/t)')),
            TextField(controller: rtCtrl, decoration: const InputDecoration(labelText: 'Retail Price (e.g. \$0.30/kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
            onPressed: () {
              if (commCtrl.text.isNotEmpty) {
                setState(() {
                  _prices.insert(0, {
                    'commodity': commCtrl.text.trim(),
                    'province': provCtrl.text.trim().isEmpty ? 'Harare' : provCtrl.text.trim(),
                    'wholesale': wsCtrl.text.trim().isEmpty ? '\$250/t' : wsCtrl.text.trim(),
                    'retail': rtCtrl.text.trim().isEmpty ? '\$0.30/kg' : rtCtrl.text.trim(),
                    'change': '+1.5%',
                    'up': true,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commodity Price Updated!'), backgroundColor: GovernmentPage.green));
              }
            },
            child: const Text('Save Price Update'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color textColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
        ),
      ],
    );
  }
}