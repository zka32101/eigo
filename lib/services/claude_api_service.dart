import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/conversation_message.dart';
import 'package:uuid/uuid.dart';

class ClaudeApiService {
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _model = 'claude-3-5-haiku-20241022';
  static const int _maxTokens = 500;

  final String _apiKey;
  final String _userGrade;

  ClaudeApiService({required String apiKey, required String userGrade})
    : _apiKey = apiKey,
      _userGrade = userGrade;

  Future<ConversationMessage> sendMessage(
    String userMessage,
    List<ConversationMessage> conversationHistory,
  ) async {
    const uuid = Uuid();

    try {
      final systemPrompt = _buildSystemPrompt();
      final messages = _buildMessages(userMessage, conversationHistory);

      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': _maxTokens,
          'system': systemPrompt,
          'messages': messages,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final assistantMessage = body['content'][0]['text'] as String;

        return ConversationMessage(
          id: uuid.v4(),
          text: assistantMessage,
          role: 'assistant',
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return ConversationMessage(
        id: uuid.v4(),
        text: '',
        role: 'assistant',
        timestamp: DateTime.now(),
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  String _buildSystemPrompt() {
    return '''You are a friendly English conversation partner for a ${_userGrade}-year-old Japanese elementary school student learning English.

Your role is to:
1. Have natural, encouraging conversations in simple English
2. Use vocabulary appropriate for this student's age and level
3. Correct mistakes gently and naturally
4. Ask follow-up questions to keep the conversation going
5. Celebrate successes and encourage the student
6. Mix English with Japanese hints when the student seems to struggle

Topics: daily life, hobbies, school, family, nature, food, animals, games, dreams

Always keep responses brief (1-3 sentences max) and use simple, clear English. If the student doesn't respond, gently encourage them with a hint.''';
  }

  List<Map<String, String>> _buildMessages(
    String userMessage,
    List<ConversationMessage> history,
  ) {
    final messages = <Map<String, String>>[];

    for (final msg in history) {
      if (!msg.isError) {
        messages.add({
          'role': msg.role,
          'content': msg.text,
        });
      }
    }

    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    return messages;
  }
}
