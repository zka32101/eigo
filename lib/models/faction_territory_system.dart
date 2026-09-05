/// ファクションテリトリー制御システム
/// 領土管理、制御権、ボーナス、領土戦争

/// ファクションテリトリーシステム
class FactionTerritorySystem {
  static final FactionTerritorySystem _instance =
      FactionTerritorySystem._internal();

  factory FactionTerritorySystem.getInstance() {
    return _instance;
  }

  FactionTerritorySystem._internal();

  // テリトリー: territory_id -> Territory
  final Map<String, Territory> _territories = {};

  // テリトリー支配: territory_id -> controlling_faction_id
  final Map<String, String> _territoryControl = {};

  // テリトリー支配履歴: territory_id -> list of (faction_id, timestamp, duration)
  final Map<String, List<ControlHistory>> _controlHistory = {};

  /// システムを初期化
  void initialize() {
    _territories.clear();
    _territoryControl.clear();
    _controlHistory.clear();
    _initializeAllTerritories();
  }

  /// すべてのテリトリーを初期化
  void _initializeAllTerritories() {
    // 魔法使いの塔地域
    _registerTerritory(Territory(
      id: 'mage_tower_region',
      name: 'Mage Tower Region',
      factionId: 'mage_tower',
      region: 'Mage Tower',
      type: TerritoryType.arcane,
      level: 1,
      baseBonus: 1.15,
      bonusTypes: ['spell_learning', 'mana_regeneration', 'research_speed'],
      resourcesPerDay: {'arcane_dust': 50, 'mana_crystal': 10},
      population: 300,
    ));

    _territoryControl['mage_tower_region'] = 'mage_tower';

    // 冒険者の村地域
    _registerTerritory(Territory(
      id: 'adventurers_region',
      name: 'Adventurers Village Region',
      factionId: 'adventurers_guild',
      region: 'Adventurers Village',
      type: TerritoryType.martial,
      level: 2,
      baseBonus: 1.20,
      bonusTypes: ['combat_experience', 'armor_durability', 'loot_multiplier'],
      resourcesPerDay: {'iron_ore': 80, 'leather': 40, 'combat_reports': 5},
      population: 400,
    ));

    _territoryControl['adventurers_region'] = 'adventurers_guild';

    // 商人の街地域
    _registerTerritory(Territory(
      id: 'merchant_region',
      name: 'Merchants City Region',
      factionId: 'merchant_cartel',
      region: 'Merchants City',
      type: TerritoryType.commerce,
      level: 1,
      baseBonus: 1.25,
      bonusTypes: ['gold_gain', 'trade_discount', 'merchant_favor'],
      resourcesPerDay: {'gold': 500, 'trade_goods': 30, 'gems': 5},
      population: 500,
    ));

    _territoryControl['merchant_region'] = 'merchant_cartel';

    // 森林地域（争奪対象）
    _registerTerritory(Territory(
      id: 'forest_region',
      name: 'Ancient Forest',
      factionId: null,
      region: 'Neutral',
      type: TerritoryType.natural,
      level: 1,
      baseBonus: 1.10,
      bonusTypes: ['herb_gathering', 'nature_affinity', 'stealth_bonus'],
      resourcesPerDay: {'herbs': 100, 'wood': 60, 'rare_plants': 8},
      population: 100,
    ));

    _territoryControl['forest_region'] = 'neutral';

    // 山岳地域（争奪対象）
    _registerTerritory(Territory(
      id: 'mountain_region',
      name: 'Crystal Mountains',
      factionId: null,
      region: 'Neutral',
      type: TerritoryType.mineral,
      level: 2,
      baseBonus: 1.15,
      bonusTypes: ['mining_yield', 'ore_quality', 'gem_discovery'],
      resourcesPerDay: {'crystal': 150, 'gold_ore': 75, 'precious_gems': 10},
      population: 150,
    ));

    _territoryControl['mountain_region'] = 'neutral';

    // 沿岸地域（争奪対象）
    _registerTerritory(Territory(
      id: 'coastal_region',
      name: 'Coastal Harbor',
      factionId: null,
      region: 'Neutral',
      type: TerritoryType.maritime,
      level: 1,
      baseBonus: 1.12,
      bonusTypes: ['fishing_yield', 'trade_routes', 'naval_advantage'],
      resourcesPerDay: {'fish': 80, 'pearls': 15, 'sea_salt': 40},
      population: 200,
    ));

    _territoryControl['coastal_region'] = 'neutral';
  }

