import 'package:verdi/features/crop_health/data/crop_health_models.dart';

class CropHealthAnalysis {
  final String executiveSummary;
  final List<Recommendation> recommendations;
  final List<String> alerts;
  final List<String> decisionFactors;

  CropHealthAnalysis({
    required this.executiveSummary,
    required this.recommendations,
    required this.alerts,
    required this.decisionFactors,
  });
}
