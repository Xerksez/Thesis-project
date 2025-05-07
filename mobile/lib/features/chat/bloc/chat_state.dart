import '../models/chat_message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatConnecting extends ChatState {}

class ChatConnected extends ChatState {}

class ChatHistoryLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  ChatLoaded(this.messages) {
    print("[ChatState] ChatLoaded with ${messages.length} messages");
  }

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String errorMessage;

  ChatError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
