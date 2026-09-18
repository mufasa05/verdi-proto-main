import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:latlong2/latlong.dart' hide Path;
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NATIONAL AGRICULTURAL ADMINISTRATION CONSOLE
// Pixel-perfect sovereign government dashboard matching exact wireframe.
// 7-Tab Portal: Food Security | Farmer Registry | Farm Registration |
//   Extension Officers | Subsidies & Advisory | Biosecurity | Trade & Prices
// ─────────────────────────────────────────────────────────────────────────────

class _GrainChartData {
  final String date;
  final double tons;
  _GrainChartData(this.date, this.tons);
}

class GovernmentPage extends ConsumerStatefulWidget {
  final int initialTab;
  const GovernmentPage({super.key, this.initialTab = 0});

  // ── SOVEREIGN PALETTE ──────────────────────────────────────────────────────
  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF15803D);
  static const dark = Color(0xFF0F172A);
  static const darkBg = Color(0xFF070B14);
  static const surface = Color(0xFF0F1629);
  static const surfaceLight = Color(0xFF151D33);
  static const border = Color(0xFF1E293B);
  static const borderLight = Color(0xFF334155);
  static const slate = Color(0xFF334155);
  static const muted = Color(0xFF64748B);
  static const mutedLight = Color(0xFF94A3B8);
  static const teal = Color(0xFF0D9488);
  static const purple = Color(0xFF7C3AED);
  static const red = Color(0xFFEF4444);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const amber = Color(0xFFF59E0B);
  static const gold = Color(0xFFD4A017);
  static const cyan = Color(0xFF06B6D4);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<GovernmentPage> createState() => _GovernmentPageState();
}

