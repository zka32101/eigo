/// ダンジョン探索システム
/// 迷路生成、敵エンカウンター、トレジャー、難易度スケーリング

import 'dart:math' as math;

/// ダンジョンシステム
class DungeonSystem {
  static final DungeonSystem _instance = DungeonSystem._internal();

  factory DungeonSystem.getInstance() {
    return _instance;
  }

  DungeonSystem._internal();

  // ダンジョン定義: dungeon_id -> Dungeon
  final Map<String, Dungeon> _dungeons = {};

  // ダンジョンフロア: dungeon_id -> List<DungeonFloor>
  final Map<String, List<DungeonFloor>> _dungeonFloors = {};

  // プレイヤーの進捗: player_id -> DungeonProgress
  final Map<String, DungeonProgress> _playerProgress = {};

  // 敵定義: enemy_id -> Enemy
  final Map<String, Enemy> _enemies = {};

  // ボス定義: boss_id -> BossEnemy
  final Map<String, BossEnemy> _bosses = {};

  // トレジャーチェスト定義: treasure_id -> Treasure
  final Map<String, Treasure> _treasures = {};

  /// システムを初期化
  void initialize() {
    _dungeons.clear();
    _dungeonFloors.clear();
    _playerProgress.clear();
    _enemies.clear();
    _bosses.clear();
    _treasures.clear();
    _initializeAllDungeons();
  }

  /// すべてのダンジョンを初期化
  void _initializeAllDungeons() {
    // 魔法研究所ダンジョン
    _registerDungeon(Dungeon(
      id: 'arcane_research_facility',
      name: 'Arcane Research Facility',
      description: 'A mystical dungeon filled with magical experiments',
      region: 'Mage Tower',
      difficulty: DungeonDifficulty.easy,
      recommendedLevel: 5,
      minPlayerCount: 1,
      maxPlayerCount: 4,
      floorCount: 5,
      bossId: 'boss_arcane_construct',
      rewards: DungeonReward(
        baseGold: 500,
        baseExperience: 800,
        questProgress: 25,
      ),
      biomeType: BiomeType.arcane,
    ));

    // 地下採掘場ダンジョン
    _registerDungeon(Dungeon(
      id: 'crystal_mines',
      name: 'Crystal Mines',
      description: 'Ancient mines deep beneath the mountains',
      region: 'Crystal Mountains',
      difficulty: DungeonDifficulty.medium,
      recommendedLevel: 15,
      minPlayerCount: 2,
      maxPlayerCount: 4,
      floorCount: 8,
      bossId: 'boss_crystal_guardian',
      rewards: DungeonReward(
        baseGold: 1200,
        baseExperience: 1500,
        questProgress: 40,
      ),
      biomeType: BiomeType.mineral,
    ));

    // 古代森林遺跡ダンジョン
    _registerDungeon(Dungeon(
      id: 'ancient_forest_ruins',
      name: 'Ancient Forest Ruins',
      description: 'Mysterious ruins hidden in the forest',
      region: 'Ancient Forest',
      difficulty: DungeonDifficulty.hard,
      recommendedLevel: 25,
      minPlayerCount: 3,
      maxPlayerCount: 4,
      floorCount: 10,
      bossId: 'boss_forest_elder',
      rewards: DungeonReward(
        baseGold: 2000,
        baseExperience: 2500,
        questProgress: 60,
      ),
      biomeType: BiomeType.natural,
    ));

    // 破壊された城塞ダンジョン
    _registerDungeon(Dungeon(
      id: 'shattered_fortress',
      name: 'Shattered Fortress',
      description: 'A war-torn fortress filled with undead',
      region: 'Neutral Zone',
      difficulty: DungeonDifficulty.legendary,
      recommendedLevel: 40,
      minPlayerCount: 4,
      maxPlayerCount: 4,
      floorCount: 15,
      bossId: 'boss_undead_king',
      rewards: DungeonReward(
        baseGold: 5000,
        baseExperience: 5000,
        questProgress: 100,
      ),
      biomeType: BiomeType.undead,
    ));

    // ダンジョンフロアを初期化
    _initializeAllFloors();

    // 敵定義を初期化
    _initializeAllEnemies();

    // ボス定義を初期化
    _initializeAllBosses();

    // トレジャー定義を初期化
    _initializeAllTreasures();
  }

