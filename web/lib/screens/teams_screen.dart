import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web_app/themes/styles.dart';
import 'package:web_app/widgets/add_project_dialog.dart';
import 'package:web_app/services/teams_service.dart';
import 'package:web_app/widgets/add_user_dialog.dart';
import 'package:web_app/widgets/edit_team_dialog.dart';
import 'package:web_app/widgets/edit_user_dialog.dart';

class TeamsScreen extends StatefulWidget {
  final int loggedInUserId;

  TeamsScreen({required this.loggedInUserId});

  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TeamsService _teamsService = TeamsService();
  List<Map<String, dynamic>> teams = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchTeams() async {
    setState(() => _isLoading = true);
    try {
      final fetchedTeams = await _teamsService.fetchTeamsWithMembers(
        widget.loggedInUserId,
        widget.loggedInUserId,
      );
      if (mounted) {
        setState(() {
          teams = fetchedTeams;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
      print('Error fetching teams: $e');
    }
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(
        onCancel: () => Navigator.pop(context),
        onSuccess: (projectData) {
          print('Project added: $projectData');
          _showSuccessNotification(context, 'Project added successfully.');
          _fetchTeams();
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, int teamId, List<int> existingUserIds) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        teamId: teamId,
        existingUserIds: existingUserIds,
        onCancel: () => Navigator.pop(context),
        onSuccess: (List<int> userIds) async {
          try {
            for (final userId in userIds) {
              print('Adding user $userId to team $teamId');
              await _teamsService.addUserToTeam(teamId, userId);
            }
            _showSuccessNotification(context, 'Successfully added worker.');
            await _fetchTeams();
          } catch (e) {
            print('Error adding users: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add worker. Insufficient permissions to add user to team. '),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, Map<String, dynamic> team) {
    showDialog(
      context: context,
      builder: (context) => EditTeamDialog(
        teamId: team['id'],
        teamName: team['name'],
        addressData: team['address'] as Map<String, String>,
        onSubmit: (updatedName, updatedAddress) async {
          try {
            await _teamsService.updateAddress(team['addressId'], updatedAddress);
            await _teamsService.updateTeam(team['id'], updatedName, team['addressId']);
            _showSuccessNotification(context, 'Team was updated successfully.');
            await _fetchTeams();
          } catch (e) {
            print('Error updating team or address: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update team. Insufficient permissions to add user to team.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onCancel: () => Navigator.pop(context),
        onTeamDeleted: _fetchTeams,
      ),
    );
  }

void _showEditUserDialog(BuildContext context, int userId, int teamId) {
  showDialog(
    context: context,
    builder: (context) => EditUserDialog(
      userId: userId,
      teamId: teamId,
      onCancel: () {
        Navigator.pop(context);
      },
      onSubmit: (newPowerLevel, newRoleName) async {
        try {
          // Aktualizacja roli użytkownika
          await _teamsService.updateUserRole(userId, newRoleName, newPowerLevel);
          print('Rola użytkownika zaktualizowana pomyślnie');

          // Odświeżenie widoku zespołów
          _fetchTeams();
        } catch (e) {
          print('Błąd podczas aktualizacji rangi użytkownika: $e');
        }
      },
      onDelete: () {
    _fetchTeams(); // Odświeżenie widoku po usunięciu użytkownika
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(144, 81, 85, 87),
        title: Row(
          children: [
            Text(
              'Teams and Projects',
              style: AppStyles.headerStyle.copyWith(color: Colors.black),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddProjectDialog(context),
              icon: const Icon(Icons.apartment, size: 24, color: Colors.white),
              label: Text(
                "Add Project",
                style: AppStyles.textStyle.copyWith(color: Colors.white),
              ),
              style: AppStyles.buttonStyle().copyWith(
                backgroundColor: MaterialStateProperty.all(AppStyles.primaryBlue),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ), 
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchTeams, // Trigger refresh function
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: AppStyles.backgroundDecoration,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isError
                ? const Center(
                    child: Text(
                      'Failed to load teams.',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final address = team['address'] as Map<String, String>;
                      final members = team['members'] as List<Map<String, String>>;

                      return Card(
                        color: AppStyles.transparentWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                team['name'],
                                style: AppStyles.headerStyle,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.black),
                                    onPressed: () => _showEditTeamDialog(context, team),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showAddUserDialog(
                                      context,
                                      team['id'],
                                      team['members']
                                              ?.map<int>((member) => int.parse(member['id']))
                                              ?.toList() ??
                                          [],
                                    ),
                                    icon: const Icon(Icons.add, color: AppStyles.primaryBlue),
                                    label: Text(
                                      "Add Worker",
                                      style: AppStyles.textStyle.copyWith(color: AppStyles.primaryBlue),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${address['street']} ${address['houseNumber']}, ${address['city']}, ${address['country']}, ${address['postalCode']}',
                                style: AppStyles.textStyle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Description: ${address['description']}',
                                style: AppStyles.textStyle.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                          children: members
                              .map(
                                (member) => ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        member['name']!,
                                        style: AppStyles.textStyle,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.black),
                                        onPressed: () => _showEditUserDialog(
                                          context,
                                          int.tryParse(member['id'] ?? '0') ?? 0,
                                          int.tryParse(team['id']?.toString() ?? '0') ?? 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    member['role']!,
                                    style: AppStyles.textStyle.copyWith(color: Colors.black54),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
