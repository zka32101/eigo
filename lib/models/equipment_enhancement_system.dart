/// 装備強化・クラフトシステム
/// アイテム強化、エンチャント、合成、分解

/// 装備強化システム
class EquipmentEnhancementSystem {
  static final EquipmentEnhancementSystem _instance =
      EquipmentEnhancementSystem._internal();

  factory EquipmentEnhancementSystem.getInstance() {
    return _instance;
  }

  EquipmentEnhancementSystem._internal();

  // プレイヤーの強化記録: player_id -> item_id -> EnhancedItem
  final Map<String, Map<String, EnhancedItem>> _enhancedItems = {};

  // クラフトレシピ: recipe_id -> CraftingRecipe
  final Map<String, CraftingRecipe> _recipes = {};

  // エンチャント効果: enchantment_id -> Enchantment
  final Map<String, Enchantment> _enchantments = {};

  /// システムを初期化
  void initialize() {
    _enhancedItems.clear();
    _recipes.clear();
    _enchantments.clear();
    _initializeAllRecipes();
    _initializeAllEnchantments();
  }

  /// すべてのクラフトレシピを初期化
  void _initializeAllRecipes() {
    // 鉄の剣を作成
    _registerRecipe(CraftingRecipe(
      id: 'craft_iron_sword',
      name: 'Craft Iron Sword',
      outputItemId: 'iron_sword',
      outputQuantity: 1,
      materials: {
        'iron_ore': 5,
        'wood': 2,
      },
      goldCost: 50,
      skillRequired: 5,
      craftTime: 300, // 秒
      difficulty: CraftingDifficulty.easy,
    ));

    // 鋼の剣を作成
    _registerRecipe(CraftingRecipe(
      id: 'craft_steel_sword',
      name: 'Craft Steel Sword',
      outputItemId: 'steel_sword',
      outputQuantity: 1,
      materials: {
        'iron_ore': 10,
        'steel_ingot': 3,
        'wood': 3,
      },
      goldCost: 150,
      skillRequired: 20,
      craftTime: 600,
      difficulty: CraftingDifficulty.medium,
    ));

    // 革鎧を作成
    _registerRecipe(CraftingRecipe(
      id: 'craft_leather_armor',
      name: 'Craft Leather Armor',
      outputItemId: 'leather_armor',
      outputQuantity: 1,
      materials: {
        'leather': 8,
        'thread': 2,
      },
      goldCost: 40,
      skillRequired: 10,
      craftTime: 400,
      difficulty: CraftingDifficulty.easy,
    ));

    // 鉄の鎧を作成
    _registerRecipe(CraftingRecipe(
      id: 'craft_iron_armor',
      name: 'Craft Iron Armor',
      outputItemId: 'iron_armor',
      outputQuantity: 1,
      materials: {
        'iron_ore': 15,
        'leather': 5,
        'thread': 3,
      },
      goldCost: 120,
      skillRequired: 25,
      craftTime: 800,
      difficulty: CraftingDifficulty.medium,
    ));

    // ポーション制作
    _registerRecipe(CraftingRecipe(
      id: 'craft_health_potion',
      name: 'Brew Health Potion',
      outputItemId: 'health_potion',
      outputQuantity: 5,
      materials: {
        'herbs': 3,
        'water': 1,
        'bottle': 5,
      },
      goldCost: 10,
      skillRequired: 5,
      craftTime: 180,
      difficulty: CraftingDifficulty.easy,
    ));

    // 高級ポーション制作
    _registerRecipe(CraftingRecipe(
      id: 'craft_mana_potion',
      name: 'Brew Mana Potion',
      outputItemId: 'mana_potion',
      outputQuantity: 5,
      materials: {
        'mana_herb': 4,
        'crystal_powder': 1,
        'water': 2,
        'bottle': 5,
      },
      goldCost: 30,
      skillRequired: 15,
      craftTime: 300,
      difficulty: CraftingDifficulty.medium,
    ));
  }

