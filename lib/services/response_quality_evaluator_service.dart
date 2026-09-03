import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';

/// 応答品質評価サービス（シングルトンパターン）
/// Claude生成の応答が要件を満たしているかを評価
class ResponseQualityEvaluatorService {
  static final ResponseQualityEvaluatorService _instance =
      ResponseQualityEvaluatorService._internal();

  factory ResponseQualityEvaluatorService() {
    return _instance;
  }

  ResponseQualityEvaluatorService._internal();

  /// シングルトンインスタンスを取得
  static ResponseQualityEvaluatorService getInstance() {
    return _instance;
  }

  // ==================== QUALITY EVALUATION ====================

  /// 応答品質を評価（0.0-1.0）
  double evaluateResponseQuality(
    String response,
    DialogueTemplate template,
    NPCExtended npc,
  ) {
    try {
      double qualityScore = 0.0;

      // 関連性スコア
      qualityScore +=
          _evaluateRelevance(response, template, npc) * 0.25;

      // 自然性スコア
      qualityScore += _evaluateNaturalness(response) * 0.25;

      // 文法・句読点スコア
      qualityScore += _evaluateGrammar(response) * 0.2;

      // トピック適合スコア
      qualityScore += _evaluateTopicAlignment(response, template) * 0.15;

      // NPCキャラクター一貫性スコア
      qualityScore +=
          _evaluateCharacterConsistency(response, npc) * 0.15;

      return qualityScore.clamp(0.0, 1.0);
    } catch (e) {
      print('Error evaluating response quality: $e');
      return 0.5;
    }
  }

  // ==================== EVALUATION COMPONENTS ====================

