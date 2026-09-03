import 'package:eigo/models/dialogue_template_model.dart';

/// 応答検証サービス（シングルトンパターン）
/// ユーザー応答が評価基準を満たしているかを検証
class ResponseValidationService {
  static final ResponseValidationService _instance =
      ResponseValidationService._internal();

  factory ResponseValidationService() {
    return _instance;
  }

  ResponseValidationService._internal();

  /// シングルトンインスタンスを取得
  static ResponseValidationService getInstance() {
    return _instance;
  }

  // ==================== RESPONSE VALIDATION ====================

  /// 応答が評価基準を満たしているかを検証
  Map<String, dynamic> validateResponse(
    String userResponse,
    ResponseEvaluationCriteria criteria,
  ) {
    try {
      final results = <String, dynamic>{
        'isValid': true,
        'issues': <String>[],
        'warnings': <String>[],
        'suggestions': <String>[],
      };

      // 単語数チェック
      final wordCount = _countWords(userResponse);
      if (wordCount < criteria.minWordCount) {
        results['isValid'] = false;
        results['issues'].add(
          'Response too short: $wordCount words (minimum ${criteria.minWordCount} required)',
        );
      }
      if (wordCount > criteria.maxWordCount) {
        results['isValid'] = false;
        results['issues'].add(
          'Response too long: $wordCount words (maximum ${criteria.maxWordCount} allowed)',
        );
      }

      // 必須キーワードチェック
      final missingKeywords = _checkMissingKeywords(
        userResponse,
        criteria.keywordsMustInclude,
      );
      if (missingKeywords.isNotEmpty) {
        results['isValid'] = false;
        results['issues'].add(
          'Missing required keywords: ${missingKeywords.join(", ")}',
        );
      }

      // 避けるべき単語チェック
      final unwantedWords = _checkUnwantedWords(
        userResponse,
        criteria.keywordsToAvoid,
      );
      if (unwantedWords.isNotEmpty) {
        results['isValid'] = false;
        results['issues'].add(
          'Contains words to avoid: ${unwantedWords.join(", ")}',
        );
      }

      // 文法ルールチェック
      final grammarIssues = _checkGrammarRules(
        userResponse,
        criteria.grammarRules,
      );
      if (grammarIssues.isNotEmpty) {
        results['issues'].addAll(grammarIssues);
      }

      // 一般的な間違いチェック
      final commonMistakeMatches = _checkCommonMistakes(
        userResponse,
        criteria.commonMistakes,
      );
      if (commonMistakeMatches.isNotEmpty) {
        results['warnings'].addAll(commonMistakeMatches);
      }

      // 提案の例と比較
      _checkAgainstExamples(
        userResponse,
        criteria.perfectResponseExamples,
        results,
      );

      return results;
    } catch (e) {
      print('Error validating response: $e');
      return {
        'isValid': false,
        'issues': ['Error during validation: $e'],
        'warnings': <String>[],
        'suggestions': <String>[],
      };
    }
  }

  // ==================== VALIDATION HELPERS ====================

  /// 単語数をカウント
  int _countWords(String text) {
    try {
      return text.trim().split(RegExp(r'\s+')).length;
    } catch (e) {
      return 0;
    }
  }

  /// 必須キーワードが存在するか確認
  List<String> _checkMissingKeywords(
    String text,
    List<String> requiredKeywords,
  ) {
    try {
      final lowerText = text.toLowerCase();
      final missing = <String>[];

      for (final keyword in requiredKeywords) {
        if (!lowerText.contains(keyword.toLowerCase())) {
          missing.add(keyword);
        }
      }

      return missing;
    } catch (e) {
      return [];
    }
  }

  /// 避けるべき単語が含まれているか確認
  List<String> _checkUnwantedWords(
    String text,
    List<String> unwantedWords,
  ) {
    try {
      final lowerText = text.toLowerCase();
      final found = <String>[];

      for (final word in unwantedWords) {
        if (lowerText.contains(word.toLowerCase())) {
          found.add(word);
        }
      }

      return found;
    } catch (e) {
      return [];
    }
  }

  /// 文法ルールをチェック
  List<String> _checkGrammarRules(
    String text,
    List<String> grammarRules,
  ) {
    try {
      final issues = <String>[];

      for (final rule in grammarRules) {
        // 簡単な文法ルール（例: "no_double_spaces", "must_end_with_period"）
        if (rule == 'no_double_spaces' && text.contains('  ')) {
          issues.add('Double spaces detected');
        } else if (rule == 'must_end_with_period' &&
            !text.trimEnd().endsWith('.')) {
          issues.add('Response must end with a period');
        } else if (rule == 'must_start_uppercase' &&
            text.isNotEmpty &&
            text[0].toLowerCase() == text[0]) {
          issues.add('Response must start with uppercase letter');
        } else if (rule == 'no_exclamation_marks' && text.contains('!')) {
          issues.add('Avoid exclamation marks');
        } else if (rule == 'proper_capitalization') {
          // 簡単な大文字チェック
          final properNouns = <String>[];
          // 実装は複雑なため、基本的なチェックのみ
          if (text.contains('i ') && !text.contains('I ')) {
            issues.add('Use capital "I" for first person');
          }
        }
      }

      return issues;
    } catch (e) {
      return [];
    }
  }

  /// 一般的な間違いをチェック
  List<String> _checkCommonMistakes(
    String text,
    List<String> commonMistakes,
  ) {
    try {
      final matches = <String>[];
      final lowerText = text.toLowerCase();

      for (final mistake in commonMistakes) {
        if (lowerText.contains(mistake.toLowerCase())) {
          matches.add(
            'Common mistake detected: "$mistake" - consider revising',
          );
        }
      }

      return matches;
    } catch (e) {
      return [];
    }
  }

