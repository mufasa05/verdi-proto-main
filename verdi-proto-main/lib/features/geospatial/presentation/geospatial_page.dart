import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../state/app_state.dart';
import '../models/geospatial_models.dart';
import '../providers/geospatial_providers.dart';
import '../widgets/layer_chip_row.dart';
import '../widgets/map_header.dart';
import '../widgets/field_card.dart';
import 'field_detail_map_page.dart';
import 'zone_editor_page.dart';
import 'scouting_tasks_page.dart';
import 'layer_manager_page.dart';
import 'historical_compare_page.dart';

class GeospatialPage extends ConsumerStatefulWidget {
  const GeospatialPage({super.key});

  @override
  ConsumerState<GeospatialPage> createState() => _GeospatialPageState();
}

class _GeospatialPageState extends ConsumerState<GeospatialPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All Regions';
  String _selectedCrop = 'All Crops';
  bool _pinDropMode = false;
  bool _measureMode = false;
  final List<LatLng> _measuredPoints = [];
  bool _isAiScanning = false;
  LatLng? _userLocation;
  bool _isFetchingGps = false;
  IrrigationScheme? _selectedScheme;

  Future<LatLng?> _fetchDeviceGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LatLng(-17.8214, 31.0489);
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LatLng(-17.8214, 31.0489);
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return const LatLng(-17.8214, 31.0489);
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return const LatLng(-17.8214, 31.0489);
    }
  }

  Future<void> _centerOnUserLocation() async {
    setState(() => _isFetchingGps = true);
    final pos = await _fetchDeviceGpsLocation();
    if (pos != null && mounted) {
      setState(() {
        _userLocation = pos;
        _isFetchingGps = false;
      });
      _mapController.move(pos, 15.0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎯 Map centered on current device GPS: Lat ${pos.latitude.toStringAsFixed(4)}°, Lng ${pos.longitude.toStringAsFixed(4)}°'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } else {
      if (mounted) setState(() => _isFetchingGps = false);
    }
  }

  void _showCoordinatesDialog() {
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedSaveType = 'FlyTo';
    bool fetchingInModal = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.explore_outlined, color: Color(0xFF16A34A), size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'GPS Coordinates Navigator & Reader',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input custom Latitude & Longitude or read live device GPS location.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),

                  // Detect Device GPS Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: fetchingInModal
                          ? null
                          : () async {
                              setModalState(() => fetchingInModal = true);
                              final pos = await _fetchDeviceGpsLocation();
                              if (pos != null) {
                                latController.text = pos.latitude.toStringAsFixed(5);
                                lngController.text = pos.longitude.toStringAsFixed(5);
                                setState(() => _userLocation = pos);
                              }
                              setModalState(() => fetchingInModal = false);
                            },
                      icon: fetchingInModal
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location_rounded, color: Color(0xFF16A34A), size: 18),
                      label: Text(fetchingInModal ? 'Reading Device GPS...' : '🎯 Detect My Live Device GPS Location'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: 'Latitude (°)',
                      hintText: 'e.g. -17.8214',
                      prefixIcon: const Icon(Icons.navigation_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final d = double.tryParse(v);
                      if (d == null || d < -90 || d > 90) return 'Enter valid Lat (-90 to 90)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: 'Longitude (°)',
                      hintText: 'e.g. 31.0489',
                      prefixIcon: const Icon(Icons.navigation_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final d = double.tryParse(v);
                      if (d == null || d < -180 || d > 180) return 'Enter valid Lng (-180 to 180)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: selectedSaveType,
                    decoration: InputDecoration(
                      labelText: 'Action / Save As',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'FlyTo', child: Text('Fly Map Camera to Location')),
                      DropdownMenuItem(value: 'Pin', child: Text('Save as Scouting Pin')),
                      DropdownMenuItem(value: 'Field', child: Text('Create Field Boundary at Coords')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedSaveType = v);
                    },
                  ),
                  if (selectedSaveType != 'FlyTo') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: selectedSaveType == 'Pin' ? 'Scouting Note / Label' : 'Field Plot Name',
                        hintText: 'e.g. South Quadrant Anomaly',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final lat = double.parse(latController.text.trim());
                  final lng = double.parse(lngController.text.trim());
                  final point = LatLng(lat, lng);

                  _mapController.move(point, 14.5);

                  final name = nameController.text.trim();
                  if (selectedSaveType == 'Pin') {
                    final newObs = GeoObservation(
                      id: 'OBS-${DateTime.now().millisecondsSinceEpoch}',
                      fieldId: ref.read(selectedFieldIdProvider) ?? 'FLD-01',
                      position: point,
                      title: name.isNotEmpty ? name : 'GPS Coordinate Pin',
                      issueType: 'Other',
                      severity: 'Low',
                      notes: 'Manual GPS input: ($lat, $lng)',
                      date: 'Just now',
                    );
                    ref.read(geoObservationsProvider.notifier).addObservation(newObs);
                  } else if (selectedSaveType == 'Field') {
                    final newField = GeoField(
                      id: 'FLD-${DateTime.now().millisecondsSinceEpoch}',
                      farmId: 'FRM-01',
                      name: name.isNotEmpty ? name : 'Custom GPS Field',
                      boundary: [
                        LatLng(lat + 0.004, lng - 0.004),
                        LatLng(lat + 0.004, lng + 0.004),
                        LatLng(lat - 0.004, lng + 0.004),
                        LatLng(lat - 0.004, lng - 0.004),
                      ],
                      hectares: 18.5,
                      crop: 'Maize',
                      healthScore: 0.82,
                      status: 'Healthy',
                      lastScoutDate: 'Just added',
                    );
                    ref.read(geoFieldsProvider.notifier).addField(newField);
                    ref.read(selectedFieldIdProvider.notifier).select(newField.id);
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📍 Map centered on ($lat, $lng)'),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.near_me_rounded, size: 16),
              label: const Text('Go to Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalDistanceKm() {
    if (_measuredPoints.length < 2) return 0.0;
    const Distance dist = Distance();
    double totalMeters = 0.0;
    for (int i = 0; i < _measuredPoints.length - 1; i++) {
      totalMeters += dist.as(LengthUnit.Meter, _measuredPoints[i], _measuredPoints[i + 1]);
    }
    if (_measuredPoints.length >= 3) {
      totalMeters += dist.as(LengthUnit.Meter, _measuredPoints.last, _measuredPoints.first);
    }
    return totalMeters / 1000.0;
  }

  double _calculateAreaHectares() {
    if (_measuredPoints.length < 3) return 0.0;
    double area = 0.0;
    final int n = _measuredPoints.length;
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final lat1 = _measuredPoints[i].latitude * (pi / 180.0);
      final lat2 = _measuredPoints[j].latitude * (pi / 180.0);
      final lng1 = _measuredPoints[i].longitude * (pi / 180.0);
      final lng2 = _measuredPoints[j].longitude * (pi / 180.0);
      area += (lng2 - lng1) * (2 + sin(lat1) + sin(lat2));
    }
    area = (area * 6378137.0 * 6378137.0 / 2.0).abs();
    return area / 10000.0;
  }

  Future<void> _runAiSpatialAnomalyScan() async {
    setState(() => _isAiScanning = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    final fields = ref.read(geoFieldsProvider);
    final selectedId = ref.read(selectedFieldIdProvider);
    final targetField = fields.firstWhere((f) => f.id == selectedId, orElse: () => fields.first);

    final anomalyObs = GeoObservation(
      id: 'OBS-AI-${DateTime.now().millisecondsSinceEpoch}',
      fieldId: targetField.id,
      position: targetField.boundary.first,
      title: 'AI Spatial Anomaly: Transpiration Vector',
      issueType: 'Water',
      severity: 'High',
      notes: 'Verdi AI Spatial ML Engine detected severe canopy temperature elevation (+3.4°C) in northern quadrant.',
      date: 'Just now (AI Scan)',
    );

    ref.read(geoObservationsProvider.notifier).addObservation(anomalyObs);
    _mapController.move(targetField.boundary.first, 14.5);

    setState(() => _isAiScanning = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🤖 AI Spatial Anomaly Scan Complete! High-stress vector detected in ${targetField.name}.'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  void _showZonalStatisticsDialog(GeoField field) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF16A34A), size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zonal Statistics & Spectral Histogram',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Field: ${field.name} (${field.crop} • ${field.hectares} Ha)',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text('Canopy Health (NDVI) Zonal Distribution:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  _ZonalBar(label: 'High Vigour (>0.80 NDVI)', percent: 0.68, color: Colors.green, valText: '68% of plot (Optimal)'),
                  const SizedBox(height: 8),
                  _ZonalBar(label: 'Moderate Vigour (0.60 - 0.80)', percent: 0.24, color: Colors.amber, valText: '24% of plot (Stable)'),
                  const SizedBox(height: 8),
                  _ZonalBar(label: 'Water/Pest Stress (<0.60)', percent: 0.08, color: Colors.red, valText: '8% of plot (Action Req.)'),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _ZonalStatBox(title: 'Soil Organic Matter', value: '3.8%', subtitle: 'Optimal Carbon')),
                      const SizedBox(width: 10),
                      Expanded(child: _ZonalStatBox(title: 'Moisture Retention', value: '64%', subtitle: 'Root-zone 45cm')),
                      const SizedBox(width: 10),
                      Expanded(child: _ZonalStatBox(title: 'Chlorophyll Content', value: '74.2 µg/cm²', subtitle: 'High Photosynthesis')),
                    ],
                  ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📄 Zonal statistics report for ${field.name} exported!'),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export Zonal Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                      ),
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

  void _showSatelliteExportDialog(GeoField field) {
    String selectedBand = 'NDVI Band 8 (NIR - Vegetation Index)';
    String format = 'GeoTIFF (32-bit Floating Point)';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.satellite_alt_outlined, color: Color(0xFF16A34A), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Export Multispectral GeoTIFF Band Data',
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
                Text(
                  'Select raw satellite spectral band telemetry for spatial GIS software (QGIS / ArcGIS / ERDAS).',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Text('Target Field:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('${field.name} (${field.hectares} Hectares)', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A))),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedBand,
                  decoration: InputDecoration(
                    labelText: 'Spectral Band Layer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'NDVI Band 8 (NIR - Vegetation Index)', child: Text('NDVI Band 8 (NIR - Vegetation Index)')),
                    DropdownMenuItem(value: 'NDWI Band 11 (SWIR - Moisture Index)', child: Text('NDWI Band 11 (SWIR - Moisture Index)')),
                    DropdownMenuItem(value: 'RGB True Color (10m Resolution)', child: Text('RGB True Color (10m Resolution)')),
                    DropdownMenuItem(value: 'Thermal Infrared (TIR Band 10)', child: Text('Thermal Infrared (TIR Band 10)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedBand = v);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: format,
                  decoration: InputDecoration(
                    labelText: 'Export Format',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'GeoTIFF (32-bit Floating Point)', child: Text('GeoTIFF (32-bit Floating Point)')),
                    DropdownMenuItem(value: 'Shapefile (.shp / .prj zip)', child: Text('ESRI Shapefile (.shp)')),
                    DropdownMenuItem(value: 'GeoJSON Vector Layer', child: Text('GeoJSON Vector Layer')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => format = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🛰️ GeoTIFF Data for ${field.name} ($selectedBand) downloaded to your Downloads folder!'),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Download GeoTIFF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> _regions = const [
    'All Regions',
    'Masvingo',
    'Chiredzi',
    'Mutare',
    'Harare',
    'Gwanda',
  ];
  final List<String> _crops = const [
    'All Crops',
    'Maize',
    'Tomatoes',
    'Potatoes',
    'Cabbages',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  void _showAddPinDialog(LatLng point, String fieldId) {
    if (ref.read(appStateProvider).role != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Read-Only Mode: Dropping scouting pins requires Administrator clearance.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'Pest';
    String selectedSeverity = 'Medium';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('New Scouting Pin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Issue Title',
                        hintText: 'e.g. Locust sighting',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Issue Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pest',
                          child: Text('Pest / Insect'),
                        ),
                        DropdownMenuItem(
                          value: 'Disease',
                          child: Text('Crop Disease'),
                        ),
                        DropdownMenuItem(
                          value: 'Water',
                          child: Text('Water / Irrigation'),
                        ),
                        DropdownMenuItem(
                          value: 'Weed',
                          child: Text('Weeds / Growth'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSeverity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedSeverity = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Describe details for the scouting team...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final newObs = GeoObservation(
                      id: 'OBS-${DateTime.now().millisecondsSinceEpoch}',
                      fieldId: fieldId,
                      position: point,
                      title: title,
                      issueType: selectedType,
                      severity: selectedSeverity,
                      notes: notesController.text.trim(),
                      date:
                          'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    );

                    ref
                        .read(geoObservationsProvider.notifier)
                        .addObservation(newObs);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Drop Pin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(geoFieldsProvider);
    final observations = ref.watch(geoObservationsProvider);
    final tasks = ref.watch(geoTasksProvider);
    final settings = ref.watch(geoLayerSettingsProvider);
    final selectedFieldId = ref.watch(selectedFieldIdProvider);
    final schemes = ref.watch(irrigationSchemesProvider);
    final appState = ref.watch(appStateProvider);
    final isAdmin = appState.role == UserRole.admin;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    // Filters
    final searchText = _searchController.text.toLowerCase();
    final filteredFields = fields.where((f) {
      final matchesSearch =
          f.name.toLowerCase().contains(searchText) ||
          f.crop.toLowerCase().contains(searchText);
      final matchesRegion =
          _selectedRegion == 'All Regions' ||
          f.name.contains(_selectedRegion) ||
          _selectedRegion.toLowerCase() == 'gwanda' &&
              f.id == 'FLD-04'; // mock logic to align regional centers
      final matchesCrop =
          _selectedCrop == 'All Crops' || f.crop == _selectedCrop;
      return matchesSearch && matchesRegion && matchesCrop;
    }).toList();

    final selectedField = fields.firstWhere(
      (f) => f.id == selectedFieldId,
      orElse: () => fields.first,
    );

    // Compute center stats
    final totalFields = filteredFields.length;
    final avgHealth = totalFields > 0
        ? filteredFields.map((e) => e.healthScore).reduce((a, b) => a + b) /
              totalFields
        : 0.0;

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Header with search & filter dropdowns
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: MapHeader(
                  searchController: _searchController,
                  onSearchChanged: (v) => setState(() {}),
                  selectedRegion: _selectedRegion,
                  regions: _regions,
                  onRegionChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedRegion = v);
                    }
                  },
                  selectedCrop: _selectedCrop,
                  crops: _crops,
                  onCropChanged: (v) {
                    if (v != null) setState(() => _selectedCrop = v);
                  },
                  totalFields: totalFields,
                  avgHealth: avgHealth,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Interactive Map Access Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeospatialMapFullScreenPage(
                              initialRegion: _selectedRegion,
                              initialCrop: _selectedCrop,
                              initialSearchText: _searchController.text,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.map_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Open Interactive Map',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'View field boundaries, NDVI crop health overlays, and active scouting pins.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filtered Fields',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  totalFields.toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Average NDVI Health',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(avgHealth * 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Fields List Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Field Registry',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (isAdmin)
                          IconButton(
                            onPressed: _showCoordinatesDialog,
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF16A34A)),
                            tooltip: 'Add Field / Pin',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (filteredFields.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No fields match your search filters.',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...filteredFields.map((field) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FieldCard(
                            field: field,
                            onViewDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FieldDetailMapPage(fieldId: field.id),
                                ),
                              );
                            },
                            onEditZones: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ZoneEditorPage(fieldId: field.id),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tile template selection
    final tileUrl = settings.showSatellite
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
        : settings.showTerrain
        ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    // Map Polygons mapping
    final polygons = filteredFields.map((f) {
      Color fill = const Color(0xFF16A34A).withOpacity(0.15);
      if (settings.showNdvi) {
        fill = f.healthScore >= 0.8
            ? const Color(0xFF22C55E).withOpacity(settings.opacityNdvi)
            : f.healthScore >= 0.6
            ? const Color(0xFFF97316).withOpacity(settings.opacityNdvi)
            : const Color(0xFFEF4444).withOpacity(settings.opacityNdvi);
      } else if (settings.showSoil) {
        fill = Colors.brown.withOpacity(settings.opacitySoil);
      }

      return Polygon(
        points: f.boundary,
        color: fill,
        borderColor: selectedFieldId == f.id
            ? Colors.yellow
            : const Color(0xFF16A34A),
        borderStrokeWidth: selectedFieldId == f.id ? 4 : 2,
        isFilled: true,
      );
    }).toList();

    if (settings.showIrrigation) {
      for (final s in schemes) {
        polygons.add(
          Polygon(
            points: s.boundary,
            color: Colors.blue.withOpacity(0.12),
            borderColor: Colors.blue.shade600,
            borderStrokeWidth: 2.5,
            isFilled: true,
          ),
        );
      }
    }

    // Irrigation layer polylines (mock layout pipes)
    final polylines = <Polyline>[];
    if (settings.showIrrigation) {
      polylines.add(
        Polyline(
          points: [
            LatLng(-17.80, 31.04),
            LatLng(-17.81, 31.045),
            LatLng(-17.82, 31.05),
          ],
          strokeWidth: 3.5,
          color: Colors.blue.shade400,
        ),
      );
      polylines.add(
        Polyline(
          points: [LatLng(-21.04, 31.66), LatLng(-21.05, 31.67)],
          strokeWidth: 3.5,
          color: Colors.blue.shade400,
        ),
      );
    }

    // Weather radar mock layers
    final circles = <CircleMarker>[];
    if (settings.showWeather) {
      circles.add(
        CircleMarker(
          point: LatLng(-17.81, 31.05),
          radius: 80,
          useRadiusInMeter: false,
          color: Colors.purple.withOpacity(settings.opacityWeather * 0.4),
          borderColor: Colors.purple.withOpacity(settings.opacityWeather),
          borderStrokeWidth: 1.5,
        ),
      );
      circles.add(
        CircleMarker(
          point: LatLng(-20.93, 29.00),
          radius: 120,
          useRadiusInMeter: false,
          color: Colors.blue.withOpacity(settings.opacityWeather * 0.3),
          borderColor: Colors.blue.withOpacity(settings.opacityWeather),
          borderStrokeWidth: 1.5,
        ),
      );
    }

    // Map Markers mapping
    final markers = <Marker>[];
    for (final obs in observations) {
      final severityColor = obs.severity == 'High'
          ? Colors.red
          : obs.severity == 'Medium'
          ? Colors.orange
          : Colors.blue;
      markers.add(
        Marker(
          point: obs.position,
          width: 38,
          height: 38,
          child: GestureDetector(
            onTap: () {
              ref.read(selectedFieldIdProvider.notifier).select(obs.fieldId);
              _mapController.move(obs.position, 14);
            },
            child: Tooltip(
              message: obs.title,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: severityColor, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Icon(
                  obs.issueType == 'Pest'
                      ? Icons.bug_report
                      : obs.issueType == 'Water'
                      ? Icons.water_drop
                      : obs.issueType == 'Disease'
                      ? Icons.coronavirus
                      : Icons.warning,
                  color: severityColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (settings.showIrrigation) {
      for (final s in schemes) {
        markers.add(
          Marker(
            point: s.position,
            width: 42,
            height: 42,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedScheme = s;
                });
                _mapController.move(s.position, 12);
              },
              child: Tooltip(
                message: '${s.name} (${s.crop})',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade600, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    Icons.shower,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Task markers mapping
    for (final task in tasks) {
      if (task.position != null) {
        markers.add(
          Marker(
            point: task.position!,
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () {
                ref.read(selectedFieldIdProvider.notifier).select(task.fieldId);
                _mapController.move(task.position!, 14);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Task: ${task.title} - Assignee: ${task.assignee}',
                    ),
                    action: SnackBarAction(
                      label: 'Complete',
                      onPressed: () => ref
                          .read(geoTasksProvider.notifier)
                          .toggleTaskStatus(task.id),
                    ),
                  ),
                );
              },
              child: Tooltip(
                message: task.title,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Full-screen Interactive map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(-19.5, 30.5),
                initialZoom: 7.0,
                onTap: (tapPosition, point) {
                  if (_measureMode) {
                    setState(() {
                      _measuredPoints.add(point);
                    });
                  } else if (_pinDropMode) {
                    setState(() => _pinDropMode = false);
                    _showAddPinDialog(point, selectedFieldId ?? 'FLD-01');
                  } else {
                    // Click detection within field bounds
                    for (final field in fields) {
                      if (_isPointInPolygon(point, field.boundary)) {
                        ref
                            .read(selectedFieldIdProvider.notifier)
                            .select(field.id);
                        _mapController.move(point, 13.5);
                        return;
                      }
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolygonLayer(polygons: polygons),
                PolylineLayer(polylines: polylines),
                CircleLayer(circles: circles),
                MarkerLayer(markers: markers),
                if (_measuredPoints.isNotEmpty) ...[
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _measuredPoints.length >= 3 ? [..._measuredPoints, _measuredPoints.first] : _measuredPoints,
                        color: const Color(0xFF16A34A),
                        strokeWidth: 3.5,
                      ),
                    ],
                  ),
                  if (_measuredPoints.length >= 3)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: _measuredPoints,
                          color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                          borderColor: const Color(0xFF16A34A),
                          borderStrokeWidth: 2,
                          isFilled: true,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: List.generate(_measuredPoints.length, (idx) {
                      return Marker(
                        point: _measuredPoints[idx],
                        width: 28,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation!,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: const Center(
                            child: Icon(Icons.my_location_rounded, color: Colors.blue, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                child: const Center(
                  child: Text(
                    'READ-ONLY MODE (Privileged data modification restricted to Admins)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

          // 2. Map HUD controls (Top layer)
          Positioned(
            top: isAdmin ? 16 : 38,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row
                MapHeader(
                  searchController: _searchController,
                  onSearchChanged: (v) => setState(() {}),
                  selectedRegion: _selectedRegion,
                  regions: _regions,
                  onRegionChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedRegion = v);
                      // Focus map to region center
                      final center = switch (v.toLowerCase()) {
                        'harare' => LatLng(-17.82, 31.05),
                        'masvingo' => LatLng(-20.06, 30.83),
                        'chiredzi' => LatLng(-21.05, 31.67),
                        'mutare' => LatLng(-18.97, 32.67),
                        'gwanda' => LatLng(-20.93, 29.00),
                        _ => LatLng(-19.5, 30.5),
                      };
                      _mapController.move(
                        center,
                        v == 'All Regions' ? 7.0 : 11.5,
                      );
                    }
                  },
                  selectedCrop: _selectedCrop,
                  crops: _crops,
                  onCropChanged: (v) {
                    if (v != null) setState(() => _selectedCrop = v);
                  },
                  totalFields: totalFields,
                  avgHealth: avgHealth,
                ),
                const SizedBox(height: 10),

                // Map Layers selection chips
                const LayerChipRow(),
              ],
            ),
          ),

          // 3. Side Actions / Screen Router (Top Right controls)
          Positioned(
            top: isAdmin ? 156 : 178,
            right: 16,
            child: Column(
              children: [
                _roundHudButton(
                  icon: _isFetchingGps ? Icons.sync : Icons.my_location_rounded,
                  tooltip: 'Read Live Device GPS & Center Map',
                  color: _userLocation != null ? Colors.blue.shade600 : Colors.white,
                  iconColor: _userLocation != null ? Colors.white : Colors.blue.shade600,
                  onTap: _centerOnUserLocation,
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.explore_outlined,
                  tooltip: 'Pinpoint Location by Coordinates',
                  onTap: _showCoordinatesDialog,
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.square_foot_outlined,
                  tooltip: _measureMode ? 'Cancel Measurement' : 'Measure GIS Distance & Area',
                  color: _measureMode ? const Color(0xFF16A34A) : Colors.white,
                  iconColor: _measureMode ? Colors.white : const Color(0xFF475569),
                  onTap: () {
                    setState(() {
                      _measureMode = !_measureMode;
                      if (!_measureMode) _measuredPoints.clear();
                    });
                  },
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.bar_chart_rounded,
                  tooltip: 'Zonal Health Histogram & Stats',
                  onTap: () => _showZonalStatisticsDialog(selectedField),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.psychology_rounded,
                  tooltip: _isAiScanning ? 'Scanning...' : 'AI Spatial Anomaly Auto-Detect',
                  color: _isAiScanning ? Colors.purple.shade600 : Colors.white,
                  iconColor: _isAiScanning ? Colors.white : Colors.purple.shade600,
                  onTap: _isAiScanning ? () {} : _runAiSpatialAnomalyScan,
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.cloud_download_outlined,
                  tooltip: 'Export Satellite GeoTIFF Band Data',
                  onTap: () => _showSatelliteExportDialog(selectedField),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.layers_outlined,
                  tooltip: 'Layer Settings Manager',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LayerManagerPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.compare_outlined,
                  tooltip: 'Compare Seasons Side-by-Side',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoricalComparePage(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.assignment_turned_in_outlined,
                  tooltip: 'Scouting Task Center',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScoutingTasksPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.pin_drop,
                  tooltip: _pinDropMode
                      ? 'Tap Map to Drop Pin (Active)'
                      : 'Drop Scouting Pin',
                  color: _pinDropMode ? Colors.orange.shade700 : Colors.white,
                  iconColor: _pinDropMode ? Colors.white : Colors.blue.shade600,
                  onTap: () {
                    setState(() => _pinDropMode = !_pinDropMode);
                  },
                ),
              ],
            ),
          ),

          // 4. Floating Measurement HUD Banner
          if (_measureMode || _measuredPoints.isNotEmpty)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.straighten_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GIS Measurement Tool (Active)',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Perimeter: ${_calculateTotalDistanceKm().toStringAsFixed(2)} km  •  Area: ${_calculateAreaHectares().toStringAsFixed(1)} Ha (${(_calculateAreaHectares() * 2.471).toStringAsFixed(1)} Acres)',
                            style: GoogleFonts.inter(color: Colors.grey.shade300, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _measuredPoints.clear());
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _measureMode = false;
                        });
                        _showCoordinatesDialog();
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Save as Field'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Focus Card Overlay (Bottom sheet widget)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    final center = _mapController.camera.center;
                    _showAddPinDialog(center, selectedField.id);
                  },
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add Observation Pin'),
                ),
                const SizedBox(height: 10),
                if (settings.showIrrigation && _selectedScheme != null)
                  _SchemeCard(
                    scheme: _selectedScheme!,
                    onClose: () => setState(() => _selectedScheme = null),
                  )
                else
                  FieldCard(
                    field: selectedField,
                    onViewDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FieldDetailMapPage(fieldId: selectedField.id),
                        ),
                      );
                    },
                    onEditZones: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ZoneEditorPage(fieldId: selectedField.id),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundHudButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color iconColor = const Color(0xFF475569),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor),
        tooltip: tooltip,
        style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
      ),
    );
  }

  // Ray casting algorithm to determine if a LatLng is inside a Polygon boundary
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i;
    int j = polygon.length - 1;
    bool inside = false;
    for (i = 0; i < polygon.length; i++) {
      if (((polygon[i].longitude < point.longitude &&
                  polygon[j].longitude >= point.longitude) ||
              (polygon[j].longitude < point.longitude &&
                  polygon[i].longitude >= point.longitude)) &&
          (polygon[i].latitude +
                  (point.longitude - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) *
                      (polygon[j].latitude - polygon[i].latitude) <
              point.latitude)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }
}

class _SchemeCard extends StatelessWidget {
  final IrrigationScheme scheme;
  final VoidCallback onClose;

  const _SchemeCard({required this.scheme, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final utilizationPct = (scheme.utilization * 100).round();
    final green = const Color(0xFF16A34A);
    final dark = const Color(0xFF0F172A);
    final muted = const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shower_outlined,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Irrigation Scheme',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  scheme.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: dark,
                  ),
                ),
              ),
              Text(
                scheme.crop,
                style: GoogleFonts.inter(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Water Utilization ($utilizationPct%)',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${scheme.waterUsed.toStringAsFixed(1)} / ${scheme.waterAllocated.toStringAsFixed(0)} m3',
                style: TextStyle(
                  fontSize: 12,
                  color: dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: scheme.utilization,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            color: Colors.blue.shade500,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Uptime',
                  value: '${(scheme.uptime * 100).round()}%',
                  icon: Icons.schedule_outlined,
                  color: green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Blocked',
                  value: '${scheme.blockedValves}',
                  icon: Icons.block_outlined,
                  color: scheme.blockedValves > 0 ? Colors.orange : muted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Alerts',
                  value: '${scheme.alerts}',
                  icon: Icons.warning_amber_outlined,
                  color: scheme.alerts > 0 ? Colors.red : muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
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

// ==========================================
// NEW: Full Screen Map Page for Mobile Views
// ==========================================

class GeospatialMapFullScreenPage extends ConsumerStatefulWidget {
  final String initialRegion;
  final String initialCrop;
  final String initialSearchText;

  const GeospatialMapFullScreenPage({
    super.key,
    required this.initialRegion,
    required this.initialCrop,
    required this.initialSearchText,
  });

  @override
  ConsumerState<GeospatialMapFullScreenPage> createState() =>
      _GeospatialMapFullScreenPageState();
}

class _GeospatialMapFullScreenPageState
    extends ConsumerState<GeospatialMapFullScreenPage> {
  late final MapController _mapController;
  late final TextEditingController _searchController;
  late String _selectedRegion;
  late String _selectedCrop;
  bool _pinDropMode = false;
  bool _showFilters = false;
  IrrigationScheme? _selectedScheme;

  final List<String> _regions = const [
    'All Regions',
    'Masvingo',
    'Chiredzi',
    'Mutare',
    'Harare',
    'Gwanda',
  ];
  final List<String> _crops = const [
    'All Crops',
    'Maize',
    'Tomatoes',
    'Potatoes',
    'Cabbages',
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController(text: widget.initialSearchText);
    _selectedRegion = widget.initialRegion;
    _selectedCrop = widget.initialCrop;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCoordinatesDialog() {
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedSaveType = 'Pin';

    final appState = ref.read(appStateProvider);
    final isAdmin = appState.role == UserRole.admin;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: const [
                  Icon(Icons.explore_outlined, color: Color(0xFF16A34A)),
                  SizedBox(width: 8),
                  Text(
                    'Pinpoint Coordinates',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enter GPS coordinates to fly the map or save a location.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: latController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          hintText: 'e.g. -17.82',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.navigation_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final d = double.tryParse(v);
                          if (d == null) return 'Invalid number';
                          if (d < -90 || d > 90) {
                            return 'Must be between -90 and 90';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lngController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          hintText: 'e.g. 31.05',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.navigation_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final d = double.tryParse(v);
                          if (d == null) return 'Invalid number';
                          if (d < -180 || d > 180) {
                            return 'Must be between -180 and 180';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Action:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (!isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Read-Only',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedSaveType,
                        decoration: InputDecoration(
                          labelText: 'Save As',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Pin',
                            child: Text('Scouting Pin'),
                          ),
                          DropdownMenuItem(
                            value: 'Field',
                            child: Text('New Field Boundary'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedSaveType = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: selectedSaveType == 'Pin'
                              ? 'Pin Label / Note'
                              : 'Field Name',
                          hintText: selectedSaveType == 'Pin'
                              ? 'e.g. GPS Waypoint'
                              : 'e.g. Custom Plot',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final lat = double.parse(latController.text.trim());
                      final lng = double.parse(lngController.text.trim());
                      final point = LatLng(lat, lng);

                      _mapController.move(point, 13.0);

                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        if (!isAdmin) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Read-Only Mode: Location shown. Saving is restricted to Admins.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final selectedFieldId = ref.read(
                          selectedFieldIdProvider,
                        );
                        if (selectedSaveType == 'Pin') {
                          final newObs = GeoObservation(
                            id: 'OBS-${DateTime.now().millisecondsSinceEpoch}',
                            fieldId: selectedFieldId ?? 'FLD-01',
                            position: point,
                            title: name,
                            issueType: 'Other',
                            severity: 'Low',
                            notes: 'Manually pinned coordinate: ($lat, $lng)',
                            date:
                                'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          );
                          ref
                              .read(geoObservationsProvider.notifier)
                              .addObservation(newObs);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Scouting observation pin dropped successfully!',
                              ),
                            ),
                          );
                        } else {
                          final newField = GeoField(
                            id: 'FLD-${DateTime.now().millisecondsSinceEpoch}',
                            farmId: 'FRM-01',
                            name: name,
                            boundary: [
                              LatLng(lat + 0.005, lng - 0.005),
                              LatLng(lat + 0.005, lng + 0.005),
                              LatLng(lat - 0.005, lng + 0.005),
                              LatLng(lat - 0.005, lng - 0.005),
                            ],
                            hectares: 25.0,
                            crop: 'Maize',
                            healthScore: 0.75,
                            status: 'Healthy',
                            lastScoutDate: 'Just added',
                          );
                          ref
                              .read(geoFieldsProvider.notifier)
                              .addField(newField);
                          ref
                              .read(selectedFieldIdProvider.notifier)
                              .select(newField.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'New Field registered successfully!',
                              ),
                            ),
                          );
                        }
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Moved map view to coordinates: ($lat, $lng)',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go to Location'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddPinDialog(LatLng point, String fieldId) {
    if (ref.read(appStateProvider).role != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Read-Only Mode: Dropping scouting pins requires Administrator clearance.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'Pest';
    String selectedSeverity = 'Medium';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('New Scouting Pin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Issue Title',
                        hintText: 'e.g. Locust sighting',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Issue Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pest',
                          child: Text('Pest / Insect'),
                        ),
                        DropdownMenuItem(
                          value: 'Disease',
                          child: Text('Crop Disease'),
                        ),
                        DropdownMenuItem(
                          value: 'Water',
                          child: Text('Water / Irrigation'),
                        ),
                        DropdownMenuItem(
                          value: 'Weed',
                          child: Text('Weeds / Growth'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSeverity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedSeverity = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Describe details for the scouting team...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final newObs = GeoObservation(
                      id: 'OBS-${DateTime.now().millisecondsSinceEpoch}',
                      fieldId: fieldId,
                      position: point,
                      title: title,
                      issueType: selectedType,
                      severity: selectedSeverity,
                      notes: notesController.text.trim(),
                      date:
                          'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    );

                    ref
                        .read(geoObservationsProvider.notifier)
                        .addObservation(newObs);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Scouting observation pin dropped successfully!',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Drop Pin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i;
    int j = polygon.length - 1;
    bool inside = false;
    for (i = 0; i < polygon.length; i++) {
      if (((polygon[i].longitude < point.longitude &&
                  polygon[j].longitude >= point.longitude) ||
              (polygon[j].longitude < point.longitude &&
                  polygon[i].longitude >= point.longitude)) &&
          (polygon[i].latitude +
                  (point.longitude - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) *
                      (polygon[j].latitude - polygon[i].latitude) <
              point.latitude)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(geoFieldsProvider);
    final observations = ref.watch(geoObservationsProvider);
    final tasks = ref.watch(geoTasksProvider);
    final settings = ref.watch(geoLayerSettingsProvider);
    final selectedFieldId = ref.watch(selectedFieldIdProvider);
    final schemes = ref.watch(irrigationSchemesProvider);
    final appState = ref.watch(appStateProvider);
    final isAdmin = appState.role == UserRole.admin;

    // Filters
    final searchText = _searchController.text.toLowerCase();
    final filteredFields = fields.where((f) {
      final matchesSearch =
          f.name.toLowerCase().contains(searchText) ||
          f.crop.toLowerCase().contains(searchText);
      final matchesRegion =
          _selectedRegion == 'All Regions' ||
          f.name.contains(_selectedRegion) ||
          _selectedRegion.toLowerCase() == 'gwanda' &&
              f.id == 'FLD-04'; // mock logic to align regional centers
      final matchesCrop =
          _selectedCrop == 'All Crops' || f.crop == _selectedCrop;
      return matchesSearch && matchesRegion && matchesCrop;
    }).toList();

    final selectedField = fields.firstWhere(
      (f) => f.id == selectedFieldId,
      orElse: () => fields.first,
    );

    // Compute center stats
    final totalFields = filteredFields.length;
    final avgHealth = totalFields > 0
        ? filteredFields.map((e) => e.healthScore).reduce((a, b) => a + b) /
              totalFields
        : 0.0;

    // Tile template selection
    final tileUrl = settings.showSatellite
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
        : settings.showTerrain
        ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    // Map Polygons mapping
    final polygons = filteredFields.map((f) {
      Color fill = const Color(0xFF16A34A).withOpacity(0.15);
      if (settings.showNdvi) {
        fill = f.healthScore >= 0.8
            ? const Color(0xFF22C55E).withOpacity(settings.opacityNdvi)
            : f.healthScore >= 0.6
            ? const Color(0xFFF97316).withOpacity(settings.opacityNdvi)
            : const Color(0xFFEF4444).withOpacity(settings.opacityNdvi);
      } else if (settings.showSoil) {
        fill = Colors.brown.withOpacity(settings.opacitySoil);
      }

      return Polygon(
        points: f.boundary,
        color: fill,
        borderColor: selectedFieldId == f.id
            ? Colors.yellow
            : const Color(0xFF16A34A),
        borderStrokeWidth: selectedFieldId == f.id ? 4 : 2,
        isFilled: true,
      );
    }).toList();

    if (settings.showIrrigation) {
      for (final s in schemes) {
        polygons.add(
          Polygon(
            points: s.boundary,
            color: Colors.blue.withOpacity(0.12),
            borderColor: Colors.blue.shade600,
            borderStrokeWidth: 2.5,
            isFilled: true,
          ),
        );
      }
    }

    // Irrigation layer polylines (mock layout pipes)
    final polylines = <Polyline>[];
    if (settings.showIrrigation) {
      polylines.add(
        Polyline(
          points: [
            LatLng(-17.80, 31.04),
            LatLng(-17.81, 31.045),
            LatLng(-17.82, 31.05),
          ],
          strokeWidth: 3.5,
          color: Colors.blue.shade400,
        ),
      );
      polylines.add(
        Polyline(
          points: [LatLng(-21.04, 31.66), LatLng(-21.05, 31.67)],
          strokeWidth: 3.5,
          color: Colors.blue.shade400,
        ),
      );
    }

    // Weather radar mock layers
    final circles = <CircleMarker>[];
    if (settings.showWeather) {
      circles.add(
        CircleMarker(
          point: LatLng(-17.81, 31.05),
          radius: 80,
          useRadiusInMeter: false,
          color: Colors.purple.withOpacity(settings.opacityWeather * 0.4),
          borderColor: Colors.purple.withOpacity(settings.opacityWeather),
          borderStrokeWidth: 1.5,
        ),
      );
      circles.add(
        CircleMarker(
          point: LatLng(-20.93, 29.00),
          radius: 120,
          useRadiusInMeter: false,
          color: Colors.blue.withOpacity(settings.opacityWeather * 0.3),
          borderColor: Colors.blue.withOpacity(settings.opacityWeather),
          borderStrokeWidth: 1.5,
        ),
      );
    }

    // Map Markers mapping
    final markers = <Marker>[];
    for (final obs in observations) {
      final severityColor = obs.severity == 'High'
          ? Colors.red
          : obs.severity == 'Medium'
          ? Colors.orange
          : Colors.blue;
      markers.add(
        Marker(
          point: obs.position,
          width: 38,
          height: 38,
          child: GestureDetector(
            onTap: () {
              ref.read(selectedFieldIdProvider.notifier).select(obs.fieldId);
              _mapController.move(obs.position, 14);
            },
            child: Tooltip(
              message: obs.title,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: severityColor, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Icon(
                  obs.issueType == 'Pest'
                      ? Icons.bug_report
                      : obs.issueType == 'Water'
                      ? Icons.water_drop
                      : obs.issueType == 'Disease'
                      ? Icons.coronavirus
                      : Icons.warning,
                  color: severityColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (settings.showIrrigation) {
      for (final s in schemes) {
        markers.add(
          Marker(
            point: s.position,
            width: 42,
            height: 42,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedScheme = s;
                });
                _mapController.move(s.position, 12);
              },
              child: Tooltip(
                message: '${s.name} (${s.crop})',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade600, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    Icons.shower,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Task markers mapping
    for (final task in tasks) {
      if (task.position != null) {
        markers.add(
          Marker(
            point: task.position!,
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () {
                ref.read(selectedFieldIdProvider.notifier).select(task.fieldId);
                _mapController.move(task.position!, 14);
              },
              child: Tooltip(
                message: task.title,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Interactive Spatial Map',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.pin_drop,
              color: _pinDropMode ? Colors.orange : const Color(0xFF475569),
            ),
            onPressed: () {
              setState(() => _pinDropMode = !_pinDropMode);
            },
            tooltip: 'Drop Scouting Pin',
          ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Toggle Map Filters',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'coordinates') {
                _showCoordinatesDialog();
              } else if (value == 'layers') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LayerManagerPage(),
                  ),
                );
              } else if (value == 'compare') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoricalComparePage(),
                  ),
                );
              } else if (value == 'tasks') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScoutingTasksPage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'coordinates',
                child: Row(
                  children: [
                    Icon(Icons.explore_outlined, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Pinpoint Coordinates'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'layers',
                child: Row(
                  children: [
                    Icon(Icons.layers_outlined, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Layer Manager'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'compare',
                child: Row(
                  children: [
                    Icon(Icons.compare_outlined, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Compare Seasons'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'tasks',
                child: Row(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Scouting Tasks'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black12,
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Full-screen Interactive map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(-19.5, 30.5),
                initialZoom: 7.0,
                onTap: (tapPosition, point) {
                  if (_pinDropMode) {
                    setState(() => _pinDropMode = false);
                    _showAddPinDialog(point, selectedFieldId ?? 'FLD-01');
                  } else {
                    // Click detection within field bounds
                    for (final field in fields) {
                      if (_isPointInPolygon(point, field.boundary)) {
                        ref
                            .read(selectedFieldIdProvider.notifier)
                            .select(field.id);
                        _mapController.move(point, 13.5);
                        return;
                      }
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolygonLayer(polygons: polygons),
                PolylineLayer(polylines: polylines),
                CircleLayer(circles: circles),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                child: const Center(
                  child: Text(
                    'READ-ONLY MODE (Privileged data modification restricted to Admins)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

          // 2. Map HUD controls (Top layer)
          Positioned(
            top: isAdmin ? 16 : 38,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showFilters) ...[
                  MapHeader(
                    searchController: _searchController,
                    onSearchChanged: (v) => setState(() {}),
                    selectedRegion: _selectedRegion,
                    regions: _regions,
                    onRegionChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedRegion = v);
                        // Focus map to region center
                        final center = switch (v.toLowerCase()) {
                          'harare' => LatLng(-17.82, 31.05),
                          'masvingo' => LatLng(-20.06, 30.83),
                          'chiredzi' => LatLng(-21.05, 31.67),
                          'mutare' => LatLng(-18.97, 32.67),
                          'gwanda' => LatLng(-20.93, 29.00),
                          _ => LatLng(-19.5, 30.5),
                        };
                        _mapController.move(
                          center,
                          v == 'All Regions' ? 7.0 : 11.5,
                        );
                      }
                    },
                    selectedCrop: _selectedCrop,
                    crops: _crops,
                    onCropChanged: (v) {
                      if (v != null) setState(() => _selectedCrop = v);
                    },
                    totalFields: totalFields,
                    avgHealth: avgHealth,
                  ),
                  const SizedBox(height: 10),
                ],
                const LayerChipRow(),
              ],
            ),
          ),

          // 3. Focus Card Overlay (Bottom sheet widget)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    final center = _mapController.camera.center;
                    _showAddPinDialog(center, selectedField.id);
                  },
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add Observation Pin'),
                ),
                const SizedBox(height: 10),
                if (settings.showIrrigation && _selectedScheme != null)
                  _SchemeCard(
                    scheme: _selectedScheme!,
                    onClose: () => setState(() => _selectedScheme = null),
                  )
                else
                  FieldCard(
                    field: selectedField,
                    onViewDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FieldDetailMapPage(fieldId: selectedField.id),
                        ),
                      );
                    },
                    onEditZones: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ZoneEditorPage(fieldId: selectedField.id),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonalBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final String valText;

  const _ZonalBar({
    required this.label,
    required this.percent,
    required this.color,
    required this.valText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(valText, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _ZonalStatBox extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _ZonalStatBox({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF16A34A), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

