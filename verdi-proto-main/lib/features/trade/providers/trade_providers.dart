import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/verdi_api_service.dart';
import '../../../state/app_state.dart';
import '../models/trade_models.dart';

// =============================================================================
// MOCK SEED DATA
// =============================================================================

final _initialSuppliers = [
  const TradeSupplier(
    id: 'SUP-01',
    name: 'Chiredzi Valley Farms',
    region: 'Masvingo',
    category: 'Fruits',
    trustScore: 0.94,
    capacityTonnes: 280,
    isVerified: true,
    contactName: 'Takudzwa Mhende',
    contactPhone: '+263 77 401 2233',
    primaryProduct: 'Mangoes',
    totalOrdersFulfilled: 42,
    onboardedDate: '2025-03-10',
  ),
  const TradeSupplier(
    id: 'SUP-02',
    name: 'Mvurwi Grains Co-op',
    region: 'Mashonaland Central',
    category: 'Grains',
    trustScore: 0.88,
    capacityTonnes: 650,
    isVerified: true,
    contactName: 'Rudo Chirimba',
    contactPhone: '+263 71 905 1140',
    primaryProduct: 'White Maize',
    totalOrdersFulfilled: 78,
    onboardedDate: '2024-11-22',
  ),
  const TradeSupplier(
    id: 'SUP-03',
    name: 'Eastern Highlands Produce',
    region: 'Manicaland',
    category: 'Vegetables',
    trustScore: 0.76,
    capacityTonnes: 190,
    isVerified: true,
    contactName: 'Simba Gondo',
    contactPhone: '+263 77 320 8870',
    primaryProduct: 'Potatoes',
    totalOrdersFulfilled: 31,
    onboardedDate: '2025-01-05',
  ),
  const TradeSupplier(
    id: 'SUP-04',
    name: 'Bulawayo Fresh Market',
    region: 'Bulawayo',
    category: 'Vegetables',
    trustScore: 0.61,
    capacityTonnes: 120,
    isVerified: false,
    contactName: 'Mufaro Nyathi',
    contactPhone: '+263 71 543 6612',
    primaryProduct: 'Tomatoes',
    totalOrdersFulfilled: 14,
    onboardedDate: '2025-06-01',
  ),
  const TradeSupplier(
    id: 'SUP-05',
    name: 'Odzi River Onion Growers',
    region: 'Manicaland',
    category: 'Vegetables',
    trustScore: 0.82,
    capacityTonnes: 200,
    isVerified: true,
    contactName: 'Precious Choto',
    contactPhone: '+263 77 882 3391',
    primaryProduct: 'Onions',
    totalOrdersFulfilled: 29,
    onboardedDate: '2024-09-14',
  ),
];

final _initialPurchaseOrders = [
  const PurchaseOrder(
    id: 'PO-3001',
    supplierId: 'SUP-02',
    productName: 'White Maize',
    quantityKg: 20000,
    unitPricePer100kg: 42.50,
    status: 'Confirmed',
    date: '2026-06-20',
    deliveryDate: '2026-07-05',
    warehouseId: 'WH-01',
    notes: 'Harvest lot June batch.',
  ),
  const PurchaseOrder(
    id: 'PO-3002',
    supplierId: 'SUP-01',
    productName: 'Mangoes',
    quantityKg: 5000,
    unitPricePer100kg: 85.00,
    status: 'Sent',
    date: '2026-06-25',
    deliveryDate: '2026-07-08',
    warehouseId: 'WH-02',
  ),
  const PurchaseOrder(
    id: 'PO-3003',
    supplierId: 'SUP-03',
    productName: 'Potatoes',
    quantityKg: 8000,
    unitPricePer100kg: 38.00,
    status: 'Received',
    date: '2026-06-10',
    deliveryDate: '2026-06-18',
    warehouseId: 'WH-01',
  ),
  const PurchaseOrder(
    id: 'PO-3004',
    supplierId: 'SUP-05',
    productName: 'Onions',
    quantityKg: 4500,
    unitPricePer100kg: 32.00,
    status: 'Draft',
    date: '2026-06-28',
    deliveryDate: '2026-07-12',
    warehouseId: 'WH-02',
  ),
  const PurchaseOrder(
    id: 'PO-3005',
    supplierId: 'SUP-04',
    productName: 'Tomatoes',
    quantityKg: 3000,
    unitPricePer100kg: 55.00,
    status: 'Cancelled',
    date: '2026-06-12',
    deliveryDate: '2026-06-20',
    warehouseId: 'WH-01',
    notes: 'Supplier failed quality inspection.',
  ),
];

