import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:web_app/services/chat_hub_service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web_app/themes/styles.dart';

class ChatScreen extends StatefulWidget {
  final String conversationName;
  final List<Map<String, dynamic>> participants;
  final int conversationId;
  final int? teamId; // Opcjonalne teamId dla sprawdzania typu konwersacji
  final String? initialMessage;

  const ChatScreen({
    Key? key,
    required this.conversationName,
    required this.participants,
    required this.conversationId,
    this.teamId,
    this.initialMessage,

  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHubService _chatHubService = ChatHubService();
  List<Map<String, dynamic>> messages = [];
  int? userId;

  @override
void initState() {
  super.initState();
  _connectToChat().then((_) {
    
    // Dodanie wiadomości z NewMessageScreen
     if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _sendMessage(widget.initialMessage!);
    }
_fetchHistory();
  });
}


  @override
  void dispose() {
    _chatHubService.disconnect();
    super.dispose();
  }

  Future<void> _connectToChat() async {
    userId = int.tryParse(
      (html.document.cookie?.split('; ') ?? [])
          .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
          .split('=')[1],
    );

    if (userId != null) {
      await _chatHubService.connect(
        baseUrl: "http://buildbuddy-websocets-hdgubwc5cebedhhz.northeurope-01.azurewebsites.net",
        conversationId: widget.conversationId,
        userId: userId!,
        onMessageReceived: _onMessageReceived,
        onHistoryReceived: _onHistoryReceived,
      );
    }
  }

  void _onMessageReceived(Map<String, dynamic> message) {
    if (message.containsKey('text') &&
        message.containsKey('senderId') &&
        message.containsKey('dateTimeDate')) {
      setState(() {
        messages.add(message);
      });
      _scrollToBottom();
    }
  }

  Future<void> _fetchHistory() async {
    if (userId != null) {
      try {
        await _chatHubService.fetchHistory(widget.conversationId, userId!);
      } catch (e) {
        print("[ChatScreen] Error during FetchHistory: $e");
      }
    }
  }

  void _onHistoryReceived(List<Map<String, dynamic>> history) {
    setState(() {
      messages = history;
    });
    _scrollToBottom();
  }

Future<void> _sendMessage(String text) async {
  if (text.isNotEmpty && userId != null) {
    final localMessage = {
      'senderId': userId,
      'text': text,
      'dateTimeDate': DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(localMessage);
    });

    print("[ChatScreen] Attempting to send message: $text");

    try {
      await _chatHubService.sendMessage(userId!, widget.conversationId, text);
      print("[ChatScreen] Message sent successfully: $text");
    } catch (e) {
      print("[ChatScreen] Error sending message: $e");
    }

    _scrollToBottom();
  }
}


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent+2000 ,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showParticipantsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppStyles.transparentWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            "Conversation participants",
            style: AppStyles.headerStyle,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.participants
                  .map((participant) => Text(
                        "${participant['name']} ${participant['surname']}",
                        style: AppStyles.textStyle,
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: AppStyles.textButtonStyle().copyWith(
                foregroundColor: MaterialStateProperty.all(Colors.black),
              ),
              child: const Text("Zamknij"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String? formattedDate;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.subtract(const Duration(days: 1)).day) {
      formattedDate = "Yesterday";
    } else if (date.year != now.year || date.month != now.month || date.day != now.day) {
      formattedDate = "${date.day}/${date.month}/${date.year}";
    }

    if (formattedDate == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastMessageDate;

    return Scaffold(
      body: Container(
        decoration: AppStyles.backgroundDecoration,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                final isTeamChat = widget.teamId != null;
                final isGroupChat = widget.participants.length > 1;

                if (isTeamChat || isGroupChat) {
                  _showParticipantsDialog();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.conversationName,
                        style: AppStyles.headerStyle.copyWith(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isSentByMe = message['senderId'] == userId;
                  final timestampString = message['dateTimeDate'];

                  final messageDate = timestampString != null
                      ? DateTime.tryParse(timestampString)?.toLocal() ?? DateTime.now()
                      : DateTime.now();

                  final bool isLastMessageOfDay = index == messages.length - 1 ||
                      (index < messages.length - 1 &&
                          DateTime.tryParse(messages[index + 1]['dateTimeDate'])
                                  ?.toLocal()
                                  .day !=
                              messageDate.day);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSentByMe ?Colors.lightBlue[100] :  Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isSentByMe ? const Radius.circular(12) : Radius.zero,
                                bottomRight: isSentByMe ? Radius.zero : const Radius.circular(12),
                              ),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Column(
                              crossAxisAlignment: isSentByMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isSentByMe)
                                  Text(
                                    "${widget.participants.firstWhere(
                                      (p) => p['id'] == message['senderId'],
                                      orElse: () => {'name': 'Unknown', 'surname': ''},
                                    )['name'] ?? 'Unknown'} ${widget.participants.firstWhere(
                                      (p) => p['id'] == message['senderId'],
                                      orElse: () => {'name': '', 'surname': ''},
                                    )['surname'] ?? ''}",
                                    style: AppStyles.textStyle,
                                  ),
                                Text(
                                  message['text'] ?? '',
                                  textAlign: isSentByMe ? TextAlign.right : TextAlign.left,
                                  style: AppStyles.textStyle.copyWith(fontSize: 16),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      messageDate.toString().substring(11, 16),
                                      style: AppStyles.textStyle.copyWith(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isLastMessageOfDay) _buildDateSeparator(messageDate),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white.withOpacity(0.3),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: AppStyles.inputFieldStyle(hintText: "Write message... ").copyWith(
                        filled: false,
                        hintStyle: const TextStyle(color: Colors.black54),
                        fillColor: Colors.transparent,
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppStyles.primaryBlue),
                     onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    _sendMessage(text);
                    _messageController.clear();
                     }
                     }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