class _GovernmentPageState extends ConsumerState<GovernmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  String _selectedTimeRange = '30D';
  String _selectedAlertFilter = 'All';
  String _selectedScope = 'National Overview';

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
    {'id': 'EXT-0021', 'name': 'Evelyn Moyo', 'province': 'Manicaland', 'district': 'Mutare', 'wards': 'Ward 12, 13, 14', 'farmersSupported': 142, 'phone': '+263 77 201 3344', 'status': 'Active', 'verified': true, 'specialization': 'Horticulture & Export Crops'},
    {'id': 'EXT-0022', 'name': 'Solomon Sibanda', 'province': 'Matabeleland South', 'district': 'Plumtree', 'wards': 'Ward 3, 4, 5', 'farmersSupported': 87, 'phone': '+263 71 490 8823', 'status': 'Active', 'verified': true, 'specialization': 'Dryland Grain & Livestock'},
    {'id': 'EXT-0023', 'name': 'Tatenda Mushonga', 'province': 'Mashonaland Central', 'district': 'Mazowe', 'wards': 'Ward 7, 8', 'farmersSupported': 210, 'phone': '+263 78 112 5599', 'status': 'Active', 'verified': true, 'specialization': 'Irrigation & Soil Health'},
    {'id': 'EXT-0024', 'name': 'Alice Dube', 'province': 'Midlands', 'district': 'Gweru', 'wards': 'Ward 2', 'farmersSupported': 56, 'phone': '+263 77 340 1122', 'status': 'On Leave', 'verified': true, 'specialization': 'Livestock & Veterinary Liaison'},
  ];

  // ── 4. BIOSECURITY STATE & FORM CONTROLLERS ────────────────────────────────
  final _outbreakPestCtrl = TextEditingController();
  final _outbreakLocCtrl = TextEditingController();
  final _outbreakOfficerCtrl = TextEditingController();
  String _outbreakType = 'Crop';
  String _outbreakSeverity = 'High';

  final List<Map<String, dynamic>> _outbreaks = [
    {'id': 'OUT-102', 'pest': 'Fall Armyworm Infestation', 'type': 'Crop', 'location': 'Domboshava Fields', 'severity': 'Critical', 'date': 'Today, 08:30', 'status': 'Quarantine Ordered', 'affectedHa': 340, 'officer': 'Evelyn Moyo'},
    {'id': 'OUT-103', 'pest': 'Foot and Mouth Disease Alert', 'type': 'Livestock', 'location': 'Gwanda Southern Corridors', 'severity': 'High', 'date': 'Yesterday, 14:15', 'status': 'Vaccination Dispatched', 'affectedHa': 0, 'officer': 'Alice Dube'},
    {'id': 'OUT-104', 'pest': 'Tobacco Mosaic Virus', 'type': 'Crop', 'location': 'Rusape East', 'severity': 'Moderate', 'date': '2 days ago', 'status': 'Monitoring Active', 'affectedHa': 85, 'officer': 'Tatenda Mushonga'},
  ];

  // ── 5. TRADE & PRICES STATE ─────────────────────────────────────────────────
  final List<Map<String, dynamic>> _prices = [
    {'commodity': 'Maize (white)', 'province': 'Harare', 'wholesale': '\$210/t', 'retail': '\$0.25/kg', 'change': '+3.2%', 'up': true},
    {'commodity': 'Tomatoes', 'province': 'Mutare', 'wholesale': '\$320/t', 'retail': '\$0.38/kg', 'change': '-1.5%', 'up': false},
    {'commodity': 'Sugar Beans', 'province': 'Bulawayo', 'wholesale': '\$580/t', 'retail': '\$0.65/kg', 'change': '+5.8%', 'up': true},
    {'commodity': 'Sorghum', 'province': 'Gwanda', 'wholesale': '\$180/t', 'retail': '\$0.22/kg', 'change': '+0.4%', 'up': true},
    {'commodity': 'Blueberries', 'province': 'Nyanga', 'wholesale': '\$4200/t', 'retail': '\$5.20/kg', 'change': '+12.1%', 'up': true},
    {'commodity': 'Avocados', 'province': 'Mutare', 'wholesale': '\$850/t', 'retail': '\$1.10/kg', 'change': '-2.0%', 'up': false},
  ];

  final List<Map<String, dynamic>> _consignments = [
    {'id': 'EXP-PEAS-9921', 'crop': 'Sugar Snap Peas', 'exporter': 'Eastern Highlands Growers', 'weightKg': 8400, 'destination': 'Rotterdam, Netherlands (EU)', 'border': 'Forbes Border Post', 'amaStatus': 'Valid', 'phytoStatus': 'Pending Clearance', 'hash': '0x7e8b91a0c4f2e9198d02ab41fa9c'},
    {'id': 'EXP-BLUE-3310', 'crop': 'Fresh Blueberries', 'exporter': 'Mazowe Berry Estates', 'weightKg': 4200, 'destination': 'London Heathrow, UK', 'border': 'Beitbridge Border Post', 'amaStatus': 'Valid', 'phytoStatus': 'Cleared & Sealed', 'hash': '0x3a91c89012beef71940bcad18299'},
  ];

  // ── 6. FOOD SECURITY DATA ──────────────────────────────────────────────────
  final int _maizeReserveTons = 420000;
  final int _wheatReserveTons = 180000;
  final int _sorghumReserveTons = 82000;

  // Grain chart data (last 30 days)
  final List<_GrainChartData> _maizeChartData = [
    _GrainChartData('Aug 04', 385), _GrainChartData('Aug 07', 392),
    _GrainChartData('Aug 11', 398), _GrainChartData('Aug 14', 402),
    _GrainChartData('Aug 18', 405), _GrainChartData('Aug 21', 408),
    _GrainChartData('Aug 25', 410), _GrainChartData('Aug 28', 412),
    _GrainChartData('Sep 01', 415), _GrainChartData('Sep 04', 418),
    _GrainChartData('Sep 08', 420),
  ];
  final List<_GrainChartData> _wheatChartData = [
    _GrainChartData('Aug 04', 172), _GrainChartData('Aug 07', 174),
    _GrainChartData('Aug 11', 175), _GrainChartData('Aug 14', 176),
    _GrainChartData('Aug 18', 177), _GrainChartData('Aug 21', 178),
    _GrainChartData('Aug 25', 178), _GrainChartData('Aug 28', 179),
    _GrainChartData('Sep 01', 179), _GrainChartData('Sep 04', 180),
    _GrainChartData('Sep 08', 180),
  ];
  final List<_GrainChartData> _sorghumChartData = [
    _GrainChartData('Aug 04', 96), _GrainChartData('Aug 07', 94),
    _GrainChartData('Aug 11', 93), _GrainChartData('Aug 14', 91),
    _GrainChartData('Aug 18', 90), _GrainChartData('Aug 21', 88),
    _GrainChartData('Aug 25', 87), _GrainChartData('Aug 28', 85),
    _GrainChartData('Sep 01', 84), _GrainChartData('Sep 04', 83),
    _GrainChartData('Sep 08', 82),
  ];

  // Dam telemetry data with real GPS coordinates
  final List<Map<String, dynamic>> _dams = [
    {'name': 'Lake Kariba Basin', 'level': 65.2, 'volume': '28,012 Mm³', 'capacity': 'of 42,300 Mm³', 'trend': 'Stable', 'lat': -16.5225, 'lng': 28.7583, 'statusColor': 0xFF16A34A},
    {'name': 'Mazowe Dam Complex', 'level': 88.5, 'volume': '438 Mm³', 'capacity': 'of 495 Mm³', 'trend': 'High', 'lat': -17.4933, 'lng': 31.0522, 'statusColor': 0xFF2563EB},
    {'name': 'Lake Mutirikwi (Masvingo)', 'level': 72.4, 'volume': '856 Mm³', 'capacity': 'of 1,183 Mm³', 'trend': 'Stable', 'lat': -20.1667, 'lng': 30.8667, 'statusColor': 0xFF16A34A},
    {'name': 'Osborne Dam (Manicaland)', 'level': 61.0, 'volume': '410 Mm³', 'capacity': 'of 672 Mm³', 'trend': 'Stable', 'lat': -19.5667, 'lng': 32.4167, 'statusColor': 0xFF16A34A},
    {'name': 'Manyame Dam', 'level': 54.0, 'volume': '736 Mm³', 'capacity': 'of 1,361 Mm³', 'trend': 'Monitor', 'lat': -17.8500, 'lng': 30.7167, 'statusColor': 0xFFF59E0B},
    {'name': 'Chivero Dam', 'level': 48.0, 'volume': '204 Mm³', 'capacity': 'of 425 Mm³', 'trend': 'Watch', 'lat': -17.9000, 'lng': 30.8000, 'statusColor': 0xFFEF4444},
  ];

  // Risk scores per province
  final Map<String, int> _riskScores = {
    'Masvingo': 72,
    'Matabeleland South': 65,
    'Manicaland': 58,
    'Midlands': 46,
    'Mashonaland East': 42,
    'Mashonaland West': 35,
    'Mashonaland Central': 28,
    'Matabeleland North': 44,
    'Harare': 22,
    'Bulawayo': 38,
  };

  // Crop production outlook
  final List<Map<String, dynamic>> _cropOutlook = [
    {'crop': 'Maize', 'change': 12, 'up': true, 'volume': '2.1 MT', 'icon': Icons.grass_rounded},
    {'crop': 'Wheat', 'change': 8, 'up': true, 'volume': '420K MT', 'icon': Icons.grain_rounded},
    {'crop': 'Tobacco', 'change': 5, 'up': false, 'volume': '295K MT', 'icon': Icons.local_florist_rounded},
    {'crop': 'Horticulture', 'change': 15, 'up': true, 'volume': '1.3M MT', 'icon': Icons.eco_rounded},
    {'crop': 'Soya Beans', 'change': 10, 'up': true, 'volume': '310K MT', 'icon': Icons.spa_rounded},
  ];

  // Alerts & actions
  final List<Map<String, dynamic>> _actionAlerts = [
    {'title': 'High drought risk – Masvingo Province', 'desc': 'Below average rainfall forecast for Oct - Dec 2025', 'time': '2 hours ago', 'severity': 'High', 'action': 'View Alert', 'category': 'Drought'},
    {'title': 'Fall Armyworm outbreak reported', 'desc': 'New cases in Chimanimani and Chipinge', 'time': '5 hours ago', 'severity': 'Medium', 'action': 'Dispatch Officer', 'category': 'Pests'},
    {'title': 'Chivero Dam below 50%', 'desc': 'Currently at 48% capacity', 'time': '8 hours ago', 'severity': 'Medium', 'action': 'Open Report', 'category': 'Water'},
    {'title': 'Maize prices increasing', 'desc': '12% increase in major markets this month', 'time': '1 day ago', 'severity': 'Info', 'action': 'View Report', 'category': 'Markets'},
  ];

  // ── 7. SUBSIDIES STATE ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _vouchers = [
    {'id': 'VCH-882', 'farmer': 'Tendai Chigodora', 'inputs': 'Maize Seed (25kg), Compound D Fertilizer (50kg)', 'value': '\$42.00', 'status': 'Distributed'},
    {'id': 'VCH-883', 'farmer': 'Nomsa Ndlovu', 'inputs': 'Sorghum Seed (10kg), Ammonium Nitrate (50kg)', 'value': '\$28.50', 'status': 'Redeemed'},
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 6),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
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
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _loading = false);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GovernmentPage.darkBg,
        cardColor: GovernmentPage.surface,
        dividerColor: GovernmentPage.border,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      child: Scaffold(
        backgroundColor: GovernmentPage.darkBg,
        body: Column(
          children: [
            _buildSovereignHeader(context),
            _buildNavTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFoodSecurityTab(),
                  _buildFarmerRegistryTab(),
                  _buildFarmRegistrationTab(),
                  _buildExtensionOfficersTab(),
                  _buildSubsidiesTab(),
                  _buildBiosecurityTab(),
                  _buildTradeTab(),
                ],
              ),
            ),
            _buildFooterBar(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOVEREIGN HEADER BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSovereignHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        border: Border(bottom: BorderSide(color: GovernmentPage.border, width: 1)),
      ),
      child: Row(
        children: [
          // Coat of arms emblem
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A472A), Color(0xFF0D331A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: GovernmentPage.gold, width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.shield_rounded, color: GovernmentPage.gold, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          // Ministry title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GOVERNMENT OF ZIMBABWE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: GovernmentPage.gold, letterSpacing: 1.5)),
              Text('Ministry of Lands, Agriculture, Fisheries,\nWater and Rural Development', style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w500, color: GovernmentPage.mutedLight, height: 1.3)),
            ],
          ),
          Container(width: 1, height: 36, margin: const EdgeInsets.symmetric(horizontal: 14), color: GovernmentPage.border),
          // Console title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('National Agricultural Administration Console', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('Food Secure Zimbabwe  •  Productive Farmers  •  Prosperous Communities', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GovernmentPage.green)),
              ],
            ),
          ),
          // Search bar
          Container(
            width: 220,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: GovernmentPage.darkBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GovernmentPage.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(Icons.search_rounded, size: 15, color: GovernmentPage.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Search systems, data, reports...', style: GoogleFonts.inter(fontSize: 10.5, color: GovernmentPage.muted, fontWeight: FontWeight.w500)),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: GovernmentPage.border, borderRadius: BorderRadius.circular(4)),
                  child: Text('Ctrl+K', style: GoogleFonts.inter(fontSize: 9, color: GovernmentPage.mutedLight, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Live data badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: GovernmentPage.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GovernmentPage.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: GovernmentPage.green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Live Data', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: GovernmentPage.green)),
              ],
            ),
          ),
          // Notification bell
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Sovereign Alerts',
                onPressed: () => _showNotificationCenterModal(context),
                icon: const Icon(Icons.notifications_active_rounded, color: GovernmentPage.mutedLight, size: 20),
                constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
                padding: EdgeInsets.zero,
              ),
              Positioned(
                right: 2, top: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: GovernmentPage.red, shape: BoxShape.circle),
                  child: Text('3', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          // User avatar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: GovernmentPage.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GovernmentPage.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: GovernmentPage.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: GovernmentPage.green, width: 1.5),
                  ),
                  child: Center(child: Text('PS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: GovernmentPage.green))),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Prince A. Shumba', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('National Administrator', style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Zimbabwe banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A472A), Color(0xFF0D331A)]),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovernmentPage.gold.withValues(alpha: 0.4)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ZIMBABWE', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: GovernmentPage.gold, letterSpacing: 2)),
                Text('FEEDS TOMORROW', style: GoogleFonts.inter(fontSize: 7.5, fontWeight: FontWeight.w700, color: GovernmentPage.green, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGATION TAB BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildNavTabBar() {
    const tabData = [
      {'icon': Icons.grid_view_rounded, 'label': 'Food Security'},
      {'icon': Icons.person_pin_rounded, 'label': 'Farmer Registry'},
      {'icon': Icons.map_rounded, 'label': 'Farm Registration'},
      {'icon': Icons.support_agent_rounded, 'label': 'Extension Officers'},
      {'icon': Icons.card_giftcard_rounded, 'label': 'Subsidies & Advisory'},
      {'icon': Icons.bug_report_rounded, 'label': 'Biosecurity'},
      {'icon': Icons.show_chart_rounded, 'label': 'Trade & Prices'},
    ];
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        border: Border(bottom: BorderSide(color: GovernmentPage.border, width: 1)),
      ),
      child: Row(
        children: List.generate(tabData.length, (i) {
          final isActive = _tabController.index == i;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _tabController.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? GovernmentPage.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tabData[i]['icon'] as IconData, size: 14, color: isActive ? Colors.white : GovernmentPage.muted),
                    const SizedBox(width: 6),
                    Text(tabData[i]['label'] as String, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600, color: isActive ? Colors.white : GovernmentPage.muted)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: FOOD SECURITY COMMAND CENTER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFoodSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCommandSubHeader(),
        const SizedBox(height: 16),
        _buildKpiRow(),
        const SizedBox(height: 16),
        _buildMiddleRow(),
        const SizedBox(height: 16),
        _buildBottomRow(),
      ],
    );
  }

  // ── COMMAND SUB-HEADER ─────────────────────────────────────────────────────
  Widget _buildCommandSubHeader() {
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(_now);
    final timeStr = DateFormat('HH:mm').format(_now);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('National Food Security Command Center', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Real-time monitoring for a food secure and resilient Zimbabwe', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
              ],
            ),
          ),
          // Date + Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: GovernmentPage.surfaceLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: GovernmentPage.border)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 13, color: GovernmentPage.muted),
                const SizedBox(width: 6),
                Text(dateStr, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: GovernmentPage.mutedLight)),
                Container(width: 1, height: 16, margin: const EdgeInsets.symmetric(horizontal: 8), color: GovernmentPage.border),
                Text(timeStr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(width: 4),
                Text('CAT', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: GovernmentPage.muted)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Weather
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: GovernmentPage.surfaceLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: GovernmentPage.border)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wb_sunny_rounded, size: 16, color: GovernmentPage.amber),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('Harare', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
                      ],
                    ),
                    Text('24°C', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 6),
                Text('Clear Sky', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: GovernmentPage.mutedLight)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Scope selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: GovernmentPage.surfaceLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: GovernmentPage.border)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedScope,
                isDense: true,
                dropdownColor: GovernmentPage.surface,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                icon: const Icon(Icons.expand_more_rounded, size: 16, color: GovernmentPage.muted),
                items: const [
                  DropdownMenuItem(value: 'National Overview', child: Text('National Overview')),
                  DropdownMenuItem(value: 'Manicaland', child: Text('Manicaland')),
                  DropdownMenuItem(value: 'Masvingo', child: Text('Masvingo')),
                  DropdownMenuItem(value: 'Mashonaland', child: Text('Mashonaland')),
                  DropdownMenuItem(value: 'Midlands', child: Text('Midlands')),
                  DropdownMenuItem(value: 'Matabeleland', child: Text('Matabeleland')),
                ],
                onChanged: (v) => setState(() => _selectedScope = v!),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Time range pills
          ..._buildTimeRangePills(),
          const SizedBox(width: 10),
          // Refresh button
          _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: GovernmentPage.green))
              : InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _refresh,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: GovernmentPage.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GovernmentPage.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 14, color: GovernmentPage.green),
                        const SizedBox(width: 4),
                        Text('Refresh', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: GovernmentPage.green)),
                      ],
                    ),
                  ),
                ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text('Live Data', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: GovernmentPage.green)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeRangePills() {
    const ranges = ['7D', '30D', '90D', '1Y'];
    return ranges.map((r) {
      final isActive = _selectedTimeRange == r;
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => setState(() => _selectedTimeRange = r),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? GovernmentPage.green : GovernmentPage.surfaceLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isActive ? GovernmentPage.green : GovernmentPage.border),
            ),
            child: Text(r, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? Colors.white : GovernmentPage.muted)),
          ),
        ),
      );
    }).toList();
  }

  // ── KPI ROW: 5 CARDS ──────────────────────────────────────────────────────
  Widget _buildKpiRow() {
    return LayoutBuilder(builder: (context, constraints) {
      final w = (constraints.maxWidth - 48) / 5;
      return Row(
        children: [
          _buildKpiCard(w, 'Strategic Grain Reserve', '420K', 'metric tons', '↑ 12%', 'vs last month', 'On Track', GovernmentPage.green, Icons.warehouse_rounded, [3.0, 3.5, 3.2, 3.8, 4.0, 3.9, 4.2]),
          const SizedBox(width: 12),
          _buildKpiCard(w, 'Registered Farmers', '1.24M', 'farmers', '↑ 6%', 'vs last month', 'Growing', GovernmentPage.blue, Icons.people_rounded, [1.0, 1.05, 1.1, 1.12, 1.15, 1.2, 1.24]),
          const SizedBox(width: 12),
          _buildKpiCard(w, 'Active Farms', '896K', 'farms', '↑ 4%', 'vs last month', 'Stable', GovernmentPage.teal, Icons.terrain_rounded, [8.2, 8.4, 8.5, 8.6, 8.7, 8.8, 8.96]),
          const SizedBox(width: 12),
          _buildKpiCard(w, 'National Food Production', '3.8M', 'metric tons', '↑ 8%', 'vs last season', 'Increasing', GovernmentPage.green, Icons.inventory_2_rounded, [3.0, 3.2, 3.3, 3.4, 3.5, 3.6, 3.8]),
          const SizedBox(width: 12),
          _buildKpiCard(w, 'Biosecurity Alerts', '12', 'active alerts', '↓ 25%', 'vs last month', 'Monitoring', GovernmentPage.orange, Icons.security_rounded, [18, 16, 15, 14, 13, 12, 12]),
        ],
      );
    });
  }

  Widget _buildKpiCard(double width, String title, String value, String unit, String change, String changeLabel, String badge, Color color, IconData icon, List<double> sparkData) {
    final isUp = change.startsWith('↑');
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: GovernmentPage.muted)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(width: 4),
                        Flexible(child: Text(unit, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: GovernmentPage.muted))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(change, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isUp ? GovernmentPage.green : GovernmentPage.red)),
                        const SizedBox(width: 4),
                        Text(changeLabel, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
                      ],
                    ),
                  ],
                ),
              ),
              // Mini sparkline
              SizedBox(
                width: 56, height: 28,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    minY: sparkData.reduce(min) * 0.95,
                    maxY: sparkData.reduce(max) * 1.05,
                    lineBarsData: [
                      LineChartBarData(
                        spots: sparkData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
                        isCurved: true,
                        color: color,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
                        barWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── MIDDLE ROW: Grain Reserves + Dam Telemetry ─────────────────────────────
  Widget _buildMiddleRow() {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth > 900;
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: _buildGrainReservesPanel()),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: _buildDamTelemetryPanel()),
          ],
        );
      }
      return Column(children: [_buildGrainReservesPanel(), const SizedBox(height: 16), _buildDamTelemetryPanel()]);
    });
  }

  // ── STRATEGIC GRAIN RESERVES PANEL ────────────────────────────────────────
  Widget _buildGrainReservesPanel() {
    const totalReserve = 682000;
    const totalTarget = 1200000;
    final pct = (totalReserve / totalTarget * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Strategic Grain Reserves (GMB)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              const Spacer(),
              Text('Total: 720K / 1.2M MT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: GovernmentPage.muted)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text('$pct%', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.green)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Current Reserves vs strategic targets', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          const SizedBox(height: 14),
          // Grain stock rows
          _buildGrainStockRow('Maize (GMB)', _maizeReserveTons, 600000, 'Adequate', GovernmentPage.green),
          const SizedBox(height: 10),
          _buildGrainStockRow('Wheat Reserve', _wheatReserveTons, 300000, 'Moderate', GovernmentPage.orange),
          const SizedBox(height: 10),
          _buildGrainStockRow('Sorghum & Small Grains', _sorghumReserveTons, 300000, 'Low', GovernmentPage.red),
          const SizedBox(height: 18),
          // Chart header
          Row(
            children: [
              Text('Reserve Movement (Last 30 Days)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: GovernmentPage.mutedLight)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: GovernmentPage.surfaceLight, borderRadius: BorderRadius.circular(6), border: Border.all(color: GovernmentPage.border)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Metric Tons', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: GovernmentPage.muted)),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded, size: 12, color: GovernmentPage.muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Grain trend chart
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                alignment: ChartAlignment.near,
                textStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: GovernmentPage.mutedLight),
              ),
              primaryXAxis: const CategoryAxis(
                labelStyle: TextStyle(fontSize: 9, color: GovernmentPage.muted),
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                labelRotation: 0,
                interval: 2,
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(fontSize: 9, color: GovernmentPage.muted),
                majorGridLines: MajorGridLines(width: 0.3, color: GovernmentPage.border.withValues(alpha: 0.5)),
                axisLine: const AxisLine(width: 0),
                numberFormat: NumberFormat.compact(),
              ),
              series: [
                SplineSeries<_GrainChartData, String>(
                  name: 'Maize', dataSource: _maizeChartData,
                  xValueMapper: (d, _) => d.date, yValueMapper: (d, _) => d.tons,
                  color: GovernmentPage.green, width: 2.5,
                ),
                SplineSeries<_GrainChartData, String>(
                  name: 'Wheat', dataSource: _wheatChartData,
                  xValueMapper: (d, _) => d.date, yValueMapper: (d, _) => d.tons,
                  color: GovernmentPage.amber, width: 2.5,
                ),
                SplineSeries<_GrainChartData, String>(
                  name: 'Sorghum', dataSource: _sorghumChartData,
                  xValueMapper: (d, _) => d.date, yValueMapper: (d, _) => d.tons,
                  color: GovernmentPage.purple, width: 2.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrainStockRow(String label, int tons, int target, String badge, Color color) {
    final pct = (tons / target).clamp(0.0, 1.0);
    final pctInt = (pct * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(badge, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('${(tons / 1000).toStringAsFixed(0)}K', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(' / ${(target / 1000).toStringAsFixed(0)}K MT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: pct, backgroundColor: GovernmentPage.surfaceLight, color: color, minHeight: 8),
              ),
            ),
            const SizedBox(width: 8),
            Text('$pctInt%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ],
    );
  }

  // ── DAM TELEMETRY PANEL ───────────────────────────────────────────────────
  Widget _buildDamTelemetryPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('National Water & Dam Telemetry', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              const Spacer(),
              Text('View All ▾', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: GovernmentPage.green)),
            ],
          ),
          const SizedBox(height: 2),
          Text('Live reservoir levels across Zimbabwe', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          const SizedBox(height: 12),
          // Map
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(-19.2, 29.9),
                      initialZoom: 5.8,
                      interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: _dams.map((dam) {
                          final level = dam['level'] as double;
                          final statusColor = Color(dam['statusColor'] as int);
                          return Marker(
                            point: LatLng(dam['lat'] as double, dam['lng'] as double),
                            width: 26, height: 26,
                            child: Tooltip(
                              message: '${dam['name']}: ${level.toStringAsFixed(1)}%',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: statusColor, width: 2),
                                  boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)],
                                ),
                                child: Center(child: Icon(Icons.water_drop_rounded, size: 12, color: statusColor)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  // Dark overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: GovernmentPage.darkBg.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  // Legend
                  Positioned(
                    left: 8, bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: GovernmentPage.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Reservoir Status', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: GovernmentPage.mutedLight)),
                          const SizedBox(height: 3),
                          _legendDot('Above 80%', GovernmentPage.blue),
                          _legendDot('50-80%', GovernmentPage.green),
                          _legendDot('Below 50%', GovernmentPage.amber),
                          _legendDot('Critical', GovernmentPage.red),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Dam telemetry table
          Container(
            decoration: BoxDecoration(
              color: GovernmentPage.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: Text('Reservoir', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: GovernmentPage.muted))),
                      Expanded(flex: 2, child: Text('Level', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: GovernmentPage.muted))),
                      Expanded(flex: 3, child: Text('Volume', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: GovernmentPage.muted))),
                      Expanded(flex: 2, child: Text('Trend', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: GovernmentPage.muted))),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),
                const Divider(height: 1, color: GovernmentPage.border),
                // Data rows
                for (int i = 0; i < _dams.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: GovernmentPage.border),
                  _buildDamTableRow(_dams[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 7.5, fontWeight: FontWeight.w500, color: GovernmentPage.mutedLight)),
        ],
      ),
    );
  }

  Widget _buildDamTableRow(Map<String, dynamic> dam) {
    final level = dam['level'] as double;
    final statusColor = Color(dam['statusColor'] as int);
    final trend = dam['trend'] as String;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          Expanded(flex: 4, child: Text(dam['name'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Text('${level.toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dam['volume'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(dam['capacity'] as String, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  trend == 'High' ? Icons.trending_up_rounded : trend == 'Watch' ? Icons.trending_down_rounded : Icons.trending_flat_rounded,
                  size: 13, color: statusColor,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(trend, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor)),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ROW: Risk Index + Crop Outlook + Alerts ─────────────────────────
  Widget _buildBottomRow() {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth > 900;
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildRiskIndexPanel()),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildCropOutlookPanel()),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: _buildAlertsPanel()),
          ],
        );
      }
      return Column(children: [_buildRiskIndexPanel(), const SizedBox(height: 16), _buildCropOutlookPanel(), const SizedBox(height: 16), _buildAlertsPanel()]);
    });
  }

  // ── FOOD SECURITY RISK INDEX ──────────────────────────────────────────────
  Widget _buildRiskIndexPanel() {
    final sortedProvinces = _riskScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topRisk = sortedProvinces.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Food Security Risk Index', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 2),
          Text('Provincial food security risk levels (lower is better)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk map
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: _ZimbabweRiskMapPainter(_riskScores),
                    size: const Size(double.infinity, 180),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right side: legend + top risk provinces
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Legend
                    _riskLegendItem(const Color(0xFF16A34A), 'Low Risk (0 - 20)'),
                    _riskLegendItem(const Color(0xFF84CC16), 'Moderate (21 - 40)'),
                    _riskLegendItem(const Color(0xFFF59E0B), 'Elevated (41 - 60)'),
                    _riskLegendItem(const Color(0xFFF97316), 'High (61 - 80)'),
                    _riskLegendItem(const Color(0xFFEF4444), 'Critical (81 - 100)'),
                    const SizedBox(height: 12),
                    Text('Top Risk Provinces', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: GovernmentPage.mutedLight)),
                    const SizedBox(height: 6),
                    for (int i = 0; i < topRisk.length; i++)
                      _buildRiskProvinceRow(i + 1, topRisk[i].key, topRisk[i].value),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riskLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: GovernmentPage.mutedLight)),
        ],
      ),
    );
  }

  Widget _buildRiskProvinceRow(int rank, String name, int score) {
    Color scoreColor;
    if (score >= 81) {
      scoreColor = GovernmentPage.red;
    } else if (score >= 61) {
      scoreColor = GovernmentPage.orange;
    } else if (score >= 41) {
      scoreColor = GovernmentPage.amber;
    } else if (score >= 21) {
      scoreColor = const Color(0xFF84CC16);
    } else {
      scoreColor = GovernmentPage.green;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(child: Text('$rank', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: scoreColor))),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text('$score', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: scoreColor)),
          ),
        ],
      ),
    );
  }

  // ── CROP PRODUCTION OUTLOOK ───────────────────────────────────────────────
  Widget _buildCropOutlookPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Crop Production Outlook', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              const Spacer(),
              Text('vs last season', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
            ],
          ),
          const SizedBox(height: 2),
          Text('(2025/26 Season)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          const SizedBox(height: 14),
          for (int i = 0; i < _cropOutlook.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildCropRow(_cropOutlook[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildCropRow(Map<String, dynamic> crop) {
    final isUp = crop['up'] as bool;
    final change = crop['change'] as int;
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: (isUp ? GovernmentPage.green : GovernmentPage.red).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(crop['icon'] as IconData, size: 14, color: isUp ? GovernmentPage.green : GovernmentPage.red),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(crop['crop'] as String, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: isUp ? GovernmentPage.green : GovernmentPage.red),
        const SizedBox(width: 2),
        SizedBox(
          width: 32,
          child: Text('$change%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: isUp ? GovernmentPage.green : GovernmentPage.red)),
        ),
        const SizedBox(width: 8),
        Text(crop['volume'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: GovernmentPage.mutedLight)),
      ],
    );
  }

  // ── ALERTS & ACTIONS CENTER ───────────────────────────────────────────────
  Widget _buildAlertsPanel() {
    const filters = ['All', 'Drought', 'Pests', 'Water', 'Markets'];
    final filtered = _selectedAlertFilter == 'All'
        ? _actionAlerts
        : _actionAlerts.where((a) => a['category'] == _selectedAlertFilter).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Alerts & Actions', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              const Spacer(),
              // Filter tabs
              for (final f in filters)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedAlertFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _selectedAlertFilter == f ? GovernmentPage.green : GovernmentPage.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(f, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: _selectedAlertFilter == f ? Colors.white : GovernmentPage.muted)),
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Text('View All Alerts ▸', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: GovernmentPage.green)),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < filtered.length; i++) ...[
            if (i > 0) Divider(height: 16, color: GovernmentPage.border.withValues(alpha: 0.5)),
            _buildAlertItem(filtered[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final severity = alert['severity'] as String;
    Color sevColor;
    if (severity == 'High') {
      sevColor = GovernmentPage.red;
    } else if (severity == 'Medium') {
      sevColor = GovernmentPage.orange;
    } else {
      sevColor = GovernmentPage.blue;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6, height: 6,
          margin: const EdgeInsets.only(top: 5, right: 8),
          decoration: BoxDecoration(color: sevColor, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert['title'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 2),
              Text(alert['desc'] as String, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(alert['time'] as String, style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(severity, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: sevColor)),
            ),
          ],
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${alert['action']}: ${alert['title']}'), backgroundColor: GovernmentPage.green));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: GovernmentPage.surfaceLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GovernmentPage.border),
            ),
            child: Text(alert['action'] as String, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: GovernmentPage.mutedLight)),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FOOTER STATUS BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFooterBar() {
    final syncTime = DateFormat('dd MMM yyyy HH:mm').format(_now);
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        border: Border(top: BorderSide(color: GovernmentPage.border, width: 1)),
      ),
      child: Row(
        children: [
          // System status
          Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6), decoration: const BoxDecoration(color: GovernmentPage.green, shape: BoxShape.circle)),
          Text('System Status:', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: GovernmentPage.muted)),
          const SizedBox(width: 4),
          Text('All systems operational', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: GovernmentPage.green)),
          _footerDivider(),
          const Icon(Icons.storage_rounded, size: 10, color: GovernmentPage.muted),
          const SizedBox(width: 4),
          Text('Data Feeds: Online (ZINWA, GMB, MET, AGRITEX, ZIMSTAT)', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          _footerDivider(),
          Text('Last sync: $syncTime', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          _footerDivider(),
          Text('API Services: ', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          Text('Healthy (6/6)', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: GovernmentPage.green)),
          _footerDivider(),
          const Icon(Icons.description_outlined, size: 10, color: GovernmentPage.muted),
          const SizedBox(width: 4),
          Text('Audit Log: 2,498 records (24h)', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: GovernmentPage.muted)),
          const Spacer(),
          Text('Sustainable Agriculture · A Food Secure Zimbabwe', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: GovernmentPage.muted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _footerDivider() {
    return Container(width: 1, height: 12, margin: const EdgeInsets.symmetric(horizontal: 10), color: GovernmentPage.border);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: FARMER REGISTRY
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFarmerRegistryTab() {
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
        _sectionHeader(Icons.person_pin_rounded, 'National Farmer Registry'),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register New Farmer — Unique Digital National ID', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _darkTextField(_farmerNameCtrl, 'Full Name')),
                const SizedBox(width: 20),
                Expanded(child: _darkTextField(_farmerNatIdCtrl, 'National ID Number')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _darkDropdown(_farmerProvince, 'Province', ['Manicaland', 'Matabeleland South', 'Mashonaland Central', 'Midlands', 'Harare'], (v) => setState(() => _farmerProvince = v!))),
                const SizedBox(width: 16),
                Expanded(child: _darkTextField(_farmerDistrictCtrl, 'District / Region')),
                const SizedBox(width: 16),
                Expanded(child: _darkTextField(_farmerWardCtrl, 'Ward Number')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _darkTextField(_farmerCropsCtrl, 'Primary Crops')),
                const SizedBox(width: 20),
                Expanded(child: _darkDropdown(_farmerWallet, 'Mobile Wallet', ['EcoCash', 'OneMoney', 'ZB Mobile', 'CBZ Agro Card', 'Steward Bank'], (v) => setState(() => _farmerWallet = v!))),
              ]),
              const SizedBox(height: 20),
              _actionButton(Icons.person_add_rounded, 'Generate National Farmer ID & Register', GovernmentPage.green, () {
                if (_farmerNameCtrl.text.isNotEmpty) {
                  setState(() {
                    _farmers.insert(0, {
                      'id': 'ZIM-FID-${1000 + _farmers.length}', 'name': _farmerNameCtrl.text.trim(),
                      'nationalId': _farmerNatIdCtrl.text.trim().isEmpty ? '63-999821 B00' : _farmerNatIdCtrl.text.trim(),
                      'province': _farmerProvince, 'district': _farmerDistrictCtrl.text.trim().isEmpty ? 'Mutare District' : _farmerDistrictCtrl.text.trim(),
                      'ward': _farmerWardCtrl.text.trim().isEmpty ? 'Ward 12' : 'Ward ${_farmerWardCtrl.text.trim()}',
                      'crops': _farmerCropsCtrl.text.trim().isEmpty ? 'Maize, Horticulture' : _farmerCropsCtrl.text.trim(),
                      'landHa': 4.5, 'wallet': '$_farmerWallet (\$0.00)', 'status': 'Verified',
                    });
                    _farmerNameCtrl.clear(); _farmerNatIdCtrl.clear(); _farmerDistrictCtrl.clear(); _farmerWardCtrl.clear(); _farmerCropsCtrl.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('National Farmer ID Generated & Registered!'), backgroundColor: GovernmentPage.green));
                }
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('National Farmer Ledger (${filtered.length} Records)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _farmerSearchQuery = val),
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search farmer by name, ID, or NatID...', hintStyle: GoogleFonts.inter(color: GovernmentPage.muted, fontWeight: FontWeight.w500, fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: GovernmentPage.muted),
                      filled: true, fillColor: GovernmentPage.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GovernmentPage.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GovernmentPage.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GovernmentPage.green)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _farmerProvinceFilter, dropdownColor: GovernmentPage.surface,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'All Provinces', child: Text('All Provinces')),
                    DropdownMenuItem(value: 'Manicaland', child: Text('Manicaland')),
                    DropdownMenuItem(value: 'Matabeleland South', child: Text('Matabeleland South')),
                    DropdownMenuItem(value: 'Mashonaland Central', child: Text('Mashonaland Central')),
                  ],
                  onChanged: (v) => setState(() => _farmerProvinceFilter = v!),
                ),
              ]),
              const SizedBox(height: 16),
              for (int i = 0; i < filtered.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: GovernmentPage.border),
                _buildLedgerItem(
                  icon: Icons.person_rounded, iconColor: GovernmentPage.green,
                  title: filtered[i]['name'] as String, badge: filtered[i]['status'] as String, badgeColor: GovernmentPage.green,
                  subtitle: 'ID: ${filtered[i]['id']} · NatID: ${filtered[i]['nationalId']}\n'
                      '${filtered[i]['province']}, ${filtered[i]['district']}, ${filtered[i]['ward']} · Land: ${filtered[i]['landHa']} ha\n'
                      'Crops: ${filtered[i]['crops']} · Wallet: ${filtered[i]['wallet']}',
                  trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.badge_outlined, color: GovernmentPage.blue), tooltip: 'View Sovereign ID Card'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: FARM REGISTRATION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFarmRegistrationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.map_rounded, 'Farm Parcel Registration — GIS Boundary & Soil Ledger'),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register New Farm Parcel (GIS Boundary)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _darkTextField(_parcelNatIdCtrl, 'Farmer National ID')),
                const SizedBox(width: 20),
                Expanded(child: _darkTextField(_parcelGpsCtrl, 'GPS Boundary / Coordinates')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _darkTextField(_parcelSoilCtrl, 'Soil Type')),
                const SizedBox(width: 16),
                Expanded(child: _darkTextField(_parcelWaterCtrl, 'Water Source')),
                const SizedBox(width: 16),
                Expanded(child: _darkDropdown(_parcelLandUse, 'Land Use Classification', ['Mixed Horticulture', 'Dryland Grain', 'Export Horticulture', 'Livestock Rangeland'], (v) => setState(() => _parcelLandUse = v!))),
              ]),
              const SizedBox(height: 20),
              _actionButton(Icons.travel_explore_rounded, 'Register Farm Parcel & Queue NDVI Scan', GovernmentPage.teal, () {
                setState(() {
                  _farms.insert(0, {
                    'parcelId': 'PARCEL-MAN-00${80 + _farms.length}', 'farmerName': 'Tendai Chigodora',
                    'farmerId': _parcelNatIdCtrl.text.trim().isEmpty ? 'ZIM-FID-9821' : _parcelNatIdCtrl.text.trim(),
                    'boundary': _parcelGpsCtrl.text.trim().isEmpty ? 'GIS Polygon: -18.9712, 32.6711 (4.5 Ha)' : _parcelGpsCtrl.text.trim(),
                    'soilType': _parcelSoilCtrl.text.trim().isEmpty ? 'Sandy Loam' : _parcelSoilCtrl.text.trim(),
                    'elevation': '820m ASL', 'waterSource': _parcelWaterCtrl.text.trim().isEmpty ? 'Borehole + River Divert' : _parcelWaterCtrl.text.trim(),
                    'landUse': _parcelLandUse, 'province': 'Manicaland', 'ndvi': '0.74 (Healthy)', 'registeredBy': 'Ext. Officer E. Moyo on 12 Mar 2025',
                  });
                  _parcelNatIdCtrl.clear(); _parcelGpsCtrl.clear(); _parcelSoilCtrl.clear(); _parcelWaterCtrl.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farm Parcel Registered & NDVI Scan Queued!'), backgroundColor: GovernmentPage.teal));
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registered Farm Parcels Ledger (${_farms.length} Parcels)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 14),
              for (int i = 0; i < _farms.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: GovernmentPage.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(_farms[i]['parcelId'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(_farms[i]['ndvi'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: GovernmentPage.green)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.satellite_alt_rounded, color: GovernmentPage.teal, size: 18),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                      'Farmer: ${_farms[i]['farmerName']} (${_farms[i]['farmerId']})\n'
                      '${_farms[i]['boundary']}\n'
                      'Soil: ${_farms[i]['soilType']} · Elevation: ${_farms[i]['elevation']} · Water: ${_farms[i]['waterSource']}\n'
                      'Land Use: ${_farms[i]['landUse']} · Province: ${_farms[i]['province']}\n'
                      'Registered by: ${_farms[i]['registeredBy']}',
                      style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 4: EXTENSION OFFICERS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildExtensionOfficersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.support_agent_rounded, 'Extension Officers Management'),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, c) {
          final cardW = (c.maxWidth - 36) / 4;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            _buildOfficerKpiCard('Total Officers', '${_officers.length}', Icons.badge_outlined, GovernmentPage.purple, cardW),
            _buildOfficerKpiCard('Farmers Supported', '495', Icons.people_outline, GovernmentPage.green, cardW),
            _buildOfficerKpiCard('Training Sessions', '28', Icons.school_outlined, GovernmentPage.blue, cardW),
            _buildOfficerKpiCard('Active Officers', '${_officers.where((o) => o['status'] == 'Active').length}', Icons.check_circle_outline, GovernmentPage.teal, cardW),
          ]);
        }),
        const SizedBox(height: 20),
        _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Register New Extension Officer', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _darkTextField(_officerNameCtrl, 'Full Name')),
              const SizedBox(width: 20),
              Expanded(child: _darkTextField(_officerPhoneCtrl, 'Phone Number')),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _darkDropdown(_officerProvince, 'Province', ['Manicaland', 'Matabeleland South', 'Mashonaland Central', 'Midlands'], (v) => setState(() => _officerProvince = v!))),
              const SizedBox(width: 16),
              Expanded(child: _darkTextField(_officerDistrictCtrl, 'District Assignment')),
              const SizedBox(width: 16),
              Expanded(child: _darkTextField(_officerWardsCtrl, 'Wards (comma separated)')),
            ]),
            const SizedBox(height: 16),
            _darkDropdown(_officerSpec, 'Specialization', ['Horticulture & Export Crops', 'Dryland Grain & Livestock', 'Irrigation & Soil Health', 'Livestock & Veterinary Liaison'], (v) => setState(() => _officerSpec = v!)),
            const SizedBox(height: 20),
            _actionButton(Icons.person_add_rounded, 'Register Extension Officer', GovernmentPage.purple, () {
              if (_officerNameCtrl.text.isNotEmpty) {
                setState(() {
                  _officers.insert(0, {
                    'id': 'EXT-00${25 + _officers.length}', 'name': _officerNameCtrl.text.trim(),
                    'province': _officerProvince, 'district': _officerDistrictCtrl.text.trim().isEmpty ? 'Mutare' : _officerDistrictCtrl.text.trim(),
                    'wards': _officerWardsCtrl.text.trim().isEmpty ? 'Ward 12, 13' : _officerWardsCtrl.text.trim(),
                    'farmersSupported': 100, 'phone': _officerPhoneCtrl.text.trim().isEmpty ? '+263 77 201 3344' : _officerPhoneCtrl.text.trim(),
                    'status': 'Active', 'verified': true, 'specialization': _officerSpec,
                  });
                  _officerNameCtrl.clear(); _officerPhoneCtrl.clear(); _officerDistrictCtrl.clear(); _officerWardsCtrl.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extension Officer Registered & Deployed!'), backgroundColor: GovernmentPage.purple));
              }
            }),
          ]),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Extension Officer Field Roster (${_officers.length} Officers)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 14),
            for (int i = 0; i < _officers.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: GovernmentPage.border),
              _buildLedgerItem(
                icon: null, iconColor: GovernmentPage.purple,
                title: _officers[i]['name'] as String,
                badge: _officers[i]['status'] as String, badgeColor: GovernmentPage.green,
                extraBadge: 'Verified by State', extraBadgeColor: GovernmentPage.orange,
                subtitle: 'ID: ${_officers[i]['id']} · ${_officers[i]['phone']} · Specialization: ${_officers[i]['specialization']}\n'
                    'District: ${_officers[i]['district']} (${_officers[i]['wards']}) · Farmers: ${_officers[i]['farmersSupported']}',
                trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.phone_outlined, color: GovernmentPage.green)),
                avatarText: (_officers[i]['name'] as String).substring(0, 1),
              ),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _buildOfficerKpiCard(String label, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: GovernmentPage.muted)),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        ]),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 5: SUBSIDIES & ADVISORY
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSubsidiesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.card_giftcard_rounded, 'State Input Subsidies & E-Voucher Issuance'),
        const SizedBox(height: 12),
        _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Issue State Input Subsidies (E-Voucher)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 14),
            for (final vch in _vouchers)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.confirmation_number_outlined, color: GovernmentPage.orange),
                title: Text('${vch['id']} · ${vch['farmer']} (${vch['value']})', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                subtitle: Text('Inputs: ${vch['inputs']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: GovernmentPage.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(vch['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GovernmentPage.orange)),
                ),
              ),
          ]),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 6: BIOSECURITY
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBiosecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.bug_report_rounded, 'Pest, Disease & Biosecurity Control'),
        const SizedBox(height: 12),
        _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Report New Pest / Disease Outbreak (Geo-tagged)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _darkTextField(_outbreakPestCtrl, 'Disease or Pest Name')),
              const SizedBox(width: 20),
              Expanded(child: _darkTextField(_outbreakLocCtrl, 'Geo-tagged Location')),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _darkDropdown(_outbreakType, 'Type', ['Crop', 'Livestock', 'Forestry'], (v) => setState(() => _outbreakType = v!))),
              const SizedBox(width: 16),
              Expanded(child: _darkDropdown(_outbreakSeverity, 'Severity Level', ['Low', 'Moderate', 'High', 'Critical'], (v) => setState(() => _outbreakSeverity = v!))),
              const SizedBox(width: 16),
              Expanded(child: _darkTextField(_outbreakOfficerCtrl, 'Responding Officer')),
            ]),
            const SizedBox(height: 20),
            _actionButton(Icons.warning_amber_rounded, 'Raise Quarantine Alert', GovernmentPage.red, () {
              if (_outbreakPestCtrl.text.isNotEmpty) {
                setState(() {
                  _outbreaks.insert(0, {
                    'id': 'OUT-${105 + _outbreaks.length}', 'pest': _outbreakPestCtrl.text.trim(), 'type': _outbreakType,
                    'location': _outbreakLocCtrl.text.trim().isEmpty ? 'Domboshava Fields' : _outbreakLocCtrl.text.trim(),
                    'severity': _outbreakSeverity, 'date': 'Today, 08:30', 'status': 'Quarantine Ordered',
                    'affectedHa': 340, 'officer': _outbreakOfficerCtrl.text.trim().isEmpty ? 'Evelyn Moyo' : _outbreakOfficerCtrl.text.trim(),
                  });
                  _outbreakPestCtrl.clear(); _outbreakLocCtrl.clear(); _outbreakOfficerCtrl.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quarantine Alert Raised & Dispatched!'), backgroundColor: GovernmentPage.red));
              }
            }),
          ]),
        ),
        const SizedBox(height: 20),
        for (final out in _outbreaks)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: out['severity'] == 'Critical' ? const Color(0xFF1A0A0A) : GovernmentPage.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: out['severity'] == 'Critical' ? const Color(0xFF7F1D1D) : GovernmentPage.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(out['pest'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
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
              ]),
              const SizedBox(height: 6),
              Text('Location: ${out['location']} · Date: ${out['date']} · Status: ${out['status']}\nAffected Area: ${out['affectedHa']} Ha · Officer: ${out['officer']}',
                style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600, height: 1.4)),
              const SizedBox(height: 10),
              _actionButton(Icons.emergency_outlined, 'Enforce Quarantine', GovernmentPage.red, () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enforcing Quarantine for ${out['pest']}!'), backgroundColor: GovernmentPage.red));
              }),
            ]),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 7: TRADE & PRICES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTradeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.show_chart_rounded, 'Trade Corridors, Price Monitoring & ePhyto Customs'),
        const SizedBox(height: 12),
        _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('National Commodity Price Monitor (Real-Time)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
              _actionButton(Icons.edit_outlined, 'Update Commodity Price', GovernmentPage.teal, () => _showUpdatePriceModal(context)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: GovernmentPage.surfaceLight, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Expanded(flex: 3, child: Text('Commodity', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentPage.mutedLight))),
                Expanded(flex: 2, child: Text('Province', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentPage.mutedLight))),
                Expanded(flex: 2, child: Text('Wholesale', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentPage.mutedLight))),
                Expanded(flex: 2, child: Text('Retail', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentPage.mutedLight))),
                Expanded(flex: 2, child: Text('Change', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: GovernmentPage.mutedLight))),
              ]),
            ),
            for (int i = 0; i < _prices.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(children: [
                  Expanded(flex: 3, child: Text(_prices[i]['commodity'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white))),
                  Expanded(flex: 2, child: Text(_prices[i]['province'] as String, style: GoogleFonts.inter(fontSize: 12, color: GovernmentPage.muted, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text(_prices[i]['wholesale'] as String, style: GoogleFonts.inter(fontSize: 12, color: GovernmentPage.muted, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text(_prices[i]['retail'] as String, style: GoogleFonts.inter(fontSize: 12, color: GovernmentPage.muted, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Row(children: [
                    Icon((_prices[i]['up'] as bool) ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 15, color: (_prices[i]['up'] as bool) ? GovernmentPage.green : GovernmentPage.red),
                    const SizedBox(width: 4),
                    Text(_prices[i]['change'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: (_prices[i]['up'] as bool) ? GovernmentPage.green : GovernmentPage.red)),
                  ])),
                ]),
              ),
              if (i < _prices.length - 1) const Divider(height: 1, color: GovernmentPage.border),
            ],
          ]),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ePhyto Digital Certification & Border Clearance Portal (Beitbridge | Forbes)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Verify AMA exporter licenses, SAZ compliance dossiers, and clear shipments for the South Corridor (Beitbridge → Durban) and East Corridor (Forbes → Beira).', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            for (final csn in _consignments)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  const Icon(Icons.verified_outlined, color: GovernmentPage.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${csn['id']} · ${csn['crop']} (${csn['weightKg']} kg)', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                    Text('Exporter: ${csn['exporter']} · Border: ${csn['border']} · Destination: ${csn['destination']}', style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
                  ])),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.green, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() => csn['phytoStatus'] = 'Cleared & Sealed');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ePhyto ${csn['id']} Cleared!'), backgroundColor: GovernmentPage.green));
                    },
                    child: Text(csn['phytoStatus'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
          ]),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODALS
  // ══════════════════════════════════════════════════════════════════════════
  void _showUpdatePriceModal(BuildContext context) {
    final commCtrl = TextEditingController();
    final provCtrl = TextEditingController(text: 'Harare');
    final wsCtrl = TextEditingController();
    final rtCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GovernmentPage.surface,
        title: Text('Update Commodity Price Monitor', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(commCtrl, 'Commodity Name'),
          _dialogField(provCtrl, 'Province'),
          _dialogField(wsCtrl, 'Wholesale Price (e.g. \$250/t)'),
          _dialogField(rtCtrl, 'Retail Price (e.g. \$0.30/kg)'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: GovernmentPage.muted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GovernmentPage.teal, foregroundColor: Colors.white),
            onPressed: () {
              if (commCtrl.text.isNotEmpty) {
                setState(() {
                  _prices.insert(0, {'commodity': commCtrl.text.trim(), 'province': provCtrl.text.trim(), 'wholesale': wsCtrl.text.trim().isEmpty ? '\$250/t' : wsCtrl.text.trim(), 'retail': rtCtrl.text.trim().isEmpty ? '\$0.30/kg' : rtCtrl.text.trim(), 'change': '+2.0%', 'up': true});
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

  Widget _dialogField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: GovernmentPage.muted, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GovernmentPage.border)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GovernmentPage.green)),
        ),
      ),
    );
  }

  void _showNotificationCenterModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GovernmentPage.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.65, maxChildSize: 0.9, minChildSize: 0.4,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(controller: scrollController, children: [
            Row(children: [
              const Icon(Icons.notifications_active_rounded, color: GovernmentPage.green, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text('Sovereign Alert & Notification Center', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white))),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: GovernmentPage.muted)),
            ]),
            const Divider(height: 20, color: GovernmentPage.border),
            _buildNotificationTile(title: 'CRITICAL BIOSECURITY EMERGENCY', subtitle: 'Fall Armyworm Infestation detected in Domboshava Fields (340 Ha affected). Ring-fence quarantine ordered.', time: '10 mins ago', icon: Icons.bug_report_rounded, iconColor: GovernmentPage.red, onTap: () { Navigator.pop(ctx); _tabController.animateTo(5); }),
            const SizedBox(height: 10),
            _buildNotificationTile(title: 'ePhyto Export Clearance Sign-off Pending', subtitle: 'Consignment EXP-PEAS-9921 (8,400 kg Sugar Snaps to Rotterdam) requires official digital signature at Forbes Border.', time: '25 mins ago', icon: Icons.verified_outlined, iconColor: GovernmentPage.blue, onTap: () { Navigator.pop(ctx); _tabController.animateTo(6); }),
            const SizedBox(height: 10),
            _buildNotificationTile(title: 'Strategic Maize Reserve Intake Update', subtitle: 'GMB Silos recorded +12,400 metric tons intake from Mazowe outgrowers today. Stock level at 84.0% capacity.', time: '1 hour ago', icon: Icons.warehouse_outlined, iconColor: GovernmentPage.green, onTap: () { Navigator.pop(ctx); _tabController.animateTo(0); }),
            const SizedBox(height: 10),
            _buildNotificationTile(title: 'Mazowe Dam Capacity Advisory', subtitle: 'Mazowe Dam Complex reached 89.5% capacity. Downstream irrigation discharge optimized to 420 m³/s.', time: '3 hours ago', icon: Icons.water_drop_rounded, iconColor: GovernmentPage.teal, onTap: () { Navigator.pop(ctx); _tabController.animateTo(0); }),
          ]),
        ),
      ),
    );
  }

  Widget _buildNotificationTile({required String title, required String subtitle, required String time, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: GovernmentPage.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Row(children: [
          Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: iconColor))),
          Text(time, style: GoogleFonts.inter(fontSize: 10, color: GovernmentPage.muted, fontWeight: FontWeight.w600)),
        ]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: GovernmentPage.muted),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED UI HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _sectionHeader(IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: 18, color: GovernmentPage.green),
      const SizedBox(width: 8),
      Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
    ]);
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GovernmentPage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GovernmentPage.border),
      ),
      child: child,
    );
  }

  Widget _darkTextField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: GovernmentPage.muted, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GovernmentPage.border)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GovernmentPage.green)),
      ),
    );
  }

  Widget _darkDropdown(String value, String label, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: GovernmentPage.surface,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: GovernmentPage.muted, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GovernmentPage.border)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: GovernmentPage.green)),
      ),
      items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildLedgerItem({
    IconData? icon, required Color iconColor, required String title, required String badge, required Color badgeColor,
    String? extraBadge, Color? extraBadgeColor, required String subtitle, Widget? trailing, String? avatarText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: avatarText != null
              ? Text(avatarText, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: iconColor))
              : Icon(icon ?? Icons.person_rounded, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor)),
            ),
            if (extraBadge != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: (extraBadgeColor ?? GovernmentPage.orange).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(extraBadge, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: extraBadgeColor ?? GovernmentPage.orange)),
              ),
            ],
          ]),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: GovernmentPage.muted, fontWeight: FontWeight.w600, height: 1.4)),
        ])),
        ?trailing,
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ZIMBABWE RISK MAP — CUSTOM PAINTER
// ══════════════════════════════════════════════════════════════════════════════
class _ZimbabweRiskMapPainter extends CustomPainter {
  final Map<String, int> riskScores;
  _ZimbabweRiskMapPainter(this.riskScores);

