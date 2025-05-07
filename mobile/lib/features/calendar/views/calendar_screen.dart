import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../shared/themes/styles.dart';
import '../views/widgets/calendar_widget.dart';
import '../views/widgets/task_list.dart';
import '/shared/widgets/bottom_navigation.dart';
import '../../../shared/services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
      List<Map<String, dynamic>> tasks = await TaskService.fetchTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
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
