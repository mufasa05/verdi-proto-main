import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeQualityPage extends ConsumerStatefulWidget {
  const TradeQualityPage({super.key});

  @override
  ConsumerState<TradeQualityPage> createState() => _TradeQualityPageState();
}

class _TradeQualityPageState extends ConsumerState<TradeQualityPage> {
  String _filter = 'All';

  final _filters = ['All', 'Pass', 'Fail', 'Grade A', 'Grade B', 'Grade C'];

  List<QualityCheck> _filtered(List<QualityCheck> all) {
    switch (_filter) {
      case 'Pass':
        return all.where((qc) => qc.passed).toList();
      case 'Fail':
        return all.where((qc) => !qc.passed).toList();
      case 'Grade A':
        return all.where((qc) => qc.assignedGrade == GradeClass.a).toList();
      case 'Grade B':
        return all.where((qc) => qc.assignedGrade == GradeClass.b).toList();
      case 'Grade C':
        return all.where((qc) => qc.assignedGrade == GradeClass.c).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allChecks = ref.watch(qualityCheckProvider);
    final filtered = _filtered(allChecks);

    final passCount = allChecks.where((qc) => qc.passed).length;
    final failCount = allChecks.where((qc) => !qc.passed).length;
    final gradeACount = allChecks.where((qc) => qc.assignedGrade == GradeClass.a).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Quality Control',
            subtitle: 'Inspections, grading, and batch compliance records.',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showQcDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Log QC'),
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
                TradeStatTile(label: 'Total Checks', value: '${allChecks.length}', icon: Icons.fact_check_outlined),
                TradeStatTile(
                  label: 'Passed',
                  value: '$passCount',
                  icon: Icons.check_circle_outline,
                  iconColor: TradeColors.green,
                  valueColor: TradeColors.green,
                ),
                TradeStatTile(
                  label: 'Failed',
                  value: '$failCount',
                  icon: Icons.cancel_outlined,
                  iconColor: failCount > 0 ? TradeColors.red : TradeColors.green,
                  valueColor: failCount > 0 ? TradeColors.red : null,
                ),
                TradeStatTile(
                  label: 'Grade A',
                  value: '$gradeACount',
                  icon: Icons.star_outlined,
                  iconColor: TradeColors.green,
                ),
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
                child: Text('No quality check records.', style: TextStyle(color: TradeColors.muted)),
              ),
            )
          else
            for (final qc in filtered) ...[
              _QcCard(qc: qc),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showQcDialog(BuildContext context) {
    final batches = ref.read(stockBatchProvider);
    String? selectedBatchId;
    GradeClass selectedGrade = GradeClass.a;
    bool passed = true;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Record Quality Check'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Batch',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: batches.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.productName} • ${b.lotNumber}'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedBatchId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GradeClass>(
                  value: selectedGrade,
                  decoration: InputDecoration(
                    labelText: 'Assign Grade',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: GradeClass.values.map((g) => DropdownMenuItem(value: g, child: Text(g.label))).toList(),
                  onChanged: (v) => setDialogState(() => selectedGrade = v ?? GradeClass.a),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Pass'),
                  value: passed,
                  activeColor: TradeColors.green,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setDialogState(() => passed = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Inspector Notes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selectedBatchId != null) {
                  ref.read(qualityCheckProvider.notifier).addCheck(
                        QualityCheck(
                          id: 'QC-${DateTime.now().millisecondsSinceEpoch}',
                          batchId: selectedBatchId!,
                          productName: batches.firstWhere((b) => b.id == selectedBatchId).productName,
                          inspector: 'Current User',
                          assignedGrade: selectedGrade,
                          passed: passed,
                          moisturePercent: 0,
                          weightCheckedKg: 0,
                          notes: notesController.text,
                          date: 'Today',
                        ),
                      );
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TradeColors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QcCard extends StatelessWidget {
  final QualityCheck qc;

  const _QcCard({required this.qc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TradeColors.border),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${qc.id} — ${qc.productName}',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: TradeColors.dark),
                ),
              ),
              TradeBadge(
                label: qc.passed ? 'Pass' : 'Fail',
                color: qc.passed ? TradeColors.green : TradeColors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GradeBadge(grade: qc.assignedGrade),
              const SizedBox(width: 10),
              const Icon(Icons.person_outline, size: 14, color: TradeColors.muted),
              const SizedBox(width: 4),
              Text(qc.inspector, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
              const Spacer(),
              Text(qc.date, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QcMini(label: 'Batch', value: qc.batchId),
              const SizedBox(width: 16),
              _QcMini(label: 'Moisture', value: '${qc.moisturePercent}%'),
              const SizedBox(width: 16),
              _QcMini(label: 'Weight Checked', value: '${qc.weightCheckedKg}kg'),
            ],
          ),
          if (qc.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TradeColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(qc.notes, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
            ),
          ],
        ],
      ),
    );
  }
}

class _QcMini extends StatelessWidget {
  final String label;
  final String value;

  const _QcMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: TradeColors.muted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TradeColors.dark)),
      ],
    );
  }
}
