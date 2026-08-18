import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../state/platform_data_state.dart';
import '../../../state/app_state.dart';

class TraceabilityPage extends ConsumerStatefulWidget {
  const TraceabilityPage({super.key});

  @override
  ConsumerState<TraceabilityPage> createState() => _TraceabilityPageState();
}

class _TraceabilityPageState extends ConsumerState<TraceabilityPage> {
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  String? _selectedBatchId;
  bool _isScanning = false;
  final Map<String, List<_ScanLog>> _localScans = {}; // batchId -> scans

  List<_TraceEvent> _eventsFor(String batchId, bool isTransporter) {
    if (isTransporter) {
      return [
        _TraceEvent(eventType: 'Freight Loading', eventTime: '2026-08-14 08:30', actorName: 'Harare Packhouse', location: 'Bay 4', notes: 'Consignment palletized, weighed, and loaded onto Truck TRK-9442.'),
        _TraceEvent(eventType: 'Seal Affixed', eventTime: '2026-08-14 09:10', actorName: 'Quality Inspector', location: 'Gate Out', notes: 'Phyto-security tamper seal #ZIM-9921 applied.'),
        _TraceEvent(eventType: 'Corridor Dispatch', eventTime: '2026-08-14 09:30', actorName: 'Lead Driver T. Moyo', location: 'Harare A5 Toll', notes: 'Transit initiated on Harare-Bulawayo corridor.'),
        _TraceEvent(eventType: 'Cold-Chain Check', eventTime: '2026-08-14 11:45', actorName: 'Automated Telemetry', location: 'Chivhu Waypoint', notes: 'Reefer temp maintained at 4.2°C (Optimal).'),
        _TraceEvent(eventType: 'Weighbridge Pass', eventTime: '2026-08-14 13:20', actorName: 'Gweru Scale Station', location: 'Scale #2', notes: 'Gross axle weight compliant (11.8 Tonnes).'),
        _TraceEvent(eventType: 'Depot Handover', eventTime: '2026-08-14 15:00', actorName: 'Consignee Receiver', location: 'Bulawayo Depot', notes: 'Offload seal verified intact and received.'),
      ];
    }
    return [
      _TraceEvent(eventType: 'Planting', eventTime: '2026-03-01 07:00', actorName: 'Farm Manager', location: 'Block 4', notes: 'Seed lot recorded and field mapped.'),
      _TraceEvent(eventType: 'Input Applied', eventTime: '2026-04-11 09:30', actorName: 'Field Officer', location: 'Block 4', notes: 'Fertilizer applied at recommended rate.'),
      _TraceEvent(eventType: 'Harvest', eventTime: '2026-06-12 06:15', actorName: 'Harvest Team', location: 'Packhouse A', notes: 'Batch harvested and weighed.'),
      _TraceEvent(eventType: 'Inspection', eventTime: '2026-06-12 11:40', actorName: 'Inspector', location: 'Packhouse A', notes: 'Quality inspection completed.'),
      _TraceEvent(eventType: 'Dispatch', eventTime: '2026-06-13 15:20', actorName: 'Logistics', location: 'Depot', notes: 'Loaded for shipment.'),
    ];
  }

  List<_BatchDocument> _docsFor(String batchId, bool isTransporter) {
    if (isTransporter) {
      return [
        _BatchDocument(docType: 'Bill of Lading (BoL)', fileName: '$batchId-BoL-manifest.pdf'),
        _BatchDocument(docType: 'Phytosanitary Clearance', fileName: '$batchId-phyto-transit.pdf'),
        _BatchDocument(docType: 'Cold-Chain Reefer Log', fileName: '$batchId-reefer-telemetry.pdf'),
        _BatchDocument(docType: 'Weighbridge Scale Slip', fileName: '$batchId-weighbridge-pass.pdf'),
      ];
    }
    return [
      _BatchDocument(docType: 'Harvest Log', fileName: '$batchId-harvest.pdf'),
      _BatchDocument(docType: 'Inspection Certificate', fileName: '$batchId-inspection.pdf'),
      _BatchDocument(docType: 'Dispatch Note', fileName: '$batchId-dispatch.pdf'),
    ];
  }

