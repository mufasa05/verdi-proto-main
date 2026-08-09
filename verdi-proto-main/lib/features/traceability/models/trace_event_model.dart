class TraceEventModel {
  final String id;
  final String batchId;
  final String eventType;
  final DateTime eventTime;
  final String actorName;
  final String location;
  final String notes;

  const TraceEventModel({
    required this.id,
    required this.batchId,
    required this.eventType,
    required this.eventTime,
    required this.actorName,
    required this.location,
    required this.notes,
  });

  factory TraceEventModel.fromMap(Map<String, dynamic> map) {
    return TraceEventModel(
      id: map['id'] ?? '',
      batchId: map['batchId'] ?? '',
      eventType: map['eventType'] ?? '',
      eventTime: DateTime.tryParse(map['eventTime'] ?? '') ?? DateTime.now(),
      actorName: map['actorName'] ?? '',
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchId': batchId,
      'eventType': eventType,
      'eventTime': eventTime.toIso8601String(),
      'actorName': actorName,
      'location': location,
      'notes': notes,
    };
  }
}