import 'package:flutter/material.dart';
import 'package:mobile/features/calendar/views/calendar_screen.dart';
import 'package:mobile/features/construction_calendar/views/construction_calendar_screen.dart';
import 'package:mobile/features/construction_home/views/construction_home_screen.dart';
import 'package:mobile/features/construction_inventory/views/inventory_screen.dart';
import 'package:mobile/features/construction_team/views/team_screen.dart';
import 'package:mobile/features/conversation_list/views/conversation_list_screen.dart';
import 'package:mobile/features/profile/views/user_profile_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../state/app_state.dart' as appState;

class NavigationConfig {
  static List<Map<String, dynamic>> getNavItems(bool isConstructionMode) {
    return isConstructionMode
        ? [
            {'icon': Icons.calendar_today, 'label': 'Calendar', 'route': '/construction_calendar'},
            {'icon': Icons.people, 'label': 'Team', 'route': '/construction_team'},
            {'icon': Icons.home, 'label': 'Home', 'route': '/home'},
            {'icon': Icons.construction, 'label': 'Construction', 'route': '/construction_home'},
            {'icon': Icons.inventory, 'label': 'Inventory', 'route': '/construction_inventory'},
          ]
        : [
            {'icon': Icons.calendar_today, 'label': 'Calendar', 'route': '/calendar'},
            {'icon': Icons.chat, 'label': 'Chat', 'route': '/chats'},
            {'icon': Icons.home, 'label': 'Home', 'route': '/home'},
            {'icon': Icons.person, 'label': 'Profile', 'route': '/profile'},
          ];
  }

  static Widget getDestinationScreen(String route) {
    switch (route) {
      case '/calendar':
        return const CalendarScreen();
      case '/construction_calendar':
        return const ConstructionCalendarScreen();
      case '/construction_team':
        return const TeamScreen();
      case '/construction_home':
        return const ConstructionHomeScreen();
      case '/construction_inventory':
        return const InventoryScreen();
      case '/chats':
        return const ConversationListScreen();
      case '/home':
        appState.isConstructionContext = false;
        return const HomeScreen();
      case '/profile':
        return const UserProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
