import 'verdi_agro_autonomous_agent.dart';

/// Specialized Live Multilingual Agronomy Knowledge Engine for Verdi AI.
class ShonaAgronomyBrain {
  ShonaAgronomyBrain._();
  static final ShonaAgronomyBrain instance = ShonaAgronomyBrain._();

  /// Processes [prompt] via Live Neural AI Agent.
  Future<String> processQueryAsync(String prompt) async {
    return VerdiAgroAutonomousAgent.instance.processQuery(prompt);
  }

  /// Synchronous fallback (delegates to live query processing).
  Future<String> generateShonaResponseAsync(String prompt) async {
    return VerdiAgroAutonomousAgent.instance.processQuery(prompt);
  }
}
