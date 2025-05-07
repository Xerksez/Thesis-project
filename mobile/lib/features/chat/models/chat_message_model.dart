class ChatMessage {
  final int senderId;
  final int conversationId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.conversationId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'conversationId': conversationId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'],
      conversationId: json['conversationId'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
