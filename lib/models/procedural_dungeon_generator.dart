/// 手続き的ダンジョン生成システム
/// 迷路生成、ルームレイアウト、敵配置、トレジャー配置

import 'dart:math' as math;

/// 手続き的ダンジョン生成システム
class ProceduralDungeonGenerator {
  static final ProceduralDungeonGenerator _instance =
      ProceduralDungeonGenerator._internal();

  factory ProceduralDungeonGenerator.getInstance() {
    return _instance;
  }

  ProceduralDungeonGenerator._internal();

  final math.Random _random = math.Random();

  /// ダンジョンマップを生成
  GeneratedDungeonMap generateDungeonMap(
    int width,
    int height,
    DungeonGenerationParams params,
  ) {
    // 初期化：すべてを壁に設定
    List<List<DungeonTile>> tiles = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) => DungeonTile(
          x: x,
          y: y,
          type: DungeonTileType.wall,
        ),
      ),
    );

    // ルームを作成
    final rooms = _generateRooms(width, height, params);

    // ルームを彫刻
    for (final room in rooms) {
      _carvRoom(tiles, room);
    }

    // ルーム間に通路を作成
    for (int i = 0; i < rooms.length - 1; i++) {
      _connectRooms(tiles, rooms[i], rooms[i + 1]);
    }

    // エンティティをスポーン
    final entities = _spawnEntities(tiles, rooms, params);

    return GeneratedDungeonMap(
      width: width,
      height: height,
      tiles: tiles,
      rooms: rooms,
      entities: entities,
    );
  }

  /// ルームを生成
  List<DungeonRoom> _generateRooms(
    int width,
    int height,
    DungeonGenerationParams params,
  ) {
    final rooms = <DungeonRoom>[];
    final attempts = 20;

    for (int attempt = 0; attempt < attempts; attempt++) {
      final roomWidth = _random.nextInt(
            params.maxRoomWidth - params.minRoomWidth + 1,
          ) +
          params.minRoomWidth;
      final roomHeight = _random.nextInt(
            params.maxRoomHeight - params.minRoomHeight + 1,
          ) +
          params.minRoomHeight;

      final x = _random.nextInt(width - roomWidth - 2) + 1;
      final y = _random.nextInt(height - roomHeight - 2) + 1;

      final newRoom = DungeonRoom(
        x: x,
        y: y,
        width: roomWidth,
        height: roomHeight,
        id: 'room_${rooms.length}',
      );

      // 他のルームとの衝突をチェック
      bool overlaps = false;
      for (final existingRoom in rooms) {
        if (_roomsOverlap(newRoom, existingRoom)) {
          overlaps = true;
          break;
        }
      }

      if (!overlaps) {
        rooms.add(newRoom);
      }
    }

    return rooms;
  }

  /// ルームを彫刻
  void _carvRoom(
    List<List<DungeonTile>> tiles,
    DungeonRoom room,
  ) {
    for (int y = room.y; y < room.y + room.height; y++) {
      for (int x = room.x; x < room.x + room.width; x++) {
        if (y >= 0 && y < tiles.length && x >= 0 && x < tiles[0].length) {
          tiles[y][x].type = DungeonTileType.floor;
          tiles[y][x].roomId = room.id;
        }
      }
    }
  }

  /// ルーム間を接続
  void _connectRooms(
    List<List<DungeonTile>> tiles,
    DungeonRoom room1,
    DungeonRoom room2,
  ) {
    // ルームの中心を取得
    final x1 = room1.x + room1.width ~/ 2;
    final y1 = room1.y + room1.height ~/ 2;
    final x2 = room2.x + room2.width ~/ 2;
    final y2 = room2.y + room2.height ~/ 2;

    // 水平通路を作成
    final startX = x1 < x2 ? x1 : x2;
    final endX = x1 < x2 ? x2 : x1;
    for (int x = startX; x <= endX; x++) {
      if (y1 >= 0 && y1 < tiles.length && x >= 0 && x < tiles[0].length) {
        tiles[y1][x].type = DungeonTileType.floor;
      }
    }

    // 垂直通路を作成
    final startY = y1 < y2 ? y1 : y2;
    final endY = y1 < y2 ? y2 : y1;
    for (int y = startY; y <= endY; y++) {
      if (y >= 0 && y < tiles.length && x2 >= 0 && x2 < tiles[0].length) {
        tiles[y][x2].type = DungeonTileType.floor;
      }
    }
  }

  /// ルームが重なっているかチェック
  bool _roomsOverlap(DungeonRoom room1, DungeonRoom room2) {
    return room1.x < room2.x + room2.width &&
        room1.x + room1.width > room2.x &&
        room1.y < room2.y + room2.height &&
        room1.y + room1.height > room2.y;
  }

  /// エンティティをスポーン
  List<DungeonEntity> _spawnEntities(
    List<List<DungeonTile>> tiles,
    List<DungeonRoom> rooms,
    DungeonGenerationParams params,
  ) {
    final entities = <DungeonEntity>[];

    // 各ルームに敵をスポーン
    for (int i = 1; i < rooms.length; i++) {
      final room = rooms[i];
      final enemyCount = _random.nextInt(
            params.maxEnemiesPerRoom - params.minEnemiesPerRoom + 1,
          ) +
          params.minEnemiesPerRoom;

      for (int j = 0; j < enemyCount; j++) {
        final x = _random.nextInt(room.width) + room.x;
        final y = _random.nextInt(room.height) + room.y;

        entities.add(DungeonEntity(
          id: 'enemy_${entities.length}',
          type: DungeonEntityType.enemy,
          x: x,
          y: y,
          roomId: room.id,
        ));
      }

      // トレジャーをスポーン
      if (_random.nextDouble() < params.treasureSpawnRate) {
        final x = _random.nextInt(room.width) + room.x;
        final y = _random.nextInt(room.height) + room.y;

        entities.add(DungeonEntity(
          id: 'treasure_${entities.length}',
          type: DungeonEntityType.treasure,
          x: x,
          y: y,
          roomId: room.id,
        ));
      }
    }

    // 最後のルームにボスをスポーン
    if (rooms.isNotEmpty) {
      final bossRoom = rooms.last;
      final bossX = bossRoom.x + bossRoom.width ~/ 2;
      final bossY = bossRoom.y + bossRoom.height ~/ 2;

      entities.add(DungeonEntity(
        id: 'boss',
        type: DungeonEntityType.boss,
        x: bossX,
        y: bossY,
        roomId: bossRoom.id,
      ));
    }

    // プレイヤースポーンポイント（最初のルーム）
    if (rooms.isNotEmpty) {
      final spawnRoom = rooms.first;
      entities.add(DungeonEntity(
        id: 'spawn',
        type: DungeonEntityType.spawnPoint,
        x: spawnRoom.x + spawnRoom.width ~/ 2,
        y: spawnRoom.y + spawnRoom.height ~/ 2,
        roomId: spawnRoom.id,
      ));
    }

    return entities;
  }

  /// 難易度に基づいてパラメータを調整
  DungeonGenerationParams getParametersForDifficulty(
    int difficulty,
    int width,
    int height,
  ) {
    // 難易度が高いほど複雑になる
    final complexity = difficulty / 10.0;

    return DungeonGenerationParams(
      minRoomWidth: 6,
      maxRoomWidth: (12 + (complexity * 8)).toInt(),
      minRoomHeight: 6,
      maxRoomHeight: (12 + (complexity * 8)).toInt(),
      minEnemiesPerRoom: (1 + (difficulty * 0.2)).toInt(),
      maxEnemiesPerRoom: (3 + (difficulty * 0.5)).toInt(),
      treasureSpawnRate: 0.2 + (complexity * 0.3),
    );
  }
}

