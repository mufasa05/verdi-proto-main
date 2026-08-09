import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeSalesPage extends ConsumerStatefulWidget {
  const TradeSalesPage({super.key});

  @override
  ConsumerState<TradeSalesPage> createState() => _TradeSalesPageState();
}

class _TradeSalesPageState extends ConsumerState<TradeSalesPage> {
  String _filter = 'All';
  String? _selectedOrderId;

  final _filters = ['All', 'Draft', 'Confirmed', 'Dispatched', 'Delivered', 'Cancelled'];

  List<SalesOrder> _filtered(List<SalesOrder> all) {
    if (_filter == 'All') return all;
    return all.where((so) => so.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(salesOrderProvider);
    final filtered = _filtered(allOrders);

    if (_selectedOrderId == null && filtered.isNotEmpty) {
      _selectedOrderId = filtered.first.id;
    }

    final selected = filtered.isEmpty
        ? null
        : filtered.firstWhere((so) => so.id == _selectedOrderId, orElse: () => filtered.first);

    final revenueMtd = allOrders.where((so) => so.status != 'Cancelled').fold<double>(0, (s, so) => s + so.totalValue);
    final paidCount = allOrders.where((so) => so.paymentStatus == 'Paid').length;

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;

      final listPanel = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TradePageHeader(
              title: 'Sales & Distribution',
              subtitle: 'Customer orders, dispatch planning, and invoicing.',
              actions: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Sale'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradeColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            // KPI row
            LayoutBuilder(builder: (ctx, c) {
              final cols = c.maxWidth >= 600 ? 4 : 2;
              final ratio = c.maxWidth >= 600 ? 1.8 : 1.35;
              return GridView.count(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: ratio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  TradeStatTile(label: 'Total Orders', value: '${allOrders.length}', icon: Icons.shopping_bag_outlined),
                  TradeStatTile(label: 'Revenue MTD', value: 'US\$ ${(revenueMtd / 1000).toStringAsFixed(1)}k', icon: Icons.attach_money, iconColor: TradeColors.green, trendPercent: 12.6),
                  TradeStatTile(label: 'Paid', value: '$paidCount', icon: Icons.payments_outlined, iconColor: TradeColors.green, valueColor: TradeColors.green),
                  TradeStatTile(
                    label: 'Unpaid',
                    value: '${allOrders.where((so) => so.paymentStatus != 'Paid' && so.status != 'Cancelled').length}',
                    icon: Icons.pending_outlined,
                    iconColor: TradeColors.orange,
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            TradeFilterRow(filters: _filters, selected: _filter, onSelect: (f) => setState(() {
              _filter = f;
              _selectedOrderId = null;
            })),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No orders for this filter.', style: TextStyle(color: TradeColors.muted))))
            else
              for (final so in filtered) ...[
                _SalesOrderCard(
                  order: so,
                  isSelected: so.id == _selectedOrderId && isWide,
                  onTap: () => setState(() => _selectedOrderId = so.id),
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 48),
          ],
        ),
      );

      if (isWide && selected != null) {
        return Row(
          children: [
            Expanded(flex: 5, child: listPanel),
            const VerticalDivider(width: 1, color: TradeColors.border),
            Expanded(
              flex: 3,
              child: _SalesDetailPanel(
                order: selected,
                onUpdateStatus: (s) => ref.read(salesOrderProvider.notifier).updateStatus(selected.id, s),
                onMarkPaid: () => ref.read(salesOrderProvider.notifier).markPaid(selected.id),
                onClose: () => setState(() => _selectedOrderId = null),
              ),
            ),
          ],
        );
      }
      return listPanel;
    });
  }
}

class _SalesOrderCard extends StatelessWidget {
  final SalesOrder order;
  final bool isSelected;
  final VoidCallback onTap;

  const _SalesOrderCard({required this.order, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TradeColors.green.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? TradeColors.green : TradeColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.id} — ${order.buyerName}',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: TradeColors.dark),
                  ),
                ),
                TradeBadge(label: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.lines.map((l) => '${l.productName} ${l.quantityKg.round()}kg').join(' • '),
              style: const TextStyle(fontSize: 12, color: TradeColors.muted),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'US\$ ${order.totalValue.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: TradeColors.dark),
                ),
                const Spacer(),
                TradeBadge(
                  label: order.paymentStatus,
                  color: switch (order.paymentStatus) {
                    'Paid' => TradeColors.green,
                    'Partial' => TradeColors.orange,
                    _ => TradeColors.red,
                  },
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined, size: 13, color: TradeColors.muted),
                Text(order.buyerRegion, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesDetailPanel extends StatelessWidget {
  final SalesOrder order;
  final ValueChanged<String> onUpdateStatus;
  final VoidCallback onMarkPaid;
  final VoidCallback onClose;

  const _SalesDetailPanel({
    required this.order,
    required this.onUpdateStatus,
    required this.onMarkPaid,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(order.id, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: TradeColors.dark))),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: [
            TradeBadge(label: order.status),
            const SizedBox(width: 8),
            TradeBadge(
              label: order.paymentStatus,
              color: switch (order.paymentStatus) {
                'Paid' => TradeColors.green,
                'Partial' => TradeColors.orange,
                _ => TradeColors.red,
              },
            ),
          ]),
          const SizedBox(height: 16),
          TradeSectionCard(
            title: 'Buyer',
            child: Column(children: [
              MetricRow(label: 'Buyer', value: order.buyerName),
              MetricRow(label: 'Region', value: order.buyerRegion),
              MetricRow(label: 'Invoice', value: order.invoiceId),
              MetricRow(label: 'Order Date', value: order.orderDate),
              if (order.dispatchDate != null) MetricRow(label: 'Dispatched', value: order.dispatchDate!),
            ]),
          ),
          const SizedBox(height: 12),
          TradeSectionCard(
            title: 'Line Items',
            child: Column(
              children: [
                // Table header
                Row(
                  children: const [
                    Expanded(child: Text('Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TradeColors.muted))),
                    SizedBox(width: 50, child: Text('Qty (kg)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TradeColors.muted), textAlign: TextAlign.right)),
                    SizedBox(width: 80, child: Text('Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TradeColors.muted), textAlign: TextAlign.right)),
                  ],
                ),
                const Divider(height: 16, color: TradeColors.border),
                ...order.lines.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(l.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      SizedBox(width: 50, child: Text('${l.quantityKg.round()}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                      SizedBox(width: 80, child: Text('US\$ ${l.lineTotal.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: TradeColors.dark))),
                    ],
                  ),
                )),
                const Divider(height: 8, color: TradeColors.border),
                Row(
                  children: [
                    const Expanded(child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                    Text('US\$ ${order.totalValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: TradeColors.green)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (order.status == 'Confirmed')
                ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('Dispatched'),
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Dispatch'),
                  style: ElevatedButton.styleFrom(backgroundColor: TradeColors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              if (order.status == 'Dispatched')
                ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('Delivered'),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Mark Delivered'),
                  style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              if (order.paymentStatus != 'Paid')
                ElevatedButton.icon(
                  onPressed: onMarkPaid,
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Mark Paid'),
                  style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
