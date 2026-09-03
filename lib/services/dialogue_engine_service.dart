import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/models/interaction_history_model.dart';

/// ダイアログエンジンサービス（シングルトンパターン）
/// テンプレート選択、コンテキスト構築、応答生成の調整を管理
class DialogueEngineService {
  static final DialogueEngineService _instance =
      DialogueEngineService._internal();

  factory DialogueEngineService() {
    return _instance;
  }

  DialogueEngineService._internal();

  /// シングルトンインスタンスを取得
  static DialogueEngineService getInstance() {
    return _instance;
  }

  // ==================== TEMPLATE SELECTION ====================

  /// 与えられたコンテキストに基づいて最適なテンプレートを選択
  Future<DialogueTemplate?> selectBestTemplate(
    List<DialogueTemplate> availableTemplates,
    DialogueContext context,
    NPCExtended npc,
  ) async {
    try {
      if (availableTemplates.isEmpty) return null;

      // スコア付けしてベストを選択
      var scoredTemplates = <MapEntry<DialogueTemplate, double>>[];

      for (final template in availableTemplates) {
        double score = 0.0;

        // NPC気分と会話フェーズの相性
        score += _calculateMoodCompatibility(template, npc) * 0.3;

        // 難易度の適切性（低・中・高）
        score += _calculateDifficultyRelevance(template) * 0.2;

        // トピックの興味度
        score += _calculateTopicInterest(template, npc) * 0.3;

        // ストーリー進捗との関連性
        score += _calculateStoryRelevance(template) * 0.2;

        scoredTemplates.add(MapEntry(template, score));
      }

      // スコアが最高のテンプレートを返す
      scoredTemplates.sort((a, b) => b.value.compareTo(a.value));
      return scoredTemplates.isNotEmpty ? scoredTemplates.first.key : null;
    } catch (e) {
      print('Error selecting best template: $e');
      return null;
    }
  }

  /// 難易度に基づいてテンプレートをフィルタリング
  List<DialogueTemplate> filterTemplatesByDifficulty(
    List<DialogueTemplate> templates,
    int playerLevel,
  ) {
    try {
      return templates.where((t) {
        final difficulty = int.tryParse(t.difficulty) ?? 1;
        // プレイヤーレベルに応じた難易度範囲（±1）
        return (difficulty >= (playerLevel - 1)) &&
            (difficulty <= (playerLevel + 1));
      }).toList();
    } catch (e) {
      print('Error filtering templates by difficulty: $e');
      return templates;
    }
  }

  /// トピック別にテンプレートをフィルタリング
  List<DialogueTemplate> filterTemplatesByTopic(
    List<DialogueTemplate> templates,
    String topic,
  ) {
    try {
      return templates.where((t) => t.topic == topic).toList();
    } catch (e) {
      print('Error filtering templates by topic: $e');
      return [];
    }
  }

  /// 会話フェーズ別にテンプレートをフィルタリング
  List<DialogueTemplate> filterTemplatesByPhase(
    List<DialogueTemplate> templates,
    String phase,
  ) {
    try {
      return templates.where((t) => t.conversationPhase == phase).toList();
    } catch (e) {
      print('Error filtering templates by phase: $e');
      return [];
    }
  }

  /// NPCの気分に基づいてテンプレートをフィルタリング
  List<DialogueTemplate> filterTemplatesByMood(
    List<DialogueTemplate> templates,
    String moodState,
  ) {
    try {
      // 気分ごとに適切なテンプレートの特性を定義
      final moodPreferences = {
        'happy': ['friendly', 'humorous', 'adventurous'],
        'neutral': ['analytical', 'serious', 'friendly'],
        'tired': ['friendly', 'casual', 'short'],
        'excited': ['adventurous', 'humorous', 'engaging'],
        'sad': ['friendly', 'supportive', 'understanding'],
        'confused': ['analytical', 'explanatory', 'clear'],
      };

      final preferences = moodPreferences[moodState] ?? [];
      if (preferences.isEmpty) return templates;

      // トピックまたは説明がプリファレンスに該当するテンプレートを返す
      return templates.where((t) {
        final description = '${t.topic} ${t.conversationPhase}';
        return preferences.any((pref) =>
            description.toLowerCase().contains(pref.toLowerCase()));
      }).toList();
    } catch (e) {
      print('Error filtering templates by mood: $e');
      return templates;
    }
  }

