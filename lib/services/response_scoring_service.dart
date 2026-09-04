import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';

/// 応答スコアリングサービス（シングルトンパターン）
/// ユーザー応答を複数の基準に基づいてスコア化
class ResponseScoringService {
  static final ResponseScoringService _instance =
      ResponseScoringService._internal();

  factory ResponseScoringService() {
    return _instance;
  }

  ResponseScoringService._internal();

  /// シングルトンインスタンスを取得
  static ResponseScoringService getInstance() {
    return _instance;
  }

  // ==================== SCORING ====================

  /// 応答をスコア化（0-100）
  int scoreResponse({
    required String userResponse,
    required ResponseEvaluationCriteria criteria,
    required NPCExtended npc,
    required Map<String, dynamic> validationResults,
    bool wasSuccessful = true,
  }) {
    try {
      double score = 0.0;

      // 基本スコア（100点から開始）
      score = 100.0;

      // バリデーション結果に基づく減点
      score += _applyValidationPenalties(validationResults) * 0.3;

      // 発音精度に基づくスコア
      score += _calculatePronunciationScore(
        userResponse,
        criteria.pronunciationAccuracyThreshold,
      ) * 0.2;

      // コンテンツ品質に基づくスコア
      score += _calculateContentQualityScore(
        userResponse,
        criteria,
      ) * 0.25;

      // NPCの好みに基づくスコア
      score += _calculateNPCPreferenceScore(
        userResponse,
        npc,
      ) * 0.15;

      // 成功/失敗フラグに基づく調整
      if (!wasSuccessful) {
        score *= 0.7; // 失敗した場合は30%減点
      }

      return score.clamp(0, 100).toInt();
    } catch (e) {
      print('Error scoring response: $e');
      return 50; // デフォルトスコア
    }
  }

  /// 難易度調整を含めたスコア化
  int scoreResponseWithDifficulty({
    required String userResponse,
    required ResponseEvaluationCriteria criteria,
    required NPCExtended npc,
    required Map<String, dynamic> validationResults,
    required String difficulty,
    required int playerLevel,
    bool wasSuccessful = true,
  }) {
    try {
      int baseScore = scoreResponse(
        userResponse: userResponse,
        criteria: criteria,
        npc: npc,
        validationResults: validationResults,
        wasSuccessful: wasSuccessful,
      );

      // 難易度ボーナス
      final difficultyModifier = _calculateDifficultyModifier(
        difficulty,
        playerLevel,
      );

      return (baseScore * difficultyModifier).clamp(0, 100).toInt();
    } catch (e) {
      print('Error scoring with difficulty: $e');
      return 50;
    }
  }

  // ==================== SCORING COMPONENTS ====================

  /// バリデーション結果に基づく減点（-100 to 0）
  double _applyValidationPenalties(Map<String, dynamic> validationResults) {
    try {
      double penalty = 0.0;

      // 問題ごとに減点
      final issues = validationResults['issues'] as List<String>?;
      if (issues != null && issues.isNotEmpty) {
        penalty -= (issues.length * 15).toDouble().clamp(0, 50);
      }

      // 警告ごとに減点
      final warnings = validationResults['warnings'] as List<String>?;
      if (warnings != null && warnings.isNotEmpty) {
        penalty -= (warnings.length * 5).toDouble().clamp(0, 20);
      }

      return penalty.clamp(-100, 0);
    } catch (e) {
      return -20.0;
    }
  }

  /// 発音精度スコア（0-100）
  int _calculatePronunciationScore(
    String userResponse,
    double accuracyThreshold,
  ) {
    try {
      // 簡単な発音精度チェック（実装は簡略化）
      // 実際のシステムではSpeech Recognition APIを使用

      // ここではダミー実装：レスポンスの長さと複雑さで判定
      final wordCount = userResponse.split(RegExp(r'\s+')).length;

      if (wordCount == 0) return 0;

      // 単語数に基づいて精度を推定
      double estimatedAccuracy = 0.8; // デフォルト80%

      if (wordCount > 20) estimatedAccuracy = 0.7; // 長いと難しい
      if (wordCount > 30) estimatedAccuracy = 0.6;
      if (wordCount < 3) estimatedAccuracy = 0.9; // 短いと簡単

      return (estimatedAccuracy * 100).toInt();
    } catch (e) {
      return 75;
    }
  }