  List<_ScanLog> _scansFor(String batchId, bool isTransporter) {
    final custom = _localScans[batchId] ?? [];
    if (isTransporter) {
      return [
        _ScanLog(scannedAt: '2026-08-14 08:45', scannerRole: 'Consignor Depot Gate', result: 'Seal Verified & Loaded'),
        _ScanLog(scannedAt: '2026-08-14 11:50', scannerRole: 'Corridor Checkpoint Officer', result: 'Highway Transit Passed'),
        _ScanLog(scannedAt: '2026-08-14 14:55', scannerRole: 'Bulawayo Receiver Agent', result: 'Offload Cleared'),
        ...custom,
      ];
    }
    return [
      _ScanLog(scannedAt: '2026-07-18 11:50', scannerRole: 'Inspector', result: 'Verified'),
      _ScanLog(scannedAt: '2026-07-19 15:30', scannerRole: 'Driver', result: 'Loaded'),
      ...custom,
    ];
  }

  void _startScan(String batchId) {
    setState(() {
      _isScanning = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        final list = _localScans[batchId] ?? [];
        list.add(_ScanLog(
          scannedAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          scannerRole: 'Operator (Simulated)',
          result: 'Pass',
        ));
        _localScans[batchId] = list;
      });
    });
  }

  double _overallReadiness(List<_TraceBatch> batches) {
    if (batches.isEmpty) return 0;
    return batches.fold<double>(0, (sum, b) => sum + b.readinessScore) / batches.length;
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(appStateProvider).role;
    final isTransporter = role == UserRole.transporter;
    final orders = ref.watch(ordersListProvider);
    final List<_TraceBatch> batches = orders.map((o) {
      final code = isTransporter ? o.id.replaceAll('#', 'CARGO-TR-') : o.id.replaceAll('#', 'VER-TR-');
      double score = 0.95;
      String status = 'Ready';
      if (o.status.toLowerCase().contains('pending') || o.status.toLowerCase().contains('confirm')) {
        score = 0.65;
        status = isTransporter ? 'Manifested' : 'Review';
      } else if (o.status.toLowerCase().contains('cancel')) {
        score = 0.30;
        status = 'Blocked';
      } else if (isTransporter && o.status.toLowerCase().contains('transit')) {
        score = 0.88;
        status = 'In-Transit';
      }
      return _TraceBatch(
        id: o.id,
        batchCode: code,
        cropName: o.product,
        farmName: o.supplier.isNotEmpty ? o.supplier : 'Mufasa Farm Depot',
        fieldName: isTransporter ? 'Harare-Bulawayo A5 Highway' : 'Harvest Field 1',
        harvestDate: '2026-08-14',
        quantity: int.tryParse(o.quantity.replaceAll(RegExp(r'[^0-9]'), '')) ?? 100,
        unit: o.quantity.toLowerCase().contains('unit') ? 'units' : 'kg',
        status: status,
        readinessScore: score,
        originVerified: true,
        inspectionPassed: !o.status.toLowerCase().contains('cancel'),
      );
    }).toList();

    if (batches.isNotEmpty) {
      if (_selectedBatchId == null || !batches.any((b) => b.id == _selectedBatchId)) {
        _selectedBatchId = batches.first.id;
      }
    }

    final batch = batches.isNotEmpty
        ? batches.firstWhere((b) => b.id == _selectedBatchId)
        : null;

    final events = batch != null ? _eventsFor(batch.id, isTransporter) : <_TraceEvent>[];
    final docs = batch != null ? _docsFor(batch.id, isTransporter) : <_BatchDocument>[];
    final scans = batch != null ? _scansFor(batch.id, isTransporter) : <_ScanLog>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTransporter ? 'Freight Chain of Custody & Consignment Tracking' : 'Traceability',
                            style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w800, color: dark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isTransporter
                                ? 'Live cargo manifest, Bill of Lading, transit checkpoints, cold-chain integrity, and offload handovers.'
                                : 'Track origin, events, documents, scans, and readiness.',
                            style: GoogleFonts.inter(color: muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (batches.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.black12)),
                        child: Text(
                          isTransporter ? 'Seal Verified 99.4%' : 'Avg ${(_overallReadiness(batches) * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: dark, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (batches.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
                    child: Center(
                      child: Text(
                        isTransporter ? 'No active cargo consignments in transit. Check back when dispatch orders are assigned.' : 'No active batches to trace. Please check back when orders are confirmed.',
                        style: GoogleFonts.inter(color: muted),
                      ),
                    ),
                  )
                else ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stats = isTransporter
                          ? [
                              {'label': 'Cargo Loads', 'value': '${batches.length}', 'icon': Icons.local_shipping_outlined},
                              {'label': 'In-Transit', 'value': '${batches.where((b) => b.status == 'Ready' || b.status == 'In-Transit').length}', 'icon': Icons.navigation_outlined},
                              {'label': 'Cold-Chain OK', 'value': '${batches.length}', 'icon': Icons.ac_unit_outlined},
                              {'label': 'Cleared', 'value': '${batches.where((b) => b.status != 'Blocked').length}', 'icon': Icons.verified_user_outlined},
                            ]
                          : [
                              {'label': 'Batches', 'value': '${batches.length}', 'icon': Icons.inventory_2_outlined},
                              {'label': 'Ready', 'value': '${batches.where((b) => b.status == 'Ready').length}', 'icon': Icons.verified_outlined},
                              {'label': 'Review', 'value': '${batches.where((b) => b.status == 'Review').length}', 'icon': Icons.rate_review_outlined},
                              {'label': 'Blocked', 'value': '${batches.where((b) => b.status == 'Blocked').length}', 'icon': Icons.block_outlined},
                            ];
                      if (constraints.maxWidth >= 900) {
                        return Row(
                          children: stats.map((s) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _StatCard(label: s['label'] as String, value: s['value'] as String, icon: s['icon'] as IconData),
                            ),
                          )).toList(),
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _StatCard(label: stats[0]['label'] as String, value: stats[0]['value'] as String, icon: stats[0]['icon'] as IconData)),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: stats[1]['label'] as String, value: stats[1]['value'] as String, icon: stats[1]['icon'] as IconData)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _StatCard(label: stats[2]['label'] as String, value: stats[2]['value'] as String, icon: stats[2]['icon'] as IconData)),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: stats[3]['label'] as String, value: stats[3]['value'] as String, icon: stats[3]['icon'] as IconData)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isTransporter ? 'Active Consignment Manifests & Cargo Batches' : 'Batches',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                  ),
                  const SizedBox(height: 10),
                  ...batches.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BatchCard(
                      batch: b,
                      selected: b.id == _selectedBatchId,
                      onTap: () => setState(() => _selectedBatchId = b.id),
                    ),
                  )),
                  const SizedBox(height: 16),
                  Text(
                    isTransporter ? 'Consignment Waybill QR & Digital Seal' : 'Batch QR Code & Generator',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        if (batch != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.qr_code, size: 80, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Batch Code: ${batch.batchCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Verdi Certified Crop Identity Block for ${batch.cropName}.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text('Generate QR Batch: ${batch.batchCode}'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('This will generate 10 unique item-level tracking QR codes for this batch.'),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: List.generate(4, (index) => Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.qr_code, size: 40),
                                        )),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                                      child: const Text('Print/Download PDF'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.qr_code_2),
                            label: const Text('Generate Batch QR Set'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ] else ...[
                          Text('No batch selected to generate QR codes.', style: TextStyle(color: muted)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(isTransporter ? 'Freight Transit Logs & Milestones' : 'Trace Events', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
                  const SizedBox(height: 10),
                  ...events.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EventCard(event: e),
                  )),
                  const SizedBox(height: 16),
                  Text(isTransporter ? 'Consignment & Transit Documents' : 'Documents', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
                  const SizedBox(height: 10),
                  ...docs.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DocCard(doc: d),
                  )),
                  const SizedBox(height: 16),
                  Text(isTransporter ? 'Chain of Custody Scan Records' : 'Scan Logs', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
                  const SizedBox(height: 10),
                  ...scans.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ScanCard(scan: s),
                  )),
                  const SizedBox(height: 16),
                  Text(isTransporter ? 'Live Checkpoint & Waybill Scanner' : 'Live Scan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
                  const SizedBox(height: 10),
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_isScanning)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.qr_code_scanner, size: 50, color: Colors.white70),
                                const SizedBox(height: 12),
                                Text(
                                  isTransporter ? 'Aim camera at cargo QR seal / Bill of Lading' : 'Aim camera at product QR label',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: batch != null ? () => _startScan(batch.id) : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(isTransporter ? 'Scan Waybill / Cargo Seal' : 'Start Scan Simulation'),
                                ),
                              ],
                            )
                          else
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: Container(color: Colors.black54),
                                ),
                                // Reticle
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF16A34A), width: 3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                // Blinking scanning line
                                const _BlinkingScanLine(),
                                const Positioned(
                                  bottom: 20,
                                  child: Text(
                                    'Scanning QR Code...',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlinkingScanLine extends StatefulWidget {
  const _BlinkingScanLine();

  @override
  State<_BlinkingScanLine> createState() => _BlinkingScanLineState();
}

class _BlinkingScanLineState extends State<_BlinkingScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 50 + _controller.value * 140,
          child: Container(
            width: 140,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TraceBatch {
  final String id;
  final String batchCode;
  final String cropName;
  final String farmName;
  final String fieldName;
  final String harvestDate;
  final int quantity;
  final String unit;
  final String status;
  final double readinessScore;
  final bool originVerified;
  final bool inspectionPassed;

  const _TraceBatch({
    required this.id,
    required this.batchCode,
    required this.cropName,
    required this.farmName,
    required this.fieldName,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.readinessScore,
    required this.originVerified,
    required this.inspectionPassed,
  });
}

class _TraceEvent {
  final String eventType;
  final String eventTime;
  final String actorName;
  final String location;
  final String notes;

  const _TraceEvent({
    required this.eventType,
    required this.eventTime,
    required this.actorName,
    required this.location,
    required this.notes,
  });
}

class _BatchDocument {
  final String docType;
  final String fileName;

  const _BatchDocument({required this.docType, required this.fileName});
}

class _ScanLog {
  final String scannedAt;
  final String scannerRole;
  final String result;

  const _ScanLog({
    required this.scannedAt,
    required this.scannerRole,
    required this.result,
  });
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(color: muted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final _TraceBatch batch;
  final bool selected;
  final VoidCallback onTap;

  const _BatchCard({
    required this.batch,
    required this.selected,
    required this.onTap,
  });

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  Color _color() {
    return batch.status == 'Ready'
        ? green
        : batch.status == 'Review'
            ? Colors.orange
            : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? color : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${batch.batchCode} • ${batch.cropName}',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: dark),
                  ),
                ),
                Text(batch.status, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${batch.farmName} • ${batch.fieldName}', style: const TextStyle(color: muted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Harvest ${batch.harvestDate}', style: const TextStyle(color: muted, fontSize: 12)),
                const Spacer(),
                Text('${batch.quantity} ${batch.unit}', style: const TextStyle(color: muted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: batch.readinessScore,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: color,
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 380;
                final badge1 = _MiniBadge(label: 'Origin', value: batch.originVerified ? 'Verified' : 'Missing', dark: dark, muted: muted);
                final badge2 = _MiniBadge(label: 'Inspection', value: batch.inspectionPassed ? 'Passed' : 'Pending', dark: dark, muted: muted);
                final badge3 = _MiniBadge(label: 'Readiness', value: '${(batch.readinessScore * 100).round()}%', dark: dark, muted: muted);

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      badge1,
                      const SizedBox(height: 8),
                      badge2,
                      const SizedBox(height: 8),
                      badge3,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: badge1),
                    const SizedBox(width: 10),
                    Expanded(child: badge2),
                    const SizedBox(width: 10),
                    Expanded(child: badge3),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color dark;
  final Color muted;

  const _MiniBadge({
    required this.label,
    required this.value,
    required this.dark,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: dark)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final _TraceEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventType,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: _StatCard.dark),
                ),
              ),
              Text(event.eventTime, style: const TextStyle(color: _StatCard.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${event.actorName} • ${event.location}', style: const TextStyle(color: _StatCard.muted)),
          const SizedBox(height: 4),
          Text(event.notes, style: const TextStyle(color: _StatCard.dark)),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final _BatchDocument doc;
  const _DocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: _StatCard.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.docType, style: const TextStyle(fontWeight: FontWeight.w800, color: _StatCard.dark)),
                const SizedBox(height: 4),
                Text(doc.fileName, style: const TextStyle(color: _StatCard.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final _ScanLog scan;
  const _ScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_scanner_outlined, color: _StatCard.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${scan.scannerRole} • ${scan.result}', style: const TextStyle(fontWeight: FontWeight.w800, color: _StatCard.dark)),
                const SizedBox(height: 4),
                Text(scan.scannedAt, style: const TextStyle(color: _StatCard.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}