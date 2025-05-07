import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatPollingService {
  late Timer _timer;
  final int pollingInterval = 10; // Interval in seconds
  bool _isPolling = false;

  // Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Start polling for new messages
  Future<void> startPolling() async {
    if (_isPolling) {
      return; // Prevent multiple polling instances
    }

    _isPolling = true;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      print("[ChatPollingService] User not logged in, stopping polling.");
      return;
    }

    print("[ChatPollingService] Starting polling for userId: $userId");

    _timer = Timer.periodic(Duration(seconds: pollingInterval), (timer) async {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print("[ChatPollingService] Token is missing or empty.");
        stopPolling();
        return;
      }

      final chatListUrl = AppConfig.getChatListEndpoint(userId);
      print("[ChatPollingService] Fetching chat list from: $chatListUrl");

      try {
        final response = await http.get(
          Uri.parse(chatListUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> conversations = json.decode(response.body);
          print("[ChatPollingService] Fetched ${conversations.length} conversations");

          for (var conversation in conversations) {
            
            final conversationId = conversation['id'];
            final unreadCountUrl = AppConfig.unreadCountEndpoint(conversationId, userId);

            final unreadResponse = await http.get(
              Uri.parse(unreadCountUrl),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            );

            if (unreadResponse.statusCode == 200) {
              final unreadData = json.decode(unreadResponse.body);
              
              if (unreadData.containsKey('time')) {
                final lastMessageTime = DateTime.parse(unreadData['time']);
                final currentTime = DateTime.now();

                // Save the latest message time in SharedPreferences
                await prefs.setString('lastMessageTime_$conversationId', lastMessageTime.toIso8601String());

                // Log new messages
                if (lastMessageTime.isAfter(currentTime.subtract(Duration(minutes: 5)))) {
                  print("[ChatPollingService] New messages detected in conversationId: $conversationId");
                } else {
                  print("[ChatPollingService] No new messages in conversationId: $conversationId");
                }
              } else {
                print("[ChatPollingService] No 'time' field in unread count response for conversationId: $conversationId");
              }
            } else {
              print("[ChatPollingService] Error fetching unread count for conversationId: $conversationId. Status code: ${unreadResponse.statusCode}");
            }
          }
        } else {
          print("[ChatPollingService] Error fetching conversation list. Status code: ${response.statusCode}");
        }
      } catch (e) {
        print("[ChatPollingService] Error occurred during polling: $e");
      }
    });
  }

  // Stop polling
  void stopPolling() {
    if (_isPolling) {
      _timer.cancel();
      _isPolling = false;
      print("[ChatPollingService] Stopped polling.");
    } else {
      print("[ChatPollingService] Polling was not active.");
    }
  }
}