  /// 完璧な応答の例と比較
  void _checkAgainstExamples(
    String text,
    List<String> perfectExamples,
    Map<String, dynamic> results,
  ) {
    try {
      if (perfectExamples.isEmpty) return;

      // テキストの類似度を簡単に計算
      double bestSimilarity = 0.0;
      String? bestExample;

      for (final example in perfectExamples) {
        final similarity = _calculateSimilarity(text, example);
        if (similarity > bestSimilarity) {
          bestSimilarity = similarity;
          bestExample = example;
        }
      }

      // 高い類似度（>0.7）なら提案
      if (bestSimilarity > 0.7 && bestExample != null) {
        results['suggestions'].add(
          'Your response is similar to this example: "$bestExample"',
        );
      } else if (bestSimilarity < 0.3) {
        results['suggestions'].add(
          'Consider the structure: "${perfectExamples.first}"',
        );
      }
    } catch (e) {
      print('Error checking examples: $e');
    }
  }

  /// 2つのテキスト間の類似度を計算（0.0-1.0）
  double _calculateSimilarity(String text1, String text2) {
    try {
      final words1 = text1.toLowerCase().split(RegExp(r'\s+'));
      final words2 = text2.toLowerCase().split(RegExp(r'\s+'));

      final common = words1
          .where((w) => words2.contains(w))
          .length;
      final total = (words1.length + words2.length) / 2;

      return total == 0 ? 0.0 : (common / total);
    } catch (e) {
      return 0.0;
    }
  }

  // ==================== RESPONSE QUALITY ====================

  /// 応答の複雑さをスコア化（0.0-1.0）
  double analyzeComplexity(String text) {
    try {
      final wordCount = _countWords(text);
      final sentenceCount = text.split(RegExp(r'[.!?]+')).length;
      final avgWordsPerSentence =
          sentenceCount > 0 ? wordCount / sentenceCount : 0;

      // 複雑さ：文が長く、単語が多いほど複雑
      if (avgWordsPerSentence > 20) return 1.0;
      if (avgWordsPerSentence > 15) return 0.8;
      if (avgWordsPerSentence > 10) return 0.6;
      if (avgWordsPerSentence > 5) return 0.4;
      return 0.2;
    } catch (e) {
      return 0.5;
    }
  }

  /// 応答の詳細さをスコア化（0.0-1.0）
  double analyzeDetailLevel(String text) {
    try {
      final wordCount = _countWords(text);
      final sentenceCount = text.split(RegExp(r'[.!?]+')).length;

      // 詳細さ：ワード数とセンテンス数で判定
      if (wordCount > 100) return 1.0;
      if (wordCount > 75) return 0.8;
      if (wordCount > 50) return 0.6;
      if (wordCount > 25) return 0.4;
      return 0.2;
    } catch (e) {
      return 0.5;
    }
  }

  /// 応答の流暢さをスコア化（0.0-1.0）
  double analyzeFluency(String text) {
    try {
      // 流暢さ：単語間の空白が適切か、句読点が適切か
      var score = 1.0;

      // 二重スペース
      if (text.contains('  ')) score -= 0.2;

      // 句読点の適切性
      final punctuationCount =
          '.!?,;:'.split('').fold<int>(0, (sum, p) => sum + p.allMatches(text).length);
      if (punctuationCount == 0) score -= 0.3;

      // 不適切な句読点の配置
      if (text.startsWith(',') || text.startsWith('.')) score -= 0.2;

      return score.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  // ==================== VALIDATION REPORT ====================

  /// 検証レポートを生成
  String generateValidationReport(
    Map<String, dynamic> validationResults,
    String userResponse,
  ) {
    try {
      final buffer = StringBuffer();

      buffer.writeln('=== Response Validation Report ===');
      buffer.writeln('');

      // 基本的な有効性
      final isValid = validationResults['isValid'] as bool;
      buffer.writeln('Overall Status: ${isValid ? "✓ VALID" : "✗ INVALID"}');
      buffer.writeln('Response: "$userResponse"');
      buffer.writeln('');

      // 問題点
      final issues = validationResults['issues'] as List<String>;
      if (issues.isNotEmpty) {
        buffer.writeln('Issues (${issues.length}):');
        for (final issue in issues) {
          buffer.writeln('  • $issue');
        }
        buffer.writeln('');
      }

      // 警告
      final warnings = validationResults['warnings'] as List<String>;
      if (warnings.isNotEmpty) {
        buffer.writeln('Warnings (${warnings.length}):');
        for (final warning in warnings) {
          buffer.writeln('  • $warning');
        }
        buffer.writeln('');
      }

      // 提案
      final suggestions = validationResults['suggestions'] as List<String>;
      if (suggestions.isNotEmpty) {
        buffer.writeln('Suggestions (${suggestions.length}):');
        for (final suggestion in suggestions) {
          buffer.writeln('  • $suggestion');
        }
        buffer.writeln('');
      }

      // 分析
      final complexity = analyzeComplexity(userResponse);
      final detailLevel = analyzeDetailLevel(userResponse);
      final fluency = analyzeFluency(userResponse);

      buffer.writeln('Quality Analysis:');
      buffer.writeln('  • Complexity: ${(complexity * 100).toStringAsFixed(1)}%');
      buffer.writeln('  • Detail Level: ${(detailLevel * 100).toStringAsFixed(1)}%');
      buffer.writeln('  • Fluency: ${(fluency * 100).toStringAsFixed(1)}%');

      return buffer.toString();
    } catch (e) {
      print('Error generating validation report: $e');
      return 'Error generating report';
    }
  }
}
