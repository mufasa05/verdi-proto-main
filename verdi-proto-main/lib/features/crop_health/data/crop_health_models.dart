class CropHealthSnapshot {
  final DateTime capturedAt;
  final String title;
  final String summary;
  final List<FieldIndexReading> fieldIndexReadings;
  final List<FieldHealthDetail> fields;
  final List<StressZone> stressZones;
  final List<ScoutingNote> scoutingNotes;
  final List<ImageDiagnosis> imageDiagnoses;
  final WeatherRisk weatherRisk;
  final List<Recommendation> recommendations;
  final List<TreatmentLog> treatmentHistory;
  final HealthComparison comparison;

  const CropHealthSnapshot({
    required this.capturedAt,
    required this.title,
    required this.summary,
    required this.fieldIndexReadings,
    required this.fields,
    required this.stressZones,
    required this.scoutingNotes,
    required this.imageDiagnoses,
    required this.weatherRisk,
    required this.recommendations,
    required this.treatmentHistory,
    required this.comparison,
  });
}

class FieldIndexReading {
  final String label;
  final double value;
  final String trend;
  final String detail;

  const FieldIndexReading({
    required this.label,
    required this.value,
    required this.trend,
    required this.detail,
  });
}

class FieldHealthDetail {
  final String name;
  final String crop;
  final double ndvi;
  final double ndre;
  final double msavi;
  final double biomass;
  final double stressLevel;
  final int hotspotCount;
  final String lastScanned;
  final String fieldStatus;
  final String notes;

  const FieldHealthDetail({
    required this.name,
    required this.crop,
    required this.ndvi,
    required this.ndre,
    required this.msavi,
    required this.biomass,
    required this.stressLevel,
    required this.hotspotCount,
    required this.lastScanned,
    required this.fieldStatus,
    required this.notes,
  });

  double get healthScore => (ndvi + ndre + msavi + biomass) / 4;
}

class StressZone {
  final String zoneLabel;
  final String issue;
  final double severity;
  final bool needsScouting;

  const StressZone({
    required this.zoneLabel,
    required this.issue,
    required this.severity,
    required this.needsScouting,
  });
}

class ScoutingNote {
  final String title;
  final String location;
  final String note;
  final String photoUrl;
  final String recordedAt;

  const ScoutingNote({
    required this.title,
    required this.location,
    required this.note,
    required this.photoUrl,
    required this.recordedAt,
  });
}

class ImageDiagnosis {
  final String issue;
  final String confidence;
  final String recommendedAction;
  final String imageUrl;

  const ImageDiagnosis({
    required this.issue,
    required this.confidence,
    required this.recommendedAction,
    required this.imageUrl,
  });
}

class WeatherRisk {
  final String summary;
  final String level;
  final List<String> alerts;

  const WeatherRisk({
    required this.summary,
    required this.level,
    required this.alerts,
  });
}

class Recommendation {
  final String title;
  final String detail;
  final String priority;

  const Recommendation({
    required this.title,
    required this.detail,
    required this.priority,
  });
}

class TreatmentLog {
  final String action;
  final String date;
  final String result;
  final String notes;

  const TreatmentLog({
    required this.action,
    required this.date,
    required this.result,
    required this.notes,
  });
}

class HealthComparison {
  final String periodLabel;
  final double previousHealth;
  final double currentHealth;
  final String trend;

  const HealthComparison({
    required this.periodLabel,
    required this.previousHealth,
    required this.currentHealth,
    required this.trend,
  });

  double get change => currentHealth - previousHealth;
}
