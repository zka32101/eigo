import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';

/// ダイアログフォールバック提供サービス（シングルトンパターン）
/// Claude APIが利用できない場合のフォールバック応答を提供
class DialogueFallbackProviderService {
  static final DialogueFallbackProviderService _instance =
      DialogueFallbackProviderService._internal();

  factory DialogueFallbackProviderService() {
    return _instance;
  }

  DialogueFallbackProviderService._internal();

  /// シングルトンインスタンスを取得
  static DialogueFallbackProviderService getInstance() {
    return _instance;
  }

  // ==================== FALLBACK RESPONSES ====================

  /// フォールバック応答を提供
  String provideFallbackResponse({
    required NPCExtended npc,
    required DialogueTemplate template,
    required String userInput,
    required String phase,
  }) {
    try {
      // テンプレートに基づいてフォールバック応答を選択
      if (template.responseTemplates.isNotEmpty) {
        return _selectFromTemplate(
          template.responseTemplates,
          userInput,
          npc,
        );
      }

      // フェーズに基づいたフォールバック応答
      return _providePhaseBasedFallback(phase, npc);
    } catch (e) {
      print('Error providing fallback response: $e');
      return _provideGenericFallback(npc);
    }
  }

  /// テンプレートから応答を選択
  String _selectFromTemplate(
    List<String> templates,
    String userInput,
    NPCExtended npc,
  ) {
    try {
      if (templates.isEmpty) return _provideGenericFallback(npc);

      // ユーザー入力に基づいて最適なテンプレートを選択
      var bestTemplate = templates.first;
      var bestScore = 0;

      for (final template in templates) {
        var score = 0;

        // キーワードマッチング
        for (final word in userInput.split(RegExp(r'\s+'))) {
          if (template.toLowerCase().contains(word.toLowerCase())) {
            score++;
          }
        }

        if (score > bestScore) {
          bestScore = score;
          bestTemplate = template;
        }
      }

      return bestTemplate;
    } catch (e) {
      return templates.isNotEmpty
          ? templates.first
          : _provideGenericFallback(npc);
    }
  }

  /// フェーズベースのフォールバック応答
  String _providePhaseBasedFallback(String phase, NPCExtended npc) {
    try {
      const phaseResponses = {
        'Greeting': [
          'Hi there! How are you doing today?',
          'Hello! Nice to meet you. What\'s your name?',
          'Hey! Welcome! How can I help you?',
          'Good to see you! How\'s everything going?',
          'Hello! Ready to have a chat?',
        ],
        'Main': [
          'That\'s interesting! Tell me more about that.',
          'I see. Can you explain that a bit more?',
          'Right, and how did that make you feel?',
          'That sounds great. What happened next?',
          'I understand. What do you think about it?',
        ],
        'Climax': [
          'That\'s a really important point.',
          'This is the key moment, isn\'t it?',
          'So what did you decide to do?',
          'That must have been challenging.',
          'This is where it gets interesting!',
        ],
        'Resolution': [
          'So in the end, everything worked out?',
          'I see how that all came together.',
          'That\'s a good way to wrap it up.',
          'Thanks for sharing that with me.',
          'That really helped me understand.',
        ],
        'Closing': [
          'It was great talking with you!',
          'Thanks for the wonderful conversation!',
          'Glad we could chat today.',
          'See you next time!',
          'Until we talk again, take care!',
        ],
      };

      final responses = phaseResponses[phase] ?? phaseResponses['Main']!;
      return _selectRandomResponse(responses);
    } catch (e) {
      return _provideGenericFallback(npc);
    }
  }

  /// 一般的なフォールバック応答
  String _provideGenericFallback(NPCExtended npc) {
    try {
      const fallbacks = [
        'That\'s interesting! Tell me more.',
        'I see what you mean.',
        'Can you elaborate on that?',
        'What do you think about that?',
        'That sounds great!',
        'I hadn\'t thought about it that way.',
        'Please, go on.',
        'That\'s a good point.',
      ];

      return _selectRandomResponse(fallbacks);
    } catch (e) {
      return 'That\'s interesting. Tell me more.';
    }
  }

  // ==================== RESPONSE SELECTION ====================

  /// ランダムに応答を選択
  String _selectRandomResponse(List<String> responses) {
    try {
      if (responses.isEmpty) return 'I see.';
      final index = DateTime.now().millisecond % responses.length;
      return responses[index];
    } catch (e) {
      return responses.isNotEmpty ? responses.first : 'I see.';
    }
  }

