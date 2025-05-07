import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/conversation_service.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationService conversationService;

  ConversationBloc(this.conversationService) : super(ConversationLoading()) {
    on<LoadConversationsFromCacheEvent>(_onLoadConversationsFromCache);
    on<LoadConversationsEvent>(_onLoadConversations);
  }

  Future<void> _onLoadConversationsFromCache(
      LoadConversationsFromCacheEvent event, Emitter<ConversationState> emit) async {
  //  print("[conversation_bloc] _onLoadConversationsFromCache -> start");
    final cachedConversations = await conversationService.loadConversationsFromCache();

    if (cachedConversations.isNotEmpty) {
   //   print("[conversation_bloc] _onLoadConversationsFromCache -> loaded ${cachedConversations.length} conv from cache");
      emit(ConversationLoaded(conversations: cachedConversations));
     // print("[conversation_bloc] _onLoadConversationsFromCache -> Emit ConversationLoaded (cache)");
    } else {
    //  print("[conversation_bloc] _onLoadConversationsFromCache -> no cached data available");
      // Nie emitujemy błędu, bo za chwilę wczytamy z endpointu
    }
  }

 Future<void> _onLoadConversations(
    LoadConversationsEvent event, Emitter<ConversationState> emit) async {
  emit(ConversationLoading());
  try {
    final rawConversations = await conversationService.fetchConversations();
    if (rawConversations.isEmpty) {
      emit(ConversationLoaded(conversations: [])); // No conversations found
    } else {
      await conversationService.saveConversationsToCache(rawConversations);
      emit(ConversationLoaded(conversations: rawConversations));
    }
  } catch (e) {
    if (e.toString().contains('404')) {
      emit(ConversationLoaded(conversations: [])); // Treat 404 as "no conversations"
    } else {
      emit(ConversationError('Failed to load data: $e'));
    }
  }
}

}
