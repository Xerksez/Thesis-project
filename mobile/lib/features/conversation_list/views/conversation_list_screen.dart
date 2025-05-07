import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/chat/bloc/chat_bloc.dart';
import 'package:mobile/features/new_message/new_message_screen.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import 'widgets/conversation_item.dart';
import 'widgets/conversation_search_bar.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'package:http/http.dart' as http;

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  _ConversationListScreenState createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allConversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
  bool isLoading = true;
  String? errorMessage;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
   context.read<ConversationBloc>().add(LoadConversationsFromCacheEvent());
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<ConversationBloc>().add(LoadConversationsEvent());
    });
    _loadConversations();  // Ładowanie konwersacji przy starcie
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
  }

  void _filterConversations(String query) {
  final results = allConversations
      .where((conv) {
        final conversationName = conv['conversationName']?.toString().toLowerCase() ?? '';
        print('[ConversationListScreen] Filtering for query "$query" in conversationName: $conversationName');
        return conversationName.contains(query.toLowerCase());
      })
      .toList();

  setState(() {
    filteredConversations = results;
  });

  print('[ConversationListScreen] Filtered conversations: $filteredConversations');
}

Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

  // Funkcja do zapisywania czasu przed wejściem na czat
Future<void> _saveLastMessageTime(int conversationId) async {
  final token = await _getToken();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId') ?? 0; // Pobieramy userId z SharedPreferences
  if (userId == 0) {
    print("[ConversationListScreen] Error: User not logged in.");
    return;
  }
  final url = AppConfig.exitChatEndpoint(conversationId, userId); // Twój poprawny endpoint
  print("[ConversationListScreen] conv id ${conversationId}");
  print("[ConversationListScreen] user id ${userId}");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {

      print("[ConversationListScreen] Time saved");
    } else {
      // Wydrukowanie kodu statusu i ciała odpowiedzi w przypadku błędu
      print("[ConversationListScreen] Error fetching last message time: ${response.statusCode}, ${response.body}");
    }
  } catch (e) {
    print("[ConversationListScreen] Error during fetch: $e");
  }
}

  void _loadConversations() {
    context.read<ConversationBloc>().add(LoadConversationsFromCacheEvent());
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<ConversationBloc>().add(LoadConversationsEvent());
    });
  }

  // Sprawdzanie stanu ładowania konwersacji w funkcji
void _updateConversations(List<Map<String, dynamic>> conversations) async {
  final prefs = await SharedPreferences.getInstance();
  final Map<int, DateTime> lastMessageTimes = {};

  for (var conversation in conversations) {
    final conversationId = conversation['id'];
    final lastMessageTimeStr = prefs.getString('lastMessageTime_$conversationId');
    if (lastMessageTimeStr != null) {
      lastMessageTimes[conversationId] = DateTime.parse(lastMessageTimeStr);
    } else {
      lastMessageTimes[conversationId] = DateTime(1970);
    }
    conversation['lastMessageTime'] = lastMessageTimes[conversationId]?.toIso8601String();
  }

  // Sortowanie konwersacji po czasie ostatniej wiadomości
  conversations.sort((a, b) {
    final lastMessageTimeA = lastMessageTimes[a['id']] ?? DateTime(1970);
    final lastMessageTimeB = lastMessageTimes[b['id']] ?? DateTime(1970);
    return lastMessageTimeB.compareTo(lastMessageTimeA);
  });

  // Logowanie uporządkowanej listy konwersacji
  print("[ConversationListScreen] Sorted conversations with times:");
  for (var conversation in conversations) {
    final id = conversation['id'];
    final name = conversation['name'] ?? 'Unnamed Conversation';
    final lastMessageTime = conversation['lastMessageTime'] ?? 'No Time';
    print("  - ID: $id, Name: $name, LastMessageTime: $lastMessageTime");
  }

  setState(() {
    allConversations = conversations;
    filteredConversations = allConversations;
    isLoading = false;
  });
}




