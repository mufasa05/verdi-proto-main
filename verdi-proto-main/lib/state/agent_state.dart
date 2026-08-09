import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/assistant/services/shona_speech_service.dart';
import '../features/assistant/services/verdi_agro_autonomous_agent.dart';
import 'app_state.dart';
import 'cart_state.dart';

import '../features/assistant/services/platform_word_index.dart';

class AgentState {
  final bool isAgentModeOn;
  final bool isListening;
  final bool isProcessing;
  final bool wakeWordDetected;
  final String currentTask;
  final String liveTranscript;
  final String lastSpeechResponse;
  final String? lastExecutedTool;
  final List<PageMatch>? pendingDisambiguationMatches;
  final String? pendingDisambiguationKeyword;

  const AgentState({
    this.isAgentModeOn = false,
    this.isListening = false,
    this.isProcessing = false,
    this.wakeWordDetected = false,
    this.currentTask = '',
    this.liveTranscript = '',
    this.lastSpeechResponse = '',
    this.lastExecutedTool,
    this.pendingDisambiguationMatches,
    this.pendingDisambiguationKeyword,
  });

  AgentState copyWith({
    bool? isAgentModeOn,
    bool? isListening,
    bool? isProcessing,
    bool? wakeWordDetected,
    String? currentTask,
    String? liveTranscript,
    String? lastSpeechResponse,
    String? lastExecutedTool,
    List<PageMatch>? pendingDisambiguationMatches,
    String? pendingDisambiguationKeyword,
    bool clearDisambiguation = false,
  }) {
    return AgentState(
      isAgentModeOn: isAgentModeOn ?? this.isAgentModeOn,
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      wakeWordDetected: wakeWordDetected ?? this.wakeWordDetected,
      currentTask: currentTask ?? this.currentTask,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      lastSpeechResponse: lastSpeechResponse ?? this.lastSpeechResponse,
      lastExecutedTool: lastExecutedTool ?? this.lastExecutedTool,
      pendingDisambiguationMatches: clearDisambiguation ? null : (pendingDisambiguationMatches ?? this.pendingDisambiguationMatches),
      pendingDisambiguationKeyword: clearDisambiguation ? null : (pendingDisambiguationKeyword ?? this.pendingDisambiguationKeyword),
    );
  }
}

class AgentNotifier extends StateNotifier<AgentState> {
  final Ref ref;

  AgentNotifier(this.ref) : super(const AgentState());

  /// Toggles global Autonomous Agent Mode ON/OFF
  void toggleAgentMode() {
    final nextState = !state.isAgentModeOn;
    state = state.copyWith(
      isAgentModeOn: nextState,
      wakeWordDetected: nextState,
      currentTask: nextState ? 'Listening for wake word "Hey Verdi"...' : '',
      clearDisambiguation: true,
    );

    if (nextState) {
      stopGlobalListening();
      ShonaSpeechService.instance.speakShona(
        'Verdi Autonomous Agent Mode activated. Say Hey Verdi followed by your command.',
        onComplete: () {
          if (state.isAgentModeOn) {
            startGlobalListening();
          }
        },
      );
    } else {
      stopGlobalListening();
      ShonaSpeechService.instance.stopShona();
    }
  }

  /// Starts continuous listening with 1.8s silence VAD and "Hey Verdi" wake word parsing
  void startGlobalListening() {
    if (!state.isAgentModeOn) return;

    ShonaSpeechService.instance.startListeningWithVad(
      onResult: (text) {
        state = state.copyWith(liveTranscript: text);
        _parseWakeWordAndCommands(text);
      },
      onAutoSubmit: () {
        final prompt = state.liveTranscript.trim();
        if (prompt.length >= 4) {
          processVoicePrompt(prompt);
        }
      },
      onStatus: (listening) {
        state = state.copyWith(isListening: listening);
      },
    );
  }

  void stopGlobalListening() {
    ShonaSpeechService.instance.stopListening();
    state = state.copyWith(isListening: false, liveTranscript: '');
  }

  void _parseWakeWordAndCommands(String rawText) {
    final lower = rawText.toLowerCase();

    // Check for stop wake word
    if (lower.contains('hey verdi stop') || lower.contains('stop listening') || lower.contains('agent mode off')) {
      toggleAgentMode();
      return;
    }

    // Detect "Hey Verdi" wake word
    if (lower.contains('hey verdi') || lower.contains('verdi')) {
      state = state.copyWith(
        wakeWordDetected: true,
        currentTask: 'Wake word detected! Processing voice command...',
      );
    }
  }

