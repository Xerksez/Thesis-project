import 'package:flutter/material.dart';

class InventoryItemCard extends StatelessWidget {
  final String name;
  final int purchased;
  final int remaining;
  final VoidCallback onEdit;

  const InventoryItemCard({
    super.key,
    required this.name,
    required this.purchased,
    required this.remaining,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Purchased: $purchased | Remaining: $remaining'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}