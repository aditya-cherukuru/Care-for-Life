import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/features/chatbot/data/repositories/gemini_repository.dart';
import 'package:care_for_life/features/chatbot/data/models/chat_message.dart';

// Chat State
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  
  const ChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });
  
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Chat Cubit
class ChatCubit extends Cubit<ChatState> {
  final GeminiRepository _repository;
  
  ChatCubit(this._repository)
      : super(ChatState(messages: _repository.messages));
  
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    emit(state.copyWith(isLoading: true));
    
    try {
      await _repository.sendMessage(content);
      emit(ChatState(
        messages: _repository.messages,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
  
  void clearMessages() {
    _repository.clearMessages();
    emit(const ChatState(messages: []));
  }
}