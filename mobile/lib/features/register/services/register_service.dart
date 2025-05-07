import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model_register.dart';
import 'package:mobile/shared/config/config.dart';



class RegisterService {
  static Future<bool> registerUser(User user) async {
    final url = AppConfig.registerEndpoint();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(user.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }
}

