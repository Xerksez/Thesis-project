import 'package:signalr_core/signalr_core.dart';

class ChatHubService {
  late HubConnection _connection;
  bool _connected = false;

  Future<void> connect({
    required String baseUrl,
    required int conversationId,
    required int userId,
    required void Function(Map<String, dynamic>) onMessageReceived,
    required void Function(List<Map<String, dynamic>>) onHistoryReceived,
  }) async {
    final url = '$baseUrl/Chat?conversationId=$conversationId&userId=$userId';
    print("[ChatHubService] Connecting to $url");

    _connection = HubConnectionBuilder()
    .withUrl(
    url,
    HttpConnectionOptions(
      skipNegotiation: false,
      transport: HttpTransportType.webSockets,),
    )
    .withAutomaticReconnect()
    .build();

    _connection.on("ReceiveMessage", (args) {
      if (args != null && args.isNotEmpty) {
        print("[ChatHubService] Message received: $args");
        final message = {
          'senderId': args[0],
          'text': args[1],
          'timestamp': args[2],
        };
        onMessageReceived(message);
      }
    });

    _connection.on("ReceiveHistory", (args) {
      if (args != null && args.isNotEmpty) {
        print("[ChatHubService] History received: $args");
        final history = (args[0] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        onHistoryReceived(history);
      }
    });

    _connection.onclose((error) {
      print("[ChatHubService] Connection closed: $error");
      _connected = false;
    });

    try {
      await _connection.start();
      _connected = true;
      print("[ChatHubService] Connected to SignalR Hub");
    } catch (e) {
      print("[ChatHubService] Error connecting to SignalR: $e");
    }
  }

  Future<void> sendMessage(int senderId, int conversationId, String text) async {
    if (_connected) {
      try {
        await _connection.invoke("SendMessage", args: [senderId, conversationId, text]);
        print("[ChatHubService] Message sent: $text");
      } catch (e) {
        print("[ChatHubService] Error sending message: $e");
      }
    } else {
      print("[ChatHubService] Not connected to the hub.");
    }
  }

  Future<void> fetchHistory(int conversationId, int userId) async {
  print("[ChatHubService] Invoking FetchHistory for conversationId=$conversationId, userId=$userId");
  try {
    await _connection.invoke("FetchHistory", args: [conversationId, userId]);
    print("[ChatHubService] FetchHistory invoked successfully.");
  } catch (e) {
    print("[ChatHubService] Error invoking FetchHistory: $e");
  }
}

  void disconnect() async {
    if (_connected) {
      try {
        await _connection.stop();
        _connected = false;
        print("[ChatHubService] Disconnected from SignalR Hub");
      } catch (e) {
        print("[ChatHubService] Error during disconnect: $e");
      }
    }
  }
}
