import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../state/app_state.dart';
import '../../../features/auth/state/auth_state.dart';

/// Universal Agro-Processing & Value-Addition Hub
/// Designed for ALL types of value-adders (Millers, Packers, Oil Processors, Bottlers, Cold-Storage, Canners).
class ValueAdderProcessingPage extends ConsumerStatefulWidget {
  const ValueAdderProcessingPage({super.key});

  @override
  ConsumerState<ValueAdderProcessingPage> createState() => _ValueAdderProcessingPageState();
}

class _ValueAdderProcessingPageState extends ConsumerState<ValueAdderProcessingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Local state for dynamically added processing runs (works in both Live and Demo mode)
  final List<_ProcessingBatchRun> _userBatchRuns = [];
  final List<_RawIntakeRecord> _userIntakeRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openStartBatchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StartBatchModalSheet(
        onSave: (run) {
          setState(() => _userBatchRuns.insert(0, run));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Batch #${run.batchCode} (${run.productName}) started successfully!'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        },
      ),
    );
  }

  void _openRawIntakeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RawIntakeModalSheet(
        onSave: (record) {
          setState(() => _userIntakeRecords.insert(0, record));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Intake recorded: ${record.weightTonnes}T of ${record.cropName} (${record.supplier})'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(isDemoModeProvider);
    final user = ref.watch(authStateProvider).user;
    final enterpriseName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Value-Addition Facility';

    // Demo Data
    final demoBatchRuns = _getDemoBatchRuns();
    final demoIntakeRecords = _getDemoIntakeRecords();

    // Active List (User added items + demo items if in demo mode)
    final activeBatchRuns = isDemo ? [..._userBatchRuns, ...demoBatchRuns] : _userBatchRuns;
    final activeIntakeRecords = isDemo ? [..._userIntakeRecords, ...demoIntakeRecords] : _userIntakeRecords;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.factory, color: Color(0xFF16A34A), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value Addition Hub',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  enterpriseName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _openStartBatchModal,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Start New Batch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF16A34A),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF16A34A),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(text: 'Batch Runs'),
            Tab(text: 'Crop Intake'),
            Tab(text: 'Yield Matrix'),
            Tab(text: 'Line Telemetry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBatchRunsTab(activeBatchRuns, isDemo),
          _buildCropIntakeTab(activeIntakeRecords, isDemo),
          _buildYieldMatrixTab(activeBatchRuns, isDemo),
          _buildLineTelemetryTab(isDemo),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: BATCH RUNS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBatchRunsTab(List<_ProcessingBatchRun> runs, bool isDemo) {
    if (runs.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.factory,
        title: 'No Processing Runs Logged',
        subtitle: isDemo
            ? 'No demo runs available.'
            : 'Your live value-addition hub is empty and ready. Start a new processing batch to track transformation, stages, and finished yield.',
        buttonText: 'Start Processing Batch',
        onTap: _openStartBatchModal,
      );
    }

    final activeCount = runs.where((r) => r.status == 'Processing').length;
    final totalFinished = runs.fold<double>(0, (sum, r) => sum + r.finishedOutputTonnes);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Cards Header
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Active Runs',
                  value: '$activeCount Batch${activeCount == 1 ? '' : 'es'}',
                  subtitle: 'In production lines',
                  icon: LucideIcons.playCircle,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Finished Output',
                  value: '${totalFinished.toStringAsFixed(1)} Tonnes',
                  subtitle: 'Value-added produce',
                  icon: LucideIcons.packageCheck,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROCESSING BATCH QUEUE',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: 0.8),
              ),
              Text(
                '${runs.length} Records',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: runs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _BatchRunCard(run: runs[index]),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: RAW CROP INTAKE
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCropIntakeTab(List<_RawIntakeRecord> records, bool isDemo) {
    if (records.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.clipboardList,
        title: 'No Crop Intake Records',
        subtitle: isDemo
            ? 'No intake data in demo mode.'
            : 'No raw produce delivery records registered yet. Record farm/co-op deliveries to log moisture, quality grade, and Brix scores.',
        buttonText: 'Register Raw Intake',
        onTap: _openRawIntakeModal,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RAW PRODUCE INTAKE LOG',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: 0.8),
              ),
              ElevatedButton.icon(
                onPressed: _openRawIntakeModal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log Intake', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _IntakeRecordTile(record: records[i]),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: YIELD MATRIX
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildYieldMatrixTab(List<_ProcessingBatchRun> runs, bool isDemo) {
    if (runs.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.trendingUp,
        title: 'Yield Telemetry Baseline Empty',
        subtitle: 'Transformation yield ratios will automatically calculate once processing runs commence.',
        buttonText: 'Start Processing Batch',
        onTap: _openStartBatchModal,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RAW-TO-FINISHED VALUE TRANSFORMATION MATRIX',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: 0.8),
          ),
          const SizedBox(height: 14),

          ...runs.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r.productName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Yield: ${((r.finishedOutputTonnes / (r.rawInputTonnes > 0 ? r.rawInputTonnes : 1)) * 100).toStringAsFixed(1)}%',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Raw Crop Input', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
                              Text('${r.rawInputTonnes} Tonnes (${r.rawCropName})', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF16A34A), size: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Finished Produce', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
                              Text('${r.finishedOutputTonnes} Tonnes', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: LINE TELEMETRY
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildLineTelemetryTab(bool isDemo) {
    if (!isDemo) {
      return _buildEmptyState(
        icon: LucideIcons.activity,
        title: 'Machinery Telemetry Baseline Normal',
        subtitle: 'No IoT sensor telemetry modules configured for live line monitoring yet. Connect sensors to view live boiler, motor, and line temperature data.',
        buttonText: 'Add Machinery Sensor',
        onTap: () {},
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROCESSING MACHINERY & LINE STATUS',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: 0.8),
          ),
          const SizedBox(height: 14),

          _buildTelemetryCard('Main Milling & Crusher Line #1', 'Operational', '420 RPM • 84% Load', const Color(0xFF16A34A)),
          _buildTelemetryCard('Vacuum Evaporator & Concentrator #2', 'Optimal', '88°C • 0.82 Bar Vacuum', const Color(0xFF16A34A)),
          _buildTelemetryCard('Aseptic Bottling & Canning Unit #3', 'Standby', 'Cleaned • Ready for next run', const Color(0xFF2563EB)),
          _buildTelemetryCard('Cold Storage & Blast Freezer Module', 'Operational', '-18.5°C Target Met', const Color(0xFF16A34A)),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(String line, String status, String telemetry, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(LucideIcons.activity, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(telemetry, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.10), shape: BoxShape.circle),
              child: Icon(icon, size: 42, color: const Color(0xFF16A34A)),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B), height: 1.4)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add, size: 18),
              label: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Representative Demo Data
  List<_ProcessingBatchRun> _getDemoBatchRuns() => [
        _ProcessingBatchRun(
          batchCode: 'RUN-104',
          productName: 'White Maize Fortified Meal',
          rawCropName: 'White Maize',
          rawInputTonnes: 15.0,
          finishedOutputTonnes: 12.8,
          status: 'Processing',
          stage: 'Milling & Fortification',
        ),
        _ProcessingBatchRun(
          batchCode: 'RUN-208',
          productName: 'Concentrated Tomato Paste (28° Brix)',
          rawCropName: 'Fresh Tomatoes',
          rawInputTonnes: 22.0,
          finishedOutputTonnes: 3.8,
          status: 'Completed',
          stage: 'Packaging',
        ),
      ];

  List<_RawIntakeRecord> _getDemoIntakeRecords() => [
        _RawIntakeRecord(
          supplier: 'Chiredzi Smallholder Co-op',
          cropName: 'Fresh Tomatoes',
          weightTonnes: 12.5,
          qualityGrade: 'Grade A (Brix 6.2°)',
          date: 'Today, 09:30',
        ),
        _RawIntakeRecord(
          supplier: 'Mvurwi Farmers Union',
          cropName: 'White Maize (Grain)',
          weightTonnes: 28.0,
          qualityGrade: 'Grade A (Moisture 12.5%)',
          date: 'Yesterday, 14:15',
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class _ProcessingBatchRun {
  final String batchCode;
  final String productName;
  final String rawCropName;
  final double rawInputTonnes;
  final double finishedOutputTonnes;
  final String status;
  final String stage;

  _ProcessingBatchRun({
    required this.batchCode,
    required this.productName,
    required this.rawCropName,
    required this.rawInputTonnes,
    required this.finishedOutputTonnes,
    required this.status,
    required this.stage,
  });
}

class _RawIntakeRecord {
  final String supplier;
  final String cropName;
  final double weightTonnes;
  final String qualityGrade;
  final String date;

  _RawIntakeRecord({
    required this.supplier,
    required this.cropName,
    required this.weightTonnes,
    required this.qualityGrade,
    required this.date,
  });
}

class _BatchRunCard extends StatelessWidget {
  final _ProcessingBatchRun run;
  const _BatchRunCard({required this.run});

  @override
  Widget build(BuildContext context) {
    final isDone = run.status == 'Completed';
    final statusColor = isDone ? const Color(0xFF16A34A) : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(run.batchCode, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
              ),
              const SizedBox(width: 8),
              Text(run.productName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.10), borderRadius: BorderRadius.circular(6)),
                child: Text(run.status, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.arrowRightLeft, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                '${run.rawInputTonnes}T ${run.rawCropName} ➔ ${run.finishedOutputTonnes}T Finished Product',
                style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.stepForward, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text('Current Stage: ', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              Text(run.stage, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntakeRecordTile extends StatelessWidget {
  final _RawIntakeRecord record;
  const _IntakeRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.packageCheck, color: Color(0xFF16A34A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${record.weightTonnes} Tonnes • ${record.cropName}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Supplier: ${record.supplier} • ${record.qualityGrade}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Text(record.date, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODAL SHEETS FOR STARTING BATCH AND LOGGING INTAKE
// ─────────────────────────────────────────────────────────────────────────────

class _StartBatchModalSheet extends StatefulWidget {
  final void Function(_ProcessingBatchRun run) onSave;
  const _StartBatchModalSheet({required this.onSave});

  @override
  State<_StartBatchModalSheet> createState() => _StartBatchModalSheetState();
}

class _StartBatchModalSheetState extends State<_StartBatchModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _productCtrl = TextEditingController();
  final _rawCropCtrl = TextEditingController();
  final _inputTonnesCtrl = TextEditingController();
  final _outputTonnesCtrl = TextEditingController();

  @override
  void dispose() {
    _productCtrl.dispose();
    _rawCropCtrl.dispose();
    _inputTonnesCtrl.dispose();
    _outputTonnesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_ProcessingBatchRun(
      batchCode: 'RUN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      productName: _productCtrl.text.trim(),
      rawCropName: _rawCropCtrl.text.trim(),
      rawInputTonnes: double.parse(_inputTonnesCtrl.text.trim()),
      finishedOutputTonnes: double.parse(_outputTonnesCtrl.text.trim()),
      status: 'Processing',
      stage: 'Initial Preparation & Milling',
    ));
    Navigator.pop(context);
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 14),
              Text('Start New Processing Batch', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productCtrl,
                decoration: _dec('Finished Product Name (e.g. Fortified Flour)', LucideIcons.package),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter product name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rawCropCtrl,
                decoration: _dec('Raw Crop Input (e.g. White Maize)', LucideIcons.leaf),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter raw crop' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _inputTonnesCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec('Raw Input (T)', LucideIcons.arrowDown),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter weight' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _outputTonnesCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec('Est. Finished Output (T)', LucideIcons.arrowUp),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter weight' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Batch Production', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RawIntakeModalSheet extends StatefulWidget {
  final void Function(_RawIntakeRecord record) onSave;
  const _RawIntakeModalSheet({required this.onSave});

  @override
  State<_RawIntakeModalSheet> createState() => _RawIntakeModalSheetState();
}

class _RawIntakeModalSheetState extends State<_RawIntakeModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _supplierCtrl = TextEditingController();
  final _cropCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();

  @override
  void dispose() {
    _supplierCtrl.dispose();
    _cropCtrl.dispose();
    _weightCtrl.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_RawIntakeRecord(
      supplier: _supplierCtrl.text.trim(),
      cropName: _cropCtrl.text.trim(),
      weightTonnes: double.parse(_weightCtrl.text.trim()),
      qualityGrade: _gradeCtrl.text.trim(),
      date: 'Just now',
    ));
    Navigator.pop(context);
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 14),
              Text('Register Raw Crop Delivery Intake', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supplierCtrl,
                decoration: _dec('Supplier / Farmer Co-op Name', LucideIcons.users),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter supplier name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cropCtrl,
                decoration: _dec('Raw Crop Type (e.g. Tomatoes / Maize)', LucideIcons.leaf),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter crop' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec('Net Weight (T)', LucideIcons.scale),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter weight' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gradeCtrl,
                      decoration: _dec('Quality Grade / Brix', LucideIcons.award),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter grade' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Record Delivery Intake', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
