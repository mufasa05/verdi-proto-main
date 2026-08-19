import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../core/services/supabase_service.dart';
import '../../../features/auth/state/auth_state.dart';
import '../../../state/platform_data_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TRANSPORTER GPS TELEMETRY PAGE
// Dedicated GPS & Route Tracking Hub for Freight Drivers & Transporters
// ─────────────────────────────────────────────────────────────────────────────

class TransporterTelemetryPage extends ConsumerStatefulWidget {
  const TransporterTelemetryPage({super.key});

  @override
  ConsumerState<TransporterTelemetryPage> createState() =>
      _TransporterTelemetryPageState();
}

class _TransporterTelemetryPageState
    extends ConsumerState<TransporterTelemetryPage>
    with SingleTickerProviderStateMixin {
  static const Color primary = Color(0xFF2563EB);
  static const Color success = Color(0xFF16A34A);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color danger = Color(0xFFEF4444);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final bool _gpsLocked = true;
  bool _broadcastOn = true;
  bool _isUpdating = false;

  // Live telemetry status
  double _lat = -17.8292;
  double _lon = 31.0522;
  double _speedKmh = 78.4;
  final double _heading = 312.0;
  final double _altitude = 1483.0;
  final String _signal = '4G LTE';
  final int _signalBars = 4;
  final double _batteryPct = 86.0;
  String _lastSync = 'Just now';
  final int _waypointsRemaining = 2;
  final double _routeCompletionPct = 0.62;
  final String _eta = '14:47 CAT';
  final double _distanceRemaining = 214.0;

  final List<_TelemetryEvent> _demoEventLog = const [
    _TelemetryEvent('12:18', 'Position broadcast sent to Dispatch Control', Icons.send_outlined, Color(0xFF2563EB)),
    _TelemetryEvent('12:05', 'Geofence boundary crossed — Harare South Tollgate', Icons.fence_outlined, Color(0xFFF97316)),
    _TelemetryEvent('11:52', 'Speed alert cleared — regulated under 80 km/h', Icons.speed_outlined, Color(0xFF16A34A)),
    _TelemetryEvent('11:39', 'Waypoint #2 reached — Masvingo Highway Hub', Icons.place_outlined, Color(0xFF16A34A)),
    _TelemetryEvent('10:47', 'Route deviation warning auto-resolved', Icons.alt_route_outlined, Color(0xFFEF4444)),
    _TelemetryEvent('09:21', 'Driver authenticated — Tendai Moyo (TR-8821)', Icons.badge_outlined, Color(0xFF7C3AED)),
    _TelemetryEvent('09:15', 'Trip manifested: Harare Fresh Market → Bulawayo Depot', Icons.local_shipping_outlined, Color(0xFF2563EB)),
  ];

  final List<_Waypoint> _demoWaypoints = const [
    _Waypoint('WP-1', 'Harare Mbare Agri-Depot', '09:15', true, -17.8747, 31.0441),
    _Waypoint('WP-2', 'Chivhu Waypoint Checkpoint', '11:39', true, -19.0211, 30.8922),
    _Waypoint('WP-3', 'Gweru Logistics Junction', '~13:20', false, -19.4500, 29.8167),
    _Waypoint('WP-4', 'Bulawayo Central Offloading Depot', '~14:47', false, -20.1503, 28.5882),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pushGpsUpdate() async {
    setState(() => _isUpdating = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final rng = Random();
    setState(() {
      _isUpdating = false;
      _lat += (rng.nextDouble() - 0.5) * 0.003;
      _lon += (rng.nextDouble() - 0.5) * 0.003;
      _speedKmh = 72 + rng.nextDouble() * 14;
      _lastSync = 'Just now';
    });

    final authUser = ref.read(authStateProvider).user;
    final driverName = authUser?.fullName ?? 'Tendai Moyo (TR-8821)';
    final userId = authUser?.id ?? 'usr_transporter_live';

    SupabaseService.instance.broadcastActivityEvent(
      PlatformActivityEvent(
        id: 'ACT_GPS_${DateTime.now().millisecondsSinceEpoch}',
        userName: driverName,
        userId: userId,
        userRole: UserRole.transporter,
        userAvatar: 'TM',
        actionTitle: 'GPS Telemetry & Reefer Cold Chain Transmitted',
        actionDescription: 'Beacon broadcast: Speed ${_speedKmh.toStringAsFixed(1)} km/h, Location [${_lat.toStringAsFixed(4)}, ${_lon.toStringAsFixed(4)}].',
        module: 'Logistics',
        targetResource: 'Vehicle TRK-9442',
        timestamp: 'Just now',
        exactTime: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        ipAddress: 'In-Cab IoT Gateway',
        device: 'Verdi Fleet Terminal',
        status: 'Success',
        metadata: const <String, dynamic>{},
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Live Telemetry Packet Broadcasted to Carrier Network',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(isDemoModeProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 800;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22, color: dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transporter GPS Telemetry',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 17, color: dark),
            ),
            Text(
              'Freight Unit: TRK-9442 (12T Refrigerated Isuzu)',
              style: GoogleFonts.inter(fontSize: 11, color: muted, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Opacity(
                opacity: _gpsLocked ? _pulseAnim.value : 0.3,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (_gpsLocked ? success : danger).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (_gpsLocked ? success : danger).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _gpsLocked ? success : danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _gpsLocked ? 'GPS High-Precision Lock' : 'Searching Satellites…',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _gpsLocked ? success : danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1150),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 24 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Broadcast Card ──
                  _HeroBroadcastCard(
                    lat: _lat,
                    lon: _lon,
                    speedKmh: _speedKmh,
                    heading: _heading,
                    altitude: _altitude,
                    lastSync: _lastSync,
                    broadcastOn: _broadcastOn,
                    gpsLocked: _gpsLocked,
                    isUpdating: _isUpdating,
                    onToggleBroadcast: () => setState(() => _broadcastOn = !_broadcastOn),
                    onPushUpdate: _pushGpsUpdate,
                    pulseAnim: _pulseAnim,
                  ),
                  const SizedBox(height: 20),

                  // ── Route Corridor Progress ──
                  _RouteProgressCard(
                    completion: _routeCompletionPct,
                    eta: _eta,
                    distanceRemaining: _distanceRemaining,
                    waypointsRemaining: _waypointsRemaining,
                  ),
                  const SizedBox(height: 20),

                  // ── Telemetry Sensor Metrics ──
                  _TelemetryKpiGrid(
                    speedKmh: _speedKmh,
                    heading: _heading,
                    altitude: _altitude,
                    batteryPct: _batteryPct,
                    signal: _signal,
                    signalBars: _signalBars,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 24),

                  // ── Transit Waypoints & Tolls ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Corridor Waypoints & Toll Checkpoints',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: dark),
                      ),
                      Text(
                        isDemo ? 'Harare-Bulawayo A5 Highway' : 'Active Corridor Route',
                        style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _WaypointTimeline(waypoints: isDemo ? _demoWaypoints : const <_Waypoint>[]),
                  const SizedBox(height: 24),

                  // ── Telemetry Audit Log ──
                  Text(
                    'Real-Time Telemetry Audit Stream',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: dark),
                  ),
                  const SizedBox(height: 12),
                  _EventLogCard(
                    events: isDemo
                        ? _demoEventLog
                        : const [
                            _TelemetryEvent('Live Now', 'GPS Telemetry beacon locked — 0 trip deviations', Icons.gps_fixed_outlined, Color(0xFF16A34A)),
                            _TelemetryEvent('Live Now', 'Carrier telemetry pipeline online and transmitting heartbeat', Icons.sensors_outlined, Color(0xFF2563EB)),
                            _TelemetryEvent('Live Now', 'Vehicle ready for dispatch assignment', Icons.local_shipping_outlined, Color(0xFF7C3AED)),
                          ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUpdating ? null : _pushGpsUpdate,
        backgroundColor: _isUpdating ? muted : primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: _isUpdating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.satellite_alt_rounded, size: 20),
        label: Text(
          _isUpdating ? 'Transmitting Packet…' : 'Transmit Live Telemetry',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BROADCAST CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBroadcastCard extends StatelessWidget {
  final double lat, lon, speedKmh, heading, altitude;
  final String lastSync;
  final bool broadcastOn, gpsLocked, isUpdating;
  final VoidCallback onToggleBroadcast, onPushUpdate;
  final Animation<double> pulseAnim;

  const _HeroBroadcastCard({
    required this.lat,
    required this.lon,
    required this.speedKmh,
    required this.heading,
    required this.altitude,
    required this.lastSync,
    required this.broadcastOn,
    required this.gpsLocked,
    required this.isUpdating,
    required this.onToggleBroadcast,
    required this.onPushUpdate,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(painter: _MapGridPainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseAnim,
                      builder: (_, child) => Transform.scale(
                        scale: gpsLocked ? pulseAnim.value : 1.0,
                        child: child,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pin_drop_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Cargo Corridor Broadcast',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Route A5 (Harare - Gweru - Bulawayo) • Freight ID #FR-902',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggleBroadcast,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: broadcastOn ? Colors.white.withOpacity(0.2) : Colors.red.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              broadcastOn ? Icons.cell_tower_rounded : Icons.signal_wifi_off_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              broadcastOn ? 'Live Uplink ON' : 'Uplink Muted',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _CoordBox(label: 'LATITUDE', value: '${lat.toStringAsFixed(5)}° S'),
                    const SizedBox(width: 10),
                    _CoordBox(label: 'LONGITUDE', value: '${lon.toStringAsFixed(5)}° E'),
                    const SizedBox(width: 10),
                    _CoordBox(label: 'SPEED', value: '${speedKmh.toStringAsFixed(1)} km/h'),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.sync_rounded, color: Colors.white60, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Last satellite ping: $lastSync',
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: isUpdating ? null : onPushUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3A8A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: isUpdating
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E3A8A)))
                          : const Icon(Icons.upload_rounded, size: 17),
                      label: Text(
                        isUpdating ? 'Pinging…' : 'Sync Coordinate',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordBox extends StatelessWidget {
  final String label, value;
  const _CoordBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTE PROGRESS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _RouteProgressCard extends StatelessWidget {
  final double completion, distanceRemaining;
  final String eta;
  final int waypointsRemaining;
  static const Color dark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color success = Color(0xFF16A34A);

  const _RouteProgressCard({
    required this.completion,
    required this.eta,
    required this.distanceRemaining,
    required this.waypointsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.alt_route_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Transit Completion', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14.5, color: dark)),
                  Text('439 km total highway route', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B))),
                ],
              ),
              const Spacer(),
              Text(
                '${(completion * 100).round()}% Completed',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13.5, color: primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completion,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(primary),
              minHeight: 9,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ProgressStat(label: 'Destination ETA', value: eta, icon: Icons.schedule_rounded, color: success),
              const SizedBox(width: 12),
              _ProgressStat(label: 'Remaining Run', value: '${distanceRemaining.toStringAsFixed(0)} km', icon: Icons.straighten_rounded, color: primary),
              const SizedBox(width: 12),
              _ProgressStat(label: 'Toll/Offload Stops', value: '$waypointsRemaining stops', icon: Icons.flag_circle_outlined, color: const Color(0xFFF97316)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ProgressStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TELEMETRY KPI GRID
// ─────────────────────────────────────────────────────────────────────────────
class _TelemetryKpiGrid extends StatelessWidget {
  final double speedKmh, heading, altitude, batteryPct;
  final int signalBars;
  final String signal;
  final bool isWide;

  const _TelemetryKpiGrid({
    required this.speedKmh,
    required this.heading,
    required this.altitude,
    required this.batteryPct,
    required this.signalBars,
    required this.signal,
    required this.isWide,
  });

  String _compassDir(double deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }

  @override
  Widget build(BuildContext context) {
    final kpis = [
      _KpiData('Fleet Cruise Speed', '${speedKmh.toStringAsFixed(1)} km/h', Icons.speed_rounded, const Color(0xFF2563EB), speedKmh >= 90 ? 'Over Highway Limit' : 'Compliant (Under 80 km/h)'),
      _KpiData('Bearing & Heading', '${heading.toStringAsFixed(0)}° ${_compassDir(heading)}', Icons.explore_rounded, const Color(0xFF7C3AED), 'Heading South-West'),
      _KpiData('Elevation / Altitude', '${altitude.toStringAsFixed(0)} m', Icons.terrain_rounded, const Color(0xFF0F766E), 'Highveld Plateau'),
      _KpiData('OBD-II Telemetry Unit', '${batteryPct.toStringAsFixed(0)}% Battery', Icons.battery_charging_full_rounded, const Color(0xFF16A34A), 'Alternator Charging Active'),
      _KpiData('Cellular Telemetry Uplink', signal, Icons.cell_tower_rounded, const Color(0xFF16A34A), '$signalBars/5 Bars (Econet High-Speed)'),
      _KpiData('GNSS Accuracy', '± 2.4 m', Icons.gps_fixed_rounded, const Color(0xFF2563EB), 'Galileo + GPS Dual Band'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isWide ? 2.4 : 1.75,
      ),
      itemBuilder: (ctx, i) => _KpiCard(data: kpis[i]),
    );
  }
}

class _KpiData {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color, this.sub);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: data.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(data.icon, color: data.color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(data.label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(data.value, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(data.sub, style: GoogleFonts.inter(fontSize: 10.5, color: data.color, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WAYPOINT TIMELINE
// ─────────────────────────────────────────────────────────────────────────────
class _WaypointTimeline extends StatelessWidget {
  final List<_Waypoint> waypoints;
  const _WaypointTimeline({required this.waypoints});

  @override
  Widget build(BuildContext context) {
    if (waypoints.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.alt_route_rounded, size: 36, color: Color(0xFF64748B)),
              const SizedBox(height: 8),
              Text(
                'No active corridor waypoints',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Route milestones and toll checkpoints will populate upon trip dispatch.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: List.generate(waypoints.length, (i) => _WaypointRow(waypoint: waypoints[i], isLast: i == waypoints.length - 1)),
      ),
    );
  }
}

class _WaypointRow extends StatelessWidget {
  final _Waypoint waypoint;
  final bool isLast;
  static const Color success = Color(0xFF16A34A);
  static const Color muted = Color(0xFF64748B);
  static const Color primary = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);

  const _WaypointRow({required this.waypoint, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: waypoint.reached ? success : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    waypoint.reached ? Icons.check_rounded : Icons.location_on_outlined,
                    color: waypoint.reached ? Colors.white : muted,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: waypoint.reached ? success.withOpacity(0.4) : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 14, 16, isLast ? 16 : 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(waypoint.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5, color: dark)),
                        const SizedBox(height: 2),
                        Text(
                          '${waypoint.lat.toStringAsFixed(4)}° S, ${waypoint.lon.toStringAsFixed(4)}° E • Checkpoint verified',
                          style: GoogleFonts.inter(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: waypoint.reached ? success.withOpacity(0.1) : primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      waypoint.time,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: waypoint.reached ? success : primary,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// EVENT LOG CARD
// ─────────────────────────────────────────────────────────────────────────────
class _EventLogCard extends StatelessWidget {
  final List<_TelemetryEvent> events;
  const _EventLogCard({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: events.map((e) => ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: e.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(e.icon, color: e.color, size: 16),
          ),
          title: Text(e.message, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
          trailing: Text(e.time, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        )).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _TelemetryEvent {
  final String time, message;
  final IconData icon;
  final Color color;
  const _TelemetryEvent(this.time, this.message, this.icon, this.color);
}

class _Waypoint {
  final String id, name, time;
  final bool reached;
  final double lat, lon;
  const _Waypoint(this.id, this.name, this.time, this.reached, this.lat, this.lon);
}

// ─────────────────────────────────────────────────────────────────────────────
// MAP GRID PAINTER (decorative background)
// ─────────────────────────────────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final cPaint = Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), 18, cPaint..style = PaintingStyle.stroke);
    canvas.drawLine(Offset(size.width * 0.75 - 10, size.height * 0.5), Offset(size.width * 0.75 + 10, size.height * 0.5), cPaint);
    canvas.drawLine(Offset(size.width * 0.75, size.height * 0.5 - 10), Offset(size.width * 0.75, size.height * 0.5 + 10), cPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
