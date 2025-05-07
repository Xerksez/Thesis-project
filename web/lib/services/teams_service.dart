import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:web_app/config/config.dart';
import 'package:universal_html/html.dart' as html;

class TeamsService {

 String _getAuthToken() {
    final cookies = html.document.cookie?.split('; ') ?? [];
    final tokenCookie = cookies.firstWhere(
      (cookie) => cookie.startsWith('userToken='),
      orElse: () => '',
    );
    return tokenCookie.split('=').last;
  }
  
Future<void> updateTeam(int teamId, String name, int addressId) async {
  final token = _getAuthToken();
  final client = HttpClient();
  try {
    final teamUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId';
    print('Updating team with URL: $teamUrl');
    print('Payload: ${jsonEncode({
      'name': name,
      'addressId': addressId,
    })}');

    final request = await client.putUrl(Uri.parse(teamUrl));
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json'); // Ensure Content-Type is set
    request.add(utf8.encode(jsonEncode({
      'name': name,
      'addressId': addressId,
    })));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Team updated successfully.');
    } else {
      print('Failed to update team: ${response.statusCode}, Response: $responseBody');
      throw Exception('Failed to update team: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating team: $e');
    rethrow;
  } finally {
    client.close();
  }
}


Future<void> deleteUserFromTeam(int teamId, int userId) async {
  final token = _getAuthToken();
  final client = HttpClient();
  final deleteUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId/users/$userId';
  print('Deleting user $userId from team $teamId with URL: $deleteUrl');

  try {
    
    final request = await client.deleteUrl(Uri.parse(deleteUrl));
    request.headers.set('Authorization', 'Bearer $token');

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('User $userId successfully deleted from team $teamId.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to delete user: ${response.statusCode}, Response: $responseBody');
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting user $userId from team $teamId: $e');
    rethrow;
  } finally {
    client.close();
  }
}


  /// Update a user's role using a PATCH request
  Future<void> updateUserRole(int userId, String roleName, int powerLevel) async {
  final client = HttpClient();
  try {
    final token = _getAuthToken();
    final createRoleEndpoint = AppConfig.createRoleEndpoint();
    final assignRoleEndpoint = (int roleId) => AppConfig.assignUserToRoleEndpoint(roleId, userId);

    print('Creating role for userId: $userId with roleName: $roleName, powerLevel: $powerLevel');

    // Step 1: Create the role
    final roleId = await _createRole(roleName, powerLevel, createRoleEndpoint, token, client);
    print('Created role "$roleName" with ID: $roleId.');

    // Step 2: Assign the created role to the user
    await _assignRoleToUser(roleId, userId, assignRoleEndpoint, token, client);
    print('Assigned role "$roleName" (ID: $roleId) to userId: $userId.');

  } catch (e) {
    print('Error updating user role: $e');
    rethrow;
  } finally {
    client.close();
  }
}

// Helper to create a role
Future<int> _createRole(
  String roleName,
  int powerLevel,
  String endpoint,
  String token,
  HttpClient client,
) async {
  final request = await client.postUrl(Uri.parse(endpoint));
  request.headers.set('Authorization', 'Bearer $token');
  request.headers.set('Content-Type', 'application/json');

  final createBody = {
    "id": 0, // New role
    "name": roleName,
    "powerLevel": powerLevel
  };

  request.add(utf8.encode(jsonEncode(createBody)));

  final response = await request.close();
  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);
    return data['id']; // Return the roleId from response
  } else {
    final responseBody = await response.transform(utf8.decoder).join();
    throw Exception('Failed to create role: ${response.statusCode}, Response: $responseBody');
  }
}

// Helper to assign role to a user
Future<void> _assignRoleToUser(
  int roleId,
  int userId,
  String Function(int) assignRoleEndpoint,
  String token,
  HttpClient client,
) async {
  final assignEndpoint = assignRoleEndpoint(roleId);
  final request = await client.postUrl(Uri.parse(assignEndpoint));
  request.headers.set('Authorization', 'Bearer $token');
  request.headers.set('Content-Type', 'application/json');

  final response = await request.close();
  if (response.statusCode == 200 || response.statusCode == 204) {
    print('Role ID $roleId assigned to user ID $userId successfully.');
  } else {
    final responseBody = await response.transform(utf8.decoder).join();
    throw Exception('Failed to assign role to user: ${response.statusCode}, Response: $responseBody');
  }
}

