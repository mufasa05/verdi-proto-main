import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/platform_data_state.dart';
import '../../../state/cart_state.dart';
import '../../../state/chat_state.dart';
import '../../auth/state/auth_state.dart';
import '../../../state/app_state.dart';
import '../../logistics/presentation/transporter_telemetry_page.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'In Transit',
    'Delivered',
    'Cancelled',
    'High Priority',
    'Awaiting Payment',
    'Low Stock Risk',
    'Delayed',
    'Traceable Batch',
  ];

  final List<String> _transporterFilters = const [
    'All',
    'Assigned Hauls',
    'In Transit',
    'Delivered',
    'High Priority',
    'Escrow Paid',
    'Reefer Freight',
    'Delayed Route',
  ];

  String _selectedFilter = 'All';
  String _searchQuery = '';
  String? _selectedOrderId;

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const bgLight = Color(0xFFF8FAFC);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderItem> _filteredOrders(List<OrderItem> allOrders) {
    final query = _searchQuery.toLowerCase();
    return allOrders.where((order) {
      final haystack = '${order.id} ${order.buyer} ${order.product} ${order.destination}'.toLowerCase();
      final matchesQuery = query.isEmpty || haystack.contains(query);
      final matchesFilter = _matchesFilter(order, _selectedFilter);
      return matchesQuery && matchesFilter;
    }).toList();
  }

  bool _matchesFilter(OrderItem order, String filter) {
    switch (filter) {
      case 'Pending':
      case 'Confirmed':
      case 'In Transit':
      case 'Delivered':
      case 'Cancelled':
        return order.status == filter;
      case 'High Priority':
        return order.priority == 'High';
      case 'Awaiting Payment':
        return order.payment == 'Pending' || order.payment == 'Unpaid';
      case 'Low Stock Risk':
        return _riskLevel(order) != 'Low' && order.status != 'Delivered';
      case 'Delayed':
      case 'Delayed Route':
        return order.eta.contains('Awaiting') || order.status == 'Pending' || order.status == 'Cancelled';
      case 'Traceable Batch':
        return order.id.contains('1001') || order.id.contains('1003');
      case 'Assigned Hauls':
        return order.status == 'Confirmed' || order.status == 'In Transit' || order.status == 'Pending';
      case 'Escrow Paid':
        return order.payment == 'Paid' || order.payment == 'Escrow';
      case 'Reefer Freight':
        return order.product.toLowerCase().contains('berry') || order.product.toLowerCase().contains('tomato') || order.product.toLowerCase().contains('milk') || order.product.toLowerCase().contains('seed');
      default:
        return true;
    }
  }

  String _riskLevel(OrderItem order) {
    if (order.payment == 'Unpaid' || order.payment == 'Pending' || order.status == 'Pending') {
      return 'High';
    }
    if (order.status == 'In Transit' || order.priority == 'High') {
      return 'Medium';
    }
    return 'Low';
  }

  String _recommendation(OrderItem order) {
    if (order.status == 'Pending') {
      return 'Confirm stock hold and approve the buyer request.';
    }
    if (order.payment == 'Pending' || order.payment == 'Unpaid') {
      return 'Resolve payment before dispatch to protect fulfilment confidence.';
    }
    if (order.status == 'In Transit') {
      return 'Monitor route adherence and protect the delivery ETA.';
    }
    if (order.status == 'Cancelled') {
      return 'Escalate the exception and recover the load plan.';
    }
    return 'Keep the batch traceable and close the loop with the buyer.';
  }

  List<_TimelineStep> _timelineSteps(OrderItem order) {
    final transitDone = order.status == 'In Transit' || order.status == 'Delivered';
    final deliveredDone = order.status == 'Delivered';

    if (order.status == 'Cancelled') {
      return const [
        _TimelineStep('Order placed', true),
        _TimelineStep('Verified', true),
        _TimelineStep('Hold', true, issue: true),
        _TimelineStep('Dispute', true, issue: true),
      ];
    }

    return [
      const _TimelineStep('Order placed', true),
      const _TimelineStep('Verified', true),
      const _TimelineStep('Stock reserved', true),
      _TimelineStep('Packed', transitDone),
      _TimelineStep('Dispatched', transitDone),
      _TimelineStep('In transit', order.status == 'In Transit' || deliveredDone),
      _TimelineStep('Delivered', deliveredDone),
      _TimelineStep('Closed', deliveredDone),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).user;
    final currentRole = ref.watch(appStateProvider).role;
    final isTransporter = currentRole == UserRole.transporter;
    final allOrdersRaw = ref.watch(ordersListProvider);
    final activeFilters = isTransporter ? _transporterFilters : _filters;

    final isDemo = ref.watch(isDemoModeProvider);
    final List<OrderItem> allOrders;
    if (currentRole == UserRole.admin || isTransporter || isDemo) {
      allOrders = allOrdersRaw;
    } else {
      allOrders = allOrdersRaw.where((order) {
        final isBuyer = order.buyer.toLowerCase() == currentUser?.fullName.toLowerCase();
        final isSupplier = order.supplier.toLowerCase() == currentUser?.fullName.toLowerCase();
        return isBuyer || isSupplier || currentUser != null;
      }).toList();
    }

    final orders = _filteredOrders(allOrders);

    if (_selectedOrderId == null && orders.isNotEmpty) {
      _selectedOrderId = orders.first.id;
    }

    final selectedOrder = orders.firstWhere(
      (order) => order.id == _selectedOrderId,
      orElse: () => orders.isNotEmpty
          ? orders.first
          : const OrderItem(
              id: '',
              buyer: '',
              product: '',
              quantity: '',
              destination: '',
              status: '',
              payment: '',
              total: '',
              date: '',
              eta: '',
              priority: '',
              supplier: '',
            ),
    );

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isEndUserCustomer = currentRole == UserRole.consumer;

    final stats = isTransporter
        ? [
            _StatData('Active Freight Hauls', orders.length.toString(), Icons.local_shipping_outlined, '4 live routes', const Color(0xFF2563EB)),
            _StatData('Pending Loading', orders.where((order) => order.status == 'Pending' || order.status == 'Confirmed').length.toString(), Icons.pending_actions_outlined, 'Depot loading ready', Colors.amber),
            _StatData('In Highway Transit', orders.where((order) => order.status == 'In Transit').length.toString(), Icons.navigation_outlined, 'A5 & A3 Corridors', Colors.blue),
            _StatData('Delivered & Offloaded', orders.where((order) => order.status == 'Delivered').length.toString(), Icons.check_circle_outline, '100% on time', Colors.teal),
            _StatData('Haulage Gross Fees', 'US\$ ${_revenueValue(orders)}', Icons.payments_outlined, 'Carrier payout volume', Colors.indigo),
            _StatData('At-Risk Corridors', orders.where((order) => _riskLevel(order) == 'High').length.toString(), Icons.warning_amber_rounded, 'Weather/Road review', Colors.red),
            _StatData('Escrow Payout Due', 'US\$ ${_unpaidValue(orders)}', Icons.account_balance_wallet_outlined, 'Guaranteed escrow', Colors.deepOrange),
            _StatData('Dispatch SLA Score', '${_slaScore(orders)}%', Icons.speed_outlined, 'Top carrier tier', Colors.green),
          ]
        : (isEndUserCustomer
            ? [
                _StatData('My Grocery Orders', orders.length.toString(), Icons.shopping_basket_outlined, 'All household orders', const Color(0xFF10B981)),
                _StatData('Harvest Packing', orders.where((order) => order.status == 'Pending' || order.status == 'Confirmed').length.toString(), Icons.hourglass_top_outlined, 'Preparing fresh harvest', Colors.amber),
                _StatData('Out for Delivery', orders.where((order) => order.status == 'In Transit').length.toString(), Icons.delivery_dining_outlined, 'InDrive Courier en route', Colors.blue),
                _StatData('Delivered to Door', orders.where((order) => order.status == 'Delivered').length.toString(), Icons.check_circle_outline, '100% fulfilled', Colors.teal),
                _StatData('Total Spend', 'US\$ ${_revenueValue(orders)}', Icons.payments_outlined, 'Household grocery spend', Colors.indigo),
                _StatData('Direct Savings', 'US\$ ${(double.tryParse(_revenueValue(orders).replaceAll(',', '')) ?? 0.0 * 0.25).toStringAsFixed(2)}', Icons.savings_outlined, 'Saved vs supermarket', Colors.green),
                _StatData('Protected in Escrow', 'US\$ ${_unpaidValue(orders)}', Icons.lock_clock_outlined, 'Auto-refund protection', Colors.deepOrange),
                _StatData('Freshness Rating', '5.0 ★', Icons.eco_outlined, 'Harvested <24h ago', Colors.green),
              ]
            : [
                _StatData('Total orders', orders.length.toString(), Icons.receipt_long_outlined, '+12% this week', const Color(0xFF10B981)),
                _StatData('Pending approval', orders.where((order) => order.status == 'Pending').length.toString(), Icons.pending_actions_outlined, 'Action required', Colors.amber),
                _StatData('In transit', orders.where((order) => order.status == 'In Transit').length.toString(), Icons.delivery_dining_outlined, 'Active corridors', Colors.blue),
                _StatData('Delivered today', orders.where((order) => order.status == 'Delivered').length.toString(), Icons.check_circle_outline, '100% on time', Colors.teal),
                _StatData('Revenue', 'US\$ ${_revenueValue(orders)}', Icons.payments_outlined, 'Gross volume', Colors.indigo),
                _StatData('At-risk orders', orders.where((order) => _riskLevel(order) == 'High').length.toString(), Icons.warning_amber_rounded, 'Requires review', Colors.red),
                _StatData('Unpaid value', 'US\$ ${_unpaidValue(orders)}', Icons.account_balance_wallet_outlined, 'Pending escrow', Colors.deepOrange),
                _StatData('Fulfillment SLA', '${_slaScore(orders)}%', Icons.speed_outlined, 'High SLA score', Colors.green),
              ]);

    return Scaffold(
      backgroundColor: bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isTransporter
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransporterTelemetryPage()),
                );
              }
            : () => _showNewOrderDialog(context, ref),
        backgroundColor: isTransporter ? const Color(0xFF2563EB) : green,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(isTransporter ? Icons.pin_drop_outlined : Icons.add_circle_outline, size: 20),
        label: Text(
          isTransporter ? 'Live GPS Telemetry' : 'New Order',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: SingleChildScrollView(
              padding: width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UpgradedHeaderBanner(
                    isCompact: !isDesktop,
                    isTransporter: isTransporter,
                    selectedFilter: _selectedFilter,
                    filters: activeFilters,
                    controller: _searchController,
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onFilterChanged: (value) {
                      setState(() {
                        _selectedFilter = value;
                        final filtered = _filteredOrders(allOrders);
                        if (filtered.isNotEmpty) {
                          _selectedOrderId = filtered.first.id;
                        }
                      });
                    },
                    onExport: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting orders report to CSV...')),
                      );
                    },
                    onSync: () {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Orders synced with network database.')),
                      );
                    },
                    onAlerts: () {
                      final atRisk = allOrders.where((o) => _riskLevel(o) == 'High').toList();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                              const SizedBox(width: 8),
                              Text('At-Risk Orders Alert', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: SizedBox(
                            width: 420,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: atRisk.map((o) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                  child: const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                ),
                                title: Text('${o.id} - ${o.buyer}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                subtitle: Text('${o.product} • ${o.status} • Payment: ${o.payment}', style: GoogleFonts.inter(fontSize: 12)),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() => _selectedOrderId = o.id);
                                },
                              )).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _UpgradedStatsGrid(cards: stats, isDesktop: isDesktop),
                  const SizedBox(height: 20),
                  if (orders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 54, color: muted),
                          const SizedBox(height: 12),
                          Text(
                            'No orders found matching this filter',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: dark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try clearing search keywords or selecting "All" filter.',
                            style: GoogleFonts.inter(fontSize: 13, color: muted),
                          ),
                        ],
                      ),
                    )
                  else if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _UpgradedSectionCard(
                            title: 'Order Queue',
                            subtitle: '${orders.length} active shipments',
                            child: Column(
                              children: [
                                for (int i = 0; i < orders.length; i++) ...[
                                  _UpgradedOrderCard(
                                    order: orders[i],
                                    selected: orders[i].id == _selectedOrderId,
                                    riskLevel: _riskLevel(orders[i]),
                                    onTap: () {
                                      setState(() => _selectedOrderId = orders[i].id);
                                    },
                                  ),
                                  if (i != orders.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _UpgradedSectionCard(
                                title: 'Order Command Center',
                                subtitle: 'Real-time fulfillment control',
                                child: _UpgradedOrderDetailPanel(
                                  order: selectedOrder,
                                  recommendation: _recommendation(selectedOrder),
                                  riskLevel: _riskLevel(selectedOrder),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _UpgradedSectionCard(
                                title: 'Fulfillment Timeline',
                                subtitle: 'Batch progress tracker',
                                child: _UpgradedTimeline(steps: _timelineSteps(selectedOrder)),
                              ),
                              const SizedBox(height: 18),
                              _UpgradedSectionCard(
                                title: 'Exception Watch',
                                subtitle: 'Risk & dispute monitor',
                                child: _UpgradedIssuePanel(order: selectedOrder),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _UpgradedSectionCard(
                          title: 'Order Command Center',
                          subtitle: 'Real-time fulfillment control',
                          child: _UpgradedOrderDetailPanel(
                            order: selectedOrder,
                            recommendation: _recommendation(selectedOrder),
                            riskLevel: _riskLevel(selectedOrder),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _UpgradedSectionCard(
                          title: 'Order Queue',
                          subtitle: '${orders.length} active shipments',
                          child: Column(
                            children: [
                              for (int i = 0; i < orders.length; i++) ...[
                                _UpgradedOrderCard(
                                  order: orders[i],
                                  selected: orders[i].id == _selectedOrderId,
                                  riskLevel: _riskLevel(orders[i]),
                                  onTap: () {
                                    setState(() => _selectedOrderId = orders[i].id);
                                  },
                                ),
                                if (i != orders.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _UpgradedSectionCard(
                          title: 'Fulfillment Timeline',
                          subtitle: 'Batch progress tracker',
                          child: _UpgradedTimeline(steps: _timelineSteps(selectedOrder)),
                        ),
                        const SizedBox(height: 18),
                        _UpgradedSectionCard(
                          title: 'Exception Watch',
                          subtitle: 'Risk & dispute monitor',
                          child: _UpgradedIssuePanel(order: selectedOrder),
                        ),
                      ],
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _revenueValue(List<OrderItem> orders) {
    final values = orders.where((order) => order.total.contains('US\$')).map((order) {
      final raw = order.total.replaceAll('US\$', '').replaceAll(',', '').trim();
      return int.tryParse(raw) ?? 0;
    }).toList();
    return values.fold<int>(0, (a, b) => a + b).toString();
  }

  String _unpaidValue(List<OrderItem> orders) {
    final values = orders.where((order) => order.payment == 'Pending' || order.payment == 'Unpaid').map((order) {
      final raw = order.total.replaceAll('US\$', '').replaceAll(',', '').trim();
      return int.tryParse(raw) ?? 0;
    }).toList();
    return values.fold<int>(0, (a, b) => a + b).toString();
  }

  String _slaScore(List<OrderItem> orders) {
    if (orders.isEmpty) return '100';
    final score = (orders.where((order) => order.status != 'Pending' && order.status != 'Cancelled').length / orders.length * 100).round();
    return score.toString();
  }
}

// Logic implementations for buttons
void _showRouteTrackingDialog(BuildContext context, WidgetRef ref, OrderItem order) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _OrdersPageState.green.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.alt_route_rounded, color: _OrdersPageState.green, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Route Tracking: ${order.id}',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: _OrdersPageState.dark),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _OrdersPageState.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _OrdersPageState.green.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Corridor: Harare - ${order.destination} Express Route', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 4),
                    Text('Status: ${order.status} • ETA: ${order.eta}', style: GoogleFonts.inter(color: _OrdersPageState.muted, fontSize: 12.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text('Driver & Vehicle Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: _OrdersPageState.dark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 20, color: _OrdersPageState.muted),
                  const SizedBox(width: 8),
                  Text('Scania R500 (Reg: AEB-2910)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 20, color: _OrdersPageState.muted),
                  const SizedBox(width: 8),
                  Text('Tafadzwa M. (Driver)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 14),
              Text('Route Adherence & Health', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: _OrdersPageState.dark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: LinearProgressIndicator(
                      value: 0.98,
                      minHeight: 8,
                      color: _OrdersPageState.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('98% On Route', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _OrdersPageState.green)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling Driver Tafadzwa M. (+263 77 123 4567)...')),
              );
            },
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Call Driver'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ref.read(appStateProvider.notifier).setNavIndex(13);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Geospatial GIS Map...')),
              );
            },
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('View Full Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _OrdersPageState.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    },
  );
}

void _messageBuyer(BuildContext context, WidgetRef ref, OrderItem order) {
  ref.read(chatProvider.notifier).startOrGetThread(
        order.buyer,
        'Order ${order.id} Inquiry',
        'Hello ${order.buyer}, I am contacting you regarding Order ${order.id} for ${order.product} (${order.quantity}). Is everything on track?',
      );
  ref.read(appStateProvider.notifier).setNavIndex(2);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Opened chat thread with ${order.buyer}')),
  );
}

void _showRepeatOrderDialog(BuildContext context, WidgetRef ref, OrderItem order) {
  final qtyController = TextEditingController(text: order.quantity);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Repeat Order ${order.id}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duplicate order details for ${order.buyer}:', style: GoogleFonts.inter(color: _OrdersPageState.muted)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product: ${order.product}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  Text('Destination: ${order.destination}', style: GoogleFonts.inter(color: _OrdersPageState.muted, fontSize: 13)),
                  Text('Original Total: ${order.total}', style: GoogleFonts.inter(color: _OrdersPageState.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(
                labelText: 'Quantity to Order',
                hintText: 'e.g. 120 kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newId = '#ORD-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';
              final newOrder = OrderItem(
                id: newId,
                buyer: order.buyer,
                product: order.product,
                quantity: qtyController.text.trim().isEmpty ? order.quantity : qtyController.text.trim(),
                destination: order.destination,
                status: 'Pending',
                payment: 'Pending',
                total: order.total,
                date: 'Just now',
                eta: '2h 00m',
                priority: order.priority,
                supplier: order.supplier,
              );

              ref.read(ordersListProvider.notifier).addOrder(newOrder);
              ref.read(cartProvider.notifier).addItem(
                    CartItem(
                      id: '${newOrder.product}-${newOrder.buyer}',
                      name: newOrder.product,
                      price: newOrder.total,
                      quantity: 1,
                      imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80',
                      supplier: newOrder.supplier,
                    ),
                  );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Repeat Order $newId created successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _OrdersPageState.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Repeat Order'),
          ),
        ],
      );
    },
  );
}

void _showUpdateStatusDialog(BuildContext context, WidgetRef ref, OrderItem order) {
  String currentStatus = order.status;
  String currentPayment = order.payment;
  String currentPriority = order.priority;
  final etaController = TextEditingController(text: order.eta);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Update Status: ${order.id}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: ['Pending', 'Confirmed', 'In Transit', 'Delivered', 'Cancelled'].contains(currentStatus) ? currentStatus : 'Pending',
                    decoration: const InputDecoration(labelText: 'Fulfillment Status'),
                    items: const ['Pending', 'Confirmed', 'In Transit', 'Delivered', 'Cancelled']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => currentStatus = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: ['Paid', 'Pending', 'Unpaid'].contains(currentPayment) ? currentPayment : 'Pending',
                    decoration: const InputDecoration(labelText: 'Payment Status'),
                    items: const ['Paid', 'Pending', 'Unpaid']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => currentPayment = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: ['Low', 'Medium', 'High'].contains(currentPriority) ? currentPriority : 'Medium',
                    decoration: const InputDecoration(labelText: 'Priority Level'),
                    items: const ['Low', 'Medium', 'High']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => currentPriority = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: etaController,
                    decoration: const InputDecoration(labelText: 'ETA / Delivery Time', hintText: 'e.g. 45m or Completed'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updated = OrderItem(
                    id: order.id,
                    buyer: order.buyer,
                    product: order.product,
                    quantity: order.quantity,
                    destination: order.destination,
                    status: currentStatus,
                    payment: currentPayment,
                    total: order.total,
                    date: order.date,
                    eta: etaController.text.trim().isEmpty ? order.eta : etaController.text.trim(),
                    priority: currentPriority,
                    supplier: order.supplier,
                  );

                  ref.read(ordersListProvider.notifier).updateOrder(updated);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order ${order.id} status updated to "$currentStatus"')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _OrdersPageState.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showNewOrderDialog(BuildContext context, WidgetRef ref) {
  final buyerController = TextEditingController();
  final quantityController = TextEditingController(text: '100 kg');
  final destinationController = TextEditingController(text: 'Harare');
  final totalController = TextEditingController(text: 'US\$ 150');
  final etaController = TextEditingController(text: '2h 30m');
  String selectedProduct = 'Tomatoes';
  String selectedStatus = 'Pending';
  String selectedPayment = 'Pending';
  String selectedPriority = 'Medium';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Create New Order', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: buyerController,
                    decoration: const InputDecoration(labelText: 'Buyer / Client Name', hintText: 'e.g. Masvingo Fresh Ltd'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedProduct,
                    decoration: const InputDecoration(labelText: 'Product'),
                    items: const ['Tomatoes', 'Maize', 'Potatoes', 'Onions', 'Beans', 'Vegetables', 'Fruits', 'Mango']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedProduct = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity', hintText: 'e.g. 500 kg'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: destinationController,
                    decoration: const InputDecoration(labelText: 'Destination City / Hub', hintText: 'e.g. Harare Depot'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: totalController,
                    decoration: const InputDecoration(labelText: 'Total Value', hintText: 'e.g. US\$ 450'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: const ['Pending', 'Confirmed', 'In Transit', 'Delivered']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => selectedStatus = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPayment,
                          decoration: const InputDecoration(labelText: 'Payment'),
                          items: const ['Pending', 'Paid', 'Unpaid']
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => selectedPayment = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPriority,
                          decoration: const InputDecoration(labelText: 'Priority'),
                          items: const ['Low', 'Medium', 'High']
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => selectedPriority = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: etaController,
                          decoration: const InputDecoration(labelText: 'ETA', hintText: 'e.g. 2h 30m'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final buyer = buyerController.text.trim();
                  if (buyer.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter buyer name.')),
                    );
                    return;
                  }

                  final newId = '#ORD-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';
                  final currentUser = ref.read(authStateProvider).user;
                  final newOrder = OrderItem(
                    id: newId,
                    buyer: buyer,
                    product: selectedProduct,
                    quantity: quantityController.text.trim(),
                    destination: destinationController.text.trim(),
                    status: selectedStatus,
                    payment: selectedPayment,
                    total: totalController.text.trim().startsWith('US\$')
                        ? totalController.text.trim()
                        : 'US\$ ${totalController.text.trim()}',
                    date: 'Today, Just now',
                    eta: etaController.text.trim(),
                    priority: selectedPriority,
                    supplier: currentUser?.fullName ?? 'Masara Farm',
                  );

                  ref.read(ordersListProvider.notifier).addOrder(newOrder);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('New Order $newId created successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _OrdersPageState.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Order'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _UpgradedHeaderBanner extends StatelessWidget {
  final bool isCompact;
  final bool isTransporter;
  final String selectedFilter;
  final List<String> filters;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onExport;
  final VoidCallback onSync;
  final VoidCallback onAlerts;

  const _UpgradedHeaderBanner({
    required this.isCompact,
    this.isTransporter = false,
    required this.selectedFilter,
    required this.filters,
    required this.controller,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onExport,
    required this.onSync,
    required this.onAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            isTransporter ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isTransporter ? 'Freight Haulage & Dispatch Hub' : 'Order Operations Hub',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: isCompact ? 22 : 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isTransporter ? const Color(0xFF3B82F6) : const Color(0xFF10B981)).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: (isTransporter ? const Color(0xFF3B82F6) : const Color(0xFF10B981)).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isTransporter ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isTransporter ? 'CARRIER FLEET LIVE' : 'LIVE NETWORK',
                                style: GoogleFonts.inter(
                                  color: isTransporter ? const Color(0xFF93C5FD) : const Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isTransporter
                          ? 'Active cargo loads, carrier dispatch slips, route waybills, and driver payout milestones.'
                          : 'Automated batch tracking, SLA monitoring, and delivery corridor execution across Zimbabwe.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF94A3B8),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 16),
                _bannerActionButton('Export CSV', Icons.ios_share_outlined, onExport, Colors.white12),
                const SizedBox(width: 8),
                _bannerActionButton('Sync Network', Icons.sync_outlined, onSync, Colors.white12),
                const SizedBox(width: 8),
                _bannerActionButton('Risk Alerts', Icons.notifications_active_outlined, onAlerts, Colors.amber.withValues(alpha: 0.25), isHighlight: true),
              ],
            ],
          ),
          if (isCompact) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _bannerActionButton('Export CSV', Icons.ios_share_outlined, onExport, Colors.white12)),
                const SizedBox(width: 8),
                Expanded(child: _bannerActionButton('Sync', Icons.sync_outlined, onSync, Colors.white12)),
                const SizedBox(width: 8),
                Expanded(child: _bannerActionButton('Alerts', Icons.notifications_active_outlined, onAlerts, Colors.amber.withValues(alpha: 0.25), isHighlight: true)),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search buyer name, product, or order ID...',
                hintStyle: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_outlined, color: Color(0xFF10B981), size: 22),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.white70),
                        onPressed: () {
                          controller.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onFilterChanged(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.12),
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerActionButton(String label, IconData icon, VoidCallback onPressed, Color bg, {bool isHighlight = false}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: isHighlight ? Colors.amber : Colors.white),
      label: Text(label, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: isHighlight ? Colors.amber : Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _UpgradedStatsGrid extends StatelessWidget {
  final bool isDesktop;
  final List<_StatData> cards;

  const _UpgradedStatsGrid({required this.isDesktop, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 950
            ? 4
            : (constraints.maxWidth > 520 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 96,
          ),
          itemBuilder: (context, index) {
            final stat = cards[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: stat.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(stat.icon, color: stat.accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12, color: _OrdersPageState.muted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          stat.value,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _OrdersPageState.dark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat.trend,
                          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: stat.accentColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _UpgradedOrderCard extends StatelessWidget {
  final OrderItem order;
  final bool selected;
  final String riskLevel;
  final VoidCallback onTap;

  const _UpgradedOrderCard({
    required this.order,
    required this.selected,
    required this.riskLevel,
    required this.onTap,
  });

  Color _statusColor() {
    switch (order.status) {
      case 'Pending':
        return Colors.amber.shade800;
      case 'Confirmed':
        return Colors.blue.shade700;
      case 'In Transit':
        return _OrdersPageState.green;
      case 'Delivered':
        return const Color(0xFF64748B);
      case 'Cancelled':
        return Colors.red.shade700;
      default:
        return _OrdersPageState.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final isAtRisk = riskLevel == 'High';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _OrdersPageState.green.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _OrdersPageState.green : Colors.black.withValues(alpha: 0.08),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? _OrdersPageState.green.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left selection bar accent
            if (selected)
              Container(
                width: 4,
                height: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: _OrdersPageState.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${order.id} • ${order.buyer}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _OrdersPageState.dark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          order.status,
                          style: GoogleFonts.inter(
                            color: statusColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: _OrdersPageState.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${order.product} • ${order.quantity}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(color: _OrdersPageState.dark, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: _OrdersPageState.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${order.destination} • ${order.date}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12, color: _OrdersPageState.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _upgradedMiniTag(label: order.payment, icon: Icons.payment_outlined, isSuccess: order.payment == 'Paid'),
                      _upgradedMiniTag(label: order.priority, icon: Icons.flag_outlined, isWarning: order.priority == 'High'),
                      _upgradedMiniTag(label: 'Batch TR-47', icon: Icons.fact_check_outlined),
                      if (isAtRisk)
                        _upgradedMiniTag(label: 'Risk Alert', icon: Icons.warning_amber_rounded, isDanger: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _progressValue(order.status),
                            minHeight: 7,
                            backgroundColor: Colors.grey.shade200,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        order.eta,
                        style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.w800, fontSize: 12.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upgradedMiniTag({required String label, required IconData icon, bool isSuccess = false, bool isWarning = false, bool isDanger = false}) {
    final Color bg = isDanger
        ? Colors.red.shade50
        : (isWarning ? Colors.amber.shade50 : (isSuccess ? _OrdersPageState.green.withValues(alpha: 0.1) : Colors.grey.shade100));
    final Color text = isDanger
        ? Colors.red.shade800
        : (isWarning ? Colors.amber.shade900 : (isSuccess ? _OrdersPageState.green : _OrdersPageState.dark));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: text)),
        ],
      ),
    );
  }

  double _progressValue(String status) {
    switch (status) {
      case 'Pending':
        return 0.2;
      case 'Confirmed':
        return 0.45;
      case 'In Transit':
        return 0.75;
      case 'Delivered':
        return 1.0;
      case 'Cancelled':
        return 0.0;
      default:
        return 0.2;
    }
  }
}

class _UpgradedOrderDetailPanel extends ConsumerWidget {
  final OrderItem order;
  final String recommendation;
  final String riskLevel;

  const _UpgradedOrderDetailPanel({required this.order, required this.recommendation, required this.riskLevel});

  Color _statusColor() {
    switch (order.status) {
      case 'Pending':
        return Colors.amber.shade800;
      case 'Confirmed':
        return Colors.blue.shade700;
      case 'In Transit':
        return _OrdersPageState.green;
      case 'Delivered':
        return const Color(0xFF64748B);
      case 'Cancelled':
        return Colors.red.shade700;
      default:
        return _OrdersPageState.muted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor();
    final isAtRisk = riskLevel == 'High';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: _OrdersPageState.dark),
                  ),
                  const SizedBox(height: 2),
                  Text(order.buyer, style: GoogleFonts.inter(color: _OrdersPageState.muted, fontSize: 13.5)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isAtRisk ? Colors.orange.shade50 : _OrdersPageState.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isAtRisk ? Colors.orange.shade300 : _OrdersPageState.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isAtRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    size: 14,
                    color: isAtRisk ? Colors.orange.shade800 : _OrdersPageState.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isAtRisk ? 'Needs attention' : 'Stable promise',
                    style: GoogleFonts.inter(
                      color: isAtRisk ? Colors.orange.shade900 : _OrdersPageState.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Metadata Table Cards
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _OrdersPageState.bgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              _detailRow(Icons.shopping_bag_outlined, 'Ordered items', order.product),
              _detailRow(Icons.scale_outlined, 'Quantity', order.quantity),
              _detailRow(Icons.place_outlined, 'Destination', order.destination),
              _detailRow(Icons.attach_money_outlined, 'Total value', order.total, isGreen: true),
              _detailRow(Icons.credit_card_outlined, 'Payment state', order.payment),
              _detailRow(Icons.speed_outlined, 'Priority / SLA', '${order.priority} • ${order.eta}'),
              _detailRow(Icons.qr_code_outlined, 'Traceability', 'Batch #TR-47'),
              _detailRow(Icons.route_outlined, 'Route summary', '${order.destination} corridor'),
            ],
          ),
        ),

        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _OrdersPageState.green.withValues(alpha: 0.08),
                _OrdersPageState.dark.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _OrdersPageState.green.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: _OrdersPageState.green, size: 18),
                  const SizedBox(width: 8),
                  Text('Recommended next action', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: _OrdersPageState.dark, fontSize: 13.5)),
                ],
              ),
              const SizedBox(height: 6),
              Text(recommendation, style: GoogleFonts.inter(color: _OrdersPageState.muted, fontSize: 13, height: 1.35)),
            ],
          ),
        ),

        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _progressValue(order.status),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: statusColor,
          ),
        ),
        const SizedBox(height: 14),

        // Action Chips (Open route, Message buyer)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _upgradedInteractiveChip(label: order.status, icon: Icons.info_outline),
            _upgradedInteractiveChip(label: order.eta, icon: Icons.timer_outlined),
            _upgradedInteractiveChip(
              label: 'Open route',
              icon: Icons.alt_route_outlined,
              onTap: () => _showRouteTrackingDialog(context, ref, order),
            ),
            _upgradedInteractiveChip(
              label: 'Message buyer',
              icon: Icons.chat_bubble_outline,
              onTap: () => _messageBuyer(context, ref, order),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Primary Buttons (Repeat order, Update status)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showRepeatOrderDialog(context, ref, order),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Repeat Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _OrdersPageState.green,
                  side: const BorderSide(color: _OrdersPageState.green, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateStatusDialog(context, ref, order),
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text('Update Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _OrdersPageState.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: _OrdersPageState.green.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _OrdersPageState.muted),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(color: _OrdersPageState.muted, fontWeight: FontWeight.w500, fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: GoogleFonts.inter(
                color: isGreen ? _OrdersPageState.green : _OrdersPageState.dark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _upgradedInteractiveChip({required String label, required IconData icon, VoidCallback? onTap}) {
    final isClickable = onTap != null;
    return ActionChip(
      avatar: Icon(icon, size: 16, color: isClickable ? _OrdersPageState.green : _OrdersPageState.muted),
      label: Text(label),
      labelStyle: GoogleFonts.inter(
        color: isClickable ? _OrdersPageState.green : _OrdersPageState.dark,
        fontWeight: isClickable ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      side: isClickable ? const BorderSide(color: _OrdersPageState.green, width: 1.2) : BorderSide(color: Colors.black.withValues(alpha: 0.1)),
      backgroundColor: isClickable ? _OrdersPageState.green.withValues(alpha: 0.08) : Colors.white,
      onPressed: onTap ?? () {},
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  double _progressValue(String status) {
    switch (status) {
      case 'Pending':
        return 0.2;
      case 'Confirmed':
        return 0.45;
      case 'In Transit':
        return 0.75;
      case 'Delivered':
        return 1.0;
      case 'Cancelled':
        return 0.0;
      default:
        return 0.2;
    }
  }
}

class _UpgradedTimeline extends StatelessWidget {
  final List<_TimelineStep> steps;

  const _UpgradedTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: step.issue ? Colors.red : (step.done ? _OrdersPageState.green : Colors.grey.shade200),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.issue ? Icons.close : (step.done ? Icons.check : Icons.circle),
                    size: step.done ? 14 : 6,
                    color: step.done || step.issue ? Colors.white : Colors.grey.shade400,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: step.done ? _OrdersPageState.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  step.label,
                  style: GoogleFonts.inter(
                    fontWeight: step.done ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    color: step.issue ? Colors.red : (step.done ? _OrdersPageState.dark : _OrdersPageState.muted),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _UpgradedIssuePanel extends StatelessWidget {
  final OrderItem order;

  const _UpgradedIssuePanel({required this.order});

  @override
  Widget build(BuildContext context) {
    final issue = order.status == 'Cancelled'
        ? 'Dispatch exception requires review.'
        : order.payment == 'Pending' || order.payment == 'Unpaid'
            ? 'Payment is still open and can endanger the promise.'
            : 'No active exception. Delivery confidence remains healthy.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(issue, style: GoogleFonts.inter(color: _OrdersPageState.muted, fontSize: 13)),
        const SizedBox(height: 10),
        if (order.status == 'Cancelled')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(child: Text('Shortage and dispute escalation required.', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.red.shade900))),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _OrdersPageState.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _OrdersPageState.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: _OrdersPageState.green),
                const SizedBox(width: 10),
                Expanded(child: Text('Inventory promise and route execution are on track.', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: _OrdersPageState.green))),
              ],
            ),
          ),
      ],
    );
  }
}

class _UpgradedSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _UpgradedSectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: _OrdersPageState.dark),
              ),
              if (subtitle != null) ...[
                const Spacer(),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(fontSize: 12, color: _OrdersPageState.muted, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final bool done;
  final bool issue;

  const _TimelineStep(this.label, this.done, {this.issue = false});
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final Color accentColor;

  _StatData(this.label, this.value, this.icon, this.trend, this.accentColor);
}
