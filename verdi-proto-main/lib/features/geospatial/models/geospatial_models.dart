import 'package:latlong2/latlong.dart';

class GeoFarm {
  final String id;
  final String name;
  final LatLng center;
  final String owner;
  final String region;

  const GeoFarm({
    required this.id,
    required this.name,
    required this.center,
    required this.owner,
    required this.region,
  });
}

class IrrigationScheme {
  final String id;
  final String name;
  final String crop;
  final LatLng position;
  final double waterAllocated;
  final double waterUsed;
  final double uptime;
  final int blockedValves;
  final int alerts;
  final List<LatLng> boundary;

  const IrrigationScheme({
    required this.id,
    required this.name,
    required this.crop,
    required this.position,
    required this.waterAllocated,
    required this.waterUsed,
    required this.uptime,
    required this.blockedValves,
    required this.alerts,
    required this.boundary,
  });

  double get utilization =>
      waterAllocated == 0 ? 0 : (waterUsed / waterAllocated).clamp(0.0, 1.0);
  double get efficiency =>
      (uptime - (blockedValves * 0.04) - (alerts * 0.03)).clamp(0.0, 1.0);
}

class GeoField {
  final String id;
  final String farmId;
  final String name;
  final List<LatLng> boundary;
  final double hectares;
  final String crop;
  final double healthScore; // NDVI index (e.g. 0.85)
  final String status; // "Healthy", "Water Stress", "Pest Risk", "Disease Alert"
  final String lastScoutDate;

  const GeoField({
    required this.id,
    required this.farmId,
    required this.name,
    required this.boundary,
    required this.hectares,
    required this.crop,
    required this.healthScore,
    required this.status,
    required this.lastScoutDate,
  });

  GeoField copyWith({
    String? name,
    List<LatLng>? boundary,
    double? hectares,
    String? crop,
    double? healthScore,
    String? status,
    String? lastScoutDate,
  }) {
    return GeoField(
      id: id,
      farmId: farmId,
      name: name ?? this.name,
      boundary: boundary ?? this.boundary,
      hectares: hectares ?? this.hectares,
      crop: crop ?? this.crop,
      healthScore: healthScore ?? this.healthScore,
      status: status ?? this.status,
      lastScoutDate: lastScoutDate ?? this.lastScoutDate,
    );
  }
}

class GeoZone {
  final String id;
  final String fieldId;
  final String name;
  final List<LatLng> boundary;
  final String cropType;
  final String irrigationRule;
  final String treatmentRule;

  const GeoZone({
    required this.id,
    required this.fieldId,
    required this.name,
    required this.boundary,
    required this.cropType,
    required this.irrigationRule,
    required this.treatmentRule,
  });
}

class GeoObservation {
  final String id;
  final String fieldId;
  final LatLng position;
  final String title;
  final String issueType; // "Pest", "Disease", "Water", "Weed", "Other"
  final String severity; // "Low", "Medium", "High"
  final String notes;
  final String date;

  const GeoObservation({
    required this.id,
    required this.fieldId,
    required this.position,
    required this.title,
    required this.issueType,
    required this.severity,
    required this.notes,
    required this.date,
  });
}

class GeoTask {
  final String id;
  final String fieldId;
  final String title;
  final String description;
  final LatLng? position;
  final String assignee;
  final String status; // "Pending", "In Progress", "Completed"
  final String dueDate;

  const GeoTask({
    required this.id,
    required this.fieldId,
    required this.title,
    required this.description,
    this.position,
    required this.assignee,
    required this.status,
    required this.dueDate,
  });

  GeoTask copyWith({
    String? status,
    String? title,
    String? description,
    LatLng? position,
    String? assignee,
    String? dueDate,
  }) {
    return GeoTask(
      id: id,
      fieldId: fieldId,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      assignee: assignee ?? this.assignee,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class GeoLayerSettings {
  final bool showSatellite;
  final bool showNdvi;
  final bool showSoil;
  final bool showWeather;
  final bool showTerrain;
  final bool showIrrigation;
  final double opacityNdvi;
  final double opacitySoil;
  final double opacityWeather;

  const GeoLayerSettings({
    this.showSatellite = false,
    this.showNdvi = true,
    this.showSoil = false,
    this.showWeather = false,
    this.showTerrain = false,
    this.showIrrigation = true,
    this.opacityNdvi = 0.6,
    this.opacitySoil = 0.5,
    this.opacityWeather = 0.5,
  });

  GeoLayerSettings copyWith({
    bool? showSatellite,
    bool? showNdvi,
    bool? showSoil,
    bool? showWeather,
    bool? showTerrain,
    bool? showIrrigation,
    double? opacityNdvi,
    double? opacitySoil,
    double? opacityWeather,
  }) {
    return GeoLayerSettings(
      showSatellite: showSatellite ?? this.showSatellite,
      showNdvi: showNdvi ?? this.showNdvi,
      showSoil: showSoil ?? this.showSoil,
      showWeather: showWeather ?? this.showWeather,
      showTerrain: showTerrain ?? this.showTerrain,
      showIrrigation: showIrrigation ?? this.showIrrigation,
      opacityNdvi: opacityNdvi ?? this.opacityNdvi,
      opacitySoil: opacitySoil ?? this.opacitySoil,
      opacityWeather: opacityWeather ?? this.opacityWeather,
    );
  }
}
