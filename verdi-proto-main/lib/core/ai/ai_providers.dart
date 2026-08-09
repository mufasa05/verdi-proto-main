import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';
import '../ai_data/ai_data_providers.dart';

final aiDecisionServiceProvider = Provider<AiDecisionService>((ref) {
  final repo = ref.watch(aiDataRepositoryProvider);
  return BackendAiDecisionService(dataRepo: repo);
});
