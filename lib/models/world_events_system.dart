/// ワールドイベントシステム
/// 動的ワールドイベント、季節変化、ランダムエンカウント

/// ワールドイベントシステム
class WorldEventsSystem {
  static final WorldEventsSystem _instance = WorldEventsSystem._internal();

  factory WorldEventsSystem.getInstance() {
    return _instance;
  }

  WorldEventsSystem._internal();

  // ワールドイベント: event_id -> WorldEvent
  final Map<String, WorldEvent> _activeEvents = {};

  // イベント履歴: event_id -> WorldEventResult
  final Map<String, WorldEventResult> _eventHistory = {};

  // 季節システム
  Season _currentSeason = Season.spring;
  int _seasonProgress = 0; // 0-99 (季節進行度)
  int _currentDay = 1;

  // 領域の状態: territory_id -> TerritoryState
  final Map<String, TerritoryState> _territoryStates = {};

  // NPC移動トラッキング: npc_id -> Territory
  final Map<String, String> _npcLocations = {};

  // エンカウント発生率: 季節による調整
  final Map<Season, double> _encounterRateModifiers = {
    Season.spring: 1.0,
    Season.summer: 0.8,
    Season.autumn: 1.2,
    Season.winter: 0.6,
  };

  // イベント結果の報告
  final Map<String, List<EventConsequence>> _consequences = {};

  /// システムを初期化
  void initialize() {
    _activeEvents.clear();
    _eventHistory.clear();
    _territoryStates.clear();
    _npcLocations.clear();
    _consequences.clear();
    _currentSeason = Season.spring;
    _seasonProgress = 0;
    _currentDay = 1;

    _initializeTerritoriesAndNPCs();
  }

  /// 領域とNPCを初期化
  void _initializeTerritoriesAndNPCs() {
    // 領域の初期化
    final territories = [
      'arcane_citadel',
      'martial_fortress',
      'commerce_harbor',
      'natural_forest',
      'mineral_canyon',
      'maritime_coast',
    ];

    for (final territory in territories) {
      _territoryStates[territory] = TerritoryState(
        territoryId: territory,
        currentSeason: _currentSeason,
        stability: 100,
        prosperity: 50,
        populationMorale: 75,
        lastEventTime: DateTime.now().millisecondsSinceEpoch,
      );
    }

    // NPC位置の初期化
    final npcs = ['npc_001', 'npc_002', 'npc_003', 'npc_004', 'npc_005'];
    final locations = ['arcane_citadel', 'martial_fortress', 'commerce_harbor'];
    for (int i = 0; i < npcs.length; i++) {
      _npcLocations[npcs[i]] = locations[i % locations.length];
    }
  }

  /// 時間を進める（毎日呼び出し）
  List<String> advanceDay() {
    _currentDay++;
    _seasonProgress++;

    // 季節を更新
    if (_seasonProgress >= 100) {
      _advanceSeason();
      _seasonProgress = 0;
    }

    final triggeredEventIds = <String>[];

    // アクティブなイベントをチェック
    for (final event in _activeEvents.values) {
      if (event.isExpired()) {
        _resolveEvent(event);
        triggeredEventIds.add(event.id);
      }
    }

    // 新しいイベントの発生をチェック
    if (_shouldTriggerNewEvent()) {
      final newEvent = _generateRandomEvent();
      _activeEvents[newEvent.id] = newEvent;
      _propagateEventConsequences(newEvent);
      triggeredEventIds.add(newEvent.id);
    }

    // NPCの移動
    _updateNPCLocations();

    return triggeredEventIds;
  }

  /// 季節を進める
  void _advanceSeason() {
    final seasons = Season.values;
    final currentIndex = seasons.indexOf(_currentSeason);
    _currentSeason = seasons[(currentIndex + 1) % seasons.length];

    // すべての領域を季節で更新
    for (final state in _territoryStates.values) {
      state.currentSeason = _currentSeason;
      _applySeasonalEffects(state);
    }
  }

