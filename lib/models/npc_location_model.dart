import 'package:json_annotation/json_annotation.dart';

part 'npc_location_model.g.dart';

/// NPC地点座標
@JsonSerializable()
class NPCCoordinate {
  /// X座標（0.0-1.0の相対位置）
  final double x;

  /// Y座標（0.0-1.0の相対位置）
  final double y;

  NPCCoordinate({
    required this.x,
    required this.y,
  });

  factory NPCCoordinate.fromJson(Map<String, dynamic> json) =>
      _$NPCCoordinateFromJson(json);

  Map<String, dynamic> toJson() => _$NPCCoordinateToJson(this);

  /// 文字列形式から座標を作成（"x:100,y:200"）
  static NPCCoordinate fromPositionString(String position) {
    final parts = position.split(',');
    double x = 0.0;
    double y = 0.0;

    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        final value = double.tryParse(keyValue[1]) ?? 0.0;
        if (keyValue[0] == 'x') x = value / 320.0; // Normalize to 0-1
        if (keyValue[0] == 'y') y = value / 568.0; // Normalize to 0-1
      }
    }

    return NPCCoordinate(x: x.clamp(0.0, 1.0), y: y.clamp(0.0, 1.0));
  }

  /// 座標を文字列形式に変換
  String toPositionString() {
    return 'x:${(x * 320).toInt()},y:${(y * 568).toInt()}';
  }
}

/// NPC位置情報
@JsonSerializable()
class NPCLocation {
  /// NPC ID
  final String npcId;

  /// NPC名
  final String name;

  /// NPC絵文字
  final String emoji;

  /// エリアID
  final String areaId;

  /// 座標
  final NPCCoordinate coordinate;

  /// 移動可能か
  final bool isMovable;

  /// NPC職業
  final String profession;

  /// 現在の状態（idle, moving, talking）
  final String currentState;

  /// 最終更新時刻
  final DateTime lastUpdatedAt;

  NPCLocation({
    required this.npcId,
    required this.name,
    required this.emoji,
    required this.areaId,
    required this.coordinate,
    required this.isMovable,
    required this.profession,
    this.currentState = 'idle',
    required this.lastUpdatedAt,
  });

  factory NPCLocation.fromJson(Map<String, dynamic> json) =>
      _$NPCLocationFromJson(json);

  Map<String, dynamic> toJson() => _$NPCLocationToJson(this);

  /// コピー関数
  NPCLocation copyWith({
    String? npcId,
    String? name,
    String? emoji,
    String? areaId,
    NPCCoordinate? coordinate,
    bool? isMovable,
    String? profession,
    String? currentState,
    DateTime? lastUpdatedAt,
  }) {
    return NPCLocation(
      npcId: npcId ?? this.npcId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      areaId: areaId ?? this.areaId,
      coordinate: coordinate ?? this.coordinate,
      isMovable: isMovable ?? this.isMovable,
      profession: profession ?? this.profession,
      currentState: currentState ?? this.currentState,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

/// タウンマップNPC管理
@JsonSerializable()
class TownMapNPCData {
  /// マップID
  final String mapId;

  /// エリアID
  final String areaId;

  /// NPC位置情報リスト
  final List<NPCLocation> npcLocations;

  /// スポーン可能な位置のリスト
  final List<NPCCoordinate> spawnPoints;

  /// 最終更新時刻
  final DateTime lastUpdatedAt;

  TownMapNPCData({
    required this.mapId,
    required this.areaId,
    required this.npcLocations,
    required this.spawnPoints,
    required this.lastUpdatedAt,
  });

  factory TownMapNPCData.fromJson(Map<String, dynamic> json) =>
      _$TownMapNPCDataFromJson(json);

  Map<String, dynamic> toJson() => _$TownMapNPCDataToJson(this);

  /// コピー関数
  TownMapNPCData copyWith({
    String? mapId,
    String? areaId,
    List<NPCLocation>? npcLocations,
    List<NPCCoordinate>? spawnPoints,
    DateTime? lastUpdatedAt,
  }) {
    return TownMapNPCData(
      mapId: mapId ?? this.mapId,
      areaId: areaId ?? this.areaId,
      npcLocations: npcLocations ?? this.npcLocations,
      spawnPoints: spawnPoints ?? this.spawnPoints,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

/// NPC相互作用イベント
class NPCInteractionEvent {
  /// イベントタイプ
  final String eventType; // "approach", "talk", "leave"

  /// NPC ID
  final String npcId;

  /// イベント発生時刻
  final DateTime timestamp;

  /// イベント詳細
  final Map<String, dynamic> eventData;

  NPCInteractionEvent({
    required this.eventType,
    required this.npcId,
    required this.timestamp,
    this.eventData = const {},
  });
}
