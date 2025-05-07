import 'dart:convert';
import 'dart:html'; // For HttpRequest and localStorage
import 'package:web_app/config/config.dart';


class TaskService {

  static String _getAuthToken() {
    final cookies = document.cookie?.split('; ') ?? [];
    final tokenCookie = cookies.firstWhere(
      (cookie) => cookie.startsWith('userToken='),
      orElse: () => '',
    );
    return tokenCookie.split('=').last;
  }

static Future<List<Map<String, dynamic>>> fetchTasksByAddress(int addressId) async {
    final token = _getAuthToken();
    final url = AppConfig.getJobsByAddressEndpoint(addressId);
    print('[TaskService] Fetching tasks for address ID: $url');

    try {
      final response = await HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.status == 200) {
        final List<dynamic> data = json.decode(response.responseText!);
        print('[TaskService] Tasks fetched successfully: ${data.length}');
        return data.map<Map<String, dynamic>>((task) {
          return {
            'id': task['id'],
            'name': task['name'],
            'message': task['message'],
            'startTime': DateTime.parse(task['startTime']),
            'endTime': DateTime.parse(task['endTime']),
            'allDay': task['allDay'],
            'addressId': task['addressId'],
          };
        }).toList();
      } else if (response.status == 404) {
        print('[TaskService] 404 Not Found for address ID: $addressId. Returning empty list.');
        return [];
      } else {
        throw Exception('Failed to fetch tasks for address ID: $addressId. Status: ${response.status}');
      }
    } catch (e) {
      print('[TaskService] Error fetching tasks: $e');
      return [];
    }
  }


static Future<int> addJob({
  required String name,
  required String message,
  required DateTime startTime,
  required DateTime endTime,
  required bool allDay,
  required int addressId,
}) async {
  final token = _getAuthToken();
  final url = AppConfig.postJobEndpoint();
  print('[TaskService] Adding new job at $url');

  // Convert DateTime to UTC
  final body = jsonEncode({
    'id': 0,
    'name': name,
    'message': message,
    'startTime': startTime.toUtc().toIso8601String(), // Ensure UTC
    'endTime': endTime.toUtc().toIso8601String(), // Ensure UTC
    'allDay': allDay,
    'addressId': addressId,
  });

  print('[TaskService] Request Body: $body');

  try {
    final response = await HttpRequest.request(
      url,
      method: 'POST',
      requestHeaders: {
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer $token',
      },
      sendData: body,
    );

    if (response.status == 200 || response.status == 201) {
      final jsonResponse = json.decode(response.responseText!);
      print('[TaskService] Job added successfully. ID: ${jsonResponse['id']}');
      return jsonResponse['id'];
    } else {
      print('[TaskService] Failed to add job. Status: ${response.status}');
      throw Exception('Failed to add job');
    }
  } catch (e) {
    print('[TaskService] Error adding job: $e');
    rethrow;
  }
}



  // Fetch team members for a specific address
static Future<List<Map<String, dynamic>>> fetchTeamMembers(int addressId) async {
  final url = AppConfig.getTeamMembersEndpoint(addressId);
  print('[TaskService] Fetching team members for address ID: $addressId at $url');

  try {
    final token = _getAuthToken();
    final response = await HttpRequest.request(
      url,
      method: 'GET',
      requestHeaders: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );

    if (response.status == 200) {
      final List<dynamic> data = json.decode(response.responseText!);
      print('[TaskService] Team members fetched successfully: ${data.length}');

      return data.map<Map<String, dynamic>>((user) {
        return {
          'id': user['id'], // User ID
          'name': user['name'], // First name
          'surname': user['surname'], // Surname
          'email': user['mail'], // Email (if needed)
        };
      }).toList();
    } else {
      print('[TaskService] Failed to fetch team members. Status: ${response.status}');
      throw Exception('Failed to fetch team members for address ID: $addressId');
    }
  } catch (e) {
    print('[TaskService] Error fetching team members: $e');
    rethrow;
  }
}


 static Future<void> assignUserToTask(int taskId, int userId) async {
  final url = '${AppConfig.getBaseUrl()}/api/Job/assign?taskId=$taskId&userId=$userId';
  print('[TaskService] Assigning user ID $userId to task ID $taskId at $url');

  try {
    final token = _getAuthToken();
    final response = await HttpRequest.request(
      url,
      method: 'POST', // Ensure you are using the correct HTTP method
      requestHeaders: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );

    if (response.status == 200 || response.status == 204) {
      print('[TaskService] Successfully assigned user ID $userId to task ID $taskId');
    } else {
      print('[TaskService] Failed to assign user. Status: ${response.status}');
      throw Exception('Failed to assign user ID $userId to task ID $taskId');
    }
  } catch (e) {
    print('[TaskService] Error assigning user to task: ${e.toString()}');
    rethrow; // Re-throw the error after logging it
  }
}


  // Toggle job actualization status
