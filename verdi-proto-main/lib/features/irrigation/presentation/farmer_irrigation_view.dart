import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdi/state/app_state.dart';
import '../../../state/geospatial_state.dart';
import '../../../state/irrigation_state.dart';

class FarmerIrrigationView extends ConsumerWidget {
  final bool readOnly;

  const FarmerIrrigationView({super.key, this.readOnly = false});

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
    final isReadOnly = readOnly || role != UserRole.farmer && role != UserRole.admin;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Irrigation Command Centre',
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
              physics: const ClampingScrollPhysics(),
              padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geospatial Connection Banner
                  _GeospatialConnectionBanner(),
                  const SizedBox(height: 16),

                  // Top Command Summary Row
                  _TopCommandSummary(),
                  const SizedBox(height: 16),

                  // AI Operational Insights Card
                  _AiInsightsCard(
                    latestAnomaly: () {
                      final list = ref.watch(geospatialStateProvider).where((a) => !a.resolved);
                      return list.isEmpty ? null : list.first;
                    }(),
                  ),
                  const SizedBox(height: 16),

                  // Telemetry Sensor Strip
                  _SensorStrip(),
                  const SizedBox(height: 16),

                  // Alert exceptions rail
                  _AlertExceptionsRail(),
                  const SizedBox(height: 16),

                  // Zone Control Grid
                  Text(
                    'Zone Control Grid',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                  ),
                  const SizedBox(height: 10),
                  _ZoneControlGrid(isReadOnly: isReadOnly),
                  const SizedBox(height: 20),

                  // Hardware Controls & Scheduling Panels
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 750;
                      final panel1 = _PumpValvePanel(isReadOnly: isReadOnly);
                      final panel2 = _SchedulingPanel(isReadOnly: isReadOnly);

