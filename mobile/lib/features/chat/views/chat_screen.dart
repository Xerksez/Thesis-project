
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/chat_header.dart'; // Importujemy ChatHeader
import 'package:mobile/shared/themes/styles.dart';

class ChatScreen extends StatefulWidget {
  final String conversationName;
  final List<Map<String, dynamic>> participants; // Lista map z uczestnikami
  final int conversationId; // Accept conversationId as part of the constructor

  const ChatScreen({
    super.key,
    required this.participants,
    required this.conversationName,
    required this.conversationId, // Add conversationId to the constructor
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatBloc? _chatBloc;
  int? userId;

  @override
  void dispose() {
    _updateLastChecked(widget.conversationId);
    _chatBloc?.chatHubService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _loadUserIdAndConversationId(); // Use conversationId passed through arguments
  }

  void _loadUserIdAndConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    setState(() {
      this.userId = userId;
    });

    // Use the conversationId passed via arguments, no need for SharedPreferences here
    final conversationId = widget.conversationId;
    print(conversationId);
    if (conversationId != 0) {
      _chatBloc?.add(ConnectChatEvent(
        baseUrl: AppConfig.getChatUrl(),
        conversationId: conversationId,  // Use passed conversationId
        userId: userId,
      ));
    } else {
      print("[ChatScreen] No valid conversationId passed");
    }
  }

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      final senderId = userId ?? 0;
      final conversationId = widget.conversationId; // Use conversationId passed via arguments

      _chatBloc?.add(SendMessageEvent(
        senderId: senderId,
        conversationId: conversationId,  // Use passed conversationId
        text: text,
      ));

      messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final targetOffset = _scrollController.position.maxScrollExtent;
        if (_scrollController.offset != targetOffset) {
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final formattedDate = date.day == now.day &&
            date.month == now.month &&
            date.year == now.year
        ? "Dzisiaj"
        : "${date.day}/${date.month}/${date.year}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Text(
        formattedDate,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getSenderName(int senderId) {
    for (var participant in widget.participants) {
      if (participant['id'] == senderId) {
        return participant['name'];
      }
    }
    return 'Nieznany użytkownik';
  }

 Future<void> _updateLastChecked(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastChecked_$conversationId', DateTime.now().toIso8601String());
    print("[NewMessageScreen] Last checked time for conversation $conversationId updated.");
  }


  @override
  Widget build(BuildContext context) {
    List<String> filteredParticipants = widget.participants
        .where((participant) => participant['id'] != userId)
        .map((p) => p['name'].toString())
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: AppStyles.backgroundDecoration),
          ),
          Positioned.fill(
            child: Container(color: AppStyles.filterColor.withOpacity(0.75)),
          ),
          Column(
            children: [
              // Wybór, jak nazywać nagłówek
              ChatHeader(
                conversationName: widget.conversationName,
                participants: filteredParticipants,
                onBackPressed: () {
                  Navigator.pop(context, 'refresh');
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/chats', // Change to your conversation list path
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              Expanded(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: BlocConsumer<ChatBloc, ChatState>(
                    listener: (context, state) {
                      if (state is ChatLoaded) {
                        _scrollToBottom();
                      }
                    },
                    builder: (context, state) {
                      if (state is ChatLoaded) {
                        final messages = state.messages;
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final senderName = _getSenderName(message.senderId);
                            final previousMessage =
                                index > 0 ? messages[index - 1] : null;

                            final showDateSeparator = previousMessage == null ||
                                message.timestamp.toLocal().day !=
                                    previousMessage.timestamp.toLocal().day;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showDateSeparator)
                                  _buildDateSeparator(message.timestamp.toLocal()),
                                ChatBubble(
                                  message: message.text,
                                  isSentByMe: message.senderId == userId,
                                  sender: senderName,
                                  time: message.timestamp
                                      .toLocal()
                                      .toString()
                                      .substring(11, 16),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              ChatInputField(
                controller: messageController,
                onSendPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
