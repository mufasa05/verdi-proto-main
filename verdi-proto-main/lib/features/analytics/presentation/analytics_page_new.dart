import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../data/analytics_export_service.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _selectedTimeframe = '7 Days';
  String _selectedComparePeriod = 'Previous Period';
  String _selectedDateRange = 'This Week';
  String _selectedRegion = 'All Regions';

  final List<String> _timeframes = const ['7 Days', '30 Days', '12 Months'];
  final List<String> _comparePeriods = const ['Previous Period', 'Last Year', 'Rolling Avg'];
  final List<String> _dateRanges = const ['This Week', 'This Month', 'Quarter'];
  final List<String> _regions = const ['All Regions', 'Masvingo', 'Chiredzi', 'Mutare', 'Harare'];

  double _getRegionScale() {
    switch (_selectedRegion) {
      case 'Masvingo':
        return 0.4;
      case 'Chiredzi':
        return 0.25;
      case 'Mutare':
        return 0.2;
      case 'Harare':
        return 0.15;
      default:
        return 1.0;
    }
  }

  AnalyticsMockDataset _getDataset() {
    final scale = _getRegionScale();

    if (_selectedTimeframe == '30 Days') {
      return AnalyticsMockDataset(
        revenue: '\$${(52140 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        revenueChange: '+15.8%',
        revenueSpark: [12000, 11500, 13000, 12800, 14200, 14640],
        orders: '${(945 * scale).round()}',
        ordersChange: '+10.2%',
        ordersSpark: [180, 170, 210, 195, 230, 245],
        buyers: '${(142 * scale).round()}',
        buyersChange: '+7.4%',
        buyersSpark: [95, 100, 115, 112, 130, 142],
        fulfillment: '95.0%',
        fulfillmentChange: '+1.8%',
        fulfillmentSpark: [93, 94, 94.2, 94.8, 95, 95],
        deliveries: '${(318 * scale).round()}',
        deliveriesChange: '+9.1%',
        deliveriesSpark: [50, 54, 60, 62, 66, 70],
        listings: '${(204 * scale).round()}',
        listingsChange: '+6.3%',
        listingsSpark: [140, 150, 158, 166, 178, 184],
        revenueTrend: [
          ChartData('Wk 1', 11200 * scale, 10500 * scale),
          ChartData('Wk 2', 12800 * scale, 12000 * scale),
          ChartData('Wk 3', 13500 * scale, 13000 * scale),
          ChartData('Wk 4', 14640 * scale, 14000 * scale),
        ],
        fulfillmentTrend: [
          ChartData('Mon', 91.4, 90.0),
          ChartData('Tue', 92.1, 91.1),
          ChartData('Wed', 93.0, 92.0),
          ChartData('Thu', 94.2, 92.9),
          ChartData('Fri', 94.8, 93.5),
          ChartData('Sat', 95.1, 94.0),
          ChartData('Sun', 95.3, 94.5),
        ],
        deliveryTrend: [
          ChartData('Mon', 54, 50),
          ChartData('Tue', 57, 53),
          ChartData('Wed', 60, 55),
          ChartData('Thu', 61, 58),
          ChartData('Fri', 65, 60),
          ChartData('Sat', 69, 63),
          ChartData('Sun', 72, 66),
        ],
        cropVolumes: [
          CropVolumeData('Tomatoes', 3200 * scale, AnalyticsPage.green),
          CropVolumeData('Maize', 2800 * scale, AnalyticsPage.blue),
          CropVolumeData('Potatoes', 2100 * scale, AnalyticsPage.orange),
          CropVolumeData('Onions', 1700 * scale, AnalyticsPage.purple),
        ],
        categories: [
          CircularChartData('Vegetables', 48, AnalyticsPage.green),
          CircularChartData('Grains', 28, AnalyticsPage.blue),
          CircularChartData('Fruits', 14, AnalyticsPage.orange),
          CircularChartData('Others', 10, AnalyticsPage.purple),
        ],
        topProducts: [
          ProductLeaderboardItem('Tomatoes', 'Vegetables', '🍅', '\$${(22400 * scale).round()}', (185 * scale).round(), 0.97, 8.5),
          ProductLeaderboardItem('Maize', 'Grains', '🌽', '\$${(16800 * scale).round()}', (120 * scale).round(), 0.93, 3.4),
          ProductLeaderboardItem('Potatoes', 'Vegetables', '🥔', '\$${(9200 * scale).round()}', (94 * scale).round(), 0.90, -1.2),
          ProductLeaderboardItem('Onions', 'Vegetables', '🧅', '\$${(4740 * scale).round()}', (78 * scale).round(), 0.86, 2.1),
        ],
      );
    }

    if (_selectedTimeframe == '12 Months') {
      return AnalyticsMockDataset(
        revenue: '\$${(680200 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        revenueChange: '+22.5%',
        revenueSpark: [45000, 48000, 52000, 50000, 58000, 62000, 68000, 75200],
        orders: (12480 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
        ordersChange: '+14.3%',
        ordersSpark: [900, 950, 1100, 1050, 1200, 1300, 1450, 1530],
        buyers: '${(520 * scale).round()}',
        buyersChange: '+18.9%',
        buyersSpark: [320, 340, 380, 390, 420, 450, 490, 520],
        fulfillment: '96.5%',
        fulfillmentChange: '+3.1%',
        fulfillmentSpark: [92.5, 93.0, 94.1, 94.6, 95.2, 95.8, 96.2, 96.5],
        deliveries: '${(782 * scale).round()}',
        deliveriesChange: '+11.4%',
        deliveriesSpark: [135, 142, 148, 154, 162, 172, 181, 188],
        listings: '${(360 * scale).round()}',
        listingsChange: '+8.7%',
        listingsSpark: [240, 256, 270, 288, 302, 314, 330, 345],
        revenueTrend: [
          ChartData('Jan', 45000 * scale, 42000 * scale),
          ChartData('Feb', 48000 * scale, 45000 * scale),
          ChartData('Mar', 52000 * scale, 48000 * scale),
          ChartData('Apr', 50000 * scale, 50000 * scale),
          ChartData('May', 55000 * scale, 52000 * scale),
          ChartData('Jun', 58000 * scale, 55000 * scale),
          ChartData('Jul', 62000 * scale, 58000 * scale),
          ChartData('Aug', 60000 * scale, 60000 * scale),
          ChartData('Sep', 63000 * scale, 62000 * scale),
          ChartData('Oct', 68000 * scale, 65000 * scale),
          ChartData('Nov', 72000 * scale, 68000 * scale),
          ChartData('Dec', 75200 * scale, 70000 * scale),
        ],
        fulfillmentTrend: [
          ChartData('Jan', 92.4, 90.8),
          ChartData('Feb', 92.9, 91.2),
          ChartData('Mar', 93.3, 91.8),
          ChartData('Apr', 93.9, 92.4),
          ChartData('May', 94.5, 92.8),
          ChartData('Jun', 95.0, 93.2),
          ChartData('Jul', 95.4, 93.8),
          ChartData('Aug', 95.7, 94.2),
          ChartData('Sep', 95.9, 94.6),
          ChartData('Oct', 96.1, 95.0),
          ChartData('Nov', 96.4, 95.3),
          ChartData('Dec', 96.5, 95.5),
        ],
        deliveryTrend: [
          ChartData('Jan', 120, 115),
          ChartData('Feb', 128, 121),
          ChartData('Mar', 134, 126),
          ChartData('Apr', 138, 131),
          ChartData('May', 145, 137),
          ChartData('Jun', 151, 142),
          ChartData('Jul', 158, 148),
          ChartData('Aug', 163, 152),
          ChartData('Sep', 169, 157),
          ChartData('Oct', 176, 162),
          ChartData('Nov', 182, 169),
          ChartData('Dec', 188, 175),
        ],
        cropVolumes: [
          CropVolumeData('Tomatoes', 42000 * scale, AnalyticsPage.green),
          CropVolumeData('Maize', 38000 * scale, AnalyticsPage.blue),
          CropVolumeData('Potatoes', 30000 * scale, AnalyticsPage.orange),
          CropVolumeData('Onions', 22000 * scale, AnalyticsPage.purple),
        ],
        categories: [
          CircularChartData('Vegetables', 50, AnalyticsPage.green),
          CircularChartData('Grains', 25, AnalyticsPage.blue),
          CircularChartData('Fruits', 15, AnalyticsPage.orange),
          CircularChartData('Others', 10, AnalyticsPage.purple),
        ],
        topProducts: [
          ProductLeaderboardItem('Tomatoes', 'Vegetables', '🍅', '\$${(294000 * scale).round()}', (2480 * scale).round(), 0.98, 12.4),
          ProductLeaderboardItem('Maize', 'Grains', '🌽', '\$${(218000 * scale).round()}', (1910 * scale).round(), 0.94, 9.1),
          ProductLeaderboardItem('Potatoes', 'Vegetables', '🥔', '\$${(112000 * scale).round()}', (1420 * scale).round(), 0.92, 4.8),
          ProductLeaderboardItem('Onions', 'Vegetables', '🧅', '\$${(56200 * scale).round()}', (980 * scale).round(), 0.89, -0.6),
        ],
      );
    }

    return AnalyticsMockDataset(
      revenue: '\$${(12480 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
      revenueChange: '+12.4%',
      revenueSpark: [420, 520, 480, 680, 750, 840, 920],
      orders: '${(214 * scale).round()}',
      ordersChange: '+8.1%',
      ordersSpark: [18, 22, 19, 28, 31, 35, 42],
      buyers: '${(86 * scale).round()}',
      buyersChange: '+5.6%',
      buyersSpark: [72, 74, 76, 79, 81, 84, 86],
      fulfillment: '94.0%',
      fulfillmentChange: '+2.2%',
      fulfillmentSpark: [90.5, 91.2, 92.0, 92.5, 93.1, 93.8, 94.0],
      deliveries: '${(152 * scale).round()}',
      deliveriesChange: '+6.8%',
      deliveriesSpark: [24, 26, 28, 30, 33, 35, 38],
      listings: '${(96 * scale).round()}',
      listingsChange: '+4.1%',
      listingsSpark: [58, 62, 66, 70, 74, 78, 82],
      revenueTrend: [
        ChartData('Mon', 1200 * scale, 1100 * scale),
        ChartData('Tue', 1500 * scale, 1300 * scale),
        ChartData('Wed', 1400 * scale, 1400 * scale),
        ChartData('Thu', 2100 * scale, 1600 * scale),
        ChartData('Fri', 1800 * scale, 1800 * scale),
        ChartData('Sat', 2200 * scale, 2000 * scale),
        ChartData('Sun', 2280 * scale, 2100 * scale),
      ],
      fulfillmentTrend: [
        ChartData('Mon', 90.5, 89.2),
        ChartData('Tue', 91.0, 90.1),
        ChartData('Wed', 91.8, 90.8),
        ChartData('Thu', 92.2, 91.3),
        ChartData('Fri', 93.0, 91.9),
        ChartData('Sat', 93.7, 92.5),
        ChartData('Sun', 94.0, 93.0),
      ],
      deliveryTrend: [
        ChartData('Mon', 24, 20),
        ChartData('Tue', 26, 22),
        ChartData('Wed', 27, 24),
        ChartData('Thu', 31, 27),
        ChartData('Fri', 32, 29),
        ChartData('Sat', 35, 31),
        ChartData('Sun', 38, 33),
      ],
      cropVolumes: [
        CropVolumeData('Tomatoes', 850 * scale, AnalyticsPage.green),
        CropVolumeData('Maize', 620 * scale, AnalyticsPage.blue),
        CropVolumeData('Potatoes', 510 * scale, AnalyticsPage.orange),
        CropVolumeData('Onions', 390 * scale, AnalyticsPage.purple),
      ],
      categories: [
        CircularChartData('Vegetables', 45, AnalyticsPage.green),
        CircularChartData('Grains', 30, AnalyticsPage.blue),
        CircularChartData('Fruits', 15, AnalyticsPage.orange),
        CircularChartData('Others', 10, AnalyticsPage.purple),
      ],
      topProducts: [
        ProductLeaderboardItem('Tomatoes', 'Vegetables', '🍅', '\$${(5240 * scale).round()}', (42 * scale).round(), 0.96, 4.2),
        ProductLeaderboardItem('Maize', 'Grains', '🌽', '\$${(3980 * scale).round()}', (31 * scale).round(), 0.91, -2.1),
        ProductLeaderboardItem('Potatoes', 'Vegetables', '🥔', '\$${(2160 * scale).round()}', (24 * scale).round(), 0.88, 1.8),
        ProductLeaderboardItem('Onions', 'Vegetables', '🧅', '\$${(1100 * scale).round()}', (19 * scale).round(), 0.84, 0.5),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Refine view', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeframes.map((item) => ChoiceChip(
                label: Text(item),
                selected: _selectedTimeframe == item,
                onSelected: (_) {
                  setState(() => _selectedTimeframe = item);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _regions.map((item) => ChoiceChip(
                label: Text(item),
                selected: _selectedRegion == item,
                onSelected: (_) {
                  setState(() => _selectedRegion = item);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _exportCSV() async {
    final dataset = _getDataset();
    final rows = [
      ['Analytics Report', 'Timeframe: $_selectedTimeframe', 'Region: $_selectedRegion'],
      [],
      ['Metric', 'Value', 'Change'],
      ['Revenue', dataset.revenue, dataset.revenueChange],
      ['Orders', dataset.orders, dataset.ordersChange],
      ['Buyers', dataset.buyers, dataset.buyersChange],
      ['Fulfillment', dataset.fulfillment, dataset.fulfillmentChange],
      ['Deliveries', dataset.deliveries, dataset.deliveriesChange],
      ['Listings', dataset.listings, dataset.listingsChange],
    ];

    try {
      final file = await AnalyticsExportService.exportCsv(
        rows: rows,
        fileName: 'verdi_analytics_${_selectedTimeframe.toLowerCase().replaceAll(' ', '_')}.csv',
      );
      _showExportSuccessDialog(file.path);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _exportPDF() async {
    final dataset = _getDataset();
    final summaryLines = [
      'Timeframe: $_selectedTimeframe',
      'Region: $_selectedRegion',
      'Revenue Summary: ${dataset.revenue} (${dataset.revenueChange})',
      'Fulfillment Efficiency: ${dataset.fulfillment}',
      'Active Buyers: ${dataset.buyers}',
      'Total Orders: ${dataset.orders}',
      'Total Deliveries: ${dataset.deliveries}',
      '',
      'Executive Highlights:',
      '- Demand remains strongest in the southern corridor.',
      '- Delivery reliability is improving faster than order volume.',
    ];

    try {
      final file = await AnalyticsExportService.exportPdf(
        title: 'Verdi Executive Intelligence Report',
        summaryLines: summaryLines,
        fileName: 'verdi_analytics_${_selectedTimeframe.toLowerCase().replaceAll(' ', '_')}.pdf',
      );
      _showExportSuccessDialog(file.path);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _exportOrderSummary() async {
    final orders = ref.read(ordersListProvider);
    final rows = orders.map((o) => {
      'id': o.id,
      'buyer': o.buyer,
      'product': o.product,
      'quantity': o.quantity,
      'destination': o.destination,
      'status': o.status,
      'payment': o.payment,
      'total': o.total,
      'date': o.date,
      'eta': o.eta,
      'priority': o.priority,
    }).toList();

    try {
      final file = await AnalyticsExportService.exportOrderSummary(orders: rows);
      _showExportSuccessDialog(file.path);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _exportFullReport() async {
    final dataset = _getDataset();
    try {
      final file = await AnalyticsExportService.exportFullPdfReport(
        title: 'Verdi Platform Intelligence Report',
        timeframe: _selectedTimeframe,
        region: _selectedRegion,
        kpiLines: [
          'Revenue: ${dataset.revenue} (${dataset.revenueChange})',
          'Orders: ${dataset.orders} (${dataset.ordersChange})',
          'Active Buyers: ${dataset.buyers} (${dataset.buyersChange})',
          'Order Fulfillment: ${dataset.fulfillment} (${dataset.fulfillmentChange})',
        ],
        deliveryLines: [
          'On-Time Rate: 92.0%',
          'Avg ETA Accuracy: 2h 18m',
          'Deliveries Today: 3',
          'Failed / Cancelled: 1',
        ],
        marketplaceLines: dataset.topProducts.map((p) => '${p.name} (${p.category}): ${p.sales} revenue, ${p.ordersCount} orders, ${(p.completion * 100).round()}% completion, ${p.trend > 0 ? '+' : ''}${p.trend.toStringAsFixed(1)}% trend').toList(),
        fileName: 'verdi_platform_report.pdf',
      );
      _showExportSuccessDialog(file.path);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showExportSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: AnalyticsPage.green, size: 28),
            SizedBox(width: 10),
            Text('Export Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your report was exported successfully.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: SelectableText(path, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AnalyticsPage.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to export: $error'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataset = _getDataset();
    final role = ref.watch(appStateProvider).role;

    return Scaffold(
      backgroundColor: AnalyticsPage.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(role),
              const SizedBox(height: 18),
              _buildRoleBanner(role),
              const SizedBox(height: 18),
              _buildKpiGrid(dataset),
              const SizedBox(height: 20),
              _buildTrendSection(dataset),
              const SizedBox(height: 20),
              _buildMarketSection(dataset),
              const SizedBox(height: 20),
              _buildIntelligenceSection(),
              const SizedBox(height: 20),
              _buildGeographySection(),
              const SizedBox(height: 20),
              _buildLeaderboardSection(dataset),
              const SizedBox(height: 20),
              _buildActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic role) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analytics', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
                    const SizedBox(height: 4),
                    Text('Farm, market, delivery, and growth performance in one executive cockpit.', style: GoogleFonts.inter(fontSize: 13.5, color: AnalyticsPage.muted, height: 1.4)),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _headerChip('Date Range', _selectedDateRange, Icons.calendar_today_outlined),
                  _headerChip('Compare', _selectedComparePeriod, Icons.compare_arrows_outlined),
                  _headerChip('Region', _selectedRegion, Icons.public_outlined),
                  _actionButton(Icons.ios_share_outlined, 'Export', () => _showExportMenu()),
                  _actionButton(Icons.filter_list_outlined, 'Filter', _showFilterSheet),
                  _actionButton(Icons.notifications_none_outlined, '', () {}),
                  _profileChip(role),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pillSelector('7 Days', _selectedTimeframe, (value) => setState(() => _selectedTimeframe = value)),
              _pillSelector('30 Days', _selectedTimeframe, (value) => setState(() => _selectedTimeframe = value)),
              _pillSelector('12 Months', _selectedTimeframe, (value) => setState(() => _selectedTimeframe = value)),
              _dropdownPill('Compare', _selectedComparePeriod, _comparePeriods, (value) => setState(() => _selectedComparePeriod = value)),
              _dropdownPill('Range', _selectedDateRange, _dateRanges, (value) => setState(() => _selectedDateRange = value)),
              _dropdownPill('Region', _selectedRegion, _regions, (value) => setState(() => _selectedRegion = value)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBanner(dynamic role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AnalyticsPage.green.withOpacity(0.08), AnalyticsPage.blue.withOpacity(0.06)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnalyticsPage.green.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(role.icon, color: AnalyticsPage.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Role intelligence: ${role.categoryTag} analytics for ${role.label}. This view highlights demand, logistics, buyer reach, and operational risks most relevant to your work.',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AnalyticsPage.dark, height: 1.35),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AnalyticsPage.green.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
            child: Text(role.hasFullAnalytics ? 'Full Access' : 'Role View', style: TextStyle(color: AnalyticsPage.green, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(AnalyticsMockDataset dataset) {
    final cards = [
      _kpiCard('Total Revenue', dataset.revenue, dataset.revenueChange, Icons.payments_outlined, AnalyticsPage.green, dataset.revenueSpark, 'vs ${_selectedComparePeriod.toLowerCase()}'),
      _kpiCard('Total Orders', dataset.orders, dataset.ordersChange, Icons.receipt_long_outlined, AnalyticsPage.blue, dataset.ordersSpark, 'order momentum'),
      _kpiCard('Total Deliveries', dataset.deliveries, dataset.deliveriesChange, Icons.local_shipping_outlined, AnalyticsPage.orange, dataset.deliveriesSpark, 'shipment cadence'),
      _kpiCard('Active Listings', dataset.listings, dataset.listingsChange, Icons.storefront_outlined, AnalyticsPage.purple, dataset.listingsSpark, 'market visibility'),
      _kpiCard('Active Buyers', dataset.buyers, dataset.buyersChange, Icons.people_outline, AnalyticsPage.dark, dataset.buyersSpark, 'buyer retention'),
      _kpiCard('Fulfillment Rate', dataset.fulfillment, dataset.fulfillmentChange, Icons.verified_outlined, AnalyticsPage.green, dataset.fulfillmentSpark, 'service quality'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 1080 ? 3 : constraints.maxWidth > 720 ? 2 : 1;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.7,
          children: cards,
        );
      },
    );
  }

  Widget _buildTrendSection(AnalyticsMockDataset dataset) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 940;
        final revenueCard = _sectionCard(
          title: 'Revenue over time',
          subtitle: 'Revenue is up ${dataset.revenueChange} against the prior window.',
          child: SizedBox(height: 260, child: _buildRevenueChart(dataset.revenueTrend)),
        );
        final ordersCard = _sectionCard(
          title: 'Orders and deliveries',
          subtitle: 'Demand is outpacing execution in the key logistics corridors.',
          child: SizedBox(height: 260, child: _buildOrdersDeliveryChart(dataset)),
        );
        final projectionCard = _sectionCard(
          title: 'Revenue vs target projection',
          subtitle: 'Visible headroom remains strong across the current operating cycle.',
          child: SizedBox(height: 260, child: _buildProjectionChart(dataset.revenueTrend)),
        );
        final fulfillmentCard = _sectionCard(
          title: 'Fulfillment trend',
          subtitle: 'Reliability continues to improve after recent routing adjustments.',
          child: SizedBox(height: 260, child: _buildFulfillmentChart(dataset.fulfillmentTrend)),
        );

        if (isWide) {
          return Column(
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: revenueCard),
                const SizedBox(width: 16),
                Expanded(child: ordersCard),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: projectionCard),
                const SizedBox(width: 16),
                Expanded(child: fulfillmentCard),
              ]),
            ],
          );
        }

        return Column(children: [revenueCard, const SizedBox(height: 16), ordersCard, const SizedBox(height: 16), projectionCard, const SizedBox(height: 16), fulfillmentCard]);
      },
    );
  }

  Widget _buildMarketSection(AnalyticsMockDataset dataset) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 980;
        final volumeCard = _sectionCard(title: 'Crop volume', subtitle: 'Current trade activity by commodity', child: SizedBox(height: 260, child: _buildVolumeChart(dataset.cropVolumes)));
        final shareCard = _sectionCard(title: 'Revenue share by category', subtitle: 'The portfolio is still weighted to vegetables and grains', child: SizedBox(height: 260, child: _buildCategoryChart(dataset.categories)));
        final breakdownCard = _sectionCard(title: 'Category breakdown', subtitle: 'High-value categories are improving in relative share', child: _buildCategoryBreakdown(dataset.categories));
        final productCard = _sectionCard(title: 'Top performing crops', subtitle: 'Tomatoes remain the strongest regional driver', child: Column(children: dataset.topProducts.take(3).map((item) => _leaderboardRow(item)).toList()));

        if (isWide) {
          return Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: volumeCard), const SizedBox(width: 16), Expanded(child: shareCard)]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: breakdownCard), const SizedBox(width: 16), Expanded(child: productCard)]),
          ]);
        }

        return Column(children: [volumeCard, const SizedBox(height: 16), shareCard, const SizedBox(height: 16), breakdownCard, const SizedBox(height: 16), productCard]);
      },
    );
  }

  Widget _buildIntelligenceSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AnalyticsPage.green.withOpacity(0.06), AnalyticsPage.purple.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnalyticsPage.green.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Icon(Icons.auto_awesome_outlined, color: AnalyticsPage.green), SizedBox(width: 8), Text('Executive intelligence', style: TextStyle(color: AnalyticsPage.green, fontWeight: FontWeight.w800, fontSize: 16))]),
          const SizedBox(height: 10),
          Text('Demand is rising in the southern corridor while onion supply remains tighter than expected, creating stronger margins on premium lots.', style: GoogleFonts.inter(fontSize: 14, color: AnalyticsPage.dark, height: 1.45)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _insightPill('Regional opportunity', Icons.trending_up_outlined, AnalyticsPage.green),
            _insightPill('Supply shortage', Icons.warning_amber_rounded, AnalyticsPage.orange),
            _insightPill('Delivery risk', Icons.route_outlined, AnalyticsPage.blue),
            _insightPill('Pricing suggestion', Icons.attach_money_outlined, AnalyticsPage.purple),
          ]),
          const SizedBox(height: 12),
          const Text('Recommended next actions: rebalance inventory toward potatoes, prioritize afternoon dispatch in Chiredzi, and publish morning listing updates for higher conversion.', style: TextStyle(color: AnalyticsPage.muted, fontSize: 13, height: 1.45)),
        ],
      ),
    );
  }

  Widget _buildGeographySection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;
        final mapCard = _sectionCard(
          title: 'Buyer locations',
          subtitle: 'Regional concentration of active buyers',
          child: IgnorePointer(
            child: Container(
              height: 280,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: const MapOptions(initialCenter: LatLng(-19.5, 30.5), initialZoom: 6.8),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.verdi.app'),
                    MarkerLayer(markers: const [
                      Marker(point: LatLng(-17.8292, 31.0522), width: 40, height: 40, child: Icon(Icons.location_pin, color: Colors.red, size: 28)),
                      Marker(point: LatLng(-20.0637, 30.8276), width: 40, height: 40, child: Icon(Icons.location_pin, color: Colors.blue, size: 28)),
                      Marker(point: LatLng(-21.05, 31.67), width: 40, height: 40, child: Icon(Icons.location_pin, color: Colors.green, size: 28)),
                      Marker(point: LatLng(-18.97, 32.67), width: 40, height: 40, child: Icon(Icons.location_pin, color: Colors.orange, size: 28)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );

        final reachCard = _sectionCard(
          title: 'Customer reach',
          subtitle: 'Growth and engagement metrics',
          child: GridView.count(
            crossAxisCount: isWide ? 2 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _buildReachMetric('Profile Views', '1,420', '+12.4%', Icons.visibility_outlined, Colors.blue),
              _buildReachMetric('Unique Visitors', '950', '+8.2%', Icons.people_outline, Colors.teal),
              _buildReachMetric('Inquiries Received', '185', '+15.3%', Icons.chat_bubble_outline, Colors.purple),
              _buildReachMetric('Conversion Rate', '13.0%', '+2.5%', Icons.swap_horiz_outlined, Colors.orange),
            ],
          ),
        );

        if (isWide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: mapCard), const SizedBox(width: 16), Expanded(flex: 1, child: reachCard)]);
        }

        return Column(children: [mapCard, const SizedBox(height: 16), reachCard]);
      },
    );
  }

  Widget _buildLeaderboardSection(AnalyticsMockDataset dataset) {
    return _sectionCard(
      title: 'Performance leaderboard',
      subtitle: 'Products and categories outperforming the rest of the portfolio',
      child: Column(children: dataset.topProducts.map((item) => _leaderboardRow(item)).toList()),
    );
  }

  Widget _buildActivitySection() {
    final events = [
      _ActivityEvent('New order created', 'Order #1003 moved into confirmed status', Icons.add_circle_outline, AnalyticsPage.green),
      _ActivityEvent('Delivery completed', 'ZW-14 arrived in Chiredzi on schedule', Icons.local_shipping_outlined, AnalyticsPage.blue),
      _ActivityEvent('Listing published', 'Potato lot updated for the morning market window', Icons.storefront_outlined, AnalyticsPage.orange),
      _ActivityEvent('Payment received', 'Settlement posted for the last wholesale batch', Icons.payments_outlined, AnalyticsPage.purple),
      _ActivityEvent('Stock adjusted', 'Onion reserve trimmed after demand spike', Icons.inventory_2_outlined, Colors.teal),
    ];

    return _sectionCard(
      title: 'Recent activity',
      subtitle: 'Operational momentum and live business events',
      child: Column(children: events.map((event) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: event.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(event.icon, color: event.color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AnalyticsPage.dark)), const SizedBox(height: 2), Text(event.detail, style: const TextStyle(color: AnalyticsPage.muted, fontSize: 12))]))]))).toList()),
    );
  }

  Widget _sectionCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12.5, color: AnalyticsPage.muted)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _kpiCard(String title, String value, String change, IconData icon, Color color, List<double> sparkData, String note) {
    final isNegative = change.startsWith('-');
    final changeColor = isNegative ? Colors.redAccent : color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(color: AnalyticsPage.muted, fontSize: 12.5, fontWeight: FontWeight.w700)))]),
        const SizedBox(height: 14),
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        const SizedBox(height: 6),
        Row(children: [Icon(isNegative ? Icons.south_east : Icons.north_east, size: 12, color: changeColor), const SizedBox(width: 4), Text(change, style: TextStyle(color: changeColor, fontSize: 11.5, fontWeight: FontWeight.w700)), const SizedBox(width: 8), Text(note, style: const TextStyle(color: AnalyticsPage.muted, fontSize: 10.5, fontWeight: FontWeight.w600))]),
        const SizedBox(height: 12),
        SizedBox(height: 24, width: double.infinity, child: CustomPaint(painter: SparklinePainter(sparkData, color))),
      ]),
    );
  }

  Widget _buildRevenueChart(List<ChartData> data) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      primaryYAxis: const NumericAxis(axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        SplineAreaSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.actual, color: AnalyticsPage.green.withOpacity(0.14), borderColor: AnalyticsPage.green, borderWidth: 2.5),
        SplineSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.target, color: AnalyticsPage.muted.withOpacity(0.4), width: 1.5),
      ],
    );
  }

  Widget _buildOrdersDeliveryChart(AnalyticsMockDataset dataset) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      primaryYAxis: const NumericAxis(axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(dataSource: dataset.revenueTrend, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.actual, color: AnalyticsPage.blue, width: 0.28),
        LineSeries<ChartData, String>(dataSource: dataset.deliveryTrend, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.actual, color: AnalyticsPage.orange, markerSettings: const MarkerSettings(isVisible: true)),
      ],
    );
  }

  Widget _buildProjectionChart(List<ChartData> data) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      primaryYAxis: const NumericAxis(axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        SplineAreaSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.target, color: AnalyticsPage.muted.withOpacity(0.12), borderColor: AnalyticsPage.muted.withOpacity(0.55), borderWidth: 1.5),
        SplineAreaSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.actual, color: AnalyticsPage.green.withOpacity(0.16), borderColor: AnalyticsPage.green, borderWidth: 2.5),
      ],
    );
  }

  Widget _buildFulfillmentChart(List<ChartData> data) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      primaryYAxis: const NumericAxis(axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        LineSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.actual, color: AnalyticsPage.green, markerSettings: const MarkerSettings(isVisible: true)),
        LineSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.target, color: AnalyticsPage.blue, dashArray: const <double>[5, 5], markerSettings: const MarkerSettings(isVisible: false)),
      ],
    );
  }

  Widget _buildVolumeChart(List<CropVolumeData> data) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      primaryYAxis: const NumericAxis(axisLine: AxisLine(width: 0), majorTickLines: MajorTickLines(size: 0), labelStyle: TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<CropVolumeData, String>>[
        ColumnSeries<CropVolumeData, String>(dataSource: data, xValueMapper: (d, _) => d.crop, yValueMapper: (d, _) => d.volume, pointColorMapper: (d, _) => d.color, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), dataLabelSettings: const DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside)),
      ],
    );
  }

  Widget _buildCategoryChart(List<CircularChartData> data) {
    return SfCircularChart(
      legend: const Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap, textStyle: TextStyle(color: AnalyticsPage.dark, fontSize: 11, fontWeight: FontWeight.bold)),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries<CircularChartData, String>>[
        DoughnutSeries<CircularChartData, String>(dataSource: data, xValueMapper: (d, _) => d.category, yValueMapper: (d, _) => d.value, pointColorMapper: (d, _) => d.color, innerRadius: '65%', explode: true, explodeIndex: 0),
      ],
    );
  }

  Widget _buildCategoryBreakdown(List<CircularChartData> data) {
    return Column(children: data.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Text(item.category, style: const TextStyle(fontWeight: FontWeight.w600, color: AnalyticsPage.dark))), Text('${item.value}%', style: const TextStyle(fontWeight: FontWeight.w700, color: AnalyticsPage.dark))]))).toList());
  }

  Widget _buildReachMetric(String label, String value, String growth, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: color, size: 20), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(6)), child: Text(growth, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)))]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)), const SizedBox(height: 2), Text(label, style: GoogleFonts.inter(fontSize: 11, color: AnalyticsPage.muted, fontWeight: FontWeight.w500))]),
      ]),
    );
  }

  Widget _leaderboardRow(ProductLeaderboardItem item) {
    final isNegative = item.trend < 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AnalyticsPage.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black.withOpacity(0.04))),
        child: Row(children: [
          Container(width: 38, height: 38, alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Text(item.emoji, style: const TextStyle(fontSize: 18))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, style: const TextStyle(color: AnalyticsPage.dark, fontWeight: FontWeight.w700, fontSize: 13)), Text(item.category, style: const TextStyle(color: AnalyticsPage.muted, fontSize: 11, fontWeight: FontWeight.w600))])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(item.sales, style: const TextStyle(color: AnalyticsPage.dark, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 2), Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(isNegative ? Icons.trending_down : Icons.trending_up, size: 11, color: isNegative ? Colors.red : AnalyticsPage.green), const SizedBox(width: 2), Text('${isNegative ? '' : '+'}${item.trend.toStringAsFixed(1)}%', style: TextStyle(color: isNegative ? Colors.red : AnalyticsPage.green, fontSize: 10.5, fontWeight: FontWeight.bold))])])),
        ]),
      ),
    );
  }

  Widget _headerChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AnalyticsPage.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: AnalyticsPage.green), const SizedBox(width: 6), Text('$label: $value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AnalyticsPage.dark))]),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: AnalyticsPage.dark), if (label.isNotEmpty) ...[const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AnalyticsPage.dark))]]),
      ),
    );
  }

  Widget _profileChip(dynamic role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: AnalyticsPage.green.withOpacity(0.1), borderRadius: BorderRadius.circular(999), border: Border.all(color: AnalyticsPage.green.withOpacity(0.18))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 12, backgroundColor: AnalyticsPage.green, child: Text(role.label.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))), const SizedBox(width: 8), Text(role.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AnalyticsPage.dark))]),
    );
  }

  Widget _pillSelector(String label, String selectedValue, ValueChanged<String> onChanged) {
    final isSelected = selectedValue == label;
    return InkWell(
      onTap: () => onChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? AnalyticsPage.green : Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: isSelected ? AnalyticsPage.green : Colors.black12)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AnalyticsPage.dark, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _dropdownPill(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.black12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(color: AnalyticsPage.dark, fontWeight: FontWeight.w700, fontSize: 12),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AnalyticsPage.muted),
          onChanged: (val) { if (val != null) onChanged(val); },
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        ),
      ),
    );
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.picture_as_pdf_outlined, color: AnalyticsPage.green), title: const Text('Executive PDF'), onTap: () { Navigator.pop(context); _exportPDF(); }),
          ListTile(leading: const Icon(Icons.table_view_outlined, color: AnalyticsPage.blue), title: const Text('Analytics CSV'), onTap: () { Navigator.pop(context); _exportCSV(); }),
          ListTile(leading: const Icon(Icons.receipt_long_outlined, color: AnalyticsPage.orange), title: const Text('Order Summary'), onTap: () { Navigator.pop(context); _exportOrderSummary(); }),
          ListTile(leading: const Icon(Icons.summarize_outlined, color: AnalyticsPage.purple), title: const Text('Full Platform Report'), onTap: () { Navigator.pop(context); _exportFullReport(); }),
        ]),
      ),
    );
  }

  Widget _insightPill(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(0.16))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))]),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final fillPaint = Paint()..color = color.withOpacity(0.08)..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) => oldDelegate.data != data || oldDelegate.color != color;
}

