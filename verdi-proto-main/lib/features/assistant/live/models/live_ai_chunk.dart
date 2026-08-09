class LiveAiChunk {
  final String conversationId;
  final String text;
  final bool isFinal;

  const LiveAiChunk({
    required this.conversationId,
    required this.text,
    required this.isFinal,
  });

  factory LiveAiChunk.fromMap(Map<String, dynamic> map) {
    return LiveAiChunk(
      conversationId: map['conversationId'] ?? '',
      text: map['text'] ?? '',
      isFinal: map['isFinal'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'text': text,
      'isFinal': isFinal,
    };
  }
}
