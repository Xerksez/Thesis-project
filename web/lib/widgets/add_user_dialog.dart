import 'package:flutter/material.dart';
import 'package:web_app/services/teams_service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web_app/themes/styles.dart';

class AddUserDialog extends StatefulWidget {
  final int teamId;
  final List<int> existingUserIds; // List of users in the team
  final VoidCallback onCancel;
  final Function(List<int>) onSuccess;

  AddUserDialog({
    required this.teamId,
    required this.existingUserIds, // Pass the list of users in the team
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TeamsService _teamsService = TeamsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> selectedUsers = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  int? _getLoggedInUserId() {
    final loggedInUserId = int.tryParse(
        (html.document.cookie?.split('; ') ?? [])
            .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
            .split('=')[1]);

    print('Logged in user ID: $loggedInUserId');
    return loggedInUserId;
  }

  Future<void> _fetchUsers() async {
    try {
      final fetchedUsers = await _teamsService.fetchAllUsers();

      // Filter out users who are already in the team or the logged-in user
      final availableUsers = fetchedUsers
          .where((user) =>
              !widget.existingUserIds.contains(user['id']) && user['id'] != _getLoggedInUserId())
          .toList();

      setState(() {
        users = availableUsers;
        filteredUsers = availableUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
      print('Error while fetching users: $e');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final fullName = '${user['name']} ${user['surname']}'.toLowerCase();
        final email = user['email'].toLowerCase();
        final id = user['id'].toString();

        return fullName.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase()) ||
            id == query;
      }).toList();
    });
  }

  void _toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: AlertDialog(
        backgroundColor: AppStyles.transparentWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          'Add Users to Team',
          style: AppStyles.headerStyle.copyWith(color: Colors.black), // Black title text
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isError
                  ? const Center(
                      child: Text(
                        'Failed to load users.',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search User',
                            hintStyle: const TextStyle(color: Colors.black), // Black placeholder
                            prefixIcon: const Icon(Icons.search, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          cursorColor: AppStyles.cursorColor,
                          onChanged: _filterUsers,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            interactive: true,
                            child: ListView(
                              controller: _scrollController,
                              children: [
                                ...selectedUsers.map(
                                  (user) => _buildUserTile(user, true),
                                ),
                                ...filteredUsers
                                    .where((user) => !selectedUsers.contains(user))
                                    .map((user) => _buildUserTile(user, false)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onCancel();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text color for Cancel button
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedUsers.isNotEmpty
                ? () {
                    final userIds = selectedUsers.map((user) => user['id'] as int).toList();
                    widget.onSuccess(userIds);
                    Navigator.pop(context);
                  }
                : null,
            style: AppStyles.buttonStyle(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, bool isSelected) {
    return Card(
      color: AppStyles.transparentWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          activeColor: AppStyles.primaryBlue,
          onChanged: (_) {
            _toggleUserSelection(user);
          },
        ),
        title: Text(
          '${user['name']} ${user['surname']}',
          style: AppStyles.textStyle,
        ),
        subtitle: Text(
          user['email'],
          style: AppStyles.textStyle.copyWith(color: Colors.grey),
        ),
        onTap: () {
          _toggleUserSelection(user);
        },
      ),
    );
  }
}
