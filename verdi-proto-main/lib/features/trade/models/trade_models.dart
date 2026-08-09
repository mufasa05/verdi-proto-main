// =============================================================================
// Trade Intelligence Hub — Core Data Models
// =============================================================================

/// Represents an organisation role in the value chain.
enum OrgType { farmer, wholesaler, processor, retailer, transporter, government }

/// Grade classes for produce quality.
enum GradeClass { a, b, c, rejected }

extension GradeClassLabel on GradeClass {
  String get label {
    switch (this) {
      case GradeClass.a:
        return 'Grade A';
      case GradeClass.b:
        return 'Grade B';
      case GradeClass.c:
        return 'Grade C';
      case GradeClass.rejected:
        return 'Rejected';
    }
  }
}

// =============================================================================
// SUPPLIER
// =============================================================================
class TradeSupplier {
  final String id;
  final String name;
  final String region;
  final String category; // e.g. "Grains", "Vegetables", "Fruits"
  final double trustScore; // 0.0 – 1.0
  final double capacityTonnes;
  final bool isVerified;
  final String contactName;
  final String contactPhone;
  final String primaryProduct;
  final int totalOrdersFulfilled;
  final String onboardedDate;

  const TradeSupplier({
    required this.id,
    required this.name,
    required this.region,
    required this.category,
    required this.trustScore,
    required this.capacityTonnes,
    required this.isVerified,
    required this.contactName,
    required this.contactPhone,
    required this.primaryProduct,
    required this.totalOrdersFulfilled,
    required this.onboardedDate,
  });

  double get reliabilityPct => trustScore * 100;
}

// =============================================================================
// PURCHASE ORDER
// =============================================================================
class PurchaseOrder {
  final String id;
  final String supplierId;
  final String productName;
  final double quantityKg;
  final double unitPricePer100kg;
  final String status; // Draft / Sent / Confirmed / Received / Cancelled
  final String date;
  final String deliveryDate;
  final String warehouseId;
  final String? contractId;
  final String notes;

  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.productName,
    required this.quantityKg,
    required this.unitPricePer100kg,
    required this.status,
    required this.date,
    required this.deliveryDate,
    required this.warehouseId,
    this.contractId,
    this.notes = '',
  });

  double get totalValue => (quantityKg / 100) * unitPricePer100kg;

  PurchaseOrder copyWith({String? status}) {
    return PurchaseOrder(
      id: id,
      supplierId: supplierId,
      productName: productName,
      quantityKg: quantityKg,
      unitPricePer100kg: unitPricePer100kg,
      status: status ?? this.status,
      date: date,
      deliveryDate: deliveryDate,
      warehouseId: warehouseId,
      contractId: contractId,
      notes: notes,
    );
  }
}

// =============================================================================
// WAREHOUSE & BIN
// =============================================================================
class WarehouseBin {
  final String id;
  final String label; // e.g. "A-01", "B-12"
  final bool isOccupied;
  final String? batchId;

  const WarehouseBin({
    required this.id,
    required this.label,
    required this.isOccupied,
    this.batchId,
  });
}

class Warehouse {
  final String id;
  final String name;
  final String location;
  final double capacityTonnes;
  final double currentStockTonnes;
  final List<WarehouseBin> bins;

  const Warehouse({
    required this.id,
    required this.name,
    required this.location,
    required this.capacityTonnes,
    required this.currentStockTonnes,
    required this.bins,
  });

  double get utilisation =>
      capacityTonnes == 0 ? 0 : (currentStockTonnes / capacityTonnes).clamp(0.0, 1.0);
}

// =============================================================================
// STOCK BATCH
// =============================================================================
class StockBatch {
  final String id;
  final String productName;
  final String supplierId;
  final String warehouseId;
  final String binLabel;
  final double quantityKg;
  final GradeClass gradeClass;
  final String lotNumber;
  final String arrivalDate;
  final String? expiryDate;
  final String status; // In Stock / Reserved / Dispatched / Processed / Expired

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
    this.expiryDate,
    required this.status,
  });

  StockBatch copyWith({String? status, double? quantityKg}) {
    return StockBatch(
      id: id,
      productName: productName,
      supplierId: supplierId,
      warehouseId: warehouseId,
      binLabel: binLabel,
      quantityKg: quantityKg ?? this.quantityKg,
      gradeClass: gradeClass,
      lotNumber: lotNumber,
      arrivalDate: arrivalDate,
      expiryDate: expiryDate,
      status: status ?? this.status,
    );
  }
}

// =============================================================================
// QUALITY CHECK
// =============================================================================
class QualityCheck {
  final String id;
  final String batchId;
  final String productName;
  final String inspector;
  final GradeClass assignedGrade;
  final bool passed;
  final double moisturePercent;
  final double weightCheckedKg;
  final String notes;
  final String date;

  const QualityCheck({
    required this.id,
    required this.batchId,
    required this.productName,
    required this.inspector,
    required this.assignedGrade,
    required this.passed,
    required this.moisturePercent,
    required this.weightCheckedKg,
    required this.notes,
    required this.date,
  });
}

// =============================================================================
// PROCESSING RUN
// =============================================================================
class ProcessingRun {
  final String id;
  final String inputBatchId;
  final String? outputBatchId;
  final String productName;
  final String recipeName; // e.g. "Maize Meal Milling", "Tomato Paste"
  final double inputKg;
  final double outputKg;
  final double wasteKg;
  final String status; // Active / Completed / Paused
  final String startDate;
  final String? endDate;
  final String operatorName;

