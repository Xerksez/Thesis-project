import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMessageService {
  /// Get the token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Pobierz identyfikatory odbiorców na podstawie nazw i użytkownika
  Future<List<int>> getRecipientIds(int userId, List<String> recipientNames) async {
    final Set<int> recipientIds = {};
    print('[NewMessageService] Fetching recipient IDs for userId: $userId');

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(AppConfig.getTeamsEndpoint(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> teams = json.decode(response.body);
        print('[NewMessageService] Teams fetched: $teams');

        for (var team in teams) {
          final teamId = team['id'];
          final membersResponse = await http.get(
            Uri.parse(AppConfig.getTeammatesEndpoint(teamId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (membersResponse.statusCode == 200) {
            final List<dynamic> teammates = json.decode(membersResponse.body);
            print('[NewMessageService] Teammates for teamId $teamId: $teammates');

            for (var mate in teammates) {
              final String fullName = '${mate['name']} ${mate['surname']}';
              if (recipientNames.contains(fullName) && mate['id'] != userId) {
                recipientIds.add(mate['id']);
                print('[NewMessageService] Added recipient ID: ${mate['id']} for $fullName');
              }
            }
          } else {
            print('[NewMessageService] Error fetching teammates for teamId $teamId: ${membersResponse.statusCode}');
          }
        }
      } else {
        print('[NewMessageService] Error fetching teams: ${response.statusCode}');
        throw Exception('Failed to fetch teams: ${response.body}');
      }
    } catch (e) {
      print('[NewMessageService] Error during getRecipientIds: $e');
      throw Exception('Error fetching recipient IDs: $e');
    }

    print('[NewMessageService] Final recipient IDs: $recipientIds');
    return recipientIds.toList();
  }

  /// Pobierz dane konwersacji
  Future<Map<String, dynamic>> getConversationData(int conversationId) async {
    print('[NewMessageService] Fetching conversation data for ID: $conversationId');
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.getBaseUrl()}/api/Conversation/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch conversation data: ${response.body}');
      }
    } catch (e) {
      print('[NewMessageService] Error fetching conversation data: $e');
      throw Exception('Error fetching conversation data: $e');
    }
  }

  /// Znajdź lub utwórz nową konwersację
  Future<int> findOrCreateConversation(int userId, List<int> recipientIds) async {
    recipientIds = recipientIds.toSet().toList()..sort();
    print('[NewMessageService] Searching for conversation with recipient IDs: $recipientIds');

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(AppConfig.getChatListEndpoint(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> conversations = json.decode(response.body);

        for (var conversation in conversations) {
          final List<dynamic> participants = conversation['users'];
          final participantIds = participants
              .map((p) => p['id'])
              .where((id) => id != userId)
              .toSet()
              .toList()
            ..sort();

          print('[NewMessageService] Comparing participant IDs: $participantIds with $recipientIds');
          if (const ListEquality().equals(participantIds, recipientIds)) {
            print('[NewMessageService] Found existing conversation: ${conversation['id']}');
            return conversation['id'];
          }
        }
      } else {
        print('[NewMessageService] Error fetching conversations: ${response.statusCode}');
        throw Exception('Failed to fetch conversations: ${response.body}');
      }
    } catch (e) {
      print('[NewMessageService] Error during findOrCreateConversation: $e');
      throw Exception('Error finding or creating conversation: $e');
    }

    // Jeśli nie znaleziono istniejącej konwersacji, utwórz nową
    return await _createNewConversation(userId, recipientIds);
  }

  /// Utwórz nową konwersację
  Future<int> _createNewConversation(int userId, List<int> recipientIds) async {
    print('[NewMessageService] Creating new conversation for userId: $userId');
    try {
      final token = await _getToken();
      final uri = Uri.parse(
        '${AppConfig.createConversationEndpoint()}?user1Id=$userId&user2Id=${recipientIds.first}',
      );

      final createResponse = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (createResponse.statusCode == 200) {
        final newConversation = json.decode(createResponse.body);
        final conversationId = newConversation['conversationId'];
        print('[NewMessageService] New conversation created: $conversationId');

        for (int i = 1; i < recipientIds.length; i++) {
          await _addUserToConversation(conversationId, recipientIds[i]);
        }

        return conversationId;
      } else {
        throw Exception('Failed to create conversation: ${createResponse.body}');
      }
    } catch (e) {
      print('[NewMessageService] Error creating new conversation: $e');
      throw Exception('Error creating new conversation: $e');
    }
  }

  /// Dodaj użytkownika do konwersacji
  Future<void> _addUserToConversation(int conversationId, int userId) async {
    final token = await _getToken();
    final addUserUri = Uri.parse(
      '${AppConfig.getBaseUrl()}/api/Conversation/$conversationId/addUser?userId=$userId',
    );

    try {
      final addUserResponse = await http.post(
        addUserUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (addUserResponse.statusCode == 200) {
        print('[NewMessageService] Added user $userId to conversation $conversationId');
      } else if (addUserResponse.statusCode == 409) {
        print('[NewMessageService] User $userId already exists in conversation $conversationId');
      } else {
        print('[NewMessageService] Error adding user $userId: ${addUserResponse.statusCode}');
        throw Exception('Failed to add user to conversation: ${addUserResponse.body}');
      }
    } catch (e) {
      print('[NewMessageService] Error adding user to conversation: $e');
      throw Exception('Error adding user to conversation: $e');
    }
  }
}
