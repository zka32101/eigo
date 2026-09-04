/// インベントリ・装備システム
/// アイテム管理、装備スロット、統計ボーナス、アイテムレアリティ

/// インベントリシステム
class InventorySystem {
  static final InventorySystem _instance = InventorySystem._internal();

  factory InventorySystem.getInstance() {
    return _instance;
  }

  InventorySystem._internal();

  // プレイヤーインベントリ: player_id -> PlayerInventory
  final Map<String, PlayerInventory> _inventories = {};

  // アイテム定義: item_id -> Item
  final Map<String, Item> _itemDefinitions = {};

  // 装備セット: equipment_set_id -> EquipmentSet
  final Map<String, EquipmentSet> _equipmentSets = {};

  /// システムを初期化
  void initialize() {
    _inventories.clear();
    _itemDefinitions.clear();
    _equipmentSets.clear();
    _initializeAllItems();
    _initializeEquipmentSets();
  }

  /// すべてのアイテムを初期化
  void _initializeAllItems() {
    // 武器
    _registerItem(Item(
      id: 'iron_sword',
      name: 'Iron Sword',
      rarity: ItemRarity.common,
      type: ItemType.weapon,
      weight: 5,
      goldValue: 100,
      description: 'A basic iron sword',
      stats: {'attack': 5, 'critical': 2},
      slotType: EquipmentSlot.weapon,
      level: 1,
    ));

    _registerItem(Item(
      id: 'steel_sword',
      name: 'Steel Sword',
      rarity: ItemRarity.uncommon,
      type: ItemType.weapon,
      weight: 6,
      goldValue: 300,
      description: 'A sturdy steel sword',
      stats: {'attack': 10, 'critical': 4},
      slotType: EquipmentSlot.weapon,
      level: 10,
    ));

    _registerItem(Item(
      id: 'legendary_blade',
      name: 'Legendary Blade',
      rarity: ItemRarity.legendary,
      type: ItemType.weapon,
      weight: 7,
      goldValue: 2000,
      description: 'A weapon of immense power',
      stats: {'attack': 30, 'critical': 15},
      slotType: EquipmentSlot.weapon,
      level: 40,
    ));

    // 防具
    _registerItem(Item(
      id: 'leather_armor',
      name: 'Leather Armor',
      rarity: ItemRarity.common,
      type: ItemType.armor,
      weight: 8,
      goldValue: 80,
      description: 'Light leather protection',
      stats: {'defense': 3, 'health': 20},
      slotType: EquipmentSlot.chest,
      level: 1,
    ));

    _registerItem(Item(
      id: 'iron_armor',
      name: 'Iron Armor',
      rarity: ItemRarity.uncommon,
      type: ItemType.armor,
      weight: 12,
      goldValue: 250,
      description: 'Heavy iron protection',
      stats: {'defense': 8, 'health': 50},
      slotType: EquipmentSlot.chest,
      level: 10,
    ));

    _registerItem(Item(
      id: 'dragon_scale_armor',
      name: 'Dragon Scale Armor',
      rarity: ItemRarity.epic,
      type: ItemType.armor,
      weight: 15,
      goldValue: 1500,
      description: 'Armor crafted from dragon scales',
      stats: {'defense': 20, 'health': 150, 'fire_resistance': 30},
      slotType: EquipmentSlot.chest,
      level: 35,
    ));

    // ヘルメット
    _registerItem(Item(
      id: 'iron_helmet',
      name: 'Iron Helmet',
      rarity: ItemRarity.common,
      type: ItemType.armor,
      weight: 3,
      goldValue: 50,
      description: 'Basic iron helmet',
      stats: {'defense': 2, 'health': 15},
      slotType: EquipmentSlot.head,
      level: 1,
    ));

    // グローブ
    _registerItem(Item(
      id: 'leather_gloves',
      name: 'Leather Gloves',
      rarity: ItemRarity.common,
      type: ItemType.armor,
      weight: 1,
      goldValue: 30,
      description: 'Light protective gloves',
      stats: {'defense': 1, 'attack': 2},
      slotType: EquipmentSlot.hands,
      level: 1,
    ));

    // ブーツ
    _registerItem(Item(
      id: 'leather_boots',
      name: 'Leather Boots',
      rarity: ItemRarity.common,
      type: ItemType.armor,
      weight: 2,
      goldValue: 40,
      description: 'Comfortable leather boots',
      stats: {'defense': 1, 'movement_speed': 10},
      slotType: EquipmentSlot.feet,
      level: 1,
    ));

    // アクセサリー
    _registerItem(Item(
      id: 'ruby_ring',
      name: 'Ruby Ring',
      rarity: ItemRarity.rare,
      type: ItemType.accessory,
      weight: 0,
      goldValue: 500,
      description: 'Enhances fire magic',
      stats: {'magic': 5, 'fire_damage': 15},
      slotType: EquipmentSlot.ring,
      level: 15,
    ));

    _registerItem(Item(
      id: 'mana_necklace',
      name: 'Mana Necklace',
      rarity: ItemRarity.rare,
      type: ItemType.accessory,
      weight: 0,
      goldValue: 450,
      description: 'Increases mana capacity',
      stats: {'mana': 50, 'magic_regen': 5},
      slotType: EquipmentSlot.neck,
      level: 12,
    ));

    // 消耗品
    _registerItem(Item(
      id: 'health_potion',
      name: 'Health Potion',
      rarity: ItemRarity.common,
      type: ItemType.consumable,
      weight: 1,
      goldValue: 25,
      description: 'Restores 50 health',
      stats: {'heal_amount': 50},
      stackable: true,
      maxStack: 20,
      level: 1,
    ));

    _registerItem(Item(
      id: 'mana_potion',
      name: 'Mana Potion',
      rarity: ItemRarity.common,
      type: ItemType.consumable,
      weight: 1,
      goldValue: 20,
      description: 'Restores 30 mana',
      stats: {'mana_restore': 30},
      stackable: true,
      maxStack: 20,
      level: 1,
    ));

    // クエストアイテム
    _registerItem(Item(
      id: 'ancient_key',
      name: 'Ancient Key',
      rarity: ItemRarity.rare,
      type: ItemType.quest,
      weight: 2,
      goldValue: 0,
      description: 'Opens an ancient door',
      stats: {},
      stackable: false,
      level: 20,
    ));
  }

