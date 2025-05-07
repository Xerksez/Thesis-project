import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/features/profile/models/user_model.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  /// Pobierz token z SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Edytuj profil użytkownika
  Future<void> editUserProfile(User updatedProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = await _getToken();

    if (userId == null || token == null) {
      throw Exception('User ID or token not found in preferences');
    }

    final url = AppConfig.patchUserEndpoint(userId);
    print('Updating profile at: $url');

    // Create JSON Patch document
    final patchDoc = [
      {"op": "replace", "path": "/name", "value": updatedProfile.name},
      {"op": "replace", "path": "/surname", "value": updatedProfile.surname},
      {"op": "replace", "path": "/mail", "value": updatedProfile.email},
      {"op": "replace", "path": "/telephoneNr", "value": updatedProfile.telephoneNr},
      {"op": "replace", "path": "/preferredLanguage", "value": updatedProfile.preferredLanguage},
    ];

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json-patch+json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(patchDoc),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 204 || response.statusCode == 200) {
      print('Profile updated successfully!');
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  /// Wyślij zdjęcie użytkownika
  Future<void> uploadUserImage(int userId, File image) async {
    final url = AppConfig.uploadUserImageEndpoint(userId);
    final token = await _getToken();

    if (token == null) {
      throw Exception('Token not found in preferences');
    }

    print('Uploading image to: $url');

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      request.headers.addAll({
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      var response = await request.send();
      final responseString = await response.stream.bytesToString();

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: $responseString');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Image uploaded successfully!');
      } else {
        throw Exception('Failed to upload image: $responseString');
      }
    } catch (e) {
      print('Error during image upload: $e');
      throw Exception('Error uploading image.');
    }
  }

  /// Cache user profile locally
  Future<void> cacheUserProfile(User profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(profile.toJson());
    print('Caching Profile: $jsonData');
    await prefs.setString('cachedProfile', jsonData);
  }

  /// Logout user and clear cache
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('User logged out and preferences cleared.');
  }

  /// Retrieve cached user profile
  Future<User?> getCachedUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedProfile = prefs.getString('cachedProfile');

    if (cachedProfile != null) {
      final user = User.fromJson(jsonDecode(cachedProfile));

      // Fetch latest user image from the API
      user.userImageUrl = await getUserImage(user.id);

      return user;
    }
    return null;
  }

  /// Pobierz profil użytkownika
  Future<User> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = await _getToken();

    if (userId == null || token == null) {
      throw Exception('User ID or token not found in preferences');
    }

    final url = AppConfig.getProfileEndpoint(userId);
    print('Fetching profile from: $url');

    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      throw Exception('Failed to fetch profile.');
    }
  }

  /// Pobierz URL zdjęcia użytkownika
  Future<String> getUserImage(int userId) async {
  final url = AppConfig.getUserImageEndpoint(userId);
  final token = await _getToken();

  if (token == null) {
    throw Exception('Token not found in preferences');
  }

  try {
    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> images = jsonDecode(response.body);
      return images.isNotEmpty ? images[0] : '';
    }
  } catch (e) {
    print('Failed to fetch user image: $e');
  }

  return ''; // Zwróć pusty string w przypadku błędu
}

}
