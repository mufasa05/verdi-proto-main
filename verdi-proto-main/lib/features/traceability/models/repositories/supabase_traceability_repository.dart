import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../batch_document_model.dart';
import '../batch_model.dart';
import '../farm_model.dart';
import '../field_model.dart';
import '../scan_log_model.dart';
import '../trace_event_model.dart';
import 'in_memory_traceability_repository.dart';
import 'traceability_repository.dart';

/// Production-ready Supabase Traceability Repository.
/// Persists and queries farms, fields, batches, trace events, documents, and scan logs
/// against Supabase Postgres with automatic fallback to InMemoryTraceabilityRepository
/// when offline or uninitialized.
class SupabaseTraceabilityRepository implements TraceabilityRepository {
  final TraceabilityRepository fallback;

  SupabaseTraceabilityRepository({TraceabilityRepository? fallbackRepository})
      : fallback = fallbackRepository ?? InMemoryTraceabilityRepository();

  bool get _isSupabaseReady => SupabaseService.instance.isInitialized && SupabaseService.instance.client != null;

  @override
  Future<List<FarmModel>> getFarms() async {
    if (!_isSupabaseReady) {
      return fallback.getFarms();
    }
    try {
      final client = SupabaseService.instance.client!;
      final response = await client
          .from('trace_farms')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        // Fall back to seed data if empty
        return await fallback.getFarms();
      }
      return (response as List).map((row) => FarmModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getFarms error: $e. Using local cache.');
      return await fallback.getFarms();
    }
  }

  @override
  Future<FarmModel?> getFarmById(String farmId) async {
    if (!_isSupabaseReady) {
      return fallback.getFarmById(farmId);
    }
    try {
      final client = SupabaseService.instance.client!;
      final response = await client
          .from('trace_farms')
          .select()
          .eq('id', farmId)
          .maybeSingle();

      if (response == null) {
        return await fallback.getFarmById(farmId);
      }
      return FarmModel.fromMap(response);
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getFarmById error: $e');
      return await fallback.getFarmById(farmId);
    }
  }

