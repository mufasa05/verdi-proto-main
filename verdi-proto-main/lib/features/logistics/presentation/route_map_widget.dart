import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RouteMapWidget extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final String truckLabel;
  final String statusText;
  final String etaText;
  final String distanceLeftText;
  final bool useLiveLocation;

  const RouteMapWidget({
    super.key,
    required this.origin,
    required this.destination,
    required this.truckLabel,
    required this.statusText,
    required this.etaText,
    required this.distanceLeftText,
    this.useLiveLocation = true,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;
  LatLng? _truckPosition;
  int _step = 0;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _truckPosition = widget.origin;
    _initLocationTracking();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
  }

  @override
  void didUpdateWidget(covariant RouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin || oldWidget.destination != widget.destination) {
      _truckPosition = widget.origin;
      _step = 0;
      _restartTracking();
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
    if (widget.useLiveLocation) {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _startFallbackSimulation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _startFallbackSimulation();
        return;
      }

      const settings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      );

      _positionSub = Geolocator.getPositionStream(locationSettings: settings).listen(
        (position) {
          if (!mounted) return;
          setState(() {
            _truckPosition = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_truckPosition!, _mapController.camera.zoom);
        },
      );
    } else {
      _startFallbackSimulation();
    }
  }

  void _restartTracking() {
    _positionSub?.cancel();
    _fallbackTimer?.cancel();
    _initLocationTracking();
  }

  void _startFallbackSimulation() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _advanceTruck();
    });
  }

  void _fitBounds() {
    final points = <LatLng>[
      widget.origin,
      widget.destination,
      ?_truckPosition,
    ];

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  void _advanceTruck() {
    final totalSteps = 40;
    if (_step >= totalSteps || !mounted) return;

    setState(() {
      _step++;
      final t = _step / totalSteps;
      _truckPosition = LatLng(
        _lerp(widget.origin.latitude, widget.destination.latitude, t),
        _lerp(widget.origin.longitude, widget.destination.longitude, t),
      );
    });

    _mapController.move(_truckPosition!, _mapController.camera.zoom);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final truck = _truckPosition ?? widget.origin;
    final route = <LatLng>[widget.origin, truck, widget.destination];

    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialZoom: 10,
              minZoom: 4,
              maxZoom: 18,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.verdi',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route,
                    strokeWidth: 4,
                    color: Colors.green,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  _buildMarker(
                    point: widget.origin,
                    color: Colors.blue,
                    icon: Icons.storefront_outlined,
                    label: 'Origin',
                  ),
                  _buildMarker(
                    point: widget.destination,
                    color: Colors.red,
                    icon: Icons.flag_outlined,
                    label: 'Destination',
                  ),
                  _buildMarker(
                    point: truck,
                    color: Colors.green,
                    icon: Icons.local_shipping_outlined,
                    label: widget.truckLabel,
                    pulse: true,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            top: 16,
            child: _MapInfoCard(
              statusText: widget.statusText,
              etaText: widget.etaText,
              distanceLeftText: widget.distanceLeftText,
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
    required String label,
    bool pulse = false,
  }) {
    return Marker(
      point: point,
      width: pulse ? 70 : 58,
      height: pulse ? 70 : 58,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse)
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.20),
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.35),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapInfoCard extends StatelessWidget {
  final String statusText;
  final String etaText;
  final String distanceLeftText;

  const _MapInfoCard({
    required this.statusText,
    required this.etaText,
    required this.distanceLeftText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(statusText, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('ETA: $etaText'),
          const SizedBox(height: 4),
          Text('Remaining: $distanceLeftText'),
        ],
      ),
    );
  }
}