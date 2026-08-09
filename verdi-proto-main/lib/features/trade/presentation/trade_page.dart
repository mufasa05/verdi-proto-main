import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';
import 'trade_overview_page.dart';
import 'trade_supplier_network_page.dart';
import 'trade_procurement_page.dart';
import 'trade_inventory_page.dart';
import 'trade_quality_page.dart';
import 'trade_processing_page.dart';
import 'trade_sales_page.dart';
import 'trade_logistics_page.dart';
import 'trade_intelligence_page.dart';
import 'trade_compliance_page.dart';

class TradePage extends ConsumerStatefulWidget {
  const TradePage({super.key});

  @override
  ConsumerState<TradePage> createState() => _TradePageState();
}

class _TradePageState extends ConsumerState<TradePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    _TabItem(label: 'Overview', icon: Icons.dashboard_outlined),
    _TabItem(label: 'Suppliers', icon: Icons.handshake_outlined),
    _TabItem(label: 'Procurement', icon: Icons.receipt_long_outlined),
    _TabItem(label: 'Inventory', icon: Icons.inventory_2_outlined),
    _TabItem(label: 'Quality', icon: Icons.fact_check_outlined),
    _TabItem(label: 'Processing', icon: Icons.precision_manufacturing_outlined),
    _TabItem(label: 'Sales', icon: Icons.point_of_sale_outlined),
    _TabItem(label: 'Logistics', icon: Icons.local_shipping_outlined),
    _TabItem(label: 'Intelligence', icon: Icons.auto_graph_outlined),
    _TabItem(label: 'Compliance', icon: Icons.gavel_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedTradeTabProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(selectedTradeTabProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    final openAlerts = ref.watch(openAlertsProvider);
    final alertCount = openAlerts.length;

    return Scaffold(
      backgroundColor: TradeColors.surface,
      body: Column(
        children: [
          _HubHeader(alertCount: alertCount, tabController: _tabController, tabs: _tabs),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TradeOverviewPage(),
                TradeSupplierNetworkPage(),
                TradeProcurementPage(),
                TradeInventoryPage(),
                TradeQualityPage(),
                TradeProcessingPage(),
                TradeSalesPage(),
                TradeLogisticsPage(),
                TradeIntelligencePage(),
                TradeCompliancePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HUB HEADER
// =============================================================================

class _HubHeader extends StatelessWidget {
  final int alertCount;
  final TabController tabController;
  final List<_TabItem> tabs;

  const _HubHeader({
    required this.alertCount,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Title bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.hub_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trade Intelligence Hub',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: TradeColors.dark,
                          ),
                        ),
                        const Text(
                          'Agri-value-chain commerce engine',
                          style: TextStyle(fontSize: 12, color: TradeColors.muted),
                        ),
                      ],
                    ),
                  ),
                  if (alertCount > 0)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TradeColors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: TradeColors.orange, size: 22),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: TradeColors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$alertCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: TradeColors.border),
          // Tab bar
          TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: TradeColors.green,
            indicatorWeight: 3,
            labelColor: TradeColors.green,
            unselectedLabelColor: TradeColors.muted,
            labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: tabs
                .map(
                  (t) => Tab(
                    height: 46,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 16),
                        const SizedBox(width: 6),
                        Text(t.label),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(height: 1, color: TradeColors.border),
        ],
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}