  /// ダンジョンフロアを初期化
  void _initializeAllFloors() {
    // 研究所フロア（5フロア）
    final arcaneFloors = <DungeonFloor>[];
    for (int i = 1; i <= 5; i++) {
      arcaneFloors.add(DungeonFloor(
        id: 'arcane_floor_$i',
        floorNumber: i,
        width: 10,
        height: 10,
        enemyEncounters: i <= 3 ? ['weak_golem', 'arcane_imp'] : ['strong_golem', 'mage_construct'],
        treasureChance: 0.4 + (i * 0.1),
        difficulty: i <= 2 ? DungeonDifficulty.easy : DungeonDifficulty.medium,
        isBossFloor: i == 5,
        hasShop: i % 2 == 0,
        hazards: i > 2 ? ['arcane_trap', 'mana_drain'] : [],
      ));
    }
    _dungeonFloors['arcane_research_facility'] = arcaneFloors;

    // 鉱山フロア（8フロア）
    final mineFloors = <DungeonFloor>[];
    for (int i = 1; i <= 8; i++) {
      mineFloors.add(DungeonFloor(
        id: 'mine_floor_$i',
        floorNumber: i,
        width: 12,
        height: 12,
        enemyEncounters: i <= 3 ? ['stone_golem', 'crystal_bug'] : i <= 6 ? ['iron_golem', 'crystal_spider'] : ['obsidian_golem', 'crystal_dragon'],
        treasureChance: 0.3 + (i * 0.08),
        difficulty: i <= 3 ? DungeonDifficulty.easy : i <= 6 ? DungeonDifficulty.medium : DungeonDifficulty.hard,
        isBossFloor: i == 8,
        hasShop: i % 3 == 0,
        hazards: i > 4 ? ['cave_collapse', 'toxic_gas'] : [],
      ));
    }
    _dungeonFloors['crystal_mines'] = mineFloors;
  }

  /// すべての敵を初期化
  void _initializeAllEnemies() {
    // 弱いゴーレム
    _registerEnemy(Enemy(
      id: 'weak_golem',
      name: 'Weak Golem',
      level: 3,
      healthPoints: 30,
      attackPower: 5,
      defenseRating: 2,
      experience: 50,
      goldReward: 25,
      rarity: EnemyRarity.common,
    ));

    // アルケイン・インプ
    _registerEnemy(Enemy(
      id: 'arcane_imp',
      name: 'Arcane Imp',
      level: 4,
      healthPoints: 20,
      attackPower: 8,
      defenseRating: 1,
      experience: 75,
      goldReward: 40,
      rarity: EnemyRarity.common,
    ));

    // 強いゴーレム
    _registerEnemy(Enemy(
      id: 'strong_golem',
      name: 'Strong Golem',
      level: 8,
      healthPoints: 60,
      attackPower: 12,
      defenseRating: 5,
      experience: 200,
      goldReward: 100,
      rarity: EnemyRarity.uncommon,
    ));

    // ストーンゴーレム
    _registerEnemy(Enemy(
      id: 'stone_golem',
      name: 'Stone Golem',
      level: 10,
      healthPoints: 80,
      attackPower: 10,
      defenseRating: 8,
      experience: 250,
      goldReward: 150,
      rarity: EnemyRarity.uncommon,
    ));

    // クリスタルバグ
    _registerEnemy(Enemy(
      id: 'crystal_bug',
      name: 'Crystal Bug',
      level: 9,
      healthPoints: 40,
      attackPower: 14,
      defenseRating: 2,
      experience: 180,
      goldReward: 120,
      rarity: EnemyRarity.uncommon,
    ));
  }