  /// 装備セットを初期化
  void _initializeEquipmentSets() {
    // 初級戦士セット
    _registerEquipmentSet(EquipmentSet(
      id: 'novice_warrior',
      name: 'Novice Warrior',
      description: 'Basic starting equipment',
      items: ['iron_sword', 'leather_armor', 'iron_helmet', 'leather_gloves', 'leather_boots'],
      setBonuses: {
        'attack': 3,
        'defense': 5,
        'health': 30,
      },
      level: 1,
    ));

    // 熟練戦士セット
    _registerEquipmentSet(EquipmentSet(
      id: 'veteran_warrior',
      name: 'Veteran Warrior',
      description: 'Intermediate equipment set',
      items: ['steel_sword', 'iron_armor', 'iron_helmet', 'leather_gloves', 'leather_boots'],
      setBonuses: {
        'attack': 8,
        'defense': 12,
        'health': 80,
      },
      level: 10,
    ));

    // ドラゴンスレイヤーセット
    _registerEquipmentSet(EquipmentSet(
      id: 'dragon_slayer',
      name: 'Dragon Slayer',
      description: 'Advanced equipment for dragon hunters',
      items: ['legendary_blade', 'dragon_scale_armor', 'ruby_ring', 'mana_necklace'],
      setBonuses: {
        'attack': 25,
        'defense': 25,
        'health': 200,
        'fire_resistance': 50,
      },
      level: 35,
    ));
  }

  /// アイテムを登録
  void _registerItem(Item item) {
    _itemDefinitions[item.id] = item;
  }

  /// 装備セットを登録
  void _registerEquipmentSet(EquipmentSet set) {
    _equipmentSets[set.id] = set;
  }