final _initialWarehouses = [
  const Warehouse(
    id: 'WH-01',
    name: 'Harare Central Depot',
    location: 'Harare',
    capacityTonnes: 500,
    currentStockTonnes: 312,
    bins: [
      WarehouseBin(id: 'BIN-A01', label: 'A-01', isOccupied: true, batchId: 'BAT-001'),
      WarehouseBin(id: 'BIN-A02', label: 'A-02', isOccupied: true, batchId: 'BAT-002'),
      WarehouseBin(id: 'BIN-A03', label: 'A-03', isOccupied: false),
      WarehouseBin(id: 'BIN-B01', label: 'B-01', isOccupied: true, batchId: 'BAT-003'),
      WarehouseBin(id: 'BIN-B02', label: 'B-02', isOccupied: false),
    ],
  ),
  const Warehouse(
    id: 'WH-02',
    name: 'Bulawayo Cold Store',
    location: 'Bulawayo',
    capacityTonnes: 250,
    currentStockTonnes: 94,
    bins: [
      WarehouseBin(id: 'BIN-C01', label: 'C-01', isOccupied: true, batchId: 'BAT-004'),
      WarehouseBin(id: 'BIN-C02', label: 'C-02', isOccupied: false),
      WarehouseBin(id: 'BIN-C03', label: 'C-03', isOccupied: false),
    ],
  ),
  const Warehouse(
    id: 'WH-03',
    name: 'Mutare Border Depot',
    location: 'Manicaland',
    capacityTonnes: 180,
    currentStockTonnes: 67,
    bins: [
      WarehouseBin(id: 'BIN-D01', label: 'D-01', isOccupied: true, batchId: 'BAT-005'),
      WarehouseBin(id: 'BIN-D02', label: 'D-02', isOccupied: false),
    ],
  ),
];

final _initialBatches = [
  const StockBatch(
    id: 'BAT-001',
    productName: 'White Maize',
    supplierId: 'SUP-02',
    warehouseId: 'WH-01',
    binLabel: 'A-01',
    quantityKg: 20000,
    gradeClass: GradeClass.a,
    lotNumber: 'LOT-JUN-2601',
    arrivalDate: '2026-06-22',
    expiryDate: '2026-12-22',
    status: 'In Stock',
  ),
  const StockBatch(
    id: 'BAT-002',
    productName: 'Potatoes',
    supplierId: 'SUP-03',
    warehouseId: 'WH-01',
    binLabel: 'A-02',
    quantityKg: 7800,
    gradeClass: GradeClass.b,
    lotNumber: 'LOT-JUN-2602',
    arrivalDate: '2026-06-18',
    expiryDate: '2026-08-18',
    status: 'In Stock',
  ),
  const StockBatch(
    id: 'BAT-003',
    productName: 'Onions',
    supplierId: 'SUP-05',
    warehouseId: 'WH-01',
    binLabel: 'B-01',
    quantityKg: 3200,
    gradeClass: GradeClass.a,
    lotNumber: 'LOT-JUN-2603',
    arrivalDate: '2026-06-25',
    expiryDate: '2026-09-25',
    status: 'Reserved',
  ),
  const StockBatch(
    id: 'BAT-004',
    productName: 'Mangoes',
    supplierId: 'SUP-01',
    warehouseId: 'WH-02',
    binLabel: 'C-01',
    quantityKg: 4800,
    gradeClass: GradeClass.a,
    lotNumber: 'LOT-JUN-2604',
    arrivalDate: '2026-06-28',
    expiryDate: '2026-07-12',
    status: 'In Stock',
  ),
  const StockBatch(
    id: 'BAT-005',
    productName: 'Potatoes',
    supplierId: 'SUP-03',
    warehouseId: 'WH-03',
    binLabel: 'D-01',
    quantityKg: 6500,
    gradeClass: GradeClass.c,
    lotNumber: 'LOT-JUN-2605',
    arrivalDate: '2026-06-15',
    expiryDate: '2026-07-30',
    status: 'In Stock',
  ),
];

