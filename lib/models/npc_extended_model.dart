import 'package:json_annotation/json_annotation.dart';

part 'npc_extended_model.g.dart';

/// NPC性格特性
enum NPCPersonalityTrait {
  friendly('親友的', 'Friendly', '😊'),
  serious('真面目', 'Serious', '😐'),
  humorous('ユーモア好き', 'Humorous', '😄'),
  analytical('分析的', 'Analytical', '🤔'),
  adventurous('冒険好き', 'Adventurous', '🤩'),
  cautious('慎重', 'Cautious', '😰');

  final String japanese;
  final String english;
  final String emoji;

  const NPCPersonalityTrait(this.japanese, this.english, this.emoji);
}

/// NPC性格アーキタイプ
enum NPCPersonalityArchetype {
  mentor('メンター', 'Mentor', 'Teacher-like, educational focus'),
  friend('友人', 'Friend', 'Peer-like, casual conversation'),
  authority('権威者', 'Authority', 'Professional, formal interaction'),
  character('キャラクター', 'Character', 'Unique personality, story-focused');

  final String japanese;
  final String english;
  final String description;

  const NPCPersonalityArchetype(this.japanese, this.english, this.description);
}

/// NPC気分状態
enum NPCMoodState {
  happy('幸せ', 'Happy', '😊'),
  neutral('中立', 'Neutral', '😐'),
  tired('疲れた', 'Tired', '😴'),
  excited('興奮', 'Excited', '🤩'),
  sad('悲しい', 'Sad', '😢'),
  confused('戸惑い', 'Confused', '😕');

  final String japanese;
  final String english;
  final String emoji;

  const NPCMoodState(this.japanese, this.english, this.emoji);
}

/// NPC性格定義
@JsonSerializable()
class NPCPersonality {
  /// 性格特性リスト
  final List<String> traits; // NPCPersonalityTrait names

  /// 性格アーキタイプ
  final String archetype; // NPCPersonalityArchetype name

  /// NPC伝記/背景
  final String biography;

  /// 関心事
  final List<String> interests;

  /// 感情状態（感情名 -> レベル 0-100）
  final Map<String, int> emotionalState;

  /// 話し方（フォーマル、カジュアル、ユーモアなど）
  final String speakingStyle;

  /// 好みのトピック
  final List<String> preferredTopics;

  /// 避けるべきトピック
  final List<String> avoidedTopics;

  /// 性格説明プロンプト（Claude用）
  final String personalityPrompt;

  NPCPersonality({
    required this.traits,
    required this.archetype,
    required this.biography,
    required this.interests,
    required this.emotionalState,
    required this.speakingStyle,
    required this.preferredTopics,
    required this.avoidedTopics,
    required this.personalityPrompt,
  });

  /// copyWith メソッド
  NPCPersonality copyWith({
    List<String>? traits,
    String? archetype,
    String? biography,
    List<String>? interests,
    Map<String, int>? emotionalState,
    String? speakingStyle,
    List<String>? preferredTopics,
    List<String>? avoidedTopics,
    String? personalityPrompt,
  }) {
    return NPCPersonality(
      traits: traits ?? this.traits,
      archetype: archetype ?? this.archetype,
      biography: biography ?? this.biography,
      interests: interests ?? this.interests,
      emotionalState: emotionalState ?? this.emotionalState,
      speakingStyle: speakingStyle ?? this.speakingStyle,
      preferredTopics: preferredTopics ?? this.preferredTopics,
      avoidedTopics: avoidedTopics ?? this.avoidedTopics,
      personalityPrompt: personalityPrompt ?? this.personalityPrompt,
    );
  }

  factory NPCPersonality.fromJson(Map<String, dynamic> json) =>
      _$NPCPersonalityFromJson(json);

  Map<String, dynamic> toJson() => _$NPCPersonalityToJson(this);
}

/// NPC利用可能スケジュール
@JsonSerializable()
class NPCAvailabilitySchedule {
  /// 時間帯別の利用可能性
  final Map<String, bool> availabilityByTimeOfDay; // morning, afternoon, evening, night

  /// 好みの時間帯
  final List<String> preferredTimes;

  /// 忙しい時間帯
  final List<String> busyTimes;

  /// 曜日別の利用可能性（0=日～6=土）
  final Map<int, bool> availabilityByDayOfWeek;

  /// クールダウン期間（分）
  final int cooldownMinutes;

  /// 最後の会話後の利用可能時間（分）
  final int minTimeBetweenConversations;

  NPCAvailabilitySchedule({
    required this.availabilityByTimeOfDay,
    required this.preferredTimes,
    required this.busyTimes,
    required this.availabilityByDayOfWeek,
    required this.cooldownMinutes,
    required this.minTimeBetweenConversations,
  });

  /// 現在利用可能かチェック
  bool isCurrentlyAvailable() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday % 7;

    // 曜日チェック
    if (!(availabilityByDayOfWeek[dayOfWeek] ?? true)) {
      return false;
    }

