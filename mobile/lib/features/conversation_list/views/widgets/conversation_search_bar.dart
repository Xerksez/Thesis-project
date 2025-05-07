import 'package:flutter/material.dart';

class ConversationSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onAddPressed;

  const ConversationSearchBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Find by name...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.black),
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}
