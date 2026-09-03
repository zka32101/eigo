import 'package:json_annotation/json_annotation.dart';

part 'npc_behavior_model.g.dart';

/// NPC性格タイプ
enum PersonalityType {
  cheerful('陽気', 'Cheerful'),
  calm('冷静', 'Calm'),
  timid('臆病', 'Timid'),
  ambitious('野心的', 'Ambitious'),
  kind('親切', 'Kind'),
  sarcastic('皮肉的', 'Sarcastic');

  final String japanese;
  final String english;

  const PersonalityType(this.japanese, this.english);
}

/// NPCムード
enum NPCMood {
  happy('楽しい', 'Happy', 1.5),
  neutral('普通', 'Neutral', 1.0),
  sad('悲しい', 'Sad', 0.7),
  angry('怒っている', 'Angry', 0.5),
  excited('興奮', 'Excited', 1.8),
  tired('疲れている', 'Tired', 0.6);

  final String japanese;
  final String english;
  final double affectionMultiplier;

  const NPCMood(this.japanese, this.english, this.affectionMultiplier);
}

/// 性格特性（Big Five personality traits）
@JsonSerializable()
class PersonalityTraits {
  /// 開放性 (Openness) - 0-100
  final int openness;

  /// 誠実性 (Conscientiousness) - 0-100
  final int conscientiousness;

  /// 外向性 (Extraversion) - 0-100
  final int extraversion;

  /// 協調性 (Agreeableness) - 0-100
  final int agreeableness;

  /// 神経症傾向 (Neuroticism) - 0-100
  final int neuroticism;

  PersonalityTraits({
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
  });

  /// 主要な性格タイプを取得
  PersonalityType getPrimaryType() {
    if (extraversion > 70) {
      return agreeableness > 60 ? PersonalityType.cheerful : PersonalityType.sarcastic;
    } else if (openness > 70) {
      return PersonalityType.ambitious;
    } else if (agreeableness > 70) {
      return PersonalityType.kind;
    } else if (neuroticism > 60) {
      return PersonalityType.timid;
    }
    return PersonalityType.calm;
  }

  factory PersonalityTraits.fromJson(Map<String, dynamic> json) =>
      _$PersonalityTraitsFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityTraitsToJson(this);
}

/// NPCの行動パターン
@JsonSerializable()
class BehaviorPattern {
  /// パターン ID
  final String patternId;

  /// パターン名
  final String name;

  /// 説明
  final String description;

  /// 特定の状況でのNPCの反応
  final String reaction;

  /// 関連する性格特性
  final List<PersonalityType> relatedPersonalities;

  /// 発動条件
  final BehaviorTrigger trigger;

  /// 報酬/ペナルティ
  final BehaviorOutcome outcome;

  BehaviorPattern({
    required this.patternId,
    required this.name,
    required this.description,
    required this.reaction,
    required this.relatedPersonalities,
    required this.trigger,
    required this.outcome,
  });

  factory BehaviorPattern.fromJson(Map<String, dynamic> json) =>
      _$BehaviorPatternFromJson(json);

  Map<String, dynamic> toJson() => _$BehaviorPatternToJson(this);
}

/// 行動トリガー
@JsonSerializable()
class BehaviorTrigger {
  /// トリガータイプ
  final String type; // "affection_level", "mood", "time_of_day", "event", "greeting"

  /// 最小値（必要に応じて）
  final int? minValue;

  /// 最大値（必要に応じて）
  final int? maxValue;

  /// 特定の条件
  final String? condition;

  /// トリガーの確率（0.0-1.0）
  final double probability;

  BehaviorTrigger({
    required this.type,
    this.minValue,
    this.maxValue,
    this.condition,
    this.probability = 1.0,
  });

  factory BehaviorTrigger.fromJson(Map<String, dynamic> json) =>
      _$BehaviorTriggerFromJson(json);

  Map<String, dynamic> toJson() => _$BehaviorTriggerToJson(this);
}

/// 行動の結果
@JsonSerializable()
class BehaviorOutcome {
  /// 親密度変更
  final int affectionChange;

  /// ムード変更
  final String? moodChange;

  /// 特別なダイアログをアンロック
  final String? unlocksDialogue;

  /// イベント発火
  final String? eventId;

  /// 報酬（XP等）
  final int xpReward;

  BehaviorOutcome({
    required this.affectionChange,
    this.moodChange,
    this.unlocksDialogue,
    this.eventId,
    this.xpReward = 0,
  });

  factory BehaviorOutcome.fromJson(Map<String, dynamic> json) =>
      _$BehaviorOutcomeFromJson(json);

  Map<String, dynamic> toJson() => _$BehaviorOutcomeToJson(this);
}

/// NPC行動状態
@JsonSerializable()
class NPCBehaviorState {
  /// NPC ID
  final String npcId;

  /// 性格特性
  final PersonalityTraits personalityTraits;

  /// 現在のムード
  NPCMood currentMood;

  /// 最後のムード変更時刻
  DateTime? lastMoodChangeTime;

  /// 記憶されたインタラクション
  final List<MemorizedInteraction> memorizedInteractions;

  /// 実行された行動パターン
  final List<ExecutedBehavior> executedBehaviors;

  /// 好みのトピック
  final List<String> preferredTopics;

  /// 嫌いなトピック
  final List<String> dislikedTopics;

  /// 習慣（繰り返し行動）
  final List<Habit> habits;

  /// 作成日時
  final DateTime createdAt;

  /// 更新日時
  DateTime updatedAt;

