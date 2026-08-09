class FieldModel {
  final String id;
  final String farmId;
  final String name;
  final String cropName;
  final double areaHa;
  final double latitude;
  final double longitude;
  final String boundaryRef;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FieldModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.cropName,
    required this.areaHa,
    required this.latitude,
    required this.longitude,
    required this.boundaryRef,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FieldModel.fromMap(Map<String, dynamic> map) {
    return FieldModel(
      id: map['id'] ?? '',
      farmId: map['farmId'] ?? '',
      name: map['name'] ?? '',
      cropName: map['cropName'] ?? '',
      areaHa: (map['areaHa'] ?? 0).toDouble(),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      boundaryRef: map['boundaryRef'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'cropName': cropName,
      'areaHa': areaHa,
      'latitude': latitude,
      'longitude': longitude,
      'boundaryRef': boundaryRef,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}