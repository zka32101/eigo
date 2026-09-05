/// プレイヤーハウジングシステム
/// ホーム自動化、家具配置、ストレージ、家のアップグレード

/// ハウジングシステム
class HousingSystem {
  static final HousingSystem _instance = HousingSystem._internal();

  factory HousingSystem.getInstance() {
    return _instance;
  }

  HousingSystem._internal();

  // プレイヤーの家: player_id -> PlayerHouse
  final Map<String, PlayerHouse> _playerHouses = {};

  // 利用可能な家具: furniture_id -> FurnitureDefinition
  final Map<String, FurnitureDefinition> _furnitureDefinitions = {};

  /// システムを初期化
  void initialize() {
    _playerHouses.clear();
    _furnitureDefinitions.clear();
    _initializeAllFurniture();
  }

  /// プレイヤーIDでハウスを取得（存在しなければ作成）
  PlayerHouse getOrCreateHouse(String playerId) {
    return _playerHouses.putIfAbsent(
      playerId,
      () => PlayerHouse(
        playerId: playerId,
        houseName: 'My Home',
        rooms: [
          Room(
            id: 'living_room',
            name: 'Living Room',
            type: RoomType.livingRoom,
            width: 10,
            height: 10,
            decorations: [],
          ),
          Room(
            id: 'bedroom',
            name: 'Bedroom',
            type: RoomType.bedroom,
            width: 8,
            height: 8,
            decorations: [],
          ),
          Room(
            id: 'kitchen',
            name: 'Kitchen',
            type: RoomType.kitchen,
            width: 8,
            height: 6,
            decorations: [],
          ),
        ],
        storageItems: [],
        upgrades: [],
        level: 1,
        experience: 0,
      ),
    );
  }

  /// すべての家具定義を初期化
  void _initializeAllFurniture() {
    // リビング家具
    _registerFurniture(FurnitureDefinition(
      id: 'sofa_leather',
      name: 'Leather Sofa',
      category: FurnitureCategory.seating,
      width: 3,
      height: 2,
      costGold: 500,
      costMaterials: {'wood': 10, 'leather': 5},
      description: 'A comfortable leather sofa for relaxation',
      happiness: 15,
      rarity: FurnitureRarity.common,
    ));

    _registerFurniture(FurnitureDefinition(
      id: 'bookshelf',
      name: 'Wooden Bookshelf',
      category: FurnitureCategory.storage,
      width: 2,
      height: 3,
      costGold: 300,
      costMaterials: {'wood': 8},
      description: 'A sturdy bookshelf to display your collection',
      happiness: 10,
      rarity: FurnitureRarity.common,
    ));

    _registerFurniture(FurnitureDefinition(
      id: 'fireplace',
      name: 'Marble Fireplace',
      category: FurnitureCategory.decoration,
      width: 2,
      height: 3,
      costGold: 800,
      costMaterials: {'marble': 15, 'coal': 5},
      description: 'A beautiful marble fireplace that radiates warmth',
      happiness: 25,
      rarity: FurnitureRarity.uncommon,
    ));

    // 寝室家具
    _registerFurniture(FurnitureDefinition(
      id: 'bed_king',
      name: 'King Bed',
      category: FurnitureCategory.furniture,
      width: 3,
      height: 3,
      costGold: 1000,
      costMaterials: {'wood': 20, 'silk': 10},
      description: 'A luxurious king-sized bed for restful sleep',
      happiness: 30,
      rarity: FurnitureRarity.uncommon,
    ));

    _registerFurniture(FurnitureDefinition(
      id: 'wardrobe',
      name: 'Oak Wardrobe',
      category: FurnitureCategory.storage,
      width: 2,
      height: 3,
      costGold: 600,
      costMaterials: {'wood': 12},
      description: 'A spacious wardrobe for your clothing collection',
      happiness: 10,
      rarity: FurnitureRarity.common,
    ));

    // キッチン家具
    _registerFurniture(FurnitureDefinition(
      id: 'stove',
      name: 'Iron Stove',
      category: FurnitureCategory.furniture,
      width: 2,
      height: 2,
      costGold: 700,
      costMaterials: {'iron': 15, 'wood': 5},
      description: 'A sturdy iron stove for cooking delicious meals',
      happiness: 20,
      rarity: FurnitureRarity.uncommon,
    ));

    _registerFurniture(FurnitureDefinition(
      id: 'dining_table',
      name: 'Dining Table',
      category: FurnitureCategory.furniture,
      width: 3,
      height: 2,
      costGold: 400,
      costMaterials: {'wood': 10},
      description: 'A sturdy wooden dining table for gatherings',
      happiness: 15,
      rarity: FurnitureRarity.common,
    ));

    // 装飾品
    _registerFurniture(FurnitureDefinition(
      id: 'painting_sunset',
      name: 'Sunset Painting',
      category: FurnitureCategory.decoration,
      width: 1,
      height: 1,
      costGold: 200,
      costMaterials: {'paint': 3, 'canvas': 2},
      description: 'A beautiful painting of a sunset',
      happiness: 12,
      rarity: FurnitureRarity.common,
    ));

    _registerFurniture(FurnitureDefinition(
      id: 'chandelier_crystal',
      name: 'Crystal Chandelier',
      category: FurnitureCategory.decoration,
      width: 2,
      height: 2,
      costGold: 1500,
      costMaterials: {'crystal': 20, 'gold': 10},
      description: 'An exquisite crystal chandelier that sparkles beautifully',
      happiness: 40,
      rarity: FurnitureRarity.rare,
    ));

    _registerFurniture(FurnitureDefinition(
      id: 'plant_potted',
      name: 'Potted Plant',
      category: FurnitureCategory.decoration,
      width: 1,
      height: 1,
      costGold: 100,
      costMaterials: {'clay': 2},
      description: 'A fresh potted plant to brighten your home',
      happiness: 8,
      rarity: FurnitureRarity.common,
    ));
  }

