import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdi/state/app_state.dart';
import '../../../state/geospatial_state.dart';

class CropHealthPage extends ConsumerWidget {
  const CropHealthPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const background = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appStateProvider).role;
    final isReadOnly = role != UserRole.farmer && role != UserRole.admin;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Crop Health Dashboard',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: dark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isReadOnly)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: const Text('Read-Only View', style: TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: orange,
                side: BorderSide.none,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: isMobile ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geospatial sync banner
                  _SpatialBanner(),
                  const SizedBox(height: 16),

                  // Top Summary Row
                  _TopSummaryRow(),
                  const SizedBox(height: 16),

                  // AI Decision Insight Cards (Confidence + Source badges)
                  Text(
                    'AI Predictive Diagnostics',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                  ),
                  const SizedBox(height: 10),
                  _AiInsightGrid(),
                  const SizedBox(height: 20),

                  // Crop Health Trend Chart + Evidence Panel side-by-side
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(flex: 3, child: _HealthTrendChartCard()),
                            const SizedBox(width: 16),
                            const Expanded(flex: 2, child: _EvidencePanel()),
                          ],
                        );
                      }
                      return const Column(
                        children: [
                          _HealthTrendChartCard(),
                          SizedBox(height: 16),
                          _EvidencePanel(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Zone Health Cards list
                  Text(
                    'Zone Crop Health Registry',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                  ),
                  const SizedBox(height: 10),
                  _ZoneHealthList(isReadOnly: isReadOnly),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpatialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_outlined, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Geospatial Communication rules: Every zone points to a unique ID. Selecting a stressed zone updates highlights in the shared layer.',
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: CropHealthPage.dark),
            ),
          ),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Active', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TopSummaryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Healthy Zones', '12 Zones', Icons.check_circle_outline, CropHealthPage.green),
      ('Stressed Zones', '3 flagged', Icons.warning_amber_outlined, CropHealthPage.orange),
      ('Critical Alerts', '1 Active', Icons.error_outline, CropHealthPage.red),
      ('Average Score', '0.78 NDVI', Icons.grass_outlined, CropHealthPage.green),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 500 ? 2 : 1);
        final spacing = 12.0;
        final double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats.map((s) {
            return Container(
              width: width,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: s.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(s.$3, color: s.$4, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.$1, style: const TextStyle(color: CropHealthPage.muted, fontSize: 11)),
                        Text(s.$2, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: CropHealthPage.dark)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _AiInsightGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = const [
      _AiCard(
        title: 'Moisture Stress Forecast',
        desc: 'Vegetation stress likely in 48 hours due to soil saturation drop in Zone 2.',
        confidence: 92,
        signals: ['Satellite Moisture', 'Sensor #14'],
        color: CropHealthPage.orange,
      ),
      _AiCard(
        title: 'Fungal Disease Risk Rising',
        desc: 'High ambient humidity levels indicate rising powdery mildew risk in Zone 3.',
        confidence: 84,
        signals: ['Weather Humidity', 'Drone Scan'],
        color: CropHealthPage.red,
      ),
      _AiCard(
        title: 'Irrigation Recommendation',
        desc: 'Zone 4 moisture satisfies transpiration requirement. Review irrigation skip recommendation.',
        confidence: 96,
        signals: ['Transpiration Rate', 'Sensor #9'],
        color: CropHealthPage.green,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final double width = wide ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((c) {
            return Container(
              width: width,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.color.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: CropHealthPage.dark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${c.confidence}% confidence', style: TextStyle(color: c.color, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(c.desc, style: const TextStyle(fontSize: 12.5, color: CropHealthPage.muted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: c.signals.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(s, style: const TextStyle(fontSize: 10, color: CropHealthPage.muted, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _HealthTrendChartCard extends StatelessWidget {
  const _HealthTrendChartCard();

  @override
  Widget build(BuildContext context) {
    final weeks = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5', 'Wk 6'];
    final healthData = [0.72, 0.74, 0.61, 0.68, 0.75, 0.78];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crop Health Trend (Normalized NDVI)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weeks.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: healthData[i],
                            child: Container(
                              decoration: BoxDecoration(
                                color: healthData[i] < 0.65 ? CropHealthPage.orange : CropHealthPage.green,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(weeks[i], style: const TextStyle(fontSize: 10.5, color: CropHealthPage.muted, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidencePanel extends ConsumerWidget {
  const _EvidencePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anomalies = ref.watch(geospatialStateProvider);
    final evidenceItems = anomalies.map((a) {
      final icon = a.source == 'Satellite' 
          ? Icons.satellite_alt_outlined 
          : (a.source == 'Drone' ? Icons.flight_outlined : Icons.sensors_outlined);
      final color = a.resolved 
          ? CropHealthPage.green 
          : (a.severity >= 0.7 ? CropHealthPage.red : CropHealthPage.orange);
      return (
        '${a.source} Scan · ${a.zone}',
        '${a.title}: ${a.detail}',
        icon,
        color
      );
    }).toList();

    if (evidenceItems.isEmpty) {
      evidenceItems.addAll([
        ('Satellite Scan · Zone 2', 'NDVI trend drops in northern quadrant.', Icons.satellite_alt_outlined, CropHealthPage.blue),
        ('Drone Inspector Note · Zone 2', 'Identified localized water stress patches.', Icons.flight_outlined, CropHealthPage.orange),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Evidence Panel', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
          const SizedBox(height: 10),
          ...evidenceItems.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(e.$3, color: e.$4, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                      Text(e.$2, style: const TextStyle(fontSize: 11, color: CropHealthPage.muted)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ZoneHealthList extends ConsumerWidget {
  final bool isReadOnly;
  const _ZoneHealthList({required this.isReadOnly});

  void _showSmartIrrigationControlDialog(BuildContext context, WidgetRef ref, _ZoneItem z) {
    double waterVolume = 25;
    String systemType = 'Drip Line Fertigation';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: CropHealthPage.blue, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Smart Irrigation & Valve Dispatch',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CropHealthPage.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CropHealthPage.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: CropHealthPage.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(z.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: CropHealthPage.dark)),
                            Text('Current Moisture: ${z.moisture} • Target: 80% Optimal', style: GoogleFonts.inter(fontSize: 11, color: CropHealthPage.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Irrigation Dispense Rate (mm / ha):', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: waterVolume,
                        min: 5,
                        max: 50,
                        divisions: 9,
                        activeColor: CropHealthPage.blue,
                        label: '${waterVolume.round()} mm',
                        onChanged: (v) => setModalState(() => waterVolume = v),
                      ),
                    ),
                    Text('${waterVolume.round()} mm', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CropHealthPage.blue)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Select Delivery Mechanism:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: systemType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Drip Line Fertigation', child: Text('Drip Line Fertigation (Precision)')),
                    DropdownMenuItem(value: 'Center Pivot Spray', child: Text('Center Pivot Overhead Spray')),
                    DropdownMenuItem(value: 'Sub-surface Micro-drip', child: Text('Sub-surface Micro-drip')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => systemType = val);
                  },
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: CropHealthPage.muted),
                      const SizedBox(width: 8),
                      Text('Est. Cycle Time: ${(waterVolume * 1.8).round()} mins', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ref.read(appStateProvider.notifier).setNavIndex(9); // Navigate to Farmer Irrigation View
              },
              icon: const Icon(Icons.dashboard_outlined, size: 16),
              label: const Text('Irrigation Center'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚡ Smart Valve Dispatched! Dispensing ${waterVolume.round()}mm via $systemType to ${z.name}.'),
                    backgroundColor: CropHealthPage.green,
                  ),
                );
              },
              icon: const Icon(Icons.flash_on_rounded, size: 16),
              label: const Text('Dispatch Valve Command'),
              style: ElevatedButton.styleFrom(backgroundColor: CropHealthPage.green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showInternationalEvidenceModal(BuildContext context, WidgetRef ref, _ZoneItem z) {
    final statusColor = z.status == 'Stressed'
        ? CropHealthPage.red
        : (z.status == 'Watch' ? CropHealthPage.orange : CropHealthPage.green);

    final auditCode = 'ISO-AGRI-2026-NDVI-${z.name.replaceAll(' ', '').toUpperCase()}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top ISO Header Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CropHealthPage.dark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified_outlined, color: CropHealthPage.green, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INTERNATIONAL AGRONOMIC EVIDENCE & DIAGNOSTIC REPORT',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ISO 14064 / FAO-56 Standard Multispectral Audit • Certificate ID: $auditCode',
                                style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            z.status.toUpperCase(),
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Plot Identification Metadata Grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _MetaItem(label: 'Target Plot', value: z.name)),
                        Expanded(child: _MetaItem(label: 'Crop Stage', value: z.stage)),
                        Expanded(child: _MetaItem(label: 'Telemetry Source', value: 'Sentinel-2B & PlanetScope')),
                        Expanded(child: _MetaItem(label: 'Coordinates', value: 'Lat -17.8214°, Long 31.0489°')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Multispectral Image Heatmap & Anomaly Overlay Preview
                  Text('Multispectral Satellite Infrared & Anomaly Scan Canvas:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFF1E293B),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Opacity(
                              opacity: 0.5,
                              child: Image.network(
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.black38),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'False-Color Near-Infrared (NIR Band 8) Heatmap',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Text('NDVI Scale: ', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                                Container(
                                  width: 80,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(colors: [Colors.red, Colors.yellow, Colors.green]),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('${z.score} Score', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // International FAO Spectral Telemetry Matrix
                  Text('FAO-Standard Spectral Indices & Telemetry Table:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                        children: [
                          _buildTableHeader('Metric Indicator'),
                          _buildTableHeader('Current Scan Value'),
                          _buildTableHeader('FAO Benchmark Range'),
                          _buildTableHeader('Diagnostic Assessment'),
                        ],
                      ),
                      TableRow(children: [
                        _buildTableCell('NDVI (Canopy Density)'),
                        _buildTableCell(z.score.toStringAsFixed(2), isBold: true),
                        _buildTableCell('0.70 – 0.95'),
                        _buildTableCell(z.score >= 0.7 ? 'Healthy' : 'Stomatal Deficit', color: statusColor),
                      ]),
                      TableRow(children: [
                        _buildTableCell('EVI (Enhanced Vegetation)'),
                        _buildTableCell((z.score * 0.88).toStringAsFixed(2)),
                        _buildTableCell('0.65 – 0.85'),
                        _buildTableCell('Optimal Canopy Architecture'),
                      ]),
                      TableRow(children: [
                        _buildTableCell('NDWI (Soil Water Deficit)'),
                        _buildTableCell(z.moisture, isBold: true),
                        _buildTableCell('75% – 85% Normal'),
                        _buildTableCell(z.moisture.contains('Critical') ? 'Severe Water Stress' : 'Acceptable', color: statusColor),
                      ]),
                      TableRow(children: [
                        _buildTableCell('Chlorophyll Content'),
                        _buildTableCell('74.8 µg / cm²'),
                        _buildTableCell('65 – 90 µg/cm²'),
                        _buildTableCell('High Photosynthetic Capacity'),
                      ]),
                      TableRow(children: [
                        _buildTableCell('Thermal Transpiration Deficit'),
                        _buildTableCell('+3.2°C Thermal Elevation'),
                        _buildTableCell('< +1.5°C Ambient'),
                        _buildTableCell('Transpiration Stress Detected', color: CropHealthPage.orange),
                      ]),
                    ],
                  ),
                const SizedBox(height: 18),

                // Certified Findings & FAO Agronomic Action Plan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology_outlined, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Text('Certified AI Diagnostic Finding & Agronomic Root Cause:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Multispectral Sentinel-2 & sub-surface soil telemetry indicate localized moisture stress in ${z.name}. Stomatal conductance has dropped by 24%, triggering root-zone water extraction deficit.',
                        style: GoogleFonts.inter(fontSize: 12, color: CropHealthPage.dark),
                      ),
                      const SizedBox(height: 10),
                      Text('FAO Recommended Agronomic Remediation Plan:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
                      const SizedBox(height: 4),
                      Text(
                        '1. Immediate automated 35mm drip fertigation cycle.\n2. Apply foliar biostimulant to accelerate stomatal recovery.\n3. Orbital re-scan scheduled in 48 hours.',
                        style: GoogleFonts.inter(fontSize: 11.5, color: CropHealthPage.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Footer Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('📄 ISO 14064 Certified Audit PDF Report exported for ${z.name}!')),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export ISO Audit PDF'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSmartIrrigationControlDialog(context, ref, z);
                      },
                      icon: const Icon(Icons.water_drop_rounded, size: 16),
                      label: const Text('Open Irrigation Valves'),
                      style: ElevatedButton.styleFrom(backgroundColor: CropHealthPage.green, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = const [
      _ZoneItem(name: 'Zone 1 – Maize Block', stage: 'Vegetative stage', moisture: '64% Normal', score: 0.72, date: '1h ago', status: 'Stable'),
      _ZoneItem(name: 'Zone 2 – Tomato Plot', stage: 'Flowering stage', moisture: '44% Critical', score: 0.44, date: '2h ago', status: 'Stressed'),
      _ZoneItem(name: 'Zone 3 – Potato Field', stage: 'Tuber initiation', moisture: '58% Low', score: 0.58, date: '4h ago', status: 'Watch'),
    ];

    return Column(
      children: zones.map((z) {
        final color = z.status == 'Stressed'
            ? CropHealthPage.red
            : (z.status == 'Watch' ? CropHealthPage.orange : CropHealthPage.green);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
                      z.name,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: CropHealthPage.dark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      z.status,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(z.stage, style: const TextStyle(fontSize: 12, color: CropHealthPage.muted)),
                  const SizedBox(width: 12),
                  const Text('·', style: TextStyle(color: CropHealthPage.muted, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Text('Moisture: ${z.moisture}', style: const TextStyle(fontSize: 12, color: CropHealthPage.muted)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('NDVI Health Score', style: TextStyle(fontSize: 11, color: CropHealthPage.muted)),
                  const Spacer(),
                  Text(z.score.toStringAsFixed(2), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: z.score,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              const Divider(height: 20),
              // Action strip
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 400;
                  final scanText = Text('Scan: ${z.date}', style: const TextStyle(fontSize: 11, color: CropHealthPage.muted));
                  final btnReview = OutlinedButton.icon(
                    onPressed: () => _showInternationalEvidenceModal(context, ref, z),
                    icon: const Icon(Icons.assessment_outlined, size: 14),
                    label: const Text('Review Evidence', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      foregroundColor: CropHealthPage.dark,
                    ),
                  );
                  final btnOpen = ElevatedButton.icon(
                    onPressed: isReadOnly
                        ? null
                        : () => _showSmartIrrigationControlDialog(context, ref, z),
                    icon: const Icon(Icons.water_drop_rounded, size: 14),
                    label: const Text('Open Irrigation', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CropHealthPage.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        scanText,
                        const SizedBox(height: 10),
                        btnReview,
                        const SizedBox(height: 8),
                        btnOpen,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      scanText,
                      const Spacer(),
                      btnReview,
                      const SizedBox(width: 8),
                      btnOpen,
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: CropHealthPage.muted)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
      ],
    );
  }
}

Widget _buildTableHeader(String text) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: CropHealthPage.dark)),
  );
}

Widget _buildTableCell(String text, {bool isBold = false, Color? color}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color ?? CropHealthPage.dark,
      ),
    ),
  );
}

class _ZoneItem {
  final String name;
  final String stage;
  final String moisture;
  final double score;
  final String date;
  final String status;

  const _ZoneItem({
    required this.name,
    required this.stage,
    required this.moisture,
    required this.score,
    required this.date,
    required this.status,
  });
}

class _AiCard {
  final String title;
  final String desc;
  final int confidence;
  final List<String> signals;
  final Color color;

  const _AiCard({
    required this.title,
    required this.desc,
    required this.confidence,
    required this.signals,
    required this.color,
  });
}

