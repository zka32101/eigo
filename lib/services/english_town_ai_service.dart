import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/english_town_model.dart';
import 'package:uuid/uuid.dart';

/// Response from AI dialogue generation
class NPCDialogueResponse {
  final String id;
  final String npcMessage;
  final String? correctionFeedback;
  final bool isError;
  final String? errorMessage;

  NPCDialogueResponse({
    required this.id,
    required this.npcMessage,
    this.correctionFeedback,
    this.isError = false,
    this.errorMessage,
  });
}

/// Response evaluation result
class ResponseEvaluation {
  final String responseId;
  final int correctnessScore; // 0-100
  final String feedback; // Corrective/encouraging feedback
  final List<String> vocabulary; // Key words learned
  final bool passedThreshold; // Whether response met difficulty threshold

  ResponseEvaluation({
    required this.responseId,
    required this.correctnessScore,
    required this.feedback,
    this.vocabulary = const [],
    this.passedThreshold = true,
  });
}

/// English-Only Town AI Service
/// Handles NPC dialogue generation and response evaluation
class EnglishTownAIService {
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _model = 'claude-3-5-haiku-20241022';
  static const int _maxTokens = 300;
  static const int _evaluationTokens = 200;

  final String _apiKey;

  EnglishTownAIService({required String apiKey}) : _apiKey = apiKey;

