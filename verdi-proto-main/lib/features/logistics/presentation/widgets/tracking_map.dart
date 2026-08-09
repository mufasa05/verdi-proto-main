import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class TrackingMap extends StatelessWidget {
  final LatLng startPoint;
  final LatLng stopPoint;
  final String startLabel;
  final String stopLabel;
  final String eta;
  final String distance;
  final double? height;

  const TrackingMap({
    super.key,
    required this.startPoint,
    required this.stopPoint,
    required this.startLabel,
    required this.stopLabel,
    required this.eta,
    required this.distance,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final midpoint = LatLng(
      (startPoint.latitude + stopPoint.latitude) / 2,
      (startPoint.longitude + stopPoint.longitude) / 2,
    );

    return Container(
      height: height ?? 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: midpoint,
                  initialZoom: 8.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.verdi.app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [startPoint, stopPoint],
                        strokeWidth: 5,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: startPoint,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: const Icon(Icons.agriculture_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                      Marker(
                        point: stopPoint,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                      Marker(
                        point: midpoint,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF10B981), width: 3),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                          child: const Icon(Icons.local_shipping, color: Color(0xFF10B981), size: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Tactical Live Bar Overlay
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS TELEMETRY • SADC CORRIDOR ALPHA',
                        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '78 km/h',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Route Start & Stop Badges
            Positioned(
              top: 54,
              left: 12,
              child: _RouteBadge(label: 'Farm: $startLabel', icon: Icons.grass, color: Colors.blue.shade600),
            ),
            Positioned(
              top: 88,
              left: 12,
              child: _RouteBadge(label: 'Market: $stopLabel', icon: Icons.store, color: Colors.redAccent),
            ),

            // Bottom Telemetry Summary Card
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _RouteSummaryCard(eta: eta, distance: distance, stopLabel: stopLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _RouteBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final String eta;
  final String distance;
  final String stopLabel;

  const _RouteSummaryCard({
    required this.eta,
    required this.distance,
    required this.stopLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_outlined, color: Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Route ETA: $eta',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Destination: $stopLabel • $distance remaining',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ON TRACK',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}