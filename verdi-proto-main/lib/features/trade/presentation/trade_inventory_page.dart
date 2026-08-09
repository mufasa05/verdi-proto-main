import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeInventoryPage extends ConsumerStatefulWidget {
  const TradeInventoryPage({super.key});

  @override
  ConsumerState<TradeInventoryPage> createState() => _TradeInventoryPageState();
}

class _TradeInventoryPageState extends ConsumerState<TradeInventoryPage> {
  String _selectedWarehouseId = 'All';
  String _gradeFilter = 'All';
  String? _selectedBatchId;

  final _gradeFilters = ['All', 'Grade A', 'Grade B', 'Grade C', 'Reserved'];

  List<StockBatch> _filtered(List<StockBatch> all) {
    return all.where((b) {
      final matchWh = _selectedWarehouseId == 'All' || b.warehouseId == _selectedWarehouseId;
      final matchGrade = switch (_gradeFilter) {
        'Grade A' => b.gradeClass == GradeClass.a,
        'Grade B' => b.gradeClass == GradeClass.b,
        'Grade C' => b.gradeClass == GradeClass.c,
        'Reserved' => b.status == 'Reserved',
        _ => true,
      };
      return matchWh && matchGrade;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allBatches = ref.watch(stockBatchProvider);
    final warehouses = ref.watch(warehouseProvider);
    final suppliers = ref.watch(tradeSupplierProvider);
    final filtered = _filtered(allBatches);

    final supplierMap = {for (final s in suppliers) s.id: s};

    final totalKg = filtered.fold<double>(0, (s, b) => s + b.quantityKg);
    final lowCount = filtered.where((b) => b.quantityKg < 2000).length;
    final nearExpiry = filtered
        .where((b) => b.expiryDate != null && b.status == 'In Stock')
        .length;

    final selectedBatch = _selectedBatchId == null
        ? null
        : filtered.where((b) => b.id == _selectedBatchId).firstOrNull;

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;

      final mainPanel = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TradePageHeader(
              title: 'Inventory & Warehouse',
              subtitle: 'Track batches by location, grade, and expiry.',
            ),
            // Warehouse chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _WarehouseChip(
                    label: 'All Warehouses',
                    isSelected: _selectedWarehouseId == 'All',
                    onTap: () => setState(() => _selectedWarehouseId = 'All'),
                  ),
                  ...warehouses.map((wh) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _WarehouseChip(
                          label: wh.name,
                          sublabel: '${(wh.utilisation * 100).round()}% full',
                          isSelected: _selectedWarehouseId == wh.id,
                          onTap: () => setState(() => _selectedWarehouseId = wh.id),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Summary stats
            LayoutBuilder(builder: (ctx, c) {
              final invTiles = [
                TradeStatTile(label: 'Total Batches', value: '${filtered.length}', icon: Icons.inventory_2_outlined),
                TradeStatTile(
                  label: 'Total Stock',
                  value: '${(totalKg / 1000).toStringAsFixed(1)}t',
                  icon: Icons.scale_outlined,
                  iconColor: TradeColors.blue,
                ),
                TradeStatTile(
                  label: 'Low Stock',
                  value: '$lowCount',
                  icon: Icons.warning_amber_outlined,
                  iconColor: lowCount > 0 ? TradeColors.orange : TradeColors.green,
                  valueColor: lowCount > 0 ? TradeColors.orange : null,
                ),
                TradeStatTile(
                  label: 'Near Expiry',
                  value: '$nearExpiry',
                  icon: Icons.access_time_outlined,
                  iconColor: nearExpiry > 0 ? TradeColors.red : TradeColors.green,
                  valueColor: nearExpiry > 0 ? TradeColors.red : null,
                ),
              ];
              if (c.maxWidth >= 900) {
                return Row(
                  children: invTiles.map((t) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: t))).toList(),
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: invTiles[0]),
                      const SizedBox(width: 12),
                      Expanded(child: invTiles[1]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: invTiles[2]),
                      const SizedBox(width: 12),
                      Expanded(child: invTiles[3]),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // Grade filter
            TradeFilterRow(
              filters: _gradeFilters,
              selected: _gradeFilter,
              onSelect: (g) => setState(() => _gradeFilter = g),
            ),
            const SizedBox(height: 16),
            // Batch list
            if (filtered.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No stock batches match these filters.', style: TextStyle(color: TradeColors.muted)),
                ),
              )
            else
              for (final batch in filtered) ...[
                _BatchCard(
                  batch: batch,
                  supplierName: supplierMap[batch.supplierId]?.name ?? batch.supplierId,
                  isSelected: batch.id == _selectedBatchId && isWide,
                  onTap: () => setState(() => _selectedBatchId = batch.id),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 48),
          ],
        ),
      );

      if (isWide && selectedBatch != null) {
        return Row(
          children: [
            Expanded(flex: 5, child: mainPanel),
            const VerticalDivider(width: 1, color: TradeColors.border),
            Expanded(
              flex: 3,
              child: _BatchDetailPanel(
                batch: selectedBatch,
                supplierName: supplierMap[selectedBatch.supplierId]?.name ?? selectedBatch.supplierId,
                qualityChecks: ref.watch(qualityCheckProvider).where((qc) => qc.batchId == selectedBatch.id).toList(),
                onUpdateStatus: (s) => ref.read(stockBatchProvider.notifier).updateStatus(selectedBatch.id, s),
                onClose: () => setState(() => _selectedBatchId = null),
              ),
            ),
          ],
        );
      }
      return mainPanel;
    });
  }
}

