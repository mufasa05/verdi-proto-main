import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../state/app_state.dart';
import '../models/geospatial_models.dart';
import '../providers/geospatial_providers.dart';

class ZoneEditorPage extends ConsumerStatefulWidget {
  final String fieldId;

  const ZoneEditorPage({super.key, required this.fieldId});

  @override
  ConsumerState<ZoneEditorPage> createState() => _ZoneEditorPageState();
}

class _ZoneEditorPageState extends ConsumerState<ZoneEditorPage> {
  final MapController _mapController = MapController();
  final List<LatLng> _drawnPoints = [];

  LatLng _getPolygonCenter(List<LatLng> points) {
    double latSum = 0;
    double lngSum = 0;
    for (final p in points) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }

  void _saveZoneDialog() {
    if (_drawnPoints.length < 3) return;

    final nameController = TextEditingController(text: 'Subzone ${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}');
    final cropController = TextEditingController(text: 'Maize');
    final irrigationController = TextEditingController(text: '10mm / 24h');
    final treatmentController = TextEditingController(text: 'NPK Fertilizer');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Save Management Zone'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Zone Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cropController,
                  decoration: const InputDecoration(labelText: 'Sub-crop variety'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: irrigationController,
                  decoration: const InputDecoration(labelText: 'Irrigation Target'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: treatmentController,
                  decoration: const InputDecoration(labelText: 'Treatment Protocol'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final newZone = GeoZone(
                  id: 'ZN-${DateTime.now().millisecondsSinceEpoch}',
                  fieldId: widget.fieldId,
                  name: name,
                  boundary: List.from(_drawnPoints),
                  cropType: cropController.text.trim(),
                  irrigationRule: irrigationController.text.trim(),
                  treatmentRule: treatmentController.text.trim(),
                );

                ref.read(geoZonesProvider.notifier).addZone(newZone);
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // pop screen back to map
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save Zone'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(geoFieldsProvider);
    if (fields.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zone Editor')),
        body: const Center(child: Text('No mapped farm fields available.')),
      );
    }
    final field = fields.firstWhere((f) => f.id == widget.fieldId, orElse: () => fields.first);
    final fieldCenter = _getPolygonCenter(field.boundary);
    final isAdmin = ref.watch(appStateProvider).role == UserRole.admin;

    // Build the visual drawing polygon and handle markers
    final polygons = <Polygon>[
      // Field bounds (base reference in transparent gray)
      Polygon(
        points: field.boundary,
        color: Colors.black.withOpacity(0.04),
        borderColor: Colors.black26,
        borderStrokeWidth: 1.5,
        isFilled: true,
      ),
    ];

    if (_drawnPoints.length >= 3) {
      polygons.add(
        Polygon(
          points: _drawnPoints,
          color: const Color(0xFF3B82F6).withOpacity(0.25),
          borderColor: const Color(0xFF2563EB),
          borderStrokeWidth: 3.0,
          isFilled: true,
        ),
      );
    }

    final polylines = <Polyline>[];
    if (_drawnPoints.length >= 2) {
      polylines.add(
        Polyline(
          points: _drawnPoints,
          strokeWidth: 3.0,
          color: const Color(0xFF2563EB),
        ),
      );
    }

    final markers = <Marker>[];
    for (int i = 0; i < _drawnPoints.length; i++) {
      final point = _drawnPoints[i];
      markers.add(
        Marker(
          point: point,
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Zones: ${field.name}'),
        actions: [
          IconButton(
            onPressed: !isAdmin
                ? () {}
                : () {
                    setState(() {
                      _drawnPoints.clear();
                    });
                  },
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Vertices',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Draw Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: fieldCenter,
                initialZoom: 14.5,
                onTap: (tapPos, point) {
                  if (!isAdmin) {
                    return;
                  }
                  setState(() {
                    _drawnPoints.add(point);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolygonLayer(polygons: polygons),
                PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),
          ),

          if (!isAdmin)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.orange.shade800,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: const Center(
                  child: Text(
                    'READ-ONLY MODE (Privileged data modification restricted to Admins)',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),

          // 2. HUD Drawing Guidance Overlay
          Positioned(
            top: isAdmin ? 16 : 38,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _drawnPoints.length < 3
                          ? 'Tap the map inside the field bounds to place at least 3 vertices.'
                          : 'Polygon closed. Tap more points to refine, or click Save Zone.',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Save / Reset buttons
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _drawnPoints.isEmpty
                        ? null
                        : () => setState(() => _drawnPoints.clear()),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset Points'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _drawnPoints.length >= 3 ? _saveZoneDialog : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Zone'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
