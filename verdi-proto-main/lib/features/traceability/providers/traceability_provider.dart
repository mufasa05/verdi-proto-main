import 'package:flutter/foundation.dart';
import '../models/batch_document_model.dart';
import '../models/batch_model.dart';
import '../models/farm_model.dart';
import '../models/field_model.dart';
import '../models/scan_log_model.dart';
import '../models/trace_event_model.dart';
import '../models/repositories/traceability_repository.dart';

class TraceabilityProvider extends ChangeNotifier {
  final TraceabilityRepository repository;

  TraceabilityProvider({required this.repository}) {
    init();
  }

  bool loading = false;
  String? errorMessage;

  List<FarmModel> farms = [];
  List<FieldModel> fields = [];
  List<BatchModel> batches = [];
  List<TraceEventModel> events = [];
  List<BatchDocumentModel> documents = [];
  List<ScanLogModel> scanLogs = [];

  FarmModel? selectedFarm;
  FieldModel? selectedField;
  BatchModel? selectedBatch;

  Future<void> init() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      farms = await repository.getFarms();
      selectedFarm = farms.isNotEmpty ? farms.first : null;

      fields = selectedFarm == null
          ? []
          : await repository.getFields(farmId: selectedFarm!.id);
      selectedField = fields.isNotEmpty ? fields.first : null;

      batches = selectedField == null
          ? []
          : await repository.getBatches(fieldId: selectedField!.id);

      selectedBatch = batches.isNotEmpty ? batches.first : null;

      await _loadBatchDetails();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await init();
  }

  Future<void> selectFarm(FarmModel farm) async {
    selectedFarm = farm;
    selectedField = null;
    selectedBatch = null;
    fields = await repository.getFields(farmId: farm.id);
    selectedField = fields.isNotEmpty ? fields.first : null;
    batches = selectedField == null
        ? []
        : await repository.getBatches(fieldId: selectedField!.id);
    selectedBatch = batches.isNotEmpty ? batches.first : null;
    await _loadBatchDetails();
    notifyListeners();
  }

  Future<void> selectField(FieldModel field) async {
    selectedField = field;
    selectedBatch = null;
    batches = await repository.getBatches(fieldId: field.id);
    selectedBatch = batches.isNotEmpty ? batches.first : null;
    await _loadBatchDetails();
    notifyListeners();
  }

  Future<void> selectBatch(BatchModel batch) async {
    selectedBatch = batch;
    await _loadBatchDetails();
    notifyListeners();
  }

  Future<void> _loadBatchDetails() async {
    if (selectedBatch == null) {
      events = [];
      documents = [];
      scanLogs = [];
      return;
    }

    events = await repository.getEvents(selectedBatch!.id);
    documents = await repository.getDocuments(selectedBatch!.id);
    scanLogs = await repository.getScanLogs(selectedBatch!.id);
  }

  Future<void> saveBatch(BatchModel batch) async {
    loading = true;
    notifyListeners();
    try {
      final saved = await repository.saveBatch(batch);
      await init();
      selectedBatch = saved;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(TraceEventModel event) async {
    if (selectedBatch == null) return;
    loading = true;
    notifyListeners();
    try {
      await repository.addEvent(event);
      events = await repository.getEvents(selectedBatch!.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addDocument(BatchDocumentModel document) async {
    if (selectedBatch == null) return;
    loading = true;
    notifyListeners();
    try {
      await repository.addDocument(document);
      documents = await repository.getDocuments(selectedBatch!.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addScanLog(ScanLogModel scanLog) async {
    if (selectedBatch == null) return;
    loading = true;
    notifyListeners();
    try {
      await repository.addScanLog(scanLog);
      scanLogs = await repository.getScanLogs(selectedBatch!.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBatch(String batchId) async {
    loading = true;
    notifyListeners();
    try {
      await repository.deleteBatch(batchId);
      await init();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  double get averageReadiness {
    if (batches.isEmpty) return 0;
    final total = batches.fold<double>(0, (sum, b) => sum + b.readinessScore);
    return total / batches.length;
  }

  int get readyCount => batches.where((b) => b.status == 'Ready').length;
  int get reviewCount => batches.where((b) => b.status == 'Review').length;
  int get blockedCount => batches.where((b) => b.status == 'Blocked').length;
}