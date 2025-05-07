class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastUpdated;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastUpdated,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      lastMessage: json['lastMessage'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
