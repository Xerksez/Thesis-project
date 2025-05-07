import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/calendar/views/widgets/calendar_widget.dart';
import 'package:mobile/features/calendar/views/widgets/task_list.dart';
import 'package:mobile/shared/services/task_service.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class ConstructionCalendarScreen extends StatefulWidget {
  const ConstructionCalendarScreen({super.key});

  @override
  _ConstructionCalendarScreenState createState() =>
      _ConstructionCalendarScreenState();
}

class _ConstructionCalendarScreenState
    extends State<ConstructionCalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL');
    
    _loadTasks();
  }

  // Fetch tasks from the backend
  Future<void> _loadTasks() async {
  try {
    // Log the start of the task loading process
  
    print('Loading tasks...');

    // Fetch SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    final int? addressId = prefs.getInt('addressId');
  

    // Log the fetched SharedPreferences values
    print('Fetched userId: $userId, addressId: $addressId');

    if (userId == null || addressId == null) {
      throw Exception('User ID or Address ID not found in SharedPreferences');
    }

    // Log the attempt to fetch tasks
    print('Fetching tasks for userId: $userId, addressId: $addressId');

    // Fetch tasks
    List<Map<String, dynamic>> tasks =
        await TaskService.fetchTasksByAddress(userId, addressId);

    // Log the fetched tasks
    print('Tasks fetched successfully: $tasks');

    // Update state with the fetched tasks
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  } catch (e) {
    // Log the error details
    print('Failed to load tasks: $e');

    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    // Filter tasks for the selected day
    final tasksForSelectedDay = TaskService.getTasksForDay(_tasks, _selectedDay);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),

          // Main content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Calendar widget for day selection
                CalendarWidget(
                  selectedDay: _selectedDay,
                  focusedDay: _focusedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                Container(
                  color: AppStyles.transparentWhite,
                  child: const Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
                // Task List or Loading Spinner
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TaskList(
                          selectedDay: _selectedDay,
                          tasks: tasksForSelectedDay,
                        ),
                ),
                // Bottom Navigation
                BottomNavigation(onTap: (_) {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