  // Zimbabwe outer boundary (normalized 0-1 coords)
  static const _boundary = [
    Offset(0.008, 0.322), Offset(0.038, 0.324), Offset(0.077, 0.294),
    Offset(0.231, 0.191), Offset(0.333, 0.132), Offset(0.462, 0.003),
    Offset(0.667, 0.000), Offset(0.744, 0.007), Offset(0.782, 0.088),
    Offset(0.846, 0.162), Offset(0.910, 0.250), Offset(0.974, 0.353),
    Offset(0.994, 0.426), Offset(0.974, 0.500), Offset(0.987, 0.618),
    Offset(0.936, 0.676), Offset(0.923, 0.765), Offset(0.821, 0.868),
    Offset(0.615, 0.971), Offset(0.551, 1.000), Offset(0.487, 0.985),
    Offset(0.359, 0.926), Offset(0.295, 0.868), Offset(0.231, 0.721),
    Offset(0.090, 0.647), Offset(0.077, 0.500), Offset(0.051, 0.426),
    Offset(0.013, 0.353),
  ];

  // Province regions (approximate center + radius for filled circles)
  static const _provinceRegions = {
    'Matabeleland North': Offset(0.16, 0.35),
    'Mashonaland West': Offset(0.38, 0.18),
    'Mashonaland Central': Offset(0.62, 0.10),
    'Mashonaland East': Offset(0.72, 0.28),
    'Manicaland': Offset(0.90, 0.42),
    'Midlands': Offset(0.40, 0.52),
    'Masvingo': Offset(0.68, 0.72),
    'Matabeleland South': Offset(0.25, 0.82),
    'Harare': Offset(0.66, 0.22),
    'Bulawayo': Offset(0.22, 0.65),
  };

