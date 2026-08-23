import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> with SingleTickerProviderStateMixin {
  int _activeTab = 0;
  String _selectedTimeframe = '7 Days';
  String _selectedRegion = 'All Regions';
  UserRole? _perspectiveOverride;

  // What-If Yield & ROI Simulator State Variables
  double _simNitrogen = 120.0; // kg/ha
  double _simWaterQuota = 85.0; // %
  double _simMarketPrice = 310.0; // $/ton

  final List<String> _timeframes = const ['7 Days', '30 Days', '12 Months'];
  final List<String> _regions = const ['All Regions', 'Masvingo', 'Chiredzi', 'Mutare', 'Harare'];

  bool get _isTestEnvironment {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

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
    final isDemo = ref.watch(isDemoModeProvider);
    final scale = _getRegionScale();

    if (!isDemo) {
      final orders = ref.watch(ordersListProvider);
      final totalRev = orders.where((o) => o.payment == 'Paid').fold<double>(0, (sum, o) {
        final val = double.tryParse(o.total.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        return sum + val;
      });
      final deliveryCount = orders.where((o) => o.status == 'Delivered' || o.status == 'In Transit').length;

      return AnalyticsMockDataset(
        revenue: '\$${totalRev.toStringAsFixed(0)}',
        revenueChange: '+0.0%',
        orders: '${orders.length}',
        ordersChange: '+0.0%',
        buyers: '${orders.map((o) => o.buyer).toSet().length}',
        buyersChange: '+0.0%',
        fulfillment: orders.isEmpty ? '100%' : '98.0%',
        fulfillmentChange: '+0.0%',
        deliveries: '$deliveryCount',
        deliveriesChange: '+0.0%',
        listings: '0',
        listingsChange: '+0.0%',
        revenueTrend: [
          ChartData('Wk 1', 0, 0),
          ChartData('Wk 2', 0, 0),
          ChartData('Wk 3', 0, 0),
          ChartData('Wk 4', totalRev, totalRev),
        ],
        fulfillmentTrend: [],
        cropVolumes: [],
        categories: [],
        topProducts: [],
      );
    }

    if (_selectedTimeframe == '30 Days') {
      return AnalyticsMockDataset(
        revenue: '\$${(52140 * scale).round()}',
        revenueChange: '+15.8%',
        orders: '${(945 * scale).round()}',
        ordersChange: '+10.2%',
        buyers: '${(142 * scale).round()}',
        buyersChange: '+7.4%',
        fulfillment: '95.0%',
        fulfillmentChange: '+1.8%',
        deliveries: '${(318 * scale).round()}',
        deliveriesChange: '+9.1%',
        listings: '${(204 * scale).round()}',
        listingsChange: '+6.3%',
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
        revenue: '\$${(680200 * scale).round()}',
        revenueChange: '+22.5%',
        orders: '${(12480 * scale).round()}',
        ordersChange: '+14.3%',
        buyers: '${(520 * scale).round()}',
        buyersChange: '+18.9%',
        fulfillment: '96.5%',
        fulfillmentChange: '+3.1%',
        deliveries: '${(782 * scale).round()}',
        deliveriesChange: '+11.4%',
        listings: '${(360 * scale).round()}',
        listingsChange: '+8.7%',
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
      revenue: '\$${(12480 * scale).round()}',
      revenueChange: '+12.4%',
      orders: '${(214 * scale).round()}',
      ordersChange: '+8.1%',
      buyers: '${(86 * scale).round()}',
      buyersChange: '+5.6%',
      fulfillment: '94.0%',
      fulfillmentChange: '+2.2%',
      deliveries: '${(152 * scale).round()}',
      deliveriesChange: '+6.8%',
      listings: '${(96 * scale).round()}',
      listingsChange: '+4.1%',
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Refine Intelligence Scope', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text('Timeframe Selection:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AnalyticsPage.muted)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _timeframes.map((item) => ChoiceChip(
                label: Text(item),
                selected: _selectedTimeframe == item,
                selectedColor: AnalyticsPage.green,
                labelStyle: TextStyle(color: _selectedTimeframe == item ? Colors.white : AnalyticsPage.dark),
                onSelected: (_) { setState(() => _selectedTimeframe = item); Navigator.pop(context); },
              )).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Region Scope:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AnalyticsPage.muted)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _regions.map((item) => ChoiceChip(
                label: Text(item),
                selected: _selectedRegion == item,
                selectedColor: AnalyticsPage.green,
                labelStyle: TextStyle(color: _selectedRegion == item ? Colors.white : AnalyticsPage.dark),
                onSelected: (_) { setState(() => _selectedRegion = item); Navigator.pop(context); },
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
      ['Analytics Executive Intelligence', 'Timeframe: $_selectedTimeframe', 'Region: $_selectedRegion'],
      [],
      ['Metric', 'Value', 'Change'],
      ['Revenue', dataset.revenue, dataset.revenueChange],
      ['Orders', dataset.orders, dataset.ordersChange],
      ['Buyers', dataset.buyers, dataset.buyersChange],
      ['Fulfillment', dataset.fulfillment, dataset.fulfillmentChange],
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
      '',
      'Executive Intelligence Summary:',
      '- High demand for white maize and horticulture across SADC.',
      '- Delivery turnaround speed at record efficiency.',
    ];

    try {
      final file = await AnalyticsExportService.exportPdf(
        title: 'Verdi Agricultural Intelligence & ROI Report',
        summaryLines: summaryLines,
        fileName: 'verdi_analytics_${_selectedTimeframe.toLowerCase().replaceAll(' ', '_')}.pdf',
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
        title: Row(children: const [Icon(Icons.check_circle_outline, color: AnalyticsPage.green, size: 28), SizedBox(width: 10), Text('Export Successful')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your report was generated successfully.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: Text(path, style: const TextStyle(fontSize: 11, color: AnalyticsPage.muted)),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $error'), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataset = _getDataset();
    final appState = ref.watch(appStateProvider);
    final realRole = appState.role;
    final buyerSubRole = appState.buyerSubRole;
    final isSuperAdmin = realRole == UserRole.admin;
    final effectiveRole = isSuperAdmin ? (_perspectiveOverride ?? UserRole.admin) : realRole;

    final isB2BBuyer = effectiveRole == UserRole.buyer && buyerSubRole == BuyerSubRole.retailerWholesaler;
    final isEndUser = (effectiveRole == UserRole.buyer && buyerSubRole == BuyerSubRole.endUserCustomer) || effectiveRole == UserRole.consumer;

    if (isB2BBuyer) {
      return _B2BBuyerAnalyticsView(
        isSuperAdmin: isSuperAdmin,
        onPerspectiveSelected: (r) => setState(() => _perspectiveOverride = r),
      );
    }

    if (isEndUser) {
      return Scaffold(
        backgroundColor: AnalyticsPage.background,
        appBar: AppBar(
          title: Text('Analytics', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AnalyticsPage.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.analytics_outlined, size: 48, color: AnalyticsPage.green),
                ),
                const SizedBox(height: 16),
                Text(
                  'Commercial Analytics Portal',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18, color: AnalyticsPage.dark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Analytics tools are reserved exclusively for B2B Commercial Buyers, Producers, and Wholesalers.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: AnalyticsPage.muted),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.read(appStateProvider.notifier).setNavIndex(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnalyticsPage.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Return to Store & Home', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AnalyticsPage.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              switch (effectiveRole) {
                UserRole.farmer => 'Field & Yield Analytics',
                UserRole.transporter => 'Freight & Logistics Analytics',
                UserRole.buyer => 'Supply Chain Sourcing Analytics',
                UserRole.expert => 'Agronomy Diagnostic Analytics',
                UserRole.financier => 'Agri-Credit Portfolio Analytics',
                UserRole.valueAdder => 'Agri-Processing Analytics',
                UserRole.government => 'Grain Security & Trade Analytics',
                UserRole.consumer => 'Commercial Value Chain Analytics',
                UserRole.admin => 'Executive Value Chain Analytics',
              },
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 15, color: AnalyticsPage.dark),
            ),
            Text(
              'Spatial Telemetry & Predictive AI',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, color: AnalyticsPage.muted, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined, color: AnalyticsPage.dark),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.picture_as_pdf_outlined, color: AnalyticsPage.red),
                      title: const Text('Export Executive PDF Report'),
                      onTap: () { Navigator.pop(context); _exportPDF(); },
                    ),
                    ListTile(
                      leading: const Icon(Icons.table_chart_outlined, color: AnalyticsPage.green),
                      title: const Text('Export Telemetry CSV Data'),
                      onTap: () { Navigator.pop(context); _exportCSV(); },
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.filter_list_outlined, color: AnalyticsPage.dark), onPressed: _showFilterSheet),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E))),
                    const SizedBox(width: 8),
                    Text('LIVE TELEMETRY PULSE: ', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E), letterSpacing: 1.0)),
                    Text('Satellite Pass Landsat-9 Active (NDVI 0.84) • Soil N-P-K Ratio: 14:14:12 • Beira Corridor Clearance: 18m • White Maize Spot Floor: \$290/MT (↑3.5%) • Cold-Chain Temp: +3.2°C', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(0, '📊 Executive Command', Icons.dashboard_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(1, '🛰️ Soil & Spatial Telemetry', Icons.radar_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(2, '💸 Commodity Pricing AI', Icons.show_chart_outlined),
                    const SizedBox(width: 8),
                    _buildTabChip(3, '⚡ Yield & ROI Simulator', Icons.auto_awesome_outlined),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isSuperAdmin) ...[
                          _SuperAdminPerspectiveSelector(selectedRole: _perspectiveOverride ?? UserRole.admin, onRoleSelected: (r) => setState(() => _perspectiveOverride = r)),
                          const SizedBox(height: 16),
                        ],
                        if (_activeTab == 0) _buildExecutiveTab(dataset, effectiveRole, isSuperAdmin),
                        if (_activeTab == 1) _buildGeospatialTab(),
                        if (_activeTab == 2) _buildCommodityFuturesTab(),
                        if (_activeTab == 3) _buildYieldSimulatorTab(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? AnalyticsPage.green : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : AnalyticsPage.dark),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.white : AnalyticsPage.dark)),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveTab(AnalyticsMockDataset dataset, UserRole effectiveRole, bool isSuperAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SpatialBanner(),
        const SizedBox(height: 16),
        _RoleScopeBanner(role: effectiveRole, isSuperAdmin: isSuperAdmin),
        const SizedBox(height: 16),
        _AiAdvisoryCard(role: effectiveRole),
        const SizedBox(height: 16),
        _buildTailoredKpiGrid(dataset, effectiveRole),
        const SizedBox(height: 20),
        Text('Trade & Delivery Trends', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            if (wide) {
              return Row(
                children: [
                  Expanded(child: _sectionCard(title: 'Revenue over time', subtitle: 'Actual vs Target values', child: SizedBox(height: 240, child: _buildRevenueChart(dataset.revenueTrend)))),
                  const SizedBox(width: 16),
                  Expanded(child: _sectionCard(title: 'Fulfillment rate', subtitle: 'Target threshold 95%', child: SizedBox(height: 240, child: _buildFulfillmentChart(dataset.fulfillmentTrend)))),
                ],
              );
            }
            return Column(
              children: [
                _sectionCard(title: 'Revenue over time', subtitle: 'Actual vs Target values', child: SizedBox(height: 240, child: _buildRevenueChart(dataset.revenueTrend))),
                const SizedBox(height: 16),
                _sectionCard(title: 'Fulfillment rate', subtitle: 'Target threshold 95%', child: SizedBox(height: 240, child: _buildFulfillmentChart(dataset.fulfillmentTrend))),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text('Market & Crop Metrics', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            if (wide) {
              return Row(
                children: [
                  Expanded(child: _sectionCard(title: 'Crop Volume (m³)', subtitle: 'Trade volume by crop type', child: SizedBox(height: 240, child: _buildVolumeChart(dataset.cropVolumes)))),
                  const SizedBox(width: 16),
                  Expanded(child: _sectionCard(title: 'Revenue Share', subtitle: 'By agricultural category', child: SizedBox(height: 240, child: _buildCategoryChart(dataset.categories)))),
                ],
              );
            }
            return Column(
              children: [
                _sectionCard(title: 'Crop Volume (m³)', subtitle: 'Trade volume by crop type', child: SizedBox(height: 240, child: _buildVolumeChart(dataset.cropVolumes))),
                const SizedBox(height: 16),
                _sectionCard(title: 'Revenue Share', subtitle: 'By agricultural category', child: SizedBox(height: 240, child: _buildCategoryChart(dataset.categories))),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text('Product Leaderboard', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        const SizedBox(height: 10),
        _buildLeaderboard(dataset),
      ],
    );
  }

  Widget _buildGeospatialTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Geospatial NDVI & Soil Health Matrix', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        Text('Real-time multispectral satellite telemetry and rootzone sensor readings.', style: GoogleFonts.inter(fontSize: 12, color: AnalyticsPage.muted)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.satellite_alt, color: Color(0xFF22C55E), size: 20),
                  const SizedBox(width: 10),
                  Text('Field Sector 4 - Multispectral Heatmap', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: const Text('NDVI: 0.82 High Vigour', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 2.2),
                itemCount: 18,
                itemBuilder: (context, index) {
                  final colors = [const Color(0xFF15803D), const Color(0xFF16A34A), const Color(0xFF22C55E), const Color(0xFF84CC16), const Color(0xFFEAB308), const Color(0xFF15803D)];
                  final color = colors[index % colors.length];
                  return Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)), alignment: Alignment.center, child: Text('Z-${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)));
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Low Vigour (<0.3)', style: TextStyle(color: Colors.amber, fontSize: 10.5)),
                  Text('Optimal Canopy Density (>0.75)', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _telemetryMeterCard(title: 'Soil Nitrogen (N)', value: '42 mg/kg', status: 'Optimal', progress: 0.82, color: AnalyticsPage.green, icon: Icons.science_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _telemetryMeterCard(title: 'Phosphorus (P)', value: '28 mg/kg', status: 'Slight Dip', progress: 0.58, color: AnalyticsPage.orange, icon: Icons.bubble_chart_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _telemetryMeterCard(title: 'Potassium (K)', value: '185 mg/kg', status: 'High Reserve', progress: 0.91, color: AnalyticsPage.blue, icon: Icons.grain_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _telemetryMeterCard(title: 'Soil Moisture Depth', value: '68% Capacity', status: 'Irrigation Ready', progress: 0.68, color: AnalyticsPage.purple, icon: Icons.water_drop_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _telemetryMeterCard({required String title, required String value, required String status, required double progress, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)))]),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AnalyticsPage.dark)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.12), color: color, minHeight: 6),
          const SizedBox(height: 6),
          Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCommodityFuturesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Commodity Price Forecast & Arbitrage Matrix', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        Text('30-Day Predictive Neural Price Models & Regional Arbitrage Comparison.', style: GoogleFonts.inter(fontSize: 12, color: AnalyticsPage.muted)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _priceTickerCard('🌽 White Maize', '\$290 / MT', '+3.5%', true),
              const SizedBox(width: 12),
              _priceTickerCard('🍅 Tomatoes (Grade A)', '\$14.50 / Box', '+8.2%', true),
              const SizedBox(width: 12),
              _priceTickerCard('🥑 Hass Avocados', '\$2.80 / kg', '-1.2%', false),
              const SizedBox(width: 12),
              _priceTickerCard('🍵 Flue-Cured Tobacco', '\$4.20 / kg', '+5.1%', true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Regional Price Arbitrage Matrix (White Maize / MT)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
              const SizedBox(height: 12),
              _arbitrageRow('Harare Mbare Musika', '\$310 / MT', 'Baseline', AnalyticsPage.dark),
              _arbitrageRow('GMB Silos Concession', '\$285 / MT', '+\$25 Premium in Harare', AnalyticsPage.green),
              _arbitrageRow('Mutare Regional Hub', '\$295 / MT', '+\$15 Margin', AnalyticsPage.blue),
              _arbitrageRow('Beira Mozambique Border', '\$340 / MT', '+\$30 Export Margin', AnalyticsPage.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceTickerCard(String commodity, String price, String change, bool isUp) {
    final color = isUp ? AnalyticsPage.green : AnalyticsPage.red;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(commodity, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
          const SizedBox(height: 4),
          Text(price, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AnalyticsPage.dark)),
          const SizedBox(height: 2),
          Row(children: [Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 14, color: color), const SizedBox(width: 4), Text(change, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))]),
        ],
      ),
    );
  }

  Widget _arbitrageRow(String hub, String price, String margin, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
          const SizedBox(width: 10),
          Expanded(child: Text(hub, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AnalyticsPage.dark))),
          Text(price, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AnalyticsPage.dark)),
          const SizedBox(width: 16),
          Text(margin, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accent)),
        ],
      ),
    );
  }

  Widget _buildYieldSimulatorTab() {
    final projectedYield = 3.5 + (_simNitrogen * 0.015) + ((_simWaterQuota / 100) * 1.8);
    final projectedRevenue = projectedYield * _simMarketPrice * 25.0;
    final estimatedCost = 3500.0 + (_simNitrogen * 12.0) + (_simWaterQuota * 20.0);
    final netProfit = projectedRevenue - estimatedCost;
    final margin = (netProfit / projectedRevenue) * 100;
    final co2Offset = projectedYield * 1.65;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interactive Yield & Net Profit "What-If" Simulator', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
        Text('Adjust agronomic inputs to simulate real-time yield tonnage, net revenue, and carbon offset.', style: GoogleFonts.inter(fontSize: 12, color: AnalyticsPage.muted)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INPUT CONTROLS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AnalyticsPage.green, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Nitrogen Fertilizer Input: ${_simNitrogen.toStringAsFixed(0)} kg/ha', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
              Slider(value: _simNitrogen, min: 40.0, max: 240.0, activeColor: AnalyticsPage.green, label: '${_simNitrogen.toStringAsFixed(0)} kg/ha', onChanged: (v) => setState(() => _simNitrogen = v)),
              Text('Irrigation Quota Allocation: ${_simWaterQuota.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
              Slider(value: _simWaterQuota, min: 30.0, max: 100.0, activeColor: AnalyticsPage.blue, label: '${_simWaterQuota.toStringAsFixed(0)}%', onChanged: (v) => setState(() => _simWaterQuota = v)),
              Text('Target Market Farmgate Price: \$${_simMarketPrice.toStringAsFixed(0)} / Ton', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
              Slider(value: _simMarketPrice, min: 180.0, max: 500.0, activeColor: AnalyticsPage.orange, label: '\$${_simMarketPrice.toStringAsFixed(0)}/t', onChanged: (v) => setState(() => _simMarketPrice = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIMULATED OUTPUT PROJECTIONS (25 HA SECTOR)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E), letterSpacing: 1.0)),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 540;
                  if (isNarrow) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        _simOutputMetric('Projected Yield', '${projectedYield.toStringAsFixed(1)} Tons/ha', const Color(0xFF22C55E)),
                        _simOutputMetric('Net Gross Profit', '\$${netProfit.toStringAsFixed(0)}', Colors.white),
                        _simOutputMetric('Profit Margin', '${margin.toStringAsFixed(1)}%', const Color(0xFF38BDF8)),
                        _simOutputMetric('CO2 Offset', '${co2Offset.toStringAsFixed(1)} T', const Color(0xFFA7F3D0)),
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _simOutputMetric('Projected Yield', '${projectedYield.toStringAsFixed(1)} Tons/ha', const Color(0xFF22C55E)),
                      _simOutputMetric('Net Gross Profit', '\$${netProfit.toStringAsFixed(0)}', Colors.white),
                      _simOutputMetric('Profit Margin', '${margin.toStringAsFixed(1)}%', const Color(0xFF38BDF8)),
                      _simOutputMetric('CO2 Offset', '${co2Offset.toStringAsFixed(1)} T', const Color(0xFFA7F3D0)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _simOutputMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildTailoredKpiGrid(AnalyticsMockDataset dataset, UserRole role) {
    final isDemo = ref.watch(isDemoModeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 480 ? 2 : 1);
        final spacing = 12.0;
        final double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

        final cards = switch (role) {
          UserRole.admin => isDemo
              ? [_kpiCard('Platform GMV', '\$1,420,800', '+18.4%', Icons.account_balance_outlined, AnalyticsPage.green, width), _kpiCard('Trade Orders', '1,842', '+12.1%', Icons.shopping_bag_outlined, AnalyticsPage.blue, width), _kpiCard('Fleet Dispatches', '42,600 km', '+9.5%', Icons.local_shipping_outlined, AnalyticsPage.orange, width), _kpiCard('EUDR Compliance', '98.4%', '+2.1%', Icons.verified_outlined, AnalyticsPage.purple, width)]
              : [_kpiCard('Platform GMV', dataset.revenue, '+0.0%', Icons.account_balance_outlined, AnalyticsPage.green, width), _kpiCard('Trade Orders', dataset.orders, '+0.0%', Icons.shopping_bag_outlined, AnalyticsPage.blue, width), _kpiCard('Fleet Dispatches', '${dataset.deliveries} km', '+0.0%', Icons.local_shipping_outlined, AnalyticsPage.orange, width), _kpiCard('EUDR Compliance', '100.0%', '+0.0%', Icons.verified_outlined, AnalyticsPage.purple, width)],
          UserRole.farmer => isDemo
              ? [_kpiCard('Harvest Yield', '3.8 Tons/ha', '+14.2%', Icons.agriculture_outlined, AnalyticsPage.green, width), _kpiCard('Field Health NDVI', '0.78 (Good)', '+5.1%', Icons.eco_outlined, AnalyticsPage.blue, width), _kpiCard('Farmgate Margin', '\$12,480', '+11.8%', Icons.payments_outlined, AnalyticsPage.orange, width), _kpiCard('Storage Reserve', '45.0 Tons', 'Stable', Icons.inventory_2_outlined, AnalyticsPage.purple, width)]
              : [_kpiCard('Harvest Yield', '0.0 Tons/ha', '+0.0%', Icons.agriculture_outlined, AnalyticsPage.green, width), _kpiCard('Field Health NDVI', '0.00 (Baseline)', '+0.0%', Icons.eco_outlined, AnalyticsPage.blue, width), _kpiCard('Farmgate Margin', '\$0', '+0.0%', Icons.payments_outlined, AnalyticsPage.orange, width), _kpiCard('Storage Reserve', '0.0 Tons', 'Baseline', Icons.inventory_2_outlined, AnalyticsPage.purple, width)],
          UserRole.buyer => isDemo
              ? (ref.watch(appStateProvider).buyerSubRole == BuyerSubRole.endUserCustomer
                  ? [_kpiCard('Monthly Spend', '\$142.50', '-12.4%', Icons.shopping_basket_outlined, AnalyticsPage.green, width), _kpiCard('Farmgate Savings', '18.5%', '+3.2%', Icons.savings_outlined, AnalyticsPage.blue, width), _kpiCard('Fresh Deliveries', '12 Orders', '+2', Icons.local_shipping_outlined, AnalyticsPage.orange, width), _kpiCard('Carbon Offset', '-42 kg CO2', 'Local', Icons.eco_outlined, AnalyticsPage.purple, width)]
                  : [_kpiCard('Sourcing Volume', '142 Tons', '+16.5%', Icons.shopping_cart_outlined, AnalyticsPage.green, width), _kpiCard('Order Fulfillment', '95.4%', '+1.8%', Icons.task_alt_outlined, AnalyticsPage.blue, width), _kpiCard('Avg Produce Rate', '\$1.45/kg', '-3.2%', Icons.price_change_outlined, AnalyticsPage.orange, width), _kpiCard('Supplier Quality', '4.8 / 5.0', '+0.2', Icons.star_outline_rounded, AnalyticsPage.purple, width)])
              : [_kpiCard('Sourcing Volume', '0 Tons', '+0.0%', Icons.shopping_cart_outlined, AnalyticsPage.green, width), _kpiCard('Order Fulfillment', dataset.fulfillment, '+0.0%', Icons.task_alt_outlined, AnalyticsPage.blue, width), _kpiCard('Avg Produce Rate', '\$0.00/kg', '+0.0%', Icons.price_change_outlined, AnalyticsPage.orange, width), _kpiCard('Supplier Quality', '0.0 / 5.0', '+0.0', Icons.star_outline_rounded, AnalyticsPage.purple, width)],
          UserRole.consumer => isDemo
              ? [_kpiCard('Monthly Spend', '\$142.50', '-12.4%', Icons.shopping_basket_outlined, AnalyticsPage.green, width), _kpiCard('Farmgate Savings', '18.5%', '+3.2%', Icons.savings_outlined, AnalyticsPage.blue, width), _kpiCard('Fresh Deliveries', '12 Orders', '+2', Icons.local_shipping_outlined, AnalyticsPage.orange, width), _kpiCard('Carbon Offset', '-42 kg CO2', 'Local', Icons.eco_outlined, AnalyticsPage.purple, width)]
              : [_kpiCard('Monthly Spend', dataset.revenue, '+0.0%', Icons.shopping_basket_outlined, AnalyticsPage.green, width), _kpiCard('Farmgate Savings', '0.0%', '+0.0%', Icons.savings_outlined, AnalyticsPage.blue, width), _kpiCard('Fresh Deliveries', '${dataset.deliveries} Orders', '+0.0%', Icons.local_shipping_outlined, AnalyticsPage.orange, width), _kpiCard('Carbon Offset', '0 kg CO2', 'Local', Icons.eco_outlined, AnalyticsPage.purple, width)],
          UserRole.transporter => isDemo
              ? [_kpiCard('Distance Driven', '4,280 km', '+12.3%', Icons.route_outlined, AnalyticsPage.green, width), _kpiCard('Completed Trips', '48 Trips', '+8.0%', Icons.local_shipping_outlined, AnalyticsPage.blue, width), _kpiCard('Fuel Efficiency', '28.5 L/100km', '-4.1%', Icons.local_gas_station_outlined, AnalyticsPage.orange, width), _kpiCard('Haulage Earnings', '\$3,420', '+15.2%', Icons.account_balance_wallet_outlined, AnalyticsPage.purple, width)]
              : [_kpiCard('Distance Driven', '0 km', '+0.0%', Icons.route_outlined, AnalyticsPage.green, width), _kpiCard('Completed Trips', '0 Trips', '+0.0%', Icons.local_shipping_outlined, AnalyticsPage.blue, width), _kpiCard('Fuel Efficiency', '0.0 L/100km', '+0.0%', Icons.local_gas_station_outlined, AnalyticsPage.orange, width), _kpiCard('Haulage Earnings', '\$0', '+0.0%', Icons.account_balance_wallet_outlined, AnalyticsPage.purple, width)],
          UserRole.financier => isDemo
              ? [_kpiCard('Deployed Capital', '\$385,000', '+14.2%', Icons.account_balance_outlined, AnalyticsPage.green, width), _kpiCard('Repayment Rate', '96.8%', '+1.4%', Icons.fact_check_outlined, AnalyticsPage.blue, width), _kpiCard('Portfolio Risk', 'Low (3.2%)', '-0.8%', Icons.shield_outlined, AnalyticsPage.orange, width), _kpiCard('Net Interest Yield', '11.4% p.a.', '+0.9%', Icons.trending_up, AnalyticsPage.purple, width)]
              : [_kpiCard('Deployed Capital', '\$0', '+0.0%', Icons.account_balance_outlined, AnalyticsPage.green, width), _kpiCard('Repayment Rate', '100.0%', '+0.0%', Icons.fact_check_outlined, AnalyticsPage.blue, width), _kpiCard('Portfolio Risk', 'None (0.0%)', '+0.0%', Icons.shield_outlined, AnalyticsPage.orange, width), _kpiCard('Net Interest Yield', '0.0% p.a.', '+0.0%', Icons.trending_up, AnalyticsPage.purple, width)],
          UserRole.valueAdder => isDemo
              ? [_kpiCard('Processing Vol', '840 Tons', '+21.0%', Icons.factory_outlined, AnalyticsPage.green, width), _kpiCard('Input Cost / Ton', '\$185/ton', '-2.4%', Icons.point_of_sale_outlined, AnalyticsPage.blue, width), _kpiCard('Value Margin', '42.5%', '+3.8%', Icons.bar_chart_outlined, AnalyticsPage.orange, width), _kpiCard('Plant Uptime', '97.2%', '+0.8%', Icons.precision_manufacturing_outlined, AnalyticsPage.purple, width)]
              : [_kpiCard('Processing Vol', '0 Tons', '+0.0%', Icons.factory_outlined, AnalyticsPage.green, width), _kpiCard('Input Cost / Ton', '\$0/ton', '+0.0%', Icons.point_of_sale_outlined, AnalyticsPage.blue, width), _kpiCard('Value Margin', '0.0%', '+0.0%', Icons.bar_chart_outlined, AnalyticsPage.orange, width), _kpiCard('Plant Uptime', '100.0%', '+0.0%', Icons.precision_manufacturing_outlined, AnalyticsPage.purple, width)],
          UserRole.expert => isDemo
              ? [_kpiCard('Advisory Sessions', '142 Cases', '+18.0%', Icons.psychology_outlined, AnalyticsPage.green, width), _kpiCard('Diagnosis Accuracy', '98.2%', '+1.1%', Icons.health_and_safety_outlined, AnalyticsPage.blue, width), _kpiCard('Farmer Reach', '1,240 Farmers', '+24.5%', Icons.groups_outlined, AnalyticsPage.orange, width), _kpiCard('Field Anomalies', '12 Active', '-4.0%', Icons.crisis_alert_outlined, AnalyticsPage.purple, width)]
              : [_kpiCard('Advisory Sessions', '0 Cases', '+0.0%', Icons.psychology_outlined, AnalyticsPage.green, width), _kpiCard('Diagnosis Accuracy', '100.0%', '+0.0%', Icons.health_and_safety_outlined, AnalyticsPage.blue, width), _kpiCard('Farmer Reach', '0 Farmers', '+0.0%', Icons.groups_outlined, AnalyticsPage.orange, width), _kpiCard('Field Anomalies', '0 Active', '+0.0%', Icons.crisis_alert_outlined, AnalyticsPage.purple, width)],
          UserRole.government => isDemo
              ? [_kpiCard('Regional Trade Vol', '1.42M Tons', '+18.4%', Icons.gavel_outlined, AnalyticsPage.green, width), _kpiCard('EUDR Compliance', '98.4%', '+2.1%', Icons.verified_user_outlined, AnalyticsPage.blue, width), _kpiCard('Subsidy Allocated', '\$1.2M', '+5.8%', Icons.account_balance_outlined, AnalyticsPage.orange, width), _kpiCard('Food Security', 'High Reserve', 'Stable', Icons.shield_outlined, AnalyticsPage.purple, width)]
              : [_kpiCard('Regional Trade Vol', '0 Tons', '+0.0%', Icons.gavel_outlined, AnalyticsPage.green, width), _kpiCard('EUDR Compliance', '100.0%', '+0.0%', Icons.verified_user_outlined, AnalyticsPage.blue, width), _kpiCard('Subsidy Allocated', '\$0', '+0.0%', Icons.account_balance_outlined, AnalyticsPage.orange, width), _kpiCard('Food Security', 'Baseline', 'Stable', Icons.shield_outlined, AnalyticsPage.purple, width)],
        };

        return Wrap(spacing: spacing, runSpacing: spacing, children: cards);
      },
    );
  }

  Widget _kpiCard(String title, String value, String change, IconData icon, Color color, double width) {
    final isNegative = change.startsWith('-');
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: Row(
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AnalyticsPage.muted, fontSize: 11)),
                Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
                Text(change, style: TextStyle(color: isNegative ? Colors.red : AnalyticsPage.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AnalyticsPage.muted)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<ChartData> data) {
    if (_isTestEnvironment) return _buildTestChartPlaceholder('Revenue Trend Chart');
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
      primaryYAxis: const NumericAxis(axisLine: AxisLine(width: 0)),
      series: <CartesianSeries<ChartData, String>>[
        SplineAreaSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.actual, color: AnalyticsPage.green.withOpacity(0.15), borderColor: AnalyticsPage.green, borderWidth: 2),
      ],
    );
  }

  Widget _buildFulfillmentChart(List<ChartData> data) {
    if (_isTestEnvironment) return _buildTestChartPlaceholder('Fulfillment Rate Chart');
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
      series: <CartesianSeries<ChartData, String>>[
        LineSeries<ChartData, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.actual, color: AnalyticsPage.blue, markerSettings: const MarkerSettings(isVisible: true)),
      ],
    );
  }

  Widget _buildVolumeChart(List<CropVolumeData> data) {
    if (_isTestEnvironment) return _buildTestChartPlaceholder('Crop Volume Chart');
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
      series: <CartesianSeries<CropVolumeData, String>>[
        ColumnSeries<CropVolumeData, String>(dataSource: data, xValueMapper: (d, _) => d.crop, yValueMapper: (d, _) => d.volume, pointColorMapper: (d, _) => d.color, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
      ],
    );
  }

  Widget _buildCategoryChart(List<CircularChartData> data) {
    if (_isTestEnvironment) return _buildTestChartPlaceholder('Category Share Chart');
    return SfCircularChart(
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CircularSeries<CircularChartData, String>>[
        DoughnutSeries<CircularChartData, String>(dataSource: data, xValueMapper: (d, _) => d.category, yValueMapper: (d, _) => d.value, pointColorMapper: (d, _) => d.color, innerRadius: '65%'),
      ],
    );
  }

  Widget _buildTestChartPlaceholder(String title) {
    return Container(decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(title, style: const TextStyle(color: AnalyticsPage.muted, fontWeight: FontWeight.bold))));
  }

  Widget _buildLeaderboard(AnalyticsMockDataset dataset) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dataset.topProducts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = dataset.topProducts[i];
          final trendColor = item.trend >= 0 ? AnalyticsPage.green : AnalyticsPage.red;
          return ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFF8FAFC), child: Text(item.emoji, style: const TextStyle(fontSize: 20))),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(item.category, style: const TextStyle(fontSize: 12, color: AnalyticsPage.muted)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.sales, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${item.trend >= 0 ? '+' : ''}${item.trend}%', style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpatialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Shared Geospatial coordination is active: Analytics aggregates regional trade volumes from synced field and zone boundaries.', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AnalyticsPage.dark))),
        ],
      ),
    );
  }
}

class _SuperAdminPerspectiveSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleSelected;
  const _SuperAdminPerspectiveSelector({required this.selectedRole, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    final roles = [UserRole.admin, UserRole.farmer, UserRole.buyer, UserRole.transporter, UserRole.financier, UserRole.valueAdder, UserRole.expert];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AnalyticsPage.green.withValues(alpha: 0.3)), boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AnalyticsPage.green.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.admin_panel_settings_outlined, color: AnalyticsPage.green, size: 18)),
              const SizedBox(width: 8),
              Text('Super Admin Perspective Switcher', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AnalyticsPage.dark)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AnalyticsPage.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)), child: Text('Full Chain Scope', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: AnalyticsPage.green))),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: roles.map((r) {
                final isSelected = selectedRole == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(r.icon, size: 14, color: isSelected ? Colors.white : AnalyticsPage.green),
                    label: Text(r == UserRole.admin ? '👑 Super Admin Command' : r.label),
                    selected: isSelected,
                    onSelected: (_) => onRoleSelected(r),
                    selectedColor: AnalyticsPage.green,
                    labelStyle: GoogleFonts.inter(color: isSelected ? Colors.white : AnalyticsPage.dark, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 11.5),
                    side: BorderSide(color: isSelected ? AnalyticsPage.green : Colors.black12),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleScopeBanner extends StatelessWidget {
  final UserRole role;
  final bool isSuperAdmin;
  const _RoleScopeBanner({required this.role, required this.isSuperAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AnalyticsPage.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AnalyticsPage.green.withValues(alpha: 0.2))),
      child: Row(
        children: [
          Icon(role.icon, color: AnalyticsPage.green, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(isSuperAdmin ? 'Super Admin Mode: Currently inspecting value-chain metrics as (${role == UserRole.admin ? "Super Admin Command" : role.label}). Full audit logging active.' : 'Stakeholder Scope: Viewing agricultural analytics tailored for your active role (${role.label}). Access to regional details and raw telemetry is audited.', style: GoogleFonts.inter(fontSize: 12.5, color: AnalyticsPage.dark, height: 1.35))),
        ],
      ),
    );
  }
}