  /// コンテンツ品質スコア（0-100）
  int _calculateContentQualityScore(
    String userResponse,
    ResponseEvaluationCriteria criteria,
  ) {
    try {
      double qualityScore = 0.0;

      // 単語数スコア
      final wordCount = userResponse.split(RegExp(r'\s+')).length;
      final minWords = criteria.minWordCount;
      final maxWords = criteria.maxWordCount;
      final optimalWords = (minWords + maxWords) / 2;

      if (wordCount >= minWords && wordCount <= maxWords) {
        final distanceFromOptimal = (wordCount - optimalWords).abs();
        qualityScore +=
            100 - (distanceFromOptimal / optimalWords * 100);
      } else if (wordCount < minWords) {
        qualityScore += (wordCount / minWords * 100).clamp(0, 100);
      } else {
        qualityScore +=
            (maxWords / wordCount * 100).clamp(0, 100);
      }

      // 必須キーワードスコア
      final requiredCount = criteria.keywordsMustInclude.length;
      final foundCount = criteria.keywordsMustInclude
          .where((kw) => userResponse.toLowerCase().contains(kw.toLowerCase()))
          .length;

      if (requiredCount > 0) {
        qualityScore += (foundCount / requiredCount * 100);
      }

      // 避けるべき単語スコア
      final avoidedCount = criteria.keywordsToAvoid
          .where((kw) => userResponse.toLowerCase().contains(kw.toLowerCase()))
          .length;

      if (avoidedCount > 0) {
        qualityScore -= (avoidedCount * 10).toDouble().clamp(0, 50);
      }

      return (qualityScore / 2).clamp(0, 100).toInt();
    } catch (e) {
      return 50;
    }
  }

  /// NPC好みスコア（0-100）
  int _calculateNPCPreferenceScore(
    String userResponse,
    NPCExtended npc,
  ) {
    try {
      double score = 50.0; // ニュートラルスコア

      final lowerResponse = userResponse.toLowerCase();

      // 好みのトピックが含まれているか
      for (final topic in npc.personality.preferredTopics) {
        if (lowerResponse.contains(topic.toLowerCase())) {
          score += 15.0;
        }
      }

      // 避けるべきトピックが含まれているか
      for (final topic in npc.personality.avoidedTopics) {
        if (lowerResponse.contains(topic.toLowerCase())) {
          score -= 25.0;
        }
      }

      // NPCの話し方に合わせているか
      if (npc.personality.speakingStyle.contains('formal') &&
          !_containsInformalLanguage(userResponse)) {
        score += 10.0;
      } else if (npc.personality.speakingStyle.contains('casual') &&
          _containsInformalLanguage(userResponse)) {
        score += 10.0;
      }

      return score.clamp(0, 100).toInt();
    } catch (e) {
      return 50;
    }
  }

  /// 難易度モディファイアを計算（0.5-1.5）
  double _calculateDifficultyModifier(
    String difficulty,
    int playerLevel,
  ) {
    try {
      final difficultyLevel = int.tryParse(difficulty) ?? 1;
      final levelDifference = (playerLevel - difficultyLevel).abs();

      if (levelDifference == 0) {
        return 1.0; // 同等のレベル
      } else if (levelDifference == 1) {
        return playerLevel > difficultyLevel
            ? 1.1 // 難易度より高レベル → ボーナス
            : 0.95; // 難易度より低レベル → ペナルティ
      } else if (levelDifference == 2) {
        return playerLevel > difficultyLevel
            ? 1.2 // 著しく高レベル → 大きなボーナス
            : 0.9; // 著しく低レベル → 大きなペナルティ
      } else {
        return playerLevel > difficultyLevel
            ? 1.5 // 最大ボーナス
            : 0.5; // 最小スコア
      }
    } catch (e) {
      return 1.0;
    }
  }

