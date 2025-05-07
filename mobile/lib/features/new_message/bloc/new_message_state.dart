abstract class NewMessageState {}

class NewMessageInitial extends NewMessageState {}

class NewMessageLoading extends NewMessageState {}

class NewMessageSuccess extends NewMessageState {}

class NewMessageFailure extends NewMessageState {
  final String error;
  NewMessageFailure({required this.error});
}