  /// 家具定義を登録
  void _registerFurniture(FurnitureDefinition furniture) {
    _furnitureDefinitions[furniture.id] = furniture;
  }

  /// 家具定義を取得
  FurnitureDefinition? getFurnitureDefinition(String furnitureId) {
    return _furnitureDefinitions[furnitureId];
  }

  /// すべての家具定義を取得
  List<FurnitureDefinition> getAllFurnitures() {
    return _furnitureDefinitions.values.toList();
  }

  /// カテゴリ別の家具を取得
  List<FurnitureDefinition> getFurnitureByCategory(
      FurnitureCategory category) {
    return _furnitureDefinitions.values
        .where((f) => f.category == category)
        .toList();
  }

  /// レアリティ別の家具を取得
  List<FurnitureDefinition> getFurnitureByRarity(FurnitureRarity rarity) {
    return _furnitureDefinitions.values
        .where((f) => f.rarity == rarity)
        .toList();
  }

  /// 家具をルームに配置
  bool placeFurniture(
    String playerId,
    String roomId,
    String furnitureId,
    int x,
    int y,
  ) {
    final house = _playerHouses[playerId];
    if (house == null) return false;

    final room = house.rooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => null as Room,
    );
    if (room == null) return false;

    final furniture = _furnitureDefinitions[furnitureId];
    if (furniture == null) return false;

    // 配置可能かチェック
    if (!_canPlaceFurniture(room, furniture, x, y)) {
      return false;
    }

    final decoration = Decoration(
      furnitureId: furnitureId,
      x: x,
      y: y,
      rotation: 0,
      placedAt: DateTime.now(),
    );

    room.decorations.add(decoration);
    return true;
  }

  /// 家具が配置可能かチェック
  bool _canPlaceFurniture(Room room, FurnitureDefinition furniture, int x, int y) {
    // 範囲チェック
    if (x < 0 || y < 0) return false;
    if (x + furniture.width > room.width) return false;
    if (y + furniture.height > room.height) return false;

    // 他の家具との衝突チェック
    for (final decoration in room.decorations) {
      final existingFurniture = _furnitureDefinitions[decoration.furnitureId];
      if (existingFurniture == null) continue;

      // 衝突判定
      if (_rectsIntersect(
        x, y, furniture.width, furniture.height,
        decoration.x, decoration.y,
        existingFurniture.width, existingFurniture.height,
      )) {
        return false;
      }
    }

    return true;
  }

  /// 矩形が交差しているかチェック
  bool _rectsIntersect(int x1, int y1, int w1, int h1,
                       int x2, int y2, int w2, int h2) {
    return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
  }

  /// 家具を回転
  void rotateFurniture(String playerId, String roomId, int decorationIndex) {
    final house = _playerHouses[playerId];
    if (house == null) return;

    final room = house.rooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => null as Room,
    );
    if (room == null || decorationIndex >= room.decorations.length) return;

    room.decorations[decorationIndex].rotation =
        (room.decorations[decorationIndex].rotation + 90) % 360;
  }

  /// 家具を削除
  bool removeFurniture(String playerId, String roomId, int decorationIndex) {
    final house = _playerHouses[playerId];
    if (house == null) return false;

    final room = house.rooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => null as Room,
    );
    if (room == null || decorationIndex >= room.decorations.length) {
      return false;
    }

    room.decorations.removeAt(decorationIndex);
    return true;
  }

  /// ハウスの幸福度を計算
  int calculateHappiness(String playerId) {
    final house = _playerHouses[playerId];
    if (house == null) return 0;

    int totalHappiness = 0;
    for (final room in house.rooms) {
      for (final decoration in room.decorations) {
        final furniture = _furnitureDefinitions[decoration.furnitureId];
        if (furniture != null) {
          totalHappiness += furniture.happiness;
        }
      }
    }

    return totalHappiness;
  }

  /// ハウスをアップグレード
  bool upgradeHouse(String playerId, HouseUpgrade upgrade) {
    final house = _playerHouses[playerId];
    if (house == null) return false;

    // レベルチェック
    if (house.level < upgrade.requiredLevel) return false;

    house.upgrades.add(upgrade);
    house.experience += upgrade.experienceGain;

    // レベルアップチェック
    while (house.experience >= house.level * 100) {
      house.level++;
      house.experience -= house.level * 100;
    }

    return true;
  }

  /// ハウス情報を取得
  HouseInfo getHouseInfo(String playerId) {
    final house = _playerHouses[playerId];
    if (house == null) {
      return HouseInfo(
        houseName: 'No House',
        level: 0,
        happiness: 0,
        totalFurniture: 0,
        rooms: 0,
      );
    }

    int totalFurniture = 0;
    for (final room in house.rooms) {
      totalFurniture += room.decorations.length;
    }

    return HouseInfo(
      houseName: house.houseName,
      level: house.level,
      happiness: calculateHappiness(playerId),
      totalFurniture: totalFurniture,
      rooms: house.rooms.length,
    );
  }
}

