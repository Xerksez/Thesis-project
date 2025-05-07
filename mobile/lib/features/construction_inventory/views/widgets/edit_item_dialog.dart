import 'package:flutter/material.dart';

class EditItemDialog extends StatefulWidget {
  final double remaining;
  final double purchased;
  final ValueChanged<double> onSave;

  const EditItemDialog({
    super.key,
    required this.remaining,
    required this.purchased,
    required this.onSave,
  });

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _remainingController;

  @override
  void initState() {
    super.initState();
    _remainingController = TextEditingController(text: widget.remaining.toString());
  }

  @override
  void dispose() {
    _remainingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.8), // Dark background for the dialog
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
      title: const Text(
        'Edit Remaining',
        style: TextStyle(color: Colors.white), // White text for the title
      ),
      content: TextField(
        controller: _remainingController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white), // White text input
        decoration: InputDecoration(
          hintText: 'Remaining',
          hintStyle: const TextStyle(color: Colors.white70), // Hint style
          filled: true,
          fillColor: Colors.grey.withOpacity(0.2), // Slightly darkened input background
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white), // White border when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue), // Blue border when focused
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Close dialog on cancel
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white), // White text for cancel button
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final newRemaining = double.tryParse(_remainingController.text);
            if (newRemaining == null || newRemaining > widget.purchased) {
              // Show error if input is invalid
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Remaining cannot exceed purchased quantity!')),
              );
            } else {
              widget.onSave(newRemaining); // Call onSave callback with new value
              Navigator.pop(context); // Close dialog
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Blue background for the "Save" button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners for the button
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white), // White text for save button
          ),
        ),
      ],
    );
  }
}