  /// 季節効果を適用
  void _applySeasonalEffects(TerritoryState state) {
    switch (_currentSeason) {
      case Season.spring:
        state.prosperity += 10;
        state.populationMorale += 5;
        state.stability = (state.stability + 95) ~/ 2;
        break;
      case Season.summer:
        state.prosperity += 15;
        state.populationMorale -= 5;
        state.stability = (state.stability + 90) ~/ 2;
        break;
      case Season.autumn:
        state.prosperity += 5;
        state.populationMorale += 10;
        state.stability = (state.stability + 85) ~/ 2;
        break;
      case Season.winter:
        state.prosperity -= 10;
        state.populationMorale -= 15;
        state.stability = (state.stability + 70) ~/ 2;
        break;
    }

    // 上限・下限を適用
    state.prosperity = state.prosperity.clamp(0, 100);
    state.populationMorale = state.populationMorale.clamp(0, 100);
    state.stability = state.stability.clamp(0, 100);
  }

  /// 新しいイベントを発生させるべきか判定
  bool _shouldTriggerNewEvent() {
    final baseChance = 0.15;
    final seasonModifier = _encounterRateModifiers[_currentSeason] ?? 1.0;
    final totalChance = baseChance * seasonModifier;
    return DateTime.now().millisecondsSinceEpoch % 100 < (totalChance * 100).toInt();
  }

  /// ランダムイベントを生成
  WorldEvent _generateRandomEvent() {
    final eventTypes = WorldEventType.values;
    final randomType = eventTypes[DateTime.now().millisecondsSinceEpoch % eventTypes.length];
    final territories = _territoryStates.keys.toList();
    final territory = territories[DateTime.now().millisecondsSinceEpoch % territories.length];

    final eventId = 'event_${DateTime.now().millisecondsSinceEpoch}';
    final intensity = (DateTime.now().millisecondsSinceEpoch % 3) + 1; // 1-3

    return WorldEvent(
      id: eventId,
      type: randomType,
      territory: territory,
      startTime: DateTime.now().millisecondsSinceEpoch,
      duration: (2 + intensity * 2),
      intensity: intensity,
      isActive: true,
      affectedNPCs: _getNPCsInTerritory(territory),
    );
  }

  /// 領域内のNPCを取得
  List<String> _getNPCsInTerritory(String territory) {
    return _npcLocations.entries
        .where((e) => e.value == territory)
        .map((e) => e.key)
        .toList();
  }

  /// イベント結果を伝播
  void _propagateEventConsequences(WorldEvent event) {
    final territory = _territoryStates[event.territory];
    if (territory == null) return;

    final consequenceList = <EventConsequence>[];

    switch (event.type) {
      case WorldEventType.invasion:
        territory.stability -= event.intensity * 20;
        territory.populationMorale -= event.intensity * 15;
        territory.prosperity -= event.intensity * 10;
        consequenceList.add(EventConsequence(
          type: ConsequenceType.stability,
          value: -event.intensity * 20,
          description: '領域が侵略を受けた',
        ));
        break;

      case WorldEventType.disaster:
        territory.prosperity -= event.intensity * 25;
        territory.populationMorale -= event.intensity * 20;
        territory.stability -= event.intensity * 15;
        consequenceList.add(EventConsequence(
          type: ConsequenceType.prosperity,
          value: -event.intensity * 25,
          description: '自然災害が発生した',
        ));
        break;

      case WorldEventType.celebration:
        territory.populationMorale += event.intensity * 15;
        territory.prosperity += event.intensity * 10;
        territory.stability += event.intensity * 5;
        consequenceList.add(EventConsequence(
          type: ConsequenceType.morale,
          value: event.intensity * 15,
          description: 'お祭りが開催された',
        ));
        break;

      case WorldEventType.epidemic:
        territory.populationMorale -= event.intensity * 25;
        territory.prosperity -= event.intensity * 15;
        territory.stability -= event.intensity * 10;
        consequenceList.add(EventConsequence(
          type: ConsequenceType.morale,
          value: -event.intensity * 25,
          description: '疫病が蔓延した',
        ));
        break;

      case WorldEventType.migration:
        territory.populationMorale -= event.intensity * 10;
        territory.prosperity += event.intensity * 5;
        consequenceList.add(EventConsequence(
          type: ConsequenceType.migration,
          value: -event.intensity * 10,
          description: 'NPCが移動した',
        ));
        break;
    }

    // 上限・下限を適用
    territory.prosperity = territory.prosperity.clamp(0, 100);
    territory.populationMorale = territory.populationMorale.clamp(0, 100);
    territory.stability = territory.stability.clamp(0, 100);

    _consequences[event.id] = consequenceList;
  }

