import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationService {
  ConversationService();

  // Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Shared function to handle HTTP requests with token
  Future<http.Response> _makeRequest(String url, String method) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('[ConversationService] Missing token for authorization.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(Uri.parse(url), headers: headers);
        default:
          throw Exception('[ConversationService] Unsupported HTTP method: $method');
      }
    } catch (e) {
      throw Exception('[ConversationService] Error making request to $url: $e');
    }
  }

  /// Fetches raw data from the endpoint, adds the 'usersName' key, and returns a list of conversations.
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('userId') ?? 0;
    final endpoint = AppConfig.getChatListEndpoint(currentUserId);

    try {
      final response = await _makeRequest(endpoint, 'GET');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('[ConversationService] Fetched ${data.length} conversations from API.');
        return data.map((c) => c as Map<String, dynamic>).toList();
      } else if (response.statusCode == 404) {
        print('[ConversationService] No conversations found (404).');
        return []; // Return an empty list for 404
      } else {
        throw Exception('[ConversationService] Failed to load conversations. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[ConversationService] Error fetching conversations: $e');
      throw Exception('Error fetching conversations: $e');
    }
  }

  /// Saves raw conversations to cache
  Future<void> saveConversationsToCache(List<Map<String, dynamic>> conversations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(conversations);
      await prefs.setString('conversations_cache', jsonData);
      print('[ConversationService] Saved ${conversations.length} conversations to cache.');
    } catch (e) {
      print('[ConversationService] Error saving to cache: $e');
      throw Exception('Error saving conversations to cache: $e');
    }
  }

  /// Reads raw conversations from cache
  Future<List<Map<String, dynamic>>> loadConversationsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('conversations_cache');
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<Map<String, dynamic>> result =
            decoded.map((item) => item as Map<String, dynamic>).toList();
        print('[ConversationService] Loaded ${result.length} conversations from cache.');
        return result;
      }
      print('[ConversationService] No conversations in cache.');
      return [];
    } catch (e) {
      print('[ConversationService] Error loading from cache: $e');
      throw Exception('Error loading conversations from cache: $e');
    }
  }
}
