import 'package:mobile/features/chat/bloc/chat_event.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../features/chat/models/chat_message_model.dart';
import '../../features/chat/bloc/chat_bloc.dart';

class ChatHubService {
  late HubConnection _hubConnection;
  bool _connected = false;
bool get isConnected => _connected;
  Future<void> connect({
  required String baseUrl,
  required int conversationId,
  required int userId,
  required ChatBloc chatBloc,
}) async {
  if (_connected) return;

  final hubUrl = '$baseUrl/Chat?conversationId=$conversationId&userId=$userId';
  _hubConnection = HubConnectionBuilder()
    .withUrl(hubUrl, options: HttpConnectionOptions())
    .build();

  _registerSignalRListeners(chatBloc, conversationId);

  _hubConnection.onclose(({Exception? error}) async {
    _connected = false;
    print("[ChatHubService] Connection closed: $error");
    await _retryConnection(baseUrl, conversationId, userId, chatBloc);
  });

  try {
    await _hubConnection.start();
    _connected = true;
    print("[ChatHubService] Connected to SignalR Hub");

    // Pobranie historii po połączeniu
    await fetchHistory(conversationId, userId);
  } catch (e) {
    print("[ChatHubService] Error connecting: $e");
    rethrow;
  }
}

void _registerSignalRListeners(ChatBloc chatBloc, int conversationId) {
  // Najpierw usuń istniejące nasłuchiwacze, jeśli istnieją
  _hubConnection.off("ReceiveMessage");
  _hubConnection.off("ReceiveHistory");

  print("[ChatHubService] Registering SignalR listeners...");

  _hubConnection.on("ReceiveMessage", (params) {
    print("[ChatHubService] ReceiveMessage triggered with params: $params");
    if (params != null && params.length >= 3) {
      final message = ChatMessage(
        senderId: params[0] as int,
        text: params[1] as String,
        timestamp: DateTime.parse(params[2] as String),
        conversationId: conversationId,
      );
      print("[ChatHubService] Received message: ${message.text}");
      chatBloc.add(ReceiveMessageEvent(message: message));
    } else {
      print("[ChatHubService] Invalid ReceiveMessage params: $params");
    }
  });

  _hubConnection.on("ReceiveHistory", (params) {
    print("[ChatHubService] ReceiveHistory triggered with params: $params");
    if (params != null && params.isNotEmpty) {
      final List<dynamic> rawMessages = params[0] as List<dynamic>;
      final history = rawMessages.map((e) {
        return ChatMessage(
          senderId: e['senderId'] as int,
          text: e['text'] as String,
          timestamp: DateTime.parse(e['dateTimeDate']),
          conversationId: conversationId,
        );
      }).toList();

      print("[ChatHubService] History parsed: ${history.length} messages");
      chatBloc.add(ReceiveHistoryEvent(messages: history));
    } else {
      print("[ChatHubService] Empty history received");
    }
  });
}


  // Ponowne połączenie
  Future<void> _retryConnection(String baseUrl, int conversationId, int userId, ChatBloc chatBloc) async {
    while (!_connected) {
      try {
        print("[ChatHubService] Attempting to reconnect...");
        await _hubConnection.start();
        _connected = true;
        print("[ChatHubService] Reconnected to SignalR Hub");

        _registerSignalRListeners(chatBloc, conversationId);
        await fetchHistory(conversationId, userId);
      } catch (e) {
        print("[ChatHubService] Reconnection failed: $e");
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> fetchHistory(int conversationId, int userId) async {
    if (_connected) {
      try {
        await _hubConnection.invoke("FetchHistory", args: [conversationId, userId]);
        print("[ChatHubService] FetchHistory invoked for conversationId: $conversationId and userId: $userId");
      } catch (e) {
        print("[ChatHubService] Error fetching history: $e");
      }
    } else {
      print("[ChatHubService] Connection is not active.");
    }
  }

  Future<void> sendMessage(int senderId, int conversationId, String text) async {
    print("[ChatHubService] Connection state: ${_hubConnection.state}");
    if (_connected) {
      await _hubConnection.invoke("SendMessage", args: [senderId, conversationId, text]);
      print("[ChatHubService] Message sent: $text");
    } else {
      print("[ChatHubService] Connection is not active.");
    }
  }

  Future<void> dispose() async {
    if (_connected) {
      await _hubConnection.stop();
      _connected = false;
      print("[ChatHubService] Disconnected from SignalR Hub");
    }
  }
}