  /// すべてのボスを初期化
  void _initializeAllBosses() {
    // アルケイン・コンストラクト（研究所ボス）
    _registerBoss(BossEnemy(
      id: 'boss_arcane_construct',
      name: 'Arcane Construct',
      description: 'A massive magical golem constructed to guard the research',
      level: 8,
      healthPoints: 200,
      attackPower: 15,
      defenseRating: 8,
      experience: 500,
      goldReward: 300,
      rarity: EnemyRarity.rare,
      specialAbilities: ['arcane_blast', 'mana_shield'],
      phaseCount: 2,
      lootTableIds: ['boss_loot_arcane'],
      minPartyLevel: 5,
      recommendedPartySize: 2,
    ));

    // クリスタル・ガーディアン（鉱山ボス）
    _registerBoss(BossEnemy(
      id: 'boss_crystal_guardian',
      name: 'Crystal Guardian',
      description: 'An ancient protector of the crystal mines',
      level: 20,
      healthPoints: 400,
      attackPower: 25,
      defenseRating: 12,
      experience: 1200,
      goldReward: 800,
      rarity: EnemyRarity.epic,
      specialAbilities: ['crystal_spike', 'geothermal_eruption', 'crystallize'],
      phaseCount: 3,
      lootTableIds: ['boss_loot_crystal'],
      minPartyLevel: 15,
      recommendedPartySize: 3,
    ));

    // アンデッド・キング（城塞ボス）
    _registerBoss(BossEnemy(
      id: 'boss_undead_king',
      name: 'Undead King',
      description: 'The corrupted ruler of the shattered fortress',
      level: 45,
      healthPoints: 800,
      attackPower: 50,
      defenseRating: 20,
      experience: 3000,
      goldReward: 2500,
      rarity: EnemyRarity.legendary,
      specialAbilities: ['death_curse', 'soul_drain', 'undead_summon', 'dark_explosion'],
      phaseCount: 4,
      lootTableIds: ['boss_loot_undead', 'boss_loot_legendary'],
      minPartyLevel: 40,
      recommendedPartySize: 4,
    ));
  }

  /// すべてのトレジャーを初期化
  void _initializeAllTreasures() {
    _registerTreasure(Treasure(
      id: 'arcane_tome',
      name: 'Arcane Tome',
      rarity: TreasureRarity.uncommon,
      goldValue: 200,
      description: 'An ancient book of magical knowledge',
      type: TreasureType.equipment,
      stats: {'intelligence': 5, 'mana': 20},
    ));

    _registerTreasure(Treasure(
      id: 'crystal_ore',
      name: 'Crystal Ore',
      rarity: TreasureRarity.common,
      goldValue: 100,
      description: 'Refined crystal material',
      type: TreasureType.material,
      stats: {'crafting': 3},
    ));

    _registerTreasure(Treasure(
      id: 'legendary_sword',
      name: 'Legendary Sword',
      rarity: TreasureRarity.legendary,
      goldValue: 1000,
      description: 'A weapon of immense power',
      type: TreasureType.weapon,
      stats: {'attack': 20, 'critical': 15},
    ));
  }

  /// ダンジョンを登録
  void _registerDungeon(Dungeon dungeon) {
    _dungeons[dungeon.id] = dungeon;
  }

  /// 敵を登録
  void _registerEnemy(Enemy enemy) {
    _enemies[enemy.id] = enemy;
  }

  /// ボスを登録
  void _registerBoss(BossEnemy boss) {
    _bosses[boss.id] = boss;
  }

  /// トレジャーを登録
  void _registerTreasure(Treasure treasure) {
    _treasures[treasure.id] = treasure;
  }

  /// ダンジョンを取得
  Dungeon? getDungeon(String dungeonId) {
    return _dungeons[dungeonId];
  }

