import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../../../state/cart_state.dart';
import '../../../state/app_state.dart';
import '../../../state/irrigation_state.dart';
import 'package:verdi/core/services/verdi_api_service.dart';

// ============ DATA MODELS ============

enum InspectionType { health, irrigation, weeds, yield }
enum DroneStatus { idle, connected, flying, paused, rth, landing }

class InspectionIssue {
  final String type;
  final String severity;
  final double areaHa;
  final String recommendation;
  final String productLink;
  final LatLng location;

  InspectionIssue({
    required this.type,
    required this.severity,
    required this.areaHa,
    required this.recommendation,
    required this.productLink,
    required this.location,
  });
}

class DroneInspection {
  final String inspectionId;
  final String farmName;
  final double farmSizeHa;
  final String cropType;
  final DateTime date;
  final double healthScore;
  final List<InspectionIssue> issues;
  final String orthomosaicUrl;

  DroneInspection({
    required this.inspectionId,
    required this.farmName,
    required this.farmSizeHa,
    required this.cropType,
    required this.date,
    required this.healthScore,
    required this.issues,
    required this.orthomosaicUrl,
  });
}

class DroneState {
  double battery = 94.0;
  double altitude = 0.0;
  double speed = 0.0;
  double missionProgress = 0.0;
  DroneStatus status = DroneStatus.connected;
  LatLng position = const LatLng(-17.8252, 31.0335); // Harare / Mazowe
  String cameraMode = 'NDVI Thermal';
}

class DroneService {
  final DroneState state = DroneState();
  Timer? _missionTimer;

  void takeoff(VoidCallback onUpdate) {
    state.status = DroneStatus.flying;
    state.altitude = 80.0;
    state.speed = 12.5;
    onUpdate();
  }

  void startMission(VoidCallback onUpdate) {
    state.status = DroneStatus.flying;
    try {
      VerdiApiService.instance.launchDroneMission('Autonomous Mission Scan', 'Zone 1-3');
    } catch (_) {}
    _missionTimer?.cancel();
    _missionTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      state.missionProgress += 3.3;
      state.battery -= 0.3;
      state.speed = 15.2;
      state.altitude = 85.0;
      state.position = LatLng(
        state.position.latitude + 0.0001,
        state.position.longitude + 0.00015,
      );
      onUpdate();
      if (state.missionProgress >= 100) {
        state.missionProgress = 100;
        _missionTimer?.cancel();
        land(onUpdate);
      }
    });
  }

  void pauseMission() {
    _missionTimer?.cancel();
    state.status = DroneStatus.paused;
    state.speed = 0.0;
  }

  void returnToHome(VoidCallback onUpdate) {
    _missionTimer?.cancel();
    state.status = DroneStatus.rth;
    state.altitude = 40.0;
    state.speed = 22.0;
    state.position = const LatLng(-17.8252, 31.0335);
    state.missionProgress = 100;
    onUpdate();
  }

  void land(VoidCallback onUpdate) {
    state.status = DroneStatus.landing;
    state.altitude = 0.0;
    state.speed = 0.0;
    onUpdate();
  }

  DroneInspection getDemoResults() {
    return DroneInspection(
      inspectionId: "DR-${DateTime.now().millisecondsSinceEpoch}",
      farmName: "Demo Farm Kadoma",
      farmSizeHa: 5.2,
      cropType: "Maize",
      date: DateTime.now(),
      healthScore: 78,
      orthomosaicUrl:
          "https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=900&q=80",
      issues: [
        InspectionIssue(
          type: "Low Moisture",
          severity: "High",
          areaHa: 0.8,
          recommendation: "Deploy drip lines immediately",
          productLink: "drip_irrigation_kit",
          location: const LatLng(-17.826, 31.034),
        ),
        InspectionIssue(
          type: "Weed Pressure",
          severity: "Medium",
          areaHa: 1.2,
          recommendation: "Apply selective 2,4-D Herbicide",
          productLink: "herbicide_24d",
          location: const LatLng(-17.824, 31.032),
        ),
      ],
    );
  }
}

