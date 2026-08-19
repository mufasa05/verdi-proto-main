import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../features/auth/state/auth_state.dart';
import 'app_state.dart';
import 'platform_data_state.dart';

class ChatMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final String timestamp;
  final String exactTime;
  final bool isUser;
  final Map<String, dynamic>? orderAttachment;

  ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    required this.exactTime,
    required this.isUser,
    this.orderAttachment,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'text': text,
        'timestamp': timestamp,
        'exactTime': exactTime,
        'orderAttachment': orderAttachment,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json, {required String currentUserId}) {
    final sId = json['senderId']?.toString() ?? '';
    return ChatMessage(
      id: json['id']?.toString() ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      threadId: json['threadId']?.toString() ?? 'global_trade_room',
      senderId: sId,
      senderName: json['senderName']?.toString() ?? 'Stakeholder',
      senderRole: json['senderRole']?.toString() ?? 'Farmer',
      text: json['text']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? 'Just now',
      exactTime: json['exactTime']?.toString() ?? DateTime.now().toIso8601String(),
      isUser: sId.isNotEmpty && sId == currentUserId,
      orderAttachment: json['orderAttachment'] as Map<String, dynamic>?,
    );
  }
}

class ChatThread {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'Marketplace', 'Logistics', 'Advisory', 'Support', 'AI'
  final List<ChatMessage> messages;
  final String? participantA;
  final String? participantB;
  final String? participantARole;
  final String? participantBRole;
  final int unreadCount;

  ChatThread({
    required this.id,
    required this.title,
    required this.subtitle,
    this.category = 'Marketplace',
    required this.messages,
    this.participantA,
    this.participantB,
    this.participantARole,
    this.participantBRole,
    this.unreadCount = 0,
  });

