import '../models/assistant_models.dart';
import '../services/verdi_agro_autonomous_agent.dart';

abstract class AssistantRepository {
  Future<List<AssistantConversation>> getConversations();
  Future<List<AssistantMessage>> getMessages(String conversationId);
  Future<AssistantConversation> createConversation(String title);
  Future<AssistantMessage> sendMessage({
    required String conversationId,
    required String text,
    List<String> attachments,
  });
  Future<List<AssistantSource>> getSources(String messageId);
  Future<List<AssistantTask>> getTasks();
  Future<AssistantTask> createTask(String title, String module);
}

class InMemoryAssistantRepository implements AssistantRepository {
  final List<AssistantConversation> _conversations = [];
  final List<AssistantMessage> _messages = [];
  final List<AssistantSource> _sources = [];
  final List<AssistantTask> _tasks = [];

  InMemoryAssistantRepository() {
    final convo = AssistantConversation(
      id: 'c1',
      title: 'Verdi AI Copilot',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: true,
    );
    _conversations.add(convo);

    _messages.addAll([
      AssistantMessage(
        id: 'm1',
        conversationId: convo.id,
        role: AssistantMessageRole.assistant,
        text: 'Hello, I can help with crops, orders, trade, payments, alerts, and platform activity.',
        createdAt: DateTime.now(),
        confidence: AssistantConfidenceLevel.high,
        intent: AssistantIntent.generalQuestion,
      ),
      AssistantMessage(
        id: 'm2',
        conversationId: convo.id,
        role: AssistantMessageRole.assistant,
        text: 'You can ask: what is happening in the platform, which fields are at risk, which orders are delayed, or what needs action now.',
        createdAt: DateTime.now(),
        confidence: AssistantConfidenceLevel.high,
        intent: AssistantIntent.notificationSummary,
      ),
    ]);

    _sources.addAll([
      AssistantSource(
        id: 's1',
        module: 'notifications',
        title: 'Platform event feed',
        detail: 'Aggregated notifications across all modules.',
        weight: 0.9,
        createdAt: DateTime.now(),
      ),
      AssistantSource(
        id: 's2',
        module: 'crop_health',
        title: 'Crop health snapshots',
        detail: 'Satellite and scouting driven health data.',
        weight: 0.85,
        createdAt: DateTime.now(),
      ),
    ]);
  }

  String _id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  @override
  Future<List<AssistantConversation>> getConversations() async {
    return List.unmodifiable(_conversations);
  }

  @override
  Future<List<AssistantMessage>> getMessages(String conversationId) async {
    return List.unmodifiable(
      _messages.where((m) => m.conversationId == conversationId).toList(),
    );
  }

  @override
  Future<AssistantConversation> createConversation(String title) async {
    final c = AssistantConversation(
      id: _id('c'),
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _conversations.insert(0, c);
    return c;
  }

  @override
  Future<AssistantMessage> sendMessage({
    required String conversationId,
    required String text,
    List<String> attachments = const [],
  }) async {
    final user = AssistantMessage(
      id: _id('m'),
      conversationId: conversationId,
      role: AssistantMessageRole.user,
      text: text,
      attachmentUrls: attachments,
      createdAt: DateTime.now(),
    );
    _messages.add(user);

    final backendText = await VerdiAgroAutonomousAgent.instance.processQuery(text);

    final reply = AssistantMessage(
      id: _id('m'),
      conversationId: conversationId,
      role: AssistantMessageRole.assistant,
      text: backendText,
      createdAt: DateTime.now(),
      confidence: AssistantConfidenceLevel.high,
      intent: _classify(text),
      sourceIds: _sources.map((e) => e.id).toList(),
      actionLabel: 'Open related view',
      actionRoute: '/notifications',
    );
    _messages.add(reply);
    return reply;
  }

  @override
  Future<List<AssistantSource>> getSources(String messageId) async {
    return List.unmodifiable(_sources);
  }

  @override
  Future<List<AssistantTask>> getTasks() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<AssistantTask> createTask(String title, String module) async {
    final t = AssistantTask(
      id: _id('t'),
      title: title,
      module: module,
      status: 'open',
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, t);
    return t;
  }

  AssistantIntent _classify(String text) {
    final t = text.toLowerCase();
    if (t.contains('order')) return AssistantIntent.orderQuery;
    if (t.contains('payment')) return AssistantIntent.paymentQuery;
    if (t.contains('trade') || t.contains('export')) return AssistantIntent.tradeQuery;
    if (t.contains('weather')) return AssistantIntent.weatherQuery;
    if (t.contains('crop')) return AssistantIntent.cropHealthQuery;
    if (t.contains('notification') || t.contains('what is happening')) return AssistantIntent.notificationSummary;
    if (t.contains('image') || t.contains('photo')) return AssistantIntent.imageDiagnosis;
    return AssistantIntent.generalQuestion;
  }


}