/// ダンジョン生成パラメータ
class DungeonGenerationParams {
  final int minRoomWidth;
  final int maxRoomWidth;
  final int minRoomHeight;
  final int maxRoomHeight;
  final int minEnemiesPerRoom;
  final int maxEnemiesPerRoom;
  final double treasureSpawnRate;

  DungeonGenerationParams({
    required this.minRoomWidth,
    required this.maxRoomWidth,
    required this.minRoomHeight,
    required this.maxRoomHeight,
    required this.minEnemiesPerRoom,
    required this.maxEnemiesPerRoom,
    required this.treasureSpawnRate,
  });
}

/// 生成されたダンジョンマップ
class GeneratedDungeonMap {
  final int width;
  final int height;
  final List<List<DungeonTile>> tiles;
  final List<DungeonRoom> rooms;
  final List<DungeonEntity> entities;

  GeneratedDungeonMap({
    required this.width,
    required this.height,
    required this.tiles,
    required this.rooms,
    required this.entities,
  });

  /// 特定のタイプのエンティティを取得
  List<DungeonEntity> getEntitiesOfType(DungeonEntityType type) {
    return entities.where((e) => e.type == type).toList();
  }

  /// プレイヤースポーンポイントを取得
  DungeonEntity? getSpawnPoint() {
    return entities.cast<DungeonEntity?>().firstWhere(
      (e) => e?.type == DungeonEntityType.spawnPoint,
      orElse: () => null,
    );
  }

