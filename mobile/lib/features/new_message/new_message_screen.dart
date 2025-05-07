import 'package:flutter/material.dart';
import 'package:mobile/features/chat/bloc/chat_bloc.dart';
import 'package:mobile/features/chat/bloc/chat_event.dart';
import 'package:mobile/features/new_message/recipent_selection_screen.dart';
import 'package:mobile/features/new_message/services/new_message_service.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/themes/styles.dart';

class NewMessageScreen extends StatefulWidget {
  final ChatBloc chatBloc;

  const NewMessageScreen({required this.chatBloc, super.key});

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final NewMessageService _newMessageService = NewMessageService();
  List<String> selectedRecipients = [];
  TextEditingController messageController = TextEditingController();
  int? userId;

Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _updateLastChecked(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastChecked_$conversationId', DateTime.now().toIso8601String());
    print("[NewMessageScreen] Last checked time for conversation $conversationId updated.");
  }

  Future<void> _saveLastMessageTime(int conversationId) async {
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    if (userId == 0) {
      print("[ConversationListScreen] Error: User not logged in.");
      return;
    }

    final url = AppConfig.exitChatEndpoint(conversationId, userId);
    try {
      final response = await http.post(Uri.parse(url),
      headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print("[ConversationListScreen] Time saved for conversation $conversationId.");
      } else {
        print("[ConversationListScreen] Error saving time: ${response.body}");
      }
    } catch (e) {
      print("[ConversationListScreen] Error: $e");
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? 0;
    });
  }

  Future<void> _handleSendMessage() async {
    if (selectedRecipients.isEmpty || messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dodaj odbiorców i wpisz wiadomość'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final recipientIds = (await _newMessageService.getRecipientIds(userId!, selectedRecipients))
          .toSet()
          .toList();
      print('[NewMessageScreen] Unique Recipient IDs: $recipientIds');

      final conversationId = await _newMessageService.findOrCreateConversation(userId!, recipientIds);
      print('[NewMessageScreen] Using conversation ID: $conversationId');

      if (widget.chatBloc.chatHubService.isConnected) {
        widget.chatBloc.add(SendMessageEvent(
          senderId: userId!,
          conversationId: conversationId,
          text: messageController.text,
        ));
      } else {
        await widget.chatBloc.chatHubService.connect(
          baseUrl: AppConfig.getChatUrl(),
          conversationId: conversationId,
          userId: userId!,
          chatBloc: widget.chatBloc,
        );
        widget.chatBloc.add(SendMessageEvent(
          senderId: userId!,
          conversationId: conversationId,
          text: messageController.text,
        ));
      }

      final participants = await _getParticipantsWithIds(selectedRecipients);

      // Fetch teamId and conversationName
      final conversationData = await _newMessageService.getConversationData(conversationId);
      final teamId = conversationData['teamId'];
      final conversationName = teamId != null ? conversationData['name'] ?? 'Konwersacja grupowa' : 'Konwersacja grupowa';

      await _updateLastChecked(conversationId);
      await _saveLastMessageTime(conversationId);

      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': conversationId,
          'conversationName': conversationName,
          'participants': removeDuplicateParticipants(participants),
        },
      );
    } catch (e) {
      print('[NewMessageScreen] Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd podczas wysyłania wiadomości'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> removeDuplicateParticipants(List<Map<String, dynamic>> participants) {
    final seenIds = <int>{};
    return participants.where((participant) {
      if (seenIds.contains(participant['id'])) {
        return false;
      } else {
        seenIds.add(participant['id']);
        return true;
      }
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _getParticipantsWithIds(List<String> recipientNames) async {
    List<Map<String, dynamic>> participants = [];
    final token = await _getToken();
    final teamsResponse = await http.get(Uri.parse(AppConfig.getTeamsEndpoint(userId!)),
    headers: {
        'Authorization': 'Bearer $token',
      },
      );

    if (teamsResponse.statusCode == 200) {
      List<dynamic> teams = json.decode(teamsResponse.body);

      for (var team in teams) {
        final teamId = team['id'];
        final membersResponse = await http.get(Uri.parse(AppConfig.getTeammatesEndpoint(teamId)),
        headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (membersResponse.statusCode == 200) {
          List<dynamic> teammates = json.decode(membersResponse.body);

          for (var mate in teammates) {
            String fullName = '${mate['name']} ${mate['surname']}';
            if (recipientNames.contains(fullName) && mate['id'] != userId) {
              participants.add({
                'id': mate['id'],
                'name': fullName,
              });
            }
          }
        }
      }
    }

    return removeDuplicateParticipants(participants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Container(color: AppStyles.transparentWhite),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/chats');
                    },
                  ),
                ),
              ),
              _buildRecipientField(),
              _buildMessageField(),
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        readOnly: true,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipientSelectionScreen(
                selectedRecipients,
                userId: userId!,
              ),
            ),
          );
          if (result != null) {
            setState(() {
              selectedRecipients = result;
            });
          }
        },
        decoration: InputDecoration(
          hintText: selectedRecipients.isEmpty
              ? 'Add recpients'
              : selectedRecipients.join(', '),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 20.0,
          ),
          prefixIcon: const Icon(Icons.person_add, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
        child: TextField(
          controller: messageController,
          maxLines: null,
          expands: true,
          decoration: InputDecoration(
            hintText: 'Wpisz wiadomość...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: _handleSendMessage,
      child: const Text('Wyślij'),
    );
  }
}
