import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TeamService {
  // Fetch the token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust the key name if necessary
  }

 
  Future<String> fetchUserImage(int userId) async {
    final token = await _getToken();
    final url = AppConfig.getUserImageEndpoint(userId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty && data[0] is String) {
          final imageUrl = data[0];
          return imageUrl;
        } else {
          throw Exception('Invalid JSON structure');
        }
      } else {
        throw Exception('Failed to fetch image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return ''; // Return an empty string in case of error
    }
  }

  Future<List<Map<String, dynamic>>> getTeamMembers() async {
  print("[TeamService] Fetching team members...");
  final prefs = await SharedPreferences.getInstance();
  final token = await _getToken();
  final teamId = prefs.getInt('placeId') ?? 0;

  final url = AppConfig.getTeammByAddressIdEndpoint(teamId);

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("[TeamService] Data fetched from API: $data");

      return data.map<Map<String, dynamic>>((member) {
        // Safely handle null values for each field
        return {
          'id': member['id'] ?? 0,
          'name': member['name'] ?? '',
          'surname': member['surname'] ?? '',
          'email': member['mail'] ?? '',
          'phone': member['telephoneNr'] ?? '',
          'userImageUrl': member['userImageUrl'] ?? '',
          'preferredLanguage': member['preferredLanguage'] ?? 'en', // Default to 'en'
          'roleId': member['roleId'] ?? 0,
          'roleName': member['roleName'] ?? 'No Role', // Default role name
          'powerLevel': member['powerLevel'] ?? 0,
        };
      }).toList();
    } else {
      print("[TeamService] Error fetching team members. Status: ${response.statusCode}");
      throw Exception('Failed to load team members');
    }
  } catch (e) {
    print("[TeamService] Error fetching team members: $e");
    throw Exception('Error fetching team members: $e');
  }
}

}
