import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:care_for_life/core/utils/constants.dart';

class GeminiService {
  Future<String> generateResponse(String prompt) async {
    final url = Uri.parse('${AppConstants.geminiApiUrl}?key=${AppConstants.geminiApiKey}');
    
    final payload = {
      'contents': [
        {
          'parts': [
            {
              'text': 'You are a helpful health assistant for the Care for Life app. '
                  'Provide accurate, concise, and helpful information about health, '
                  'wellness, habits, nutrition, exercise, and mental well-being. '
                  'Keep responses friendly and supportive. '
                  'User query: $prompt'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      }
    };
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with Gemini API: $e');
    }
  }
}