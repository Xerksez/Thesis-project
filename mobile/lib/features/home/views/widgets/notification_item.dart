import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final VoidCallback onClose; // Dodany parametr onClose

  const NotificationItem({super.key, required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4.0)],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose, // Użycie onClose
          ),
        ),
      ),
    );
  }
}
