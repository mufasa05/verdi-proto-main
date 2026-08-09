import 'package:verdi/core/ai/ai_service.dart';
import 'package:verdi/features/crop_health/data/crop_health_models.dart';

class AiRepository {
  final AiDecisionService service;

  AiRepository({required this.service});

  Future<CropHealthAnalysis> analyzeCropHealth(CropHealthSnapshot snapshot) {
    return service.analyzeCropHealth(snapshot);
  }

  Future<String> answerAssistantPrompt(String prompt, {CropHealthSnapshot? snapshot}) {
    return service.answerAssistantPrompt(prompt, snapshot: snapshot);
  }
}