  /// プレイヤーのインベントリを取得または作成
  PlayerInventory getOrCreateInventory(String playerId) {
    return _inventories.putIfAbsent(
      playerId,
      () => PlayerInventory(
        playerId: playerId,
        items: {},
        equipment: PlayerEquipment(),
        capacity: 30,
        gold: 1000,
      ),
    );
  }

  /// アイテムを取得
  Item? getItem(String itemId) {
    return _itemDefinitions[itemId];
  }

  /// すべてのアイテムを取得
  List<Item> getAllItems() {
    return _itemDefinitions.values.toList();
  }

  /// タイプ別アイテムを取得
  List<Item> getItemsByType(ItemType type) {
    return _itemDefinitions.values
        .where((item) => item.type == type)
        .toList();
  }

  /// レアリティ別アイテムを取得
  List<Item> getItemsByRarity(ItemRarity rarity) {
    return _itemDefinitions.values
        .where((item) => item.rarity == rarity)
        .toList();
  }

  /// インベントリにアイテムを追加
  bool addItemToInventory(String playerId, String itemId, int quantity) {
    final inventory = getOrCreateInventory(playerId);
    final item = _itemDefinitions[itemId];

    if (item == null) return false;

    // 容量チェック
    int usedSlots = 0;
    for (final entry in inventory.items.entries) {
      final stackItem = _itemDefinitions[entry.key];
      if (stackItem?.stackable ?? false) {
        usedSlots += 1;
      } else {
        usedSlots += entry.value;
      }
    }

    if (usedSlots >= inventory.capacity) return false;

    // アイテムを追加
    if (item.stackable) {
      inventory.items[itemId] = (inventory.items[itemId] ?? 0) + quantity;
      // スタック上限をチェック
      if ((inventory.items[itemId] ?? 0) > (item.maxStack ?? 1)) {
        inventory.items[itemId] = item.maxStack ?? 1;
      }
    } else {
      for (int i = 0; i < quantity; i++) {
        if (usedSlots >= inventory.capacity) break;
        inventory.items[itemId] = (inventory.items[itemId] ?? 0) + 1;
        usedSlots++;
      }
    }

    return true;
  }

  /// インベントリからアイテムを削除
  bool removeItemFromInventory(String playerId, String itemId, int quantity) {
    final inventory = getOrCreateInventory(playerId);
    final currentQuantity = inventory.items[itemId] ?? 0;

    if (currentQuantity < quantity) return false;

    inventory.items[itemId] = currentQuantity - quantity;

    if ((inventory.items[itemId] ?? 0) <= 0) {
      inventory.items.remove(itemId);
    }

    return true;
  }

  /// アイテムを装備
  bool equipItem(String playerId, String itemId) {
    final inventory = getOrCreateInventory(playerId);
    final item = _itemDefinitions[itemId];

    if (item == null || item.slotType == null) return false;

    // インベントリに持っているかチェック
    if ((inventory.items[itemId] ?? 0) <= 0) return false;

    // 既に装備している場合は入れ替え
    final slot = item.slotType!;
    final previousItem = _getEquippedItemInSlot(inventory, slot);
    if (previousItem != null) {
      addItemToInventory(playerId, previousItem.id, 1);
    }

    // 装備する
    _setEquipmentSlot(inventory, slot, item);
    removeItemFromInventory(playerId, itemId, 1);

    return true;
  }

  /// アイテムを脱装
  bool unequipItem(String playerId, EquipmentSlot slot) {
    final inventory = getOrCreateInventory(playerId);
    final item = _getEquippedItemInSlot(inventory, slot);

    if (item == null) return false;

    // インベントリに追加
    if (!addItemToInventory(playerId, item.id, 1)) return false;

    // 装備を外す
    _clearEquipmentSlot(inventory, slot);

    return true;
  }

  /// 装備スロットのアイテムを取得
  Item? _getEquippedItemInSlot(PlayerInventory inventory, EquipmentSlot slot) {
    final itemId = _getEquipmentSlotId(inventory, slot);
    if (itemId == null) return null;
    return _itemDefinitions[itemId];
  }

