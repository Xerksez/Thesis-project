import 'package:equatable/equatable.dart';
import 'package:mobile/features/chat/models/chat_message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectChatEvent extends ChatEvent {
  final String baseUrl;
  final int conversationId;
  final int userId;  // Dodane pole userId

  const ConnectChatEvent({
    required this.baseUrl,
    required this.conversationId,
    required this.userId,  // Dodaj wymagany userId do konstruktora
  });

  @override
  List<Object?> get props => [baseUrl, conversationId, userId];
}

class SendMessageEvent extends ChatEvent {
  final int senderId;
  final int conversationId;
  final String text;

  const SendMessageEvent({
    required this.senderId,
    required this.conversationId,
    required this.text,
  });

  @override
  List<Object?> get props => [senderId, conversationId, text];
}

class ReceiveMessageEvent extends ChatEvent {
  final ChatMessage message;

  const ReceiveMessageEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReceiveHistoryEvent extends ChatEvent {
  final List<ChatMessage> messages;

  const ReceiveHistoryEvent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatLoadedEvent extends ChatEvent {
  final int conversationId;

  const ChatLoadedEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

class FetchHistoryEvent extends ChatEvent {
  final int conversationId;

  const FetchHistoryEvent({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}
