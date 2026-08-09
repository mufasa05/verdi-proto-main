class BatchDocumentModel {
  final String id;
  final String batchId;
  final String docType;
  final String fileName;
  final String fileUrl;
  final String uploadedBy;
  final DateTime uploadedAt;

  const BatchDocumentModel({
    required this.id,
    required this.batchId,
    required this.docType,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory BatchDocumentModel.fromMap(Map<String, dynamic> map) {
    return BatchDocumentModel(
      id: map['id'] ?? '',
      batchId: map['batchId'] ?? '',
      docType: map['docType'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: DateTime.tryParse(map['uploadedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchId': batchId,
      'docType': docType,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}