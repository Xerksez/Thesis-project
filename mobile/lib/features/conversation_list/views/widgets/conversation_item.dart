import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final String participantsList; // Dodajemy parametr na listę uczestników

  const ConversationItem({
    super.key,
    required this.name,
    required this.onTap,
    required this.participantsList, // Dodajemy parametr
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: participantsList.isNotEmpty 
          ? Text( // Jeśli jest lista uczestników, wyświetlamy ją
              participantsList,
              style: const TextStyle(color: Colors.black54),
            )
          : null,
        onTap: onTap,
      ),
    );
  }
}
