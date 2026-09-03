import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';

/// NPC イベント管理サービス
class NPCEventService {
  static final NPCEventService _instance = NPCEventService._internal();

  factory NPCEventService.getInstance() {
    return _instance;
  }

  NPCEventService._internal();

  // イベントキャッシュ
  final Map<String, NPCEvent> _eventCache = {};

  // トリガー定義キャッシュ
  final Map<String, EventTriggerDefinition> _triggerCache = {};

  // イベントシーケンスキャッシュ
  final Map<String, EventSequence> _sequenceCache = {};

  // イベントログ
  final List<EventLog> _eventLogs = [];

  /// イベントを作成
  NPCEvent createEvent(
    String npcId,
    EventType eventType,
    String title,
    String description,
    String triggerType,
    {EventPriority priority = EventPriority.normal,
    Map<String, dynamic>? triggerData,
    EventReward? reward,
    List<String>? chainedEventIds,
    Map<String, dynamic>? customData}) {
    final eventId = DateTime.now().millisecondsSinceEpoch.toString();

    final event = NPCEvent(
      eventId: eventId,
      npcId: npcId,
      eventType: eventType,
      priority: priority,
      title: title,
      description: description,
      triggerType: triggerType,
      triggerData: triggerData,
      triggeredAt: DateTime.now(),
      reward: reward,
      chainedEventIds: chainedEventIds,
      customData: customData,
    );

    _eventCache[eventId] = event;
    return event;
  }

  /// イベントを登録
  void registerEvent(NPCEvent event) {
    _eventCache[event.eventId] = event;
  }

  /// イベントを取得
  NPCEvent? getEvent(String eventId) {
    return _eventCache[eventId];
  }

  /// イベントを処理
  NPCEvent processEvent(String eventId) {
    final event = _eventCache[eventId];
    if (event == null) {
      throw Exception('Event $eventId not found');
    }

    final processed = event.copyWith(
      isProcessed: true,
      completedAt: DateTime.now(),
    );

    _eventCache[eventId] = processed;

    // ログに記録
    _logEvent(processed, 'Event processed');

    return processed;
  }

  /// イベントを完了
  NPCEvent completeEvent(String eventId) {
    return processEvent(eventId);
  }

  /// トリガー定義を作成
  EventTriggerDefinition createTrigger(
    String npcId,
    String triggerType,
    String eventId,
    {EventCondition? condition,
    double probability = 1.0,
    Duration? delay,
    bool oneTimeOnly = false,
    Duration? cooldown}) {
    final triggerId = '${npcId}-${triggerType}-${DateTime.now().millisecondsSinceEpoch}';

    final trigger = EventTriggerDefinition(
      triggerId: triggerId,
      npcId: npcId,
      triggerType: triggerType,
      condition: condition,
      eventId: eventId,
      probability: probability,
      delay: delay,
      oneTimeOnly: oneTimeOnly,
      cooldown: cooldown,
    );

    _triggerCache[triggerId] = trigger;
    return trigger;
  }

  /// トリガーを登録
  void registerTrigger(EventTriggerDefinition trigger) {
    _triggerCache[trigger.triggerId] = trigger;
  }

  /// トリガーを取得
  EventTriggerDefinition? getTrigger(String triggerId) {
    return _triggerCache[triggerId];
  }

  /// 条件をチェック
  bool checkCondition(EventCondition? condition, int affection, NPCBehaviorState npcState) {
    if (condition == null) {
      return true;
    }

    if (condition.minAffection != null && affection < condition.minAffection!) {
      return false;
    }
    if (condition.maxAffection != null && affection > condition.maxAffection!) {
      return false;
    }

    if (condition.requiredMoods != null &&
        !condition.requiredMoods!.contains(npcState.currentMood)) {
      return false;
    }

    if (condition.minInteractionCount != null &&
        npcState.memorizedInteractions.length < condition.minInteractionCount!) {
      return false;
    }

    return true;
  }

