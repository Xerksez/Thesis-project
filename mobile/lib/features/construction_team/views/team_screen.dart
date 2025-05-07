import 'package:flutter/material.dart';
import 'package:mobile/features/construction_team/services/team_service.dart';
import 'package:mobile/features/new_message/services/new_message_service.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/team_member_card.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/shared/state/app_state.dart' as appState;

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TeamService teamService = TeamService();
  List<Map<String, dynamic>> teamMembers = [];
  List<Map<String, dynamic>> filteredTeamMembers = [];
  bool isLoading = true;
  int? currentUserId;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appState.currentPage = 'construction_team';
    _loadTeamMembers();

    // Listener do pola wyszukiwania
    searchController.addListener(_filterTeamMembers);
  }

  @override
  void dispose() {
    searchController.dispose(); // Zwolnienie zasobów kontrolera
    super.dispose();
  }

Future<void> _loadTeamMembers() async {
  try {
    // Fetch team members from the service
    final members = await teamService.getTeamMembers();
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('userId');

    for (var member in members) {
      // Safely handle roles
      if (member['roleId'] != null) {
        // Use the roleName directly from the member
        member['role'] = member['roleName'] ?? 'No Role'; // Default to 'No Role'
      } else {
        member['role'] = 'No Role';
      }
    }

    // Update state
    setState(() {
      teamMembers = members;
      filteredTeamMembers = members; // Initially display all members
      isLoading = false;
    });
  } catch (e) {
    print('Error loading team members: $e');
    setState(() {
      isLoading = false;
    });
  }
}

  void _filterTeamMembers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredTeamMembers = teamMembers.where((member) {
        final fullName = member['name']?.toLowerCase() ?? '';
        return fullName.contains(query);
      }).toList();
    });
  }

  Future<void> _saveLastMessageTime(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    if (userId == 0) {
      print("[TeamScreen] Error: User not logged in.");
      return;
    }
    final url = AppConfig.exitChatEndpoint(conversationId, userId);

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        print("[TeamScreen] Last message time saved.");
      } else {
        print("[TeamScreen] Error saving last message time: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("[TeamScreen] Error during request: $e");
    }
  }

  Future<void> _updateLastChecked(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastChecked_$conversationId', DateTime.now().toIso8601String());
    print("[TeamScreen] Last checked updated for conversation $conversationId");
  }

  void _navigateToChatWithMember(int memberId, String memberName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('Nie udało się pobrać ID użytkownika');
      }

      final newMessageService = NewMessageService();
      final conversationId = await newMessageService.findOrCreateConversation(userId, [memberId]);

      // Zapisanie czasu ostatniej wiadomości i aktualizacja ostatniego wejścia
      await _saveLastMessageTime(conversationId);
      await _updateLastChecked(conversationId);

      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': conversationId,
          'conversationName': memberName,
          'participants': [
            {'id': memberId, 'name': memberName},
          ],
        },
      );
    } catch (e) {
      print('Błąd nawigacji do czatu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd podczas otwierania czatu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTeamMemberDialog(Map<String, dynamic> member) {
    final teamService = TeamService();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: FutureBuilder<String>(
            future: teamService.fetchUserImage(member['id']),
            builder: (context, snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(),
                          )
                        : (snapshot.hasError || snapshot.data?.isEmpty == true)
                            ? const Icon(Icons.person, size: 50)
                            : Image.network(
                                snapshot.data!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    member['name'] ?? 'Name and surname unknown',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Role: ${member['role'] ?? 'no role'}'),
              Text('Email: ${member['email'] ?? 'no email'}'),
              Text('Phone: ${member['phone'] ?? 'no phone number'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Column(
            children: [
              Container(
                width: double.infinity,
                color: AppStyles.transparentWhite,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Construction team',
                      style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Find by name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: AppStyles.transparentWhite,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredTeamMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredTeamMembers[index];
                            final isCurrentUser = member['id'] == currentUserId;
                            return TeamMemberCard(
                              name: isCurrentUser ? '${member['name']} (me)' : member['name'],
                              role: member['role'],
                              phone: member['phone'],
                              onInfoPressed: isCurrentUser
                                  ? null
                                  : () {
                                      _showTeamMemberDialog(member);
                                    },
                              onChatPressed: isCurrentUser
                                  ? null
                                  : () {
                                      _navigateToChatWithMember(member['id'], member['name']);
                                    },
                            );
                          },
                        ),
                ),
              ),
              BottomNavigation(onTap: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}