  /// 装備スロットにアイテムを設定
  void _setEquipmentSlot(PlayerInventory inventory, EquipmentSlot slot, Item item) {
    switch (slot) {
      case EquipmentSlot.head:
        inventory.equipment.head = item.id;
        break;
      case EquipmentSlot.neck:
        inventory.equipment.neck = item.id;
        break;
      case EquipmentSlot.chest:
        inventory.equipment.chest = item.id;
        break;
      case EquipmentSlot.hands:
        inventory.equipment.hands = item.id;
        break;
      case EquipmentSlot.feet:
        inventory.equipment.feet = item.id;
        break;
      case EquipmentSlot.weapon:
        inventory.equipment.weapon = item.id;
        break;
      case EquipmentSlot.shield:
        inventory.equipment.shield = item.id;
        break;
      case EquipmentSlot.ring:
        inventory.equipment.ring = item.id;
        break;
    }
  }

  /// 装備スロットを取得
  String? _getEquipmentSlotId(PlayerInventory inventory, EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.head:
        return inventory.equipment.head;
      case EquipmentSlot.neck:
        return inventory.equipment.neck;
      case EquipmentSlot.chest:
        return inventory.equipment.chest;
      case EquipmentSlot.hands:
        return inventory.equipment.hands;
      case EquipmentSlot.feet:
        return inventory.equipment.feet;
      case EquipmentSlot.weapon:
        return inventory.equipment.weapon;
      case EquipmentSlot.shield:
        return inventory.equipment.shield;
      case EquipmentSlot.ring:
        return inventory.equipment.ring;
    }
  }

  /// 装備スロットをクリア
  void _clearEquipmentSlot(PlayerInventory inventory, EquipmentSlot slot) {
    _setEquipmentSlot(inventory, slot, Item(
      id: '',
      name: '',
      rarity: ItemRarity.common,
      type: ItemType.weapon,
      weight: 0,
      goldValue: 0,
      description: '',
      stats: {},
      level: 0,
    ));
  }

  /// 装備統計を計算
  EquipmentStats calculateEquipmentStats(String playerId) {
    final inventory = getOrCreateInventory(playerId);
    final Map<String, int> totalStats = {};

    // 装備中のアイテムから統計を集計
    final equippedItems = <Item>[];
    for (final itemId in [
      inventory.equipment.head,
      inventory.equipment.neck,
      inventory.equipment.chest,
      inventory.equipment.hands,
      inventory.equipment.feet,
      inventory.equipment.weapon,
      inventory.equipment.shield,
      inventory.equipment.ring,
    ]) {
      if (itemId != null && itemId.isNotEmpty) {
        final item = _itemDefinitions[itemId];
        if (item != null) {
          equippedItems.add(item);
        }
      }
    }

    // すべての統計を合算
    for (final item in equippedItems) {
      item.stats.forEach((key, value) {
        totalStats[key] = (totalStats[key] ?? 0) + value;
      });
    }

    return EquipmentStats(
      totalStats: totalStats,
      equippedItems: equippedItems,
      totalWeight: equippedItems.fold(0, (sum, item) => sum + item.weight),
    );
  }

  /// ゴールドを追加
  bool addGold(String playerId, int amount) {
    final inventory = getOrCreateInventory(playerId);
    inventory.gold += amount;
    return true;
  }

  /// ゴールドを消費
  bool spendGold(String playerId, int amount) {
    final inventory = getOrCreateInventory(playerId);
    if (inventory.gold < amount) return false;
    inventory.gold -= amount;
    return true;
  }

  /// インベントリの使用容量を取得
  int getUsedCapacity(String playerId) {
    final inventory = getOrCreateInventory(playerId);
    int used = 0;

    for (final entry in inventory.items.entries) {
      final item = _itemDefinitions[entry.key];
      if (item?.stackable ?? false) {
        used += 1;
      } else {
        used += entry.value;
      }
    }

    return used;
  }

  /// 装備セットを適用
  bool applyEquipmentSet(String playerId, String setId) {
    final set = _equipmentSets[setId];
    if (set == null) return false;

    // セットのすべてのアイテムを装備
    for (final itemId in set.items) {
      if (!addItemToInventory(playerId, itemId, 1)) {
        return false;
      }
    }

    return true;
  }
}