final _initialQualityChecks = [
  const QualityCheck(
    id: 'QC-001',
    batchId: 'BAT-001',
    productName: 'White Maize',
    inspector: 'Farai Mutasa',
    assignedGrade: GradeClass.a,
    passed: true,
    moisturePercent: 12.4,
    weightCheckedKg: 500,
    notes: 'Clean, dry, no aflatoxin detected.',
    date: '2026-06-23',
  ),
  const QualityCheck(
    id: 'QC-002',
    batchId: 'BAT-002',
    productName: 'Potatoes',
    inspector: 'Nyasha Chidembo',
    assignedGrade: GradeClass.b,
    passed: true,
    moisturePercent: 18.2,
    weightCheckedKg: 300,
    notes: 'Minor surface bruising on ~8% of sample.',
    date: '2026-06-19',
  ),
  const QualityCheck(
    id: 'QC-003',
    batchId: 'BAT-005',
    productName: 'Potatoes',
    inspector: 'Farai Mutasa',
    assignedGrade: GradeClass.c,
    passed: true,
    moisturePercent: 22.1,
    weightCheckedKg: 200,
    notes: 'High moisture, borderline. Recommend quick dispatch.',
    date: '2026-06-16',
  ),
  const QualityCheck(
    id: 'QC-004',
    batchId: 'BAT-004',
    productName: 'Mangoes',
    inspector: 'Rudo Zimba',
    assignedGrade: GradeClass.a,
    passed: true,
    moisturePercent: 0,
    weightCheckedKg: 120,
    notes: 'Excellent ripeness, no bruising.',
    date: '2026-06-29',
  ),
];

final _initialProcessingRuns = [
  const ProcessingRun(
    id: 'RUN-001',
    inputBatchId: 'BAT-001',
    outputBatchId: null,
    productName: 'White Maize',
    recipeName: 'Roller Milling — Maize Meal',
    inputKg: 5000,
    outputKg: 3800,
    wasteKg: 1200,
    status: 'Active',
    startDate: '2026-06-29',
    operatorName: 'Chipo Nzou',
  ),
  const ProcessingRun(
    id: 'RUN-002',
    inputBatchId: 'BAT-002',
    outputBatchId: 'BAT-006',
    productName: 'Potatoes',
    recipeName: 'Washing & Grading Sort',
    inputKg: 3000,
    outputKg: 2700,
    wasteKg: 300,
    status: 'Completed',
    startDate: '2026-06-20',
    endDate: '2026-06-21',
    operatorName: 'Tawanda Mutema',
  ),
];

final _initialSalesOrders = [
  SalesOrder(
    id: 'SO-5001',
    buyerName: 'TM Pick n Pay – Harare',
    buyerRegion: 'Harare',
    lines: const [
      SalesOrderLine(productName: 'White Maize', quantityKg: 8000, unitPricePer100kg: 55.00),
      SalesOrderLine(productName: 'Onions', quantityKg: 1500, unitPricePer100kg: 42.00),
    ],
    status: 'Dispatched',
    paymentStatus: 'Partial',
    orderDate: '2026-06-26',
    dispatchDate: '2026-06-28',
    invoiceId: 'INV-8801',
  ),
  SalesOrder(
    id: 'SO-5002',
    buyerName: 'OK Zimbabwe – Bulawayo',
    buyerRegion: 'Bulawayo',
    lines: const [
      SalesOrderLine(productName: 'Mangoes', quantityKg: 2000, unitPricePer100kg: 110.00),
    ],
    status: 'Confirmed',
    paymentStatus: 'Unpaid',
    orderDate: '2026-06-28',
    invoiceId: 'INV-8802',
  ),
  SalesOrder(
    id: 'SO-5003',
    buyerName: 'Spar Mutare',
    buyerRegion: 'Manicaland',
    lines: const [
      SalesOrderLine(productName: 'Potatoes', quantityKg: 3500, unitPricePer100kg: 50.00),
    ],
    status: 'Delivered',
    paymentStatus: 'Paid',
    orderDate: '2026-06-18',
    dispatchDate: '2026-06-20',
    invoiceId: 'INV-8803',
  ),
];

