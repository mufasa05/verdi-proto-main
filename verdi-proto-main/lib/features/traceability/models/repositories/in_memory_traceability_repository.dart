import 'dart:math';
import '../batch_document_model.dart';
import '../batch_model.dart';
import '../farm_model.dart';
import '../field_model.dart';
import '../scan_log_model.dart';
import '../trace_event_model.dart';
import 'traceability_repository.dart';

class InMemoryTraceabilityRepository implements TraceabilityRepository {
  final List<FarmModel> _farms = [];
  final List<FieldModel> _fields = [];
  final List<BatchModel> _batches = [];
  final List<TraceEventModel> _events = [];
  final List<BatchDocumentModel> _documents = [];
  final List<ScanLogModel> _scanLogs = [];

  final Random _random = Random();

  InMemoryTraceabilityRepository() {
    _seed();
  }

  void _seed() {
    final farm1 = FarmModel(
      id: 'farm-1',
      name: 'Chiredzi Unit A',
      ownerName: 'A. Farmer',
      region: 'Masvingo',
      district: 'Chiredzi',
      village: 'Block 4',
      latitude: -21.047,
      longitude: 31.666,
      registrationStatus: 'Verified',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final farm2 = FarmModel(
      id: 'farm-2',
      name: 'Odzi Farm',
      ownerName: 'B. Grower',
      region: 'Manicaland',
      district: 'Mutare',
      village: 'Greenhouse Zone',
      latitude: -18.970,
      longitude: 32.670,
      registrationStatus: 'Verified',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _farms.addAll([farm1, farm2]);

    final field1 = FieldModel(
      id: 'field-1',
      farmId: farm1.id,
      name: 'Block 4',
      cropName: 'Mango',
      areaHa: 2.4,
      latitude: farm1.latitude,
      longitude: farm1.longitude,
      boundaryRef: 'B4-001',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final field2 = FieldModel(
      id: 'field-2',
      farmId: farm2.id,
      name: 'Greenhouse 2',
      cropName: 'Tomatoes',
      areaHa: 1.2,
      latitude: farm2.latitude,
      longitude: farm2.longitude,
      boundaryRef: 'G2-002',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _fields.addAll([field1, field2]);

    final batch1 = BatchModel(
      id: 'batch-1',
      batchCode: 'VER-TR-10021',
      farmId: farm1.id,
      fieldId: field1.id,
      cropName: 'Mango',
      harvestDate: DateTime.now(),
      quantity: 1200,
      unit: 'kg',
      status: 'Ready',
      readinessScore: 0.96,
      originVerified: true,
      inspectionPassed: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final batch2 = BatchModel(
      id: 'batch-2',
      batchCode: 'VER-TR-10022',
      farmId: farm2.id,
      fieldId: field2.id,
      cropName: 'Tomatoes',
      harvestDate: DateTime.now(),
      quantity: 780,
      unit: 'kg',
      status: 'Review',
      readinessScore: 0.71,
      originVerified: true,
      inspectionPassed: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _batches.addAll([batch1, batch2]);

    _events.addAll([
      TraceEventModel(
        id: 'event-1',
        batchId: batch1.id,
        eventType: 'Harvest',
        eventTime: DateTime.now(),
        actorName: 'Harvest Team',
        location: 'Packhouse A',
        notes: 'Batch harvested and weighed.',
      ),
      TraceEventModel(
        id: 'event-2',
        batchId: batch1.id,
        eventType: 'Inspection',
        eventTime: DateTime.now(),
        actorName: 'Inspector',
        location: 'Packhouse A',
        notes: 'Quality inspection completed.',
      ),
    ]);

    _documents.addAll([
      BatchDocumentModel(
        id: 'doc-1',
        batchId: batch1.id,
        docType: 'Harvest Log',
        fileName: 'VER-TR-10021-harvest.pdf',
        fileUrl: '',
        uploadedBy: 'Farm Manager',
        uploadedAt: DateTime.now(),
      ),
      BatchDocumentModel(
        id: 'doc-2',
        batchId: batch1.id,
        docType: 'Inspection Certificate',
        fileName: 'VER-TR-10021-inspection.pdf',
        fileUrl: '',
        uploadedBy: 'Inspector',
        uploadedAt: DateTime.now(),
      ),
    ]);

    _scanLogs.addAll([
      ScanLogModel(
        id: 'scan-1',
        batchId: batch1.id,
        scannedAt: DateTime.now(),
        scannerRole: 'Inspector',
        scannerName: 'T. Moyo',
        result: 'Verified',
      ),
    ]);
  }

  String _id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';

  @override
  Future<List<FarmModel>> getFarms() async => List.unmodifiable(_farms);

  @override
  Future<FarmModel?> getFarmById(String farmId) async {
    return _farms.where((f) => f.id == farmId).cast<FarmModel?>().firstOrNull;
  }

  @override
  Future<List<FieldModel>> getFields({String? farmId}) async {
    if (farmId == null) return List.unmodifiable(_fields);
    return List.unmodifiable(_fields.where((f) => f.farmId == farmId).toList());
  }

  @override
  Future<FieldModel?> getFieldById(String fieldId) async {
    return _fields.where((f) => f.id == fieldId).cast<FieldModel?>().firstOrNull;
  }

  @override
  Future<List<BatchModel>> getBatches({String? farmId, String? fieldId}) async {
    final result = _batches.where((b) {
      final farmOk = farmId == null || b.farmId == farmId;
      final fieldOk = fieldId == null || b.fieldId == fieldId;
      return farmOk && fieldOk;
    }).toList();
    return List.unmodifiable(result);
  }

  @override
  Future<BatchModel?> getBatchById(String batchId) async {
    return _batches.where((b) => b.id == batchId).cast<BatchModel?>().firstOrNull;
  }

  @override
  Future<BatchModel> saveBatch(BatchModel batch) async {
    final index = _batches.indexWhere((b) => b.id == batch.id);
    final newBatch = BatchModel(
      id: batch.id.isEmpty ? _id('batch') : batch.id,
      batchCode: batch.batchCode,
      farmId: batch.farmId,
      fieldId: batch.fieldId,
      cropName: batch.cropName,
      harvestDate: batch.harvestDate,
      quantity: batch.quantity,
      unit: batch.unit,
      status: batch.status,
      readinessScore: batch.readinessScore,
      originVerified: batch.originVerified,
      inspectionPassed: batch.inspectionPassed,
      createdAt: batch.createdAt,
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _batches[index] = newBatch;
    } else {
      _batches.add(newBatch);
    }
    return newBatch;
  }

  @override
  Future<void> deleteBatch(String batchId) async {
    _batches.removeWhere((b) => b.id == batchId);
    _events.removeWhere((e) => e.batchId == batchId);
    _documents.removeWhere((d) => d.batchId == batchId);
    _scanLogs.removeWhere((s) => s.batchId == batchId);
  }

  @override
  Future<List<TraceEventModel>> getEvents(String batchId) async {
    return List.unmodifiable(_events.where((e) => e.batchId == batchId).toList());
  }

  @override
  Future<TraceEventModel> addEvent(TraceEventModel event) async {
    final newEvent = TraceEventModel(
      id: event.id.isEmpty ? _id('event') : event.id,
      batchId: event.batchId,
      eventType: event.eventType,
      eventTime: event.eventTime,
      actorName: event.actorName,
      location: event.location,
      notes: event.notes,
    );
    _events.add(newEvent);
    return newEvent;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<List<BatchDocumentModel>> getDocuments(String batchId) async {
    return List.unmodifiable(_documents.where((d) => d.batchId == batchId).toList());
  }

  @override
  Future<BatchDocumentModel> addDocument(BatchDocumentModel document) async {
    final newDocument = BatchDocumentModel(
      id: document.id.isEmpty ? _id('doc') : document.id,
      batchId: document.batchId,
      docType: document.docType,
      fileName: document.fileName,
      fileUrl: document.fileUrl,
      uploadedBy: document.uploadedBy,
      uploadedAt: document.uploadedAt,
    );
    _documents.add(newDocument);
    return newDocument;
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    _documents.removeWhere((d) => d.id == documentId);
  }

  @override
  Future<List<ScanLogModel>> getScanLogs(String batchId) async {
    return List.unmodifiable(_scanLogs.where((s) => s.batchId == batchId).toList());
  }

  @override
  Future<ScanLogModel> addScanLog(ScanLogModel scanLog) async {
    final newScan = ScanLogModel(
      id: scanLog.id.isEmpty ? _id('scan') : scanLog.id,
      batchId: scanLog.batchId,
      scannedAt: scanLog.scannedAt,
      scannerRole: scanLog.scannerRole,
      scannerName: scanLog.scannerName,
      result: scanLog.result,
    );
    _scanLogs.add(newScan);
    return newScan;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}