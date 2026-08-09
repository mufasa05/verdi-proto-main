import 'package:verdi/features/crop_health/data/crop_health_models.dart';

class MockCropHealthRepository {
  const MockCropHealthRepository();

  CropHealthSnapshot fetchSnapshot() {
    return CropHealthSnapshot(
      capturedAt: DateTime(2026, 6, 25, 8, 30),
      title: 'Crop health snapshot',
      summary:
          'Multi-index satellite monitoring with stress detection and treatment tracking.',
      fieldIndexReadings: [
        FieldIndexReading(
          label: 'NDVI',
          value: 0.78,
          trend: '+5%',
          detail: 'Strong vegetation health',
        ),
        FieldIndexReading(
          label: 'NDRE',
          value: 0.62,
          trend: '+3%',
          detail: 'Nitrogen response looks healthy',
        ),
        FieldIndexReading(
          label: 'MSAVI',
          value: 0.71,
          trend: '+4%',
          detail: 'Canopy structure remains stable',
        ),
        FieldIndexReading(
          label: 'Biomass',
          value: 0.68,
          trend: '+6%',
          detail: 'Above-average biomass growth',
        ),
      ],
      fields: [
        FieldHealthDetail(
          name: 'Mvurwi North',
          crop: 'Maize',
          ndvi: 0.82,
          ndre: 0.70,
          msavi: 0.76,
          biomass: 0.72,
          stressLevel: 0.18,
          hotspotCount: 2,
          lastScanned: '5d ago',
          fieldStatus: 'Healthy',
          notes: 'Consistent irrigation and strong canopy cover.',
        ),
        FieldHealthDetail(
          name: 'Odzi Block',
          crop: 'Tomatoes',
          ndvi: 0.51,
          ndre: 0.44,
          msavi: 0.49,
          biomass: 0.42,
          stressLevel: 0.49,
          hotspotCount: 6,
          lastScanned: '2d ago',
          fieldStatus: 'Moderate stress',
          notes: 'Possible nutrient deficiency and uneven irrigation.',
        ),
        FieldHealthDetail(
          name: 'Gutu Plot',
          crop: 'Onions',
          ndvi: 0.68,
          ndre: 0.61,
          msavi: 0.63,
          biomass: 0.66,
          stressLevel: 0.31,
          hotspotCount: 3,
          lastScanned: '1d ago',
          fieldStatus: 'Watch',
          notes: 'Localized water stress near the southern edge.',
        ),
      ],
      stressZones: [
        StressZone(
          zoneLabel: 'North patch',
          issue: 'Water stress',
          severity: 0.72,
          needsScouting: true,
        ),
        StressZone(
          zoneLabel: 'East row',
          issue: 'Nitrogen deficiency',
          severity: 0.56,
          needsScouting: true,
        ),
        StressZone(
          zoneLabel: 'Southwest',
          issue: 'Pest pressure',
          severity: 0.48,
          needsScouting: false,
        ),
      ],
      scoutingNotes: [
        ScoutingNote(
          title: 'Yellowing leaves',
          location: 'Odzi Block',
          note:
              'Found patchy yellowing near the east boundary. Need leaf tissue test.',
          photoUrl:
              'https://images.unsplash.com/photo-1524594142864-7cc5d27c2d6f?auto=format&fit=crop&w=900&q=80',
          recordedAt: '2026-06-23 15:14',
        ),
        ScoutingNote(
          title: 'Dry furrows',
          location: 'Gutu Plot',
          note: 'Irrigation line appears clogged on the south side.',
          photoUrl:
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
          recordedAt: '2026-06-24 09:42',
        ),
      ],
      imageDiagnoses: [
        ImageDiagnosis(
          issue: 'Early leaf blight',
          confidence: '82%',
          recommendedAction: 'Apply fungicide in the next 24h',
          imageUrl:
              'https://images.unsplash.com/photo-1519337265831-281ec6cc8514?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      weatherRisk: WeatherRisk(
        summary: 'Storm and wind risk in 48h with elevated disease pressure.',
        level: 'High',
        alerts: ['Storm warning', 'High humidity', 'Increased disease risk'],
      ),
      recommendations: [
        Recommendation(
          title: 'Check irrigation valves',
          detail:
              'Inspect the Odzi Block east line for blockages and flush if needed.',
          priority: 'High',
        ),
        Recommendation(
          title: 'Apply nitrogen top-up',
          detail: 'Target low-N zones on Gutu Plot after scouting.',
          priority: 'Medium',
        ),
      ],
      treatmentHistory: [
        TreatmentLog(
          action: 'Applied foliar fertilizer',
          date: '2026-06-19',
          result: 'NDVI improved by 4% in treated zones.',
          notes: 'Follow-up inspection scheduled in 5 days.',
        ),
        TreatmentLog(
          action: 'Checked irrigation pump',
          date: '2026-06-22',
          result: 'Increased water pressure by 12%.',
          notes: 'No further action required unless stress persists.',
        ),
      ],
      comparison: HealthComparison(
        periodLabel: 'Last 7 days',
        previousHealth: 0.69,
        currentHealth: 0.74,
        trend: '+7%',
      ),
    );
  }
}
