import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/calendar/views/calendar_screen.dart';
import 'package:mobile/features/chat/bloc/chat_bloc.dart';
import 'package:mobile/features/construction_calendar/services/calendar_service,dart';
import 'package:mobile/shared/services/chat_hub_service.dart';
import 'package:mobile/features/chat/views/chat_screen.dart';
import 'package:mobile/features/conversation_list/bloc/conversation_bloc.dart';
import 'package:mobile/features/conversation_list/services/conversation_service.dart';
import 'package:mobile/features/conversation_list/views/conversation_list_screen.dart';
import 'package:mobile/features/new_message/new_message_screen.dart';
import 'package:mobile/features/construction_calendar/bloc/calendar_bloc.dart';
import 'package:mobile/features/construction_calendar/views/construction_calendar_screen.dart';
import 'package:mobile/features/construction_home/views/construction_home_screen.dart';
import 'package:mobile/features/construction_inventory/blocs/inventory_bloc.dart';
import 'package:mobile/features/construction_inventory/services/inventory_service.dart';
import 'package:mobile/features/construction_inventory/views/inventory_screen.dart';
import 'package:mobile/features/construction_team/views/team_screen.dart';
import 'package:mobile/features/home/bloc/home_bloc.dart';
import 'package:mobile/features/home/services/home_service.dart';
import 'package:mobile/features/home/views/home_screen.dart';
import 'package:mobile/features/profile/bloc/profile_bloc.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/shared/localization/language_provider.dart';
import 'package:mobile/features/login/services/login_service.dart';
import 'package:mobile/features/login/views/login_screen.dart';
import 'package:mobile/features/profile/views/user_profile_screen.dart';
import 'package:mobile/features/register/views/register_screen.dart';
import 'package:mobile/features/login/bloc/login_bloc.dart';
import 'package:mobile/shared/services/chat_polling_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/themes/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final chatPollingService = ChatPollingService();
  // Uruchamiamy polling od razu po starcie aplikacji
  await chatPollingService.startPolling();
  // Stwórz instancje wymaganych serwisów
  final loginService = LoginService();
  final inventoryService = InventoryService();
  final calendarService = CalendarService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (context) => LoginBloc(loginService: loginService)),
        BlocProvider<InventoryBloc>(create: (context) => InventoryBloc(inventoryService: inventoryService)),
        BlocProvider<CalendarBloc>(create: (context) => CalendarBloc(calendarService: calendarService)),
        BlocProvider<HomeBloc>(create: (context) => HomeBloc(homeService: HomeService())),
        BlocProvider<ProfileBloc>(create: (context) => ProfileBloc(UserService())),
        BlocProvider<ConversationBloc>(create: (context) => ConversationBloc(ConversationService())),
        BlocProvider<ChatBloc>(create: (context) => ChatBloc(chatHubService: ChatHubService())),
      ],
      child: BuildBuddyApp(chatPollingService: chatPollingService),
    ),
  );
}

class BuildBuddyApp extends StatefulWidget {
  final ChatPollingService chatPollingService;

  const BuildBuddyApp({super.key, required this.chatPollingService});

  @override
  _BuildBuddyAppState createState() => _BuildBuddyAppState();
}
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class _BuildBuddyAppState extends State<BuildBuddyApp> {
  @override
  void dispose() async{
    widget.chatPollingService.stopPolling();
    super.dispose();
  }

 @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      initialRoute: '/', // Start at the SplashScreen
      routes: {
        '/': (context) => const LoginScreen(), // Show splash screen first
        '/home': (context) => const HomeScreen(),
        '/chats': (context) => const ConversationListScreen(),
        '/calendar': (context) => const CalendarScreen(), // Calendar screen
        '/profile': (context) => const UserProfileScreen(),
        '/new_message': (context) {
          final chatBloc = BlocProvider.of<ChatBloc>(context);
          return NewMessageScreen(chatBloc: chatBloc);
        },
        '/construction_home': (context) => ConstructionHomeScreen(),
        '/construction_team': (context) => TeamScreen(),
        '/construction_inventory': (context) => InventoryScreen(),
        '/construction_calendar': (context) => const ConstructionCalendarScreen(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChatScreen(
            conversationName: args['conversationName'],
            participants: args['participants'],
            conversationId: args['conversationId'],
          );
        },
        '/register': (context) => RegisterScreen(),
      },
      theme: ThemeData(
        primaryColor: AppStyles.primaryBlue,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppStyles.primaryBlue,
          selectionHandleColor: Color.fromARGB(255, 39, 177, 241),
        ),
      ),
    );
  }
}