Future<void> updateAddress(int addressId, Map<String, String> addressData) async {
  final client = HttpClient();
  try {
    final addressUrl = '${AppConfig.getBaseUrl()}/api/Address/$addressId';
    final request = await client.putUrl(Uri.parse(addressUrl));
    final token = _getAuthToken();
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(jsonEncode(addressData)));

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Address updated successfully.');
    } else if (response.statusCode == 403) {
      print('Error 403: Unauthorized access. Insufficient permissions to update address.');
      throw Exception('Unauthorized: You do not have the required permissions to update this address.');
    } else {
      throw Exception('Failed to update address: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating address: $e');
    rethrow;
  } finally {
    client.close();
  }
}

  
  Future<int> createAddress(Map<String, String> addressData) async {
  final client = HttpClient();
  try {
    final addressUrl = '${AppConfig.getBaseUrl()}/api/Address';
    final token = await _getAuthToken(); // Upewnij się, że funkcja zwraca wartość asynchronicznie
    print('[CreateAddress] Endpoint URL: $addressUrl');
    print('[CreateAddress] Address Data: $addressData');
    print('[CreateAddress] Authorization Token: Bearer $token');

    final request = await client.postUrl(Uri.parse(addressUrl));
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(jsonEncode(addressData)));
    print('[CreateAddress] Headers: ${request.headers}');
    
    final response = await request.close();
    print('[CreateAddress] Response Status Code: ${response.statusCode}');

    if (response.statusCode == 201) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('[CreateAddress] Response Body: $responseBody');
      
      final data = jsonDecode(responseBody);
      print('[CreateAddress] Parsed Response Data: $data');
      return data['id'];
    } else if (response.statusCode == 403) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('[CreateAddress] 403 Forbidden Response Body: $responseBody');
      throw Exception('You do not have the required permissions to create an address.'); // Wyjątek dla statusu 403
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('[CreateAddress] Error Response Body: $responseBody');
      throw Exception('Failed to create address: ${response.statusCode}');
    }
  } catch (e) {
    print('[CreateAddress] Error creating address: $e');
    rethrow;
  } finally {
    client.close();
  }
}

  Future<int> createTeam(String teamName, int addressId) async {
  final client = HttpClient();
  try {
    final teamUrl = '${AppConfig.getBaseUrl()}/api/Team';
    final token = await _getAuthToken(); // Upewnij się, że funkcja zwraca wartość asynchronicznie
    print('[CreateTeam] Endpoint URL: $teamUrl');
    print('[CreateTeam] Team Name: $teamName, Address ID: $addressId');
    print('[CreateTeam] Authorization Token: Bearer $token');

    final request = await client.postUrl(Uri.parse(teamUrl));
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(jsonEncode({
      'name': teamName,
      'addressId': addressId,
    })));

    print('[CreateTeam] Request Headers: ${request.headers}');
    final response = await request.close();
    print('[CreateTeam] Response Status Code: ${response.statusCode}');

    if (response.statusCode == 201) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('[CreateTeam] Response Body: $responseBody');

      final data = jsonDecode(responseBody);
      print('[CreateTeam] Parsed Response Data: $data');
      return data['id'];
    } else if (response.statusCode == 403) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('[CreateTeam] 403 Forbidden Response Body: $responseBody');
      throw Exception('You do not have the required permissions to create a team.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('[CreateTeam] Error Response Body: $responseBody');
      throw Exception('Failed to create team: ${response.statusCode}');
    }
  } catch (e) {
    print('[CreateTeam] Error creating team: $e');
    rethrow;
  } finally {
    client.close();
  }
}

  Future<void> addUserToTeam(int teamId, int userId) async {
  final client = HttpClient();
  try {
    final addUserUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId/users/$userId';
    print('Starting to add user $userId to team $teamId with URL: $addUserUrl');

    final request = await client.postUrl(Uri.parse(addUserUrl));
    final token = _getAuthToken();
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 204 || response.statusCode == 200 || response.statusCode == 201) {
      print('User $userId successfully added to team $teamId');
    } else if (response.statusCode == 403) {
      print('Error 403: Unauthorized access. Insufficient permissions to add user to team.');
      throw Exception('Unauthorized: You do not have the required permissions to add a user to this team.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      throw Exception('Failed to add user to team: ${response.statusCode}, Response: $responseBody');
    }
  } catch (e) {
    print('Error adding user $userId to team $teamId: $e');
    rethrow;
  } finally {
    client.close();
  }
}

 Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final client = HttpClient();
    try {
      final usersUrl = '${AppConfig.getBaseUrl()}/api/User';
      final request = await client.getUrl(Uri.parse(usersUrl));
      final token = _getAuthToken();
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

        return data.map<Map<String, dynamic>>((user) {
          return {
            'id': user['id'],
            'name': user['name'],
            'surname': user['surname'],
            'email': user['mail'],
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    } finally {
      client.close();
    }
  }


 Future<List<Map<String, dynamic>>> fetchTeamsWithMembers(int userId, int loggedInUserId) async {
    final client = HttpClient();
    try {
      final teamsUrl = AppConfig.getTeamsEndpoint(userId);
      final request = await client.getUrl(Uri.parse(teamsUrl));
      final token = _getAuthToken();
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

        final List<Map<String, dynamic>> teams = [];

        for (var team in data) {
          final addressId = team['addressId'];
          final address = await fetchAddress(addressId);

          final members = await fetchTeamMembers(team['id'], loggedInUserId);

          teams.add({
            'id': team['id'],
            'name': team['name'],
            'addressId': team['addressId'],
            'address': address,
            'members': members,
          });
        }

        return teams;
      } else {
        throw Exception('Failed to fetch teams: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching teams: $e');
      rethrow;
    } finally {
      client.close();
    }
  }


  Future<void> deleteTeam(int teamId) async {
  final client = HttpClient();
  try {
    final deleteUrl = '${AppConfig.getBaseUrl()}/api/Team/$teamId';
    final request = await client.deleteUrl(Uri.parse(deleteUrl));
    final token = _getAuthToken();
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Team $teamId deleted successfully.');
    } else if (response.statusCode == 403) {
      print('Error 403: Unauthorized access. Insufficient permissions to delete team.');
      throw Exception('Unauthorized: You do not have the required permissions to delete this team.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      throw Exception('Failed to delete team: ${response.statusCode}, Response: $responseBody');
    }
  } catch (e) {
    print('Error deleting team $teamId: $e');
    rethrow;
  } finally {
    client.close();
  }
}

  Future<Map<String, String>> fetchAddress(int addressId) async {
    final client = HttpClient();
    try {
      final addressUrl = AppConfig.getAddressEndpoint(addressId);
      final request = await client.getUrl(Uri.parse(addressUrl));
      final token = _getAuthToken();
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(responseBody);

        return {
          'city': data['city'],
          'country': data['country'],
          'street': data['street'],
          'houseNumber': data['houseNumber'],
          'localNumber': data['localNumber'],
          'postalCode': data['postalCode'],
          'description': data['description'],
        };
      } else {
        throw Exception('Failed to fetch address: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching address with addressId $addressId: $e');
      return {
        'city': 'Unknown',
        'country': 'Unknown',
        'street': '',
        'houseNumber': '',
        'localNumber': '',
        'postalCode': '',
      };
    } finally {
      client.close();
    }
  }


  Future<List<Map<String, String>>> fetchTeamMembers(int teamId, int loggedInUserId) async {
  final client = HttpClient();
  try {
    final membersUrl = AppConfig.getTeammatesEndpoint(teamId);
    print('Fetching team members from URL: $membersUrl');
    final request = await client.getUrl(Uri.parse(membersUrl));
    final token = _getAuthToken();
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Accept', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final List<dynamic> data = jsonDecode(responseBody);
      //print('Team members fetched successfully: $responseBody');

      // Process each member
      return data
          .where((member) => member['id'] != loggedInUserId) // Exclude the logged-in user
          .map<Map<String, String>>((member) {
        final roleName = member['roleName'] ?? 'No Role';
        return {
          'id': member['id']?.toString() ?? '0',
          'name': '${member['name']} ${member['surname']}',
          'email': member['mail'] ?? 'Unknown',
          'phone': member['telephoneNr'] ?? 'Unknown',
          'role': roleName,
          'roleId': member['roleId']?.toString() ?? '0',
          'powerLevel': member['powerLevel']?.toString() ?? '0',
          'imageUrl': member['userImageUrl'] ?? '',
        };
      }).toList();
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to fetch team members: ${response.statusCode}, Response: $responseBody');
      throw Exception('Failed to fetch team members: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching team members for team $teamId: $e');
    return [];
  } finally {
    client.close();
  }
}

 Future<Map<String, dynamic>> getUserData(int userId) async {
  final client = HttpClient();
  final url = '${AppConfig.getBaseUrl()}/api/User/$userId';
  print('Fetching user data from: $url');

  try {
    final request = await client.getUrl(Uri.parse(url));
    final token = _getAuthToken();
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Accept', 'application/json');
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('User data response: $responseBody');
      return jsonDecode(responseBody);
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to fetch user data: ${response.statusCode}');
      print('Response body: $responseBody');
      throw Exception('Failed to fetch user data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching user data: $e');
    rethrow;
  } finally {
    client.close();
  }
}

 Future<Map<String, dynamic>> getRoleDetails(int roleId) async {
  if (roleId == 0) {
    // Handle case where roleId is 0 (indicating no role)
    print('RoleId is 0, returning default role details.');
    return {
      'id': 0,
      'name': 'No Role',
      'description': 'User has no assigned role.',
      'powerLevel': 0,
    };
  }

  final client = HttpClient();
  final url = '${AppConfig.getBaseUrl()}/api/Roles/$roleId';
  print('Fetching role details from: $url');

  try {
    final request = await client.getUrl(Uri.parse(url));
    final token = _getAuthToken();
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Accept', 'application/json');
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Role details response: $responseBody');
      return jsonDecode(responseBody);
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to fetch role details: ${response.statusCode}');
      print('Response body: $responseBody');
      throw Exception('Failed to fetch role details: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching role details: $e');
    return {
      'id': roleId,
      'name': 'Unknown',
      'description': 'Failed to fetch role details.',
      'powerLevel': 0,
    };
  } finally {
    client.close();
  }
}

   Future<String> fetchRoleName(int roleId) async {
    if (roleId == 0) {
      return 'Brak rangi';
    }

    final client = HttpClient();
    try {
      final roleUrl = AppConfig.getRoleEndpoint(roleId);
      final request = await client.getUrl(Uri.parse(roleUrl));
      final token = _getAuthToken();
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(responseBody);

        return data['name']?.toString() ?? 'Brak rangi';
      } else {
        throw Exception('Failed to fetch role name: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching role name for roleId $roleId: $e');
      return 'Brak rangi';
    } finally {
      client.close();
    }
  }
 
Future<void> createRole(String roleName, int powerLevel) async {
  final client = HttpClient();
  try {
    final token = _getAuthToken();
    final createRoleEndpoint = AppConfig.createRoleEndpoint();

    print('Creating role with name: $roleName, powerLevel: $powerLevel');

    final request = await client.postUrl(Uri.parse(createRoleEndpoint));
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');

    final createBody = {
      "id": 0,
      "name": roleName,
      "powerLevel": powerLevel
    };

    request.add(utf8.encode(jsonEncode(createBody)));

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Role created successfully.');
    } else if (response.statusCode == 403) {
      print('Error 403: Unauthorized access. Insufficient permissions to create role.');
      throw Exception('Unauthorized: You do not have the required permissions to create roles.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      throw Exception('Failed to create role: ${response.statusCode}, Response: $responseBody');
    }
  } catch (e) {
    print('Error creating role: $e');
    rethrow;
  } finally {
    client.close();
  }
}

 Future<void> assignUserToRole(int roleId, int userId) async {
  final client = HttpClient();
  try {
    final token = _getAuthToken();
    final assignRoleEndpoint = AppConfig.assignUserToRoleEndpoint(roleId, userId);

    print('Assigning userId: $userId to roleId: $roleId');

    final request = await client.postUrl(Uri.parse(assignRoleEndpoint));
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('User assigned to role successfully.');
    } else if (response.statusCode == 403) {
      print('Error 403: Unauthorized access. Insufficient permissions to assign role.');
      throw Exception('Unauthorized: You do not have the required permissions to assign roles.');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      throw Exception('Failed to assign user to role: ${response.statusCode}, Response: $responseBody');
    }
  } catch (e) {
    print('Error assigning user to role: $e');
    rethrow;
  } finally {
    client.close();
  }
}

}