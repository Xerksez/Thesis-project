import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/chat/bloc/chat_bloc.dart';
import 'package:mobile/features/chat/bloc/chat_event.dart';
import 'package:mobile/features/new_message/bloc/new_message_event.dart';
import 'package:mobile/features/new_message/bloc/new_message_state.dart';
import 'package:mobile/features/new_message/services/new_message_service.dart';

class NewMessageBloc extends Bloc<NewMessageEvent, NewMessageState> {
  final ChatBloc chatBloc;
  final NewMessageService _service = NewMessageService();

  NewMessageBloc({required this.chatBloc}) : super(NewMessageInitial()) {
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<NewMessageState> emit) async {
    emit(NewMessageLoading());

    try {
      final recipientIds = await _service.getRecipientIds(event.userId, event.recipientNames);
      final conversationId = await _service.findOrCreateConversation(event.userId, recipientIds);

      chatBloc.add(SendMessageEvent(
        senderId: event.userId,
        conversationId: conversationId,
        text: event.message,
      ));

      emit(NewMessageSuccess());
    } catch (e) {
      emit(NewMessageFailure(error: 'Błąd: $e'));
    }
  }
}
