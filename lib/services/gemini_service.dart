import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/conversation_message.dart';
import 'package:uuid/uuid.dart';

class GeminiService {
  final String _apiKey;
  final String _userGrade;
  late GenerativeModel _model;

  GeminiService({required String apiKey, required String userGrade})
    : _apiKey = apiKey,
      _userGrade = userGrade {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<ConversationMessage> sendMessage(
    String userMessage,
    List<ConversationMessage> conversationHistory,
  ) async {
    try {
      final messages = _buildMessages(userMessage, conversationHistory);

      final response = await _model.generateContent(
        messages,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        ],
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Gemini API timeout'),
      );

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      return ConversationMessage(
        id: const Uuid().v4(),
        text: response.text!,
        role: 'assistant',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ConversationMessage(
        id: const Uuid().v4(),
        text: '',
        role: 'assistant',
        timestamp: DateTime.now(),
        isError: true,
        errorMessage: 'Gemini Error: $e',
      );
    }
  }

  List<Content> _buildMessages(String userMessage, List<ConversationMessage> history) {
    final messages = <Content>[];
    final systemPrompt = _buildSystemPrompt();

    messages.add(Content('user', [TextPart(systemPrompt)]));

    for (var msg in history) {
      if (msg.text.isNotEmpty && !msg.isError) {
        messages.add(
          Content(
            msg.role == 'user' ? 'user' : 'model',
            [TextPart(msg.text)],
          ),
        );
      }
    }

    messages.add(Content('user', [TextPart(userMessage)]));

    return messages;
  }

  String _buildSystemPrompt() {
    return '''You are a friendly English conversation partner for a Japanese elementary school student in grade $_userGrade.
Your role is to:
1. Help them practice English conversation
2. Keep conversations simple and age-appropriate
3. Use encouraging tone
4. Correct mistakes gently
5. Provide translation hints in Japanese when needed
6. Ask follow-up questions to keep the conversation going
7. Use emojis to make it fun

Keep responses concise (2-3 sentences max for beginners, 3-5 for advanced).
Always respond in English but you can add Japanese translations for difficult words.''';
  }
}