final _initialTrips = [
  const LogisticsTrip(
    id: 'TRIP-001',
    salesOrderId: 'SO-5001',
    driverName: 'Emmanuel Dube',
    vehiclePlate: 'AFY 2241',
    originWarehouse: 'Harare Central Depot',
    destinationName: 'TM Pick n Pay – Harare',
    destinationLat: -17.8292,
    destinationLng: 31.0524,
    originLat: -17.8638,
    originLng: 31.0285,
    status: 'En Route',
    departureDate: '2026-06-28 07:30',
    eta: '2026-06-28 10:00',
    loadKg: 9500,
    hasProofOfDelivery: false,
  ),
  const LogisticsTrip(
    id: 'TRIP-002',
    salesOrderId: 'SO-5003',
    driverName: 'Tatenda Gomo',
    vehiclePlate: 'AGL 8812',
    originWarehouse: 'Mutare Border Depot',
    destinationName: 'Spar Mutare',
    destinationLat: -18.9706,
    destinationLng: 32.6737,
    originLat: -18.9550,
    originLng: 32.6500,
    status: 'Delivered',
    departureDate: '2026-06-20 06:00',
    eta: '2026-06-20 09:30',
    loadKg: 3500,
    hasProofOfDelivery: true,
  ),
  const LogisticsTrip(
    id: 'TRIP-003',
    salesOrderId: 'SO-5002',
    driverName: 'Blessing Chivhanga',
    vehiclePlate: 'AGT 4450',
    originWarehouse: 'Bulawayo Cold Store',
    destinationName: 'OK Zimbabwe – Bulawayo',
    destinationLat: -20.1494,
    destinationLng: 28.5800,
    originLat: -20.1700,
    originLng: 28.5600,
    status: 'Pending',
    departureDate: '2026-07-02 08:00',
    eta: '2026-07-02 11:00',
    loadKg: 2000,
    hasProofOfDelivery: false,
  ),
];

final _initialAlerts = [
  TradeAlert(
    id: 'ALT-001',
    type: 'ExpiryRisk',
    severity: 'High',
    message: 'BAT-004 Mangoes expire in 12 days. Dispatch immediately.',
    entityId: 'BAT-004',
    createdAt: '2026-06-30 08:00',
  ),
  TradeAlert(
    id: 'ALT-002',
    type: 'QcFail',
    severity: 'Medium',
    message: 'BAT-005 Potatoes have high moisture (22.1%). Expedite processing.',
    entityId: 'BAT-005',
    createdAt: '2026-06-30 08:15',
  ),
  TradeAlert(
    id: 'ALT-003',
    type: 'PoOverdue',
    severity: 'Low',
    message: 'PO-3002 Mango delivery delayed. ETA rescheduled to July 8.',
    entityId: 'PO-3002',
    createdAt: '2026-06-30 09:00',
  ),
];

final _initialPricePoints = [
  const PricePoint(productName: 'White Maize', grade: GradeClass.a, region: 'Harare', pricePer100kg: 55.00, date: '2026-06-30', changePercent: 2.4),
  const PricePoint(productName: 'Potatoes', grade: GradeClass.a, region: 'Harare', pricePer100kg: 50.00, date: '2026-06-30', changePercent: -1.2),
  const PricePoint(productName: 'Mangoes', grade: GradeClass.a, region: 'Harare', pricePer100kg: 110.00, date: '2026-06-30', changePercent: 5.6),
  const PricePoint(productName: 'Onions', grade: GradeClass.a, region: 'Harare', pricePer100kg: 42.00, date: '2026-06-30', changePercent: 0.8),
  const PricePoint(productName: 'Tomatoes', grade: GradeClass.a, region: 'Harare', pricePer100kg: 68.00, date: '2026-06-30', changePercent: -3.1),
];

final _initialCompliance = [
  const ComplianceRecord(
    id: 'CERT-001',
    entityId: 'SUP-01',
    entityName: 'Chiredzi Valley Farms',
    certType: 'Phytosanitary',
    issuedBy: 'Ministry of Agriculture',
    issuedDate: '2026-01-10',
    expiryDate: '2026-12-10',
    status: 'Active',
  ),
  const ComplianceRecord(
    id: 'CERT-002',
    entityId: 'SUP-02',
    entityName: 'Mvurwi Grains Co-op',
    certType: 'HACCP',
    issuedBy: 'ZABS',
    issuedDate: '2025-08-01',
    expiryDate: '2026-07-31',
    status: 'Expiring',
  ),
  const ComplianceRecord(
    id: 'CERT-003',
    entityId: 'SUP-03',
    entityName: 'Eastern Highlands Produce',
    certType: 'ISO 22000',
    issuedBy: 'SAZ',
    issuedDate: '2025-03-20',
    expiryDate: '2027-03-19',
    status: 'Active',
  ),
  const ComplianceRecord(
    id: 'CERT-004',
    entityId: 'SUP-04',
    entityName: 'Bulawayo Fresh Market',
    certType: 'License',
    issuedBy: 'City of Bulawayo',
    issuedDate: '2024-11-01',
    expiryDate: '2025-10-31',
    status: 'Expired',
  ),
];

