abstract class ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<Map<String, dynamic>> conversations;
  ConversationLoaded({required this.conversations});
}

class ConversationError extends ConversationState {
  final String message;
  ConversationError(this.message);
}
