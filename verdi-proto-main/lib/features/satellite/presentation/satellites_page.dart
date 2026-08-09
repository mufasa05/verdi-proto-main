import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/geospatial_state.dart';

class SatellitesPage extends ConsumerStatefulWidget {
  const SatellitesPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<SatellitesPage> createState() => _SatellitesPageState();
}

class _SatellitesPageState extends ConsumerState<SatellitesPage> {
  bool _loading = false;
  DateTime _updatedAt = DateTime.now();
  String _selectedLayer = 'Vegetation Index';
  String? _activeFilter; // null, 'fresh', 'anomaly', 'high_ndvi'
  double _historicalDaysAgo = 0; // 0 to 30 days

  final _fields = const [
    _SatField(name: 'Mvurwi North', ndvi: 0.82, evi: 0.71, cloud: 12, freshnessHours: 6, anomaly: 'Low', region: 'Mashonaland Central', moisture: 0.71, change: '+0.04'),
    _SatField(name: 'Odzi Block', ndvi: 0.51, evi: 0.46, cloud: 18, freshnessHours: 10, anomaly: 'High', region: 'Manicaland', moisture: 0.38, change: '-0.12'),
    _SatField(name: 'Gutu Plot', ndvi: 0.68, evi: 0.61, cloud: 7, freshnessHours: 4, anomaly: 'Low', region: 'Masvingo', moisture: 0.61, change: '+0.01'),
    _SatField(name: 'Chiredzi Unit', ndvi: 0.91, evi: 0.84, cloud: 5, freshnessHours: 2, anomaly: 'None', region: 'Lowveld', moisture: 0.84, change: '+0.06'),
  ];

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _updatedAt = DateTime.now();
      _loading = false;
    });
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) setState(() => _updatedAt = DateTime.now());
    });
  }

  List<_SatField> get _filteredFields {
    if (_activeFilter == 'fresh') {
      return _fields.where((f) => f.freshnessHours <= 6).toList();
    } else if (_activeFilter == 'anomaly') {
      return _fields.where((f) => f.anomaly != 'None').toList();
    } else if (_activeFilter == 'high_ndvi') {
      return _fields.where((f) => f.ndvi >= 0.75).toList();
    }
    return _fields;
  }

  void _showSatellitePassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.satellite_alt_rounded, color: SatellitesPage.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Sentinel-2 Orbital Pass Simulator', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Next Sentinel-2 orbit pass scheduled over Mashonaland / Lowveld in 14 minutes.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🛰️ Orbit: Sentinel-2B (Sun-synchronous)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('Bands enabled: B2 (Blue), B3 (Green), B4 (Red), B8 (NIR), B11 (SWIR)', style: TextStyle(fontSize: 11)),
                  SizedBox(height: 4),
                  Text('Spatial Resolution: 10m / pixel', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _refresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🛰️ Orbital pass capture executed! Multispectral scenes updated.'),
                  backgroundColor: SatellitesPage.green,
                ),
              );
            },
            icon: const Icon(Icons.flash_on_rounded, size: 16),
            label: const Text('Execute Orbital Capture'),
            style: ElevatedButton.styleFrom(backgroundColor: SatellitesPage.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showGisLayerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.layers_rounded, color: SatellitesPage.blue, size: 24),
                const SizedBox(width: 10),
                Text('Shared Geospatial GIS Layer Status', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Satellite telemetry, moisture dips, and NDVI anomalies are broadcasted across all farm management modules.'),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.check_circle, color: SatellitesPage.green),
              title: Text('Sentinel-2 L2A Stream'),
              subtitle: Text('Live (10m resolution, updated 2h ago)'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: SatellitesPage.green),
              title: Text('PlanetScope Daily Constellation'),
              subtitle: Text('Active (3m resolution)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(appStateProvider.notifier).setNavIndex(13); // Go to Geospatial Page
                },
                icon: const Icon(Icons.map_rounded),
                label: const Text('Open Geospatial Command Center'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SatellitesPage.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCloudCoverModal(BuildContext context, int cloudCover) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.cloud_outlined, color: SatellitesPage.blue),
            const SizedBox(width: 10),
            Text('Cloud Cover & Optical Masking', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Average regional cloud cover is currently $cloudCover%.'),
            const SizedBox(height: 10),
            const Text(
              'Automated Sentinel-2 Scene Classification Layer (SCL) filters out cloud shadows and cirrus artifacts automatically.',
              style: TextStyle(fontSize: 12, color: SatellitesPage.muted),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showNdviModal(BuildContext context, double avgNdvi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.area_chart_outlined, color: SatellitesPage.green),
            const SizedBox(width: 10),
            Text('NDVI Regional Canopy Metrics', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Average NDVI across all active plots is ${avgNdvi.toStringAsFixed(2)}.'),
            const SizedBox(height: 10),
            const Text('• 0.80 - 1.00: Dense Healthy Canopy (Chiredzi Unit: 0.91)\n• 0.50 - 0.79: Moderate Growth (Gutu Plot: 0.68)\n• < 0.50: Canopy Stress / Water Dip (Odzi Block: 0.51)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _activeFilter = _activeFilter == 'high_ndvi' ? null : 'high_ndvi');
            },
            icon: const Icon(Icons.filter_alt_outlined, size: 16),
            label: Text(_activeFilter == 'high_ndvi' ? 'Clear Filter' : 'Filter High NDVI (>=0.75)'),
            style: ElevatedButton.styleFrom(backgroundColor: SatellitesPage.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showAiInsightModal(BuildContext context, _AiInsight insight) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(insight.icon, color: insight.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI Satellite Diagnostic Report',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: insight.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'AI Confidence Level: ${insight.confidence}%',
                style: TextStyle(color: insight.color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Text(insight.text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: SatellitesPage.dark)),
            const SizedBox(height: 14),
            const Text(
              'Automated Sentinel-2 & thermal infrared bands detected localized canopy stress. Recommended operations:',
              style: TextStyle(fontSize: 12, color: SatellitesPage.muted),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ref.read(appStateProvider.notifier).setNavIndex(14); // Crop Health
            },
            icon: const Icon(Icons.health_and_safety_outlined, size: 16),
            label: const Text('Crop Health'),
            style: ElevatedButton.styleFrom(backgroundColor: SatellitesPage.green, foregroundColor: Colors.white),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ref.read(appStateProvider.notifier).setNavIndex(8); // Irrigation
            },
            icon: const Icon(Icons.water_drop_outlined, size: 16),
            label: const Text('Irrigation'),
            style: ElevatedButton.styleFrom(backgroundColor: SatellitesPage.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showFieldDetailModal(BuildContext context, _SatField field) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: SatellitesPage.dark)),
                      Text('${field.region} • Satellite Pass ${field.freshnessHours}h ago', style: const TextStyle(color: SatellitesPage.muted, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: field.anomaly == 'None' ? SatellitesPage.green.withValues(alpha: 0.1) : SatellitesPage.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    field.anomaly == 'None' ? 'Healthy' : '${field.anomaly} Risk',
                    style: TextStyle(
                      color: field.anomaly == 'None' ? SatellitesPage.green : SatellitesPage.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Spectral Breakdown Cards
            Row(
              children: [
                Expanded(child: _MiniTile(label: 'NDVI Index', value: field.ndvi.toStringAsFixed(2), color: SatellitesPage.green)),
                const SizedBox(width: 8),
                Expanded(child: _MiniTile(label: 'EVI Index', value: field.evi.toStringAsFixed(2), color: SatellitesPage.blue)),
                const SizedBox(width: 8),
                Expanded(child: _MiniTile(label: 'Moisture', value: '${(field.moisture * 100).round()}%', color: SatellitesPage.blue)),
                const SizedBox(width: 8),
                Expanded(child: _MiniTile(label: 'Cloud Cover', value: '${field.cloud}%', color: SatellitesPage.muted)),
              ],
            ),
            const SizedBox(height: 20),

            Text('Direct Actions & Field Operations:', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(appStateProvider.notifier).setNavIndex(14); // Crop Health
                  },
                  icon: const Icon(Icons.health_and_safety_outlined, size: 16),
                  label: const Text('Crop Health'),
                  style: ElevatedButton.styleFrom(backgroundColor: SatellitesPage.green, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(appStateProvider.notifier).setNavIndex(8); // Irrigation
                  },
                  icon: const Icon(Icons.water_drop_outlined, size: 16),
                  label: const Text('Irrigation'),
                  style: ElevatedButton.styleFrom(backgroundColor: SatellitesPage.blue, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(appStateProvider.notifier).setNavIndex(10); // Drone Inspection
                  },
                  icon: const Icon(Icons.flight_takeoff_outlined, size: 16),
                  label: const Text('Launch Drone Recon'),
                  style: ElevatedButton.styleFrom(backgroundColor: SatellitesPage.dark, foregroundColor: Colors.white),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('📄 GeoTIFF & Multispectral CSV exported for ${field.name}!')),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export GeoTIFF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avgNdvi = _fields.fold<double>(0, (s, f) => s + f.ndvi) / _fields.length;
    final avgCloud = _fields.fold<int>(0, (s, f) => s + f.cloud) ~/ _fields.length;
    final freshScenes = _fields.where((f) => f.freshnessHours <= 6).length;
    final anomalyCount = _fields.where((f) => f.anomaly != 'None').length;

    final displayFields = _filteredFields;

    return Scaffold(
      backgroundColor: SatellitesPage.background,
      appBar: AppBar(
        title: Text(
          'Satellite Intelligence',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: SatellitesPage.dark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSatellitePassDialog(context),
            icon: const Icon(Icons.satellite_alt_rounded, color: SatellitesPage.blue),
            tooltip: 'Trigger Satellite Orbit Pass',
          ),
          Semantics(
            button: true,
            label: 'Refresh satellite data',
            child: IconButton(
              onPressed: _refresh,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh_outlined),
              tooltip: 'Refresh satellite data',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
                children: [
                  // Geospatial connection banner
                  _SpatialBanner(onTap: () => _showGisLayerModal(context)),
                  const SizedBox(height: 16),

                  // Imagery Header
                  _ImageryHeader(
                    updatedAt: _timeAgo(_updatedAt),
                    cloudCover: avgCloud,
                    freshScenes: freshScenes,
                    onTriggerPass: () => _showSatellitePassDialog(context),
                    onCloudTap: () => _showCloudCoverModal(context, avgCloud),
                    onFreshTap: () {
                      setState(() {
                        _activeFilter = _activeFilter == 'fresh' ? null : 'fresh';
                      });
                    },
                    isFreshFiltered: _activeFilter == 'fresh',
                  ),
                  const SizedBox(height: 16),

                  // AI Insight Rail
                  _AiInsightRail(onSelectInsight: (insight) => _showAiInsightModal(context, insight)),
                  const SizedBox(height: 16),

                  // Layer Toggle Panel
                  _LayerPanel(selectedLayer: _selectedLayer, onLayerChanged: (l) => setState(() => _selectedLayer = l)),
                  const SizedBox(height: 16),

                  // Interactive Map Surface Visualization Preview
                  _SatMapVisualization(
                    selectedLayer: _selectedLayer,
                    historicalDaysAgo: _historicalDaysAgo,
                    onHistoricalDaysChanged: (v) => setState(() => _historicalDaysAgo = v),
                    fields: _fields,
                    onSelectField: (f) => _showFieldDetailModal(context, f),
                  ),
                  const SizedBox(height: 16),

                  // Active Filter Badge Bar
                  if (_activeFilter != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: SatellitesPage.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: SatellitesPage.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Filter Active: ${_activeFilter == 'fresh' ? 'Fresh Scenes (<=6h)' : _activeFilter == 'anomaly' ? 'Anomaly Zones' : 'High NDVI (>=0.75)'}',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: SatellitesPage.green),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => setState(() => _activeFilter = null),
                                  child: const Icon(Icons.close_rounded, size: 16, color: SatellitesPage.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // KPI Stats Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 900
                          ? 4
                          : (constraints.maxWidth > 500 ? 2 : 1);
                      final spacing = 12.0;
                      final double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _KpiCard(
                            width: width,
                            label: 'Avg NDVI',
                            value: avgNdvi.toStringAsFixed(2),
                            icon: Icons.area_chart_outlined,
                            color: SatellitesPage.green,
                            onTap: () => _showNdviModal(context, avgNdvi),
                          ),
                          _KpiCard(
                            width: width,
                            label: 'Cloud Cover',
                            value: '$avgCloud%',
                            icon: Icons.cloud_outlined,
                            color: SatellitesPage.blue,
                            onTap: () => _showCloudCoverModal(context, avgCloud),
                          ),
                          _KpiCard(
                            width: width,
                            label: 'Fresh Scenes',
                            value: '$freshScenes / ${_fields.length}',
                            icon: Icons.timelapse_outlined,
                            color: SatellitesPage.green,
                            onTap: () => setState(() => _activeFilter = _activeFilter == 'fresh' ? null : 'fresh'),
                          ),
                          _KpiCard(
                            width: width,
                            label: 'Anomalies',
                            value: '$anomalyCount Zones',
                            icon: Icons.warning_amber_outlined,
                            color: anomalyCount > 1 ? SatellitesPage.orange : SatellitesPage.green,
                            onTap: () => setState(() => _activeFilter = _activeFilter == 'anomaly' ? null : 'anomaly'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Hotspot Anomaly List
                  Text('Hotspot Anomaly Map', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
                  const SizedBox(height: 10),
                  ..._fields.where((f) => f.anomaly != 'None').map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HotspotCard(
                        field: f,
                        onTap: () => _showFieldDetailModal(context, f),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // All Field Scenes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All Field Scenes (${displayFields.length})', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
                      if (_activeFilter != null)
                        TextButton(
                          onPressed: () => setState(() => _activeFilter = null),
                          child: const Text('Show All Plots'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...displayFields.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FieldSceneCard(
                        field: f,
                        onTap: () => _showFieldDetailModal(context, f),
                      ),
                    ),
                  ),
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
  final VoidCallback onTap;

  const _SpatialBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.satellite_alt_outlined, color: Color(0xFF3B82F6), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Satellite anomalies and moisture data are published to the shared layer. Click to view GIS details.',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: SatellitesPage.dark),
              ),
            ),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('GIS Layer >', style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ImageryHeader extends StatelessWidget {
  final String updatedAt;
  final int cloudCover;
  final int freshScenes;
  final VoidCallback onTriggerPass;
  final VoidCallback onCloudTap;
  final VoidCallback onFreshTap;
  final bool isFreshFiltered;

  const _ImageryHeader({
    required this.updatedAt,
    required this.cloudCover,
    required this.freshScenes,
    required this.onTriggerPass,
    required this.onCloudTap,
    required this.onFreshTap,
    required this.isFreshFiltered,
  });

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Satellite Pass', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: SatellitesPage.dark)),
                    const SizedBox(height: 4),
                    Text('Updated $updatedAt • Sentinel-2B', style: const TextStyle(color: SatellitesPage.muted, fontSize: 12)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onTriggerPass,
                icon: const Icon(Icons.flash_on_rounded, size: 14, color: SatellitesPage.blue),
                label: const Text('Pass Telemetry', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SatellitesPage.blue,
                  side: const BorderSide(color: SatellitesPage.blue),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderChip(
                label: 'Cloud $cloudCover%',
                icon: Icons.cloud_outlined,
                color: SatellitesPage.blue,
                onTap: onCloudTap,
              ),
              _HeaderChip(
                label: isFreshFiltered ? 'showing $freshScenes Fresh' : '$freshScenes Fresh',
                icon: isFreshFiltered ? Icons.filter_alt : Icons.check_circle_outline,
                color: SatellitesPage.green,
                onTap: onFreshTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _AiInsightRail extends StatelessWidget {
  final List<_AiInsight> insights = const [
    _AiInsight(
      text: 'Moisture anomaly in Odzi Block — stress rising over 4 days',
      icon: Icons.water_drop_outlined,
      color: Color(0xFFEF4444),
      confidence: 88,
    ),
    _AiInsight(
      text: 'Vegetation decline forecast in Odzi Block over next 7 days',
      icon: Icons.trending_down,
      color: Color(0xFFF97316),
      confidence: 79,
    ),
    _AiInsight(
      text: 'Rapid canopy growth detected in Chiredzi Unit — irrigation efficiency high',
      icon: Icons.eco_outlined,
      color: Color(0xFF16A34A),
      confidence: 94,
    ),
  ];

  final Function(_AiInsight) onSelectInsight;

  const _AiInsightRail({required this.onSelectInsight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: insights.length,
        itemBuilder: (context, i) {
          final insight = insights[i];
          return InkWell(
            onTap: () => onSelectInsight(insight),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: insight.color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: insight.color, borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.smart_toy, color: Colors.white, size: 14),
                        Text('${insight.confidence}%', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(insight.icon, color: insight.color, size: 16),
                        const SizedBox(height: 4),
                        Text(
                          insight.text,
                          style: TextStyle(fontSize: 11.5, color: insight.color, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LayerPanel extends StatelessWidget {
  final String selectedLayer;
  final ValueChanged<String> onLayerChanged;

  const _LayerPanel({required this.selectedLayer, required this.onLayerChanged});

  @override
  Widget build(BuildContext context) {
    final layers = ['Vegetation Index', 'Moisture Stress', 'Change Detection', 'Historical View'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: layers.map((l) {
          final selected = l == selectedLayer;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              button: true,
              selected: selected,
              label: '$l layer toggle',
              child: GestureDetector(
                onTap: () => onLayerChanged(l),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? SatellitesPage.green : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? SatellitesPage.green : Colors.black12),
                  ),
                  child: Text(
                    l,
                    style: TextStyle(
                      color: selected ? Colors.white : SatellitesPage.dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SatMapVisualization extends StatelessWidget {
  final String selectedLayer;
  final double historicalDaysAgo;
  final ValueChanged<double> onHistoricalDaysChanged;
  final List<_SatField> fields;
  final Function(_SatField) onSelectField;

  const _SatMapVisualization({
    required this.selectedLayer,
    required this.historicalDaysAgo,
    required this.onHistoricalDaysChanged,
    required this.fields,
    required this.onSelectField,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    const dark = Color(0xFF0F172A);
    const blue = Color(0xFF3B82F6);

    return Container(
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  selectedLayer == 'Vegetation Index'
                      ? Icons.grass_rounded
                      : selectedLayer == 'Moisture Stress'
                          ? Icons.water_drop_rounded
                          : selectedLayer == 'Change Detection'
                              ? Icons.compare_arrows_rounded
                              : Icons.history_toggle_off_rounded,
                  color: green,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Multispectral Surface Map — $selectedLayer',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedLayer == 'Historical View'
                        ? '${historicalDaysAgo.round()} days ago'
                        : 'Sentinel-2 L2A',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Map Canvas Backdrop & Pinned Field Markers
          Container(
            height: 240,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1E293B),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: selectedLayer == 'Moisture Stress' ? 0.3 : 0.45,
                      child: Image.network(
                        selectedLayer == 'Moisture Stress'
                            ? 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80'
                            : 'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.black38),
                      ),
                    ),
                  ),
                ),

                // Map Legend Bar
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text('Scale: ', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                        const SizedBox(width: 4),
                        Container(
                          width: 80,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: selectedLayer == 'Moisture Stress'
                                  ? [Colors.red, Colors.orange, blue]
                                  : [Colors.orange, Colors.yellow, green],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedLayer == 'Moisture Stress' ? '0% - 100%' : '0.0 - 1.0 NDVI',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Interactive Map Markers
                ...fields.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final f = entry.value;

                  final topPos = 30.0 + (idx * 45.0) % 150.0;
                  final leftPos = 20.0 + (idx * 80.0) % 280.0;

                  return Positioned(
                    top: topPos,
                    left: leftPos,
                    child: InkWell(
                      onTap: () => onSelectField(f),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: f.anomaly == 'None' ? green : (f.anomaly == 'Low' ? Colors.orange : Colors.red),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.satellite_outlined, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${f.name} (${f.ndvi})',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Historical Slider if Historical View selected
          if (selectedLayer == 'Historical View')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Satellite Pass Historical Timeline:', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('${historicalDaysAgo.round()} days ago', style: GoogleFonts.inter(color: green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: historicalDaysAgo,
                    min: 0,
                    max: 30,
                    divisions: 30,
                    activeColor: green,
                    inactiveColor: Colors.white24,
                    label: '${historicalDaysAgo.round()} days ago',
                    onChanged: onHistoricalDaysChanged,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;
  final VoidCallback onTap;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width ?? 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: SatellitesPage.muted, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotspotCard extends ConsumerWidget {
  final _SatField field;
  final VoidCallback onTap;

  const _HotspotCard({required this.field, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = field.anomaly == 'High' ? SatellitesPage.red : SatellitesPage.orange;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: SatellitesPage.dark)),
                  Text('${field.region} • NDVI ${field.ndvi.toStringAsFixed(2)} • 7-day change: ${field.change}', style: const TextStyle(fontSize: 11.5, color: SatellitesPage.muted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('${field.anomaly} Risk', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(geospatialStateProvider.notifier).publishAnomaly(
                            GeospatialAnomaly(
                              id: 'SAT-${DateTime.now().millisecondsSinceEpoch}',
                              source: 'Satellite',
                              title: 'Moisture dip in ${field.name}',
                              detail: 'Satellite anomaly registered. NDVI is ${field.ndvi.toStringAsFixed(2)}. 7-day change rate is ${field.change}.',
                              zone: field.name.contains('Mvurwi') ? 'Zone 2' : (field.name.contains('Odzi') ? 'Zone 5' : 'Zone 3'),
                              severity: field.anomaly == 'High' ? 0.85 : 0.50,
                              timestamp: DateTime.now(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('📡 Anomaly published to GIS layer for ${field.name}!')),
                          );
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Send to GIS →', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldSceneCard extends StatelessWidget {
  final _SatField field;
  final VoidCallback onTap;

  const _FieldSceneCard({required this.field, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = field.anomaly == 'None'
        ? SatellitesPage.green
        : field.anomaly == 'Low'
            ? SatellitesPage.orange
            : SatellitesPage.red;
    final ndviPct = (field.ndvi * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                Expanded(child: Text(field.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: SatellitesPage.dark))),
                Text(field.anomaly == 'None' ? 'Normal' : '${field.anomaly} Anomaly', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            Text(field.region, style: const TextStyle(color: SatellitesPage.muted, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Health $ndviPct%', style: const TextStyle(color: SatellitesPage.muted, fontSize: 12)),
                const Spacer(),
                Text('${field.freshnessHours}h ago', style: const TextStyle(color: SatellitesPage.muted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: field.ndvi,
              minHeight: 7,
              backgroundColor: Colors.grey.shade100,
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _MiniTile(label: 'NDVI', value: field.ndvi.toStringAsFixed(2))),
                const SizedBox(width: 8),
                Expanded(child: _MiniTile(label: 'EVI', value: field.evi.toStringAsFixed(2))),
                const SizedBox(width: 8),
                Expanded(child: _MiniTile(label: 'Cloud', value: '${field.cloud}%')),
                const SizedBox(width: 8),
                Expanded(child: _MiniTile(label: '7d Change', value: field.change, color: field.change.startsWith('+') ? SatellitesPage.green : SatellitesPage.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MiniTile({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: SatellitesPage.muted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color ?? SatellitesPage.dark)),
        ],
      ),
    );
  }
}

class _SatField {
  final String name;
  final double ndvi;
  final double evi;
  final int cloud;
  final int freshnessHours;
  final String anomaly;
  final String region;
  final double moisture;
  final String change;

  const _SatField({
    required this.name,
    required this.ndvi,
    required this.evi,
    required this.cloud,
    required this.freshnessHours,
    required this.anomaly,
    required this.region,
    required this.moisture,
    required this.change,
  });
}

class _AiInsight {
  final String text;
  final IconData icon;
  final Color color;
  final int confidence;

  const _AiInsight({required this.text, required this.icon, required this.color, required this.confidence});
}