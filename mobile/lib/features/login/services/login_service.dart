import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';

class LoginService {
  Future<LoginResponse> login(String email, String password) async {
    final url = AppConfig.getLoginEndpoint();
    print('Sending POST request to $url with email: $email');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful login
        final token = json.decode(response.body)['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        print(token);
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // Unauthorized (e.g., invalid credentials)
        final errorDetails = json.decode(response.body)['message'] ??
            'Invalid email or password. Please try again.';
        throw Exception(errorDetails);
      } else if (response.statusCode == 400) {
        // Bad request (e.g., malformed request or missing fields)
        final errorDetails = json.decode(response.body)['message'] ??
            'Bad request. Please check your input.';
        throw Exception(errorDetails);
      } else if (response.statusCode == 404) {
        // Resource not found (e.g., API endpoint missing)
        throw Exception('Server not found. Please try again later.');
      } else if (response.statusCode >= 500) {
        // Internal server error
        throw Exception('Server error. Please try again later.');
      } else {
        // Other server-side errors
        throw Exception(
            'Unexpected error. Try again later');
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }
}