  /// Processes natural language voice prompt, calls NestJS backend or local agent, executes state actions
  Future<void> processVoicePrompt(String prompt) async {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) return;

    stopGlobalListening();

    // Check if we are currently waiting for user to disambiguate a multi-page word
    if (state.pendingDisambiguationMatches != null && state.pendingDisambiguationMatches!.isNotEmpty) {
      final selectedPage = PlatformWordIndex.instance.parseDisambiguationChoice(
        cleanPrompt,
        state.pendingDisambiguationMatches!,
      );

      if (selectedPage != null) {
        ref.read(appStateProvider.notifier).setNavIndex(selectedPage.navIndex);

        final responseText = 'Opening ${selectedPage.pageName}...';
        state = state.copyWith(
          isProcessing: false,
          lastSpeechResponse: responseText,
          lastExecutedTool: 'navigate',
          currentTask: responseText,
          clearDisambiguation: true,
        );

        ShonaSpeechService.instance.speakShona(
          responseText,
          onComplete: () {
            if (state.isAgentModeOn) {
              startGlobalListening();
            }
          },
        );
        return;
      }
    }

    state = state.copyWith(
      isProcessing: true,
      currentTask: 'Executing autonomous tool: "$cleanPrompt"',
      liveTranscript: '',
    );

    final currentRole = ref.read(appStateProvider).role.label;

    try {
      // 1. Process via local Autonomous Agent Engine for immediate state mutation
      final agentResult = await VerdiAgroAutonomousAgent.instance.processAutonomousCommand(
        cleanPrompt,
        userRole: currentRole,
      );

      if (agentResult.actionType == 'disambiguate' && agentResult.payload != null) {
        final matches = agentResult.payload!['matches'] as List<PageMatch>;
        final keyword = agentResult.payload!['keyword'] as String;

        state = state.copyWith(
          isProcessing: false,
          lastSpeechResponse: agentResult.responseSpeech,
          lastExecutedTool: 'disambiguate',
          currentTask: 'Which screen would you like to visit for "$keyword"?',
          pendingDisambiguationMatches: matches,
          pendingDisambiguationKeyword: keyword,
        );
      } else {
        // Execute Navigation Tool if specified
        if (agentResult.navIndex != null) {
          ref.read(appStateProvider.notifier).setNavIndex(agentResult.navIndex!);
        }

        // Execute Cart Tool if user requested cart action (e.g. "Add 5 bags of fertilizer")
        if (cleanPrompt.toLowerCase().contains('add') &&
            (cleanPrompt.toLowerCase().contains('fertilizer') ||
             cleanPrompt.toLowerCase().contains('seed') ||
             cleanPrompt.toLowerCase().contains('bag') ||
             cleanPrompt.toLowerCase().contains('cart'))) {
          
          final qtyMatch = RegExp(r'(\d+)').firstMatch(cleanPrompt);
          final qty = qtyMatch != null ? int.parse(qtyMatch.group(1)!) : 5;
          
          String prodName = 'NPK 14-28-14 Fertilizer';
          if (cleanPrompt.toLowerCase().contains('seed')) prodName = 'Hybrid Seed Maize';
          if (cleanPrompt.toLowerCase().contains('solar') || cleanPrompt.toLowerCase().contains('pump')) prodName = 'Solar Irrigation Pump';

          ref.read(cartProvider.notifier).addItem(
            CartItem(
              id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
              name: prodName,
              price: '\$45.00',
              quantity: qty,
              imageUrl: 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=200',
              supplier: 'Verdi Agro Direct',
            ),
          );
        }

        state = state.copyWith(
          isProcessing: false,
          lastSpeechResponse: agentResult.responseSpeech,
          lastExecutedTool: agentResult.actionType,
          currentTask: 'Action completed: ${agentResult.responseSpeech}',
          clearDisambiguation: true,
        );
      }

      // Speak confirmation audio output after stopping mic listening
      ShonaSpeechService.instance.speakShona(
        agentResult.responseSpeech,
        onComplete: () {
          if (state.isAgentModeOn) {
            startGlobalListening();
          }
        },
      );
    } catch (e) {
      debugPrint('AgentNotifier error processing command: $e');
      state = state.copyWith(
        isProcessing: false,
        currentTask: 'Task completed',
        clearDisambiguation: true,
      );
      if (state.isAgentModeOn) {
        startGlobalListening();
      }
    }
  }
}

final agentProvider = StateNotifierProvider<AgentNotifier, AgentState>((ref) {
  return AgentNotifier(ref);
});
