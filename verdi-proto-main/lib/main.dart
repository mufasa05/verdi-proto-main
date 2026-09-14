import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/security_vault_service.dart';
import 'core/services/supabase_service.dart';
import 'features/assistant/live/providers/live_ai_provider.dart';
import 'features/assistant/live/services/live_ai_stream_service.dart';
import 'features/assistant/providers/assistant_provider.dart';
import 'features/assistant/repositories/assistant_repository.dart';
import 'features/traceability/providers/traceability_provider.dart';
import 'features/traceability/models/repositories/supabase_traceability_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize centralized App Configuration
  await AppConfig.instance.initialize();

  // 2. Initialize hardened Supabase client & realtime listeners
  await SupabaseService.instance.initialize();

  // 3. Initialize sovereign Security Vault (API keys, IP firewall, PIN & 2FA)
  await SecurityVaultService.instance.initialize();

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TraceabilityProvider(
              repository: SupabaseTraceabilityRepository(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => AssistantProvider(
              repository: InMemoryAssistantRepository(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => LiveAiProvider(
              service: SseStreamService(
                baseUrl: AppConfig.instance.backendBaseUrl,
              ),
            )..connect(),
          ),
        ],
        child: const VerdiApp(),
      ),
    ),
  );
}
