import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  /// Fetch teams for a user by userId
  Future<List<dynamic>> fetchTeams(int userId) async {
    print('[HomeService] Fetching teams for userId: $userId');

    // Retrieve token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('[HomeService] Token not found. Resetting user data...');
      // If token is not found, reset user data
      await _resetUserData();
      throw Exception('Brak tokena użytkownika. Użytkownik jest wylogowany.');
    }

    // Construct the URL for the API endpoint
    final url = AppConfig.getTeamsEndpoint(userId);
    print('[HomeService] Requesting URL: $url');

    try {
      // Make the HTTP GET request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      print('[HomeService] Response status: ${response.statusCode}');
      print('[HomeService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse and return the response body as a list
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 404) {
        // Handle 404 error specifically
        print('[HomeService] No teams found for user with ID $userId.');
        return [];
      } else {
        throw Exception('Failed to fetch teams: ${response.body}');
      }
    } catch (e) {
      print('[HomeService] Error during fetchTeams: $e');
      throw Exception('Błąd podczas pobierania zespołów: $e');
    }
  }

  /// Reset user data in SharedPreferences
  Future<void> _resetUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Remove user ID
    await prefs.remove('token'); // Remove user token
    print('[HomeService] User data reset.');
  }
}