static Future<void> toggleJobActualizationStatus(int id) async {
  final url = AppConfig.toggleJobActualizationStatusEndpoint(id);
  print('[TaskService] Toggling status for job actualization ID: $id at $url');

  try {
    final token = _getAuthToken();
    final response = await HttpRequest.request(
      url,
      method: 'POST',
      requestHeaders: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );

    if (response.status == 204 || response.status == 200) {
      print('[TaskService] Successfully toggled status for job actualization ID: $id');
    } else {
      print('[TaskService] Failed to toggle status. Status: ${response.status}');
      throw Exception('Failed to toggle job actualization status');
    }
  } catch (e) {
    print('[TaskService] Error toggling status: $e');
    rethrow;
  }
}


/// Fetch job actualizations
static Future<List<Map<String, dynamic>>> fetchJobActualizations(int jobId) async {
  final url = AppConfig.getJobActualizationEndpoint(jobId);
  print('[TaskService] Fetching job actualizations for Job ID: $jobId at $url');

  try {
    final token = _getAuthToken();
    final response = await HttpRequest.request(
      url,
      method: 'GET',
      requestHeaders: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );

    if (response.status == 200) {
      final List<dynamic> data = json.decode(response.responseText!);
      print('[TaskService] Job actualizations fetched successfully: ${data.length}');

      final List<Future<Map<String, dynamic>>> actualizationFutures = data.map((actualization) async {
        final int actualizationId = actualization['id'];
        List<String> images = [];

        try {
          images = await fetchJobActualizationImages(actualizationId);
        } catch (e) {
          print('[TaskService] Error fetching images for Actualization ID $actualizationId: $e');
        }

        print('[TaskService] Actualization ID: $actualizationId, Images: $images');

        return {
          'id': actualizationId,
          'message': actualization['message'],
          'isDone': actualization['isDone'],
          'jobImageUrl': images,
        };
      }).toList();

      return await Future.wait(actualizationFutures);
    } else if (response.status == 404) {
      // Return an empty list for 404
      print('[TaskService] 404 Not Found for job ID: $jobId. Returning empty list of actualizations.');
      return [];
    } else {
      print('[TaskService] Failed to fetch job actualizations. Status: ${response.status}');
      throw Exception('Failed to fetch job actualizations for Job ID: $jobId. Status: ${response.status}');
    }
  } catch (e) {
    print('[TaskService] Error fetching job actualizations for Job ID $jobId: $e');
    return []; // Return empty list on error
  }
}

  static Future<void> editTask({
  required int jobId,
  required List<Map<String, dynamic>> patchOperations,
}) async {
  final url = AppConfig.editTaskEndpoint(jobId);
  print('[TaskService] Editing task with ID: $jobId at $url');
  final token = _getAuthToken();

  try {
    print('[TaskService] Patch Operations: ${jsonEncode(patchOperations)}');

    final response = await HttpRequest.request(
      url,
      method: 'PATCH',
      requestHeaders: {
        'Content-Type': 'application/json-patch+json',
        'Authorization': 'Bearer $token',
      },
      sendData: jsonEncode(patchOperations),
    );

    if (response.status! >= 200 && response.status! < 300) {
      print('[TaskService] Successfully edited task with ID: $jobId');
    } else {
      final errorDetails = response.responseText ?? 'No additional details';
      print('[TaskService] Failed to edit task. Status: ${response.status}, Details: $errorDetails');
      throw Exception('Failed to edit task with ID: $jobId. Status: ${response.status}');
    }
  } catch (e) {
    print('[TaskService] Error editing task with ID: $jobId: $e');
    rethrow;
  }
}






  static Future<List<String>> fetchJobActualizationImages(int jobActualizationId) async {
  final url = AppConfig.getImagesEndpoint(jobActualizationId);
  print('[TaskService] Fetching images for Job Actualization ID: $jobActualizationId at $url');

  try {
    final token = _getAuthToken();
    final response = await HttpRequest.request(
      url,
      method: 'GET',
      requestHeaders: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );

    if (response.status == 200) {
      final List<dynamic> data = json.decode(response.responseText!);
      print('[TaskService] Images fetched successfully: ${data.length}');

      final List<String> imageUrls = data.map<String>((image) {
        final imageUrl = image.startsWith('http') ? image : '${AppConfig.s3BaseUrl}/$image';
        print('[TaskService] Image URL: $imageUrl'); // Log each image URL
        return imageUrl;
      }).toList();

      return imageUrls;
    } else {
      print('[TaskService] Failed to fetch images. Status: ${response.status}');
      throw Exception('Failed to fetch images for Job Actualization ID: $jobActualizationId');
    }
  } catch (e) {
    print('[TaskService] Error fetching images for Actualization ID: $jobActualizationId, Error: $e');
    rethrow;
  }
}