/// プレイヤーインベントリ
class PlayerInventory {
  final String playerId;
  final Map<String, int> items;
  final PlayerEquipment equipment;
  int capacity;
  int gold;

  PlayerInventory({
    required this.playerId,
    required this.items,
    required this.equipment,
    required this.capacity,
    required this.gold,
  });

  /// インベントリがいっぱいか確認
  bool isFull() {
    int used = 0;
    for (final count in items.values) {
      used += count;
    }
    return used >= capacity;
  }

  /// インベントリの使用率を取得
  double getUsagePercentage() {
    int used = 0;
    for (final count in items.values) {
      used += count;
    }
    return used / capacity;
  }
}

/// プレイヤーの装備
class PlayerEquipment {
  String? head;
  String? neck;
  String? chest;
  String? hands;
  String? feet;
  String? weapon;
  String? shield;
  String? ring;

  PlayerEquipment({
    this.head,
    this.neck,
    this.chest,
    this.hands,
    this.feet,
    this.weapon,
    this.shield,
    this.ring,
  });

  /// すべての装備を取得
  List<String?> getAllEquipped() {
    return [head, neck, chest, hands, feet, weapon, shield, ring];
  }

  /// 装備数を取得
  int getEquippedCount() {
    return getAllEquipped().where((item) => item != null && item.isNotEmpty).length;
  }
}

/// アイテム定義
class Item {
  final String id;
  final String name;
  final ItemRarity rarity;
  final ItemType type;
  final int weight;
  final int goldValue;
  final String description;
  final Map<String, int> stats;
  final EquipmentSlot? slotType;
  final int level;
  final bool stackable;
  final int? maxStack;

  Item({
    required this.id,
    required this.name,
    required this.rarity,
    required this.type,
    required this.weight,
    required this.goldValue,
    required this.description,
    required this.stats,
    this.slotType,
    required this.level,
    this.stackable = false,
    this.maxStack,
  });

  /// アイテムのレアリティ乗数を取得
  double getRarityMultiplier() {
    switch (rarity) {
      case ItemRarity.common:
        return 1.0;
      case ItemRarity.uncommon:
        return 1.3;
      case ItemRarity.rare:
        return 1.7;
      case ItemRarity.epic:
        return 2.2;
      case ItemRarity.legendary:
        return 3.0;
    }
  }
}

/// アイテムレアリティ
enum ItemRarity {
  common,    // よくある
  uncommon,  // アンコモン
  rare,      // レア
  epic,      // エピック
  legendary, // レジェンダリー
}

/// アイテムタイプ
enum ItemType {
  weapon,    // 武器
  armor,     // 防具
  accessory, // アクセサリー
  consumable,// 消耗品
  quest,     // クエストアイテム
  material,  // 素材
}

/// 装備スロット
enum EquipmentSlot {
  head,      // ヘッド
  neck,      // ネック
  chest,     // チェスト
  hands,     // ハンズ
  feet,      // フィート
  weapon,    // 武器
  shield,    // シールド
  ring,      // リング
}

/// 装備統計
class EquipmentStats {
  final Map<String, int> totalStats;
  final List<Item> equippedItems;
  final int totalWeight;

  EquipmentStats({
    required this.totalStats,
    required this.equippedItems,
    required this.totalWeight,
  });

  /// 特定の統計を取得
  int getStat(String statName) {
    return totalStats[statName] ?? 0;
  }

  /// 総合レベルを計算
  int getTotalLevel() {
    return equippedItems.fold(0, (sum, item) => sum + item.level);
  }
}

/// 装備セット
class EquipmentSet {
  final String id;
  final String name;
  final String description;
  final List<String> items;
  final Map<String, int> setBonuses;
  final int level;

  EquipmentSet({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    required this.setBonuses,
    required this.level,
  });

  /// セットボーナスを取得
  int getSetBonus(String statName) {
    return setBonuses[statName] ?? 0;
  }

  /// 総合パワースコアを計算
  int getPowerScore() {
    return setBonuses.values.fold(0, (sum, bonus) => sum + bonus);
  }
}
