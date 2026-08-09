import '../../../core/viewmodels/page_view_model.dart';

class AiAssistantViewModel extends PageViewModel {
  AiAssistantViewModel() {
    loadAssistant();
  }

  Future<void> loadAssistant() async {
    setLoading(
      title: 'Loading AI assistant',
      message: 'Preparing smart suggestions and chat tools.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setEmpty(
      title: 'AI assistant is coming soon',
      message: 'Chat, recommendations, and automation will appear here.',
    );
  }
}