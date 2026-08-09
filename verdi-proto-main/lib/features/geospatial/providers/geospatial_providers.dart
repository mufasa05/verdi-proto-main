import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/geospatial_models.dart';

// --- MOCK INITIAL DATA ---

final _initialFields = [
  const GeoField(
    id: 'FLD-01',
    farmId: 'FRM-01',
    name: 'North Maize Field',
    boundary: [
      LatLng(-17.80, 31.04),
      LatLng(-17.80, 31.06),
      LatLng(-17.82, 31.05),
      LatLng(-17.82, 31.03),
    ],
    hectares: 120.0,
    crop: 'Maize',
    healthScore: 0.86,
    status: 'Healthy',
    lastScoutDate: 'Today, 14:30',
  ),
  const GeoField(
    id: 'FLD-02',
    farmId: 'FRM-02',
    name: 'Chiredzi Tomato Patch',
    boundary: [
      LatLng(-21.04, 31.66),
      LatLng(-21.04, 31.68),
      LatLng(-21.06, 31.67),
      LatLng(-21.06, 31.65),
    ],
    hectares: 75.0,
    crop: 'Tomatoes',
    healthScore: 0.63,
    status: 'Heat Stress',
    lastScoutDate: 'Yesterday, 10:15',
  ),
  const GeoField(
    id: 'FLD-03',
    farmId: 'FRM-03',
    name: 'Eastern Potato Ridge',
    boundary: [
      LatLng(-18.96, 32.66),
      LatLng(-18.96, 32.68),
      LatLng(-18.98, 32.67),
      LatLng(-18.98, 32.65),
    ],
    hectares: 54.0,
    crop: 'Potatoes',
    healthScore: 0.91,
    status: 'Healthy',
    lastScoutDate: '2 days ago',
  ),
  const GeoField(
    id: 'FLD-04',
    farmId: 'FRM-04',
    name: 'South Cabbage Plot',
    boundary: [
      LatLng(-20.92, 28.99),
      LatLng(-20.92, 29.01),
      LatLng(-20.94, 29.00),
      LatLng(-20.94, 28.98),
    ],
    hectares: 88.0,
    crop: 'Cabbages',
    healthScore: 0.49,
    status: 'Water Stress',
    lastScoutDate: 'Today, 08:00',
  ),
];

final _initialZones = [
  const GeoZone(
    id: 'ZN-01',
    fieldId: 'FLD-01',
    name: 'Zone A - High Yield',
    boundary: [
      LatLng(-17.80, 31.04),
      LatLng(-17.80, 31.05),
      LatLng(-17.81, 31.045),
    ],
    cropType: 'White Maize',
    irrigationRule: '12mm / 48h',
    treatmentRule: 'Nitrogen NPK 50kg/ha',
  ),
  const GeoZone(
    id: 'ZN-02',
    fieldId: 'FLD-01',
    name: 'Zone B - Sandy Soil',
    boundary: [
      LatLng(-17.81, 31.045),
      LatLng(-17.80, 31.06),
      LatLng(-17.82, 31.05),
    ],
    cropType: 'Yellow Maize',
    irrigationRule: '18mm / 24h',
    treatmentRule: 'Zinc Sulfate 5kg/ha',
  ),
];

final _initialObservations = [
  const GeoObservation(
    id: 'OBS-01',
    fieldId: 'FLD-01',
    position: LatLng(-17.812, 31.046),
    title: 'Fall Armyworm Infestation',
    issueType: 'Pest',
    severity: 'High',
    notes: 'Severe damage detected on central leaves. Spot spraying required immediately.',
    date: 'Today, 11:30',
  ),
  const GeoObservation(
    id: 'OBS-02',
    fieldId: 'FLD-02',
    position: LatLng(-21.050, 31.665),
    title: 'Clogged Drip Emitter',
    issueType: 'Water',
    severity: 'Medium',
    notes: 'Section 4 lateral line showing reduced pressure. Needs cleaning.',
    date: 'Yesterday, 14:00',
  ),
];

final _initialTasks = [
  const GeoTask(
    id: 'TSK-01',
    fieldId: 'FLD-01',
    title: 'Apply Pest Treatment',
    description: 'Spray Chlorantraniliprole targeting Fall Armyworm in Zone B.',
    position: LatLng(-17.815, 31.048),
    assignee: 'Farai Chimanzi',
    status: 'Pending',
    dueDate: '2026-06-26',
  ),
  const GeoTask(
    id: 'TSK-02',
    fieldId: 'FLD-02',
    title: 'Soil Moisture Check',
    description: 'Manually verify moisture depth in high risk red zones.',
    position: LatLng(-21.052, 31.670),
    assignee: 'Nyasha K.',
    status: 'In Progress',
    dueDate: '2026-06-25',
  ),
];

// --- RIVERPOD STATE NOTIFIERS ---

class GeoFieldsNotifier extends StateNotifier<List<GeoField>> {
  GeoFieldsNotifier() : super(_initialFields);

  void addField(GeoField field) {
    state = [...state, field];
  }

  void updateField(GeoField updated) {
    state = state.map((f) => f.id == updated.id ? updated : f).toList();
  }
}

class GeoZonesNotifier extends StateNotifier<List<GeoZone>> {
  GeoZonesNotifier() : super(_initialZones);

  void addZone(GeoZone zone) {
    state = [...state, zone];
  }

  void removeZone(String id) {
    state = state.where((z) => z.id != id).toList();
  }
}

class GeoObservationsNotifier extends StateNotifier<List<GeoObservation>> {
  GeoObservationsNotifier() : super(_initialObservations);