  const ProcessingRun({
    required this.id,
    required this.inputBatchId,
    this.outputBatchId,
    required this.productName,
    required this.recipeName,
    required this.inputKg,
    required this.outputKg,
    required this.wasteKg,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.operatorName,
  });

  double get yieldPercent =>
      inputKg == 0 ? 0 : ((outputKg / inputKg) * 100).clamp(0, 100);
  double get wastePercent =>
      inputKg == 0 ? 0 : ((wasteKg / inputKg) * 100).clamp(0, 100);
}

// =============================================================================
// SALES ORDER LINE & SALES ORDER
// =============================================================================
class SalesOrderLine {
  final String productName;
  final double quantityKg;
  final double unitPricePer100kg;

  const SalesOrderLine({
    required this.productName,
    required this.quantityKg,
    required this.unitPricePer100kg,
  });

  double get lineTotal => (quantityKg / 100) * unitPricePer100kg;
}

class SalesOrder {
  final String id;
  final String buyerName;
  final String buyerRegion;
  final List<SalesOrderLine> lines;
  final String status; // Draft / Confirmed / Dispatched / Delivered / Cancelled
  final String paymentStatus; // Unpaid / Partial / Paid
  final String orderDate;
  final String? dispatchDate;
  final String invoiceId;

  const SalesOrder({
    required this.id,
    required this.buyerName,
    required this.buyerRegion,
    required this.lines,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    this.dispatchDate,
    required this.invoiceId,
  });

  double get totalValue => lines.fold(0, (sum, l) => sum + l.lineTotal);

  SalesOrder copyWith({String? status, String? paymentStatus}) {
    return SalesOrder(
      id: id,
      buyerName: buyerName,
      buyerRegion: buyerRegion,
      lines: lines,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate,
      dispatchDate: dispatchDate,
      invoiceId: invoiceId,
    );
  }
}

// =============================================================================
// LOGISTICS TRIP
// =============================================================================
class LogisticsTrip {
  final String id;
  final String salesOrderId;
  final String driverName;
  final String vehiclePlate;
  final String originWarehouse;
  final String destinationName;
  final double destinationLat;
  final double destinationLng;
  final double originLat;
  final double originLng;
  final String status; // Pending / En Route / Delivered / Delayed
  final String departureDate;
  final String eta;
  final double loadKg;
  final bool hasProofOfDelivery;

  const LogisticsTrip({
    required this.id,
    required this.salesOrderId,
    required this.driverName,
    required this.vehiclePlate,
    required this.originWarehouse,
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLng,
    required this.originLat,
    required this.originLng,
    required this.status,
    required this.departureDate,
    required this.eta,
    required this.loadKg,
    required this.hasProofOfDelivery,
  });

  LogisticsTrip copyWith({String? status, bool? hasProofOfDelivery}) {
    return LogisticsTrip(
      id: id,
      salesOrderId: salesOrderId,
      driverName: driverName,
      vehiclePlate: vehiclePlate,
      originWarehouse: originWarehouse,
      destinationName: destinationName,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      originLat: originLat,
      originLng: originLng,
      status: status ?? this.status,
      departureDate: departureDate,
      eta: eta,
      loadKg: loadKg,
      hasProofOfDelivery: hasProofOfDelivery ?? this.hasProofOfDelivery,
    );
  }
}

// =============================================================================
// TRADE ALERT
// =============================================================================
class TradeAlert {
  final String id;
  final String type; // LowStock / ExpiryRisk / PoOverdue / QcFail / Compliance
  final String severity; // Low / Medium / High / Critical
  final String message;
  final String entityId;
  final String createdAt;
  bool isDismissed;

  TradeAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.entityId,
    required this.createdAt,
    this.isDismissed = false,
  });
}

// =============================================================================
// PRICE POINT (Intelligence)
// =============================================================================
class PricePoint {
  final String productName;
  final GradeClass grade;
  final String region;
  final double pricePer100kg;
  final String date;
  final double changePercent; // positive = increase

  const PricePoint({
    required this.productName,
    required this.grade,
    required this.region,
    required this.pricePer100kg,
    required this.date,
    required this.changePercent,
  });
}

// =============================================================================
// COMPLIANCE RECORD
// =============================================================================
class ComplianceRecord {
  final String id;
  final String entityId; // supplierId or batchId
  final String entityName;
  final String certType; // HACCP / ISO / Phytosanitary / License / LabResult
  final String issuedBy;
  final String issuedDate;
  final String expiryDate;
  final String status; // Active / Expiring / Expired / Pending
  final String? documentUrl;

  const ComplianceRecord({
    required this.id,
    required this.entityId,
    required this.entityName,
    required this.certType,
    required this.issuedBy,
    required this.issuedDate,
    required this.expiryDate,
    required this.status,
    this.documentUrl,
  });
}

// =============================================================================
// AUDIT LOG
// =============================================================================
class AuditLogEntry {
  final String id;
  final String action; // Created / Updated / Approved / Rejected / Dispatched
  final String entityType;
  final String entityId;
  final String performedBy;
  final String timestamp;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.performedBy,
    required this.timestamp,
  });
}