  /// Generate NPC response for player input in English-Only Town
  ///
  /// Context includes:
  /// - NPC personality and background
  /// - Location and time of day
  /// - Conversation difficulty
  /// - Conversation history
  Future<NPCDialogueResponse> generateNPCDialogue({
    required NPC npc,
    required Location location,
    required TimeOfDay timeOfDay,
    required ConversationDifficulty difficulty,
    required String playerMessage,
    required List<ConversationTurn> conversationHistory,
  }) async {
    const uuid = Uuid();
    final dialogueId = uuid.v4();

    try {
      final systemPrompt = _buildEnglishTownSystemPrompt(
        npc: npc,
        location: location,
        timeOfDay: timeOfDay,
        difficulty: difficulty,
      );

      final messages = _buildConversationMessages(
        playerMessage: playerMessage,
        history: conversationHistory,
      );

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
          'temperature': 0.8,
          'system': systemPrompt,
          'messages': messages,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final npcMessage = body['content'][0]['text'] as String;

        return NPCDialogueResponse(
          id: dialogueId,
          npcMessage: npcMessage.trim(),
          isError: false,
        );
      } else {
        return NPCDialogueResponse(
          id: dialogueId,
          npcMessage: _getFallbackResponse(npc),
          isError: false,
        );
      }
    } catch (e) {
      return NPCDialogueResponse(
        id: dialogueId,
        npcMessage: _getFallbackResponse(npc),
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Evaluate player's English response for correctness and fluency
  ///
  /// Returns a score 0-100 based on:
  /// - Grammar accuracy
  /// - Vocabulary appropriateness
  /// - Contextual relevance
  /// - Fluency/naturalness
  /// - Difficulty level compliance
  Future<ResponseEvaluation> evaluatePlayerResponse({
    required String playerResponse,
    required NPC npc,
    required ConversationDifficulty difficulty,
    required String npcExpectation,
  }) async {
    const uuid = Uuid();
    final evaluationId = uuid.v4();

    try {
      final prompt = _buildEvaluationPrompt(
        playerResponse: playerResponse,
        npc: npc,
        difficulty: difficulty,
        npcExpectation: npcExpectation,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': _evaluationTokens,
          'temperature': 0.3,
          'messages': [{'role': 'user', 'content': prompt}],
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final responseText = body['content'][0]['text'] as String;

        return _parseEvaluationResponse(responseText, evaluationId);
      } else {
        return ResponseEvaluation(
          responseId: evaluationId,
          correctnessScore: 50,
          feedback: 'Unable to evaluate response. Try again!',
          passedThreshold: false,
        );
      }
    } catch (e) {
      return ResponseEvaluation(
        responseId: evaluationId,
        correctnessScore: 50,
        feedback: 'Error evaluating response. Please try again.',
        passedThreshold: false,
      );
    }
  }

  /// Build system prompt for English-Only Town NPC dialogue
  String _buildEnglishTownSystemPrompt({
    required NPC npc,
    required Location location,
    required TimeOfDay timeOfDay,
    required ConversationDifficulty difficulty,
  }) {
    final difficultyDesc = _getDifficultyDescription(difficulty);

    return '''You are ${npc.name}, a character in an English-Only Town learning game.

Character Profile:
- Personality: ${npc.personality}
- Background: ${npc.backstory}
- Location: ${location.name} (${location.description})
- Current Time: ${_getTimeOfDayString(timeOfDay)}

Conversation Guidelines:
1. Always respond ONLY in English - no translations or code-switching
2. Stay in character and location context
3. Keep responses to 1-2 sentences for natural flow
4. Use vocabulary and grammar appropriate for $difficultyDesc level
5. Be encouraging and supportive of the learner
6. Ask natural follow-up questions to continue the conversation
7. If the learner makes a small mistake, continue naturally without stopping to correct

Difficulty Level: $difficultyDesc
- Easy: Simple present tense, basic vocabulary, common topics
- Medium: Mix of tenses, moderate vocabulary, varied topics
- Hard: Complex structures, advanced vocabulary, nuanced topics
- Expert: Idioms, informal speech, complex reasoning

Respond naturally as ${npc.name} would in this situation.''';
  }

  /// Build evaluation prompt for response scoring
  String _buildEvaluationPrompt({
    required String playerResponse,
    required NPC npc,
    required ConversationDifficulty difficulty,
    required String npcExpectation,
  }) {
    final difficultyDesc = _getDifficultyDescription(difficulty);

    return '''Evaluate this English learner response on a scale of 0-100.

Context:
- NPC: ${npc.name}
- Difficulty Level: $difficultyDesc
- Conversation Context: "$npcExpectation"
- Learner Response: "$playerResponse"

Evaluation Criteria:
1. Grammar Accuracy (0-25 points)
2. Vocabulary Appropriateness (0-25 points)
3. Contextual Relevance (0-25 points)
4. Fluency/Naturalness (0-25 points)

Respond ONLY with this JSON format (no markdown):
{
  "score": <0-100>,
  "feedback": "<1-2 sentence encouraging or corrective feedback>",
  "vocabulary": ["word1", "word2"],
  "passed": <true if score >= 60 for this difficulty level>
}

Be encouraging. A score of 60+ indicates good understanding.''';
  }

  /// Parse evaluation response JSON
  ResponseEvaluation _parseEvaluationResponse(
    String responseText,
    String evaluationId,
  ) {
    try {
      final jsonStr = _extractJson(responseText);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return ResponseEvaluation(
        responseId: evaluationId,
        correctnessScore: (json['score'] as num?)?.toInt() ?? 50,
        feedback: json['feedback'] as String? ?? 'Good effort!',
        vocabulary: List<String>.from(
          (json['vocabulary'] as List?)?.map((v) => v.toString()) ?? [],
        ),
        passedThreshold: json['passed'] as bool? ?? false,
      );
    } catch (e) {
      return ResponseEvaluation(
        responseId: evaluationId,
        correctnessScore: 50,
        feedback: 'Good effort! Keep practicing.',
        passedThreshold: false,
      );
    }
  }

  /// Extract JSON from response (handles markdown code blocks)
  String _extractJson(String text) {
    final jsonPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonPattern.firstMatch(text);
    if (match != null) return match.group(1) ?? text;

    final backtickPattern = RegExp(r'```\s*([\s\S]*?)\s*```');
    final backtickMatch = backtickPattern.firstMatch(text);
    if (backtickMatch != null) return backtickMatch.group(1) ?? text;

    return text;
  }

  /// Build conversation messages for context
  List<Map<String, String>> _buildConversationMessages({
    required String playerMessage,
    required List<ConversationTurn> history,
  }) {
    final messages = <Map<String, String>>[];

    // Add recent history (last 5 turns for context)
    final recentHistory = history.length > 10 ? history.sublist(history.length - 10) : history;

    for (final turn in recentHistory) {
      messages.add({
        'role': turn.speaker.toLowerCase() == 'npc' ? 'assistant' : 'user',
        'content': turn.message,
      });
    }

    // Add current player message
    messages.add({
      'role': 'user',
      'content': playerMessage,
    });

    return messages;
  }

  /// Get fallback response when API fails
  String _getFallbackResponse(NPC npc) {
    final responses = {
      'npc_sarah': "That's great! Can you tell me more about that?",
      'npc_tom': "That sounds interesting! What else?",
      'npc_emily': "I see! Do you have any other questions?",
      'npc_chen': "Wonderful! How can I help you further?",
      'npc_marco': "Bellissimo! Tell me more, please!",
      'npc_lisa': "Nice! Keep going, you're doing well!",
      'npc_david': "Understood! What else would you like to know?",
      'npc_wilson': "Excellent observation! Please continue.",
    };

    return responses[npc.id] ?? "That's wonderful! Please continue.";
  }

  /// Get difficulty description string
  String _getDifficultyDescription(ConversationDifficulty difficulty) {
    switch (difficulty) {
      case ConversationDifficulty.easy:
        return 'Easy (Beginner)';
      case ConversationDifficulty.medium:
        return 'Medium (Intermediate)';
      case ConversationDifficulty.hard:
        return 'Hard (Advanced)';
      case ConversationDifficulty.expert:
        return 'Expert (Fluent)';
    }
  }

  /// Get time of day display string
  String _getTimeOfDayString(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return 'Morning (6 AM - 12 PM)';
      case TimeOfDay.afternoon:
        return 'Afternoon (12 PM - 6 PM)';
      case TimeOfDay.evening:
        return 'Evening (6 PM - 9 PM)';
      case TimeOfDay.night:
        return 'Night (9 PM - 6 AM)';
    }
  }
}