  /// シーケンスを作成
  EventSequence createSequence(String npcId, List<String> eventIds) {
    final sequenceId =
        'seq-${npcId}-${DateTime.now().millisecondsSinceEpoch}';

    final sequence = EventSequence(
      sequenceId: sequenceId,
      npcId: npcId,
      eventIds: eventIds,
      startedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sequenceCache[sequenceId] = sequence;
    return sequence;
  }

  /// シーケンスを取得
  EventSequence? getSequence(String sequenceId) {
    return _sequenceCache[sequenceId];
  }

  /// シーケンスの次のイベントを実行
  NPCEvent? executeNextInSequence(String sequenceId) {
    final sequence = _sequenceCache[sequenceId];
    if (sequence == null || sequence.isComplete) {
      return null;
    }

    if (sequence.currentIndex >= sequence.eventIds.length) {
      // シーケンス完了
      _sequenceCache[sequenceId] = sequence.copyWith(isComplete: true);
      return null;
    }

    final eventId = sequence.eventIds[sequence.currentIndex];
    final event = _eventCache[eventId];

    if (event != null) {
      processEvent(eventId);

      // 次へ進む
      _sequenceCache[sequenceId] = sequence.copyWith(
        currentIndex: sequence.currentIndex + 1,
        updatedAt: DateTime.now(),
      );

      return event;
    }

    return null;
  }

  /// イベントログを記録
  void _logEvent(NPCEvent event, String message) {
    final log = EventLog(
      logId: DateTime.now().millisecondsSinceEpoch.toString(),
      npcId: event.npcId,
      eventId: event.eventId,
      eventType: event.eventType,
      triggerType: event.triggerType,
      message: message,
      timestamp: DateTime.now(),
      metadata: {
        'priority': event.priority.english,
        'title': event.title,
      },
    );

    _eventLogs.add(log);
  }

  /// イベント統計を生成
  EventStatistics generateStatistics(String npcId) {
    final npcEvents = _eventCache.values.where((e) => e.npcId == npcId);

    int totalAffection = 0;
    final typeCount = <String, int>{};

    for (final event in npcEvents) {
      if (event.reward != null) {
        totalAffection += event.reward!.affectionBonus;
      }

      final typeName = event.eventType.english;
      typeCount[typeName] = (typeCount[typeName] ?? 0) + 1;
    }

    return EventStatistics(
      npcId: npcId,
      totalEvents: npcEvents.length,
      processedEvents:
          npcEvents.where((e) => e.isProcessed).length,
      pendingEvents:
          npcEvents.where((e) => !e.isProcessed).length,
      eventTypeCount: typeCount,
      totalAffectionFromEvents: totalAffection,
      lastEventTime: npcEvents.isEmpty
          ? null
          : npcEvents.reduce((a, b) => a.triggeredAt.isAfter(b.triggeredAt) ? a : b).triggeredAt,
    );
  }

  /// ペンディングイベントを取得
  List<NPCEvent> getPendingEvents(String npcId) {
    return _eventCache.values
        .where((e) => e.npcId == npcId && !e.isProcessed)
        .toList();
  }

  /// NPC のイベント履歴を取得
  List<EventLog> getEventHistory(String npcId) {
    return _eventLogs.where((log) => log.npcId == npcId).toList();
  }

  /// イベントをトリガー
  NPCEvent? triggerEvent(
    String triggerId,
    int currentAffection,
    NPCBehaviorState npcState,
  ) {
    final trigger = _triggerCache[triggerId];
    if (trigger == null || !trigger.isActive) {
      return null;
    }

    // 確率チェック
    if (trigger.probability < 1.0) {
      final random = DateTime.now().millisecond / 1000.0;
      if (random > trigger.probability) {
        return null;
      }
    }

    // 条件チェック
    if (!checkCondition(trigger.condition, currentAffection, npcState)) {
      return null;
    }

    final event = _eventCache[trigger.eventId];
    if (event == null) {
      return null;
    }

    return event;
  }

  /// 優先度別にイベントをソート
  List<NPCEvent> sortByPriority(List<NPCEvent> events) {
    final priorityOrder = {
      EventPriority.critical: 0,
      EventPriority.high: 1,
      EventPriority.normal: 2,
      EventPriority.low: 3,
    };

    events.sort((a, b) =>
        (priorityOrder[a.priority] ?? 999)
            .compareTo(priorityOrder[b.priority] ?? 999));
    return events;
  }

  /// イベントを削除
  void removeEvent(String eventId) {
    _eventCache.remove(eventId);
  }

  /// トリガーをディアクティベート
  void deactivateTrigger(String triggerId) {
    final trigger = _triggerCache[triggerId];
    if (trigger != null) {
      _triggerCache[triggerId] = trigger.copyWith(isActive: false);
    }
  }

  /// シーケンスをリセット
  void resetSequence(String sequenceId) {
    final sequence = _sequenceCache[sequenceId];
    if (sequence != null) {
      _sequenceCache[sequenceId] = sequence.copyWith(
        currentIndex: 0,
        isComplete: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// シーケンスを削除
  void removeSequence(String sequenceId) {
    _sequenceCache.remove(sequenceId);
  }
}
