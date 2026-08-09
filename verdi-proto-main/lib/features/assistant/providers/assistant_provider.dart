import 'package:flutter/foundation.dart';
import '../models/assistant_models.dart';
import '../repositories/assistant_repository.dart';

class AssistantProvider extends ChangeNotifier {
  final AssistantRepository repository;

  AssistantProvider({required this.repository});

  bool loading = false;
  String? errorMessage;

  List<AssistantConversation> conversations = [];
  List<AssistantMessage> messages = [];
  List<AssistantSource> sources = [];
  List<AssistantTask> tasks = [];

  AssistantConversation? selectedConversation;
  String? aiSummary;

  Future<void> init() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      conversations = await repository.getConversations();
      selectedConversation = conversations.isNotEmpty
          ? conversations.first
          : await repository.createConversation('Verdi AI Copilot');
      conversations = await repository.getConversations();
      await loadConversation(selectedConversation!.id);
      tasks = await repository.getTasks();
      aiSummary = _buildSummary();
    } catch (e) {
      errorMessage = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loadConversation(String conversationId) async {
    selectedConversation = conversations.firstWhere((c) => c.id == conversationId);
    messages = await repository.getMessages(conversationId);
    aiSummary = _buildSummary();
    notifyListeners();
  }

  Future<void> sendMessage(
    String text, {
    List<String> attachments = const [],
  }) async {
    if (selectedConversation == null) {
      await init();
    }

    loading = true;
    notifyListeners();

    try {
      await repository.sendMessage(
        conversationId: selectedConversation!.id,
        text: text,
        attachments: attachments,
      );
      messages = await repository.getMessages(selectedConversation!.id);
      if (messages.isNotEmpty) {
        sources = await repository.getSources(messages.last.id);
      }
      aiSummary = _buildSummary();
    } catch (e) {
      errorMessage = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> createTask(String title, String module) async {
    tasks = [await repository.createTask(title, module), ...tasks];
    notifyListeners();
  }

  AssistantIntent get lastIntent =>
      messages.isEmpty ? AssistantIntent.generalQuestion : messages.last.intent;

  String _buildSummary() {
    final userCount = messages.where((m) => m.role == AssistantMessageRole.user).length;
    final assistantCount = messages.where((m) => m.role == AssistantMessageRole.assistant).length;
    return 'Conversation active: $userCount user message(s), $assistantCount assistant response(s), ${tasks.length} task(s) pending.';
  }
}