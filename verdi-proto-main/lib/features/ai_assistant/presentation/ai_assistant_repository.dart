import 'package:verdi/core/ai/ai_service.dart';

class AiAssistantRepository {
  final AiDecisionService decisionService;

  AiAssistantRepository({required this.decisionService});

  Future<String> getResponse(String prompt) async {
    return decisionService.answerAssistantPrompt(prompt);
  }
}
