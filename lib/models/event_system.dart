/// ゲームイベントシステム
/// ゲーム内のイベント、トリガー、コールバックを管理

typedef EventCallback = void Function(GameEvent event);

/// ゲームイベントシステム
class GameEventSystem {
  static final GameEventSystem _instance = GameEventSystem._internal();

  factory GameEventSystem.getInstance() {
    return _instance;
  }

  GameEventSystem._internal();

  final Map<String, List<EventCallback>> _eventListeners = {};
  final List<GameEvent> _eventHistory = [];
  final Map<String, bool> _eventFlags = {}; // 発生済みイベント追跡

  /// イベントリスナーを登録
  void addEventListener(String eventType, EventCallback callback) {
    _eventListeners.putIfAbsent(eventType, () => []).add(callback);
  }

  /// イベントリスナーを削除
  void removeEventListener(String eventType, EventCallback callback) {
    _eventListeners[eventType]?.remove(callback);
  }

  /// イベントを発火
  void fireEvent(GameEvent event) {
    // イベント履歴に追加
    _eventHistory.add(event);

    // イベントフラグを設定
    _eventFlags[event.id] = true;

    // リスナーに通知
    final listeners = _eventListeners[event.type] ?? [];
    for (final callback in listeners) {
      callback(event);
    }
  }

  /// イベントが発生したかチェック
  bool hasEventOccurred(String eventId) {
    return _eventFlags[eventId] ?? false;
  }

  /// イベント履歴を取得
  List<GameEvent> getEventHistory({String? eventType}) {
    if (eventType == null) {
      return List.from(_eventHistory);
    }
    return _eventHistory.where((e) => e.type == eventType).toList();
  }

  /// すべてのリスナーをクリア
  void clearAllListeners() {
    _eventListeners.clear();
  }
}

/// ゲームイベント
class GameEvent {
  final String id;
  final String type;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  GameEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.data = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => '$title (${type})';
}

/// イベントトリガー基底クラス
abstract class EventTrigger {
  String get id;
  String get eventType;
  bool get isActive;

  /// トリガーが発動したかチェック
  bool checkTrigger();

  /// トリガーをリセット
  void reset();
}

/// 時間ベースのトリガー
class TimeBasedTrigger extends EventTrigger {
  @override
  final String id;

  @override
  final String eventType;

  final Duration duration;
  DateTime? _startTime;
  bool _triggered = false;

  TimeBasedTrigger({
    required this.id,
    required this.eventType,
    required this.duration,
  });

  @override
  bool get isActive => !_triggered;

  void start() {
    _startTime = DateTime.now();
    _triggered = false;
  }

  @override
  bool checkTrigger() {
    if (_startTime == null || _triggered) return false;

    if (DateTime.now().difference(_startTime!) >= duration) {
      _triggered = true;
      return true;
    }
    return false;
  }

  @override
  void reset() {
    _startTime = null;
    _triggered = false;
  }
}

/// 条件ベースのトリガー
class ConditionTrigger extends EventTrigger {
  @override
  final String id;

  @override
  final String eventType;

  final bool Function() condition;
  bool _triggered = false;

  ConditionTrigger({
    required this.id,
    required this.eventType,
    required this.condition,
  });

  @override
  bool get isActive => !_triggered;

  @override
  bool checkTrigger() {
    if (_triggered) return false;

    if (condition()) {
      _triggered = true;
      return true;
    }
    return false;
  }

  @override
  void reset() {
    _triggered = false;
  }
}

/// 親密度ベースのトリガー
class AffectionTrigger extends EventTrigger {
  @override
  final String id;

  @override
  final String eventType;

  final String npcId;
  final int affectionThreshold;
  bool _triggered = false;

  AffectionTrigger({
    required this.id,
    required this.eventType,
    required this.npcId,
    required this.affectionThreshold,
  });

  @override
  bool get isActive => !_triggered;

  @override
  bool checkTrigger(int? currentAffection) {
    if (_triggered) return false;

    if (currentAffection != null && currentAffection >= affectionThreshold) {
      _triggered = true;
      return true;
    }
    return false;
  }

  @override
  void reset() {
    _triggered = false;
  }
}

/// イベントトリガーマネージャー
class EventTriggerManager {
  static final EventTriggerManager _instance =
      EventTriggerManager._internal();

  factory EventTriggerManager.getInstance() {
    return _instance;
  }

  EventTriggerManager._internal();

  final Map<String, EventTrigger> _triggers = {};
  final GameEventSystem _eventSystem = GameEventSystem.getInstance();

  /// トリガーを登録
  void registerTrigger(EventTrigger trigger) {
    _triggers[trigger.id] = trigger;
  }

  /// トリガーを登録解除
  void unregisterTrigger(String triggerId) {
    _triggers.remove(triggerId);
  }

  /// すべてのアクティブなトリガーをチェック
  void checkAllTriggers({Map<String, int>? affectionValues}) {
    for (final trigger in _triggers.values) {
      if (trigger.isActive) {
        bool shouldTrigger = false;

        if (trigger is AffectionTrigger && affectionValues != null) {
          shouldTrigger =
              trigger.checkTrigger(affectionValues[trigger.npcId] ?? 0);
        } else {
          shouldTrigger = trigger.checkTrigger();
        }

        if (shouldTrigger) {
          _handleTrigger(trigger);
        }
      }
    }
  }

  /// トリガーを処理
  void _handleTrigger(EventTrigger trigger) {
    final event = GameEvent(
      id: '${trigger.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: trigger.eventType,
      title: 'Event: ${trigger.id}',
      description: 'Triggered by ${trigger.runtimeType}',
      data: {'triggerId': trigger.id},
    );

    _eventSystem.fireEvent(event);
  }

  /// トリガーマネージャーをリセット
  void reset() {
    for (final trigger in _triggers.values) {
      trigger.reset();
    }
  }
}

/// イベントタイプ定数
class EventType {
  static const String questAccepted = 'quest_accepted';
  static const String questCompleted = 'quest_completed';
  static const String affectionMilestone = 'affection_milestone';
  static const String npcMeeting = 'npc_meeting';
  static const String relationshipChanged = 'relationship_changed';
  static const String eventTriggered = 'event_triggered';
  static const String factionJoined = 'faction_joined';
  static const String factionPerkUnlocked = 'faction_perk_unlocked';
  static const String dialogueUnlocked = 'dialogue_unlocked';
  static const String skillLearned = 'skill_learned';
}
