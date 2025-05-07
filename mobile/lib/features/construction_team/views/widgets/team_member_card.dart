import 'package:flutter/material.dart';
import 'package:mobile/shared/state/app_state.dart' as appState;

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final Function()? onInfoPressed;
  final Function()? onChatPressed;

  const TeamMemberCard({
    Key? key,
    required this.name,
    required this.role,
    required this.phone,
    this.onInfoPressed,
    this.onChatPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(role.isNotEmpty ? role : 'No role asigned'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onInfoPressed != null)
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: onInfoPressed,
              ),
            if (onChatPressed != null)
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  // Aktualizacja stanu globalnego
                  appState.currentPage = 'chats';
                  appState.isConstructionContext = false;

                  // Wywołanie przekazanej funkcji
                  onChatPressed?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}
