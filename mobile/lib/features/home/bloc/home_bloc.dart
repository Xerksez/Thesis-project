import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_event.dart';
import 'home_state.dart';
import '../services/home_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService homeService;

  HomeBloc({required this.homeService}) : super(HomeInitial()) {
    on<FetchTeamsEvent>(_onFetchTeams);
    on<FetchTeamsFromCacheEvent>(_onFetchTeamsFromCache);
  }

  /// Fetch teams from the API
  Future<void> _onFetchTeams(FetchTeamsEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoading()); // Show loading indicator
      final teams = await homeService.fetchTeams(event.userId);

      if (teams.isEmpty) {
        // Emit "no teams found" state explicitly
        emit(HomeLoaded([], noTeamsFound: true));
      } else {
        // Cache the fetched teams
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cachedTeams', jsonEncode(teams));

        // Emit loaded teams state
        emit(HomeLoaded(teams));
      }
    } catch (e) {
      if (e.toString().contains('404')) {
        // Handle 404 explicitly as "no teams found"
        emit(HomeLoaded([], noTeamsFound: true));
      } else {
        // Emit error state for other errors
        emit(HomeError('Błąd podczas pobierania zespołów: ${e.toString()}'));
      }
    }
  }

  /// Default cache handling: No teams found is shown
  Future<void> _onFetchTeamsFromCache(FetchTeamsFromCacheEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoaded([], noTeamsFound: true)); // Default behavior shows "no teams found"
  }
}