  ChatThread copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    List<ChatMessage>? messages,
    String? participantA,
    String? participantB,
    String? participantARole,
    String? participantBRole,
    int? unreadCount,
  }) {
    return ChatThread(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      messages: messages ?? this.messages,
      participantA: participantA ?? this.participantA,
      participantB: participantB ?? this.participantB,
      participantARole: participantARole ?? this.participantARole,
      participantBRole: participantBRole ?? this.participantBRole,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
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
  final bool isDemo;
  final Ref ref;
  StreamSubscription<Map<String, dynamic>>? _chatSub;

  static final List<ChatThread> _demoThreads = [
    ChatThread(
      id: 'th_ai_advisor',
      title: 'Verdi AI Agronomist',
      subtitle: 'Sovereign Agricultural Copilot · 24/7',
      category: 'AI',
      messages: [
        ChatMessage(
          id: 'msg_001',
          threadId: 'th_ai_advisor',
          senderId: 'SYS_AI',
          senderName: 'Verdi AI',
          senderRole: 'AI Engine',
          text: 'Good day! I am your AI Agronomist. Ask me about weather forecasts, EUDR compliance, pest management, or market prices.',
          timestamp: '10:00 AM',
          exactTime: '2026-08-19T10:00:00Z',
          isUser: false,
        ),
      ],
    ),
    ChatThread(
      id: 'th_mkt_beans',
      title: 'FreshMart Procurement (Buyer)',
      subtitle: 'Order #ORD-1001 negotiation · Sugar Beans',
      category: 'Marketplace',
      participantA: 'Kudakwashe Moyo',
      participantB: 'FreshMart Buyer',
      messages: [
        ChatMessage(
          id: 'msg_002',
          threadId: 'th_mkt_beans',
          senderId: 'USR-BYR-003',
          senderName: 'Farai Chimanzi',
          senderRole: 'Buyer',
          text: 'Greetings! We are looking to contract 2,500 kg of Sugar Beans for the Harare warehouse. Is your batch ready for dispatch?',
          timestamp: '10:15 AM',
          exactTime: '2026-08-19T10:15:00Z',
          isUser: false,
          orderAttachment: {
            'commodity': 'Grade-A Sugar Beans',
            'quantity': '2,500 kg',
            'price': 'US\$ 1.20 / kg',
            'escrowState': 'Ready for Lock',
          },
        ),
      ],
    ),
    ChatThread(
      id: 'th_log_truck',
      title: 'Tafadzwa Freight (Transporter)',
      subtitle: 'Truck SCANIA-AEB2910 · Reefer Available',
      category: 'Logistics',
      participantA: 'Kudakwashe Moyo',
      participantB: 'Tafadzwa M.',
      messages: [
        ChatMessage(
          id: 'msg_003',
          threadId: 'th_log_truck',
          senderId: 'USR-TRP-002',
          senderName: 'Tafadzwa M.',
          senderRole: 'Transporter',
          text: 'Hello, my 12-tonne refrigerated truck is currently in Chegutu and can load by 14:00 CAT.',
          timestamp: '11:05 AM',
          exactTime: '2026-08-19T11:05:00Z',
          isUser: false,
        ),
      ],
    ),
  ];

  static final List<ChatThread> _liveThreads = [];

  ChatNotifier({required this.isDemo, required this.ref})
      : super(ChatState(
          threads: isDemo ? [..._demoThreads] : [..._liveThreads],
          selectedIndex: 0,
        )) {
    _initRealtimeChatListener();
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    super.dispose();
  }

  void _initRealtimeChatListener() {
    _chatSub = SupabaseService.instance.chatStream.listen((payload) {
      _handleIncomingMessagePayload(payload);
    });
  }

  void _handleIncomingMessagePayload(Map<String, dynamic> payload) {
    try {
      final currentUserId = ref.read(authStateProvider).user?.id ?? 'USR-UNKNOWN';
      final msg = ChatMessage.fromJson(payload, currentUserId: currentUserId);

      final existingThreadIndex = state.threads.indexWhere((t) => t.id == msg.threadId);

      if (existingThreadIndex != -1) {
        final thread = state.threads[existingThreadIndex];
        if (thread.messages.any((m) => m.id == msg.id)) return;

        final updatedThread = thread.copyWith(
          messages: [...thread.messages, msg],
          subtitle: '${msg.senderName}: ${msg.text}',
        );

        final updatedThreads = [...state.threads];
        updatedThreads[existingThreadIndex] = updatedThread;

        state = state.copyWith(threads: updatedThreads);
      } else {
        final newThread = ChatThread(
          id: msg.threadId,
          title: '${msg.senderName} (${msg.senderRole})',
          subtitle: msg.text,
          category: 'Marketplace',
          messages: [msg],
        );

        state = state.copyWith(
          threads: [newThread, ...state.threads],
          selectedIndex: 0,
        );
      }
    } catch (_) {}
  }

  void selectThread(int index) {
    if (index >= 0 && index < state.threads.length) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  void sendMessage(String text, {Map<String, dynamic>? orderAttachment}) {
    if (state.threads.isEmpty || text.trim().isEmpty) return;

    final currentUser = ref.read(authStateProvider).user;
    final currentRole = ref.read(appStateProvider).role;
    final currentUserId = currentUser?.id ?? 'USR-CURRENT';
    final currentUserName = currentUser?.fullName ?? 'Stakeholder';

    final thread = state.threads[state.selectedIndex];
    final msgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    final newMsg = ChatMessage(
      id: msgId,
      threadId: thread.id,
      senderId: currentUserId,
      senderName: currentUserName,
      senderRole: currentRole.label,
      text: text.trim(),
      timestamp: 'Just now',
      exactTime: DateTime.now().toIso8601String(),
      isUser: true,
      orderAttachment: orderAttachment,
    );

    final updatedMessages = [...thread.messages, newMsg];
    final updatedThread = thread.copyWith(
      messages: updatedMessages,
      subtitle: 'You: ${newMsg.text}',
    );

    final updatedThreads = [...state.threads];
    updatedThreads[state.selectedIndex] = updatedThread;
    state = state.copyWith(threads: updatedThreads);

    // Broadcast across all connected devices
    SupabaseService.instance.broadcastChatMessage(newMsg.toJson());

    // Also log in platform activity provider
    ref.read(platformActivityProvider.notifier).logActivity(
          PlatformActivityEvent(
            id: 'evt_chat_${DateTime.now().millisecondsSinceEpoch}',
            userName: currentUserName,
            userId: currentUserId,
            userRole: currentRole,
            userAvatar: currentUserName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(),
            actionTitle: '💬 Sent Direct Message',
            actionDescription: 'Message sent in ${thread.title}: "${newMsg.text}"',
            timestamp: 'Just now',
            exactTime: DateTime.now().toIso8601String(),
            module: 'Messaging',
            device: 'Verdi Mobile / Web Client',
            status: 'Success',
            targetResource: 'Thread #${thread.id}',
            ipAddress: 'Active Node',
            metadata: {'threadId': thread.id, 'text': newMsg.text},
          ),
        );

    // If chatting with AI, generate response
    if (thread.category == 'AI' || thread.id == 'th_ai_advisor') {
      _generateAiResponse(text, thread.id);
    }
  }

  Future<void> _generateAiResponse(String userPrompt, String threadId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final promptLower = userPrompt.toLowerCase();
    String aiReply = 'I have analyzed your query across regional soil matrices and weather data. ';

    if (promptLower.contains('price') || promptLower.contains('market')) {
      aiReply += 'Today in Harare and Bulawayo: Grade-A Sugar Beans are trading at US\$ 1.20/kg, Maize at US\$ 335/Tonne, and Tomatoes at US\$ 0.85/kg with strong buyer demand.';
    } else if (promptLower.contains('pest') || promptLower.contains('disease') || promptLower.contains('leaf') || promptLower.contains('spot')) {
      aiReply += 'Based on current humidity (68%) and temperature (24°C), inspect for early blight or Fall Armyworm. Recommended treatment: Biological Bt spray or neem extract with 48h pre-harvest interval.';
    } else if (promptLower.contains('truck') || promptLower.contains('transport') || promptLower.contains('logistics')) {
      aiReply += 'There are currently 4 verified refrigerated freight trucks within 25 km of your location on the Harare-Chiredzi corridor ready for dispatch.';
    } else {
      aiReply += 'Your farm telemetry indicates optimal NDVI vegetative index (0.76). Recommend maintaining drip irrigation schedule of 45 mins at dawn.';
    }

    final aiMsg = ChatMessage(
      id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
      threadId: threadId,
      senderId: 'SYS_AI',
      senderName: 'Verdi AI Agronomist',
      senderRole: 'AI Engine',
      text: aiReply,
      timestamp: 'Just now',
      exactTime: DateTime.now().toIso8601String(),
      isUser: false,
    );

    final threadIdx = state.threads.indexWhere((t) => t.id == threadId);
    if (threadIdx != -1) {
      final t = state.threads[threadIdx];
      final updatedT = t.copyWith(
        messages: [...t.messages, aiMsg],
        subtitle: aiReply,
      );
      final updatedList = [...state.threads];
      updatedList[threadIdx] = updatedT;
      state = state.copyWith(threads: updatedList);

      SupabaseService.instance.broadcastChatMessage(aiMsg.toJson());
    }
  }

  void startOrGetThread(
    String title,
    String subtitle, [
    String? initialMessage,
    String? category,
    String? participantA,
    String? participantB,
    Map<String, dynamic>? orderAttachment,
  ]) {
    final existingIdx = state.threads.indexWhere((t) =>
        t.title.toLowerCase() == title.toLowerCase() ||
        (participantA != null && t.participantA == participantA && t.participantB == participantB));

    if (existingIdx != -1) {
      state = state.copyWith(selectedIndex: existingIdx);
      if (initialMessage != null && initialMessage.isNotEmpty) {
        sendMessage(initialMessage, orderAttachment: orderAttachment);
      }
      return;
    }

    final threadId = 'th_${DateTime.now().millisecondsSinceEpoch}';
    final newThread = ChatThread(
      id: threadId,
      title: title,
      subtitle: subtitle,
      category: category ?? 'Marketplace',
      participantA: participantA,
      participantB: participantB,
      messages: initialMessage != null
          ? [
              ChatMessage(
                id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                threadId: threadId,
                senderId: ref.read(authStateProvider).user?.id ?? 'USR-CURRENT',
                senderName: ref.read(authStateProvider).user?.fullName ?? 'Stakeholder',
                senderRole: ref.read(appStateProvider).role.label,
                text: initialMessage,
                timestamp: 'Just now',
                exactTime: DateTime.now().toIso8601String(),
                isUser: true,
                orderAttachment: orderAttachment,
              ),
            ]
          : [],
    );

    state = state.copyWith(
      threads: [newThread, ...state.threads],
      selectedIndex: 0,
    );

    if (initialMessage != null) {
      SupabaseService.instance.broadcastChatMessage(newThread.messages.first.toJson());
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  return ChatNotifier(isDemo: isDemo, ref: ref);
});

class VerdiAiChatNotifier extends StateNotifier<ChatThread> {
  VerdiAiChatNotifier()
      : super(ChatThread(
          id: 'th_copilot_assistant',
          title: 'Verdi AI Assistant',
          subtitle: 'Dedicated system copilot chat',
          category: 'AI',
          messages: [
            ChatMessage(
              id: 'msg_copilot_001',
              threadId: 'th_copilot_assistant',
              senderId: 'SYS_AI',
              senderName: 'Verdi AI',
              senderRole: 'AI Engine',
              text: 'Hello! I am Verdi AI, your agricultural assistant. Ask me anything about crop yield, pricing, transport or logistics.',
              timestamp: 'Just now',
              exactTime: DateTime.now().toIso8601String(),
              isUser: false,
            ),
          ],
        ));

  void sendMessage(String text) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          threadId: state.id,
          senderId: 'USR-LOCAL',
          senderName: 'You',
          senderRole: 'User',
          text: text,
          timestamp: 'Just now',
          exactTime: DateTime.now().toIso8601String(),
          isUser: true,
        ),
      ],
    );
  }

  void receiveMessage(String text) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          threadId: state.id,
          senderId: 'SYS_AI',
          senderName: 'Verdi AI',
          senderRole: 'AI Engine',
          text: text,
          timestamp: 'Just now',
          exactTime: DateTime.now().toIso8601String(),
          isUser: false,
        ),
      ],
    );
  }

  void clear() {
    state = ChatThread(
      id: 'th_copilot_assistant',
      title: 'Verdi AI Assistant',
      subtitle: 'Dedicated system copilot chat',
      category: 'AI',
      messages: [
        ChatMessage(
          id: 'msg_copilot_001',
          threadId: 'th_copilot_assistant',
          senderId: 'SYS_AI',
          senderName: 'Verdi AI',
          senderRole: 'AI Engine',
          text: 'Hello! I am Verdi AI, your agricultural assistant. Ask me anything about crop yield, pricing, transport or logistics.',
          timestamp: 'Just now',
          exactTime: DateTime.now().toIso8601String(),
          isUser: false,
        ),
      ],
    );
  }
}

final verdiAiChatProvider = StateNotifierProvider<VerdiAiChatNotifier, ChatThread>((ref) {
  return VerdiAiChatNotifier();
});
