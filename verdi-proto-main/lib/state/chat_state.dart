import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatThread {
  final String title;
  final String subtitle;
  final List<ChatMessage> messages;
  final String? participantA;
  final String? participantB;

  ChatThread({
    required this.title,
    required this.subtitle,
    required this.messages,
    this.participantA,
    this.participantB,
  });
}

class ChatState {
  final List<ChatThread> threads;
  final int selectedIndex;

  ChatState({required this.threads, required this.selectedIndex});

  ChatState copyWith({
    List<ChatThread>? threads,
    int? selectedIndex,
  }) {
    return ChatState(
      threads: threads ?? this.threads,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
      : super(ChatState(
          threads: [
            ChatThread(
              title: 'Farm Planning',
              subtitle: 'Plan tomorrow’s planting schedule',
              messages: [
                ChatMessage(text: 'Good morning Sir Mufasa, how can I help today?', isUser: false),
                ChatMessage(text: 'Create a planting plan for tomatoes and maize.', isUser: true),
                ChatMessage(text: 'I can do that. How many hectares are you using?', isUser: false),
              ],
            ),
            ChatThread(
              title: 'Market Pricing',
              subtitle: 'Compare today’s crop prices',
              messages: [
                ChatMessage(text: 'Track tomato, maize, and onion prices.', isUser: true),
                ChatMessage(text: 'Tomatoes are trending up, maize is stable, onions are slightly lower.', isUser: false),
              ],
            ),
            ChatThread(
              title: 'Delivery Support',
              subtitle: 'Check transport availability',
              messages: [
                ChatMessage(text: 'Which trucks are available near Chiredzi?', isUser: true),
                ChatMessage(text: 'Two trucks are available within 10 km and one is ready now.', isUser: false),
              ],
            ),
          ],
          selectedIndex: 0,
        ));

  void selectThread(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void sendMessage(String text) {
    final thread = state.threads[state.selectedIndex];
    final updatedMessages = [...thread.messages, ChatMessage(text: text, isUser: true)];
    final updatedThread = ChatThread(
      title: thread.title,
      subtitle: thread.subtitle,
      messages: updatedMessages,
      participantA: thread.participantA,
      participantB: thread.participantB,
    );

    final updatedThreads = [...state.threads];
    updatedThreads[state.selectedIndex] = updatedThread;
    state = state.copyWith(threads: updatedThreads);
  }

  void receiveMessage(String text) {
    final thread = state.threads[state.selectedIndex];
    final updatedMessages = [...thread.messages, ChatMessage(text: text, isUser: false)];
    final updatedThread = ChatThread(
      title: thread.title,
      subtitle: thread.subtitle,
      messages: updatedMessages,
      participantA: thread.participantA,
      participantB: thread.participantB,
    );

    final updatedThreads = [...state.threads];
    updatedThreads[state.selectedIndex] = updatedThread;
    state = state.copyWith(threads: updatedThreads);
  }

  void startOrGetThread(String title, String subtitle, String initialMessage, {String? participantA, String? participantB}) {
    final index = state.threads.indexWhere((t) => t.title == title && 
        ((t.participantA == participantA && t.participantB == participantB) || 
         (t.participantA == participantB && t.participantB == participantA)));
    if (index != -1) {
      state = state.copyWith(selectedIndex: index);
      return;
    }

    final newThread = ChatThread(
      title: title,
      subtitle: subtitle,
      messages: [
        ChatMessage(text: initialMessage, isUser: false),
      ],
      participantA: participantA,
      participantB: participantB,
    );

    state = state.copyWith(
      threads: [...state.threads, newThread],
      selectedIndex: state.threads.length,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class VerdiAiChatNotifier extends StateNotifier<ChatThread> {
  VerdiAiChatNotifier()
      : super(ChatThread(
          title: 'Verdi AI Assistant',
          subtitle: 'Dedicated system copilot chat',
          messages: [
            ChatMessage(
              text: 'Hello! I am Verdi AI, your agricultural assistant. Ask me anything about crop yield, pricing, transport or logistics.',
              isUser: false,
            ),
          ],
        ));

  void sendMessage(String text) {
    state = ChatThread(
      title: state.title,
      subtitle: state.subtitle,
      messages: [...state.messages, ChatMessage(text: text, isUser: true)],
    );
  }

  void receiveMessage(String text) {
    state = ChatThread(
      title: state.title,
      subtitle: state.subtitle,
      messages: [...state.messages, ChatMessage(text: text, isUser: false)],
    );
  }

  void clear() {
    state = ChatThread(
      title: state.title,
      subtitle: state.subtitle,
      messages: [
        ChatMessage(
          text: 'Hello! I am Verdi AI, your agricultural assistant. Ask me anything about crop yield, pricing, transport or logistics.',
          isUser: false,
        ),
      ],
    );
  }
}

final verdiAiChatProvider = StateNotifierProvider<VerdiAiChatNotifier, ChatThread>((ref) {
  return VerdiAiChatNotifier();
});