/// プレイヤーの家
class PlayerHouse {
  final String playerId;
  String houseName;
  final List<Room> rooms;
  final List<HouseItem> storageItems;
  final List<HouseUpgrade> upgrades;
  int level;
  int experience;

  PlayerHouse({
    required this.playerId,
    required this.houseName,
    required this.rooms,
    required this.storageItems,
    required this.upgrades,
    required this.level,
    required this.experience,
  });

  /// 総ストレージサイズを計算
  int getTotalStorageCapacity() {
    int capacity = 20; // ベース容量
    for (final upgrade in upgrades) {
      capacity += upgrade.storageBonus;
    }
    return capacity;
  }

  /// 使用中のストレージを計算
  int getUsedStorage() {
    return storageItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// ストレージに余裕があるかチェック
  bool hasStorageSpace() {
    return getUsedStorage() < getTotalStorageCapacity();
  }
}

/// ルーム
class Room {
  final String id;
  final String name;
  final RoomType type;
  final int width;
  final int height;
  final List<Decoration> decorations;

  Room({
    required this.id,
    required this.name,
    required this.type,
    required this.width,
    required this.height,
    required this.decorations,
  });

  /// ルームの装飾品数
  int getDecorationCount() {
    return decorations.length;
  }

  /// ルームの使用面積を計算
  int getUsedArea() {
    int used = 0;
    for (final decoration in decorations) {
      // 装飾品のサイズ情報が必要
      used += 2; // 簡略版：各装飾品を2ユニット
    }
    return used;
  }
}

/// ルームタイプ
enum RoomType {
  livingRoom,
  bedroom,
  kitchen,
  bathroom,
  garage,
  garden,
}

/// 装飾品（配置された家具）
class Decoration {
  final String furnitureId;
  int x;
  int y;
  int rotation; // 0, 90, 180, 270
  final DateTime placedAt;

  Decoration({
    required this.furnitureId,
    required this.x,
    required this.y,
    required this.rotation,
    required this.placedAt,
  });
}

/// 家具定義
class FurnitureDefinition {
  final String id;
  final String name;
  final FurnitureCategory category;
  final int width;
  final int height;
  final int costGold;
  final Map<String, int> costMaterials;
  final String description;
  final int happiness; // 幸福度への寄与
  final FurnitureRarity rarity;

  FurnitureDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.width,
    required this.height,
    required this.costGold,
    required this.costMaterials,
    required this.description,
    required this.happiness,
    required this.rarity,
  });

  /// レアリティを文字列で表示
  String getRarityText() {
    switch (rarity) {
      case FurnitureRarity.common:
        return 'Common';
      case FurnitureRarity.uncommon:
        return 'Uncommon';
      case FurnitureRarity.rare:
        return 'Rare';
      case FurnitureRarity.epic:
        return 'Epic';
      case FurnitureRarity.legendary:
        return 'Legendary';
    }
  }

  /// サイズを文字列で表示
  String getSizeText() {
    return '${width}x${height}';
  }
}

/// 家具カテゴリ
enum FurnitureCategory {
  seating,
  storage,
  furniture,
  decoration,
  lighting,
  plants,
}

/// 家具レアリティ
enum FurnitureRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// ハウスアイテム（ストレージ内）
class HouseItem {
  final String itemId;
  final String itemName;
  int quantity;

  HouseItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
  });
}

/// ハウスアップグレード
class HouseUpgrade {
  final String id;
  final String name;
  final String description;
  final int requiredLevel;
  final int costGold;
  final int storageBonus;
  final int experienceGain;
  final List<String> unlockedRooms; // 新しく利用可能になるルームID

  HouseUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.costGold,
    required this.storageBonus,
    required this.experienceGain,
    required this.unlockedRooms,
  });
}

/// ハウス情報
class HouseInfo {
  final String houseName;
  final int level;
  final int happiness;
  final int totalFurniture;
  final int rooms;

  HouseInfo({
    required this.houseName,
    required this.level,
    required this.happiness,
    required this.totalFurniture,
    required this.rooms,
  });
}
