import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/models/english_town_model.dart';

/// ダイアログコンテキストビルダーサービス（シングルトンパターン）
/// 会話に必要なコンテキスト情報を収集・構築
class DialogueContextBuilderService {
  static final DialogueContextBuilderService _instance =
      DialogueContextBuilderService._internal();

  factory DialogueContextBuilderService() {
    return _instance;
  }

  DialogueContextBuilderService._internal();

  /// シングルトンインスタンスを取得
  static DialogueContextBuilderService getInstance() {
    return _instance;
  }

  // ==================== CONTEXT BUILDING ====================

  /// 完全なダイアログコンテキストを構築
  DialogueContext buildDialogueContext({
    required NPCExtended npc,
    required String locationId,
    required String playerInput,
    String? currentMood,
    Map<String, dynamic>? relationshipData,
    List<DialogueMessage>? conversationHistory,
    String? weatherEffect,
  }) {
    try {
      final context = DialogueContext(
        npcId: npc.npcId,
        locationId: locationId,
        timeOfDay: _getCurrentTimeOfDay(),
        currentMood: currentMood ?? npc.currentMoodState,
        relationshipData: relationshipData,
        conversationHistory: conversationHistory ?? [],
        weatherEffect: weatherEffect,
        playerInput: playerInput,
      );

      return context;
    } catch (e) {
      print('Error building dialogue context: $e');
      throw Exception('Failed to build dialogue context: $e');
    }
  }

  /// ミニマルなコンテキストを構築（高速化用）
  DialogueContext buildMinimalContext({
    required String npcId,
    required String locationId,
    required String playerInput,
    String? timeOfDay,
  }) {
    try {
      return DialogueContext(
        npcId: npcId,
        locationId: locationId,
        timeOfDay: timeOfDay ?? _getCurrentTimeOfDay(),
        currentMood: 'neutral',
        playerInput: playerInput,
      );
    } catch (e) {
      print('Error building minimal context: $e');
      throw Exception('Failed to build minimal context: $e');
    }
  }

  /// 既存のコンテキストを更新
  DialogueContext updateContext(
    DialogueContext context, {
    String? npcId,
    String? locationId,
    String? timeOfDay,
    String? currentMood,
    Map<String, dynamic>? relationshipData,
    List<DialogueMessage>? conversationHistory,
    String? weatherEffect,
    String? playerInput,
  }) {
    try {
      return context.copyWith(
        npcId: npcId ?? context.npcId,
        locationId: locationId ?? context.locationId,
        timeOfDay: timeOfDay ?? context.timeOfDay,
        currentMood: currentMood ?? context.currentMood,
        relationshipData: relationshipData ?? context.relationshipData,
        conversationHistory: conversationHistory ?? context.conversationHistory,
        weatherEffect: weatherEffect ?? context.weatherEffect,
        playerInput: playerInput ?? context.playerInput,
      );
    } catch (e) {
      print('Error updating context: $e');
      rethrow;
    }
  }

  // ==================== CONTEXT ENRICHMENT ====================

  /// 関係データを充実させる
  Map<String, dynamic> enrichRelationshipData(
    Map<String, dynamic>? existing,
    NPCRelationship relationship,
  ) {
    try {
      final enriched = existing ?? {};

      enriched['affectionLevel'] = relationship.affectionLevel;
      enriched['conversationCount'] = relationship.conversationCount;
      enriched['discoveredTopics'] = relationship.discoveredTopics;
      enriched['currentStreak'] = relationship.currentStreak;
      enriched['maxStreak'] = relationship.maxStreak;
      enriched['lastInteractionAt'] = relationship.lastInteractionAt?.toIso8601String();

      return enriched;
    } catch (e) {
      print('Error enriching relationship data: $e');
      return existing ?? {};
    }
  }

  /// 会話履歴を充実させる
  List<DialogueMessage> enrichConversationHistory(
    List<DialogueMessage>? existing,
    DialogueMessage newMessage,
  ) {
    try {
      final history = existing ?? [];
      return [...history, newMessage];
    } catch (e) {
      print('Error enriching conversation history: $e');
      return existing ?? [];
    }
  }

  /// NPC状態スナップショットを取得
  Map<String, dynamic> captureNPCStateSnapshot(NPCExtended npc) {
    try {
      return {
        'npcId': npc.npcId,
        'currentMoodState': npc.currentMoodState,
        'moodLastUpdatedAt': npc.moodLastUpdatedAt.toIso8601String(),
        'moodDecayRate': npc.moodDecayRate,
        'baseMoodState': npc.baseMoodState,
        'interactionCapability': npc.interactionCapability,
        'learningRate': npc.learningRate,
        'personalityTraits': npc.personality.traits,
        'personalityArchetype': npc.personality.archetype,
        'preferredTopics': npc.personality.preferredTopics,
        'avoidedTopics': npc.personality.avoidedTopics,
        'speakingStyle': npc.personality.speakingStyle,
        'isCurrentlyAvailable': npc.availabilitySchedule.isCurrentlyAvailable(),
      };
    } catch (e) {
      print('Error capturing NPC state: $e');
      return {};
    }
  }

  // ==================== CONTEXT HELPERS ====================

