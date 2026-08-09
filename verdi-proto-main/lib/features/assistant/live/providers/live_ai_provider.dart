import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../core/services/verdi_api_service.dart';
import '../models/live_ai_chunk.dart';
import '../models/live_ai_event.dart';
import '../services/live_ai_stream_service.dart';

class LiveAiProvider extends ChangeNotifier {
  final LiveAiStreamService service;

  LiveAiProvider({required this.service});

  bool connected = false;
  bool streamingReply = false;
  String currentReply = '';
  String latestPrompt = '';
  String? errorMessage;

  final List<LiveAiEvent> events = [];
  final List<String> liveSummaries = [];

  StreamSubscription<LiveAiEvent>? _eventSub;

  Future<void> connect() async {
    try {
      connected = true;
      errorMessage = null;
      _eventSub ??= service.subscribeToPlatformEvents().listen(
        _handleEvent,
        onError: (e) {
          errorMessage = e.toString();
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      connected = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _eventSub?.cancel();
    _eventSub = null;
    await service.disconnect();
    connected = false;
    notifyListeners();
  }



  Future<void> sendPrompt(String prompt, String conversationId) async {
    latestPrompt = prompt;
    currentReply = '';
    streamingReply = true;
    errorMessage = null;
    notifyListeners();

    try {
      await for (final LiveAiChunk chunk in service.streamAssistantReply(
        conversationId: conversationId,
        prompt: prompt,
      )) {
        currentReply += chunk.text;
        if (chunk.isFinal) {
          streamingReply = false;
        }
        notifyListeners();
      }

      if (currentReply.trim().isNotEmpty) {
        liveSummaries.insert(0, currentReply.trim());
      }
    } catch (e) {
      try {
        final backendReply = await VerdiApiService.instance.askBackendAi(prompt);
        currentReply = backendReply;
        streamingReply = false;
        notifyListeners();
        if (currentReply.trim().isNotEmpty) {
          liveSummaries.insert(0, currentReply.trim());
        }
        return;
      } catch (_) {}

      errorMessage = _formatError(e);
      streamingReply = false;
      notifyListeners();
    }
  }

  String _formatError(Object error) {
    final message = error.toString();
    if (message.contains('SocketException') || message.contains('Connection refused') || message.contains('errno = 111')) {
      return '⚠️ Backend AI service unreachable at ${VerdiApiService.instance.baseUrl}. Switched to local offline Agronomist.';
    }
    if (message.contains('Stream failed')) {
      return '⚠️ Stream disconnected. Please verify that the NestJS backend and Ollama are running.';
    }
    return message;
  }

  void _handleEvent(LiveAiEvent event) {
    events.insert(0, event);

    final summary = _summarizeEvent(event);
    if (summary.isNotEmpty) {
      liveSummaries.insert(0, summary);
    }

    if (liveSummaries.length > 25) {
      liveSummaries.removeLast();
    }

    notifyListeners();
  }

  String _summarizeEvent(LiveAiEvent event) {
    switch (event.type) {
      case LiveAiEventType.alert:
        return '${event.sourceModule}: ${event.title}';
      case LiveAiEventType.summary:
        return event.message;
      case LiveAiEventType.insight:
        return 'Insight: ${event.message}';
      case LiveAiEventType.task:
        return 'Task: ${event.title}';
      case LiveAiEventType.action:
        return 'Action required: ${event.title}';
      case LiveAiEventType.token:
        return '';
      case LiveAiEventType.system:
        return 'System: ${event.message}';
    }
  }
}