Future<void> _updateLastChecked(int conversationId) async {
  final prefs = await SharedPreferences.getInstance();
  // Zapisz czas wejścia do czatu
  await prefs.setString('lastChecked_$conversationId', DateTime.now().toIso8601String());
  // Dodatkowy log dla sprawdzenia
  print("[HomeScreen] Last checked time for conversation $conversationId updated: ${DateTime.now().toIso8601String()}");
  // Odczytujemy wartość z SharedPreferences, aby upewnić się, że jest zapisana
  final lastChecked = prefs.getString('lastChecked_$conversationId');
  print("[HomeScreen] Last checked value for conversation $conversationId: $lastChecked");
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: AppStyles.backgroundDecoration),
          ),
          Positioned.fill(
            child: Container(color: AppStyles.filterColor.withOpacity(0.75)),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: Column(
                      children: [
                        ConversationSearchBar(
                          searchController: searchController,
                          onSearch: _filterConversations,
                          onAddPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('userId');
                            if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    final chatBloc =
                                        BlocProvider.of<ChatBloc>(context);
                                    return NewMessageScreen(chatBloc: chatBloc);
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Błąd: Brak userId.'))
                              );
                            }
                          },
                        ),
                        Expanded(
                          child: BlocConsumer<ConversationBloc,
                              ConversationState>( 
                            listener: (context, state) {
                              if (state is ConversationLoaded) {
                                _updateConversations(state.conversations); // Update conversations
                              } else if (state is ConversationError) {
                                errorMessage = state.message;
                                isLoading = false;
                              } else if (state is ConversationLoading) {
                                isLoading = allConversations.isEmpty;
                              }
                            },
                            builder: (context, state) {
                              if (isLoading && allConversations.isEmpty) {
                                return ListView.builder(
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    return _buildSkeletonLoader();
                                  },
                                );
                              }

                              if (allConversations.isNotEmpty) {
                                return ListView.builder(
                                  itemCount: filteredConversations.length,
                                  itemBuilder: (context, index) {
                                    final conversation = filteredConversations[index];
                                    final conversationId = conversation['id'] as int? ?? 0;

                                    final List<dynamic> users = conversation['users'] ?? [];
                                    final List<Map<String, dynamic>> participants = users
                                        .map((user) => {
                                              'id': user['id'],
                                              'name': '${user['name']} ${user['surname']}',
                                            })
                                        .toList();

                                    String conversationName = '';
                                    String participantsList = '';

                                    if (participants.length == 2) {
                                      // Jeśli konwersacja ma tylko dwóch uczestników
                                      final otherUser = participants
                                          .firstWhere((p) => p['id'] != userId, orElse: () => participants.first);
                                      conversationName = otherUser['name'];
                                    } else {
                                      // Jeśli jest więcej uczestników
                                      if (conversation['teamId'] != null) {
                                        // Jeśli teamId jest niepusty, używamy conversation['name']
                                        conversationName = conversation['name'] ?? 'Group chat';
                                        participantsList = participants
                                            .where((p) => p['id'] != userId)
                                            .map((p) => p['name'])
                                            .join(', ');
                                      } else {
                                        // W przeciwnym razie ustawiamy "Konwersacja grupowa"
                                        conversationName = 'Group chat';
                                        participantsList = participants
                                            .where((p) => p['id'] != userId)
                                            .map((p) => p['name'])
                                            .join(', ');
                                      }
                                      
                                    }
                                    conversation['conversationName'] = conversationName;
                                    return ConversationItem(
                                      name: conversationName,
                                      onTap: () async {
                                        await _saveLastMessageTime(conversationId);
                                        await _updateLastChecked(conversationId);
                                        final result = await Navigator.pushNamed(
                                          context,
                                          '/chat',
                                          arguments: {
                                            'conversationName': conversationName,
                                            'participants': participants,
                                            'conversationId': conversationId,
                                          },
                                        );

                                        // Jeśli wynik jest 'refresh', to odśwież konwersacje
                                        if (result == 'refresh') {
                                          // Jeśli dostaliśmy sygnał o odświeżeniu, załaduj konwersacje ponownie
                                          _loadConversations();
                                        }
                                      },
                                      participantsList: participantsList,
                                    );
                                  },
                                );
                              }

                              if (errorMessage != null) {
                                return Center(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              return const Center(
                                  child: Text('No chat found.'));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BottomNavigation(onTap: (index) {
                  print("Tapped index: $index");
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