static String getTeamsEndpoint(int userId) =>
      "${AppConfig.getBaseUrl()}/api/User/$userId/teams";

  // Fetch addresses where the user is present
  static Future<List<Map<String, dynamic>>> getAddressesForUser(int userId) async {
    final url = getTeamsEndpoint(userId);
    print('[TaskService] Fetching addresses for user ID: $userId at $url');

    try {
      final token = _getAuthToken();
      final response = await HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
      );

      if (response.status == 200) {
        final List<dynamic> data = json.decode(response.responseText!);
        print('[TaskService] Addresses fetched successfully: ${data.length}');

        return data.map<Map<String, dynamic>>((team) {
          return {
            'id': team['id'], // Team/Address ID
            'name': team['name'], // Team/Address Name
            'addressId': team['addressId'], // Actual Address ID
          };
        }).toList();
      } else {
        print('[TaskService] Failed to fetch addresses. Status: ${response.status}');
        throw Exception('Failed to fetch addresses for user ID: $userId');
      }
    } catch (e) {
      print('[TaskService] Error fetching addresses: $e');
      rethrow;
    }
  }
static Future<void> deleteJob(int jobId) async {
  final url = AppConfig.deleteJobEndpoint(jobId);
  print('[TaskService] Deleting job at: $url');
  final token = _getAuthToken();
  final response = await HttpRequest.request(
    url,
    method: 'DELETE',
    requestHeaders: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    },
  );

  if (response.status != 204) {
    throw Exception('Failed to delete job. Status code: ${response.status}');
  }
}

  static Future<List<Map<String, dynamic>>> fetchAssignedUsers(int jobId, {int retryCount = 3}) async {
  final url = AppConfig.getAssignedUsersEndpoint(jobId);
  print('[TaskService] Fetching assigned users for Job ID: $jobId at $url');

  for (int attempt = 1; attempt <= retryCount; attempt++) {
    try {
      final token = _getAuthToken();
      final response = await HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
      );

      if (response.status == 200) {
        final dynamic data = json.decode(response.responseText!);

        if (data is String && data.contains('No users found')) {
          // Handle specific backend message
          print('[TaskService] No assigned users found for Job ID: $jobId');
          return [];
        }

        if (data is List) {
          print('[TaskService] Assigned users fetched successfully: ${data.length}');
          return data.map<Map<String, dynamic>>((user) {
            return {
              'id': user['id'],
              'name': user['name'],
              'surname': user['surname'],
              'email': user['email'],
            };
          }).toList();
        }

        throw Exception('Unexpected response format for assigned users.');
      } else if (response.status == 204) {
        // Handle no content response
        print('[TaskService] No assigned users found for Job ID: $jobId');
        return [];
      } else {
        // Handle other status codes
        print('[TaskService] Failed to fetch assigned users. Status: ${response.status}');
        throw Exception('Failed to fetch assigned users. Status code: ${response.status}');
        // ignore: dead_code
        return [];
      }
    } catch (e) {
      if (attempt == retryCount || e is! ProgressEvent) {
        print('[TaskService] Error fetching assigned users: $e');
        throw Exception('Network error occurred while fetching assigned users. Please check your connection.');
        // ignore: dead_code
        return [];
      }
      print('[TaskService] Retry $attempt/$retryCount due to network error.');
      return [];
    }
  }

  // Fallback in case of unexpected issues
  return [];
}


  // Delete User from a Job
  static Future<void> deleteUserFromJob(int jobId, int userId) async {
    final url = AppConfig.deleteUserFromJobEndpoint(jobId, userId);
    print('[TaskService] Deleting user ID: $userId from Job ID: $jobId at $url');

    try {
      final token = _getAuthToken();
      final response = await HttpRequest.request(
        url,
        method: 'DELETE',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
      );

      if (response.status == 200 || response.status == 204) {
        print('[TaskService] Successfully deleted user ID: $userId from Job ID: $jobId');
      } else {
        print('[TaskService] Failed to delete user. Status: ${response.status}');
        throw Exception('Failed to delete user ID: $userId from Job ID: $jobId');
      }
    } catch (e) {
      print('[TaskService] Error deleting user from Job ID: $jobId: $e');
      rethrow;
    }
  }

static Future<List<Map<String, dynamic>>> fetchTeamMembersWithPowerLevel(int addressId) async {
  final url = AppConfig.getTeamatesPowerLevelByAddressID(addressId);
  print('[TaskService] Fetching teammates with power levels for Address ID: $addressId at $url');

  try {
    final token = _getAuthToken();
    final response = await HttpRequest.request(
      url,
      method: 'GET',
      requestHeaders: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
    );

    if (response.status == 200) {
      final List<dynamic> data = json.decode(response.responseText!);
      print('[TaskService] Raw API Response: ${response.responseText}');
      print('[TaskService] Team members with power levels fetched successfully: ${data.length}');

      return data.map<Map<String, dynamic>>((user) {
        if (user['powerLevel'] == null) {
          print('[TaskService] Missing powerLevel for user: ${user['id']}');
        }
        return {
          'id': user['id'], // User ID
          'name': user['name'], // First name
          'surname': user['surname'], // Surname
          'email': user['email'], // Email
          'powerLevel': user['powerLevel'] ?? 0, // Default to 0 if null
        };
      }).toList();
    } else {
      print('[TaskService] Failed to fetch teammates with power levels. Status: ${response.status}');
      throw Exception('Failed to fetch teammates with power levels for Address ID: $addressId');
    }
  } catch (e) {
    print('[TaskService] Error fetching teammates with power levels: $e');
    rethrow;
  }
}


}
