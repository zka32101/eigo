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

  /// 先生ごっこモード：「間違い方」を生成
  Future<TeacherModeResponse> generateWrongPhrase({
    required String correctPhrase,
    required String japaneseTranslation,
    required String difficulty,
    required int userLevel,
  }) async {
    final prompt = _buildTeacherPrompt(
      correctPhrase,
      japaneseTranslation,
      difficulty,
      userLevel,
    );

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 300,
          'temperature': 0.7,
          'messages': [{'role': 'user', 'content': prompt}],
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final jsonText = body['content'][0]['text'] as String;
        return TeacherModeResponse.fromJson(_extractJson(jsonText));
      } else {
        return _getPresetWrongPhrase(correctPhrase, difficulty);
      }
    } catch (e) {
      print('Teacher mode API error: $e');
      return _getPresetWrongPhrase(correctPhrase, difficulty);
    }
  }

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

  /// 先生ごっこ用プロンプト構築
  String _buildTeacherPrompt(
    String correctPhrase,
    String japaneseTranslation,
    String difficulty,
    int userLevel,
  ) {
    if (difficulty == 'beginner') {
      return '''You are a student character in an English learning app.
The child is teaching you. Make a SMALL mistake in pronunciation or stress.

Correct phrase: "$correctPhrase"
Japanese: "$japaneseTranslation"
Difficulty: BEGINNER

Output ONLY JSON (no markdown):
{"mistake":"[wrong phrase]","mistakeType":"pronunciation","explanation":"[why wrong-Japanese]","correction":"$correctPhrase","teachingTip":"[hint]"}''';
    } else if (difficulty == 'intermediate') {
      return '''You are a student character. Make a grammar mistake.

Correct phrase: "$correctPhrase"
Japanese: "$japaneseTranslation"
Difficulty: INTERMEDIATE

Output ONLY JSON:
{"mistake":"[wrong]","mistakeType":"grammar","explanation":"[why-Japanese]","correction":"$correctPhrase","teachingTip":"[rule]"}''';
    } else {
      return '''You are an advanced student. Make a subtle semantic mistake.

Correct phrase: "$correctPhrase"
Japanese: "$japaneseTranslation"
Difficulty: ADVANCED

Output ONLY JSON:
{"mistake":"[wrong]","mistakeType":"semantic","explanation":"[detailed-Japanese]","correction":"$correctPhrase","teachingTip":"[deep explanation]"}''';
    }
  }

  /// JSON 抽出
  String _extractJson(String text) {
    final jsonPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonPattern.firstMatch(text);
    if (match != null) return match.group(1) ?? text;

    final backtickPattern = RegExp(r'```\s*([\s\S]*?)\s*```');
    final backtickMatch = backtickPattern.firstMatch(text);
    if (backtickMatch != null) return backtickMatch.group(1) ?? text;

    return text;
  }

  /// フォールバック：プリセット「間違い方」
  TeacherModeResponse _getPresetWrongPhrase(
    String correctPhrase,
    String difficulty,
  ) {
    if (difficulty == 'beginner') {
      return TeacherModeResponse(
        mistake: _addMinorError(correctPhrase),
        mistakeType: 'pronunciation',
        explanation: '発音が少し違っています',
        correction: correctPhrase,
        teachingTip: 'ゆっくり、はっきり発音してみましょう',
      );
    } else if (difficulty == 'intermediate') {
      return TeacherModeResponse(
        mistake: _addGrammarError(correctPhrase),
        mistakeType: 'grammar',
        explanation: '文法が少し違っています',
        correction: correctPhrase,
        teachingTip: '英語の文法ルールを思い出してください',
      );
    } else {
      return TeacherModeResponse(
        mistake: correctPhrase,
        mistakeType: 'semantic',
        explanation: '意味の使い方が違っています',
        correction: correctPhrase,
        teachingTip: '単語の使い分けが大切です',
      );
    }
  }

  String _addMinorError(String phrase) {
    final words = phrase.split(' ');
    if (words.isNotEmpty && words.last.length > 2) {
      final last = words.last;
      words[words.length - 1] = last.substring(0, last.length - 1) + 'z';
    }
    return words.join(' ');
  }

  String _addGrammarError(String phrase) {
    if (phrase.contains('goes')) return phrase.replaceFirst('goes', 'go');
    if (phrase.contains('is')) return phrase.replaceFirst('is', 'are');
    return phrase;
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

/// 先生ごっこ「間違い方」レスポンス
class TeacherModeResponse {
  final String mistake;
  final String mistakeType;
  final String explanation;
  final String correction;
  final String teachingTip;

  TeacherModeResponse({
    required this.mistake,
    required this.mistakeType,
    required this.explanation,
    required this.correction,
    required this.teachingTip,
  });

  factory TeacherModeResponse.fromJson(dynamic json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (e) {
        return TeacherModeResponse(
          mistake: 'Error',
          mistakeType: 'error',
          explanation: 'エラー',
          correction: 'もう一度試してください',
          teachingTip: '',
        );
      }
    }

    return TeacherModeResponse(
      mistake: json['mistake'] ?? '',
      mistakeType: json['mistakeType'] ?? 'grammar',
      explanation: json['explanation'] ?? '',
      correction: json['correction'] ?? '',
      teachingTip: json['teachingTip'] ?? '',
    );
  }
}
