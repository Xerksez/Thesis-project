import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String sender;
  final String time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.sender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSentByMe
              ? Colors.white.withOpacity(0.8)  // Tło dla wiadomości wysłanych przez użytkownika
              : const Color.fromARGB(248, 128, 127, 127).withOpacity(0.8),  // Tło dla wiadomości od innych użytkowników
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isSentByMe ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isSentByMe ? const Radius.circular(0) : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicWidth(
          stepWidth: 50,  // Minimalna szerokość
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,  // Dopasowanie do zawartości
              children: [
                if (!isSentByMe)
                  Text(
                    sender,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),  // Czarny tekst
                  softWrap: true,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