  /// すべてのダンジョンを取得
  List<Dungeon> getAllDungeons() {
    return _dungeons.values.toList();
  }

  /// 難易度別ダンジョンを取得
  List<Dungeon> getDungeonsByDifficulty(DungeonDifficulty difficulty) {
    return _dungeons.values
        .where((d) => d.difficulty == difficulty)
        .toList();
  }

  /// プレイヤーのレベル別推奨ダンジョンを取得
  List<Dungeon> getRecommendedDungeons(int playerLevel) {
    return _dungeons.values
        .where((d) =>
            d.recommendedLevel <= playerLevel &&
            d.recommendedLevel >= playerLevel - 5)
        .toList();
  }

  /// ダンジョンを開始
  DungeonSession? startDungeon(
    String dungeonId,
    String playerId,
    int playerLevel,
  ) {
    final dungeon = _dungeons[dungeonId];
    if (dungeon == null) return null;

    // プレイヤーのレベルが低すぎる場合はチェック
    if (playerLevel < dungeon.recommendedLevel - 5) {
      return null;
    }

    final session = DungeonSession(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      dungeonId: dungeonId,
      playerId: playerId,
      playerLevel: playerLevel,
      startTime: DateTime.now(),
      currentFloor: 1,
      currentFloorData: _dungeonFloors[dungeonId]?[0],
      visitedFloors: [1],
      defeatedEnemies: [],
      collectedTreasures: [],
      healthRemaining: 100,
      isActive: true,
    );

    // プレイヤーの進捗を保存
    _playerProgress[playerId] = DungeonProgress(
      playerId: playerId,
      lastDungeonId: dungeonId,
      floorsCompleted: 0,
      totalGoldEarned: 0,
      totalEnemiesDefeated: 0,
      dungeonCompletions: {},
    );

    return session;
  }

  /// フロアの敵を取得
  List<Enemy> getFloorEnemies(String dungeonId, int floorNumber) {
    final floors = _dungeonFloors[dungeonId];
    if (floors == null || floorNumber < 1 || floorNumber > floors.length) {
      return [];
    }

    final floor = floors[floorNumber - 1];
    return floor.enemyEncounters
        .map((id) => _enemies[id])
        .whereType<Enemy>()
        .toList();
  }

  /// 敵を取得
  Enemy? getEnemy(String enemyId) {
    return _enemies[enemyId];
  }

  /// ボスを取得
  BossEnemy? getBoss(String bossId) {
    return _bosses[bossId];
  }

  /// トレジャーを取得
  Treasure? getTreasure(String treasureId) {
    return _treasures[treasureId];
  }

  /// フロア完了時の報酬を計算
  FloorReward calculateFloorReward(
    String dungeonId,
    int floorNumber,
    List<String> defeatedEnemyIds,
  ) {
    final dungeon = _dungeons[dungeonId];
    if (dungeon == null) return FloorReward(gold: 0, experience: 0);

    int totalGold = 0;
    int totalExperience = 0;

    for (final enemyId in defeatedEnemyIds) {
      final enemy = _enemies[enemyId];
      if (enemy != null) {
        totalGold += enemy.goldReward;
        totalExperience += enemy.experience;
      }
    }

    // フロア難易度による乗数
    final difficultyMultiplier = _getDifficultyMultiplier(dungeon.difficulty);
    totalGold = (totalGold * difficultyMultiplier).toInt();
    totalExperience = (totalExperience * difficultyMultiplier).toInt();

    return FloorReward(gold: totalGold, experience: totalExperience);
  }

  /// ダンジョン完了時の報酬を計算
  DungeonCompleteReward calculateDungeonCompletion(String dungeonId) {
    final dungeon = _dungeons[dungeonId];
    if (dungeon == null) {
      return DungeonCompleteReward(
        gold: 0,
        experience: 0,
        questProgress: 0,
      );
    }

    return DungeonCompleteReward(
      gold: dungeon.rewards.baseGold,
      experience: dungeon.rewards.baseExperience,
      questProgress: dungeon.rewards.questProgress,
    );
  }