final _initialAuditLog = [
  const AuditLogEntry(id: 'LOG-001', action: 'Created', entityType: 'PurchaseOrder', entityId: 'PO-3001', performedBy: 'Rudo Chirimba', timestamp: '2026-06-20 09:14'),
  const AuditLogEntry(id: 'LOG-002', action: 'Confirmed', entityType: 'PurchaseOrder', entityId: 'PO-3001', performedBy: 'Farai Mutasa', timestamp: '2026-06-20 14:32'),
  const AuditLogEntry(id: 'LOG-003', action: 'Created', entityType: 'QualityCheck', entityId: 'QC-001', performedBy: 'Farai Mutasa', timestamp: '2026-06-23 10:05'),
  const AuditLogEntry(id: 'LOG-004', action: 'Dispatched', entityType: 'SalesOrder', entityId: 'SO-5001', performedBy: 'Chipo Nzou', timestamp: '2026-06-28 07:00'),
  const AuditLogEntry(id: 'LOG-005', action: 'Delivered', entityType: 'LogisticsTrip', entityId: 'TRIP-002', performedBy: 'Tatenda Gomo', timestamp: '2026-06-20 09:22'),
  const AuditLogEntry(id: 'LOG-006', action: 'Created', entityType: 'ProcessingRun', entityId: 'RUN-001', performedBy: 'Chipo Nzou', timestamp: '2026-06-29 06:30'),
];

// =============================================================================
// NOTIFIERS
// =============================================================================

class TradeSupplierNotifier extends StateNotifier<List<TradeSupplier>> {
  TradeSupplierNotifier({bool isDemo = true}) : super(isDemo ? _initialSuppliers : []);

  void addSupplier(TradeSupplier s) => state = [...state, s];
  void verifySupplier(String id) {
    state = state.map((s) {
      if (s.id == id) {
        return TradeSupplier(
          id: s.id, name: s.name, region: s.region, category: s.category,
          trustScore: s.trustScore, capacityTonnes: s.capacityTonnes,
          isVerified: true, contactName: s.contactName,
          contactPhone: s.contactPhone, primaryProduct: s.primaryProduct,
          totalOrdersFulfilled: s.totalOrdersFulfilled, onboardedDate: s.onboardedDate,
        );
      }
      return s;
    }).toList();
  }
}

class PurchaseOrderNotifier extends StateNotifier<List<PurchaseOrder>> {
  PurchaseOrderNotifier({bool isDemo = true}) : super(isDemo ? _initialPurchaseOrders : []) {
    _syncFromBackend();
  }

  Future<void> _syncFromBackend() async {
    try {
      final data = await VerdiApiService.instance.getOrders();
      final existing = state.map((o) => o.id).toSet();
      final toAdd = data
          .where((json) => !existing.contains(json['id']?.toString()))
          .map((json) => PurchaseOrder(
                id: json['id']?.toString() ?? '',
                supplierId: json['supplierId']?.toString() ?? '',
                productName: json['productName']?.toString() ?? '',
                quantityKg:
                    (json['quantityKg'] as num?)?.toDouble() ?? 0.0,
                unitPricePer100kg:
                    (json['unitPricePer100kg'] as num?)?.toDouble() ?? 0.0,
                status: json['status']?.toString() ?? 'Draft',
                date: json['date']?.toString() ?? '',
                deliveryDate: json['deliveryDate']?.toString() ?? '',
                warehouseId: json['warehouseId']?.toString() ?? '',
                notes: json['notes']?.toString() ?? '',
              ))
          .toList();
      if (toAdd.isNotEmpty && mounted) {
        state = [...toAdd, ...state];
      }
    } catch (_) {
      // Offline — keep local data as-is
    }
  }

  void addOrder(PurchaseOrder po) => state = [...state, po];
  void updateStatus(String id, String newStatus) {
    state = state.map((po) => po.id == id ? po.copyWith(status: newStatus) : po).toList();
  }
}

