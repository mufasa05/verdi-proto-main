import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/verdi_api_service.dart';

class StockBatch {
  final String id;
  final String productName;
  final String supplierId;
  final String warehouseId;
  final String binLabel;
  final double quantityKg;
  final String gradeClass;
  final String lotNumber;
  final String arrivalDate;
  final String status;

  const StockBatch({
    required this.id,
    required this.productName,
    required this.supplierId,
    required this.warehouseId,
    required this.binLabel,
    required this.quantityKg,
    required this.gradeClass,
    required this.lotNumber,
    required this.arrivalDate,
    required this.status,
  });

  factory StockBatch.fromJson(Map<String, dynamic> json) {
    return StockBatch(
      id: json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      supplierId: json['supplierId']?.toString() ?? '',
      warehouseId: json['warehouseId']?.toString() ?? '',
      binLabel: json['binLabel']?.toString() ?? '',
      quantityKg: (json['quantityKg'] as num?)?.toDouble() ?? 0.0,
      gradeClass: json['gradeClass']?.toString() ?? 'a',
      lotNumber: json['lotNumber']?.toString() ?? '',
      arrivalDate: json['arrivalDate']?.toString() ?? '',
      status: json['status']?.toString() ?? 'In Stock',
    );
  }
}

class ScanLog {
  final String id;
  final String batchId;
  final String scannedBy;
  final String location;
  final String timestamp;
  final String action;

  const ScanLog({
    required this.id,
    required this.batchId,
    required this.scannedBy,
    required this.location,
    required this.timestamp,
    required this.action,
  });

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    return ScanLog(
      id: json['id']?.toString() ?? '',
      batchId: json['batchId']?.toString() ?? '',
      scannedBy: json['scannedBy']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
    );
  }
}

class TraceabilityBackendState {
  final List<StockBatch> batches;
  final List<ScanLog> scanLogs;
  final bool isLoading;
  final String? error;

  const TraceabilityBackendState({
    required this.batches,
    required this.scanLogs,
    required this.isLoading,
    this.error,
  });

  static const initial = TraceabilityBackendState(
    batches: [],
    scanLogs: [],
    isLoading: true,
  );

  TraceabilityBackendState copyWith({
    List<StockBatch>? batches,
    List<ScanLog>? scanLogs,
    bool? isLoading,
    String? error,
  }) {
    return TraceabilityBackendState(
      batches: batches ?? this.batches,
      scanLogs: scanLogs ?? this.scanLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TraceabilityBackendNotifier
    extends StateNotifier<TraceabilityBackendState> {
  final _api = VerdiApiService.instance;

  TraceabilityBackendNotifier() : super(TraceabilityBackendState.initial) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final batches = await _api.getStockBatches();
      final scans = await _api.getScanLogs();
      state = state.copyWith(
        batches: batches.map(StockBatch.fromJson).toList(),
        scanLogs: scans.map(ScanLog.fromJson).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recordScan({
    required String batchId,
    required String scannedBy,
    required String location,
    required String action,
  }) async {
    await _api.recordScan(
      batchId: batchId,
      scannedBy: scannedBy,
      location: location,
      action: action,
    );
    await load();
  }
}

final traceabilityBackendProvider =
    StateNotifierProvider<TraceabilityBackendNotifier, TraceabilityBackendState>(
  (ref) => TraceabilityBackendNotifier(),
);