  /// 難易度乗数を取得
  double _getDifficultyMultiplier(DungeonDifficulty difficulty) {
    switch (difficulty) {
      case DungeonDifficulty.easy:
        return 1.0;
      case DungeonDifficulty.medium:
        return 1.5;
      case DungeonDifficulty.hard:
        return 2.0;
      case DungeonDifficulty.legendary:
        return 3.0;
    }
  }

  /// ダンジョン統計を取得
  DungeonStats getDungeonStats(String playerId) {
    final progress = _playerProgress[playerId];
    if (progress == null) {
      return DungeonStats(
        totalDungeonsCompleted: 0,
        totalGoldEarned: 0,
        totalEnemiesDefeated: 0,
        floorsCompleted: 0,
      );
    }

    return DungeonStats(
      totalDungeonsCompleted: progress.dungeonCompletions.length,
      totalGoldEarned: progress.totalGoldEarned,
      totalEnemiesDefeated: progress.totalEnemiesDefeated,
      floorsCompleted: progress.floorsCompleted,
    );
  }
}

/// ダンジョン定義
class Dungeon {
  final String id;
  final String name;
  final String description;
  final String region;
  final DungeonDifficulty difficulty;
  final int recommendedLevel;
  final int minPlayerCount;
  final int maxPlayerCount;
  final int floorCount;
  final String bossId;
  final DungeonReward rewards;
  final BiomeType biomeType;

  Dungeon({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.difficulty,
    required this.recommendedLevel,
    required this.minPlayerCount,
    required this.maxPlayerCount,
    required this.floorCount,
    required this.bossId,
    required this.rewards,
    required this.biomeType,
  });
}

/// ダンジョン難易度
enum DungeonDifficulty {
  easy,      // レベル1-10
  medium,    // レベル11-25
  hard,      // レベル26-35
  legendary, // レベル36+
}

/// バイオームタイプ
enum BiomeType {
  arcane,    // 魔法
  mineral,   // 鉱物
  natural,   // 自然
  undead,    // アンデッド
  dragon,    // ドラゴン
}

/// ダンジョンフロア
class DungeonFloor {
  final String id;
  final int floorNumber;
  final int width;
  final int height;
  final List<String> enemyEncounters;
  final double treasureChance;
  final DungeonDifficulty difficulty;
  final bool isBossFloor;
  final bool hasShop;
  final List<String> hazards;

  DungeonFloor({
    required this.id,
    required this.floorNumber,
    required this.width,
    required this.height,
    required this.enemyEncounters,
    required this.treasureChance,
    required this.difficulty,
    required this.isBossFloor,
    required this.hasShop,
    required this.hazards,
  });
}

/// 敵定義
class Enemy {
  final String id;
  final String name;
  final int level;
  final int healthPoints;
  final int attackPower;
  final int defenseRating;
  final int experience;
  final int goldReward;
  final EnemyRarity rarity;

  Enemy({
    required this.id,
    required this.name,
    required this.level,
    required this.healthPoints,
    required this.attackPower,
    required this.defenseRating,
    required this.experience,
    required this.goldReward,
    required this.rarity,
  });

  /// ダメージを計算
  int calculateDamage(int playerDefense) {
    return ((attackPower - playerDefense) / 2).ceil().clamp(1, 999);
  }
}

/// 敵レアリティ
enum EnemyRarity {
  common,    // よくある
  uncommon,  // アンコモン
  rare,      // レア
  epic,      // エピック
  legendary, // レジェンダリー
}

/// ボス敵定義
class BossEnemy extends Enemy {
  final String description;
  final List<String> specialAbilities;
  final int phaseCount;
  final List<String> lootTableIds;
  final int minPartyLevel;
  final int recommendedPartySize;

