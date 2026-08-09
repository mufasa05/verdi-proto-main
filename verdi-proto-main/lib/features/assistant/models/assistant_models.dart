enum AssistantMessageRole { user, assistant, system }

enum AssistantIntent {
  generalQuestion,
  cropAdvice,
  weatherQuery,
  cropHealthQuery,
  orderQuery,
  paymentQuery,
  tradeQuery,
  exportQuery,
  notificationSummary,
  navigation,
  actionRequest,
  imageDiagnosis,
  unknown,
}

enum AssistantConfidenceLevel { low, medium, high }

class AssistantConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  const AssistantConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  factory AssistantConversation.fromMap(Map<String, dynamic> map) {
    return AssistantConversation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      isPinned: map['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
    };
  }
}

class AssistantMessage {
  final String id;
  final String conversationId;
  final AssistantMessageRole role;
  final String text;
  final List<String> attachmentUrls;
  final AssistantIntent intent;
  final AssistantConfidenceLevel confidence;
  final DateTime createdAt;
  final List<String> sourceIds;
  final String? actionLabel;
  final String? actionRoute;

  const AssistantMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    this.attachmentUrls = const [],
    this.intent = AssistantIntent.unknown,
    this.confidence = AssistantConfidenceLevel.medium,
    required this.createdAt,
    this.sourceIds = const [],
    this.actionLabel,
    this.actionRoute,
  });

  factory AssistantMessage.fromMap(Map<String, dynamic> map) {
    return AssistantMessage(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      role: AssistantMessageRole.values[map['role'] ?? 1],
      text: map['text'] ?? '',
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? const []),
      intent: AssistantIntent.values[map['intent'] ?? AssistantIntent.unknown.index],
      confidence: AssistantConfidenceLevel.values[map['confidence'] ?? AssistantConfidenceLevel.medium.index],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      sourceIds: List<String>.from(map['sourceIds'] ?? const []),
      actionLabel: map['actionLabel'],
      actionRoute: map['actionRoute'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.index,
      'text': text,
      'attachmentUrls': attachmentUrls,
      'intent': intent.index,
      'confidence': confidence.index,
      'createdAt': createdAt.toIso8601String(),
      'sourceIds': sourceIds,
      'actionLabel': actionLabel,
      'actionRoute': actionRoute,
    };
  }
}

class AssistantSource {
  final String id;
  final String module;
  final String title;
  final String detail;
  final double weight;
  final DateTime createdAt;

  const AssistantSource({
    required this.id,
    required this.module,
    required this.title,
    required this.detail,
    required this.weight,
    required this.createdAt,
  });

  factory AssistantSource.fromMap(Map<String, dynamic> map) {
    return AssistantSource(
      id: map['id'] ?? '',
      module: map['module'] ?? '',
      title: map['title'] ?? '',
      detail: map['detail'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module': module,
      'title': title,
      'detail': detail,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AssistantTask {
  final String id;
  final String title;
  final String module;
  final String status;
  final DateTime createdAt;

  const AssistantTask({
    required this.id,
    required this.title,
    required this.module,
    required this.status,
    required this.createdAt,
  });

  factory AssistantTask.fromMap(Map<String, dynamic> map) {
    return AssistantTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      module: map['module'] ?? '',
      status: map['status'] ?? 'open',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'module': module,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}