  void addObservation(GeoObservation obs) {
    state = [...state, obs];
  }

  void removeObservation(String id) {
    state = state.where((o) => o.id != id).toList();
  }
}

class GeoTasksNotifier extends StateNotifier<List<GeoTask>> {
  GeoTasksNotifier() : super(_initialTasks);

  void addTask(GeoTask task) {
    state = [...state, task];
  }

  void toggleTaskStatus(String id) {
    state = state.map((t) {
      if (t.id == id) {
        final nextStatus = t.status == 'Completed' ? 'Pending' : 'Completed';
        return t.copyWith(status: nextStatus);
      }
      return t;
    }).toList();
  }

  void removeTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

class GeoLayerSettingsNotifier extends StateNotifier<GeoLayerSettings> {
  GeoLayerSettingsNotifier() : super(const GeoLayerSettings());

  void toggleSatellite(bool value) => state = state.copyWith(showSatellite: value);
  void toggleNdvi(bool value) => state = state.copyWith(showNdvi: value);
  void toggleSoil(bool value) => state = state.copyWith(showSoil: value);
  void toggleWeather(bool value) => state = state.copyWith(showWeather: value);
  void toggleTerrain(bool value) => state = state.copyWith(showTerrain: value);
  void toggleIrrigation(bool value) => state = state.copyWith(showIrrigation: value);

  void setNdviOpacity(double val) => state = state.copyWith(opacityNdvi: val);
  void setSoilOpacity(double val) => state = state.copyWith(opacitySoil: val);
  void setWeatherOpacity(double val) => state = state.copyWith(opacityWeather: val);
}

class SelectedFieldIdNotifier extends StateNotifier<String?> {
  SelectedFieldIdNotifier() : super('FLD-01'); // default to FLD-01

  void select(String? id) => state = id;
}

// --- PROVIDER DEFINITIONS ---

final geoFieldsProvider = StateNotifierProvider<GeoFieldsNotifier, List<GeoField>>((ref) {
  return GeoFieldsNotifier();
});

final geoZonesProvider = StateNotifierProvider<GeoZonesNotifier, List<GeoZone>>((ref) {
  return GeoZonesNotifier();
});

final geoObservationsProvider = StateNotifierProvider<GeoObservationsNotifier, List<GeoObservation>>((ref) {
  return GeoObservationsNotifier();
});

final geoTasksProvider = StateNotifierProvider<GeoTasksNotifier, List<GeoTask>>((ref) {
  return GeoTasksNotifier();
});

final geoLayerSettingsProvider = StateNotifierProvider<GeoLayerSettingsNotifier, GeoLayerSettings>((ref) {
  return GeoLayerSettingsNotifier();
});

final selectedFieldIdProvider = StateNotifierProvider<SelectedFieldIdNotifier, String?>((ref) {
  return SelectedFieldIdNotifier();
});

// --- IRRIGATION SCHEMES ---

final _initialSchemes = [
  const IrrigationScheme(
    id: 'SCH-01',
    name: 'Mvurwi Scheme',
    crop: 'Maize',
    position: LatLng(-17.02, 30.85),
    waterAllocated: 120.0,
    waterUsed: 103.2,
    uptime: 0.96,
    blockedValves: 1,
    alerts: 2,
    boundary: [
      LatLng(-17.01, 30.84),
      LatLng(-17.01, 30.86),
      LatLng(-17.03, 30.86),
      LatLng(-17.03, 30.84),
    ],
  ),
  const IrrigationScheme(
    id: 'SCH-02',
    name: 'Odzi Scheme',
    crop: 'Tomatoes',
    position: LatLng(-18.96, 32.40),
    waterAllocated: 90.0,
    waterUsed: 61.8,
    uptime: 0.88,
    blockedValves: 2,
    alerts: 4,
    boundary: [
      LatLng(-18.95, 32.39),
      LatLng(-18.95, 32.41),
      LatLng(-18.97, 32.41),
      LatLng(-18.97, 32.39),
    ],
  ),
  const IrrigationScheme(
    id: 'SCH-03',
    name: 'Gutu Cluster',
    crop: 'Onions',
    position: LatLng(-19.65, 31.16),
    waterAllocated: 75.0,
    waterUsed: 55.5,
    uptime: 0.92,
    blockedValves: 0,
    alerts: 1,
    boundary: [
      LatLng(-19.64, 31.15),
      LatLng(-19.64, 31.17),
      LatLng(-19.66, 31.17),
      LatLng(-19.66, 31.15),
    ],
  ),
  const IrrigationScheme(
    id: 'SCH-04',
    name: 'Chiredzi Block',
    crop: 'Mango',
    position: LatLng(-21.05, 31.67),
    waterAllocated: 150.0,
    waterUsed: 132.0,
    uptime: 0.99,
    blockedValves: 0,
    alerts: 0,
    boundary: [
      LatLng(-21.04, 31.66),
      LatLng(-21.04, 31.68),
      LatLng(-21.06, 31.68),
      LatLng(-21.06, 31.66),
    ],
  ),
];

class IrrigationSchemesNotifier extends StateNotifier<List<IrrigationScheme>> {
  IrrigationSchemesNotifier() : super(_initialSchemes);

  void addScheme(IrrigationScheme scheme) {
    state = [...state, scheme];
  }
}

final irrigationSchemesProvider =
    StateNotifierProvider<IrrigationSchemesNotifier, List<IrrigationScheme>>((ref) {
  return IrrigationSchemesNotifier();
});
