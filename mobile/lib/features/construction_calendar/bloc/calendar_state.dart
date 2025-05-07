import '../models/task_model.dart';

abstract class CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final List<TaskModel> tasks;

  CalendarLoaded({required this.tasks});
}

class CalendarError extends CalendarState {
  final String message;

  CalendarError(this.message);
}