  /// イベントを解決
  void _resolveEvent(WorldEvent event) {
    event.isActive = false;

    final result = WorldEventResult(
      eventId: event.id,
      eventType: event.type,
      territory: event.territory,
      intensity: event.intensity,
      startTime: event.startTime,
      endTime: DateTime.now().millisecondsSinceEpoch,
      affectedNPCs: event.affectedNPCs,
      consequences: _consequences[event.id] ?? [],
    );

    _eventHistory[event.id] = result;
    _activeEvents.remove(event.id);
  }

  /// NPCの位置を更新
  void _updateNPCLocations() {
    if (DateTime.now().millisecondsSinceEpoch % 10 != 0) return;

    for (final npcId in _npcLocations.keys) {
      // 10%の確率でNPCが移動
      if (DateTime.now().millisecondsSinceEpoch % 10 < 1) {
        final territories = _territoryStates.keys.toList();
        final newTerritory = territories[DateTime.now().millisecondsSinceEpoch % territories.length];
        _npcLocations[npcId] = newTerritory;
      }
    }
  }

  /// ランダムエンカウントを生成
  EncounterData generateRandomEncounter(String territoryId) {
    final territory = _territoryStates[territoryId];
    if (territory == null) {
      return EncounterData(
        type: EncounterType.none,
        difficulty: 0,
        reward: 0,
      );
    }

    // 季節とイベントに基づいて難易度を計算
    var baseDifficulty = 1;
    switch (_currentSeason) {
      case Season.spring:
        baseDifficulty = 1;
        break;
      case Season.summer:
        baseDifficulty = 2;
        break;
      case Season.autumn:
        baseDifficulty = 2;
        break;
      case Season.winter:
        baseDifficulty = 3;
        break;
    }

    // 安定性に基づいて難易度を調整
    if (territory.stability < 30) {
      baseDifficulty += 2; // 不安定な領域はより危険
    }

    final encounterTypes = EncounterType.values.where((t) => t != EncounterType.none).toList();
    final randomType = encounterTypes[DateTime.now().millisecondsSinceEpoch % encounterTypes.length];

    return EncounterData(
      type: randomType,
      difficulty: baseDifficulty.clamp(1, 5),
      reward: baseDifficulty * 100,
      territoryId: territoryId,
    );
  }

  /// アクティブなイベントを取得
  List<WorldEvent> getActiveEvents() {
    return _activeEvents.values
        .where((e) => e.isActive && !e.isExpired())
        .toList();
  }

  /// イベント履歴を取得
  List<WorldEventResult> getEventHistory({int limit = 50}) {
    return _eventHistory.values.toList().reversed.take(limit).toList();
  }

  /// 領域の状態を取得
  TerritoryState? getTerritoryState(String territoryId) {
    return _territoryStates[territoryId];
  }

  /// すべての領域の状態を取得
  Map<String, TerritoryState> getAllTerritoryStates() {
    return Map.from(_territoryStates);
  }

  /// 現在の季節を取得
  Season getCurrentSeason() {
    return _currentSeason;
  }

  /// 季節の進行度を取得（0-99）
  int getSeasonProgress() {
    return _seasonProgress;
  }

  /// 現在の日数を取得
  int getCurrentDay() {
    return _currentDay;
  }

  /// NPC位置を取得
  String? getNPCLocation(String npcId) {
    return _npcLocations[npcId];
  }

  /// イベント影響レポートを取得
  String getEventImpactReport(String territoryId) {
    final state = _territoryStates[territoryId];
    if (state == null) return 'No territory';

    return '''
Territory: $territoryId
Season: ${_currentSeason.toString()}
Day: $_currentDay

Status:
  Stability: ${state.stability}/100
  Prosperity: ${state.prosperity}/100
  Morale: ${state.populationMorale}/100

Recent Events: ${_eventHistory.values.where((e) => e.territory == territoryId).length}
''';
  }

  /// イベントの結果を取得
  WorldEventResult? getEventResult(String eventId) {
    return _eventHistory[eventId];
  }

