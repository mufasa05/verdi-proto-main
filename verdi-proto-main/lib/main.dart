import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/assistant/live/providers/live_ai_provider.dart';
import 'features/assistant/live/services/live_ai_stream_service.dart';
import 'features/assistant/providers/assistant_provider.dart';
import 'features/assistant/repositories/assistant_repository.dart';
import 'features/traceability/providers/traceability_provider.dart';
import 'features/traceability/models/repositories/in_memory_traceability_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TraceabilityProvider(
              repository: InMemoryTraceabilityRepository(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => AssistantProvider(
              repository: InMemoryAssistantRepository(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => LiveAiProvider(
              // MockLiveAiStreamService() — use this for offline/demo mode
              // SseStreamService — connects to the real NestJS backend
              service: SseStreamService(
                // Android emulator → 10.0.2.2, Desktop/Web → localhost
                baseUrl: 'http://localhost:3000',
              ),
            )..connect(),
          ),
        ],
        child: const VerdiApp(),
      ),
    ),
  );
}
