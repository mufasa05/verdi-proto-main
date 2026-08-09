import '../batch_document_model.dart';
import '../batch_model.dart';
import '../farm_model.dart';
import '../field_model.dart';
import '../scan_log_model.dart';
import '../trace_event_model.dart';

abstract class TraceabilityRepository {
  Future<List<FarmModel>> getFarms();
  Future<FarmModel?> getFarmById(String farmId);

  Future<List<FieldModel>> getFields({String? farmId});
  Future<FieldModel?> getFieldById(String fieldId);

  Future<List<BatchModel>> getBatches({String? farmId, String? fieldId});
  Future<BatchModel?> getBatchById(String batchId);
  Future<BatchModel> saveBatch(BatchModel batch);
  Future<void> deleteBatch(String batchId);

  Future<List<TraceEventModel>> getEvents(String batchId);
  Future<TraceEventModel> addEvent(TraceEventModel event);
  Future<void> deleteEvent(String eventId);

  Future<List<BatchDocumentModel>> getDocuments(String batchId);
  Future<BatchDocumentModel> addDocument(BatchDocumentModel document);
  Future<void> deleteDocument(String documentId);

  Future<List<ScanLogModel>> getScanLogs(String batchId);
  Future<ScanLogModel> addScanLog(ScanLogModel scanLog);
}