class _AiAdvisoryCard extends ConsumerWidget {
  final UserRole role;
  const _AiAdvisoryCard({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final advisory = isDemo
        ? switch (role) {
            UserRole.admin => (title: 'Macro Value Chain Expansion & Export Bottleneck Warning', text: 'Regional trade volume is up 18.4% with strong Beira corridor exports. Recommended action: Accelerate EUDR polygon verification for smallholder suppliers to prevent customs delays.'),
            UserRole.farmer => (title: 'Irrigation & Frost Advisory for Tomato & Potato Blocks', text: 'Moisture dip registered in Sector 4. Recommended action: Schedule early morning fertigation and verify frost protection covers before night temperature drop.'),
            UserRole.buyer => ref.watch(appStateProvider).buyerSubRole == BuyerSubRole.endUserCustomer
                ? (title: 'Farmgate Fresh Harvest & Price Drop Alert', text: 'Mazowe tomatoes and Marondera sweet maize are 18% cheaper today due to peak morning harvest. Best value grocery window is active.')
                : (title: 'Grade A White Maize Procurement Opportunity', text: 'Masvingo grain silos reporting 3,200 MT fresh harvest arrival. Recommended action: Place forward orders to lock in lower farmgate floor pricing.'),
            UserRole.consumer => (title: 'Farmgate Fresh Harvest & Price Drop Alert', text: 'Mazowe tomatoes and Marondera sweet maize are 18% cheaper today due to peak morning harvest. Best value grocery window is active.'),
            UserRole.transporter => (title: 'Beira Customs Corridor Freight Clearance Peak', text: 'Port scanner queues down to 20 minutes. Recommended action: Accept refrigerated container dispatches for immediate transport.'),
            UserRole.financier => (title: 'Low Portfolio Default Risk across Smallholder Credit Lines', text: 'Repayment compliance reaches 96.8%. Recommended action: Expand working capital loans for certified macadamia and blueberry growers.'),
            UserRole.valueAdder => (title: 'Oilseed Processing Throughput Optimization', text: 'Soybean crushing margin increased to 42.5%. Recommended action: Maximize shift capacity during low electricity tariff hours.'),
            UserRole.expert => (title: 'Targeted Pest Control Advisory for Fall Armyworm', text: 'Multispectral satellite imagery flagged early leaf biomass change in Zone 2. Recommended action: Send targeted bio-pesticide spray alerts to field managers.'),
            UserRole.government => (title: 'National Strategic Food Security & EUDR Trade Compliance', text: 'Maize reserves are 18.5% above strategic threshold. EUDR deforestation compliance reaches 98.4% across southern corridors.'),
          }
        : switch (role) {
            UserRole.admin => (title: 'Live Value Chain Surveillance Active', text: 'Distributed ecosystem nodes operational. Live stakeholder mutations and trade transactions are being synthesized into predictive AI models in real time.'),
            UserRole.farmer => (title: 'Field Telemetry & Soil Sensing Bus Ready', text: 'Map your farm parcel boundaries and log harvest yields to activate automated agronomic AI crop health forecasting and soil fertigation schedules.'),
            UserRole.buyer || UserRole.consumer => (title: 'Real-Time Farmgate Sourcing Engine Ready', text: 'Live marketplace catalog connected to verified outgrowers. AI price arbitration will optimize orders as farmers publish produce batches.'),
            UserRole.transporter => (title: 'GPS Corridor Telemetry & Freight Routing Ready', text: 'Register your transport fleet to enable automated corridor route planning, reefer temperature monitoring, and smart escrow settlements.'),
            UserRole.financier => (title: 'Agri-Credit Portfolio Risk Engine Active', text: 'Underwriting algorithms connected to live field data. Credit evaluations will compute automatically as smallholders apply for input financing.'),
            UserRole.valueAdder => (title: 'Processing Batch & Supply Pipeline Ready', text: 'Connect plant processing capacity to track input crushing yields, supplier quality grades, and energy tariff schedules.'),
            UserRole.expert => (title: 'Diagnostic AI & Agronomic Knowledge Mesh Ready', text: 'Agronomy advisory engine standing by to ingest field anomaly reports and dispatch targeted pesticide recommendations.'),
            UserRole.government => (title: 'National Grain Reserves & Trade Compliance Stream', text: 'Sovereign food security telemetry active. SADC border clearance queues and ePhyto certification records will stream continuously.'),
          };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AnalyticsPage.purple.withValues(alpha: 0.05), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18), border: Border.all(color: AnalyticsPage.purple.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AnalyticsPage.purple, borderRadius: BorderRadius.circular(8)), child: Row(children: const [Icon(Icons.smart_toy_outlined, color: Colors.white, size: 14), SizedBox(width: 4), Text('AI STRATEGIC ADVISORY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))])),
              const Spacer(),
              const Text('Confidence: ', style: TextStyle(color: AnalyticsPage.muted, fontSize: 12)),
              const Text('98%', style: TextStyle(color: AnalyticsPage.purple, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(advisory.title, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.bold, color: AnalyticsPage.dark)),
          const SizedBox(height: 4),
          Text(advisory.text, style: const TextStyle(fontSize: 12.5, color: AnalyticsPage.muted, height: 1.4)),
        ],
      ),
    );
  }
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
  final String orders;
  final String ordersChange;
  final String buyers;
  final String buyersChange;
  final String fulfillment;
  final String fulfillmentChange;
  final String deliveries;
  final String deliveriesChange;
  final String listings;
  final String listingsChange;
  final List<ChartData> revenueTrend;
  final List<ChartData> fulfillmentTrend;
  final List<CropVolumeData> cropVolumes;
  final List<CircularChartData> categories;
  final List<ProductLeaderboardItem> topProducts;

  AnalyticsMockDataset({
    required this.revenue,
    required this.revenueChange,
    required this.orders,
    required this.ordersChange,
    required this.buyers,
    required this.buyersChange,
    required this.fulfillment,
    required this.fulfillmentChange,
    required this.deliveries,
    required this.deliveriesChange,
    required this.listings,
    required this.listingsChange,
    required this.revenueTrend,
    required this.fulfillmentTrend,
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

// ─────────────────────────────────────────────────────────────────────────────
// B2B COMMERCIAL BUYER ENTERPRISE ANALYTICS VIEW (DEEP PROCUREMENT INTELLIGENCE)
// ─────────────────────────────────────────────────────────────────────────────
class _B2BBuyerAnalyticsView extends ConsumerStatefulWidget {
  final bool isSuperAdmin;
  final ValueChanged<UserRole>? onPerspectiveSelected;

  const _B2BBuyerAnalyticsView({
    required this.isSuperAdmin,
    this.onPerspectiveSelected,
  });

  @override
  ConsumerState<_B2BBuyerAnalyticsView> createState() => _B2BBuyerAnalyticsViewState();
}

class _B2BBuyerAnalyticsViewState extends ConsumerState<_B2BBuyerAnalyticsView> with SingleTickerProviderStateMixin {
  late TabController _b2bTabCtrl;
  String _timeframe = '30 Days';
  String _currency = 'USD';

  final List<Map<String, dynamic>> _commodityMatrix = [
    {
      'name': 'White Maize (Grade A)',
      'code': 'WM-GRA-01',
      'farmgate': '\$275.00',
      'verdiRate': '\$288.00',
      'supermarket': '\$335.00',
      'sadcBenchmark': '\$310.00',
      'arbitrage': 'Saved \$47.00/MT (14.0%)',
      'forward30d': '+2.8% (Bullish)',
      'moisture': '11.8%',
      'stockAvailable': '3,450 MT',
      'status': 'Optimal Buy',
      'trendColor': Color(0xFF10B981),
    },
    {
      'name': 'Soybeans (Protein 38%)',
      'code': 'SB-PRO-02',
      'farmgate': '\$410.00',
      'verdiRate': '\$425.00',
      'supermarket': '\$490.00',
      'sadcBenchmark': '\$470.00',
      'arbitrage': 'Saved \$65.00/MT (13.3%)',
      'forward30d': '-1.2% (Stable)',
      'moisture': '10.2%',
      'stockAvailable': '1,820 MT',
      'status': 'High Demand',
      'trendColor': Color(0xFF3B82F6),
    },
    {
      'name': 'Sugar Beans (Red Speckled)',
      'code': 'SB-RED-03',
      'farmgate': '\$1,080.00',
      'verdiRate': '\$1,120.00',
      'supermarket': '\$1,350.00',
      'sadcBenchmark': '\$1,280.00',
      'arbitrage': 'Saved \$230.00/MT (17.0%)',
      'forward30d': '+4.1% (Rising)',
      'moisture': '12.0%',
      'stockAvailable': '640 MT',
      'status': 'Supply Tight',
      'trendColor': Color(0xFFF59E0B),
    },
    {
      'name': 'Salad Tomatoes (Grade A Crate)',
      'code': 'TM-SLA-04',
      'farmgate': '\$0.85/kg',
      'verdiRate': '\$0.95/kg',
      'supermarket': '\$1.60/kg',
      'sadcBenchmark': '\$1.45/kg',
      'arbitrage': 'Saved \$0.65/kg (40.6%)',
      'forward30d': '-5.5% (Peak Harvest)',
      'moisture': 'Fresh Picked',
      'stockAvailable': '48 MT',
      'status': 'Flash Surplus',
      'trendColor': Color(0xFFEF4444),
    },
    {
      'name': 'Export Hass Avocados',
      'code': 'AV-HSS-05',
      'farmgate': '\$1.90/kg',
      'verdiRate': '\$2.15/kg',
      'supermarket': '\$3.40/kg',
      'sadcBenchmark': '\$3.10/kg',
      'arbitrage': 'Saved \$1.25/kg (36.8%)',
      'forward30d': '+6.2% (Export Peak)',
      'moisture': 'GlobalG.A.P.',
      'stockAvailable': '125 MT',
      'status': 'Export Ready',
      'trendColor': Color(0xFF10B981),
    },
  ];

  final List<Map<String, dynamic>> _outgrowerCoops = [
    {
      'name': 'Mashonaland West Outgrowers Syndicate',
      'region': 'Chinhoyi / Makonde',
      'lead': 'Eng. P. Chidawa',
      'farmers': 142,
      'hectares': 850,
      'deliveredMT': '1,240 MT',
      'gradeA': '98.4%',
      'defectRate': '0.35%',
      'otifScore': '99.1%',
      'escrowSettled': 'US\$ 347,200',
      'status': 'Premier Tier 1',
    },
    {
      'name': 'Mazowe Valley Horticultural Hub',
      'region': 'Mazowe / Glendale',
      'lead': 'Agro. T. Gumbo',
      'farmers': 88,
      'hectares': 420,
      'deliveredMT': '480 MT',
      'gradeA': '96.2%',
      'defectRate': '0.52%',
      'otifScore': '97.5%',
      'escrowSettled': 'US\$ 168,000',
      'status': 'Verified Active',
    },
    {
      'name': 'Masvingo Central Grain Silos Depot',
      'region': 'Masvingo / Gutu',
      'lead': 'C. Mukonori',
      'farmers': 310,
      'hectares': 1450,
      'deliveredMT': '3,100 MT',
      'gradeA': '99.0%',
      'defectRate': '0.28%',
      'otifScore': '98.8%',
      'escrowSettled': 'US\$ 899,000',
      'status': 'Strategic Vault',
    },
    {
      'name': 'Eastern Highlands Macadamia & Citrus',
      'region': 'Chipinge / Mutare',
      'lead': 'D. Van Rensburg',
      'farmers': 45,
      'hectares': 620,
      'deliveredMT': '390 MT',
      'gradeA': '97.8%',
      'defectRate': '0.40%',
      'otifScore': '96.4%',
      'escrowSettled': 'US\$ 546,000',
      'status': 'Export Certified',
    },
  ];

  @override
  void initState() {
    super.initState();
    _b2bTabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _b2bTabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.query_stats, color: Color(0xFF3B82F6), size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('B2B Commercial Procurement & Trade Analytics', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                const Text('Arbitrage Matrix, Outgrower Intake, Escrow Vault & SLA Compliance', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2563EB))),
            child: const Text('B2B WHOLESALER DESK', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
        bottom: TabBar(
          controller: _b2bTabCtrl,
          isScrollable: true,
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12.5),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined, size: 16), text: 'Procurement & Arbitrage'),
            Tab(icon: Icon(Icons.groups_outlined, size: 16), text: 'Outgrower Cooperatives & QA'),
            Tab(icon: Icon(Icons.shield_outlined, size: 16), text: 'Escrow Vault & Working Capital'),
            Tab(icon: Icon(Icons.eco_outlined, size: 16), text: 'Cold-Chain & EUDR Audits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _b2bTabCtrl,
        children: [
          _buildProcurementArbitrageTab(),
          _buildOutgrowerQualityTab(),
          _buildEscrowCapitalTab(),
          _buildColdChainEudrTab(),
        ],
      ),
    );
  }

  // TAB 1: Procurement & Arbitrage
  Widget _buildProcurementArbitrageTab() {
    final isDemo = ref.watch(isDemoModeProvider);
    final volume = isDemo ? '184.2 MT' : '0.0 MT';
    final volumeSub = isDemo ? '+22.4% vs last month' : 'No live purchases yet';
    final spend = isDemo ? (_currency == 'USD' ? 'US\$ 64,890' : 'ZWG 1,752,030') : (_currency == 'USD' ? 'US\$ 0.00' : 'ZWG 0.00');
    final spendSub = isDemo ? 'Saved \$5,420 vs Spot' : 'No live spend';
    final otif = isDemo ? '98.1%' : '100.0%';
    final otifSub = isDemo ? '98 / 100 Lots on-time' : '0 / 0 Lots';
    final defect = isDemo ? '0.42%' : '0.00%';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Currency Bar
          Row(
            children: [
              ...['7 Days', '30 Days', 'This Quarter', '12 Months'].map((t) {
                final isSel = _timeframe == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: isSel,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFF0F172A),
                    labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12),
                    onSelected: (_) => setState(() => _timeframe = t),
                  ),
                );
              }),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1E293B))),
                child: Row(
                  children: [
                    const Text('Display: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    DropdownButton<String>(
                      value: _currency,
                      dropdownColor: const Color(0xFF0F172A),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      items: ['USD', 'ZWG'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4 Big B2B KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
              final width = (constraints.maxWidth - (12.0 * (cols - 1))) / cols;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _b2bKpiCard('Total Procurement Volume', volume, volumeSub, Icons.inventory_2_outlined, const Color(0xFF10B981), width),
                  _b2bKpiCard('Commercial Spend', spend, spendSub, Icons.account_balance_wallet_outlined, const Color(0xFF3B82F6), width),
                  _b2bKpiCard('Supplier OTIF Performance', otif, otifSub, Icons.verified_outlined, const Color(0xFFF59E0B), width),
                  _b2bKpiCard('Moisture & Defect Rejection', defect, 'Threshold < 2.0% Safe', Icons.fact_check_outlined, const Color(0xFF8B5CF6), width),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Real-Time Commodity Arbitrage Matrix Table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Real-Time Commodity Sourcing & Price Arbitrage Matrix', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Live benchmark comparing Farmgate Direct Rate against Supermarkets and SADC SAFEX/ZMX wholesale', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading complete procurement matrix spreadsheet (CSV)...')));
                },
                icon: const Icon(Icons.download, size: 14),
                label: const Text('Export Ticker CSV', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFF1E293B).withOpacity(0.6)),
                dataRowHeight: 60,
                columns: const [
                  DataColumn(label: Text('Commodity & Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Verdi Contract', style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Supermarket Spot', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('SADC Benchmark', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Net Arbitrage Saving', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('30D Forecast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Available Inventory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
                rows: _commodityMatrix.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${item['code']} • Moisture: ${item['moisture']}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          ],
                        ),
                      ),
                      DataCell(Text(item['verdiRate'], style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, fontSize: 13))),
                      DataCell(Text(item['supermarket'], style: const TextStyle(color: Color(0xFFEF4444), decoration: TextDecoration.lineThrough, fontSize: 12))),
                      DataCell(Text(item['sadcBenchmark'], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(item['arbitrage'], style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11.5)),
                        ),
                      ),
                      DataCell(Text(item['forward30d'], style: TextStyle(color: item['trendColor'], fontWeight: FontWeight.bold, fontSize: 12))),
                      DataCell(Text(item['stockAvailable'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Forward contract desk initiated for ${item['name']}.'), backgroundColor: const Color(0xFF2563EB)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: const Text('Issue PO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Monthly Procurement Budget vs Actual Variance
          Text('Procurement Budget vs Actual Expenditure Variance', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isDemo ? 'Allocated Working Capital: US\$ 75,000.00' : 'Allocated Working Capital: US\$ 0.00', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
                    Text(isDemo ? 'Utilized: US\$ 64,890.00 (86.5%)' : 'Utilized: US\$ 0.00 (0.0%)', style: TextStyle(color: isDemo ? const Color(0xFF10B981) : const Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: isDemo ? 0.865 : 0.0,
                    minHeight: 10,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _budgetMiniStat('Grains & Cereals', isDemo ? 'US\$ 38,400' : 'US\$ 0.00', isDemo ? '92% of budget' : '0%', const Color(0xFF10B981)),
                    _budgetMiniStat('Oilseeds & Pulses', isDemo ? 'US\$ 16,200' : 'US\$ 0.00', isDemo ? '81% of budget' : '0%', const Color(0xFF3B82F6)),
                    _budgetMiniStat('Horticulture & Fruits', isDemo ? 'US\$ 10,290' : 'US\$ 0.00', isDemo ? '78% of budget' : '0%', const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // TAB 2: Outgrower Cooperatives & QA
  Widget _buildOutgrowerQualityTab() {
    final isDemo = ref.watch(isDemoModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outgrower Cooperatives & Intake Quality Performance', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Real-time reliability scoring, field hectarage, moisture verification, and lot intake defect rates.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 16),
          if (!isDemo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
              child: Column(
                children: [
                  const Icon(Icons.groups_outlined, size: 44, color: Color(0xFF64748B)),
                  const SizedBox(height: 12),
                  Text('No Live Outgrower Cooperative Contracts Active', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 6),
                  const Text('When you issue forward contracts or contract outgrower syndicates in live mode, their intake volume, hectarage, and QA defect scores will stream here in real time.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            )
          else
            ..._outgrowerCoops.map((coop) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coop['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white)),
                          Text('${coop['region']} • Lead: ${coop['lead']}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF10B981))),
                        child: Text(coop['status'], style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _coopStat('Network Size', '${coop['farmers']} Farmers (${coop['hectares']} Ha)'),
                      _coopStat('Intake Volume', coop['deliveredMT']),
                      _coopStat('Grade A %', coop['gradeA']),
                      _coopStat('Defect Rate', coop['defectRate']),
                      _coopStat('OTIF Score', coop['otifScore']),
                      _coopStat('Escrow Settled', coop['escrowSettled']),
                    ],
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  // TAB 3: Escrow Vault & Working Capital
  Widget _buildEscrowCapitalTab() {
    final isDemo = ref.watch(isDemoModeProvider);
    final stage1 = isDemo ? 'US\$ 18,500.00' : 'US\$ 0.00';
    final stage2 = isDemo ? 'US\$ 24,000.00' : 'US\$ 0.00';
    final stage3 = isDemo ? 'US\$ 142,800.00' : 'US\$ 0.00';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Multi-Stage Escrow Vault & Working Capital Utilization', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Verdi Smart Contract Escrow balances, inspection milestones, and settlement clearance pipelines.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _escrowCard('Stage 1: Deposit In Custody', stage1, isDemo ? 'Funds locked pending dispatch' : 'No active deposits', Icons.lock_clock_outlined, const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: _escrowCard('Stage 2: Transit & Inspection', stage2, isDemo ? 'En-route / Lab testing clearance' : 'No consignments in transit', Icons.local_shipping_outlined, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _escrowCard('Stage 3: Settled Payouts', stage3, isDemo ? 'Disbursed to outgrowers in 30D' : 'No live settlements yet', Icons.task_alt, const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 24),
          Text('Recent Escrow Smart Contract Ledger Entries', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
            child: isDemo
                ? Column(
                    children: [
                      _escrowLedgerRow('ESC-9921-A', 'Mashonaland West Silos (White Maize 60 MT)', 'US\$ 17,280.00', 'Stage 3 Cleared', const Color(0xFF10B981)),
                      const Divider(color: Color(0xFF1E293B)),
                      _escrowLedgerRow('ESC-9922-B', 'Mazowe Horticultural Hub (Tomatoes 22 MT)', 'US\$ 20,900.00', 'Stage 2 In Transit', const Color(0xFF3B82F6)),
                      const Divider(color: Color(0xFF1E293B)),
                      _escrowLedgerRow('ESC-9923-C', 'Chinhoyi Oilseed Syndicate (Soybeans 45 MT)', 'US\$ 19,125.00', 'Stage 1 Deposit Locked', const Color(0xFFF59E0B)),
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No live smart contract escrow ledger entries recorded yet.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // TAB 4: Cold-Chain & EUDR Audits
  Widget _buildColdChainEudrTab() {
    final isDemo = ref.watch(isDemoModeProvider);
    final comp = isDemo ? '98.4%' : '100.0%';
    final compSub = isDemo ? 'Mean 3.8°C Target' : 'No active consignments';
    final loss = isDemo ? '0.18%' : '0.00%';
    final lossSub = isDemo ? 'Industry Standard < 1.5%' : '0 Lots in transit';
    final eudr = isDemo ? '100.0%' : '0 Lots';
    final eudrSub = isDemo ? 'Zero Deforestation Cleared' : 'Deforestation Audits Ready';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cold-Chain Telemetry & EUDR Regulatory Audits', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Reefer ambient temperature conformity, in-transit shelf-life decay, and EU Deforestation Regulation polygon verification.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _b2bKpiCard('Reefer Temp Compliance', comp, compSub, Icons.ac_unit, const Color(0xFF3B82F6), double.infinity)),
              const SizedBox(width: 12),
              Expanded(child: _b2bKpiCard('In-Transit Loss Rate', loss, lossSub, Icons.trending_down, const Color(0xFF10B981), double.infinity)),
              const SizedBox(width: 12),
              Expanded(child: _b2bKpiCard('EUDR Geofenced Lots', eudr, eudrSub, Icons.forest_outlined, const Color(0xFF10B981), double.infinity)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isDemo ? 'EUDR Compliance Audit Certificate: ZIM-EXP-2026-LIVE' : 'EUDR Compliance Audit Engine: Active', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    ElevatedButton.icon(
                      onPressed: isDemo ? () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading EUDR Digital Compliance Certificate (PDF)...')));
                      } : null,
                      icon: const Icon(Icons.picture_as_pdf, size: 14),
                      label: const Text('Download Audit Pass', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isDemo
                      ? 'All 1,240 MT exported through Beira and Durban corridors have passed satellite polygon deforestation checks with valid European Union Traceability IDs.'
                      : 'Satellite polygon deforestation verification will automatically certify produce when export consignments are registered in live mode.',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _b2bKpiCard(String title, String value, String change, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(change, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetMiniStat(String label, String value, String sub, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        Text(value, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(sub, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _coopStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _escrowCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _escrowLedgerRow(String id, String desc, String amount, String stage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(id, style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold, fontSize: 12)),
              Text(desc, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(stage, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}


