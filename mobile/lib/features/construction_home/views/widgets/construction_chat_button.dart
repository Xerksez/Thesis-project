import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';


class ConstructionChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ConstructionChatButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.chat, color: Colors.white),
      label: const Text('Go to chat', style: TextStyle(color: Colors.white)),
      style: AppStyles.buttonStyle().copyWith(
        backgroundColor: WidgetStateProperty.all(Colors.grey[700]!.withOpacity(0.3)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 60.0),
        ),
      ),
    );
  }
}
