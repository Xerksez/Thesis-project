abstract class HomeEvent {}

class FetchTeamsEvent extends HomeEvent {
  final int userId;
  FetchTeamsEvent(this.userId);
}

class FetchTeamsFromCacheEvent extends HomeEvent {}