  /// 現在の時間帯を取得（morning/afternoon/evening/night）
  String _getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 21) return 'evening';
    return 'night';
  }

  /// 時間帯に基づくNPCの気分修正を計算
  String adjustMoodByTimeOfDay(
    String baseMood,
    String timeOfDay,
    NPCExtended npc,
  ) {
    try {
      // 時間帯による気分への影響
      const timeOfDayMoodEffects = {
        'morning': {
          'happy': 'excited',
          'neutral': 'happy',
          'tired': 'neutral',
          'excited': 'excited',
          'sad': 'neutral',
          'confused': 'neutral',
        },
        'afternoon': {
          'happy': 'happy',
          'neutral': 'neutral',
          'tired': 'tired',
          'excited': 'happy',
          'sad': 'sad',
          'confused': 'confused',
        },
        'evening': {
          'happy': 'happy',
          'neutral': 'neutral',
          'tired': 'tired',
          'excited': 'happy',
          'sad': 'sad',
          'confused': 'neutral',
        },
        'night': {
          'happy': 'neutral',
          'neutral': 'tired',
          'tired': 'tired',
          'excited': 'happy',
          'sad': 'sad',
          'confused': 'tired',
        },
      };

      final adjustedMood =
          timeOfDayMoodEffects[timeOfDay]?[baseMood] ?? baseMood;

      return adjustedMood;
    } catch (e) {
      print('Error adjusting mood: $e');
      return baseMood;
    }
  }

  /// 天気効果を適用
  String applyWeatherEffect(
    String baseMood,
    String? weatherEffect,
  ) {
    try {
      if (weatherEffect == null) return baseMood;

      const weatherMoodEffects = {
        'sunny': {
          'happy': 'excited',
          'neutral': 'happy',
          'tired': 'neutral',
          'excited': 'excited',
          'sad': 'neutral',
          'confused': 'happy',
        },
        'rainy': {
          'happy': 'neutral',
          'neutral': 'sad',
          'tired': 'tired',
          'excited': 'happy',
          'sad': 'sad',
          'confused': 'confused',
        },
        'cloudy': {
          'happy': 'neutral',
          'neutral': 'neutral',
          'tired': 'tired',
          'excited': 'happy',
          'sad': 'sad',
          'confused': 'confused',
        },
        'snowy': {
          'happy': 'excited',
          'neutral': 'happy',
          'tired': 'neutral',
          'excited': 'excited',
          'sad': 'neutral',
          'confused': 'happy',
        },
      };

      final adjustedMood = weatherMoodEffects[weatherEffect]?[baseMood] ?? baseMood;

      return adjustedMood;
    } catch (e) {
      print('Error applying weather effect: $e');
      return baseMood;
    }
  }

  // ==================== CONTEXT VALIDATION ====================

  /// コンテキストが有効かを検証
  bool validateContext(DialogueContext context) {
    try {
      // 必須フィールドのチェック
      if (context.npcId.isEmpty) {
        print('Invalid context: missing npcId');
        return false;
      }

      if (context.locationId.isEmpty) {
        print('Invalid context: missing locationId');
        return false;
      }

      if (context.timeOfDay.isEmpty) {
        print('Invalid context: missing timeOfDay');
        return false;
      }

      if (context.currentMood.isEmpty) {
        print('Invalid context: missing currentMood');
        return false;
      }

      if (context.playerInput.isEmpty) {
        print('Invalid context: missing playerInput');
        return false;
      }

      // 時間帯の妥当性チェック
      const validTimeOfDays = ['morning', 'afternoon', 'evening', 'night'];
      if (!validTimeOfDays.contains(context.timeOfDay)) {
        print('Invalid context: invalid timeOfDay "${context.timeOfDay}"');
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating context: $e');
      return false;
    }
  }

  /// コンテキストのサニタイズ（不正な値を修正）
  DialogueContext sanitizeContext(DialogueContext context) {
    try {
      var sanitized = context;

      // 時間帯を修正
      const validTimeOfDays = ['morning', 'afternoon', 'evening', 'night'];
      if (!validTimeOfDays.contains(context.timeOfDay)) {
        sanitized = sanitized.copyWith(
          timeOfDay: _getCurrentTimeOfDay(),
        );
      }

      // 気分を修正
      const validMoods = [
        'happy',
        'neutral',
        'tired',
        'excited',
        'sad',
        'confused'
      ];
      if (!validMoods.contains(context.currentMood)) {
        sanitized = sanitized.copyWith(currentMood: 'neutral');
      }

      // プレイヤー入力を修正（空白は削除）
      sanitized = sanitized.copyWith(
        playerInput: context.playerInput.trim(),
      );

      return sanitized;
    } catch (e) {
      print('Error sanitizing context: $e');
      return context;
    }
  }

  // ==================== CONTEXT SERIALIZATION ====================

  /// コンテキストをMapにシリアライズ
  Map<String, dynamic> serializeContext(DialogueContext context) {
    try {
      return {
        'npcId': context.npcId,
        'locationId': context.locationId,
        'timeOfDay': context.timeOfDay,
        'currentMood': context.currentMood,
        'relationshipData': context.relationshipData,
        'conversationHistory': context.conversationHistory
            ?.map((msg) => msg.toJson())
            .toList(),
        'weatherEffect': context.weatherEffect,
        'playerInput': context.playerInput,
      };
    } catch (e) {
      print('Error serializing context: $e');
      return {};
    }
  }

  /// Mapからコンテキストをデシリアライズ
  DialogueContext? deserializeContext(Map<String, dynamic> data) {
    try {
      final history = (data['conversationHistory'] as List?)
          ?.map((msg) => DialogueMessage.fromJson(msg as Map<String, dynamic>))
          .toList();

      return DialogueContext(
        npcId: data['npcId'] as String? ?? '',
        locationId: data['locationId'] as String? ?? '',
        timeOfDay: data['timeOfDay'] as String? ?? 'neutral',
        currentMood: data['currentMood'] as String? ?? 'neutral',
        relationshipData: data['relationshipData'] as Map<String, dynamic>?,
        conversationHistory: history,
        weatherEffect: data['weatherEffect'] as String?,
        playerInput: data['playerInput'] as String? ?? '',
      );
    } catch (e) {
      print('Error deserializing context: $e');
      return null;
    }
  }
}
