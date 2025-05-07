import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecipientSelectionScreen extends StatefulWidget {
  final List<String> initialSelectedRecipients;
  final int userId;

  const RecipientSelectionScreen(
    this.initialSelectedRecipients, {
    required this.userId,
    super.key,
  });

  @override
  _RecipientSelectionScreenState createState() =>
      _RecipientSelectionScreenState();
}

class _RecipientSelectionScreenState extends State<RecipientSelectionScreen> {
  List<String> allRecipients = [];
  List<String> displayedRecipients = [];
  List<String> selectedRecipients = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipients();
    selectedRecipients = widget.initialSelectedRecipients;
  }

  /// Get the token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Load recipients with `Authorization: Bearer <token>` header
  Future<void> _loadRecipients() async {
    List<String> recipients = [];

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token is missing. Please log in again.');
      }

      // Fetch user teams
      final teamsResponse = await http.get(
        Uri.parse(AppConfig.getTeamsEndpoint(widget.userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (teamsResponse.statusCode == 200) {
        List<dynamic> teams = json.decode(teamsResponse.body);

        for (var team in teams) {
          final teamId = team['id'];

          // Fetch team members
          final membersResponse = await http.get(
            Uri.parse(AppConfig.getTeammatesEndpoint(teamId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (membersResponse.statusCode == 200) {
            List<dynamic> teammates = json.decode(membersResponse.body);

            for (var mate in teammates) {
              if (mate['id'] != widget.userId) {
                recipients.add('${mate['name']} ${mate['surname']}');
              }
            }
          } else {
            print('Error fetching teammates for teamId $teamId: ${membersResponse.statusCode}');
          }
        }
      } else {
        print('Error fetching teams: ${teamsResponse.statusCode}');
        throw Exception('Failed to fetch teams: ${teamsResponse.body}');
      }
    } catch (e) {
      print('Error during recipient loading: $e');
    }

    setState(() {
      allRecipients = recipients.toSet().toList(); // Unique names
      allRecipients.sort();
      displayedRecipients = List.from(allRecipients);
    });
  }

  void _filterChats(String query) {
    final results = allRecipients
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      displayedRecipients = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Container(color: AppStyles.transparentWhite),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context, selectedRecipients);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterChats,
                  decoration: InputDecoration(
                    hintText: 'Szukaj po imieniu i nazwisku...',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: displayedRecipients.length,
                    itemBuilder: (context, index) {
                      String recipient = displayedRecipients[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            recipient,
                            style: const TextStyle(color: Colors.black),
                          ),
                          value: selectedRecipients.contains(recipient),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedRecipients.add(recipient);
                              } else {
                                selectedRecipients.remove(recipient);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
