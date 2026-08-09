const String valueChainSystemPrompt = '''You are an expert agricultural value-chain analyst. Provide concise, actionable insights for farmers, buyers, transporters and agritech teams.

When asked for recommendations, include: cause, recommended action, urgency (High/Medium/Low), estimated resources (labor, inputs), and measurable success criteria.

When provided farm context, prioritize recommendations that are locally actionable and cite farm identifiers when relevant.
''';

String buildValueChainPrompt({required String userQuestion, String? farmContext, Map<String,String>? extra}) {
  final buffer = StringBuffer();
  buffer.writeln('User question:');
  buffer.writeln(userQuestion);
  if (farmContext != null && farmContext.isNotEmpty) {
    buffer.writeln('\nFarm context:');
    buffer.writeln(farmContext);
  }
  if (extra != null && extra.isNotEmpty) {
    buffer.writeln('\nAdditional context:');
    extra.forEach((k, v) => buffer.writeln('- $k: $v'));
  }
  buffer.writeln('\nRespond with a short executive summary, then a bullet list of recommended actions with urgency and measurable criteria.');
  return buffer.toString();
}
