import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_data_service.dart';
import 'ai_data_repository.dart';
import 'ai_data_sqlite_service.dart';

final aiDataServiceProvider = Provider<AiDataAccessService>((ref) {
  if (kIsWeb) {
    return InMemoryAiDataService();
  }
  return SqliteAiDataService();
});

final aiDataRepositoryProvider = Provider<AiDataRepository>((ref) {
  final svc = ref.read(aiDataServiceProvider);
  return AiDataRepository(service: svc);
});