  /// ボスの位置を取得
  DungeonEntity? getBossLocation() {
    return entities.cast<DungeonEntity?>().firstWhere(
      (e) => e?.type == DungeonEntityType.boss,
      orElse: () => null,
    );
  }

  /// ダンジョンレイアウト統計を取得
  DungeonMapStats getStats() {
    int floorTiles = 0;
    int wallTiles = 0;

    for (final row in tiles) {
      for (final tile in row) {
        if (tile.type == DungeonTileType.floor) {
          floorTiles++;
        } else {
          wallTiles++;
        }
      }
    }

    return DungeonMapStats(
      width: width,
      height: height,
      totalTiles: width * height,
      floorTiles: floorTiles,
      wallTiles: wallTiles,
      roomCount: rooms.length,
      entityCount: entities.length,
      enemyCount: entities.where((e) => e.type == DungeonEntityType.enemy).length,
      treasureCount: entities.where((e) => e.type == DungeonEntityType.treasure).length,
    );
  }
}

/// ダンジョンタイル
class DungeonTile {
  final int x;
  final int y;
  DungeonTileType type;
  String? roomId;
  bool isVisited = false;

  DungeonTile({
    required this.x,
    required this.y,
    required this.type,
    this.roomId,
  });
}

/// ダンジョンタイルタイプ
enum DungeonTileType {
  floor,     // 床
  wall,      // 壁
  trap,      // トラップ
  water,     // 水
  lava,      // 溶岩
}

/// ダンジョンルーム
class DungeonRoom {
  final String id;
  final int x;
  final int y;
  final int width;
  final int height;

  DungeonRoom({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// ルームの中心を取得
  Offset getCenter() {
    return Offset(
      x + width / 2.0,
      y + height / 2.0,
    );
  }

  /// ルームの面積を計算
  int getArea() => width * height;
}

/// ダンジョンエンティティ
class DungeonEntity {
  final String id;
  final DungeonEntityType type;
  int x;
  int y;
  final String roomId;

  DungeonEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.roomId,
  });
}

/// ダンジョンエンティティタイプ
enum DungeonEntityType {
  enemy,        // 敵
  boss,         // ボス
  treasure,     // トレジャー
  trap,         // トラップ
  spawnPoint,   // プレイヤースポーン
  exit,         // 出口
  npc,          // NPC
}

/// ダンジョンマップ統計
class DungeonMapStats {
  final int width;
  final int height;
  final int totalTiles;
  final int floorTiles;
  final int wallTiles;
  final int roomCount;
  final int entityCount;
  final int enemyCount;
  final int treasureCount;

  DungeonMapStats({
    required this.width,
    required this.height,
    required this.totalTiles,
    required this.floorTiles,
    required this.wallTiles,
    required this.roomCount,
    required this.entityCount,
    required this.enemyCount,
    required this.treasureCount,
  });

  /// 床の割合を取得
  double getFloorPercentage() => floorTiles / totalTiles;

  /// ルーム間の平均距離を計算
  double getAverageRoomDensity() => roomCount / (floorTiles / 100.0);
}

/// オフセット
class Offset {
  final double x;
  final double y;

  Offset(this.x, this.y);
}