  /// 前提条件を満たすテンプレートをフィルタリング
  List<DialogueTemplate> filterTemplatesByPrerequisites(
    List<DialogueTemplate> templates,
    Map<String, dynamic> playerProgress,
  ) {
    try {
      return templates.where((t) {
        if (t.prerequisites == null || t.prerequisites!.isEmpty) {
          return true;
        }

        // すべての前提条件が満たされているかチェック
        return t.prerequisites!.entries.every((entry) {
          final key = entry.key;
          final requiredValue = entry.value;
          final playerValue = playerProgress[key];

          if (playerValue == null) return false;

          if (requiredValue is int && playerValue is int) {
            return playerValue >= requiredValue;
          } else if (requiredValue is String && playerValue is String) {
            return playerValue == requiredValue;
          } else if (requiredValue is List && playerValue is List) {
            return requiredValue
                .every((req) => playerValue.contains(req));
          }

          return playerValue == requiredValue;
        });
      }).toList();
    } catch (e) {
      print('Error filtering templates by prerequisites: $e');
      return templates;
    }
  }

  // ==================== SCORING HELPERS ====================

  /// 気分と会話フェーズの相性スコア（0.0-1.0）
  double _calculateMoodCompatibility(
    DialogueTemplate template,
    NPCExtended npc,
  ) {
    try {
      const moodPhaseCompatibility = {
        'happy': {
          'Greeting': 0.9,
          'Main': 0.8,
          'Climax': 0.7,
          'Resolution': 0.8,
          'Closing': 0.9,
        },
        'neutral': {
          'Greeting': 0.7,
          'Main': 0.9,
          'Climax': 0.8,
          'Resolution': 0.8,
          'Closing': 0.7,
        },
        'tired': {
          'Greeting': 0.6,
          'Main': 0.5,
          'Climax': 0.4,
          'Resolution': 0.7,
          'Closing': 0.8,
        },
        'excited': {
          'Greeting': 0.8,
          'Main': 0.9,
          'Climax': 0.95,
          'Resolution': 0.7,
          'Closing': 0.8,
        },
        'sad': {
          'Greeting': 0.5,
          'Main': 0.6,
          'Climax': 0.7,
          'Resolution': 0.8,
          'Closing': 0.6,
        },
        'confused': {
          'Greeting': 0.6,
          'Main': 0.7,
          'Climax': 0.5,
          'Resolution': 0.9,
          'Closing': 0.6,
        },
      };

      final phase = template.conversationPhase;
      final mood = npc.currentMoodState;
      final compatibility =
          moodPhaseCompatibility[mood]?[phase] ?? 0.5;

      return compatibility as double;
    } catch (e) {
      print('Error calculating mood compatibility: $e');
      return 0.5;
    }
  }

  /// 難易度の適切性スコア（0.0-1.0）
  double _calculateDifficultyRelevance(DialogueTemplate template) {
    try {
      // 全体的な難易度バランスを考慮
      const difficultyWeights = {
        '初級': 0.3,
        'Beginner': 0.3,
        '中級': 0.5,
        'Intermediate': 0.5,
        '上級': 0.8,
        'Advanced': 0.8,
        'エキスパート': 1.0,
        'Expert': 1.0,
      };

      return difficultyWeights[template.difficulty] ?? 0.5 as double;
    } catch (e) {
      print('Error calculating difficulty relevance: $e');
      return 0.5;
    }
  }

