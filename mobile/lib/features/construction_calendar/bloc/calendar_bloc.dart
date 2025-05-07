import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/construction_calendar/services/calendar_service,dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarService calendarService;

  CalendarBloc({required this.calendarService}) : super(CalendarLoading());

  @override
  Stream<CalendarState> mapEventToState(CalendarEvent event) async* {
    if (event is LoadCalendarEvent) {
      yield CalendarLoading();
      try {
        final tasks = await CalendarService.fetchTasks();
        yield CalendarLoaded(tasks: tasks);
      } catch (e) {
        yield CalendarError('Failed to load tasks');
      }
    }
  }
}