  /// テリトリーを登録
  void _registerTerritory(Territory territory) {
    _territories[territory.id] = territory;
    _controlHistory[territory.id] = [];
  }

  /// テリトリーを取得
  Territory? getTerritory(String territoryId) {
    return _territories[territoryId];
  }

  /// すべてのテリトリーを取得
  List<Territory> getAllTerritories() {
    return _territories.values.toList();
  }

  /// ファクション別テリトリーを取得
  List<Territory> getTerritoryByFaction(String factionId) {
    return _territories.values
        .where((t) => _territoryControl[t.id] == factionId)
        .toList();
  }

  /// テリトリーの支配者を取得
  String? getTerritoryController(String territoryId) {
    return _territoryControl[territoryId];
  }

  /// テリトリーの支配を変更
  bool claimTerritory(String territoryId, String factionId) {
    if (!_territories.containsKey(territoryId)) return false;

    final territory = _territories[territoryId]!;
    final previousController = _territoryControl[territoryId];

    // 支配履歴を記録
    final history = _controlHistory[territoryId] ?? [];
    history.add(ControlHistory(
      factionId: previousController ?? 'neutral',
      startTime: DateTime.now(),
      duration: 0,
    ));

    // 新しい支配者を設定
    _territoryControl[territoryId] = factionId;
    territory.factionId = factionId;
    territory.level = (territory.level + 1).clamp(1, 5);

    return true;
  }

  /// テリトリーボーナスを計算
  double getTerritoryBonus(String territoryId) {
    final territory = _territories[territoryId];
    if (territory == null) return 1.0;

    // ベースボーナス + レベルボーナス
    return territory.baseBonus + (territory.level * 0.02);
  }

  /// テリトリーのリソースを取得
  Map<String, int> getTerritoryResources(String territoryId) {
    final territory = _territories[territoryId];
    if (territory == null) return {};

    return Map.from(territory.resourcesPerDay);
  }

  /// ファクションの総ボーナスを計算
  double getFactionTotalBonus(String factionId) {
    final territories = getTerritoryByFaction(factionId);
    if (territories.isEmpty) return 1.0;

    double totalBonus = 0;
    for (final territory in territories) {
      totalBonus += getTerritoryBonus(territory.id);
    }

    return totalBonus / territories.length;
  }

  /// ファクションの総リソースを計算
  Map<String, int> getFactionTotalResources(String factionId) {
    final territories = getTerritoryByFaction(factionId);
    final Map<String, int> totalResources = {};

    for (final territory in territories) {
      final resources = getTerritoryResources(territory.id);
      resources.forEach((key, value) {
        totalResources[key] = (totalResources[key] ?? 0) + value;
      });
    }

    return totalResources;
  }

  /// テリトリーを支配できるか確認（争奪対象のみ）
  bool canClaimTerritory(String territoryId) {
    final territory = _territories[territoryId];
    return territory != null && territory.factionId == null;
  }

  /// テリトリーの支配交代を試みる
  bool challengeTerritory(String territoryId, String attackingFactionId,
      String defendingFactionId, double attackPower) {
    if (!_territories.containsKey(territoryId)) return false;

    // 防御力を計算（防御側のレベル + 支配期間）
    final territory = _territories[territoryId]!;
    final defensePower =
        (territory.level * 2.0) + (territory.controlDurationDays ~/ 10);

    // 攻撃が防御を上回った場合、領土交代
    if (attackPower > defensePower) {
      claimTerritory(territoryId, attackingFactionId);
      return true;
    }

    return false;
  }

  /// テリトリーの支配履歴を取得
  List<ControlHistory> getTerritoryControlHistory(String territoryId) {
    return _controlHistory[territoryId] ?? [];
  }

