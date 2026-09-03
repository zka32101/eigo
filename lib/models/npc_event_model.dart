import 'package:json_annotation/json_annotation.dart';
import 'package:eigo/models/npc_behavior_model.dart';

part 'npc_event_model.g.dart';

/// イベントタイプ
enum EventType {
  dialogue_triggered('対話トリガー', 'Dialogue Triggered'),
  relationship_milestone('関係マイルストーン', 'Relationship Milestone'),
  mood_changed('ムード変化', 'Mood Changed'),
  quest_given('クエスト与与', 'Quest Given'),
  quest_completed('クエスト完了', 'Quest Completed'),
  location_unlocked('ロケーションアンロック', 'Location Unlocked'),
  skill_learned('スキル習得', 'Skill Learned'),
  item_received('アイテム受取', 'Item Received'),
  custom_event('カスタムイベント', 'Custom Event');

  final String japanese;
  final String english;

  const EventType(this.japanese, this.english);
}

/// イベント優先度
enum EventPriority {
  low('低', 'Low'),
  normal('普通', 'Normal'),
  high('高', 'High'),
  critical('重要', 'Critical');

  final String japanese;
  final String english;

  const EventPriority(this.japanese, this.english);
}

/// NPC イベント（行動の結果）
@JsonSerializable()
class NPCEvent {
  /// イベント ID
  final String eventId;

  /// NPC ID
  final String npcId;

  /// イベントタイプ
  final EventType eventType;

  /// イベント優先度
  final EventPriority priority;

  /// イベントタイトル
  final String title;

  /// イベント説明
  final String description;

  /// トリガーの種類（dialogue, behavior, mood_change等）
  final String triggerType;

  /// トリガーの詳細
  final Map<String, dynamic>? triggerData;

  /// 発火時刻
  final DateTime triggeredAt;

  /// イベント完了時刻
  DateTime? completedAt;

  /// イベントが処理済みか
  final bool isProcessed;

  /// 報酬
  final EventReward? reward;

  /// 連鎖イベント
  final List<String>? chainedEventIds;

  /// カスタムデータ
  final Map<String, dynamic>? customData;

  NPCEvent({
    required this.eventId,
    required this.npcId,
    required this.eventType,
    this.priority = EventPriority.normal,
    required this.title,
    required this.description,
    required this.triggerType,
    this.triggerData,
    required this.triggeredAt,
    this.completedAt,
    this.isProcessed = false,
    this.reward,
    this.chainedEventIds,
    this.customData,
  });

  factory NPCEvent.fromJson(Map<String, dynamic> json) =>
      _$NPCEventFromJson(json);

  Map<String, dynamic> toJson() => _$NPCEventToJson(this);

  /// コピー関数
  NPCEvent copyWith({
    String? eventId,
    String? npcId,
    EventType? eventType,
    EventPriority? priority,
    String? title,
    String? description,
    String? triggerType,
    Map<String, dynamic>? triggerData,
    DateTime? triggeredAt,
    DateTime? completedAt,
    bool? isProcessed,
    EventReward? reward,
    List<String>? chainedEventIds,
    Map<String, dynamic>? customData,
  }) {
    return NPCEvent(
      eventId: eventId ?? this.eventId,
      npcId: npcId ?? this.npcId,
      eventType: eventType ?? this.eventType,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      triggerType: triggerType ?? this.triggerType,
      triggerData: triggerData ?? this.triggerData,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      completedAt: completedAt ?? this.completedAt,
      isProcessed: isProcessed ?? this.isProcessed,
      reward: reward ?? this.reward,
      chainedEventIds: chainedEventIds ?? this.chainedEventIds,
      customData: customData ?? this.customData,
    );
  }
}

/// イベント報酬
@JsonSerializable()
class EventReward {
  /// 親密度報酬
  final int affectionBonus;

  /// 経験値報酬
  final int xpReward;

  /// アイテム報酬 ID
  final List<String>? itemRewardIds;

  /// ゴールド報酬
  final int goldReward;

  /// スキル報酬 ID
  final String? skillRewardId;

  /// ロケーション報酬 ID
  final String? locationUnlockId;

  /// ストーリーフラグを設定
  final List<String>? setFlags;

  EventReward({
    this.affectionBonus = 0,
    this.xpReward = 0,
    this.itemRewardIds,
    this.goldReward = 0,
    this.skillRewardId,
    this.locationUnlockId,
    this.setFlags,
  });

  factory EventReward.fromJson(Map<String, dynamic> json) =>
      _$EventRewardFromJson(json);

  Map<String, dynamic> toJson() => _$EventRewardToJson(this);
}

/// イベント条件
@JsonSerializable()
class EventCondition {
  /// 最小親密度
  final int? minAffection;

  /// 最大親密度
  final int? maxAffection;

  /// 必要なムード
  final List<NPCMood>? requiredMoods;

  /// 必要なフラグ
  final List<String>? requiredFlags;

  /// 禁止されたフラグ
  final List<String>? forbiddenFlags;

  /// 最小インタラクション数
  final int? minInteractionCount;

  /// 時間経過の要件
  final Duration? timeSinceLastEvent;

  EventCondition({
    this.minAffection,
    this.maxAffection,
    this.requiredMoods,
    this.requiredFlags,
    this.forbiddenFlags,
    this.minInteractionCount,
    this.timeSinceLastEvent,
  });

