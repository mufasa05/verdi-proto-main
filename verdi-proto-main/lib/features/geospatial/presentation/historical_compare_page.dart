import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../providers/geospatial_providers.dart';

class HistoricalComparePage extends ConsumerStatefulWidget {
  const HistoricalComparePage({super.key});

  @override
  ConsumerState<HistoricalComparePage> createState() => _HistoricalComparePageState();
}

class _HistoricalComparePageState extends ConsumerState<HistoricalComparePage> {
  final MapController _mapControllerLeft = MapController();
  final MapController _mapControllerRight = MapController();

  String _layerLeft = 'NDVI Crop Health';
  String _layerRight = 'Satellite Imagery';

  final List<String> _layers = const [
    'Satellite Imagery',
    'NDVI Crop Health',
    'Soil Moisture',
    'Terrain Elevation',
    'Weather Radar',
  ];

  String _getTileUrl(String layerName) {
    return switch (layerName) {
      'Satellite Imagery' => 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      'Terrain Elevation' => 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
      _ => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(geoFieldsProvider);

    // Build polygon overlays based on layer type
    List<Polygon> getPolygons(String layerName) {
      return fields.map((f) {
        Color fill = Colors.transparent;
        if (layerName == 'NDVI Crop Health') {
          fill = f.healthScore >= 0.8
              ? const Color(0xFF22C55E).withOpacity(0.6)
              : f.healthScore >= 0.6
                  ? const Color(0xFFF97316).withOpacity(0.6)
                  : const Color(0xFFEF4444).withOpacity(0.6);
        } else if (layerName == 'Soil Moisture') {
          fill = Colors.brown.withOpacity(0.5);
        }
        return Polygon(
          points: f.boundary,
          color: fill,
          borderColor: const Color(0xFF16A34A),
          borderStrokeWidth: 2,
        );
      }).toList();
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final leftMapWidget = Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _layerLeft,
              items: _layers.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _layerLeft = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapControllerLeft,
              options: MapOptions(
                initialCenter: LatLng(-19.5, 30.5),
                initialZoom: 7.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    _mapControllerRight.move(position.center, position.zoom);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _getTileUrl(_layerLeft),
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolygonLayer(polygons: getPolygons(_layerLeft)),
              ],
            ),
          ),
        ),
      ],
    );

    final rightMapWidget = Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _layerRight,
              items: _layers.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _layerRight = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapControllerRight,
              options: MapOptions(
                initialCenter: LatLng(-19.5, 30.5),
                initialZoom: 7.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    _mapControllerLeft.move(position.center, position.zoom);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _getTileUrl(_layerRight),
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolygonLayer(polygons: getPolygons(_layerRight)),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical & Layer Compare'),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Synchronized Split-Screen View',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pan or zoom either viewport to inspect crop fluctuations and environmental changes side-by-side.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(child: leftMapWidget),
                          const SizedBox(width: 16),
                          Expanded(child: rightMapWidget),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: leftMapWidget),
                          const SizedBox(height: 16),
                          Expanded(child: rightMapWidget),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