  @override
  Future<List<FieldModel>> getFields({String? farmId}) async {
    if (!_isSupabaseReady) {
      return fallback.getFields(farmId: farmId);
    }
    try {
      final client = SupabaseService.instance.client!;
      var query = client.from('trace_fields').select();
      if (farmId != null && farmId.isNotEmpty) {
        query = query.eq('farmId', farmId);
      }
      final response = await query.order('name', ascending: true);

      if (response.isEmpty) {
        return await fallback.getFields(farmId: farmId);
      }
      return (response as List).map((row) => FieldModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getFields error: $e');
      return await fallback.getFields(farmId: farmId);
    }
  }

  @override
  Future<FieldModel?> getFieldById(String fieldId) async {
    if (!_isSupabaseReady) {
      return fallback.getFieldById(fieldId);
    }
    try {
      final client = SupabaseService.instance.client!;
      final response = await client
          .from('trace_fields')
          .select()
          .eq('id', fieldId)
          .maybeSingle();

      if (response == null) {
        return await fallback.getFieldById(fieldId);
      }
      return FieldModel.fromMap(response);
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getFieldById error: $e');
      return await fallback.getFieldById(fieldId);
    }
  }

  @override
  Future<List<BatchModel>> getBatches({String? farmId, String? fieldId}) async {
    if (!_isSupabaseReady) {
      return fallback.getBatches(farmId: farmId, fieldId: fieldId);
    }
    try {
      final client = SupabaseService.instance.client!;
      var query = client.from('trace_batches').select();
      if (farmId != null && farmId.isNotEmpty) {
        query = query.eq('farmId', farmId);
      }
      if (fieldId != null && fieldId.isNotEmpty) {
        query = query.eq('fieldId', fieldId);
      }
      final response = await query.order('created_at', ascending: false);

      if (response.isEmpty) {
        return await fallback.getBatches(farmId: farmId, fieldId: fieldId);
      }
      return (response as List).map((row) => BatchModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getBatches error: $e');
      return await fallback.getBatches(farmId: farmId, fieldId: fieldId);
    }
  }

  @override
  Future<BatchModel?> getBatchById(String batchId) async {
    if (!_isSupabaseReady) {
      return fallback.getBatchById(batchId);
    }
    try {
      final client = SupabaseService.instance.client!;
      final response = await client
          .from('trace_batches')
          .select()
          .eq('id', batchId)
          .maybeSingle();

      if (response == null) {
        return await fallback.getBatchById(batchId);
      }
      return BatchModel.fromMap(response);
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getBatchById error: $e');
      return await fallback.getBatchById(batchId);
    }
  }

  @override
  Future<BatchModel> saveBatch(BatchModel batch) async {
    // Keep local cache synced
    await fallback.saveBatch(batch);

    if (_isSupabaseReady) {
      try {
        final client = SupabaseService.instance.client!;
        await client.from('trace_batches').upsert(batch.toMap());
      } catch (e) {
        debugPrint('[SupabaseTraceabilityRepository] saveBatch Supabase error: $e');
      }
    }
    return batch;
  }

  @override
  Future<void> deleteBatch(String batchId) async {
    await fallback.deleteBatch(batchId);
    if (_isSupabaseReady) {
      try {
        final client = SupabaseService.instance.client!;
        await client.from('trace_batches').delete().eq('id', batchId);
      } catch (e) {
        debugPrint('[SupabaseTraceabilityRepository] deleteBatch Supabase error: $e');
      }
    }
  }

  @override
  Future<List<TraceEventModel>> getEvents(String batchId) async {
    if (!_isSupabaseReady) {
      return fallback.getEvents(batchId);
    }
    try {
      final client = SupabaseService.instance.client!;
      final response = await client
          .from('trace_events')
          .select()
          .eq('batchId', batchId)
          .order('event_time', ascending: false);

      if (response.isEmpty) {
        return await fallback.getEvents(batchId);
      }
      return (response as List).map((row) => TraceEventModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getEvents error: $e');
      return await fallback.getEvents(batchId);
    }
  }

  @override
  Future<TraceEventModel> addEvent(TraceEventModel event) async {
    await fallback.addEvent(event);
    if (_isSupabaseReady) {
      try {
        final client = SupabaseService.instance.client!;
        await client.from('trace_events').insert(event.toMap());
      } catch (e) {
        debugPrint('[SupabaseTraceabilityRepository] addEvent Supabase error: $e');
      }
    }
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await fallback.deleteEvent(eventId);
    if (_isSupabaseReady) {
      try {
        final client = SupabaseService.instance.client!;
        await client.from('trace_events').delete().eq('id', eventId);
      } catch (e) {
        debugPrint('[SupabaseTraceabilityRepository] deleteEvent Supabase error: $e');
      }
    }
  }

  @override
  Future<List<BatchDocumentModel>> getDocuments(String batchId) async {
    if (!_isSupabaseReady) {
      return fallback.getDocuments(batchId);
    }
    try {
      final client = SupabaseService.instance.client!;
      final response = await client
          .from('trace_documents')
          .select()
          .eq('batchId', batchId)
          .order('uploaded_at', ascending: false);

      if (response.isEmpty) {
        return await fallback.getDocuments(batchId);
      }
      return (response as List).map((row) => BatchDocumentModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getDocuments error: $e');
      return await fallback.getDocuments(batchId);
    }
  }

  @override
  Future<BatchDocumentModel> addDocument(BatchDocumentModel document) async {
    await fallback.addDocument(document);
    if (_isSupabaseReady) {
      try {
        final client = SupabaseService.instance.client!;
        await client.from('trace_documents').insert(document.toMap());
      } catch (e) {
        debugPrint('[SupabaseTraceabilityRepository] addDocument Supabase error: $e');
      }
    }
    return document;
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await fallback.deleteDocument(documentId);
    if (_isSupabaseReady) {
      try {
        final client = SupabaseService.instance.client!;
        await client.from('trace_documents').delete().eq('id', documentId);
      } catch (e) {
        debugPrint('[SupabaseTraceabilityRepository] deleteDocument Supabase error: $e');
      }
    }
  }

  @override
  Future<List<ScanLogModel>> getScanLogs(String batchId) async {
    if (!_isSupabaseReady) {
      return fallback.getScanLogs(batchId);
    }
    try {
      final client = SupabaseService.instance.client!;
      final response = await client
          .from('trace_scan_logs')
          .select()
          .eq('batchId', batchId)
          .order('scanned_at', ascending: false);

      if (response.isEmpty) {
        return await fallback.getScanLogs(batchId);
      }
      return (response as List).map((row) => ScanLogModel.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[SupabaseTraceabilityRepository] getScanLogs error: $e');
      return await fallback.getScanLogs(batchId);
    }
  }

  @override
  Future<ScanLogModel> addScanLog(ScanLogModel scanLog) async {
    await fallback.addScanLog(scanLog);
    if (_isSupabaseReady) {
      try {
        final client = SupabaseService.instance.client!;
        await client.from('trace_scan_logs').insert(scanLog.toMap());
      } catch (e) {
        debugPrint('[SupabaseTraceabilityRepository] addScanLog Supabase error: $e');
      }
    }
    return scanLog;
  }
}
