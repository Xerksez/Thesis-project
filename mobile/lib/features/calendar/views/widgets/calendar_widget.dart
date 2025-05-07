import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white.withOpacity(0.8),
      child: TableCalendar(
        locale: 'pl_PL',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          weekendTextStyle: TextStyle(color: Colors.black),
          defaultTextStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
