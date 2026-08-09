import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../analytics/data/analytics_export_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GOVERNMENT PAGE — National AgOS Administration Console
// Covers: Food Security, Farmer Registry, Farm Registration, Extension Officers,
//         Input Subsidies, Biosecurity Outbreaks, ePhyto Customs, Price Monitoring
// ─────────────────────────────────────────────────────────────────────────────

class GovernmentPage extends StatefulWidget {
  const GovernmentPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const teal = Color(0xFF0F766E);
  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFFF8FAFC);

  @override
  State<GovernmentPage> createState() => _GovernmentPageState();
}

class _GovernmentPageState extends State<GovernmentPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;

  String _farmerSearchQuery = '';
  String _farmerProvinceFilter = 'All Provinces';

  // ── FARMER REGISTRY ────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _farmers = [
    {
      'id': 'ZIM-FID-9821', 'name': 'Tendai Chigodora', 'nationalId': '63-221984 B16',
      'region': 'Mutare District', 'ward': 'Ward 12', 'province': 'Manicaland',
      'experience': '12 years', 'householdSize': 6, 'wallet': 'EcoCash (\$240.50)',
      'crops': 'Maize, Horticulture', 'landHa': 4.5, 'status': 'Verified',
      'bankStatus': 'CBZ Account Linked',
    },
    {
      'id': 'ZIM-FID-5512', 'name': 'Nomsa Ndlovu', 'nationalId': '63-401822 B24',
      'region': 'Plumtree West', 'ward': 'Ward 3', 'province': 'Matabeleland South',
      'experience': '8 years', 'householdSize': 4, 'wallet': 'OneMoney (\$150.00)',
      'crops': 'Sorghum, Groundnuts', 'landHa': 2.2, 'status': 'Verified',
      'bankStatus': 'ZB Mobile Linked',
    },
    {
      'id': 'ZIM-FID-3091', 'name': 'Farai Mupamhanga', 'nationalId': '63-519017 B41',
      'region': 'Mazowe Valley', 'ward': 'Ward 7', 'province': 'Mashonaland Central',
      'experience': '15 years', 'householdSize': 8, 'wallet': 'CBZ Agro Card',
      'crops': 'Blueberries, Coffee, Macadamia', 'landHa': 12.0, 'status': 'Pending Verification',
      'bankStatus': 'No Account Linked',
    },
    {
      'id': 'ZIM-FID-7712', 'name': 'Rutendo Chiremba', 'nationalId': '63-779022 B55',
      'region': 'Nyanga North', 'ward': 'Ward 2', 'province': 'Manicaland',
      'experience': '20 years', 'householdSize': 5, 'wallet': 'Steward Bank Mobile',
      'crops': 'Stone Fruit, Tea, Potatoes', 'landHa': 8.1, 'status': 'Verified',
      'bankStatus': 'Steward Account Linked',
    },
  ];

  // ── FARM PARCELS REGISTRATION ───────────────────────────────────────────────
  final List<Map<String, dynamic>> _farms = [
    {
      'parcelId': 'PARCEL-MAN-0012', 'farmerId': 'ZIM-FID-9821', 'farmerName': 'Tendai Chigodora',
      'boundary': 'GIS Polygon: -18.9712, 32.6711 (4.5 Ha)', 'soilType': 'Sandy Loam',
      'elevation': '820m ASL', 'waterSource': 'Borehole + River Divert',
      'landUse': 'Mixed Horticulture', 'province': 'Manicaland', 'ndvi': '0.74 (Healthy)',
      'registeredBy': 'Ext. Officer E. Moyo', 'registeredDate': '12 Mar 2025',
    },
    {
      'parcelId': 'PARCEL-MAT-0034', 'farmerId': 'ZIM-FID-5512', 'farmerName': 'Nomsa Ndlovu',
      'boundary': 'GIS Polygon: -20.5233, 27.8901 (2.2 Ha)', 'soilType': 'Red Clay',
      'elevation': '990m ASL', 'waterSource': 'Seasonal Rain + Borehole',
      'landUse': 'Dryland Grain', 'province': 'Matabeleland South', 'ndvi': '0.61 (Moderate)',
      'registeredBy': 'Ext. Officer S. Sibanda', 'registeredDate': '05 Jan 2025',
    },
    {
      'parcelId': 'PARCEL-MAC-0077', 'farmerId': 'ZIM-FID-3091', 'farmerName': 'Farai Mupamhanga',
      'boundary': 'GIS Polygon: -17.5010, 30.8802 (12.0 Ha)', 'soilType': 'Dark Fertile Loam',
      'elevation': '1100m ASL', 'waterSource': 'Mazowe River Irrigation Scheme',
      'landUse': 'Export Horticulture + Coffee', 'province': 'Mashonaland Central', 'ndvi': '0.82 (Excellent)',
      'registeredBy': 'Ext. Officer T. Mushonga', 'registeredDate': '22 Nov 2024',
    },
  ];

  // ── EXTENSION OFFICERS ─────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _officers = [
    {
      'id': 'EXT-0021', 'name': 'Evelyn Moyo', 'province': 'Manicaland',
      'district': 'Mutare', 'wards': 'Ward 12, 13, 14', 'farmersSupported': 142,
      'trainingSessions': 8, 'lastFieldVisit': 'Today', 'status': 'Active',
      'phone': '+263 77 201 3344', 'specialization': 'Horticulture & Export Crops',
    },
    {
      'id': 'EXT-0022', 'name': 'Solomon Sibanda', 'province': 'Matabeleland South',
      'district': 'Plumtree', 'wards': 'Ward 3, 4, 5', 'farmersSupported': 87,
      'trainingSessions': 5, 'lastFieldVisit': 'Yesterday', 'status': 'Active',
      'phone': '+263 71 490 8823', 'specialization': 'Dryland Grain & Livestock',
    },
    {
      'id': 'EXT-0023', 'name': 'Tatenda Mushonga', 'province': 'Mashonaland Central',
      'district': 'Mazowe', 'wards': 'Ward 7, 8', 'farmersSupported': 210,
      'trainingSessions': 12, 'lastFieldVisit': '3 days ago', 'status': 'Active',
      'phone': '+263 78 112 5599', 'specialization': 'Irrigation & Soil Health',
    },
    {
      'id': 'EXT-0024', 'name': 'Alice Dube', 'province': 'Midlands',
      'district': 'Gweru', 'wards': 'Ward 2', 'farmersSupported': 56,
      'trainingSessions': 3, 'lastFieldVisit': '1 week ago', 'status': 'On Leave',
      'phone': '+263 77 340 1122', 'specialization': 'Livestock & Veterinary Liaison',
    },
  ];

  // ── E-VOUCHERS ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _vouchers = [
    {'id': 'VCH-882', 'farmer': 'Tendai Chigodora', 'inputs': 'Maize Seed (25kg), Compound D Fertilizer (50kg)', 'value': '\$42.00', 'status': 'Distributed', 'season': '2025 A'},
    {'id': 'VCH-883', 'farmer': 'Nomsa Ndlovu', 'inputs': 'Sorghum Seed (10kg), Ammonium Nitrate (50kg)', 'value': '\$28.50', 'status': 'Redeemed', 'season': '2025 A'},
    {'id': 'VCH-884', 'farmer': 'Farai Mupamhanga', 'inputs': 'Drip Irrigation Kit (1 unit), Micronutrient Pack', 'value': '\$120.00', 'status': 'Distributed', 'season': '2025 A'},
  ];

  // ── OUTBREAKS ──────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _outbreaks = [
    {
      'id': 'OUT-102', 'pest': 'Fall Armyworm Infestation', 'type': 'Crop',
      'location': 'Domboshava Fields', 'severity': 'Critical',
      'date': 'Today, 08:30', 'status': 'Quarantine Ordered',
      'affectedHa': 340, 'respondingOfficer': 'Evelyn Moyo',
    },
    {
      'id': 'OUT-103', 'pest': 'Foot and Mouth Disease Alert', 'type': 'Livestock',
      'location': 'Gwanda Southern Corridors', 'severity': 'High',
      'date': 'Yesterday, 14:15', 'status': 'Vaccination Dispatched',
      'affectedHa': 0, 'respondingOfficer': 'Alice Dube',
    },
    {
      'id': 'OUT-104', 'pest': 'Tobacco Mosaic Virus', 'type': 'Crop',
      'location': 'Rusape East', 'severity': 'Moderate',
      'date': '2 days ago', 'status': 'Monitoring',
      'affectedHa': 85, 'respondingOfficer': 'Tatenda Mushonga',
    },
  ];

  // ── CUSTOMS / ePHYTO ───────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _dossiers = [
    {
      'consignmentId': 'EXP-PEAS-9921', 'destination': 'Port of Beira → Rotterdam (EU)',
      'border': 'Forbes Border Post', 'exporter': 'Eastern Highlands Growers',
      'crop': 'Sugar Snaps', 'weightKg': 8400, 'hsCode': 'HS-0708.10',
      'amaStatus': 'Valid', 'sazStatus': 'Compliant', 'phytoStatus': 'Pending Clearance',
    },
    {
      'consignmentId': 'EXP-BLUE-3310', 'destination': 'Port of Durban → London (UK)',
      'border': 'Beitbridge Border Post', 'exporter': 'Mazowe Blueberries Ltd',
      'crop': 'Blueberries', 'weightKg': 3600, 'hsCode': 'HS-0810.40',
      'amaStatus': 'Valid', 'sazStatus': 'Compliant', 'phytoStatus': 'Cleared',
    },
    {
      'consignmentId': 'EXP-AVOC-5514', 'destination': 'Port of Beira → Dubai (UAE)',
      'border': 'Forbes Border Post', 'exporter': 'Mutare Fresh Holdings',
      'crop': 'Avocados (Hass)', 'weightKg': 11200, 'hsCode': 'HS-0804.40',
      'amaStatus': 'Pending Renewal', 'sazStatus': 'Compliant', 'phytoStatus': 'On Hold',
    },
  ];

  // ── PRICE MONITORING ────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _prices = [
    {'commodity': 'Maize (white)', 'province': 'Harare', 'wholesale': '\$210/t', 'retail': '\$0.25/kg', 'change': '+3.2%', 'up': true},
    {'commodity': 'Tomatoes', 'province': 'Mutare', 'wholesale': '\$320/t', 'retail': '\$0.38/kg', 'change': '-1.5%', 'up': false},
    {'commodity': 'Sugar Beans', 'province': 'Bulawayo', 'wholesale': '\$580/t', 'retail': '\$0.65/kg', 'change': '+5.8%', 'up': true},
    {'commodity': 'Sorghum', 'province': 'Gwanda', 'wholesale': '\$180/t', 'retail': '\$0.22/kg', 'change': '+0.4%', 'up': true},
    {'commodity': 'Blueberries', 'province': 'Nyanga', 'wholesale': '\$4200/t', 'retail': '\$5.20/kg', 'change': '+12.1%', 'up': true},
    {'commodity': 'Avocados', 'province': 'Mutare', 'wholesale': '\$850/t', 'retail': '\$1.10/kg', 'change': '-2.0%', 'up': false},
  ];

  // ── ADVISORIES ─────────────────────────────────────────────────────────────
  final List<Map<String, String>> _advisories = [
    {
      'subject': 'Frost Risk Warning', 'region': 'Nyanga & High-Altitude Zones',
      'message': 'Temperatures expected to drop below 3°C tonight. Irrigate vulnerable crops early.',
      'lang': 'English / Shona', 'sentBy': 'Ext. Officer E. Moyo',
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovernmentPage.background,
      appBar: AppBar(
        title: Text('National Agricultural Administration Console',
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: GovernmentPage.dark, fontSize: 15)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh data',
            onPressed: _refresh,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: GovernmentPage.green))
                : const Icon(Icons.refresh_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: GovernmentPage.green,
              unselectedLabelColor: GovernmentPage.muted,
              indicatorColor: GovernmentPage.green,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_outlined, size: 16), text: 'Food Security'),
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
          _buildFoodSecurityTab(),
          _buildRegistryTab(),
          _buildFarmRegistrationTab(),
          _buildExtensionOfficersTab(),
          _buildSubsidiesTab(),
          _buildBiosecurityTab(),
          _buildTradeTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: FOOD SECURITY & STRATEGIC OVERVIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFoodSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Strategic National Food Security Dashboard', icon: Icons.shield_outlined, color: GovernmentPage.green),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 800 ? 3 : 2;
          return Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              InkWell(
                onTap: () => _tabController.animateTo(6), // Trade & Prices
                child: _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Strategic Maize Reserve', value: '420,000 t', icon: Icons.warehouse_outlined, color: GovernmentPage.green),
              ),
              InkWell(
                onTap: () => _tabController.animateTo(6), // Trade & Prices
                child: _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Wheat Reserve', value: '180,000 t', icon: Icons.grain_outlined, color: GovernmentPage.orange),
              ),
              InkWell(
                onTap: () => _showEmergencyReliefModal(context),
                child: _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Yield Forecast (National)', value: '1.24M t', icon: Icons.satellite_alt_outlined, color: GovernmentPage.blue),
              ),
              InkWell(
                onTap: () => _tabController.animateTo(1), // Farmer Registry
                child: _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Registered Farmers', value: '${_farmers.length + 8408}', icon: Icons.people_outlined, color: GovernmentPage.teal),
              ),
              InkWell(
                onTap: () => _tabController.animateTo(2), // Farm Registration
                child: _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Registered Farm Parcels', value: '${_farms.length + 3211}', icon: Icons.map_outlined, color: GovernmentPage.purple),
              ),
              InkWell(
                onTap: () => _tabController.animateTo(3), // Extension Officers
                child: _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Extension Officers', value: '${_officers.length + 182}', icon: Icons.support_agent_outlined, color: GovernmentPage.red),
              ),
            ],
          );
        }),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Climate & Disaster Early Warning System',
          child: Column(
            children: [
              _WarningItem(
                title: 'Drought Warning: Masvingo South', level: 'High Alert', color: GovernmentPage.red,
                desc: 'Rainfall anomaly threshold breached. Sub-surface moisture stress rising. Recommend emergency irrigation scheme activation.',
                onAction: () => _showEmergencyReliefModal(context),
              ),
              const SizedBox(height: 12),
              _WarningItem(
                title: 'Flood Risk: Zambezi Basin Downstream', level: 'Moderate Risk', color: GovernmentPage.orange,
                desc: 'Unusual telemetry spikes at downstream water meters. Sluice gate coordination with Kariba Dam Authority required.',
                onAction: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sluice gate coordination signal dispatched to Kariba Authority.'), backgroundColor: GovernmentPage.orange),
                  );
                },
              ),
              const SizedBox(height: 12),
              _WarningItem(
                title: 'Heatwave — Beitbridge Corridor', level: 'Advisory', color: GovernmentPage.blue,
                desc: 'Temperatures forecast 38–41°C for 5 days. Transit cold chain assets vulnerable. Issue transport advisory.',
                onAction: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cold-chain transport advisory broadcast to all refrigerated logistics operators.'), backgroundColor: GovernmentPage.blue),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Provincial Performance Scorecard',
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.2), 3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(decoration: BoxDecoration(color: GovernmentPage.green.withOpacity(0.08)),
                children: ['Province', 'Registered Farmers', 'Yield Index', 'Subsidy Coverage'].map((h) =>
                    Padding(padding: const EdgeInsets.all(10),
                        child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))).toList()),
              ...['Manicaland|2,841|0.84|78%', 'Mashonaland Central|3,120|0.91|82%',
                'Matabeleland South|1,240|0.61|64%', 'Midlands|1,810|0.73|70%',
                'Masvingo|2,190|0.68|66%'].map((row) {
                final cells = row.split('|');
                return TableRow(children: cells.map((c) =>
                    Padding(padding: const EdgeInsets.all(10),
                        child: Text(c, style: const TextStyle(fontSize: 12)))).toList());
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: FARMER REGISTRY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRegistryTab() {
    final nameCtrl = TextEditingController();
    final nationalIdCtrl = TextEditingController();
    final regionCtrl = TextEditingController();
    final wardCtrl = TextEditingController();
    final cropsCtrl = TextEditingController();
    String selectedProvince = 'Manicaland';
    String selectedWallet = 'EcoCash';

    final filteredFarmers = _farmers.where((f) {
      final matchesSearch = f['name'].toString().toLowerCase().contains(_farmerSearchQuery.toLowerCase()) ||
          f['id'].toString().toLowerCase().contains(_farmerSearchQuery.toLowerCase()) ||
          f['nationalId'].toString().toLowerCase().contains(_farmerSearchQuery.toLowerCase());
      final matchesProv = _farmerProvinceFilter == 'All Provinces' || f['province'] == _farmerProvinceFilter;
      return matchesSearch && matchesProv;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'National Farmer Registry', icon: Icons.badge_outlined, color: GovernmentPage.blue),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Register New Farmer — Unique Digital National ID',
          child: StatefulBuilder(builder: (ctx, setS) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. John Sibanda'))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: nationalIdCtrl, decoration: const InputDecoration(labelText: 'National ID Number', hintText: 'e.g. 63-221984 B16'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(
                    value: selectedProvince,
                    decoration: const InputDecoration(labelText: 'Province'),
                    items: ['Manicaland', 'Mashonaland Central', 'Mashonaland East', 'Matabeleland South',
                      'Matabeleland North', 'Midlands', 'Masvingo', 'Harare Metropolitan'].map((p) =>
                        DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setS(() => selectedProvince = v ?? selectedProvince),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: regionCtrl, decoration: const InputDecoration(labelText: 'District / Region'))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: wardCtrl, decoration: const InputDecoration(labelText: 'Ward Number', hintText: 'e.g. Ward 12'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: cropsCtrl, decoration: const InputDecoration(labelText: 'Primary Crops', hintText: 'e.g. Maize, Horticulture'))),
                  const SizedBox(width: 16),
                  Expanded(child: DropdownButtonFormField<String>(
                    value: selectedWallet,
                    decoration: const InputDecoration(labelText: 'Mobile Wallet'),
                    items: ['EcoCash', 'OneMoney', 'Telecash', 'CBZ Agro Card', 'Steward Bank Mobile', 'ZB Mobile'].map((w) =>
                        DropdownMenuItem(value: w, child: Text(w))).toList(),
                    onChanged: (v) => setS(() => selectedWallet = v ?? selectedWallet),
                  )),
                ]),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || nationalIdCtrl.text.isEmpty) return;
                    setState(() {
                      _farmers.add({
                        'id': 'ZIM-FID-${9000 + _farmers.length * 113}',
                        'name': nameCtrl.text.trim(), 'nationalId': nationalIdCtrl.text.trim(),
                        'region': regionCtrl.text.trim(), 'ward': wardCtrl.text.trim(),
                        'province': selectedProvince, 'experience': 'New Registrant',
                        'householdSize': 0, 'wallet': selectedWallet,
                        'crops': cropsCtrl.text.trim(), 'landHa': 0.0, 'status': 'Pending Verification',
                        'bankStatus': '$selectedWallet Linked',
                      });
                    });
                    nameCtrl.clear(); nationalIdCtrl.clear(); regionCtrl.clear();
                    wardCtrl.clear(); cropsCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registered new farmer to National Registry.'), backgroundColor: GovernmentPage.green),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Generate National Farmer ID & Register'),
                  style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'National Farmer Ledger (${filteredFarmers.length} Records)',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search farmer by name, ID, or NatID...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _farmerSearchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _farmerProvinceFilter,
                    style: const TextStyle(color: GovernmentPage.dark, fontSize: 13),
                    items: ['All Provinces', 'Manicaland', 'Mashonaland Central', 'Matabeleland South', 'Midlands', 'Masvingo']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _farmerProvinceFilter = v); },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFarmers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final f = filteredFarmers[i];
                  final isVerified = f['status'] == 'Verified';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: (isVerified ? GovernmentPage.green : GovernmentPage.orange).withOpacity(0.12),
                          child: Icon(Icons.person_outlined, color: isVerified ? GovernmentPage.green : GovernmentPage.orange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(f['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              _StatusChip(label: f['status'], color: isVerified ? GovernmentPage.green : GovernmentPage.orange),
                            ]),
                            const SizedBox(height: 4),
                            Text('ID: ${f['id']}  •  NatID: ${f['nationalId']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                            Text('${f['province']}, ${f['region']}, ${f['ward']}  •  Land: ${f['landHa']} ha', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                            Text('Crops: ${f['crops']}  •  Wallet: ${f['wallet']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                          ]),
                        ),
                        Wrap(
                          spacing: 4,
                          children: [
                            if (f['status'] == 'Pending Verification')
                              TextButton.icon(
                                onPressed: () => setState(() => f['status'] = 'Verified'),
                                icon: const Icon(Icons.verified_outlined, size: 14),
                                label: const Text('Verify', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(foregroundColor: GovernmentPage.green),
                              ),
                            IconButton(
                              icon: const Icon(Icons.badge_outlined, size: 18, color: GovernmentPage.blue),
                              tooltip: 'View Passport Dossier',
                              onPressed: () => _showFarmerDossierModal(context, f),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: FARM REGISTRATION (GIS / PARCEL)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFarmRegistrationTab() {
    final farmerIdCtrl = TextEditingController();
    final boundaryCtrl = TextEditingController();
    final soilCtrl = TextEditingController();
    final waterCtrl = TextEditingController();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Farm Parcel Registration — GIS Boundary & Soil Ledger', icon: Icons.map_outlined, color: GovernmentPage.teal),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Register New Farm Parcel (GIS Boundary)',
          child: StatefulBuilder(builder: (ctx, setS) {
            String landUse = 'Mixed Horticulture';
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: TextField(controller: farmerIdCtrl, decoration: const InputDecoration(labelText: 'Farmer National ID', hintText: 'ZIM-FID-XXXX'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: boundaryCtrl, decoration: const InputDecoration(labelText: 'GPS Boundary / Coordinates', hintText: '-18.9712, 32.6711 (4.5 Ha)'))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: soilCtrl, decoration: const InputDecoration(labelText: 'Soil Type', hintText: 'e.g. Sandy Loam'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: waterCtrl, decoration: const InputDecoration(labelText: 'Water Source', hintText: 'e.g. Borehole + River'))),
                const SizedBox(width: 16),
                Expanded(child: DropdownButtonFormField<String>(
                  value: landUse,
                  decoration: const InputDecoration(labelText: 'Land Use Classification'),
                  items: ['Mixed Horticulture', 'Dryland Grain', 'Export Horticulture', 'Livestock Grazing', 'Coffee/Tea Plantation', 'Smallholder Subsistence'].map((u) =>
                      DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setS(() => landUse = v ?? landUse),
                )),
              ]),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (farmerIdCtrl.text.isEmpty || boundaryCtrl.text.isEmpty) return;
                  final farmer = _farmers.firstWhere((f) => f['id'] == farmerIdCtrl.text.trim(), orElse: () => {'name': 'Unknown'});
                  setState(() {
                    _farms.add({
                      'parcelId': 'PARCEL-NEW-${_farms.length * 103}',
                      'farmerId': farmerIdCtrl.text.trim(),
                      'farmerName': farmer['name'],
                      'boundary': 'GIS Polygon: ${boundaryCtrl.text.trim()}',
                      'soilType': soilCtrl.text.trim(), 'elevation': 'Pending Survey',
                      'waterSource': waterCtrl.text.trim(), 'landUse': landUse,
                      'province': 'Manicaland', 'ndvi': '0.78 (Healthy)',
                      'registeredBy': 'Self-Service Portal', 'registeredDate': 'Today',
                    });
                  });
                  farmerIdCtrl.clear(); boundaryCtrl.clear(); soilCtrl.clear(); waterCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Farm Parcel registered & NDVI satellite scan queued.'), backgroundColor: GovernmentPage.teal),
                  );
                },
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Register Farm Parcel & Queue NDVI Scan'),
                style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.teal, foregroundColor: Colors.white),
              ),
            ]);
          }),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Registered Farm Parcels Ledger (${_farms.length} Parcels)',
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _farms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final fm = _farms[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(fm['parcelId'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(
                      children: [
                        _StatusChip(label: fm['ndvi'], color: GovernmentPage.green),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.satellite_alt_outlined, size: 18, color: GovernmentPage.teal),
                          tooltip: 'Inspect NDVI Satellite Scan',
                          onPressed: () => _showNdviInspectionModal(context, fm),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text('Farmer: ${fm['farmerName']} (${fm['farmerId']})', style: const TextStyle(fontSize: 12, color: GovernmentPage.dark)),
                  Text('${fm['boundary']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                  Text('Soil: ${fm['soilType']}  •  Elevation: ${fm['elevation']}  •  Water: ${fm['waterSource']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                  Text('Land Use: ${fm['landUse']}  •  Province: ${fm['province']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                  Text('Registered by: ${fm['registeredBy']} on ${fm['registeredDate']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: EXTENSION OFFICERS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildExtensionOfficersTab() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final districtCtrl = TextEditingController();
    final wardsCtrl = TextEditingController();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Extension Officers Management', icon: Icons.support_agent_outlined, color: GovernmentPage.purple),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 800 ? 4 : 2;
          return Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Total Officers', value: '${_officers.length}', icon: Icons.badge_outlined, color: GovernmentPage.purple),
              _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Farmers Supported', value: '${_officers.fold(0, (s, o) => s + (o['farmersSupported'] as int))}', icon: Icons.people_outlined, color: GovernmentPage.green),
              _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Training Sessions', value: '${_officers.fold(0, (s, o) => s + (o['trainingSessions'] as int))}', icon: Icons.school_outlined, color: GovernmentPage.blue),
              _KpiCard(width: (c.maxWidth - 12 * (cols - 1)) / cols, label: 'Active Officers', value: '${_officers.where((o) => o['status'] == 'Active').length}', icon: Icons.check_circle_outline, color: GovernmentPage.teal),
            ],
          );
        }),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Register New Extension Officer',
          child: StatefulBuilder(builder: (ctx, setS) {
            String selectedProvince = 'Manicaland';
            String selectedSpec = 'Horticulture & Export Crops';
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', hintText: '+263 77 xxx xxxx'))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: selectedProvince,
                  decoration: const InputDecoration(labelText: 'Province'),
                  items: ['Manicaland', 'Mashonaland Central', 'Mashonaland East', 'Matabeleland South', 'Midlands', 'Masvingo'].map((p) =>
                      DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setS(() => selectedProvince = v ?? selectedProvince),
                )),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: districtCtrl, decoration: const InputDecoration(labelText: 'District Assignment'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: wardsCtrl, decoration: const InputDecoration(labelText: 'Wards (comma separated)', hintText: 'Ward 12, 13'))),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSpec,
                decoration: const InputDecoration(labelText: 'Specialization'),
                items: ['Horticulture & Export Crops', 'Dryland Grain & Livestock', 'Irrigation & Soil Health', 'Livestock & Veterinary Liaison', 'Coffee & Tea Plantation', 'Climate-Smart Agriculture'].map((s) =>
                    DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setS(() => selectedSpec = v ?? selectedSpec),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;
                  setState(() {
                    _officers.add({
                      'id': 'EXT-${100 + _officers.length}',
                      'name': nameCtrl.text.trim(), 'province': selectedProvince,
                      'district': districtCtrl.text.trim(), 'wards': wardsCtrl.text.trim(),
                      'farmersSupported': 0, 'trainingSessions': 0,
                      'lastFieldVisit': 'Not yet deployed', 'status': 'Active',
                      'phone': phoneCtrl.text.trim(), 'specialization': selectedSpec,
                    });
                  });
                  nameCtrl.clear(); phoneCtrl.clear(); districtCtrl.clear(); wardsCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registered Extension Officer to Field Roster.'), backgroundColor: GovernmentPage.purple),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Register Extension Officer'),
                style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.purple, foregroundColor: Colors.white),
              ),
            ]);
          }),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Extension Officer Field Roster',
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _officers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final o = _officers[i];
              final isActive = o['status'] == 'Active';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: GovernmentPage.purple.withOpacity(0.1),
                      child: Text(o['name'].toString().substring(0, 1), style: const TextStyle(color: GovernmentPage.purple, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(o['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          _StatusChip(label: o['status'], color: isActive ? GovernmentPage.green : GovernmentPage.orange),
                        ]),
                        const SizedBox(height: 4),
                        Text('ID: ${o['id']}  •  ${o['phone']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                        Text('${o['province']}, ${o['district']}  •  ${o['wards']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                        Text('Specialization: ${o['specialization']}', style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                        Text('Farmers supported: ${o['farmersSupported']}  •  Training sessions: ${o['trainingSessions']}  •  Last visit: ${o['lastFieldVisit']}',
                            style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
                      ]),
                    ),
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.add_task_outlined, size: 18, color: GovernmentPage.blue),
                        tooltip: 'Log Field Visit',
                        onPressed: () {
                          setState(() {
                            o['lastFieldVisit'] = 'Today';
                            o['trainingSessions'] = (o['trainingSessions'] as int) + 1;
                            o['farmersSupported'] = (o['farmersSupported'] as int) + 5;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged field visit for ${o['name']}'), backgroundColor: GovernmentPage.green),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_outlined, size: 18, color: GovernmentPage.green),
                        tooltip: 'Contact Officer',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Contact ${o['name']}'),
                              content: Text('Phone: ${o['phone']}\nDistrict: ${o['district']}\nWards: ${o['wards']}'),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                            ),
                          );
                        },
                      ),
                    ]),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: SUBSIDIES & G2F ADVISORY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSubsidiesTab() {
    final subjectCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String region = 'Mazowe Valley';
    String lang = 'Shona';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Input Subsidies & G2F Advisory Broadcasts', icon: Icons.wallet_outlined, color: GovernmentPage.orange),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'E-Voucher Input Subsidy Platform',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Digitally allocate subsidized seeds, fertilizers, and tools to verified farmer mobile wallets.', style: TextStyle(fontSize: 12.5, color: GovernmentPage.muted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showIssueVoucherModal(context),
              icon: const Icon(Icons.card_giftcard_outlined),
              label: const Text('Issue New Input Subsidy Voucher'),
              style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.orange, foregroundColor: Colors.white),
            ),
            const Divider(height: 24),
            Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1.2)},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: GovernmentPage.orange.withOpacity(0.08)),
                  children: ['Voucher ID', 'Farmer', 'Inputs', 'Value', 'Status'].map((h) =>
                      Padding(padding: const EdgeInsets.all(8), child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))).toList(),
                ),
                ..._vouchers.map((v) => TableRow(children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text(v['id'], style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(v['farmer'], style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(v['inputs'], style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(v['value'], style: const TextStyle(fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: _StatusChip(label: v['status'], color: v['status'] == 'Redeemed' ? GovernmentPage.green : GovernmentPage.blue)),
                ])),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Digital Extension Advisory Broadcasts (SMS/USSD/WhatsApp)',
          child: StatefulBuilder(builder: (ctx, setS) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Advisory Subject', hintText: 'e.g. Frost Risk Warning')),
              const SizedBox(height: 12),
              TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Advisory Message', hintText: 'Type advisory text...')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: region,
                  decoration: const InputDecoration(labelText: 'Target Region'),
                  items: ['Mazowe Valley', 'Plumtree West', 'Nyanga North', 'Masvingo South', 'All Provinces'].map((r) =>
                      DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setS(() => region = v ?? region),
                )),
                const SizedBox(width: 16),
                Expanded(child: DropdownButtonFormField<String>(
                  value: lang,
                  decoration: const InputDecoration(labelText: 'Broadcast Language'),
                  items: ['Shona', 'Ndebele', 'English', 'Shona & English', 'Ndebele & English'].map((l) =>
                      DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (v) => setS(() => lang = v ?? lang),
                )),
              ]),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (subjectCtrl.text.isEmpty || msgCtrl.text.isEmpty) return;
                  setState(() {
                    _advisories.add({'subject': subjectCtrl.text.trim(), 'message': msgCtrl.text.trim(), 'region': region, 'lang': lang, 'sentBy': 'Gov. Admin Portal'});
                  });
                  subjectCtrl.clear(); msgCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Broadcasted Advisory SMS alert to farmers in target region.'), backgroundColor: GovernmentPage.green),
                  );
                },
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Broadcast Advisory Alert'),
                style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
              ),
              const Divider(height: 24),
              ..._advisories.map((a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.campaign_outlined, color: GovernmentPage.green),
                title: Text(a['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${a['message']}  •  [${a['region']} | ${a['lang']}]  •  Sent by: ${a['sentBy']}'),
              )),
            ]);
          }),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 6: BIOSECURITY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBiosecurityTab() {
    final pestCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final officerCtrl = TextEditingController();
    String severity = 'High';
    String type = 'Crop';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Pest, Disease & Biosecurity Control', icon: Icons.bug_report_outlined, color: GovernmentPage.red),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Report New Pest / Disease Outbreak (Geo-tagged)',
          child: StatefulBuilder(builder: (ctx, setS) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: TextField(controller: pestCtrl, decoration: const InputDecoration(labelText: 'Disease or Pest Name', hintText: 'e.g. Fall Armyworm Infestation'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Geo-tagged Location', hintText: 'e.g. Domboshava Fields Block B'))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Crop', 'Livestock', 'Poultry', 'Storage'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setS(() => type = v ?? type),
                )),
                const SizedBox(width: 16),
                Expanded(child: DropdownButtonFormField<String>(
                  value: severity,
                  decoration: const InputDecoration(labelText: 'Severity Level'),
                  items: ['Critical', 'High', 'Moderate', 'Low'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setS(() => severity = v ?? severity),
                )),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: officerCtrl, decoration: const InputDecoration(labelText: 'Responding Officer'))),
              ]),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (pestCtrl.text.isEmpty || locCtrl.text.isEmpty) return;
                  setState(() {
                    _outbreaks.insert(0, {
                      'id': 'OUT-${200 + DateTime.now().millisecond}',
                      'pest': pestCtrl.text.trim(), 'type': type,
                      'location': locCtrl.text.trim(), 'severity': severity,
                      'date': 'Today, just now', 'status': 'Quarantine Review',
                      'affectedHa': 0, 'respondingOfficer': officerCtrl.text.isEmpty ? 'Unassigned' : officerCtrl.text.trim(),
                    });
                  });
                  pestCtrl.clear(); locCtrl.clear(); officerCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Raised Quarantine Alert & dispatched biosecurity unit.'), backgroundColor: GovernmentPage.red),
                  );
                },
                icon: const Icon(Icons.warning_amber_outlined),
                label: const Text('Raise Quarantine Alert'),
                style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.red, foregroundColor: Colors.white),
              ),
              const Divider(height: 24),
              ..._outbreaks.map((o) {
                final severityColor = o['severity'] == 'Critical' ? GovernmentPage.red : o['severity'] == 'High' ? GovernmentPage.orange : GovernmentPage.blue;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: severityColor.withOpacity(0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(o['pest'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Row(children: [
                        _StatusChip(label: o['type'], color: GovernmentPage.blue),
                        const SizedBox(width: 6),
                        _StatusChip(label: o['severity'], color: severityColor),
                      ]),
                    ]),
                    const SizedBox(height: 6),
                    Text('Location: ${o['location']}  •  Date: ${o['date']}  •  Status: ${o['status']}', style: const TextStyle(fontSize: 12, color: GovernmentPage.muted)),
                    if ((o['affectedHa'] as int) > 0)
                      Text('Affected Area: ${o['affectedHa']} Ha  •  Officer: ${o['respondingOfficer']}', style: const TextStyle(fontSize: 12, color: GovernmentPage.muted)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => o['status'] = 'Quarantine Active & Enforced');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enforced quarantine for ${o['pest']} at ${o['location']}'), backgroundColor: GovernmentPage.red),
                        );
                      },
                      icon: const Icon(Icons.gavel, size: 14),
                      label: const Text('Enforce Quarantine', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.red, foregroundColor: Colors.white),
                    ),
                  ]),
                );
              }),
            ]);
          }),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 7: TRADE, PRICE MONITORING & ePHYTO CUSTOMS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTradeTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(title: 'Trade Corridors, Price Monitoring & ePhyto Customs', icon: Icons.price_change_outlined, color: GovernmentPage.teal),
        const SizedBox(height: 16),
        // Price Monitoring
        _SectionCard(
          title: 'National Commodity Price Monitor (Real-Time)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdatePriceModal(context),
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Update Commodity Price'),
                  style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.teal, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.2), 3: FlexColumnWidth(1.2), 4: FlexColumnWidth(1)},
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: GovernmentPage.teal.withOpacity(0.08)),
                    children: ['Commodity', 'Province', 'Wholesale', 'Retail', 'Change'].map((h) =>
                        Padding(padding: const EdgeInsets.all(10), child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))).toList(),
                  ),
                  ..._prices.map((p) => TableRow(children: [
                    Padding(padding: const EdgeInsets.all(10), child: Text(p['commodity'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Padding(padding: const EdgeInsets.all(10), child: Text(p['province'], style: const TextStyle(fontSize: 12))),
                    Padding(padding: const EdgeInsets.all(10), child: Text(p['wholesale'], style: const TextStyle(fontSize: 12))),
                    Padding(padding: const EdgeInsets.all(10), child: Text(p['retail'], style: const TextStyle(fontSize: 12))),
                    Padding(padding: const EdgeInsets.all(10), child: Row(children: [
                      Icon(p['up'] ? Icons.trending_up : Icons.trending_down, size: 14,
                          color: p['up'] ? GovernmentPage.green : GovernmentPage.red),
                      const SizedBox(width: 4),
                      Text(p['change'], style: TextStyle(fontSize: 12, color: p['up'] ? GovernmentPage.green : GovernmentPage.red, fontWeight: FontWeight.bold)),
                    ])),
                  ])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // ePhyto
        _SectionCard(
          title: 'ePhyto Digital Certification & Border Clearance Portal (Beitbridge | Forbes)',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Verify AMA exporter licenses, SAZ compliance dossiers, and clear shipments for the South Corridor (Beitbridge → Durban) and East Corridor (Forbes → Beira).', style: TextStyle(fontSize: 12.5, color: GovernmentPage.muted)),
            const Divider(height: 24),
            ..._dossiers.map((d) {
              final isCleared = d['phytoStatus'] == 'Cleared';
              final isOnHold = d['phytoStatus'] == 'On Hold';
              final phytoColor = isCleared ? GovernmentPage.green : isOnHold ? GovernmentPage.red : GovernmentPage.orange;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(d['consignmentId'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    _StatusChip(label: d['phytoStatus'], color: phytoColor),
                  ]),
                  const SizedBox(height: 8),
                  Table(columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)}, children: [
                    _tableRow('Exporter:', d['exporter']),
                    _tableRow('Crop / HS Code:', '${d['crop']}  —  ${d['hsCode']}'),
                    _tableRow('Weight:', '${d['weightKg']} kg'),
                    _tableRow('Border Post:', d['border']),
                    _tableRow('Destination:', d['destination']),
                    _tableRow('AMA License:', d['amaStatus']),
                    _tableRow('SAZ Compliance:', d['sazStatus']),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (!isCleared)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => d['phytoStatus'] = 'Cleared'),
                        icon: const Icon(Icons.verified_outlined, size: 14),
                        label: const Text('Issue ePhyto Clearance Certificate', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
                      ),
                    if (!isCleared) const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final file = await AnalyticsExportService.exportOrderSummary(orders: [
                            {
                              'id': d['consignmentId'],
                              'buyer': d['destination'],
                              'product': d['crop'],
                              'quantity': '${d['weightKg']} Kg',
                              'destination': d['border'],
                              'status': d['phytoStatus'],
                              'payment': 'AMA & SAZ Verified',
                              'total': '0.00',
                              'date': '2026-07-24',
                              'eta': 'Cleared',
                              'priority': 'Customs High Priority',
                            }
                          ]);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Exported Phytosanitary PDF to ${file.path}'), backgroundColor: GovernmentPage.green),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PDF Export: $e'), backgroundColor: GovernmentPage.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
                      label: const Text('Download Dossier PDF', style: TextStyle(fontSize: 11)),
                    ),
                  ]),
                ]),
              );
            }),
          ]),
        ),
      ],
    );
  }

  TableRow _tableRow(String label, String value) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(label, style: const TextStyle(fontSize: 12, color: GovernmentPage.muted, fontWeight: FontWeight.w600))),
      Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(value, style: const TextStyle(fontSize: 12))),
    ]);
  }

  // --- MODAL DIALOGS ---

  void _showEmergencyReliefModal(BuildContext context) {
    final qtyCtrl = TextEditingController(text: '5000');
    String province = 'Masvingo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dispatch Emergency Grain Relief', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: province,
              decoration: const InputDecoration(labelText: 'Target Province'),
              items: ['Masvingo', 'Matabeleland South', 'Manicaland', 'Midlands'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) { if (v != null) province = v; },
            ),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Maize Quantity (Tonnes)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dispatched ${qtyCtrl.text} tonnes emergency grain to $province.'), backgroundColor: GovernmentPage.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
            child: const Text('Dispatch Relief'),
          ),
        ],
      ),
    );
  }

  void _showFarmerDossierModal(BuildContext context, Map<String, dynamic> farmer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('National Farmer Digital Passport', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${farmer['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('National ID: ${farmer['nationalId']}'),
            Text('Farmer ID: ${farmer['id']}'),
            Text('Province/Ward: ${farmer['province']}, ${farmer['ward']}'),
            Text('Registered Crops: ${farmer['crops']}'),
            Text('Land Parcel Size: ${farmer['landHa']} Ha'),
            Text('Mobile Wallet: ${farmer['wallet']}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: GovernmentPage.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('KYC Status: ${farmer['status']} (AMA & Ministry Verified)', style: const TextStyle(color: GovernmentPage.green, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showNdviInspectionModal(BuildContext context, Map<String, dynamic> farm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Satellite NDVI Inspection: ${farm['parcelId']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer: ${farm['farmerName']} (${farm['farmerId']})'),
            Text('GPS Coordinates: ${farm['boundary']}'),
            Text('Soil Type: ${farm['soilType']}'),
            Text('Water Source: ${farm['waterSource']}'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.satellite_alt, color: GovernmentPage.teal),
                const SizedBox(width: 8),
                Text('Sentinel-2 NDVI Score: ${farm['ndvi']}', style: const TextStyle(fontWeight: FontWeight.bold, color: GovernmentPage.teal)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showIssueVoucherModal(BuildContext context) {
    String selectedFarmer = _farmers.isNotEmpty ? _farmers.first['name'] : 'Tendai Chigodora';
    final valCtrl = TextEditingController(text: '50.00');
    final inputsCtrl = TextEditingController(text: 'Basal Fertilizer (50kg), Certified Hybrid Seed (10kg)');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Issue E-Voucher Input Subsidy', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedFarmer,
              decoration: const InputDecoration(labelText: 'Beneficiary Farmer'),
              items: _farmers.map((f) => DropdownMenuItem(value: f['name'].toString(), child: Text(f['name'].toString()))).toList(),
              onChanged: (v) { if (v != null) selectedFarmer = v; },
            ),
            TextField(controller: inputsCtrl, decoration: const InputDecoration(labelText: 'Allocated Inputs Package')),
            TextField(controller: valCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Subsidized Value (US\$)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _vouchers.add({
                  'id': 'VCH-${900 + DateTime.now().millisecond}',
                  'farmer': selectedFarmer,
                  'inputs': inputsCtrl.text,
                  'value': '\$${valCtrl.text}',
                  'status': 'Distributed',
                  'season': '2025 A',
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Issued E-Voucher to $selectedFarmer'), backgroundColor: GovernmentPage.orange),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.orange, foregroundColor: Colors.white),
            child: const Text('Issue Voucher'),
          ),
        ],
      ),
    );
  }

  void _showUpdatePriceModal(BuildContext context) {
    String commodity = _prices.first['commodity'];
    final wholesaleCtrl = TextEditingController(text: '220');
    final retailCtrl = TextEditingController(text: '0.28');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update National Commodity Price', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: commodity,
              decoration: const InputDecoration(labelText: 'Commodity'),
              items: _prices.map((p) => DropdownMenuItem(value: p['commodity'].toString(), child: Text(p['commodity'].toString()))).toList(),
              onChanged: (v) { if (v != null) commodity = v; },
            ),
            TextField(controller: wholesaleCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Wholesale Price (\$/Ton)')),
            TextField(controller: retailCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Retail Price (\$/Kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final target = _prices.firstWhere((p) => p['commodity'] == commodity);
                target['wholesale'] = '\$${wholesaleCtrl.text}/t';
                target['retail'] = '\$${retailCtrl.text}/kg';
                target['change'] = '+1.8%';
                target['up'] = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Updated national price for $commodity'), backgroundColor: GovernmentPage.teal),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.teal, foregroundColor: Colors.white),
            child: const Text('Publish Price'),
          ),
        ],
      ),
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
      Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16, color: GovernmentPage.dark))),
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
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: GovernmentPage.dark)),
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
          Text(label, style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: GovernmentPage.dark)),
        ])),
      ]),
    );
  }
}

class _WarningItem extends StatelessWidget {
  final String title;
  final String desc;
  final String level;
  final Color color;
  final VoidCallback? onAction;
  const _WarningItem({required this.title, required this.desc, required this.level, required this.color, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Text(level, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color)),
          ]),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: GovernmentPage.muted)),
          if (onAction != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
              child: const Text('Take Action', style: TextStyle(fontSize: 11)),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}