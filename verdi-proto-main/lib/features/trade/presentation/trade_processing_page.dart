import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeProcessingPage extends ConsumerStatefulWidget {
  const TradeProcessingPage({super.key});

  @override
  ConsumerState<TradeProcessingPage> createState() => _TradeProcessingPageState();
}

class _TradeProcessingPageState extends ConsumerState<TradeProcessingPage> {
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Completed', 'Paused'];

  List<ProcessingRun> _filtered(List<ProcessingRun> all) {
    if (_filter == 'All') return all;
    return all.where((r) => r.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allRuns = ref.watch(processingRunProvider);
    final filtered = _filtered(allRuns);
    final batches = ref.watch(stockBatchProvider);

    final activeCount = allRuns.where((r) => r.status == 'Active').length;
    final completedCount = allRuns.where((r) => r.status == 'Completed').length;
    final totalYieldKg = allRuns.fold<double>(0, (s, r) => s + r.outputKg);
    final totalWasteKg = allRuns.fold<double>(0, (s, r) => s + r.wasteKg);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Processing Flow',
            subtitle: 'Batch transformation, yield tracking, and waste management.',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showStartRunDialog(context, batches),
                icon: const Icon(Icons.play_arrow_outlined, size: 18),
                label: const Text('Start Run'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradeColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          // KPI grid
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
                TradeStatTile(label: 'Active Runs', value: '$activeCount', icon: Icons.precision_manufacturing_outlined, iconColor: TradeColors.blue),
                TradeStatTile(label: 'Completed', value: '$completedCount', icon: Icons.check_circle_outlined, iconColor: TradeColors.green),
                TradeStatTile(label: 'Total Yield', value: '${(totalYieldKg / 1000).toStringAsFixed(1)}t', icon: Icons.output_outlined),
                TradeStatTile(label: 'Total Waste', value: '${(totalWasteKg / 1000).toStringAsFixed(1)}t', icon: Icons.delete_outline, iconColor: TradeColors.orange, valueColor: TradeColors.orange),
              ],
            );
          }),
          const SizedBox(height: 16),
          TradeFilterRow(filters: _filters, selected: _filter, onSelect: (f) => setState(() => _filter = f)),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No processing runs.', style: TextStyle(color: TradeColors.muted)),
              ),
            )
          else
            for (final run in filtered) ...[
              _ProcessingRunCard(
                run: run,
                onComplete: () => ref.read(processingRunProvider.notifier).completeRun(run.id),
              ),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showStartRunDialog(BuildContext context, List<StockBatch> batches) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Processing Run'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Input Batch',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: batches
                    .where((b) => b.status == 'In Stock')
                    .map((b) => DropdownMenuItem(value: b.id, child: Text('${b.productName} • ${b.lotNumber}')))
                    .toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Recipe / Process Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimated Output (kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _ProcessingRunCard extends StatelessWidget {
  final ProcessingRun run;
  final VoidCallback onComplete;

  const _ProcessingRunCard({required this.run, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final yieldPct = run.yieldPercent;
    final wastePct = run.wastePercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TradeColors.border),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: run.status == 'Active'
                      ? TradeColors.blue.withOpacity(0.1)
                      : TradeColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  run.status == 'Active' ? Icons.precision_manufacturing_outlined : Icons.check_circle_outlined,
                  color: run.status == 'Active' ? TradeColors.blue : TradeColors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${run.id} — ${run.productName}',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: TradeColors.dark),
                    ),
                    Text(run.recipeName, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
                  ],
                ),
              ),
              TradeBadge(label: run.status),
            ],
          ),
          const SizedBox(height: 14),
          // Yield / waste bars
          TradeProgressBar(
            value: yieldPct / 100,
            color: TradeColors.green,
            label: 'Yield',
            trailingLabel: '${yieldPct.toStringAsFixed(1)}% (${run.outputKg.round()}kg)',
          ),
          const SizedBox(height: 8),
          TradeProgressBar(
            value: wastePct / 100,
            color: TradeColors.orange,
            label: 'Waste',
            trailingLabel: '${wastePct.toStringAsFixed(1)}% (${run.wasteKg.round()}kg)',
          ),
          const SizedBox(height: 12),
          // Metadata row
          Row(
            children: [
              _RunMeta(icon: Icons.move_to_inbox_outlined, label: 'Input: ${run.inputBatchId}'),
              const SizedBox(width: 16),
              _RunMeta(icon: Icons.person_outline, label: run.operatorName),
              const SizedBox(width: 16),
              _RunMeta(icon: Icons.calendar_today_outlined, label: run.startDate),
            ],
          ),
          if (run.status == 'Active') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Complete Run'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TradeColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.pause_outlined, size: 18),
                    label: const Text('Pause'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TradeColors.orange,
                      side: const BorderSide(color: TradeColors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RunMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RunMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: TradeColors.muted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: TradeColors.muted)),
      ],
    );
  }
}
