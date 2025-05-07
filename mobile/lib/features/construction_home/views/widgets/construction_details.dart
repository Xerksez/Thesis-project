import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/state/app_state.dart' as appState;
import 'construction_chat_button.dart';

class ConstructionDetails extends StatefulWidget {
  const ConstructionDetails({super.key});

  @override
  _ConstructionDetailsState createState() => _ConstructionDetailsState();
}

class _ConstructionDetailsState extends State<ConstructionDetails> {
  String address = '';
  String description = '';
  int? teamId;
  int? conversationId;
  String conversationName = '';
  List<Map<String, dynamic>> participants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConstructionDetailsAndData();
  }

  // Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadConstructionDetailsAndData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressId = prefs.getInt('addressId');

      if (addressId == null) {
        throw Exception('Nie znaleziono addressId w SharedPreferences.');
      }

      await _loadAddressDetails(addressId);
      await _loadTeamId(addressId);
      if (teamId != null) {
        await _loadConversationDetails(teamId!);
      }
    } catch (e) {
      print('Błąd podczas ładowania danych: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveLastMessageTime(int conversationId) async {
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      print("[ConstructionDetails] Error: User not logged in.");
      return;
    }

    final url = AppConfig.exitChatEndpoint(conversationId, userId);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("[ConstructionDetails] Last message time saved");
      } else {
        print("[ConstructionDetails] Error saving last message time: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("[ConstructionDetails] Error during request: $e");
    }
  }

  Future<void> _loadAddressDetails(int addressId) async {
    final token = await _getToken();
    final url = AppConfig.getAddressInfoEndpoint(addressId);

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

        final street = data['street'] ?? '';
        final houseNumber = data['houseNumber'] ?? '';
        final localNumber = data['localNumber'] != null ? '/${data['localNumber']}' : '';
        final postalCode = data['postalCode'] ?? '';
        final city = data['city'] ?? '';
        final country = data['country'] ?? '';

        setState(() {
          address = '$street $houseNumber$localNumber, $postalCode $city, $country';
          description = data['description'] ?? 'No description';
        });
      } else {
        throw Exception('Nie udało się pobrać danych adresu.');
      }
    } catch (e) {
      print('Błąd pobierania szczegółów adresu: $e');
    }
  }

  Future<void> _loadTeamId(int addressId) async {
    final token = await _getToken();
    final url = AppConfig.getAllTeamsEndpoint();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> teams = json.decode(response.body);

        final matchingTeam = teams.firstWhere(
          (team) => team['addressId'] == addressId,
          orElse: () => null,
        );

        if (matchingTeam != null) {
          setState(() {
            teamId = matchingTeam['id'];
          });
        } else {
          throw Exception('Nie znaleziono zespołu dla podanego addressId.');
        }
      } else {
        throw Exception('Błąd pobierania zespołów.');
      }
    } catch (e) {
      print('Błąd pobierania teamId: $e');
    }
  }

  Future<void> _loadConversationDetails(int teamId) async {
    final token = await _getToken();
    final url = AppConfig.getConversationsEndpoint();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> conversations = json.decode(response.body);

        final matchingConversation = conversations.firstWhere(
          (conversation) => conversation['teamId'] == teamId,
          orElse: () => null,
        );

        if (matchingConversation != null) {
          setState(() {
            conversationId = matchingConversation['id'];
            conversationName = matchingConversation['name'];
            participants = List<Map<String, dynamic>>.from(matchingConversation['users']);
            isLoading = false;
          });
        } else {
          throw Exception('Nie znaleziono konwersacji dla podanego teamId.');
        }
      } else {
        throw Exception('Błąd pobierania konwersacji.');
      }
    } catch (e) {
      print('Błąd pobierania conversationId: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
Future<void> _updateLastChecked(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastChecked_$conversationId', DateTime.now().toIso8601String());

    print("[ConstructionDetails] Last checked updated for conversation $conversationId");
  }

   Future<void> _navigateToConversation() async {
    if (conversationId != null) {
      // Aktualizacja stanu aplikacji
      appState.currentPage = 'chats';
      appState.isConstructionContext = false;

      // Zapisanie czasu ostatniej wiadomości i aktualizacja ostatniego wejścia
      await _saveLastMessageTime(conversationId!);
      await _updateLastChecked(conversationId!);

      // Nawigacja do ekranu czatu
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': conversationId,
          'conversationName': conversationName,
          'participants': participants,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie znaleziono konwersacji'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppStyles.transparentWhite,
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Construction Ditails:',
                  style: AppStyles.headerStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Address: $address',
                  style: AppStyles.textStyle.copyWith(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: $description',
                  style: AppStyles.textStyle.copyWith(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: ConstructionChatButton(
                   onPressed: _navigateToConversation,
                  ),
                ),
              ],
            ),
    );
  }
}