                      if (isNarrow) {
                        return Column(
                          children: [
                            panel1,
                            const SizedBox(height: 16),
                            panel2,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: panel1),
                          const SizedBox(width: 16),
                          Expanded(child: panel2),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Drone dispatch panel
                  _DroneDispatchPanel(isReadOnly: isReadOnly),
                  const SizedBox(height: 20),

                  // Water Report Block
                  _WaterReportBlock(),
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

class _GeospatialConnectionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: FarmerIrrigationView.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FarmerIrrigationView.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: FarmerIrrigationView.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Connected to Geospatial Layer (Spatial truth active: Syncing field boundaries & assets).',
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: FarmerIrrigationView.dark),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          const Text('Live', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TopCommandSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final state = ref.watch(irrigationStateProvider);
    
    int activeZonesCount = 0;
    if (isDemo) {
      if (state.zone1NextWatering == 'Watering Now') activeZonesCount++;
      if (state.zone2NextWatering == 'Watering Now') activeZonesCount++;
      if (state.zone3NextWatering == 'Watering Now') activeZonesCount++;
      if (state.zone4NextWatering == 'Watering Now') activeZonesCount++;
    }

    int pumpsRunning = 0;
    if (isDemo) {
      if (state.pump1Running) pumpsRunning++;
      if (state.pump2Running) pumpsRunning++;
    }

    final stats = [
      ('Active Zones', isDemo ? '$activeZonesCount / 4' : '0 / 0', Icons.grid_view_outlined, FarmerIrrigationView.green),
      ('Pumps Running', isDemo ? '$pumpsRunning Active' : '0 Active', Icons.settings_input_component_outlined, FarmerIrrigationView.blue),
      ('Water Used Today', isDemo ? '42.8 m³' : '0.0 m³', Icons.opacity_outlined, FarmerIrrigationView.blue),
      ('Offline Assets', isDemo && state.valve3AStatus == 'Fault (Leak)' ? '1 Valve' : 'None', Icons.wifi_off_outlined, FarmerIrrigationView.orange),
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
          children: stats.map((stat) {
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: stat.$4.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(stat.$3, color: stat.$4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stat.$1, style: const TextStyle(color: FarmerIrrigationView.muted, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          stat.$2,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: FarmerIrrigationView.dark),
                        ),
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

class _AiInsightsCard extends StatelessWidget {
  final GeospatialAnomaly? latestAnomaly;
  const _AiInsightsCard({this.latestAnomaly});

  @override
  Widget build(BuildContext context) {
    if (latestAnomaly != null) {
      final color = latestAnomaly!.severity > 0.8 ? FarmerIrrigationView.red : FarmerIrrigationView.orange;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.smart_toy, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'AI ANOMALY DETECTED (${latestAnomaly!.source.toUpperCase()})',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Confidence: ', style: TextStyle(color: FarmerIrrigationView.muted, fontSize: 12)),
                    Text(
                      '${(latestAnomaly!.severity * 100).round()}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${latestAnomaly!.title} in ${latestAnomaly!.zone}',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: FarmerIrrigationView.dark),
            ),
            const SizedBox(height: 6),
            Text(
              latestAnomaly!.detail,
              style: GoogleFonts.inter(fontSize: 13, color: FarmerIrrigationView.muted),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [FarmerIrrigationView.green.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FarmerIrrigationView.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FarmerIrrigationView.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.smart_toy, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'AI RECOMMENDATION',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Confidence: ', style: TextStyle(color: FarmerIrrigationView.muted, fontSize: 12)),
                  Text('94%', style: TextStyle(color: FarmerIrrigationView.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Zone 4 (Potatoes) watering can be safely delayed by 10 hours.',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: FarmerIrrigationView.dark),
          ),
          const SizedBox(height: 6),
          Text(
            'Why this matters: Remote satellite radar scans indicate high sub-surface moisture (71%), and incoming rain showers are predicted within 6 hours. Postponing this schedule will save approximately 15% water today.',
            style: GoogleFonts.inter(fontSize: 13, color: FarmerIrrigationView.muted),
          ),
        ],
      ),
    );
  }
}

class _SensorStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    final sensors = [
      ('Soil Moisture', isDemo ? '64% avg' : '0% avg', Icons.water_drop_outlined),
      ('Line Pressure', isDemo ? '3.8 bar' : '0.0 bar', Icons.speed_outlined),
      ('Flow Rate', isDemo ? '14.2 L/s' : '0.0 L/s', Icons.air_outlined),
      ('Main Tank', isDemo ? '88% Capacity' : '0% Capacity', Icons.storage_outlined),
      ('Temperature', isDemo ? '24.2°C' : '--°C', Icons.thermostat_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sensors.map((sensor) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(sensor.$3, size: 16, color: FarmerIrrigationView.muted),
                  const SizedBox(width: 6),
                  Text(
                    '${sensor.$1}: ',
                    style: const TextStyle(fontSize: 12, color: FarmerIrrigationView.muted),
                  ),
                  Text(
                    sensor.$2,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
                  ),
                  const SizedBox(width: 12),
                  if (sensors.last != sensor)
                    Container(height: 12, width: 1, color: Colors.black12),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AlertExceptionsRail extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    if (!isDemo) return const SizedBox.shrink();

    final alerts = [
      ('Pump 2 pressure anomaly', 'Warning: High friction detected in pump casing. Diagnostic recommended.', FarmerIrrigationView.orange, Icons.warning_amber),
      ('Zone 3 dry sector', 'Critical: Soil moisture at 38% in northern strip. Recommended manual override.', FarmerIrrigationView.red, Icons.error_outline),
    ];

    return Column(
      children: alerts.map((alert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: alert.$3.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: alert.$3.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(alert.$4, color: alert.$3, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.$1, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12.5, color: FarmerIrrigationView.dark)),
                    const SizedBox(height: 3),
                    Text(
                      alert.$2,
                      style: const TextStyle(fontSize: 11, color: FarmerIrrigationView.muted),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Zone {
  final String name;
  final String crop;
  final double moisture;
  final String nextWatering;
  final String mode;
  final String risk;

  const _Zone({
    required this.name,
    required this.crop,
    required this.moisture,
    required this.nextWatering,
    required this.mode,
    required this.risk,
  });
}

class _ZoneControlGrid extends ConsumerWidget {
  final bool isReadOnly;
  const _ZoneControlGrid({required this.isReadOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final state = ref.watch(irrigationStateProvider);
    final zones = isDemo
        ? [
            _Zone(name: 'Zone 1 - Maize', crop: 'Sweetcorn', moisture: state.zone1Moisture, nextWatering: state.zone1NextWatering, mode: state.zone1Mode, risk: state.zone1Risk),
            _Zone(name: 'Zone 2 - Tomatoes', crop: 'Roma Tomatoes', moisture: state.zone2Moisture, nextWatering: state.zone2NextWatering, mode: state.zone2Mode, risk: state.zone2Risk),
            _Zone(name: 'Zone 3 - Vegetables', crop: 'Spinach & Kale', moisture: state.zone3Moisture, nextWatering: state.zone3NextWatering, mode: state.zone3Mode, risk: state.zone3Risk),
            _Zone(name: 'Zone 4 - Potatoes', crop: 'Irish Gold', moisture: state.zone4Moisture, nextWatering: state.zone4NextWatering, mode: state.zone4Mode, risk: state.zone4Risk),
          ]
        : <_Zone>[];

    if (zones.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Text(
            'No Farm Zones Configured Yet. Registered irrigation zones will appear here automatically.',
            style: GoogleFonts.inter(fontSize: 13, color: FarmerIrrigationView.muted, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: zones.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: desktop ? 4 : (constraints.maxWidth > 600 ? 2 : 1),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: desktop ? 1.05 : 1.35,
          ),
          itemBuilder: (context, index) {
            final z = zones[index];
            final moisturePct = (z.moisture * 100).round();
            final riskColor = z.risk == 'High'
                ? FarmerIrrigationView.red
                : (z.risk == 'Medium' ? FarmerIrrigationView.orange : FarmerIrrigationView.green);

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          z.name,
                          style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${z.risk} Risk',
                          style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text('Moisture: ', style: TextStyle(color: FarmerIrrigationView.muted, fontSize: 12)),
                      Text('$moisturePct%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const Spacer(),
                      Text(z.mode, style: const TextStyle(fontSize: 11, color: FarmerIrrigationView.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: z.moisture,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    color: z.moisture < 0.5 ? FarmerIrrigationView.orange : FarmerIrrigationView.green,
                  ),
                  const SizedBox(height: 6),
                  Text('Next: ${z.nextWatering}', style: const TextStyle(color: FarmerIrrigationView.muted, fontSize: 11)),
                  const Divider(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _showZoneInspectionModal(context, ref, z, index);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Inspect', style: TextStyle(fontSize: 11.5)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isReadOnly
                              ? null
                              : () {
                                  ref.read(irrigationStateProvider.notifier).toggleZoneWatering(index + 1);
                                  _showValveOperationBanner(context, z, index + 1);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FarmerIrrigationView.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            z.nextWatering == 'Watering Now' ? 'Stop' : 'Trigger',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showZoneInspectionModal(BuildContext context, WidgetRef ref, _Zone z, int index) {
    final moisturePct = (z.moisture * 100).round();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: FarmerIrrigationView.green.withOpacity(0.12),
                    child: const Icon(Icons.water_drop_outlined, color: FarmerIrrigationView.green, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${z.name} Diagnostic Telemetry',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
                        ),
                        Text(
                          'Crop: ${z.crop} • Mode: ${z.mode} • Risk: ${z.risk}',
                          style: GoogleFonts.inter(fontSize: 12, color: FarmerIrrigationView.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 24),
              Text('REAL-TIME SENSOR METRICS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: FarmerIrrigationView.green, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _metricTile('Soil Moisture', '$moisturePct%', Icons.opacity, FarmerIrrigationView.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _metricTile('Line Pressure', '3.8 bar', Icons.speed, FarmerIrrigationView.blue)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _metricTile('Water Flow Rate', '14.2 L/min', Icons.water, const Color(0xFF0F766E))),
                  const SizedBox(width: 10),
                  Expanded(child: _metricTile('Soil Temp', '22.4 °C', Icons.thermostat, FarmerIrrigationView.orange)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _metricTile('Rootzone N-P-K', '14 : 14 : 12', Icons.science, const Color(0xFF7C3AED))),
                  const SizedBox(width: 10),
                  Expanded(child: _metricTile('Solenoid Valve', z.nextWatering == 'Watering Now' ? 'ACTIVE OPEN' : 'STANDBY', Icons.power_settings_new, z.nextWatering == 'Watering Now' ? FarmerIrrigationView.green : FarmerIrrigationView.muted)),
                ],
              ),
              const SizedBox(height: 20),
              Text('VALVE CONTROL OPERATIONAL COMMANDS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: FarmerIrrigationView.dark, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(irrigationStateProvider.notifier).toggleZoneWatering(index + 1);
                        Navigator.pop(context);
                        _showValveOperationBanner(context, z, index + 1);
                      },
                      icon: Icon(z.nextWatering == 'Watering Now' ? Icons.stop : Icons.play_arrow, size: 16),
                      label: Text(z.nextWatering == 'Watering Now' ? 'Stop Watering Cycle' : 'Start Fertigation Cycle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: z.nextWatering == 'Watering Now' ? FarmerIrrigationView.red : FarmerIrrigationView.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10.5, color: FarmerIrrigationView.muted)),
                Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showValveOperationBanner(BuildContext context, _Zone z, int zoneNumber) {
    final isNowWatering = z.nextWatering != 'Watering Now';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: FarmerIrrigationView.dark,
        content: Row(
          children: [
            Icon(Icons.bolt, color: isNowWatering ? FarmerIrrigationView.green : FarmerIrrigationView.orange, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isNowWatering
                    ? '⚡ Solenoid Valve #$zoneNumber (${z.crop}) ACTIVATED! Flow: 18.5 L/min.'
                    : '🛑 Solenoid Valve #$zoneNumber (${z.crop}) STOPPED. Cycle complete.',
                style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PumpValvePanel extends ConsumerWidget {
  final bool isReadOnly;
  const _PumpValvePanel({required this.isReadOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(irrigationStateProvider);
    final notifier = ref.read(irrigationStateProvider.notifier);

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
          Text(
            'Pump & Valve Controls',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
          ),
          const SizedBox(height: 12),
          _buildHardwareControlRow(
            context,
            'Main Pressure Pump 1',
            state.pump1Running ? 'Running' : 'Idle',
            state.pump1Running ? FarmerIrrigationView.green : FarmerIrrigationView.muted,
            state.pump1Running,
            isReadOnly,
            (val) => notifier.togglePump1(val),
          ),
          _buildHardwareControlRow(
            context,
            'Secondary Pump 2',
            state.pump2Running ? 'Running' : 'Idle',
            state.pump2Running ? FarmerIrrigationView.green : FarmerIrrigationView.muted,
            state.pump2Running,
            isReadOnly,
            (val) => notifier.togglePump2(val),
          ),
          _buildValveControlRow(
            context,
            'Solenoid Valve Sector 3A',
            state.valve3AStatus,
            state.valve3AStatus == 'Fault (Leak)'
                ? FarmerIrrigationView.red
                : (state.valve3AOpen ? FarmerIrrigationView.green : FarmerIrrigationView.muted),
            state.valve3AOpen,
            isReadOnly || state.valve3AStatus == 'Fault (Leak)',
            (val) => notifier.toggleValve3A(val),
          ),
          const Divider(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 340;
              final btnStop = ElevatedButton.icon(
                onPressed: isReadOnly ? null : () {
                  notifier.emergencyStop();
                },
                icon: const Icon(Icons.stop_circle_outlined, size: 16),
                label: const Text('Emergency Stop', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FarmerIrrigationView.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              final btnDiag = OutlinedButton.icon(
                onPressed: isReadOnly ? null : () async {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      title: Text('Running System Diagnostics'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: FarmerIrrigationView.green),
                          SizedBox(height: 16),
                          Text('Scanning pressure valves and flow bus sensor loops...', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                  
                  await Future<void>.delayed(const Duration(seconds: 2));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  
                  final hadFault = state.valve3AStatus == 'Fault (Leak)';
                  if (hadFault) {
                    notifier.clearValve3AFault();
                  }

                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: FarmerIrrigationView.green),
                          SizedBox(width: 8),
                          Text('Diagnostics Complete'),
                        ],
                      ),
                      content: Text(hadFault 
                          ? 'Pressure scans complete. Resolved Leak Fault on Solenoid Valve Sector 3A. Hardware is now fully operational.' 
                          : 'All loops scanned. Pressure is nominal. 0 anomalies detected.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.science_outlined, size: 16),
                label: const Text('Diagnostics', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    btnStop,
                    const SizedBox(height: 8),
                    btnDiag,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: btnStop),
                  const SizedBox(width: 8),
                  Expanded(child: btnDiag),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareControlRow(
    BuildContext context,
    String name,
    String status,
    Color color,
    bool isRunning,
    bool readOnly,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isRunning,
            activeColor: FarmerIrrigationView.green,
            onChanged: readOnly ? null : (val) {
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValveControlRow(
    BuildContext context,
    String name,
    String status,
    Color color,
    bool isOpen,
    bool readOnly,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isOpen,
            activeColor: FarmerIrrigationView.green,
            onChanged: readOnly ? null : (val) {
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}

class _SchedulingPanel extends StatefulWidget {
  final bool isReadOnly;
  const _SchedulingPanel({required this.isReadOnly});

  @override
  State<_SchedulingPanel> createState() => _SchedulingPanelState();
}

class _SchedulingPanelState extends State<_SchedulingPanel> {
  String _selectedMode = 'Auto (AI Advisory)';

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Smart Scheduling Panel',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
          ),
          const SizedBox(height: 12),
          const _ScheduleWindowRow(time: '05:00 - 06:30', zones: 'Zones 1 & 4', label: 'Morning Optimum'),
          const _ScheduleWindowRow(time: '18:00 - 19:30', zones: 'Zones 2 & 3', label: 'Evening Evap Minimised'),
          const Divider(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Irrigation Mode:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedMode,
                underline: Container(),
                items: <String>['Manual Override', 'Time Scheduled', 'Auto (AI Advisory)'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 12.5, color: FarmerIrrigationView.blue, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: widget.isReadOnly ? null : (v) {
                  if (v != null) {
                    setState(() {
                      _selectedMode = v;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleWindowRow extends StatelessWidget {
  final String time;
  final String zones;
  final String label;

  const _ScheduleWindowRow({required this.time, required this.zones, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(zones, style: const TextStyle(fontSize: 11, color: FarmerIrrigationView.muted)),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FarmerIrrigationView.blue),
          ),
        ],
      ),
    );
  }
}

class _WaterReportBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Water Consumption \u0026 Compliance Report',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined, color: FarmerIrrigationView.green),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportValueBlock(label: 'Efficiency Score', value: '92.4%', color: FarmerIrrigationView.green),
                    const SizedBox(height: 10),
                    _ReportValueBlock(label: 'Weekly Consumption', value: '298.5 m\u00b3', color: FarmerIrrigationView.dark),
                    const SizedBox(height: 10),
                    _ReportValueBlock(label: 'Quota Allocation', value: '88% Used', color: FarmerIrrigationView.blue),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _ReportValueBlock(label: 'Efficiency Score', value: '92.4%', color: FarmerIrrigationView.green)),
                  Expanded(child: _ReportValueBlock(label: 'Weekly Consumption', value: '298.5 m\u00b3', color: FarmerIrrigationView.dark)),
                  Expanded(child: _ReportValueBlock(label: 'Quota Allocation', value: '88% Used', color: FarmerIrrigationView.blue)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportValueBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReportValueBlock({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: FarmerIrrigationView.muted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}


class _DroneDispatchPanel extends ConsumerStatefulWidget {
  final bool isReadOnly;
  const _DroneDispatchPanel({required this.isReadOnly});

  @override
  ConsumerState<_DroneDispatchPanel> createState() => _DroneDispatchPanelState();
}

class _DroneDispatchPanelState extends ConsumerState<_DroneDispatchPanel> {
  bool _isDroneEnabled = false; // Smallholders default OFF

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(irrigationStateProvider);
    final notifier = ref.read(irrigationStateProvider.notifier);

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
          Row(
            children: [
              Icon(Icons.flight_takeoff, color: FarmerIrrigationView.orange, size: 22),
              const SizedBox(width: 8),
              Text(
                'Drone Systems & Aerial Survey',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    _isDroneEnabled ? 'Drone Hardware ON' : 'Smallholder Mode',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isDroneEnabled ? FarmerIrrigationView.green : FarmerIrrigationView.muted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _isDroneEnabled,
                    onChanged: (v) => setState(() => _isDroneEnabled = v),
                    activeColor: FarmerIrrigationView.green,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_isDroneEnabled) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FarmerIrrigationView.blue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: FarmerIrrigationView.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sensors, color: FarmerIrrigationView.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ground Sensor & Satellite Telemetry Active',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: FarmerIrrigationView.dark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Smallholder Mode: Drone hardware is currently toggled OFF. Moisture & crop health are monitored via Sentinel-2 satellite feeds and sub-surface soil probes. Toggle ON to launch aerial systems.',
                          style: GoogleFonts.inter(fontSize: 11, color: FarmerIrrigationView.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Target Crop Zone:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: state.selectedDroneZone,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Zone 1 (Maize)')),
                    DropdownMenuItem(value: 2, child: Text('Zone 2 (Tomatoes)')),
                    DropdownMenuItem(value: 3, child: Text('Zone 3 (Vegetables)')),
                    DropdownMenuItem(value: 4, child: Text('Zone 4 (Potatoes)')),
                  ],
                  onChanged: widget.isReadOnly || state.droneStatus == 'In Flight'
                      ? null
                      : (val) {
                          if (val != null) {
                            notifier.setSelectedDroneZone(val);
                          }
                        },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Drone Status: ', style: TextStyle(color: FarmerIrrigationView.muted, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: state.droneStatus == 'In Flight' 
                        ? FarmerIrrigationView.blue.withOpacity(0.1) 
                        : FarmerIrrigationView.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.droneStatus == 'In Flight' ? 'In Flight (Scanning)' : 'Idle (Ready)',
                    style: TextStyle(
                      color: state.droneStatus == 'In Flight' ? FarmerIrrigationView.blue : FarmerIrrigationView.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isReadOnly || state.droneStatus == 'In Flight'
                    ? null
                    : () {
                        final title = 'Zone ${state.selectedDroneZone} Moisture Survey';
                        final zoneName = 'Zone ${state.selectedDroneZone}';
                        notifier.launchDroneSurvey(title, zoneName);
                      },
                icon: const Icon(Icons.send_outlined, size: 16),
                label: Text(state.droneStatus == 'In Flight' ? 'Drone Mission in Progress...' : 'Launch Drone Survey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FarmerIrrigationView.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}