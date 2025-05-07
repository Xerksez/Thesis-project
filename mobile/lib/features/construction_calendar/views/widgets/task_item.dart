import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../tasks/views/task_details_screen.dart';

class TaskItem extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final String title = task['name'] ?? 'Brak nazwy';
    final String description = task['message'] ?? 'Brak opisu';

    // Parse DateTime and Format with Error Handling
    String formattedStartTime = 'Invalid Date';
    String formattedEndTime = 'Invalid Date';
    try {
      final DateTime startTime = DateTime.parse(task['startTime']);
      final DateTime endTime = DateTime.parse(task['endTime']);
      formattedStartTime = DateFormat('yyyy-MM-dd HH:mm').format(startTime);
      formattedEndTime = DateFormat('yyyy-MM-dd HH:mm').format(endTime);
    } catch (e) {
      print('Error parsing startTime or endTime for task: $task, Error: $e');
    }

    final int? taskId = task['id'];

    return GestureDetector(
      onTap: () {
        print('Task clicked - Task ID: $taskId');

        if (taskId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                title: title,
                description: description,
                startTime: formattedStartTime,
                endTime: formattedEndTime,
                taskDate: formattedStartTime.split(' ')[0], // Extract date
                taskId: taskId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task ID is missing')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.event_note, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Hours: $formattedStartTime - $formattedEndTime',
                    style: const TextStyle(fontSize: 12, color: Colors.black),
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
