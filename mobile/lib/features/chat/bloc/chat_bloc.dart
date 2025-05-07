import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/services/chat_hub_service.dart';
import '../models/chat_message_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatHubService chatHubService;
  final List<ChatMessage> _messages = [];

  ChatBloc({required this.chatHubService}) : super(ChatInitial()) {
    on<ConnectChatEvent>(_onConnectChat);
    on<SendMessageEvent>(_onSendMessage);  // Obsługa wysyłania wiadomości
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<ReceiveHistoryEvent>(_onReceiveHistory);
  }

  /// Obsługa połączenia do chatu
 Future<void> _onConnectChat(ConnectChatEvent event, Emitter<ChatState> emit) async {
  emit(ChatConnecting());
  print("[ChatBloc] Emitting ChatConnecting");

  try {
    await chatHubService.connect(
      baseUrl: event.baseUrl,
      conversationId: event.conversationId,
      userId: event.userId,
      chatBloc: this,
    );
    
    print("[ChatBloc] Connection successful, waiting for history...");
    
    // Od razu emitujemy stan ChatLoaded, jeśli historia zostanie pobrana
    await chatHubService.fetchHistory(event.conversationId, event.userId);
  } catch (e) {
    emit(ChatError('Error connecting: $e'));
  }
}


  /// Obsługa wysyłania wiadomości
  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await chatHubService.sendMessage(
        event.senderId,
        event.conversationId,
        event.text,
      );
      print("[ChatBloc] Message sent: ${event.text}");
    } catch (e) {
      emit(ChatError('Error sending message: $e'));
      print("[ChatBloc] Error sending message: $e");
    }
  }

  /// Obsługa odbioru pojedynczej wiadomości
  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
    print("[ChatBloc] New message received: ${event.message.text}");
    _messages.add(event.message);
    emit(ChatLoaded(List.from(_messages)));
  }

  /// Obsługa odbioru historii wiadomości
  void _onReceiveHistory(ReceiveHistoryEvent event, Emitter<ChatState> emit) {
  _messages.clear();
  _messages.addAll(event.messages);
  
  if (_messages.isNotEmpty) {
    emit(ChatLoaded(List.from(_messages)));
    print("[ChatBloc] ChatLoaded emitted with ${_messages.length} messages");
  } else {
    emit(ChatLoaded([]));
    print("[ChatBloc] No messages found, emitting empty ChatLoaded");
  }
}

}
