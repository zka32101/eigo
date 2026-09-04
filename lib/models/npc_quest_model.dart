import 'package:json_annotation/json_annotation.dart';
import 'package:eigo/models/npc_event_model.dart';

part 'npc_quest_model.g.dart';

/// クエストステータス
enum QuestStatus {
  available('利用可能', 'Available'),
  accepted('受け入れ', 'Accepted'),
  in_progress('進行中', 'In Progress'),
  completed('完了', 'Completed'),
  failed('失敗', 'Failed'),
  abandoned('放棄', 'Abandoned');

  final String japanese;
  final String english;

  const QuestStatus(this.japanese, this.english);
}

/// クエストリワード
@JsonSerializable()
class QuestReward {
  /// 経験値報酬
  final int xpReward;

  /// ゴールド報酬
  final int goldReward;

  /// アイテム報酬
  final Map<String, int>? itemRewards;

  /// 親密度報酬
  final int affectionBonus;

  /// スキル報酬
  final List<String>? skillRewards;

  /// ロケーション解放
  final List<String>? locationUnlocks;

  /// ストーリーフラグ
  final Map<String, bool>? storyFlags;

  QuestReward({
    required this.xpReward,
    required this.goldReward,
    this.itemRewards,
    this.affectionBonus = 0,
    this.skillRewards,
    this.locationUnlocks,
    this.storyFlags,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) =>
      _$QuestRewardFromJson(json);

  Map<String, dynamic> toJson() => _$QuestRewardToJson(this);
}

/// クエスト条件
@JsonSerializable()
class QuestCondition {
  /// 最小親密度
  final int? minAffection;

  /// 必要なレベル
  final int? minPlayerLevel;

  /// 必要なストーリーフラグ
  final List<String>? requiredFlags;

  /// 禁止されたフラグ
  final List<String>? forbiddenFlags;

  /// 必要なアイテム
  final Map<String, int>? requiredItems;

  QuestCondition({
    this.minAffection,
    this.minPlayerLevel,
    this.requiredFlags,
    this.forbiddenFlags,
    this.requiredItems,
  });

  factory QuestCondition.fromJson(Map<String, dynamic> json) =>
      _$QuestConditionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestConditionToJson(this);
}

/// クエストステップ
@JsonSerializable()
class QuestStep {
  /// ステップ ID
  final String stepId;

  /// ステップ説明
  final String description;

  /// ステップ目標
  final String objective;

  /// このステップで発火するイベント
  final List<String>? eventIds;

  /// ステップ条件
  final QuestCondition? condition;

  /// 完了したか
  final bool isCompleted;

  /// 完了日時
  final DateTime? completedAt;

  QuestStep({
    required this.stepId,
    required this.description,
    required this.objective,
    this.eventIds,
    this.condition,
    this.isCompleted = false,
    this.completedAt,
  });

  factory QuestStep.fromJson(Map<String, dynamic> json) =>
      _$QuestStepFromJson(json);

  Map<String, dynamic> toJson() => _$QuestStepToJson(this);

  QuestStep copyWith({
    String? stepId,
    String? description,
    String? objective,
    List<String>? eventIds,
    QuestCondition? condition,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return QuestStep(
      stepId: stepId ?? this.stepId,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      eventIds: eventIds ?? this.eventIds,
      condition: condition ?? this.condition,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// NPC クエスト
@JsonSerializable()
class NPCQuest {
  /// クエスト ID
  final String questId;

  /// NPC ID
  final String npcId;

  /// クエスト名
  final String questName;

  /// クエスト説明
  final String description;

  /// クエストステータス
  final QuestStatus status;

  /// クエストステップ
  final List<QuestStep> steps;

  /// 現在のステップインデックス
  final int currentStepIndex;

  /// クエスト条件
  final QuestCondition? condition;

  /// クエスト報酬
  final QuestReward reward;

  /// クエスト開始日時
  final DateTime startedAt;

  /// クエスト完了日時
  final DateTime? completedAt;

  /// クエスト期限
  final DateTime? deadline;

  /// リピート可能か
  final bool isRepeatable;

  /// 最後のリピート日時
  final DateTime? lastRepeatAt;

  NPCQuest({
    required this.questId,
    required this.npcId,
    required this.questName,
    required this.description,
    required this.status,
    required this.steps,
    this.currentStepIndex = 0,
    this.condition,
    required this.reward,
    required this.startedAt,
    this.completedAt,
    this.deadline,
    this.isRepeatable = false,
    this.lastRepeatAt,
  });

  factory NPCQuest.fromJson(Map<String, dynamic> json) =>
      _$NPCQuestFromJson(json);

  Map<String, dynamic> toJson() => _$NPCQuestToJson(this);

  QuestStep? get currentStep {
    if (currentStepIndex < steps.length) {
      return steps[currentStepIndex];
    }
    return null;
  }

  bool get isActive =>
      status == QuestStatus.accepted || status == QuestStatus.in_progress;

  NPCQuest copyWith({
    String? questId,
    String? npcId,
    String? questName,
    String? description,
    QuestStatus? status,
    List<QuestStep>? steps,
    int? currentStepIndex,
    QuestCondition? condition,
    QuestReward? reward,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? deadline,
    bool? isRepeatable,
    DateTime? lastRepeatAt,
  }) {
    return NPCQuest(
      questId: questId ?? this.questId,
      npcId: npcId ?? this.npcId,
      questName: questName ?? this.questName,
      description: description ?? this.description,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      condition: condition ?? this.condition,
      reward: reward ?? this.reward,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      deadline: deadline ?? this.deadline,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      lastRepeatAt: lastRepeatAt ?? this.lastRepeatAt,
    );
  }
}

/// クエスト統計
@JsonSerializable()
class QuestStatistics {
  /// NPC ID
  final String npcId;

  /// 完了したクエスト数
  final int completedCount;

  /// 進行中のクエスト数
  final int activeCount;

  /// 失敗したクエスト数
  final int failedCount;

  /// 放棄したクエスト数
  final int abandonedCount;

  /// 総報酬（経験値）
  final int totalXpEarned;

  /// 総報酬（ゴール）
  final int totalGoldEarned;

  /// 総報酬（親密度）
  final int totalAffectionEarned;

  /// 最後のクエスト完了日時
  final DateTime? lastCompletedAt;

  QuestStatistics({
    required this.npcId,
    this.completedCount = 0,
    this.activeCount = 0,
    this.failedCount = 0,
    this.abandonedCount = 0,
    this.totalXpEarned = 0,
    this.totalGoldEarned = 0,
    this.totalAffectionEarned = 0,
    this.lastCompletedAt,
  });

  factory QuestStatistics.fromJson(Map<String, dynamic> json) =>
      _$QuestStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$QuestStatisticsToJson(this);
}
