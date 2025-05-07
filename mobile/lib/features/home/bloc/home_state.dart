abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<dynamic> teams;
  final bool noTeamsFound; // Indicates if no teams were found
  HomeLoaded(this.teams, {this.noTeamsFound = false});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