  /// トピックの興味度スコア（0.0-1.0）
  double _calculateTopicInterest(
    DialogueTemplate template,
    NPCExtended npc,
  ) {
    try {
      // NPCの好みのトピックをチェック
      if (npc.personality.preferredTopics.contains(template.topic)) {
        return 0.9;
      }

      // NPCの避けるトピックをチェック
      if (npc.personality.avoidedTopics.contains(template.topic)) {
        return 0.1;
      }

      // ニュートラル
      return 0.5;
    } catch (e) {
      print('Error calculating topic interest: $e');
      return 0.5;
    }
  }

  /// ストーリー進捗との関連性スコア（0.0-1.0）
  double _calculateStoryRelevance(DialogueTemplate template) {
    try {
      // ストーリー関連のテンプレートをボーナス
      return template.isStoryRelated ? 0.8 : 0.5;
    } catch (e) {
      print('Error calculating story relevance: $e');
      return 0.5;
    }
  }

  // ==================== CONVERSATION FLOW ====================

  /// 会話の次のフェーズを決定
  String determineNextPhase(
    String currentPhase,
    int turnCount,
  ) {
    try {
      const conversationFlow = {
        'Greeting': 'Main',
        'Main': 'Main', // メインは複数ターン可能
        'Climax': 'Resolution',
        'Resolution': 'Closing',
        'Closing': 'Closing', // クロージング後は終了
      };

      // ターン数に基づいて進行
      if (currentPhase == 'Main' && turnCount >= 3) {
        return 'Climax';
      }

      return conversationFlow[currentPhase] ?? 'Main';
    } catch (e) {
      print('Error determining next phase: $e');
      return 'Main';
    }
  }

  /// 会話を継続すべきかを判定
  bool shouldContinueConversation(
    int turnCount,
    double averageScore,
    String currentPhase,
  ) {
    try {
      // クロージングフェーズなら終了
      if (currentPhase == 'Closing') return false;

      // スコアが極端に低い場合は終了
      if (averageScore < 20.0) return false;

      // 最大ターン数チェック（通常は10ターン程度）
      if (turnCount >= 10) return false;

      return true;
    } catch (e) {
      print('Error checking conversation continuation: $e');
      return false;
    }
  }

  // ==================== INTERACTION TRACKING ====================

  /// インタラクションレコードを作成
  InteractionRecord createInteractionRecord({
    required String recordId,
    required String userId,
    required String npcId,
    required String userInput,
    required String npcResponse,
    required int responseScore,
    required int xpEarned,
    required int coinsEarned,
    required String conversationTopic,
    required String difficulty,
    required bool wasSuccessful,
    String? feedbackProvided,
    String? timeOfDay,
    String? npcMoodAtTime,
  }) {
    try {
      return InteractionRecord(
        recordId: recordId,
        userId: userId,
        npcId: npcId,
        timestamp: DateTime.now(),
        userInput: userInput,
        npcResponse: npcResponse,
        responseScore: responseScore,
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        conversationTopic: conversationTopic,
        difficulty: difficulty,
        wasSuccessful: wasSuccessful,
        feedbackProvided: feedbackProvided,
        timeOfDay: timeOfDay,
        npcMoodAtTime: npcMoodAtTime,
      );
    } catch (e) {
      print('Error creating interaction record: $e');
      rethrow;
    }
  }

  /// セッションメトリクスを計算
  ({
    int totalXPEarned,
    int totalCoinsEarned,
    double averageScore,
  }) calculateSessionMetrics(List<InteractionRecord> records) {
    try {
      if (records.isEmpty) {
        return (totalXPEarned: 0, totalCoinsEarned: 0, averageScore: 0.0);
      }

      final totalXP = records.fold<int>(0, (sum, r) => sum + r.xpEarned);
      final totalCoins =
          records.fold<int>(0, (sum, r) => sum + r.coinsEarned);
      final avgScore = records.fold<int>(0, (sum, r) => sum + r.responseScore) /
          records.length;

      return (
        totalXPEarned: totalXP,
        totalCoinsEarned: totalCoins,
        averageScore: avgScore,
      );
    } catch (e) {
      print('Error calculating session metrics: $e');
      return (totalXPEarned: 0, totalCoinsEarned: 0, averageScore: 0.0);
    }
  }
}
