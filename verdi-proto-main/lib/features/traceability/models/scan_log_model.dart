class ScanLogModel {
  final String id;
  final String batchId;
  final DateTime scannedAt;
  final String scannerRole;
  final String scannerName;
  final String result;

  const ScanLogModel({
    required this.id,
    required this.batchId,
    required this.scannedAt,
    required this.scannerRole,
    required this.scannerName,
    required this.result,
  });

  factory ScanLogModel.fromMap(Map<String, dynamic> map) {
    return ScanLogModel(
      id: map['id'] ?? '',
      batchId: map['batchId'] ?? '',
      scannedAt: DateTime.tryParse(map['scannedAt'] ?? '') ?? DateTime.now(),
      scannerRole: map['scannerRole'] ?? '',
      scannerName: map['scannerName'] ?? '',
      result: map['result'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchId': batchId,
      'scannedAt': scannedAt.toIso8601String(),
      'scannerRole': scannerRole,
      'scannerName': scannerName,
      'result': result,
    };
  }
}