  /// 季節の名前を取得
  String getSeasonName() {
    return _currentSeason.toString().split('.').last;
  }

  /// シーズン月数を取得
  int getMonthsInSeason() {
    return (_seasonProgress ~/ 25) + 1;
  }
}

/// ワールドイベント
class WorldEvent {
  final String id;
  final WorldEventType type;
  final String territory;
  final int startTime;
  final int duration;
  final int intensity;
  bool isActive;
  final List<String> affectedNPCs;

  WorldEvent({
    required this.id,
    required this.type,
    required this.territory,
    required this.startTime,
    required this.duration,
    required this.intensity,
    required this.isActive,
    required this.affectedNPCs,
  });

  /// イベントが期限切れか確認
  bool isExpired() {
    final elapsedDays = (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 86400000;
    return elapsedDays >= duration;
  }

  /// 残り日数を取得
  int getRemainingDays() {
    final elapsedDays = (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 86400000;
    return (duration - elapsedDays).clamp(0, duration);
  }
}

/// ワールドイベントの種類
enum WorldEventType {
  invasion, // 侵略
  disaster, // 自然災害
  celebration, // お祭り
  epidemic, // 疫病
  migration, // 移動
}

/// イベント結果
class WorldEventResult {
  final String eventId;
  final WorldEventType eventType;
  final String territory;
  final int intensity;
  final int startTime;
  final int endTime;
  final List<String> affectedNPCs;
  final List<EventConsequence> consequences;

  WorldEventResult({
    required this.eventId,
    required this.eventType,
    required this.territory,
    required this.intensity,
    required this.startTime,
    required this.endTime,
    required this.affectedNPCs,
    required this.consequences,
  });

  /// イベント継続時間（日数）
  int getDurationDays() {
    return (endTime - startTime) ~/ 86400000;
  }
}

/// イベント結果
class EventConsequence {
  final ConsequenceType type;
  final int value;
  final String description;

  EventConsequence({
    required this.type,
    required this.value,
    required this.description,
  });
}

/// イベント結果の種類
enum ConsequenceType {
  stability, // 安定性
  prosperity, // 繁栄
  morale, // 士気
  migration, // 移動
}

/// 領域の状態
class TerritoryState {
  final String territoryId;
  Season currentSeason;
  int stability;
  int prosperity;
  int populationMorale;
  int lastEventTime;

  TerritoryState({
    required this.territoryId,
    required this.currentSeason,
    required this.stability,
    required this.prosperity,
    required this.populationMorale,
    required this.lastEventTime,
  });

  /// 領域の安全性スコア（0-100）
  int getSafetyScore() {
    return ((stability + prosperity) ~/ 2).clamp(0, 100);
  }

  /// 領域のステータスを取得
  String getStatus() {
    if (stability > 80 && prosperity > 70) return '繁栄';
    if (stability > 50 && prosperity > 50) return '安定';
    if (stability > 30 && prosperity > 30) return '不安定';
    return '危険';
  }
}

/// 季節
enum Season {
  spring, // 春
  summer, // 夏
  autumn, // 秋
  winter, // 冬
}

/// エンカウント
class EncounterData {
  final EncounterType type;
  final int difficulty;
  final int reward;
  final String? territoryId;

  EncounterData({
    required this.type,
    required this.difficulty,
    required this.reward,
    this.territoryId,
  });

  /// エンカウント名を取得
  String getName() {
    switch (type) {
      case EncounterType.wildBeast:
        return '野獣との遭遇';
      case EncounterType.bandits:
        return '盗賊との遭遇';
      case EncounterType.magicalBeast:
        return '魔獣との遭遇';
      case EncounterType.none:
        return 'なし';
    }
  }

  /// エンカウントの説明を取得
  String getDescription() {
    switch (type) {
      case EncounterType.wildBeast:
        return '野生の獣があなたに近づいてきた';
      case EncounterType.bandits:
        return '盗賊集団があなたを襲った';
      case EncounterType.magicalBeast:
        return '魔獣があなたの前に現れた';
      case EncounterType.none:
        return 'エンカウントはありません';
    }
  }
}

/// エンカウントの種類
enum EncounterType {
  wildBeast, // 野獣
  bandits, // 盗賊
  magicalBeast, // 魔獣
  none, // なし
}
