import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeospatialAnomaly {
  final String id;
  final String source; // 'Satellite' | 'Drone' | 'Sensor'
  final String title;
  final String detail;
  final String zone; // e.g. 'Zone 2'
  final double severity; // 0.0 to 1.0
  final DateTime timestamp;
  final bool resolved;

  const GeospatialAnomaly({
    required this.id,
    required this.source,
    required this.title,
    required this.detail,
    required this.zone,
    required this.severity,
    required this.timestamp,
    this.resolved = false,
  });
}

class GeospatialNotifier extends StateNotifier<List<GeospatialAnomaly>> {
  GeospatialNotifier()
      : super([
          GeospatialAnomaly(
            id: 'ANOM-01',
            source: 'Satellite',
            title: 'Moisture Index Dip',
            detail: 'Moisture stress signature drops by 0.12 in northern quadrant.',
            zone: 'Zone 2',
            severity: 0.75,
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          ),
          GeospatialAnomaly(
            id: 'ANOM-02',
            source: 'Drone',
            title: 'Armyworm canopy signature',
            detail: 'Leaf discolouration pattern consistent with armyworm migration.',
            zone: 'Zone 5',
            severity: 0.65,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ]);

  void publishAnomaly(GeospatialAnomaly anomaly) {
    state = [anomaly, ...state];
  }

  void resolveAnomaly(String id) {
    state = state.map((a) {
      if (a.id == id) {
        return GeospatialAnomaly(
          id: a.id,
          source: a.source,
          title: a.title,
          detail: a.detail,
          zone: a.zone,
          severity: a.severity,
          timestamp: a.timestamp,
          resolved: true,
        );
      }
      return a;
    }).toList();
  }
}

final geospatialStateProvider =
    StateNotifierProvider<GeospatialNotifier, List<GeospatialAnomaly>>((ref) {
  return GeospatialNotifier();
});