  BossEnemy({
    required String id,
    required String name,
    required this.description,
    required int level,
    required int healthPoints,
    required int attackPower,
    required int defenseRating,
    required int experience,
    required int goldReward,
    required EnemyRarity rarity,
    required this.specialAbilities,
    required this.phaseCount,
    required this.lootTableIds,
    required this.minPartyLevel,
    required this.recommendedPartySize,
  }) : super(
    id: id,
    name: name,
    level: level,
    healthPoints: healthPoints,
    attackPower: attackPower,
    defenseRating: defenseRating,
    experience: experience,
    goldReward: goldReward,
    rarity: rarity,
  );
}

/// トレジャー定義
class Treasure {
  final String id;
  final String name;
  final TreasureRarity rarity;
  final int goldValue;
  final String description;
  final TreasureType type;
  final Map<String, int> stats;

  Treasure({
    required this.id,
    required this.name,
    required this.rarity,
    required this.goldValue,
    required this.description,
    required this.type,
    required this.stats,
  });
}

/// トレジャーレアリティ
enum TreasureRarity {
  common,    // よくある
  uncommon,  // アンコモン
  rare,      // レア
  epic,      // エピック
  legendary, // レジェンダリー
}

/// トレジャータイプ
enum TreasureType {
  weapon,    // 武器
  armor,     // 防具
  equipment, // 装備
  material,  // 素材
  consumable,// 消耗品
  quest,     // クエストアイテム
}

/// ダンジョン報酬
class DungeonReward {
  final int baseGold;
  final int baseExperience;
  final int questProgress;

  DungeonReward({
    required this.baseGold,
    required this.baseExperience,
    required this.questProgress,
  });
}

/// ダンジョンセッション
class DungeonSession {
  final String sessionId;
  final String dungeonId;
  final String playerId;
  final int playerLevel;
  final DateTime startTime;
  int currentFloor;
  DungeonFloor? currentFloorData;
  final List<int> visitedFloors;
  final List<String> defeatedEnemies;
  final List<String> collectedTreasures;
  int healthRemaining;
  bool isActive;

  DungeonSession({
    required this.sessionId,
    required this.dungeonId,
    required this.playerId,
    required this.playerLevel,
    required this.startTime,
    required this.currentFloor,
    required this.currentFloorData,
    required this.visitedFloors,
    required this.defeatedEnemies,
    required this.collectedTreasures,
    required this.healthRemaining,
    required this.isActive,
  });

  /// セッションの経過時間を取得
  Duration get elapsedTime => DateTime.now().difference(startTime);
}

/// ダンジョン進捗
class DungeonProgress {
  final String playerId;
  final String lastDungeonId;
  int floorsCompleted;
  int totalGoldEarned;
  int totalEnemiesDefeated;
  final Map<String, int> dungeonCompletions;

  DungeonProgress({
    required this.playerId,
    required this.lastDungeonId,
    required this.floorsCompleted,
    required this.totalGoldEarned,
    required this.totalEnemiesDefeated,
    required this.dungeonCompletions,
  });
}

/// フロア報酬
class FloorReward {
  final int gold;
  final int experience;

  FloorReward({
    required this.gold,
    required this.experience,
  });
}

/// ダンジョン完了報酬
class DungeonCompleteReward {
  final int gold;
  final int experience;
  final int questProgress;

  DungeonCompleteReward({
    required this.gold,
    required this.experience,
    required this.questProgress,
  });
}

/// ダンジョン統計
class DungeonStats {
  final int totalDungeonsCompleted;
  final int totalGoldEarned;
  final int totalEnemiesDefeated;
  final int floorsCompleted;

  DungeonStats({
    required this.totalDungeonsCompleted,
    required this.totalGoldEarned,
    required this.totalEnemiesDefeated,
    required this.floorsCompleted,
  });
}
