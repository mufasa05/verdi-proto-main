enum LiveAiEventType {
  token,
  summary,
  alert,
  task,
  insight,
  action,
  system,
}

enum LiveAiEventSeverity {
  low,
  medium,
  high,
  critical,
}

class LiveAiEvent {
  final String id;
  final LiveAiEventType type;
  final LiveAiEventSeverity severity;
  final String title;
  final String message;
  final String sourceModule;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const LiveAiEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.sourceModule,
    required this.createdAt,
    this.metadata = const {},
  });

  factory LiveAiEvent.fromMap(Map<String, dynamic> map) {
    return LiveAiEvent(
      id: map['id'] ?? '',
      type: LiveAiEventType.values[map['type'] ?? LiveAiEventType.system.index],
      severity: LiveAiEventSeverity.values[map['severity'] ?? LiveAiEventSeverity.low.index],
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      sourceModule: map['sourceModule'] ?? 'system',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? const {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'severity': severity.index,
      'title': title,
      'message': message,
      'sourceModule': sourceModule,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
