import 'package:care_for_life/features/chatbot/data/services/gemini_service.dart';
import 'package:care_for_life/features/chatbot/data/models/chat_message.dart';
import 'package:uuid/uuid.dart';

class GeminiRepository {
  final GeminiService _geminiService;
  final List<ChatMessage> _messages = [];
  final _uuid = const Uuid();
  
  GeminiRepository(this._geminiService);
  
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  
  Future<ChatMessage> sendMessage(String content) async {
    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    
    try {
      // Get response from Gemini
      final response = await _geminiService.generateResponse(content);
      
      // Add assistant message
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(assistantMessage);
      
      return assistantMessage;
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Sorry, I encountered an error: $e',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      
      return errorMessage;
    }
  }
  
  void clearMessages() {
    _messages.clear();
  }
}