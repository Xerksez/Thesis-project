import 'package:flutter/material.dart';
import 'package:web_app/services/teams_service.dart';
import 'package:web_app/themes/styles.dart';

class EditUserDialog extends StatefulWidget {
  final int userId;
  final int teamId;
  final VoidCallback onCancel;
  final Function(int, String) onSubmit;
  final VoidCallback onDelete;

  EditUserDialog({
    required this.userId,
    required this.teamId,
    required this.onCancel,
    required this.onSubmit,
    required this.onDelete,
  });

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final TeamsService _teamsService = TeamsService();
  String roleName = '';
  int powerLevel = 0;
  bool isLoading = true;
  bool isError = false;

  final TextEditingController _roleNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserRoleData();
    _roleNameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRoleData() async {
    try {
      final userData = await _teamsService.getUserData(widget.userId);

      setState(() {
        roleName = userData['roleName'] ?? '';
        powerLevel = userData['powerLevel'] ?? 0;
        _roleNameController.text = roleName;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  bool get _isFormValid => _roleNameController.text.trim().isNotEmpty;

  void _validateForm() {
    setState(() {});
  }

  void _confirmDeleteUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Accept deletion',
          style: TextStyle(color: Colors.black), // Black text
        ),
        content: const Text(
          'Do you want to delete this worker from the team?',
          style: TextStyle(color: Colors.black), // Black text
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text color for Cancel
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text color for Delete
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser() async {
    try {
      await _teamsService.deleteUserFromTeam(widget.teamId, widget.userId);
      widget.onDelete();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete user.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isError) {
      return AlertDialog(
        backgroundColor: AppStyles.transparentWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          'Error',
          style: AppStyles.headerStyle.copyWith(color: Colors.black), // Black title text
        ),
        content: const Text(
          'Could not load data.',
          style: TextStyle(color: Colors.black), // Black content text
        ),
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text color for Close
            ),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      backgroundColor: AppStyles.transparentWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Edit user rank',
        style: AppStyles.headerStyle.copyWith(color: Colors.black), // Black title text
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _roleNameController,
              decoration: InputDecoration(
                hintText: 'Rank',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
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
            ),
            const SizedBox(height: 16),
            Text(
              'Access level:',
              style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            RadioListTile<int>(
              title: Text(
                'Only mobile app',
                style: AppStyles.textStyle.copyWith(color: Colors.black), // Black text
              ),
              value: 1,
              groupValue: powerLevel,
              activeColor: AppStyles.primaryBlue,
              onChanged: (value) {
                setState(() {
                  powerLevel = value!;
                });
              },
            ),
            RadioListTile<int>(
              title: Text(
                'Access to mobile app and web app without team access',
                style: AppStyles.textStyle.copyWith(color: Colors.black), // Black text
              ),
              value: 2,
              groupValue: powerLevel,
              activeColor: AppStyles.primaryBlue,
              onChanged: (value) {
                setState(() {
                  powerLevel = value!;
                });
              },
            ),
            if (powerLevel == 0)
              Text(
                'Must choose access level',
                style: AppStyles.textStyle.copyWith(color: Colors.red),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.black), // Black delete icon
          onPressed: _confirmDeleteUser,
        ),
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, // Black text color for Cancel
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isFormValid
              ? () async {
                  try {
                    await _teamsService.updateUserRole(
                      widget.userId,
                      _roleNameController.text.trim(),
                      powerLevel,
                    );
                    widget.onSubmit(powerLevel, _roleNameController.text.trim());
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update user role. Insufficient permissions to add user to team.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              : null,
          style: AppStyles.buttonStyle(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
