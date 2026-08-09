class FarmModel {
  final String id;
  final String name;
  final String ownerName;
  final String region;
  final String district;
  final String village;
  final double latitude;
  final double longitude;
  final String registrationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.region,
    required this.district,
    required this.village,
    required this.latitude,
    required this.longitude,
    required this.registrationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmModel.fromMap(Map<String, dynamic> map) {
    return FarmModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerName: map['ownerName'] ?? '',
      region: map['region'] ?? '',
      district: map['district'] ?? '',
      village: map['village'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      registrationStatus: map['registrationStatus'] ?? 'Pending',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerName': ownerName,
      'region': region,
      'district': district,
      'village': village,
      'latitude': latitude,
      'longitude': longitude,
      'registrationStatus': registrationStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}