  /// トピックに基づいてフォールバック応答を選択
  String selectFallbackByTopic(
    String topic,
    String userInput,
    NPCExtended npc,
  ) {
    try {
      final topicResponses = {
        'travel': [
          'Where have you been to? I\'d love to hear about your travels!',
          'Travel is wonderful! Do you prefer certain destinations?',
          'What was your favorite trip?',
        ],
        'food': [
          'Do you enjoy cooking? What\'s your favorite dish?',
          'Food is such an interesting topic! What cuisines do you like?',
          'Do you have a favorite restaurant?',
        ],
        'hobbies': [
          'What hobbies do you enjoy in your free time?',
          'Hobbies are great! What do you like to do?',
          'Tell me about your interests!',
        ],
        'family': [
          'Family is important! Tell me about yours.',
          'Do you spend much time with your family?',
          'What are your favorite family moments?',
        ],
      };

      final responses = topicResponses[topic] ??
          topicResponses.values.expand((r) => r).toList();

      return _selectRandomResponse(responses.isNotEmpty
          ? responses
          : ['That\'s interesting! Tell me more.']);
    } catch (e) {
      return _provideGenericFallback(npc);
    }
  }

  // ==================== FALLBACK STRATEGIES ====================

  /// オフラインモード応答を提供
  String provideOfflineModeResponse(
    DialogueTemplate template,
    NPCExtended npc,
  ) {
    try {
      const offlineResponses = [
        'I\'m currently offline, but I\'ll respond when I\'m back online.',
        'It looks like I don\'t have a connection right now. Please try again later.',
        'I\'m not able to respond at the moment, but your message has been noted.',
        'Let me respond to that when I\'m back online.',
      ];

      return _selectRandomResponse(offlineResponses);
    } catch (e) {
      return 'I\'m not available right now. Please try again later.';
    }
  }

  /// レート制限応答を提供
  String provideRateLimitResponse(NPCExtended npc) {
    try {
      const rateLimitResponses = [
        'I\'ve been talking a lot! Let me take a moment and I\'ll respond next.',
        'Give me a second to gather my thoughts.',
        'I need a brief moment to process that.',
        'You\'re asking a lot of questions! Let me think about this one.',
      ];

      return _selectRandomResponse(rateLimitResponses);
    } catch (e) {
      return 'Let me think about that for a moment.';
    }
  }

  /// エラー応答を提供
  String provideErrorResponse(String errorType, NPCExtended npc) {
    try {
      const errorResponses = {
        'validation_error': [
          'I didn\'t quite understand that. Can you rephrase?',
          'Could you say that differently? I\'m not sure I got it.',
          'That doesn\'t quite make sense to me. Could you clarify?',
        ],
        'api_error': [
          'I\'m having trouble processing that right now.',
          'Something went wrong on my end. Try again?',
          'I encountered an error. Please try again.',
        ],
        'timeout_error': [
          'That took too long. Can we try again?',
          'I took too long to respond. Let\'s continue.',
          'That request timed out. Please try again.',
        ],
      };

      final responses =
          errorResponses[errorType] ?? errorResponses['api_error']!;
      return _selectRandomResponse(responses);
    } catch (e) {
      return 'I encountered an error. Please try again.';
    }
  }

  /// タイムアウト応答を提供
  String provideTimeoutResponse(NPCExtended npc) {
    try {
      const timeoutResponses = [
        'That took longer than expected. What were we saying?',
        'Sorry for the delay! Can you remind me what you said?',
        'I\'m back! What was your question?',
      ];

      return _selectRandomResponse(timeoutResponses);
    } catch (e) {
      return 'Sorry for the delay!';
    }
  }

  // ==================== RESPONSE ENHANCEMENT ====================

  /// フォールバック応答を改善（プレースホルダー置換）
  String enhanceFallbackResponse(
    String response,
    String npcName,
    String userInput,
  ) {
    try {
      var enhanced = response;

      // NPC名をプレースホルダーに置換
      enhanced = enhanced.replaceAll('{npc_name}', npcName);

      // ユーザー入力の最初の単語を取得
      final firstWord = userInput.split(RegExp(r'\s+')).first;
      enhanced = enhanced.replaceAll('{topic}', firstWord);

      // 現在の時刻に基づく挨拶
      final hour = DateTime.now().hour;
      String greeting = 'Hello';
      if (hour < 12) {
        greeting = 'Good morning';
      } else if (hour < 18) {
        greeting = 'Good afternoon';
      } else {
        greeting = 'Good evening';
      }
      enhanced = enhanced.replaceAll('{greeting}', greeting);

      return enhanced;
    } catch (e) {
      return response;
    }
  }

  // ==================== FALLBACK QUALITY ====================

  /// フォールバック応答の品質をスコア化（0.0-1.0）
  double evaluateFallbackQuality(String response) {
    try {
      double score = 0.5; // ニュートラル

      // 最小長チェック
      if (response.length > 20) score += 0.1;

      // 質問を含むか
      if (response.contains('?')) score += 0.2;

      // 句読点の適切性
      if (response.endsWith('.') || response.endsWith('!')) score += 0.1;

      // 大文字で開始しているか
      if (response.isNotEmpty && response[0].toUpperCase() == response[0]) {
        score += 0.1;
      }

      // 不自然な表現がないか
      if (!response.contains('would like to') && !response.contains('hereby')) {
        score += 0.1;
      }

      return score.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }
}
