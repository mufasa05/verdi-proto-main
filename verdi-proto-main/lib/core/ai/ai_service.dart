import 'dart:convert';

import 'package:verdi/features/crop_health/data/crop_health_models.dart';
import 'package:verdi/core/ai_data/ai_data_repository.dart';
import 'package:verdi/core/services/verdi_api_service.dart';
import 'ai_models.dart';

export 'ai_models.dart';

abstract class AiDecisionService {
  bool get isLive;
  Future<CropHealthAnalysis> analyzeCropHealth(CropHealthSnapshot snapshot);
  Future<String> answerAssistantPrompt(String prompt, {CropHealthSnapshot? snapshot});
}

class BackendAiDecisionService implements AiDecisionService {
  final AiDataRepository? dataRepo;

  BackendAiDecisionService({this.dataRepo});

  @override
  bool get isLive => true;

  @override
  Future<CropHealthAnalysis> analyzeCropHealth(CropHealthSnapshot snapshot) async {
    final prompt = _buildCropHealthPrompt(snapshot);
    final responseText = await VerdiApiService.instance.askBackendAi(prompt);

    try {
      final raw = jsonDecode(responseText) as Map<String, dynamic>;
      final recommendations = (raw['recommendations'] as List<dynamic>).map((item) {
        return Recommendation(
          title: item['title'] as String,
          detail: item['detail'] as String,
          priority: item['priority'] as String,
        );
      }).toList();

      return CropHealthAnalysis(
        executiveSummary: raw['executiveSummary'] as String,
        recommendations: recommendations,
        alerts: List<String>.from(raw['alerts'] as List<dynamic>),
        decisionFactors: List<String>.from(raw['decisionFactors'] as List<dynamic>),
      );
    } catch (_) {
      return CropHealthAnalysis(
        executiveSummary: responseText,
        recommendations: snapshot.recommendations,
        alerts: [snapshot.weatherRisk.summary],
        decisionFactors: [],
      );
    }
  }

  @override
  Future<String> answerAssistantPrompt(String prompt, {CropHealthSnapshot? snapshot}) async {
    final fullPrompt = snapshot != null
        ? 'Crop health data: ${_serializeSnapshot(snapshot)}\n\nQuery: $prompt'
        : prompt;
    return VerdiApiService.instance.askBackendAi(fullPrompt);
  }

  String _buildCropHealthPrompt(CropHealthSnapshot snapshot) {
    final buffer = StringBuffer();
    buffer.writeln('Analyze the following crop health snapshot:');
    buffer.writeln('Title: ${snapshot.title}');
    buffer.writeln('Summary: ${snapshot.summary}');
    buffer.writeln('Weather risk: ${snapshot.weatherRisk.level} - ${snapshot.weatherRisk.summary}');
    return buffer.toString();
  }

  String _serializeSnapshot(CropHealthSnapshot snapshot) {
    return 'Title: ${snapshot.title} | Summary: ${snapshot.summary} | Weather: ${snapshot.weatherRisk.level}';
  }
}

AiDecisionService createAiDecisionService({String? apiKey, AiDataRepository? dataRepo}) {
  return BackendAiDecisionService(dataRepo: dataRepo);
}