  /// テリトリーの統計を取得
  TerritoryStats getTerritoryStats(String territoryId) {
    final territory = _territories[territoryId];
    if (territory == null) {
      return TerritoryStats(
        totalPopulation: 0,
        controlledTerritories: 0,
        averageLevel: 0,
        totalResources: 0,
      );
    }

    return TerritoryStats(
      totalPopulation: territory.population,
      controlledTerritories: 1,
      averageLevel: territory.level,
      totalResources: territory.resourcesPerDay.values.fold(0, (a, b) => a + b),
    );
  }

  /// ファクション別テリトリー統計を取得
  FactionTerritoryStats getFactionTerritoryStats(String factionId) {
    final territories = getTerritoryByFaction(factionId);
    final resources = getFactionTotalResources(factionId);

    int totalPopulation = 0;
    int totalLevel = 0;

    for (final territory in territories) {
      totalPopulation += territory.population;
      totalLevel += territory.level;
    }

    return FactionTerritoryStats(
      totalPopulation: totalPopulation,
      controlledTerritories: territories.length,
      averageLevel: territories.isEmpty ? 0 : totalLevel ~/ territories.length,
      totalResources: resources.values.fold(0, (a, b) => a + b),
      territories: territories,
    );
  }
}

/// テリトリー定義
class Territory {
  final String id;
  final String name;
  String? factionId;
  final String region;
  final TerritoryType type;
  int level;
  final double baseBonus;
  final List<String> bonusTypes;
  final Map<String, int> resourcesPerDay;
  int population;
  DateTime lastControlChange = DateTime.now();

  Territory({
    required this.id,
    required this.name,
    required this.factionId,
    required this.region,
    required this.type,
    required this.level,
    required this.baseBonus,
    required this.bonusTypes,
    required this.resourcesPerDay,
    required this.population,
  });

  /// テリトリーの支配継続日数
  int get controlDurationDays {
    return DateTime.now().difference(lastControlChange).inDays;
  }

  /// テリトリー説明を取得
  String getDescription() {
    switch (type) {
      case TerritoryType.arcane:
        return 'A mystical land of magical power and research';
      case TerritoryType.martial:
        return 'A stronghold for warriors and adventurers';
      case TerritoryType.commerce:
        return 'A thriving center of trade and commerce';
      case TerritoryType.natural:
        return 'A natural wilderness with abundant resources';
      case TerritoryType.mineral:
        return 'A region rich in minerals and precious gems';
      case TerritoryType.maritime:
        return 'A coastal area with maritime advantages';
    }
  }
}

/// テリトリータイプ
enum TerritoryType {
  arcane,      // 神秘的 - 魔法ボーナス
  martial,     // 軍事 - 戦闘ボーナス
  commerce,    // 商業 - 取引ボーナス
  natural,     // 自然 - リソースボーナス
  mineral,     // 鉱物 - 採掘ボーナス
  maritime,    // 海事 - 航海ボーナス
}

/// テリトリー支配履歴
class ControlHistory {
  final String factionId;
  final DateTime startTime;
  int duration; // 支配継続日数

  ControlHistory({
    required this.factionId,
    required this.startTime,
    required this.duration,
  });
}

/// テリトリー統計
class TerritoryStats {
  final int totalPopulation;
  final int controlledTerritories;
  final int averageLevel;
  final int totalResources;

  TerritoryStats({
    required this.totalPopulation,
    required this.controlledTerritories,
    required this.averageLevel,
    required this.totalResources,
  });
}

/// ファクションテリトリー統計
class FactionTerritoryStats {
  final int totalPopulation;
  final int controlledTerritories;
  final int averageLevel;
  final int totalResources;
  final List<Territory> territories;

  FactionTerritoryStats({
    required this.totalPopulation,
    required this.controlledTerritories,
    required this.averageLevel,
    required this.totalResources,
    required this.territories,
  });

  /// ファクションの地力スコア（統治能力の総合評価）
  int getPowerScore() {
    return (totalPopulation ~/ 10) +
        (controlledTerritories * 20) +
        (averageLevel * 10) +
        (totalResources ~/ 50);
  }
}