class StockBatchNotifier extends StateNotifier<List<StockBatch>> {
  StockBatchNotifier({bool isDemo = true}) : super(isDemo ? _initialBatches : []);

  void addBatch(StockBatch b) => state = [...state, b];
  void updateStatus(String id, String newStatus) {
    state = state.map((b) => b.id == id ? b.copyWith(status: newStatus) : b).toList();
  }
}

class WarehouseNotifier extends StateNotifier<List<Warehouse>> {
  WarehouseNotifier({bool isDemo = true}) : super(isDemo ? _initialWarehouses : []);
}

class QualityCheckNotifier extends StateNotifier<List<QualityCheck>> {
  QualityCheckNotifier({bool isDemo = true}) : super(isDemo ? _initialQualityChecks : []);

  void addCheck(QualityCheck qc) => state = [...state, qc];
}

class ProcessingRunNotifier extends StateNotifier<List<ProcessingRun>> {
  ProcessingRunNotifier({bool isDemo = true}) : super(isDemo ? _initialProcessingRuns : []);

  void addRun(ProcessingRun run) => state = [...state, run];
  void completeRun(String id) {
    state = state.map((r) {
      if (r.id == id) {
        return ProcessingRun(
          id: r.id, inputBatchId: r.inputBatchId, outputBatchId: r.outputBatchId,
          productName: r.productName, recipeName: r.recipeName,
          inputKg: r.inputKg, outputKg: r.outputKg, wasteKg: r.wasteKg,
          status: 'Completed', startDate: r.startDate, endDate: 'Today',
          operatorName: r.operatorName,
        );
      }
      return r;
    }).toList();
  }
}

class SalesOrderNotifier extends StateNotifier<List<SalesOrder>> {
  SalesOrderNotifier({bool isDemo = true}) : super(isDemo ? _initialSalesOrders : []);

  void addOrder(SalesOrder so) => state = [...state, so];
  void updateStatus(String id, String newStatus) {
    state = state.map((so) => so.id == id ? so.copyWith(status: newStatus) : so).toList();
  }
  void markPaid(String id) {
    state = state.map((so) => so.id == id ? so.copyWith(paymentStatus: 'Paid') : so).toList();
  }
}

class LogisticsTripNotifier extends StateNotifier<List<LogisticsTrip>> {
  LogisticsTripNotifier({bool isDemo = true}) : super(isDemo ? _initialTrips : []) {
    _syncFromBackend();
  }

  Future<void> _syncFromBackend() async {
    try {
      final data = await VerdiApiService.instance.getDispatches();
      final existing = state.map((t) => t.id).toSet();
      final toAdd = data
          .where((json) => !existing.contains(json['id']?.toString()))
          .map((json) => LogisticsTrip(
                id: json['id']?.toString() ?? '',
                salesOrderId: 'DB-DISPATCH',
                driverName: json['driverName']?.toString() ?? '',
                vehiclePlate: json['truckPlate']?.toString() ?? '',
                originWarehouse: 'Verdi Operations Hub',
                destinationName: json['destination']?.toString() ?? '',
                destinationLat: (json['latitude'] as num?)?.toDouble() ?? -17.8292,
                destinationLng: (json['longitude'] as num?)?.toDouble() ?? 31.0522,
                originLat: -17.8638,
                originLng: 31.0285,
                status: json['status']?.toString() ?? 'Pending',
                departureDate: '2026-07-14 07:00',
                eta: '2026-07-14 12:00',
                loadKg: 5000,
                hasProofOfDelivery:
                    json['status']?.toString() == 'Delivered',
              ))
          .toList();
      if (toAdd.isNotEmpty && mounted) {
        state = [...toAdd, ...state];
      }
    } catch (_) {
      // Offline — keep local data as-is
    }
  }

  void addTrip(LogisticsTrip trip) => state = [...state, trip];
  void updateStatus(String id, String newStatus) {
    state = state.map((t) => t.id == id ? t.copyWith(status: newStatus) : t).toList();
  }
  void confirmDelivery(String id) {
    state = state.map((t) => t.id == id ? t.copyWith(status: 'Delivered', hasProofOfDelivery: true) : t).toList();
  }
}

