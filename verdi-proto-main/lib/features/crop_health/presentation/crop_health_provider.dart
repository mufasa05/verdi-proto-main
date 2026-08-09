import 'package:flutter/material.dart';
import 'package:verdi/core/ai/ai_service.dart';
import 'package:verdi/core/services/verdi_api_service.dart';
import 'package:verdi/features/crop_health/data/crop_health_models.dart';
import 'package:verdi/features/crop_health/data/mock_crop_health_repository.dart';

class CropHealthProvider extends ChangeNotifier {
  final MockCropHealthRepository repository;
  final AiDecisionService aiService;

  CropHealthProvider({required this.repository, required this.aiService}) {
    loadSnapshot();
  }

  CropHealthSnapshot? snapshot;
  CropHealthAnalysis? analysis;
  bool isLoading = true;
  String? error;

  Future<void> loadSnapshot() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 300));
      snapshot = repository.fetchSnapshot();

      if (snapshot != null) {
        analysis = await aiService.analyzeCropHealth(snapshot!);
      }
    } catch (e) {
      error = 'Unable to load crop health data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleIrrigation(int zoneId, String status) async {
    try {
      await VerdiApiService.instance.irrigateZone(zoneId, status);
      notifyListeners();
    } catch (_) {}
  }
}
