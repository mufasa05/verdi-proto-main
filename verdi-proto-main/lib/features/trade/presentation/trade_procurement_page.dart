import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeProcurementPage extends ConsumerStatefulWidget {
  const TradeProcurementPage({super.key});

  @override
  ConsumerState<TradeProcurementPage> createState() => _TradeProcurementPageState();
}

class _TradeProcurementPageState extends ConsumerState<TradeProcurementPage> {
  String _filter = 'All';
  String? _selectedPoId;

  final _statusFilters = ['All', 'Draft', 'Sent', 'Confirmed', 'Received', 'Cancelled'];

  List<PurchaseOrder> _filtered(List<PurchaseOrder> all) {
    if (_filter == 'All') return all;
    return all.where((po) => po.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(purchaseOrderProvider);
    final suppliers = ref.watch(tradeSupplierProvider);
    final filtered = _filtered(allOrders);

    if (_selectedPoId == null && filtered.isNotEmpty) {
      _selectedPoId = filtered.first.id;
    }

    final selected = filtered.isEmpty
        ? null
        : filtered.firstWhere(
            (po) => po.id == _selectedPoId,
            orElse: () => filtered.first,
          );

    final supplierMap = {for (final s in suppliers) s.id: s};

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;

      final listPanel = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TradePageHeader(
              title: 'Procurement Desk',
              subtitle: 'Purchase requests, RFQs, and supplier contracts.',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _showCreatePoDialog(context, suppliers),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create PO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradeColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            TradeFilterRow(
              filters: _statusFilters,
              selected: _filter,
              onSelect: (f) => setState(() {
                _filter = f;
                _selectedPoId = null;
              }),
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              children: [
                _PoStatChip(
                  label: 'Total',
                  value: '${allOrders.length}',
                  color: TradeColors.muted,
                ),
                const SizedBox(width: 8),
                _PoStatChip(
                  label: 'Pending',
                  value: '${allOrders.where((p) => p.status == 'Sent' || p.status == 'Draft').length}',
                  color: TradeColors.amber,
                ),
                const SizedBox(width: 8),
                _PoStatChip(
                  label: 'Received',
                  value: '${allOrders.where((p) => p.status == 'Received').length}',
                  color: TradeColors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No purchase orders for this filter.', style: TextStyle(color: TradeColors.muted)),
                ),
              )
            else
              for (final po in filtered) ...[
                _PoCard(
                  po: po,
                  supplier: supplierMap[po.supplierId],
                  isSelected: po.id == _selectedPoId && isWide,
                  onTap: () => setState(() => _selectedPoId = po.id),
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 48),
          ],
        ),
      );

      if (isWide && selected != null) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: listPanel),
            const VerticalDivider(width: 1, color: TradeColors.border),
            Expanded(
              flex: 3,
              child: _PoDetailPanel(
                po: selected,
                supplier: supplierMap[selected.supplierId],
                onUpdateStatus: (status) =>
                    ref.read(purchaseOrderProvider.notifier).updateStatus(selected.id, status),
              ),
            ),
          ],
        );
      }
      return listPanel;
    });
  }

  void _showCreatePoDialog(BuildContext context, List<TradeSupplier> suppliers) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Purchase Order'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const SizedBox(
          width: 400,
          child: Text('PO creation form — field UI would go here (supplier selector, product, quantity, price, delivery date).'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white),
            child: const Text('Save Draft'),
          ),
        ],
      ),
    );
  }
}

class _PoStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PoStatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PoCard extends StatelessWidget {
  final PurchaseOrder po;
  final TradeSupplier? supplier;
  final bool isSelected;
  final VoidCallback onTap;

  const _PoCard({
    required this.po,
    required this.supplier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TradeColors.green.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? TradeColors.green : TradeColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${po.id} — ${po.productName}',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: TradeColors.dark),
                  ),
                ),
                TradeBadge(label: po.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.business_outlined, size: 13, color: TradeColors.muted),
                const SizedBox(width: 4),
                Text(supplier?.name ?? po.supplierId, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
                const Spacer(),
                Text('US\$ ${po.totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TradeColors.dark)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.scale_outlined, size: 13, color: TradeColors.muted),
                const SizedBox(width: 4),
                Text('${po.quantityKg.round()}kg', style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today_outlined, size: 13, color: TradeColors.muted),
                const SizedBox(width: 4),
                Text('Due ${po.deliveryDate}', style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PoDetailPanel extends StatelessWidget {
  final PurchaseOrder po;
  final TradeSupplier? supplier;
  final ValueChanged<String> onUpdateStatus;

  const _PoDetailPanel({
    required this.po,
    required this.supplier,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(po.id, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: TradeColors.dark)),
          const SizedBox(height: 4),
          TradeBadge(label: po.status),
          const SizedBox(height: 16),
          TradeSectionCard(
            title: 'Order Details',
            child: Column(
              children: [
                MetricRow(label: 'Product', value: po.productName),
                MetricRow(label: 'Quantity', value: '${po.quantityKg.round()} kg'),
                MetricRow(label: 'Unit Price', value: 'US\$ ${po.unitPricePer100kg}/100kg'),
                MetricRow(label: 'Total Value', value: 'US\$ ${po.totalValue.toStringAsFixed(2)}'),
                MetricRow(label: 'Order Date', value: po.date),
                MetricRow(label: 'Delivery Date', value: po.deliveryDate),
                if (po.notes.isNotEmpty) MetricRow(label: 'Notes', value: po.notes),
              ],
            ),
          ),
          if (supplier != null) ...[
            const SizedBox(height: 12),
            TradeSectionCard(
              title: 'Supplier',
              child: Column(
                children: [
                  MetricRow(label: 'Name', value: supplier!.name),
                  MetricRow(label: 'Region', value: supplier!.region),
                  MetricRow(label: 'Contact', value: supplier!.contactName),
                  MetricRow(label: 'Trust Score', value: '${supplier!.reliabilityPct.round()}%'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Action buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (po.status == 'Draft')
                ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('Sent'),
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Send to Supplier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradeColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (po.status == 'Sent')
                ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('Confirmed'),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradeColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (po.status == 'Confirmed')
                ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('Received'),
                  icon: const Icon(Icons.move_to_inbox_outlined, size: 18),
                  label: const Text('Mark Received'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradeColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (po.status != 'Cancelled' && po.status != 'Received')
                OutlinedButton.icon(
                  onPressed: () => onUpdateStatus('Cancelled'),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel PO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TradeColors.red,
                    side: const BorderSide(color: TradeColors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