    // 時間帯チェック
    final timeOfDay = _getTimeOfDay(hour);
    return availabilityByTimeOfDay[timeOfDay] ?? true;
  }

  /// 時間帯を取得
  String _getTimeOfDay(int hour) {
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 21) return 'evening';
    return 'night';
  }

  /// copyWith メソッド
  NPCAvailabilitySchedule copyWith({
    Map<String, bool>? availabilityByTimeOfDay,
    List<String>? preferredTimes,
    List<String>? busyTimes,
    Map<int, bool>? availabilityByDayOfWeek,
    int? cooldownMinutes,
    int? minTimeBetweenConversations,
  }) {
    return NPCAvailabilitySchedule(
      availabilityByTimeOfDay:
          availabilityByTimeOfDay ?? this.availabilityByTimeOfDay,
      preferredTimes: preferredTimes ?? this.preferredTimes,
      busyTimes: busyTimes ?? this.busyTimes,
      availabilityByDayOfWeek:
          availabilityByDayOfWeek ?? this.availabilityByDayOfWeek,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      minTimeBetweenConversations:
          minTimeBetweenConversations ?? this.minTimeBetweenConversations,
    );
  }

  factory NPCAvailabilitySchedule.fromJson(Map<String, dynamic> json) =>
      _$NPCAvailabilityScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$NPCAvailabilityScheduleToJson(this);
}

/// NPC-ユーザー関係
@JsonSerializable()
class NPCRelationship {
  /// ユーザーID
  final String userId;

  /// NPC ID
  final String npcId;

  /// 親密度レベル（0-100）
  final int affectionLevel;

  /// 会話数
  final int conversationCount;

  /// 発見されたトピック
  final List<String> discoveredTopics;

  /// 会話履歴（トピック -> 回数）
  final Map<String, int> conversationHistory;

  /// 最後のインタラクション時刻
  final DateTime? lastInteractionAt;

  /// 現在のストリーク（連続会話日数）
  final int currentStreak;

  /// 最高ストリーク
  final int maxStreak;

  /// 関係エピソード（重要なマイルストーン）
  final List<String> relationshipEpisodes;

  /// 獲得したバッジ（この NPC との関係で）
  final List<String> earnedBadgesWithNPC;

  NPCRelationship({
    required this.userId,
    required this.npcId,
    required this.affectionLevel,
    required this.conversationCount,
    required this.discoveredTopics,
    required this.conversationHistory,
    this.lastInteractionAt,
    required this.currentStreak,
    required this.maxStreak,
    required this.relationshipEpisodes,
    required this.earnedBadgesWithNPC,
  });

  /// copyWith メソッド
  NPCRelationship copyWith({
    String? userId,
    String? npcId,
    int? affectionLevel,
    int? conversationCount,
    List<String>? discoveredTopics,
    Map<String, int>? conversationHistory,
    DateTime? lastInteractionAt,
    int? currentStreak,
    int? maxStreak,
    List<String>? relationshipEpisodes,
    List<String>? earnedBadgesWithNPC,
  }) {
    return NPCRelationship(
      userId: userId ?? this.userId,
      npcId: npcId ?? this.npcId,
      affectionLevel: affectionLevel ?? this.affectionLevel,
      conversationCount: conversationCount ?? this.conversationCount,
      discoveredTopics: discoveredTopics ?? this.discoveredTopics,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      relationshipEpisodes:
          relationshipEpisodes ?? this.relationshipEpisodes,
      earnedBadgesWithNPC: earnedBadgesWithNPC ?? this.earnedBadgesWithNPC,
    );
  }

  factory NPCRelationship.fromJson(Map<String, dynamic> json) =>
      _$NPCRelationshipFromJson(json);

  Map<String, dynamic> toJson() => _$NPCRelationshipToJson(this);
}

/// NPC拡張データ（既存NPCクラスに統合可能）
@JsonSerializable()
class NPCExtended {
  /// ベースNPC ID
  final String npcId;

  /// 性格定義
  final NPCPersonality personality;

  /// 利用可能スケジュール
  final NPCAvailabilitySchedule availabilitySchedule;

  /// 現在の気分
  final String currentMoodState; // NPCMoodState name

  /// 気分最後更新時刻
  final DateTime moodLastUpdatedAt;

  /// 気分減衰率（毎時間の減衰パーセンテージ）
  final double moodDecayRate;

  /// 基本気分（リセット時の気分）
  final String baseMoodState; // NPCMoodState name

  /// インタラクション能力（0-100、高いほど詳細な会話可能）
  final int interactionCapability;

  /// 学習能力（プレイヤーの進捗でこの値が上昇）
  final double learningRate;

  NPCExtended({
    required this.npcId,
    required this.personality,
    required this.availabilitySchedule,
    required this.currentMoodState,
    required this.moodLastUpdatedAt,
    required this.moodDecayRate,
    required this.baseMoodState,
    required this.interactionCapability,
    required this.learningRate,
  });

  /// copyWith メソッド
  NPCExtended copyWith({
    String? npcId,
    NPCPersonality? personality,
    NPCAvailabilitySchedule? availabilitySchedule,
    String? currentMoodState,
    DateTime? moodLastUpdatedAt,
    double? moodDecayRate,
    String? baseMoodState,
    int? interactionCapability,
    double? learningRate,
  }) {
    return NPCExtended(
      npcId: npcId ?? this.npcId,
      personality: personality ?? this.personality,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      currentMoodState: currentMoodState ?? this.currentMoodState,
      moodLastUpdatedAt: moodLastUpdatedAt ?? this.moodLastUpdatedAt,
      moodDecayRate: moodDecayRate ?? this.moodDecayRate,
      baseMoodState: baseMoodState ?? this.baseMoodState,
      interactionCapability:
          interactionCapability ?? this.interactionCapability,
      learningRate: learningRate ?? this.learningRate,
    );
  }

  factory NPCExtended.fromJson(Map<String, dynamic> json) =>
      _$NPCExtendedFromJson(json);

  Map<String, dynamic> toJson() => _$NPCExtendedToJson(this);
}