  Color _riskColor(int score) {
    if (score >= 81) return const Color(0xFFEF4444);
    if (score >= 61) return const Color(0xFFF97316);
    if (score >= 41) return const Color(0xFFF59E0B);
    if (score >= 21) return const Color(0xFF84CC16);
    return const Color(0xFF16A34A);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Zimbabwe boundary
    final boundaryPath = Path();
    boundaryPath.moveTo(_boundary[0].dx * size.width, _boundary[0].dy * size.height);
    for (int i = 1; i < _boundary.length; i++) {
      boundaryPath.lineTo(_boundary[i].dx * size.width, _boundary[i].dy * size.height);
    }
    boundaryPath.close();

    // Clip to boundary and fill background
    canvas.save();
    canvas.clipPath(boundaryPath);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF1E293B));

    // Draw colored province regions as large circles
    for (final entry in _provinceRegions.entries) {
      final score = riskScores[entry.key] ?? 30;
      final color = _riskColor(score);
      final center = Offset(entry.value.dx * size.width, entry.value.dy * size.height);
      final isSmall = entry.key == 'Harare' || entry.key == 'Bulawayo';
      final radius = isSmall ? size.width * 0.06 : size.width * 0.14;
      canvas.drawCircle(center, radius, Paint()..color = color.withValues(alpha: 0.5));
    }
    canvas.restore();

    // Draw boundary outline
    canvas.drawPath(boundaryPath, Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round);

    // Draw province labels
    for (final entry in _provinceRegions.entries) {
      final center = Offset(entry.value.dx * size.width, entry.value.dy * size.height);
      final tp = TextPainter(
        text: TextSpan(
          text: entry.key.split(' ').last,
          style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}