class _WarehouseChip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _WarehouseChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TradeColors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? TradeColors.green : TradeColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : TradeColors.dark,
              ),
            ),
            if (sublabel != null)
              Text(
                sublabel!,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : TradeColors.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final StockBatch batch;
  final String supplierName;
  final bool isSelected;
  final VoidCallback onTap;

  const _BatchCard({
    required this.batch,
    required this.supplierName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = batch.quantityKg < 2000;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? TradeColors.green.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TradeColors.green : (isLow ? TradeColors.orange.withOpacity(0.4) : TradeColors.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Grade indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: switch (batch.gradeClass) {
                  GradeClass.a => TradeColors.green.withOpacity(0.1),
                  GradeClass.b => TradeColors.blue.withOpacity(0.1),
                  GradeClass.c => TradeColors.orange.withOpacity(0.1),
                  GradeClass.rejected => TradeColors.red.withOpacity(0.1),
                },
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  batch.gradeClass == GradeClass.rejected ? 'R' : batch.gradeClass.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: switch (batch.gradeClass) {
                      GradeClass.a => TradeColors.green,
                      GradeClass.b => TradeColors.blue,
                      GradeClass.c => TradeColors.orange,
                      GradeClass.rejected => TradeColors.red,
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${batch.productName} • ${batch.lotNumber}',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: TradeColors.dark),
                        ),
                      ),
                      TradeBadge(label: batch.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${batch.quantityKg.round()}kg • Bin ${batch.binLabel} • $supplierName',
                    style: const TextStyle(fontSize: 12, color: TradeColors.muted),
                  ),
                  if (batch.expiryDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 12,
                          color: isLow ? TradeColors.orange : TradeColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expires ${batch.expiryDate}',
                          style: TextStyle(fontSize: 11, color: isLow ? TradeColors.orange : TradeColors.muted),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchDetailPanel extends StatelessWidget {
  final StockBatch batch;
  final String supplierName;
  final List<QualityCheck> qualityChecks;
  final ValueChanged<String> onUpdateStatus;
  final VoidCallback onClose;

  const _BatchDetailPanel({
    required this.batch,
    required this.supplierName,
    required this.qualityChecks,
    required this.onUpdateStatus,
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
              Expanded(
                child: Text(
                  batch.lotNumber,
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: TradeColors.dark),
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [GradeBadge(grade: batch.gradeClass), const SizedBox(width: 8), TradeBadge(label: batch.status)]),
          const SizedBox(height: 16),
          TradeSectionCard(
            title: 'Batch Details',
            child: Column(
              children: [
                MetricRow(label: 'Product', value: batch.productName),
                MetricRow(label: 'Quantity', value: '${batch.quantityKg.round()} kg'),
                MetricRow(label: 'Warehouse', value: batch.warehouseId),
                MetricRow(label: 'Bin', value: batch.binLabel),
                MetricRow(label: 'Supplier', value: supplierName),
                MetricRow(label: 'Arrived', value: batch.arrivalDate),
                if (batch.expiryDate != null)
                  MetricRow(label: 'Expires', value: batch.expiryDate!, valueColor: TradeColors.orange),
              ],
            ),
          ),
          if (qualityChecks.isNotEmpty) ...[
            const SizedBox(height: 12),
            TradeSectionCard(
              title: 'Quality Checks',
              child: Column(
                children: qualityChecks.map((qc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          qc.passed ? Icons.check_circle : Icons.cancel,
                          color: qc.passed ? TradeColors.green : TradeColors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(qc.inspector, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              Text('${qc.assignedGrade.label} • ${qc.date}', style: const TextStyle(fontSize: 11, color: TradeColors.muted)),
                            ],
                          ),
                        ),
                        TradeBadge(label: qc.passed ? 'Pass' : 'Fail'),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (batch.status == 'In Stock')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onUpdateStatus('Reserved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TradeColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reserve'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onUpdateStatus('Dispatched'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TradeColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Dispatch'),
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