  /// すべてのエンチャント効果を初期化
  void _initializeAllEnchantments() {
    // 火のエンチャント
    _registerEnchantment(Enchantment(
      id: 'enchant_fire',
      name: 'Fire Enchantment',
      description: 'Adds fire damage to attacks',
      level: 1,
      goldCost: 100,
      materialsCost: {'crystal': 1},
      bonusStats: {'fire_damage': 10},
      durability: 100,
    ));

    // 氷のエンチャント
    _registerEnchantment(Enchantment(
      id: 'enchant_ice',
      name: 'Ice Enchantment',
      description: 'Adds ice damage and slows enemies',
      level: 1,
      goldCost: 100,
      materialsCost: {'crystal': 1},
      bonusStats: {'ice_damage': 10, 'slow': 5},
      durability: 100,
    ));

    // 力のエンチャント
    _registerEnchantment(Enchantment(
      id: 'enchant_strength',
      name: 'Strength Enchantment',
      description: 'Increases attack power',
      level: 2,
      goldCost: 200,
      materialsCost: {'crystal': 2, 'mithril': 1},
      bonusStats: {'attack': 15},
      durability: 150,
    ));

    // 防御のエンチャント
    _registerEnchantment(Enchantment(
      id: 'enchant_protection',
      name: 'Protection Enchantment',
      description: 'Increases defense',
      level: 2,
      goldCost: 200,
      materialsCost: {'crystal': 2},
      bonusStats: {'defense': 15},
      durability: 150,
    ));

    // 命のエンチャント
    _registerEnchantment(Enchantment(
      id: 'enchant_vitality',
      name: 'Vitality Enchantment',
      description: 'Increases maximum health',
      level: 3,
      goldCost: 400,
      materialsCost: {'crystal': 3, 'mithril': 2},
      bonusStats: {'health': 50},
      durability: 200,
    ));
  }

  /// レシピを登録
  void _registerRecipe(CraftingRecipe recipe) {
    _recipes[recipe.id] = recipe;
  }

  /// エンチャント効果を登録
  void _registerEnchantment(Enchantment enchantment) {
    _enchantments[enchantment.id] = enchantment;
  }

  /// アイテムを強化
  bool enhanceItem(
    String playerId,
    String itemId,
    EnhancementType type,
    int cost,
  ) {
    if (!_enhancedItems.containsKey(playerId)) {
      _enhancedItems[playerId] = {};
    }

    final playerEnhancements = _enhancedItems[playerId]!;
    final enhanced = playerEnhancements.putIfAbsent(
      itemId,
      () => EnhancedItem(
        itemId: itemId,
        enhancement: 0,
        durability: 100,
        enchantments: [],
      ),
    );

    // 強化レベルに基づいた成功率
    final successRate = _calculateSuccessRate(enhanced.enhancement);

    // 成功判定
    if ((enhanced.enhancement + 1) > 20) {
      return false; // 最大強化レベル
    }

    final random = (DateTime.now().millisecondsSinceEpoch % 100).toDouble() / 100;
    if (random < successRate) {
      enhanced.enhancement++;
      enhanced.durability = 100;
      return true;
    }

    // 失敗時は耐久度が低下
    enhanced.durability -= 10;
    return false;
  }

  /// アイテムにエンチャントを追加
  bool addEnchantment(
    String playerId,
    String itemId,
    String enchantmentId,
  ) {
    if (!_enhancedItems.containsKey(playerId)) {
      _enhancedItems[playerId] = {};
    }

    final playerEnhancements = _enhancedItems[playerId]!;
    final enchantment = _enchantments[enchantmentId];

    if (enchantment == null) return false;

    final enhanced = playerEnhancements.putIfAbsent(
      itemId,
      () => EnhancedItem(
        itemId: itemId,
        enhancement: 0,
        durability: 100,
        enchantments: [],
      ),
    );

    // 既に同じエンチャントがあるかチェック
    if (enhanced.enchantments.contains(enchantmentId)) {
      return false;
    }

    // 最大エンチャント数をチェック
    if (enhanced.enchantments.length >= 3) {
      return false;
    }

    enhanced.enchantments.add(enchantmentId);
    return true;
  }

  /// アイテムを合成
  bool craftItem(
    String playerId,
    String recipeId,
    Map<String, int> inventory,
    int playerGold,
  ) {
    final recipe = _recipes[recipeId];
    if (recipe == null) return false;

    // 材料をチェック
    for (final entry in recipe.materials.entries) {
      if ((inventory[entry.key] ?? 0) < entry.value) {
        return false;
      }
    }

    // ゴールドをチェック
    if (playerGold < recipe.goldCost) {
      return false;
    }

    return true;
  }

  /// アイテムを分解
  Map<String, int> disassembleItem(String itemId) {
    // アイテムの素材を取得
    final materials = <String, int>{};

    // 基本的な分解ルール
    if (itemId.contains('sword')) {
      materials['iron_ore'] = 3;
      materials['wood'] = 1;
    } else if (itemId.contains('armor')) {
      materials['leather'] = 3;
      materials['iron_ore'] = 2;
    } else if (itemId.contains('potion')) {
      materials['herbs'] = 1;
      materials['bottle'] = 1;
    }

    return materials;
  }

  /// 強化成功率を計算
  double _calculateSuccessRate(int currentEnhancement) {
    // 強化レベルが高いほど成功率が低くなる
    return (100.0 - (currentEnhancement * 5)) / 100.0;
  }