class ChartData {
  final String x;
  final double actual;
  final double target;

  ChartData(this.x, this.actual, this.target);
}

class CropVolumeData {
  final String crop;
  final double volume;
  final Color color;

  CropVolumeData(this.crop, this.volume, this.color);
}

class CircularChartData {
  final String category;
  final double value;
  final Color color;

  CircularChartData(this.category, this.value, this.color);
}

class AnalyticsMockDataset {
  final String revenue;
  final String revenueChange;
  final List<double> revenueSpark;
  final String orders;
  final String ordersChange;
  final List<double> ordersSpark;
  final String buyers;
  final String buyersChange;
  final List<double> buyersSpark;
  final String fulfillment;
  final String fulfillmentChange;
  final List<double> fulfillmentSpark;
  final String deliveries;
  final String deliveriesChange;
  final List<double> deliveriesSpark;
  final String listings;
  final String listingsChange;
  final List<double> listingsSpark;
  final List<ChartData> revenueTrend;
  final List<ChartData> fulfillmentTrend;
  final List<ChartData> deliveryTrend;
  final List<CropVolumeData> cropVolumes;
  final List<CircularChartData> categories;
  final List<ProductLeaderboardItem> topProducts;

  AnalyticsMockDataset({
    required this.revenue,
    required this.revenueChange,
    required this.revenueSpark,
    required this.orders,
    required this.ordersChange,
    required this.ordersSpark,
    required this.buyers,
    required this.buyersChange,
    required this.buyersSpark,
    required this.fulfillment,
    required this.fulfillmentChange,
    required this.fulfillmentSpark,
    required this.deliveries,
    required this.deliveriesChange,
    required this.deliveriesSpark,
    required this.listings,
    required this.listingsChange,
    required this.listingsSpark,
    required this.revenueTrend,
    required this.fulfillmentTrend,
    required this.deliveryTrend,
    required this.cropVolumes,
    required this.categories,
    required this.topProducts,
  });
}

class ProductLeaderboardItem {
  final String name;
  final String category;
  final String emoji;
  final String sales;
  final int ordersCount;
  final double completion;
  final double trend;

  ProductLeaderboardItem(this.name, this.category, this.emoji, this.sales, this.ordersCount, this.completion, this.trend);
}

class _ActivityEvent {
  final String title;
  final String detail;
  final IconData icon;
  final Color color;

  _ActivityEvent(this.title, this.detail, this.icon, this.color);
}
