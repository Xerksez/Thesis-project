abstract class NewMessageEvent {}

class SendMessage extends NewMessageEvent {
  final int userId;
  final List<String> recipientNames;
  final String message;

  SendMessage({required this.userId, required this.recipientNames, required this.message});
}
