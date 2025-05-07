import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/task_item.dart';

class TaskList extends StatelessWidget {
  final DateTime selectedDay;
  final List<Map<String, dynamic>> tasks;

  const TaskList({
    super.key,
    required this.selectedDay,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks for: ${DateFormat('dd.MM.yyyy', 'pl_PL').format(selectedDay)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No task for today.'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      // Ensure startTime and endTime are formatted
                      final String startTime = DateFormat('yyyy-MM-dd HH:mm').format(task['startTime']);
                      final String endTime = DateFormat('yyyy-MM-dd HH:mm').format(task['endTime']);

                      // Pass formatted times to TaskItem
                      return TaskItem(
                        task: {
                          ...task,
                          'startTime': startTime,
                          'endTime': endTime,
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
