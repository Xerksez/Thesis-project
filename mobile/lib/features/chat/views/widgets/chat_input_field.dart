import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider( // Dodanie Divider na górze
          height: 1,
          color: Color.fromARGB(255, 255, 255, 255), // Subtelny kolor linii
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: AppStyles.transparentWhite, // Dodanie tła z AppStyles
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Write message...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.black54),
                onPressed: onSendPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