  // ==================== HELPER METHODS ====================

  /// 非形式的な言語が含まれているか
  bool _containsInformalLanguage(String text) {
    try {
      const informalWords = [
        'gonna',
        'wanna',
        'gotta',
        'ain\'t',
        'kinda',
        'sorta',
        'y\'all',
        'dunno',
      ];

      final lowerText = text.toLowerCase();
      return informalWords.any((word) => lowerText.contains(word));
    } catch (e) {
      return false;
    }
  }

  // ==================== SCORE ANALYTICS ====================

  /// スコア分布を分析
  Map<String, dynamic> analyzeScoreDistribution(List<int> scores) {
    try {
      if (scores.isEmpty) {
        return {
          'average': 0.0,
          'minimum': 0,
          'maximum': 0,
          'median': 0.0,
          'standardDeviation': 0.0,
        };
      }

      scores.sort();

      final average = scores.reduce((a, b) => a + b) / scores.length;
      final minimum = scores.first;
      final maximum = scores.last;
      final median =
          scores.length.isOdd
              ? scores[scores.length ~/ 2].toDouble()
              : (scores[scores.length ~/ 2 - 1] +
                  scores[scores.length ~/ 2]) /
                  2;

      // 標準偏差を計算
      final variance = scores
          .map((score) => (score - average) * (score - average))
          .reduce((a, b) => a + b) /
          scores.length;
      final standardDeviation = variance.isFinite ? variance.sqrt() : 0.0;

      return {
        'average': average,
        'minimum': minimum,
        'maximum': maximum,
        'median': median,
        'standardDeviation': standardDeviation,
      };
    } catch (e) {
      print('Error analyzing score distribution: $e');
      return {};
    }
  }

  /// スコア範囲を取得
  String getScoreRange(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Acceptable';
    if (score >= 50) return 'Needs Improvement';
    return 'Poor';
  }

  /// スコアに基づいてフィードバックを生成
  String generateScoreFeedback(
    int score,
    Map<String, dynamic> validationResults,
  ) {
    try {
      final buffer = StringBuffer();

      buffer.writeln('Score: $score/100 (${getScoreRange(score)})');
      buffer.writeln('');

      if (score >= 90) {
        buffer.writeln('Excellent work! Your response was well-structured and comprehensive.');
      } else if (score >= 80) {
        buffer.writeln('Very good! Your response was clear and mostly accurate.');
      } else if (score >= 70) {
        buffer.writeln('Good effort! Your response showed understanding but could be improved.');
      } else if (score >= 60) {
        buffer.writeln('Your response was acceptable but needs more work.');
      } else {
        buffer.writeln('Your response needs significant improvement. Review the feedback below.');
      }

      buffer.writeln('');

      // 具体的なフィードバック
      final issues = validationResults['issues'] as List<String>?;
      if (issues != null && issues.isNotEmpty) {
        buffer.writeln('Areas to Improve:');
        for (final issue in issues) {
          buffer.writeln('  • $issue');
        }
      }

      final suggestions = validationResults['suggestions'] as List<String>?;
      if (suggestions != null && suggestions.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('Tips for Better Responses:');
        for (final suggestion in suggestions) {
          buffer.writeln('  • $suggestion');
        }
      }

      return buffer.toString();
    } catch (e) {
      print('Error generating feedback: $e');
      return 'Unable to generate feedback';
    }
  }
}

// 標準偏差を計算するための拡張
extension NumExtension on double {
  double sqrt() {
    if (this < 0) return 0.0;
    var x = this;
    var prev = 0.0;
    while ((x - prev).abs() > 0.0001) {
      prev = x;
      x = (x + this / x) / 2;
    }
    return x;
  }
}
