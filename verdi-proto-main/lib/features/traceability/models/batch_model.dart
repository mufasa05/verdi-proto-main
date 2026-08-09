class BatchModel {
  final String id;
  final String batchCode;
  final String farmId;
  final String fieldId;
  final String cropName;
  final DateTime harvestDate;
  final int quantity;
  final String unit;
  final String status;
  final double readinessScore;
  final bool originVerified;
  final bool inspectionPassed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BatchModel({
    required this.id,
    required this.batchCode,
    required this.farmId,
    required this.fieldId,
    required this.cropName,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.readinessScore,
    required this.originVerified,
    required this.inspectionPassed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BatchModel.fromMap(Map<String, dynamic> map) {
    return BatchModel(
      id: map['id'] ?? '',
      batchCode: map['batchCode'] ?? '',
      farmId: map['farmId'] ?? '',
      fieldId: map['fieldId'] ?? '',
      cropName: map['cropName'] ?? '',
      harvestDate: DateTime.tryParse(map['harvestDate'] ?? '') ?? DateTime.now(),
      quantity: (map['quantity'] ?? 0) is int
          ? map['quantity']
          : int.tryParse('${map['quantity']}') ?? 0,
      unit: map['unit'] ?? 'kg',
      status: map['status'] ?? 'Review',
      readinessScore: (map['readinessScore'] ?? 0).toDouble(),
      originVerified: map['originVerified'] ?? false,
      inspectionPassed: map['inspectionPassed'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchCode': batchCode,
      'farmId': farmId,
      'fieldId': fieldId,
      'cropName': cropName,
      'harvestDate': harvestDate.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'status': status,
      'readinessScore': readinessScore,
      'originVerified': originVerified,
      'inspectionPassed': inspectionPassed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}