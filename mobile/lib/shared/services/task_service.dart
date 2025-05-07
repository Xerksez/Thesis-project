import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class TaskService {
  /// Pobierz token z SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Filtruj zadania według dnia
  static List<Map<String, dynamic>> getTasksForDay(
      List<Map<String, dynamic>> tasks, DateTime day) {
    return tasks.where((task) {
      final start = task['startTime'] as DateTime;
      final end = task['endTime'] as DateTime;

      return day.isAfter(start.subtract(const Duration(days: 1))) &&
          day.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Pobierz zadania dla zalogowanego użytkownika
  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final token = await _getToken();

      if (userId == null || token == null) {
        throw Exception('User ID or token not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse(AppConfig.getUserJobEndpoint(userId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map<Map<String, dynamic>>((task) {
          return {
            'id': task['id'],
            'name': task['name'],
            'message': task['message'],
            'startTime': DateTime.parse(task['startTime']),
            'endTime': DateTime.parse(task['endTime']),
            'jobId': task['id'], // Reflects the correct jobId
          };
        }).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Pobierz aktualizacje zadania
  static Future<List<Map<String, dynamic>>> fetchJobActualizations(int jobId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token not found in SharedPreferences');

      final response = await http.get(
        Uri.parse(AppConfig.getJobActualizationEndpoint(jobId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map<Map<String, dynamic>>((actualization) {
          return {
            'id': actualization['id'],
            'message': actualization['message'],
            'isDone': actualization['isDone'],
            'jobImageUrl': List<String>.from(actualization['jobImageUrl'] ?? []),
            'jobId': actualization['jobId'],
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch job actualizations: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Utwórz nową aktualizację zadania
  static Future<int> createTaskActualization(int jobId, String message) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token not found in SharedPreferences');

      final url = Uri.parse(AppConfig.postJobActualizationEndpoint());
      final body = jsonEncode({
        "id": 0,
        "message": message,
        "isDone": false,
        "jobImageUrl": [],
        "jobId": jobId,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['id'];
      } else {
        throw Exception('Failed to create task actualization.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Wyślij obrazy do aktualizacji
  static Future<void> uploadImages(int jobActualizationId, List<File> images) async {
    for (File image in images) {
      await uploadImage(jobActualizationId, image);
    }
  }

  /// Wyślij pojedynczy obraz
  static Future<String> uploadImage(int jobActualizationId, File image) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token not found in SharedPreferences');

      final url = Uri.parse(AppConfig.postAddImageEndpoint(jobActualizationId));
      var request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return 'images/job/${image.path.split('/').last}';
      } else {
        throw Exception('Failed to upload image.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Pobierz zadania dla adresu
  static Future<List<Map<String, dynamic>>> fetchTasksByAddress(
      int userId, int addressId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token not found in SharedPreferences');

      final endpoint = AppConfig.getUserJobActualizationByAddress(userId, addressId);
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map<Map<String, dynamic>>((task) {
          final startTime = DateTime.parse(task['startTime'] ?? '');
          final endTime = DateTime.parse(task['endTime'] ?? '');
          return {
            'id': task['id'],
            'addressId': task['addressId'],
            'name': task['name'],
            'message': task['message'],
            'startTime': startTime,
            'endTime': endTime,
            'allDay': task['allDay'] ?? false,
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