  /// 関連性スコア（0.0-1.0）
  double _evaluateRelevance(
    String response,
    DialogueTemplate template,
    NPCExtended npc,
  ) {
    try {
      double score = 0.5; // ニュートラルスコート

      // テンプレートの必須キーワードを含むか
      final criteria = template.evaluationCriteria;
      final lowerResponse = response.toLowerCase();
      var keywordMatchCount = 0;

      for (final keyword in criteria.keywordsMustInclude) {
        if (lowerResponse.contains(keyword.toLowerCase())) {
          keywordMatchCount++;
        }
      }

      if (criteria.keywordsMustInclude.isNotEmpty) {
        score =
            keywordMatchCount / criteria.keywordsMustInclude.length;
      }

      // テンプレートの避けるべきキーワードを含まないか
      for (final keyword in criteria.keywordsToAvoid) {
        if (lowerResponse.contains(keyword.toLowerCase())) {
          score *= 0.5; // 避けるべきキーワード発見で50%減点
        }
      }

      return score.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  /// 自然性スコア（0.0-1.0）
  double _evaluateNaturalness(String response) {
    try {
      double score = 1.0;

      // 不自然な表現を検出
      const unnatural = [
        'i will',
        'i shall',
        'hereby',
        'therefore',
        'upon',
        'henceforth',
      ];

      final lowerResponse = response.toLowerCase();
      for (final phrase in unnatural) {
        if (lowerResponse.contains(phrase)) {
          score -= 0.1;
        }
      }

      // 繰り返しを検出
      final words = response.split(RegExp(r'\s+'));
      if (words.length > 5) {
        final uniqueWords = words.toSet();
        final repetitionRatio = uniqueWords.length / words.length;
        if (repetitionRatio < 0.5) {
          score *= 0.7; // 多くの繰り返し
        }
      }

      // 質問を含むか
      if (response.contains('?')) {
        score += 0.1; // 質問を含むと自然
      }

      return score.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  /// 文法・句読点スコア（0.0-1.0）
  double _evaluateGrammar(String response) {
    try {
      double score = 1.0;

      // 句読点チェック
      if (!response.endsWith('.') &&
          !response.endsWith('!') &&
          !response.endsWith('?')) {
        score -= 0.2;
      }

      // 大文字チェック
      if (response.isNotEmpty && response[0].toUpperCase() != response[0]) {
        score -= 0.15;
      }

      // 二重スペースチェック
      if (response.contains('  ')) {
        score -= 0.1;
      }

      // 不正な句読点パターンをチェック
      if (response.startsWith(',') ||
          response.startsWith('.') ||
          response.startsWith('!')) {
        score -= 0.15;
      }

      // 連続する句読点
      if (response.contains('..') || response.contains('!!')) {
        score -= 0.1;
      }

      return score.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  /// トピック適合スコア（0.0-1.0）
  double _evaluateTopicAlignment(
    String response,
    DialogueTemplate template,
  ) {
    try {
      double score = 0.5; // ニュートラル

      final lowerResponse = response.toLowerCase();
      final topic = template.topic.toLowerCase();

      // トピックキーワードが含まれているか
      if (lowerResponse.contains(topic)) {
        score += 0.3;
      }

      // フォローアップ質問のキーワードが含まれているか
      for (final question in template.followUpQuestions) {
        if (lowerResponse.contains(question.toLowerCase())) {
          score += 0.1;
        }
      }

      // 文脈的な適合性（フェーズ別）
      const phaseKeywords = {
        'Greeting': ['hello', 'hi', 'welcome', 'nice', 'meet', 'today'],
        'Main': ['think', 'about', 'tell', 'say', 'question', 'idea'],
        'Climax': ['important', 'really', 'key', 'crucial', 'significant'],
        'Resolution': ['agree', 'understand', 'great', 'well', 'good'],
        'Closing': ['bye', 'goodbye', 'see', 'take care', 'later'],
      };

      final keywords = phaseKeywords[template.conversationPhase] ?? [];
      for (final keyword in keywords) {
        if (lowerResponse.contains(keyword)) {
          score += 0.05;
        }
      }

      return score.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  /// NPCキャラクター一貫性スコア（0.0-1.0）
  double _evaluateCharacterConsistency(
    String response,
    NPCExtended npc,
  ) {
    try {
      double score = 0.5; // ニュートラル

      final lowerResponse = response.toLowerCase();

      // 話し方の一貫性
      if (npc.personality.speakingStyle.contains('formal')) {
        // フォーマルな話し方
        if (lowerResponse.contains('please') ||
            lowerResponse.contains('would') ||
            lowerResponse.contains('could')) {
          score += 0.2;
        }
        // カジュアルな表現は減点
        if (lowerResponse.contains('hey') ||
            lowerResponse.contains('gonna') ||
            lowerResponse.contains('wanna')) {
          score -= 0.2;
        }
      } else if (npc.personality.speakingStyle.contains('casual')) {
        // カジュアルな話し方
        if (lowerResponse.contains("don't") ||
            lowerResponse.contains("it's") ||
            lowerResponse.contains("yeah")) {
          score += 0.2;
        }
      }

      // 好みのトピックを含むか
      for (final topic in npc.personality.preferredTopics) {
        if (lowerResponse.contains(topic.toLowerCase())) {
          score += 0.15;
        }
      }

      // 避けるべきトピックを含まないか
      for (final topic in npc.personality.avoidedTopics) {
        if (lowerResponse.contains(topic.toLowerCase())) {
          score -= 0.2;
        }
      }

      // トレイト別評価
      if (npc.personality.traits.contains('humorous')) {
        if (_containsHumor(response)) {
          score += 0.15;
        }
      }

      if (npc.personality.traits.contains('serious')) {
        if (_containsSerious(response)) {
          score += 0.15;
        }
      }

      return score.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  // ==================== HELPER METHODS ====================

  /// ユーモアを含むか判定
  bool _containsHumor(String text) {
    try {
      const humorIndicators = [
        'haha',
        'hehe',
        'lol',
        'funny',
        'joke',
        'laugh',
        'silly',
      ];
      final lowerText = text.toLowerCase();
      return humorIndicators.any((indicator) => lowerText.contains(indicator));
    } catch (e) {
      return false;
    }
  }

  /// 真面目な表現を含むか判定
  bool _containsSerious(String text) {
    try {
      const seriousIndicators = [
        'important',
        'serious',
        'critical',
        'significant',
        'essential',
        'must',
        'should',
      ];
      final lowerText = text.toLowerCase();
      return seriousIndicators.any((indicator) => lowerText.contains(indicator));
    } catch (e) {
      return false;
    }
  }

  // ==================== QUALITY REPORT ====================

  /// 品質評価レポートを生成
  String generateQualityReport(
    String response,
    DialogueTemplate template,
    NPCExtended npc,
    double qualityScore,
  ) {
    try {
      final buffer = StringBuffer();

      buffer.writeln('=== Response Quality Report ===');
      buffer.writeln('');

      // 全体的な品質
      buffer.writeln('Overall Quality: ${(qualityScore * 100).toStringAsFixed(1)}%');
      _addQualityGrade(buffer, qualityScore);
      buffer.writeln('');

      // コンポーネント別スコア
      buffer.writeln('Component Analysis:');
      buffer.writeln(
        '  Relevance: ${(_evaluateRelevance(response, template, npc) * 100).toStringAsFixed(1)}%',
      );
      buffer.writeln(
        '  Naturalness: ${(_evaluateNaturalness(response) * 100).toStringAsFixed(1)}%',
      );
      buffer.writeln(
        '  Grammar: ${(_evaluateGrammar(response) * 100).toStringAsFixed(1)}%',
      );
      buffer.writeln(
        '  Topic Alignment: ${(_evaluateTopicAlignment(response, template) * 100).toStringAsFixed(1)}%',
      );
      buffer.writeln(
        '  Character Consistency: ${(_evaluateCharacterConsistency(response, npc) * 100).toStringAsFixed(1)}%',
      );
      buffer.writeln('');

      // 応答情報
      buffer.writeln('Response Information:');
      buffer.writeln('  Length: ${response.length} characters');
      buffer.writeln('  Word Count: ${response.split(RegExp(r'\\s+')).length}');
      buffer.writeln('  Sentences: ${response.split(RegExp(r'[.!?]+')).length}');

      return buffer.toString();
    } catch (e) {
      print('Error generating quality report: $e');
      return 'Unable to generate quality report';
    }
  }

  /// 品質スコアに基づいてグレードを追加
  void _addQualityGrade(StringBuffer buffer, double score) {
    if (score >= 0.9) {
      buffer.writeln('Grade: ★★★★★ (Excellent)');
    } else if (score >= 0.8) {
      buffer.writeln('Grade: ★★★★☆ (Very Good)');
    } else if (score >= 0.7) {
      buffer.writeln('Grade: ★★★☆☆ (Good)');
    } else if (score >= 0.6) {
      buffer.writeln('Grade: ★★☆☆☆ (Acceptable)');
    } else if (score >= 0.5) {
      buffer.writeln('Grade: ★☆☆☆☆ (Below Average)');
    } else {
      buffer.writeln('Grade: ☆☆☆☆☆ (Poor)');
    }
  }

  // ==================== QUALITY THRESHOLD ====================

  /// 応答が品質基準を満たしているか
  bool meetsQualityThreshold(
    String response,
    DialogueTemplate template,
    NPCExtended npc,
    double threshold = 0.65,
  ) {
    try {
      final score = evaluateResponseQuality(response, template, npc);
      return score >= threshold;
    } catch (e) {
      print('Error checking quality threshold: $e');
      return false;
    }
  }
}
