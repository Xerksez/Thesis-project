import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/shared/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/themes/styles.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'widgets/build_option.dart';
import 'widgets/notification_item.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'package:mobile/shared/state/app_state.dart' as appState;
import 'package:http/http.dart' as http;
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> unreadConversations = []; // Lista rozmów z nowymi wiadomościami
  bool hasNewMessages = false; // Flaga do wykrywania nowych wiadomości
bool _isSessionChecked = false; 

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _checkUserSession();
    appState.currentPage = 'home';
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      context.read<HomeBloc>().add(FetchTeamsFromCacheEvent());
      context.read<HomeBloc>().add(FetchTeamsEvent(userId));
    } else {
      context.read<HomeBloc>().add(FetchTeamsFromCacheEvent());
    }

    _loadUnreadConversations();
  }

Future<void> _checkUserSession() async {
    if (_isSessionChecked) return; // Jeśli sesja była sprawdzana, zakończ

    setState(() {
      _isSessionChecked = true; // Ustaw flagę na true, aby uniknąć wielokrotnego sprawdzania
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Sprawdzam sesję");

    if (token != null) {
      try {
        // Endpoint do sprawdzenia ważności tokena
        final response = await http.get(
          Uri.parse('${AppConfig.getBaseUrl()}/api/Address'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          // Token jest ważny
          print("Token ważny");
        } else if (response.statusCode == 401) {
          Navigator.pushReplacementNamed(context, '/');
          print('[SessionCheck] Token expired or invalid. Logging out.');
          await prefs.clear();
          // Nie wywołuj `pushReplacementNamed` na ekranie logowania, aby uniknąć pętli
        } else {
          // Inny błąd
          Navigator.pushReplacementNamed(context, '/');
          print('[SessionCheck] Unexpected error: ${response.statusCode}');
        }
      } catch (e) {
        // Obsługa błędu sieciowego
        print('[SessionCheck] Network error: $e');
      }
    }
  }

  Future<void> _loadUnreadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> keys = prefs.getKeys().toList();

    print("[HomeScreen] Unread conversations loading... Keys: $keys");

    setState(() {
      unreadConversations = keys
          .where((key) => key.startsWith('lastMessageTime_') && prefs.getString(key) != null)
          .map((key) {
            final conversationId = int.parse(key.replaceFirst('lastMessageTime_', ''));
            final lastMessageTimeStr = prefs.getString('lastMessageTime_$conversationId');
            final lastMessageTime = DateTime.parse(lastMessageTimeStr ?? DateTime(1970).toIso8601String());

            // Log the current state of lastMessageTime
            print("[HomeScreen] conversationId: $conversationId");
            print("[HomeScreen] Last message time: $lastMessageTime");

            final lastCheckedStr = prefs.getString('lastChecked_$conversationId');
            final lastCheckedDate = lastCheckedStr != null ? DateTime.parse(lastCheckedStr) : DateTime(1970);

            // Log the state of lastChecked
            print("[HomeScreen] Last checked str $lastCheckedStr");
            print("[HomeScreen] Last checked time: $lastCheckedDate");

            // Check if the last message time is after the last checked date
            if (lastMessageTime.isAfter(lastCheckedDate)) {
              print("[HomeScreen] New message detected for conversationId: $conversationId");
              return {'conversationId': conversationId, 'lastMessageTime': lastMessageTime};
            }
            print("[HomeScreen] No new message for conversationId: $conversationId");
            return null;
          })
          .where((conversation) => conversation != null) // Remove null elements
          .map((conversation) => conversation!) // Safely unwrap the non-null elements
          .toList();

      hasNewMessages = unreadConversations.isNotEmpty;
      print("[HomeScreen] Unread conversations: $unreadConversations");
    });

    // Log if there are new messages
    if (hasNewMessages) {
      print("[HomeScreen] There are new unread messages.");
    } else {
      print("[HomeScreen] No new unread messages.");
    }
  }

  Future<void> _clearAddressIdCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('addressId');
  }

  Future<void> _clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    // Usuwamy tylko powiadomienia o nieprzeczytanych wiadomościach
    for (var conversation in unreadConversations) {
      await prefs.remove('lastMessageTime_${conversation['conversationId']}');
    }
    setState(() {
      unreadConversations.clear();
      hasNewMessages = false; // Resetujemy flagę
    });
  }

  @override
  void dispose() {
    _clearAddressIdCache();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Background
        Container(decoration: AppStyles.backgroundDecoration),
        // Filter overlay
        Container(color: AppStyles.filterColor.withOpacity(0.75)),
        // Main screen content
        Column(
          children: [
            // Logo at the top
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 25),
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Image.asset('assets/logo_small.png'),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading || state is HomeInitial) {
                    // Show loading indicator
                    return _buildLoadingView();
                  } else if (state is HomeLoaded) {
                    // Show teams section with message or teams
                    return _buildHomeContent(context, state.teams, state.noTeamsFound);
                  } else if (state is HomeError) {
                    // Show error message
                    return Center(
                      child: Text(
                        'Błąd: ${state.message}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            // Bottom Navigation
            BottomNavigation(
              onTap: (index) {
                print("Navigation tapped: $index");
              },
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

Widget _buildHomeContent(BuildContext context, List<dynamic> teams, bool noTeamsFound) {
  return Column(
    children: [
      // Teams Section
      Expanded(
        flex: 4,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: AppStyles.transparentWhite,
          ),
          child: Column(
            children: [
              const Text(
                'Choose team',
                style: AppStyles.headerStyle,
              ),
              Expanded(
                child: noTeamsFound
                    ? Center(
                        child: Text(
                          'No team found or you were not added to a team',
                          style: AppStyles.headerStyle.copyWith(
                            color: const Color.fromARGB(179, 8, 8, 8),
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return BuildOption(
                            title: team['name'],
                            addressId: team['addressId'],
                            onTap: () async {
                              await _saveAddressAndPlaceId(team['addressId']);
                              Navigator.pushNamed(
                                context,
                                '/construction_home',
                                arguments: {
                                  'teamId': team['id'],
                                  'addressId': team['addressId'],
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // Notifications Section
      Expanded(
        flex: 4,
        child: Container(
          color: AppStyles.transparentWhite,
          child: Column(
            children: [
              const Text(
                'Notification',
                style: AppStyles.headerStyle,
              ),
              Expanded(
                child: hasNewMessages
                    ? ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          NotificationItem(
                            title: 'You have new messages',
                            onClose: _clearNotifications,
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          'No new messages',
                          style: AppStyles.headerStyle.copyWith(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}



  // Method to save `addressId` and `placeId` in SharedPreferences
  Future<void> _saveAddressAndPlaceId(int addressId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store addressId
    await prefs.setInt('addressId', addressId);
    print("Saved addressId: $addressId");

    // Store placeId (assuming placeId is the same as addressId)
    await prefs.setInt('placeId', addressId);
    print("Saved placeId: $addressId");
  }
}
