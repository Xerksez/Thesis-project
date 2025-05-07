import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_app/screens/chat_screen.dart';
import 'package:web_app/screens/new_message_screen.dart';
import 'package:web_app/services/conversations_service.dart';
import 'package:universal_html/html.dart' as html;

import 'package:web_app/themes/styles.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ConversationsService _service = ConversationsService();
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredConversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _service.fetchConversations();
      setState(() {
        conversations = data;
        filteredConversations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _getConversationName(Map<String, dynamic> conversation, int? userIdFromCookie) {
    final participants = conversation['participants'] as List<dynamic>? ?? conversation['users'] as List<dynamic>? ?? [];
    final filteredParticipants = participants.where((participant) => participant['id'] != userIdFromCookie).toList();

    if (conversation['teamId'] != null) {
      return conversation['name'] ?? 'Unknown Group';
    }

    if (filteredParticipants.length == 1) {
      final otherUser = filteredParticipants.first;
      return '${otherUser['name']} ${otherUser['surname']}';
    }

    return 'Konwersacja grupowa';
  }

  void _filterConversations(String query) {
    final userId = int.tryParse(
        (html.document.cookie?.split('; ') ?? [])
            .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
            .split('=')[1]);

    setState(() {
      filteredConversations = conversations.where((conversation) {
        final conversationName = _getConversationName(conversation, userId).toLowerCase();
        return conversationName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = int.tryParse(
        (html.document.cookie?.split('; ') ?? [])
            .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
            .split('=')[1]);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, 
        title: const Text('Conversations', style: AppStyles.headerStyle), 
        backgroundColor: const Color.fromARGB(144, 81, 85, 87),
         actions: [
      IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: _loadConversations, // Wywołanie funkcji odświeżania
      tooltip: 'Odśwież', // Podpowiedź przy najechaniu kursorem
    ),
  ],
      ),
      body: Container(
        decoration: AppStyles.backgroundDecoration,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppStyles.primaryBlue))
            : errorMessage != null
                ? Center(
                    child: Text(
                      'Error: $errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _ConversationSearchBar(
                          searchController: _searchController,
                          onSearch: _filterConversations,
                          onAddPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewMessageScreen(), // Upewnij się, że przekazujesz poprawny userId
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conversation = filteredConversations[index];
                            final conversationName = _getConversationName(conversation, userId);
                            final participants = (conversation['participants'] as List<dynamic>? ?? conversation['users'])
                                .where((participant) => participant['id'] != userId)
                                .toList();
                            final participantNames =
                                (conversation['teamId'] == null && participants.length > 1) ||
                                        (conversation['teamId'] != null && participants.length > 0)
                                    ? participants
                                        .map((participant) => '${participant['name']} ${participant['surname']}')
                                        .join(', ')
                                    : '';

                            return _ConversationItem(
                              name: conversationName,
                              participantsList: participantNames,
                              onTap: () {
                                final conversationId = conversation['id'];
                                final teamId = conversation['teamId'];
                                final participants = (conversation['participants'] as List<dynamic>? ?? conversation['users'] as List<dynamic>? ?? [])
                                    .where((participant) => participant['id'] != userId)
                                    .map((participant) => Map<String, dynamic>.from(participant))
                                    .toList();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      conversationName: conversationName,
                                      participants: participants,
                                      conversationId: conversationId,
                                      teamId: teamId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final String participantsList;

  const _ConversationItem({
    required this.name,
    required this.onTap,
    required this.participantsList,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppStyles.transparentWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          name,
          style: AppStyles.headerStyle,
        ),
        subtitle: participantsList.isNotEmpty
            ? Text(
                participantsList,
                style: AppStyles.textStyle,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _ConversationSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onAddPressed;

  const _ConversationSearchBar({
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
              decoration: AppStyles.inputFieldStyle(hintText: 'Search by name...'),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add, color: AppStyles.primaryBlue),
            label: const Text('New Message', style: TextStyle(color: AppStyles.primaryBlue)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppStyles.primaryBlue),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