  NPCBehaviorState({
    required this.npcId,
    required this.personalityTraits,
    this.currentMood = NPCMood.neutral,
    this.lastMoodChangeTime,
    this.memorizedInteractions = const [],
    this.executedBehaviors = const [],
    this.preferredTopics = const [],
    this.dislikedTopics = const [],
    this.habits = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 性格タイプを取得
  PersonalityType getPersonalityType() {
    return personalityTraits.getPrimaryType();
  }

  /// ムードに基づいた親密度修正を計算
  double getAffectionModifier() {
    return currentMood.affectionMultiplier;
  }

  /// 反応を生成
  String generateReaction(String context, int affectionScore) {
    final trait = personalityTraits.getPrimaryType();
    final moodPrefix = _getMoodPrefix(currentMood);

    return '$moodPrefix $context (${trait.english})';
  }

  /// インタラクションを記憶
  void memorizeInteraction(MemorizedInteraction interaction) {
    (memorizedInteractions as List<MemorizedInteraction>).add(interaction);
    updatedAt = DateTime.now();
  }

  /// 行動パターンを実行
  void executeBehavior(ExecutedBehavior behavior) {
    (executedBehaviors as List<ExecutedBehavior>).add(behavior);
    updatedAt = DateTime.now();
  }

  /// ムードを変更
  void changeMood(NPCMood newMood) {
    currentMood = newMood;
    lastMoodChangeTime = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// コピー関数
  NPCBehaviorState copyWith({
    String? npcId,
    PersonalityTraits? personalityTraits,
    NPCMood? currentMood,
    DateTime? lastMoodChangeTime,
    List<MemorizedInteraction>? memorizedInteractions,
    List<ExecutedBehavior>? executedBehaviors,
    List<String>? preferredTopics,
    List<String>? dislikedTopics,
    List<Habit>? habits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NPCBehaviorState(
      npcId: npcId ?? this.npcId,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      currentMood: currentMood ?? this.currentMood,
      lastMoodChangeTime: lastMoodChangeTime ?? this.lastMoodChangeTime,
      memorizedInteractions: memorizedInteractions ?? this.memorizedInteractions,
      executedBehaviors: executedBehaviors ?? this.executedBehaviors,
      preferredTopics: preferredTopics ?? this.preferredTopics,
      dislikedTopics: dislikedTopics ?? this.dislikedTopics,
      habits: habits ?? this.habits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String _getMoodPrefix(NPCMood mood) {
    switch (mood) {
      case NPCMood.happy:
        return '😊';
      case NPCMood.neutral:
        return '😐';
      case NPCMood.sad:
        return '😢';
      case NPCMood.angry:
        return '😠';
      case NPCMood.excited:
        return '🤩';
      case NPCMood.tired:
        return '😴';
    }
  }

  factory NPCBehaviorState.fromJson(Map<String, dynamic> json) =>
      _$NPCBehaviorStateFromJson(json);

  Map<String, dynamic> toJson() => _$NPCBehaviorStateToJson(this);
}

/// 記憶されたインタラクション
@JsonSerializable()
class MemorizedInteraction {
  /// インタラクション ID
  final String interactionId;

  /// タイプ（greeting, dialogue, gift, etc）
  final String type;

  /// 説明
  final String description;

  /// 発生時刻
  final DateTime occurredAt;

  /// インタラクションの価値（-100 to 100）
  final int value;

  MemorizedInteraction({
    required this.interactionId,
    required this.type,
    required this.description,
    required this.occurredAt,
    required this.value,
  });

  factory MemorizedInteraction.fromJson(Map<String, dynamic> json) =>
      _$MemorizedInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$MemorizedInteractionToJson(this);
}

/// 実行された行動
@JsonSerializable()
class ExecutedBehavior {
  /// 行動 ID
  final String behaviorId;

  /// 行動名
  final String behaviorName;

  /// 実行時刻
  final DateTime executedAt;

  /// 結果
  final String result;

  ExecutedBehavior({
    required this.behaviorId,
    required this.behaviorName,
    required this.executedAt,
    required this.result,
  });

  factory ExecutedBehavior.fromJson(Map<String, dynamic> json) =>
      _$ExecutedBehaviorFromJson(json);

  Map<String, dynamic> toJson() => _$ExecutedBehaviorToJson(this);
}

/// NPCの習慣
@JsonSerializable()
class Habit {
  /// 習慣 ID
  final String habitId;

  /// 習慣名
  final String name;

  /// 説明
  final String description;

  /// 実行頻度
  final String frequency; // "daily", "weekly", "monthly"

  /// 最後の実行時刻
  DateTime? lastExecutedAt;

  /// 実行回数
  final int executionCount;

  Habit({
    required this.habitId,
    required this.name,
    required this.description,
    required this.frequency,
    this.lastExecutedAt,
    this.executionCount = 0,
  });

  factory Habit.fromJson(Map<String, dynamic> json) =>
      _$HabitFromJson(json);

  Map<String, dynamic> toJson() => _$HabitToJson(this);
}

/// 行動ツリーノード
@JsonSerializable()
class BehaviorTreeNode {
  /// ノード ID
  final String nodeId;

  /// ノードタイプ（selector, sequence, action, condition）
  final String nodeType;

  /// 子ノード
  final List<BehaviorTreeNode>? children;

  /// 実行する行動（actionの場合）
  final BehaviorPattern? action;

  /// 評価条件
  final String? condition;

  BehaviorTreeNode({
    required this.nodeId,
    required this.nodeType,
    this.children,
    this.action,
    this.condition,
  });

  factory BehaviorTreeNode.fromJson(Map<String, dynamic> json) =>
      _$BehaviorTreeNodeFromJson(json);

  Map<String, dynamic> toJson() => _$BehaviorTreeNodeToJson(this);
}
