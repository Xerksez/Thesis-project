import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_app/config/config.dart';
import 'package:web_app/services/teams_service.dart';
import 'package:web_app/themes/styles.dart';

class EditTeamDialog extends StatelessWidget {
  final int teamId; // Added teamId
  final String teamName;
  final Map<String, String> addressData;
  final Function(String, Map<String, String>) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onTeamDeleted;

  EditTeamDialog({
    required this.teamId, // Required parameter
    required this.teamName,
    required this.addressData,
    required this.onSubmit,
    required this.onCancel,
    required this.onTeamDeleted,
  });

  void _showDeleteConfirmation(BuildContext context) async {
    final TeamsService teamsService = TeamsService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team', style: TextStyle(color: Colors.black)),
        content: const Text('Are you sure you want to delete this team?', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await teamsService.deleteTeam(teamId);
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close edit dialog

                // Trigger callback after successful team deletion
                onTeamDeleted();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Team was successfully deleted.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete team: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _validateFields(BuildContext context, List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields must be filled!'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: teamName);
    final TextEditingController cityController = TextEditingController(text: addressData['city']);
    final TextEditingController countryController = TextEditingController(text: addressData['country']);
    final TextEditingController streetController = TextEditingController(text: addressData['street']);
    final TextEditingController houseNumberController = TextEditingController(text: addressData['houseNumber']);
    final TextEditingController localNumberController = TextEditingController(text: addressData['localNumber']);
    final TextEditingController postalCodeController = TextEditingController(text: addressData['postalCode']);
    final TextEditingController descriptionController = TextEditingController(text: addressData['description']);

    final controllers = [
      nameController,
      cityController,
      countryController,
      streetController,
      houseNumberController,
      localNumberController,
      postalCodeController,
      descriptionController,
    ];

    return AlertDialog(
      backgroundColor: AppStyles.transparentWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Edit Team',
            style: AppStyles.headerStyle.copyWith(color: Colors.black), // Black title text
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Team Name',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: 'City',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
            const SizedBox(height: 10),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                hintText: 'Country',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
            const SizedBox(height: 10),
            TextField(
              controller: streetController,
              decoration: InputDecoration(
                hintText: 'Street',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
            const SizedBox(height: 10),
            TextField(
              controller: houseNumberController,
              decoration: InputDecoration(
                hintText: 'House Number',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
            const SizedBox(height: 10),
            TextField(
              controller: localNumberController,
              decoration: InputDecoration(
                hintText: 'Apartment Number',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
            const SizedBox(height: 10),
            TextField(
              controller: postalCodeController,
              decoration: InputDecoration(
                hintText: 'Postal Code',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder
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
              maxLines: 3,
              cursorColor: AppStyles.cursorColor,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(foregroundColor: Colors.black), // Black text color
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_validateFields(context, controllers)) {
              onSubmit(
                nameController.text,
                {
                  'city': cityController.text,
                  'country': countryController.text,
                  'street': streetController.text,
                  'houseNumber': houseNumberController.text,
                  'localNumber': localNumberController.text,
                  'postalCode': postalCodeController.text,
                  'description': descriptionController.text,
                },
              );
              Navigator.pop(context);
            }
          },
          style: AppStyles.buttonStyle(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
