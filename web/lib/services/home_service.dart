import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class HomeService {
  final String baseUrl = 'https://buildbuddy-api-fwezfydta4atcags.northeurope-01.azurewebsites.net/api/User';

  // Pobierz token z cookies
  String? _getAuthToken() {
    return (html.document.cookie?.split('; ') ?? [])
        .firstWhere((cookie) => cookie.startsWith('userToken='), orElse: () => '')
        .split('=')[1];
  }

  // Pobierz userId z cookies
  int? _getUserId() {
    return int.tryParse(
      (html.document.cookie?.split('; ') ?? [])
          .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
          .split('=')[1],
    );
  }

  // Pobierz dane użytkownika
  Future<Map<String, dynamic>> fetchUserInfo() async {
    final userId = _getUserId();
    final token = _getAuthToken();

    if (userId == null || token == null) {
      throw Exception("Nie znaleziono userId lub tokenu.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Błąd pobierania danych użytkownika: ${response.statusCode}');
    }
  }

  // Pobierz link do zdjęcia użytkownika
  Future<String> fetchUserImage() async {
    final userId = _getUserId();
    final token = _getAuthToken();

    if (userId == null || token == null) {
      throw Exception("Nie znaleziono userId lub tokenu.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$userId/image'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['imageUrl'];
    } else {
      throw Exception('Błąd pobierania zdjęcia użytkownika: ${response.statusCode}');
    }
  }

  // Prześlij nowe zdjęcie użytkownika
  Future<void> uploadUserImage(File imageFile) async {
    final userId = _getUserId();
    final token = _getAuthToken();

    if (userId == null || token == null) {
      throw Exception("Nie znaleziono userId lub tokenu.");
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$userId/upload-image'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode != 200|| response.statusCode != 204) {
      throw Exception('Błąd przesyłania zdjęcia: ${response.statusCode}');
    }
  }
}