// ============ MAIN DRONE INSPECTION VIEW ============

class DroneInspectionView extends ConsumerWidget {
  const DroneInspectionView({super.key});

  static const green = Color(0xFF10B981);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const bgLight = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(irrigationStateProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flight_takeoff_rounded, color: green, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Autonomous Drone Inspection Command',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: dark, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManualControlScreen()),
                );
              },
              icon: const Icon(Icons.videogame_asset_outlined, size: 16, color: dark),
              label: Text('Manual Override', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: dark)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: state.droneStatus == 'In Flight'
                  ? null
                  : () => _showNewMissionDialog(context, ref),
              icon: const Icon(Icons.add_location_alt_outlined, size: 16),
              label: Text(
                state.droneStatus == 'In Flight' ? 'In Flight' : 'Schedule Mission',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
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
                  // Hero Header Banner
                  _SpatialHeroBanner(),
                  const SizedBox(height: 18),

                  // AI Analysis Summary & Telemetry Bar
                  _AiFindingSummaryCard(),
                  const SizedBox(height: 18),

                  // Telemetry Stats Row
                  const _MissionStatRow(),
                  const SizedBox(height: 20),

                  // Main Interactive Grid
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(flex: 3, child: _MissionList()),
                        const SizedBox(width: 18),
                        const Expanded(flex: 2, child: _CaptureGallery()),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        _MissionList(),
                        SizedBox(height: 18),
                        _CaptureGallery(),
                      ],
                    ),
                  const SizedBox(height: 22),

                  // AI Classified Anomaly Section
                  Row(
                    children: [
                      Text(
                        'AI-Classified Crop Anomalies & Recommendations',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ref.watch(isDemoModeProvider)
                              ? blue.withValues(alpha: 0.1)
                              : green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ref.watch(isDemoModeProvider) ? '3 HOTSPOTS DETECTED' : '0 HOTSPOTS DETECTED',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ref.watch(isDemoModeProvider) ? blue : green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (ref.watch(isDemoModeProvider))
                    ..._findings.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FindingCard(finding: f),
                        ))
                  else
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      ),
                      child: Center(
                        child: Text(
                          'No active crop anomalies or hotspots detected across registered farm zones.',
                          style: GoogleFonts.inter(fontSize: 13, color: muted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),

                  // Launch Mission Banner CTA
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: green.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.flight_takeoff, color: Colors.white, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Launch Real-Time Drone Telemetry Simulator',
                                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Experience live 5G mesh telemetry tracking, multispectral camera streams, and instant automated AI spot-treatment purchase triggers.',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.88), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AutoMissionScreen()),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text('Start Telemetry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: dark,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNewMissionDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(irrigationStateProvider.notifier);
    String selectedField = 'Field A – Gutu';
    String selectedType = 'Crop Health Scan';
    String selectedPattern = 'Zig-zag Scan Grid';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.add_location_alt_outlined, color: green),
              const SizedBox(width: 8),
              Text('Schedule Autonomous Mission', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedField,
                  decoration: const InputDecoration(labelText: 'Target Farm Zone'),
                  items: ['Field A – Gutu', 'Field B – Mvurwi', 'Field D – Odzi', 'Field E – Bindura']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedField = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Multispectral Inspection Profile'),
                  items: ['Crop Health Scan (NDVI)', 'Thermal Irrigation Check', 'Pest Anomaly Detection', 'Yield & Biomass Estimation']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPattern,
                  decoration: const InputDecoration(labelText: 'Autonomous Flight Grid'),
                  items: ['Zig-zag Scan Grid', 'Perimeter Boundary Scan', 'High-Res Orthomosaic Loop']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedPattern = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.addDroneMission(
                  DroneMission(
                    title: '$selectedType – $selectedField',
                    status: 'Scheduled',
                    field: selectedField,
                    coverage: 0.0,
                    hotspots: 0,
                  ),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mission "$selectedType" scheduled for $selectedField')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Mission'),
            ),
          ],
        ),
      ),
    );
  }

  static final List<_Finding> _findings = const [
    _Finding(
      zone: 'Zone 2 – Field B (Mvurwi)',
      findingType: 'Water Stress Pattern',
      severity: 'High',
      confidence: 91,
      likelyCause: 'Irrigation gap detected over 3 days. Possible drip line valve block.',
      suggestedAction: 'Deploy drip lines immediately. Tap "Buy Fix" to auto-order replacement drip kit.',
      productName: 'Drip Irrigation Kit',
      productPrice: '\$250.00',
      productImg: 'https://images.unsplash.com/photo-1463123081488-729f99c93b6e?auto=format&fit=crop&w=900&q=80',
    ),
    _Finding(
      zone: 'Zone 5 – Field D (Odzi)',
      findingType: 'Pest Sign (Armyworm)',
      severity: 'Medium',
      confidence: 78,
      likelyCause: 'Leaf discolouration pattern consistent with armyworm migration.',
      suggestedAction: 'Apply selective 2,4-D Herbicide. Tap "Buy Fix" to order treatment load.',
      productName: '2,4-D Selective Herbicide',
      productPrice: '\$15.00',
      productImg: 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80',
    ),
    _Finding(
      zone: 'Zone 1 – Field A (Gutu)',
      findingType: 'Water Pooling Anomaly',
      severity: 'Low',
      confidence: 85,
      likelyCause: 'Sub-surface drainage blockage after heavy rain.',
      suggestedAction: 'Monitor soil drainage for 24h. Schedule drain clearance if pooling persists.',
      productName: 'Drain Clearance Tool',
      productPrice: '\$45.00',
      productImg: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=900&q=80',
    ),
  ];
}