  factory EventCondition.fromJson(Map<String, dynamic> json) =>
      _$EventConditionFromJson(json);

  Map<String, dynamic> toJson() => _$EventConditionToJson(this);
}

/// イベントトリガー定義
@JsonSerializable()
class EventTriggerDefinition {
  /// トリガー ID
  final String triggerId;

  /// NPC ID
  final String npcId;

  /// トリガータイプ（dialogue, behavior, mood, schedule）
  final String triggerType;

  /// トリガー条件
  final EventCondition? condition;

  /// 実行するイベント ID
  final String eventId;

  /// トリガー確率（0.0-1.0）
  final double probability;

  /// 遅延時間（イベント実行前）
  final Duration? delay;

  /// 1度だけ実行されるか
  final bool oneTimeOnly;

  /// クールダウン時間
  final Duration? cooldown;

  /// 有効か
  final bool isActive;

  EventTriggerDefinition({
    required this.triggerId,
    required this.npcId,
    required this.triggerType,
    this.condition,
    required this.eventId,
    this.probability = 1.0,
    this.delay,
    this.oneTimeOnly = false,
    this.cooldown,
    this.isActive = true,
  });

  factory EventTriggerDefinition.fromJson(Map<String, dynamic> json) =>
      _$EventTriggerDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$EventTriggerDefinitionToJson(this);

  /// コピー関数
  EventTriggerDefinition copyWith({
    String? triggerId,
    String? npcId,
    String? triggerType,
    EventCondition? condition,
    String? eventId,
    double? probability,
    Duration? delay,
    bool? oneTimeOnly,
    Duration? cooldown,
    bool? isActive,
  }) {
    return EventTriggerDefinition(
      triggerId: triggerId ?? this.triggerId,
      npcId: npcId ?? this.npcId,
      triggerType: triggerType ?? this.triggerType,
      condition: condition ?? this.condition,
      eventId: eventId ?? this.eventId,
      probability: probability ?? this.probability,
      delay: delay ?? this.delay,
      oneTimeOnly: oneTimeOnly ?? this.oneTimeOnly,
      cooldown: cooldown ?? this.cooldown,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// イベントシーケンス（複数イベントの順序）
@JsonSerializable()
class EventSequence {
  /// シーケンス ID
  final String sequenceId;

  /// NPC ID
  final String npcId;

  /// イベント ID のリスト（実行順）
  final List<String> eventIds;

  /// 現在のインデックス
  final int currentIndex;

  /// シーケンスが完了したか
  final bool isComplete;

  /// シーケンス開始時刻
  final DateTime startedAt;

  /// シーケンス更新時刻
  final DateTime updatedAt;

  EventSequence({
    required this.sequenceId,
    required this.npcId,
    required this.eventIds,
    this.currentIndex = 0,
    this.isComplete = false,
    required this.startedAt,
    required this.updatedAt,
  });

  factory EventSequence.fromJson(Map<String, dynamic> json) =>
      _$EventSequenceFromJson(json);

  Map<String, dynamic> toJson() => _$EventSequenceToJson(this);

  /// コピー関数
  EventSequence copyWith({
    String? sequenceId,
    String? npcId,
    List<String>? eventIds,
    int? currentIndex,
    bool? isComplete,
    DateTime? startedAt,
    DateTime? updatedAt,
  }) {
    return EventSequence(
      sequenceId: sequenceId ?? this.sequenceId,
      npcId: npcId ?? this.npcId,
      eventIds: eventIds ?? this.eventIds,
      currentIndex: currentIndex ?? this.currentIndex,
      isComplete: isComplete ?? this.isComplete,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// イベント統計
@JsonSerializable()
class EventStatistics {
  /// NPC ID
  final String npcId;

  /// 総イベント数
  final int totalEvents;

  /// 処理済みイベント数
  final int processedEvents;

  /// ペンディングイベント数
  final int pendingEvents;

  /// イベントタイプ別カウント
  final Map<String, int>? eventTypeCount;

  /// 総報酬
  final int totalAffectionFromEvents;

  /// 最後のイベント時刻
  final DateTime? lastEventTime;

  EventStatistics({
    required this.npcId,
    this.totalEvents = 0,
    this.processedEvents = 0,
    this.pendingEvents = 0,
    this.eventTypeCount,
    this.totalAffectionFromEvents = 0,
    this.lastEventTime,
  });

  factory EventStatistics.fromJson(Map<String, dynamic> json) =>
      _$EventStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$EventStatisticsToJson(this);
}

/// イベントログ
@JsonSerializable()
class EventLog {
  /// ログ ID
  final String logId;

  /// NPC ID
  final String npcId;

  /// イベント ID
  final String eventId;

  /// イベントタイプ
  final EventType eventType;

  /// トリガータイプ
  final String triggerType;

  /// ログメッセージ
  final String message;

  /// タイムスタンプ
  final DateTime timestamp;

  /// 関連データ
  final Map<String, dynamic>? metadata;

  EventLog({
    required this.logId,
    required this.npcId,
    required this.eventId,
    required this.eventType,
    required this.triggerType,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  factory EventLog.fromJson(Map<String, dynamic> json) =>
      _$EventLogFromJson(json);

  Map<String, dynamic> toJson() => _$EventLogToJson(this);
}