class TradeAlertNotifier extends StateNotifier<List<TradeAlert>> {
  TradeAlertNotifier({bool isDemo = true}) : super(isDemo ? _initialAlerts : []);

  void dismiss(String id) {
    state = state.map((a) {
      if (a.id == id) a.isDismissed = true;
      return a;
    }).toList();
    state = [...state]; // trigger rebuild
  }
}

class PricePointNotifier extends StateNotifier<List<PricePoint>> {
  PricePointNotifier({bool isDemo = true}) : super(isDemo ? _initialPricePoints : []);
}

class ComplianceNotifier extends StateNotifier<List<ComplianceRecord>> {
  ComplianceNotifier({bool isDemo = true}) : super(isDemo ? _initialCompliance : []);
}

class AuditLogNotifier extends StateNotifier<List<AuditLogEntry>> {
  AuditLogNotifier({bool isDemo = true}) : super(isDemo ? _initialAuditLog : []);

  void addEntry(AuditLogEntry entry) => state = [entry, ...state];
}

// =============================================================================
// PROVIDERS
// =============================================================================

final tradeSupplierProvider =
    StateNotifierProvider<TradeSupplierNotifier, List<TradeSupplier>>(
        (ref) => TradeSupplierNotifier(isDemo: ref.watch(isDemoModeProvider)));

final purchaseOrderProvider =
    StateNotifierProvider<PurchaseOrderNotifier, List<PurchaseOrder>>(
        (ref) => PurchaseOrderNotifier(isDemo: ref.watch(isDemoModeProvider)));

final stockBatchProvider =
    StateNotifierProvider<StockBatchNotifier, List<StockBatch>>(
        (ref) => StockBatchNotifier(isDemo: ref.watch(isDemoModeProvider)));

final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, List<Warehouse>>(
        (ref) => WarehouseNotifier(isDemo: ref.watch(isDemoModeProvider)));

final qualityCheckProvider =
    StateNotifierProvider<QualityCheckNotifier, List<QualityCheck>>(
        (ref) => QualityCheckNotifier(isDemo: ref.watch(isDemoModeProvider)));

final processingRunProvider =
    StateNotifierProvider<ProcessingRunNotifier, List<ProcessingRun>>(
        (ref) => ProcessingRunNotifier(isDemo: ref.watch(isDemoModeProvider)));

final salesOrderProvider =
    StateNotifierProvider<SalesOrderNotifier, List<SalesOrder>>(
        (ref) => SalesOrderNotifier(isDemo: ref.watch(isDemoModeProvider)));

final logisticsTripProvider =
    StateNotifierProvider<LogisticsTripNotifier, List<LogisticsTrip>>(
        (ref) => LogisticsTripNotifier(isDemo: ref.watch(isDemoModeProvider)));

final tradeAlertProvider =
    StateNotifierProvider<TradeAlertNotifier, List<TradeAlert>>(
        (ref) => TradeAlertNotifier(isDemo: ref.watch(isDemoModeProvider)));

final pricePointProvider =
    StateNotifierProvider<PricePointNotifier, List<PricePoint>>(
        (ref) => PricePointNotifier(isDemo: ref.watch(isDemoModeProvider)));

final complianceProvider =
    StateNotifierProvider<ComplianceNotifier, List<ComplianceRecord>>(
        (ref) => ComplianceNotifier(isDemo: ref.watch(isDemoModeProvider)));

final auditLogProvider =
    StateNotifierProvider<AuditLogNotifier, List<AuditLogEntry>>(
        (ref) => AuditLogNotifier(isDemo: ref.watch(isDemoModeProvider)));

/// Selected trade tab index (0-9)
final selectedTradeTabProvider = StateProvider<int>((ref) => 0);

// --- Derived providers ---

final lowStockBatchesProvider = Provider<List<StockBatch>>((ref) {
  final batches = ref.watch(stockBatchProvider);
  return batches.where((b) => b.quantityKg < 2000 && b.status == 'In Stock').toList();
});

final pendingOrdersProvider = Provider<List<PurchaseOrder>>((ref) {
  final orders = ref.watch(purchaseOrderProvider);
  return orders.where((o) => o.status == 'Sent' || o.status == 'Draft').toList();
});

final openAlertsProvider = Provider<List<TradeAlert>>((ref) {
  final alerts = ref.watch(tradeAlertProvider);
  return alerts.where((a) => !a.isDismissed).toList();
});
