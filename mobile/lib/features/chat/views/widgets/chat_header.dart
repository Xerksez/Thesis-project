import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final String conversationName;
  final List<String> participants;
  final VoidCallback onBackPressed;

  const ChatHeader({
    super.key,
    required this.conversationName,
    required this.participants,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Sprawdzamy liczbę uczestników, jeśli 1 to wyświetlamy jego imię i nazwisko
      final displayName = participants.length == 1
        ? participants.first
        : (conversationName == null || conversationName.isEmpty
            ? 'Group chat'
            : conversationName!);
            
    return Column(
      children: [
        Container(
          color: Colors.white.withOpacity(0.7),
          padding: const EdgeInsets.only(left: 8, right: 8, top: 40, bottom: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: onBackPressed,
              ),
              Expanded(
                // Obszar na prawo od strzałki
                child: GestureDetector(
                  onLongPress: () {
                    _showParticipantsDialog(context);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (participants.length > 1)
                        Text(
                          participants.join(', '), // Wyświetlamy listę uczestników
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.white,
          height: 1,
        ),
      ],
    );
  }

  void _showParticipantsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chat users'),
          content: SingleChildScrollView(
            child: ListBody(
              children: participants
                  .map((participant) => Text(participant))
                  .toList(),
            ),
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
}