  /// アイテムの総合ボーナスを計算
  Map<String, int> calculateItemBonuses(String playerId, String itemId) {
    final enhancedItems = _enhancedItems[playerId];
    if (enhancedItems == null) return {};

    final enhanced = enhancedItems[itemId];
    if (enhanced == null) return {};

    final bonuses = <String, int>{};

    // 強化ボーナス（レベル×5%）
    final enhancementMultiplier = 1.0 + (enhanced.enhancement * 0.05);

    // エンチャントボーナス
    for (final enchantmentId in enhanced.enchantments) {
      final enchantment = _enchantments[enchantmentId];
      if (enchantment != null) {
        enchantment.bonusStats.forEach((key, value) {
          bonuses[key] = (bonuses[key] ?? 0) + (value * enhancementMultiplier).toInt();
        });
      }
    }

    return bonuses;
  }

  /// アイテムの耐久度を取得
  int getItemDurability(String playerId, String itemId) {
    final enhanced = _enhancedItems[playerId]?[itemId];
    return enhanced?.durability ?? 100;
  }

  /// 耐久度を復旧
  bool repairItem(String playerId, String itemId, int goldCost) {
    if (!_enhancedItems.containsKey(playerId)) return false;

    final enhanced = _enhancedItems[playerId]![itemId];
    if (enhanced == null) return false;

    enhanced.durability = 100;
    return true;
  }

  /// クラフトレシピを取得
  CraftingRecipe? getRecipe(String recipeId) {
    return _recipes[recipeId];
  }

  /// すべてのレシピを取得
  List<CraftingRecipe> getAllRecipes() {
    return _recipes.values.toList();
  }

  /// スキルレベル別レシピを取得
  List<CraftingRecipe> getRecipesBySkillLevel(int skillLevel) {
    return _recipes.values
        .where((r) => r.skillRequired <= skillLevel)
        .toList();
  }

  /// エンチャント効果を取得
  Enchantment? getEnchantment(String enchantmentId) {
    return _enchantments[enchantmentId];
  }

  /// 難易度別エンチャントを取得
  List<Enchantment> getEnchantmentsByLevel(int level) {
    return _enchantments.values
        .where((e) => e.level <= level)
        .toList();
  }
}

/// 強化されたアイテム
class EnhancedItem {
  final String itemId;
  int enhancement; // 強化レベル 0-20
  int durability; // 耐久度 0-100
  final List<String> enchantments; // エンチャント効果ID

  EnhancedItem({
    required this.itemId,
    required this.enhancement,
    required this.durability,
    required this.enchantments,
  });

  /// アイテムの総合パワーを計算
  int getPowerLevel() {
    return (enhancement * 10) + (enchantments.length * 15);
  }

  /// 耐久度が低いか確認
  bool isDamaged() {
    return durability < 50;
  }
}

/// クラフトレシピ
class CraftingRecipe {
  final String id;
  final String name;
  final String outputItemId;
  final int outputQuantity;
  final Map<String, int> materials;
  final int goldCost;
  final int skillRequired;
  final int craftTime; // 秒
  final CraftingDifficulty difficulty;

  CraftingRecipe({
    required this.id,
    required this.name,
    required this.outputItemId,
    required this.outputQuantity,
    required this.materials,
    required this.goldCost,
    required this.skillRequired,
    required this.craftTime,
    required this.difficulty,
  });

  /// クラフト難易度を説明
  String getDifficultyText() {
    switch (difficulty) {
      case CraftingDifficulty.easy:
        return 'Easy';
      case CraftingDifficulty.medium:
        return 'Medium';
      case CraftingDifficulty.hard:
        return 'Hard';
      case CraftingDifficulty.legendary:
        return 'Legendary';
    }
  }
}

/// クラフト難易度
enum CraftingDifficulty {
  easy,      // 簡単
  medium,    // 中程度
  hard,      // 難しい
  legendary, // レジェンダリー
}

/// 強化タイプ
enum EnhancementType {
  increase,  // ランクアップ
  repair,    // 修理
  purify,    // 浄化
}

/// エンチャント効果
class Enchantment {
  final String id;
  final String name;
  final String description;
  final int level; // 1-3
  final int goldCost;
  final Map<String, int> materialsCost;
  final Map<String, int> bonusStats;
  final int durability; // 最大耐久度

  Enchantment({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.goldCost,
    required this.materialsCost,
    required this.bonusStats,
    required this.durability,
  });

  /// エンチャントのパワースコア
  int getPowerScore() {
    return bonusStats.values.fold(0, (sum, stat) => sum + stat) * level;
  }
}