// ============ UPGRADED WORKSPACE COMPONENTS ============

class _SpatialHeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.satellite_alt_outlined, color: Color(0xFF3B82F6), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Geospatial Sentinel-2 Telemetry Link',
                      style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(12)),
                      child: Text('ACTIVE MESH', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'NDVI & Thermal imagery layers synced from high-resolution drone flight passes over Zimbabwe agricultural hubs.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiFindingSummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Anomaly Classification & Field Diagnostics',
                  style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  isDemo
                      ? '3 active hotspots classified across 5.2 ha scan. High-priority moisture deficit detected in Zone 2 (confidence: 91%). One-click fix purchase active.'
                      : '0 active hotspots detected. Telemetry normal across live field scans.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionStatRow extends ConsumerWidget {
  const _MissionStatRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth > 800 ? 1.8 : 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatChip(label: 'Missions Complete', value: isDemo ? '14' : '0', sub: isDemo ? 'This Season' : 'Live Network', icon: Icons.flight_outlined, color: const Color(0xFF10B981)),
            _StatChip(label: 'Farm Coverage', value: isDemo ? '72%' : '0%', sub: 'Total Hectares', icon: Icons.area_chart_outlined, color: const Color(0xFF3B82F6)),
            _StatChip(label: 'Active Hotspots', value: isDemo ? '3' : '0', sub: isDemo ? 'Action Required' : 'Nominal', icon: Icons.warning_amber_outlined, color: isDemo ? const Color(0xFFF97316) : const Color(0xFF10B981)),
            _StatChip(label: 'Average NDVI', value: isDemo ? '0.74' : '0.00', sub: 'Vegetative Score', icon: Icons.grass_outlined, color: const Color(0xFF10B981)),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                Text(sub, style: GoogleFonts.inter(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionList extends ConsumerWidget {
  const _MissionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final missions = isDemo ? ref.watch(irrigationStateProvider).droneMissions : <DroneMission>[];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Flight Mission Queue & History', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const Spacer(),
              Text('${missions.length} Registered', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 14),
          ...missions.map((m) {
            final color = m.status == 'Completed'
                ? const Color(0xFF10B981)
                : m.status == 'In Flight'
                    ? const Color(0xFF3B82F6)
                    : m.status == 'Failed'
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFF97316);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(m.title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13.5, color: const Color(0xFF0F172A))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Text(m.status, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(m.field, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                      const Spacer(),
                      Text('Coverage: ${(m.coverage * 100).round()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: m.coverage,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                  ),
                  if (m.status == 'In Flight' || m.status == 'Scheduled') ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AutoMissionScreen()),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Open Telemetry HUD'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CaptureGallery extends ConsumerWidget {
  const _CaptureGallery();

  static const _captures = [
    _Capture(
      label: 'NDVI Overlay – Zone 2',
      tag: 'Moisture Deficit',
      url: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=400&q=80',
    ),
    _Capture(
      label: 'RGB Multispectral – Zone 5',
      tag: 'Armyworm Sign',
      url: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=400&q=80',
    ),
    _Capture(
      label: 'Thermal Irradiance – Zone 1',
      tag: 'Water Pooling',
      url: 'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Multispectral Gallery', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          const SizedBox(height: 14),
          if (isDemo)
            ..._captures.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Image.network(c.url, height: 110, width: double.infinity, fit: BoxFit.cover),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(c.label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(10)),
                              child: Text(c.tag, style: GoogleFonts.inter(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No Multispectral Drone Imagery Captured Yet.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Capture {
  final String label;
  final String tag;
  final String url;
  const _Capture({required this.label, required this.tag, required this.url});
}

class _Finding {
  final String zone;
  final String findingType;
  final String severity;
  final int confidence;
  final String likelyCause;
  final String suggestedAction;
  final String productName;
  final String productPrice;
  final String productImg;

  const _Finding({
    required this.zone,
    required this.findingType,
    required this.severity,
    required this.confidence,
    required this.likelyCause,
    required this.suggestedAction,
    required this.productName,
    required this.productPrice,
    required this.productImg,
  });
}

class _FindingCard extends ConsumerWidget {
  final _Finding finding;
  const _FindingCard({required this.finding});

  Color get _severityColor => finding.severity == 'High'
      ? const Color(0xFFEF4444)
      : finding.severity == 'Medium'
          ? const Color(0xFFF97316)
          : const Color(0xFF10B981);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _severityColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(color: _severityColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _severityColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.my_location, color: _severityColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(finding.findingType, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14.5, color: const Color(0xFF0F172A))),
                    Text(finding.zone, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(finding.severity, style: GoogleFonts.inter(color: _severityColor, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 4),
                  Text('${finding.confidence}% AI confidence', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 10),
          Text(
            '📋 Cause: ${finding.likelyCause}',
            style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF475569), height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            '✅ Action: ${finding.suggestedAction}',
            style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF10B981), fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(cartProvider.notifier).addItem(
                        CartItem(
                          id: '${finding.productName}-AgriSupply',
                          name: finding.productName,
                          price: finding.productPrice,
                          quantity: 1,
                          imageUrl: finding.productImg,
                          supplier: 'AgriSupply Ltd',
                        ),
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${finding.productName} added to Verdi Cart!'),
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () {
                          ref.read(appStateProvider.notifier).setNavIndex(1);
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: Text('Buy Fix (${finding.productPrice})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ SCREEN 2: AUTO MISSION CONTROL TELEMETRY ============

class AutoMissionScreen extends StatefulWidget {
  const AutoMissionScreen({super.key});

  @override
  State<AutoMissionScreen> createState() => _AutoMissionScreenState();
}

class _AutoMissionScreenState extends State<AutoMissionScreen> {
  final DroneService drone = DroneService();
  GoogleMapController? _mapController;

  void _update() {
    if (mounted) {
      setState(() {});
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(drone.state.position),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mission Telemetry Control & HUD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: CameraPosition(
                    target: drone.state.position,
                    zoom: 16.0,
                  ),
                  mapType: MapType.hybrid,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('drone_position'),
                      position: drone.state.position,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: const InfoWindow(title: 'Verdi Air Drone'),
                    ),
                  },
                  polygons: {
                    Polygon(
                      polygonId: const PolygonId('farm_boundary'),
                      points: const [
                        LatLng(-17.826, 31.032),
                        LatLng(-17.828, 31.032),
                        LatLng(-17.828, 31.035),
                        LatLng(-17.826, 31.035),
                      ],
                      strokeColor: Colors.greenAccent,
                      strokeWidth: 3,
                      fillColor: Colors.greenAccent.withValues(alpha: 0.15),
                    ),
                  },
                ),
                // Telemetry HUD Overlay
                Positioned(
                  top: 12,
                  left: 12,
                  child: Card(
                    color: Colors.black.withValues(alpha: 0.85),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.battery_4_bar, color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Text('Battery: ${drone.state.battery.toStringAsFixed(0)}%', style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.height, color: Colors.blue, size: 18),
                            const SizedBox(width: 6),
                            Text('Altitude: ${drone.state.altitude.toStringAsFixed(0)}m', style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.speed, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text('Speed: ${drone.state.speed.toStringAsFixed(1)}m/s', style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.sensors, color: Colors.cyan, size: 18),
                            const SizedBox(width: 6),
                            Text('Status: ${drone.state.status.name.toUpperCase()}', style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('LIVE SIMULATOR ACTIVE', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Autonomous Mission Flight Progress', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${drone.state.missionProgress.toStringAsFixed(0)}%', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: const Color(0xFF10B981))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: drone.state.missionProgress / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => drone.pauseMission());
                          },
                          child: const Text('PAUSE'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => drone.startMission(_update));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('START MISSION'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => drone.returnToHome(_update));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('RTH'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      drone.land(_update);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InspectionResultsScreen(inspection: drone.getDemoResults()),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('END MISSION & GENERATE REPORT'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ SCREEN 3: MANUAL CONTROL OVERRIDE ============

class ManualControlScreen extends StatelessWidget {
  const ManualControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Manual Override Flight Controller', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_camera_front, size: 64, color: Colors.white54),
                    const SizedBox(height: 16),
                    Text('LIVE FEED DISCONNECTED', style: GoogleFonts.inter(color: Colors.white54, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Simulator mode active — manual flight controls ready', style: GoogleFonts.inter(color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Joystick(
                      listener: (details) {},
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                        child: const Text('TAKEOFF'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        child: const Text('AUTO-LAND'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                        child: const Text('FORCE RTH'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Joystick(
                      listener: (details) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ SCREEN 4: INSPECTION RESULTS & CART TRIGGER ============

class InspectionResultsScreen extends ConsumerWidget {
  final DroneInspection inspection;

  const InspectionResultsScreen({super.key, required this.inspection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Drone Inspection Report', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inspection.farmName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '${inspection.cropType} • ${inspection.farmSizeHa} Hectares • ${inspection.date.toString().split(' ')[0]}',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: const Text('Orthomosaic Crop Health Score'),
                trailing: Text(
                  '${inspection.healthScore}/100',
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                inspection.orthomosaicUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text('AI-Detected Anomaly Issues:', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...inspection.issues.map((issue) {
              final isHigh = issue.severity == 'High';
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: isHigh ? Colors.red : Colors.orange, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${issue.type} (${issue.severity} Risk)',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text('${issue.areaHa} ha affected • ${issue.recommendation}'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = issue.type.contains('Moisture') ? 'Drip Irrigation Kit' : '2,4-D Herbicide';
                          final price = issue.type.contains('Moisture') ? '\$250.00' : '\$15.00';
                          final img = issue.type.contains('Moisture')
                              ? 'https://images.unsplash.com/photo-1463123081488-729f99c93b6e?auto=format&fit=crop&w=900&q=80'
                              : 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80';

                          ref.read(cartProvider.notifier).addItem(
                                CartItem(
                                  id: '$name-AgriSupply',
                                  name: name,
                                  price: price,
                                  quantity: 1,
                                  imageUrl: img,
                                  supplier: 'AgriSupply',
                                ),
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name added to Verdi Cart!'),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'View Cart',
                                textColor: Colors.white,
                                onPressed: () {
                                  ref.read(appStateProvider.notifier).setNavIndex(1);
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Buy Fix'),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading PDF Report...')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download PDF Report'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}