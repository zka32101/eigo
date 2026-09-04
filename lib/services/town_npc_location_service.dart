import 'package:eigo/models/npc_location_model.dart';
import 'package:eigo/models/english_town_model.dart';

/// NPCの位置管理サービス
class TownNPCLocationService {
  static final TownNPCLocationService _instance =
      TownNPCLocationService._internal();

  factory TownNPCLocationService.getInstance() {
    return _instance;
  }

  TownNPCLocationService._internal();

  /// NPC位置情報を初期化
  TownMapNPCData initializeNPCLocations(
    String areaId,
    List<NPC> npcsInArea,
  ) {
    final npcLocations = npcsInArea.map((npc) {
      final coordinate = NPCCoordinate.fromPositionString(npc.position);
      return NPCLocation(
        npcId: npc.npcId,
        name: npc.name,
        emoji: npc.emoji,
        areaId: areaId,
        coordinate: coordinate,
        isMovable: true,
        profession: npc.profession,
        lastUpdatedAt: DateTime.now(),
      );
    }).toList();

    // 標準的なスポーン位置を生成
    final spawnPoints = _generateSpawnPoints(areaId);

    return TownMapNPCData(
      mapId: 'map_$areaId',
      areaId: areaId,
      npcLocations: npcLocations,
      spawnPoints: spawnPoints,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// エリアのスポーン位置を生成
  List<NPCCoordinate> _generateSpawnPoints(String areaId) {
    // エリアの種類に応じてスポーン位置を配置
    final basePoints = [
      NPCCoordinate(x: 0.2, y: 0.3),
      NPCCoordinate(x: 0.5, y: 0.2),
      NPCCoordinate(x: 0.8, y: 0.4),
      NPCCoordinate(x: 0.3, y: 0.7),
      NPCCoordinate(x: 0.7, y: 0.6),
    ];

    return basePoints;
  }

  /// NPCを新しい位置に移動
  NPCLocation moveNPC(
    NPCLocation npc,
    NPCCoordinate newCoordinate,
  ) {
    if (!npc.isMovable) {
      return npc;
    }

    // 座標が範囲外でないか確認
    final validX = newCoordinate.x.clamp(0.0, 1.0);
    final validY = newCoordinate.y.clamp(0.0, 1.0);
    final validCoordinate = NPCCoordinate(x: validX, y: validY);

    return npc.copyWith(
      coordinate: validCoordinate,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// NPCの状態を更新
  NPCLocation updateNPCState(
    NPCLocation npc,
    String newState,
  ) {
    return npc.copyWith(
      currentState: newState,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// 指定座標に最も近いNPCを取得
  NPCLocation? getNearestNPC(
    List<NPCLocation> npcs,
    NPCCoordinate playerCoordinate,
    double proximityThreshold,
  ) {
    NPCLocation? nearest;
    double? minDistance;

    for (final npc in npcs) {
      final distance = _calculateDistance(
        playerCoordinate,
        npc.coordinate,
      );

      if (distance <= proximityThreshold) {
        if (minDistance == null || distance < minDistance) {
          minDistance = distance;
          nearest = npc;
        }
      }
    }

    return nearest;
  }

  /// 2つの座標間の距離を計算
  double _calculateDistance(NPCCoordinate a, NPCCoordinate b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return (dx * dx + dy * dy).toDouble().sqrt();
  }

  /// プレイヤーの範囲内にいるNPCを取得
  List<NPCLocation> getNPCsInRange(
    List<NPCLocation> npcs,
    NPCCoordinate playerCoordinate,
    double rangeRadius,
  ) {
    return npcs
        .where((npc) {
          final distance = _calculateDistance(playerCoordinate, npc.coordinate);
          return distance <= rangeRadius;
        })
        .toList()
      ..sort((a, b) {
        final distA = _calculateDistance(playerCoordinate, a.coordinate);
        final distB = _calculateDistance(playerCoordinate, b.coordinate);
        return distA.compareTo(distB);
      });
  }

  /// タウンマップNPCデータを更新
  TownMapNPCData updateTownMapNPCData(
    TownMapNPCData data,
    List<NPCLocation> updatedNPCLocations,
  ) {
    return data.copyWith(
      npcLocations: updatedNPCLocations,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// NPCの相互作用イベントを作成
  NPCInteractionEvent createInteractionEvent(
    String eventType,
    String npcId,
  ) {
    return NPCInteractionEvent(
      eventType: eventType,
      npcId: npcId,
      timestamp: DateTime.now(),
    );
  }

  /// 複数のNPCを指定座標に配置（初期化用）
  List<NPCLocation> arrangeNPCsAtSpawnPoints(
    List<NPCLocation> npcs,
    List<NPCCoordinate> spawnPoints,
  ) {
    final arrangedNPCs = <NPCLocation>[];

    for (int i = 0; i < npcs.length && i < spawnPoints.length; i++) {
      arrangedNPCs.add(
        npcs[i].copyWith(coordinate: spawnPoints[i]),
      );
    }

    // スポーン位置より多いNPCは元の位置に残す
    for (int i = spawnPoints.length; i < npcs.length; i++) {
      arrangedNPCs.add(npcs[i]);
    }

    return arrangedNPCs;
  }

  /// ランダムなスポーン位置を選択
  NPCCoordinate? selectRandomSpawnPoint(
    List<NPCCoordinate> spawnPoints,
  ) {
    if (spawnPoints.isEmpty) return null;

    final randomIndex = DateTime.now().millisecond % spawnPoints.length;
    return spawnPoints[randomIndex];
  }
}
