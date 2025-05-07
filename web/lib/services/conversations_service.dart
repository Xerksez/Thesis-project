import 'dart:convert';
import 'package:universal_io/io.dart'; // Użycie poprawnego importu
import 'package:universal_html/html.dart' as html;
import 'package:web_app/config/config.dart';

class ConversationsService {
  ConversationsService();

  String _getAuthToken() {
    final cookies = html.document.cookie?.split('; ') ?? [];
    final tokenCookie = cookies.firstWhere(
      (cookie) => cookie.startsWith('userToken='),
      orElse: () => '',
    );
    return tokenCookie.split('=').last;
  }

  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final currentUserId = int.tryParse(
        (html.document.cookie?.split('; ') ?? [])
            .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
            .split('=')[1]) ??
        0;
    final endpoint = AppConfig.getChatListEndpoint(currentUserId);
    final client = HttpClient();

    print('[ConversationsService] Fetching conversations for userId: $currentUserId');
    print('[ConversationsService] Endpoint: $endpoint');

    try {
      final token = _getAuthToken();
      final request = await client.getUrl(Uri.parse(endpoint));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      print('[ConversationsService] Sending request to $endpoint');

      final response = await request.close();
      print('[ConversationsService] Response received with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('[ConversationsService] Response body: $responseBody');

        final List<dynamic> data = jsonDecode(responseBody);
        print('[ConversationsService] Parsed conversations count: ${data.length}');
        return data.map((c) => c as Map<String, dynamic>).toList();
      } else if (response.statusCode == 404) {
        print('[ConversationsService] No conversations found (404)');
        return [];
      } else {
        print('[ConversationsService] Failed to load conversations. Status code: ${response.statusCode}');
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      print('[ConversationsService] Error fetching conversations: $e');
      throw Exception('Error fetching conversations: $e');
    } finally {
      client.close();
      print('[ConversationsService] HttpClient closed');
    }
  }
}
