/// 家族進行・相続システム
/// 家族レベル、家族の系統、相続メカニクス、家族ボーナス

/// 家族進行システム
class FamilyProgressionSystem {
  static final FamilyProgressionSystem _instance =
      FamilyProgressionSystem._internal();

  factory FamilyProgressionSystem.getInstance() {
    return _instance;
  }

  FamilyProgressionSystem._internal();

  // 家族進行: player_id -> FamilyProgression
  final Map<String, FamilyProgression> _familyProgressions = {};

  // 家族の系統: family_lineage_id -> FamilyLineage
  final Map<String, FamilyLineage> _familyLineages = {};

  // 相続: inheritance_id -> Inheritance
  final Map<String, Inheritance> _inheritances = {};

  // 家族スキル: skill_id -> FamilySkill
  final Map<String, FamilySkill> _familySkills = {};

  // 相続ボーナス: lineage_id -> InheritanceBonus
  final Map<String, InheritanceBonus> _inheritanceBonuses = {};

  /// システムを初期化
  void initialize() {
    _familyProgressions.clear();
    _familyLineages.clear();
    _inheritances.clear();
    _familySkills.clear();
    _inheritanceBonuses.clear();
    _initializeAllFamilySkills();
    _initializeAllInheritanceBonuses();
  }

  /// すべての家族スキルを初期化
  void _initializeAllFamilySkills() {
    // 戦士系
    _registerFamilySkill(FamilySkill(
      id: 'skill_warrior_legacy',
      name: 'Warrior Legacy',
      description: 'Increases ATK and DEF from ancestors',
      skillType: FamilySkillType.combat,
      requirements: {
        'generations': 2,
        'family_level': 3,
      },
      bonusStats: {'attack': 15, 'defense': 10},
      level: 1,
    ));

    // 魔法系
    _registerFamilySkill(FamilySkill(
      id: 'skill_mage_legacy',
      name: 'Mage Legacy',
      description: 'Increases INT and MANA from ancestors',
      skillType: FamilySkillType.magic,
      requirements: {
        'generations': 2,
        'family_level': 3,
      },
      bonusStats: {'intelligence': 15, 'mana': 50},
      level: 1,
    ));

    // 商人系
    _registerFamilySkill(FamilySkill(
      id: 'skill_merchant_legacy',
      name: 'Merchant Legacy',
      description: 'Gold gain multiplier from ancestors',
      skillType: FamilySkillType.economic,
      requirements: {
        'generations': 2,
        'family_level': 2,
      },
      bonusStats: {'gold_multiplier': 125}, // 125 = 1.25×
      level: 1,
    ));

    // 貴族系
    _registerFamilySkill(FamilySkill(
      id: 'skill_noble_legacy',
      name: 'Noble Legacy',
      description: 'All stats increased from noble lineage',
      skillType: FamilySkillType.nobility,
      requirements: {
        'generations': 3,
        'family_level': 5,
      },
      bonusStats: {
        'attack': 20,
        'defense': 20,
        'health': 100,
        'intelligence': 10,
      },
      level: 2,
    ));

    // 冒険家系
    _registerFamilySkill(FamilySkill(
      id: 'skill_adventurer_legacy',
      name: 'Adventurer Legacy',
      description: 'XP gain and luck from ancestors',
      skillType: FamilySkillType.exploration,
      requirements: {
        'generations': 2,
        'family_level': 3,
      },
      bonusStats: {'xp_multiplier': 115, 'luck': 15},
      level: 1,
    ));
  }

  /// すべての相続ボーナスを初期化
  void _initializeAllInheritanceBonuses() {
    // 戦士の系統
    _registerInheritanceBonus(InheritanceBonus(
      id: 'bonus_warrior_line',
      lineageId: 'lineage_warrior',
      name: 'Warrior Bloodline',
      description: 'Enhanced combat abilities',
      bonusStats: {'attack': 25, 'health': 100},
      level: 1,
      passdownGeneration: 2,
    ));

    // 魔法使いの系統
    _registerInheritanceBonus(InheritanceBonus(
      id: 'bonus_mage_line',
      lineageId: 'lineage_mage',
      name: 'Arcane Lineage',
      description: 'Enhanced magical abilities',
      bonusStats: {'intelligence': 20, 'mana': 100},
      level: 1,
      passdownGeneration: 2,
    ));

    // 商人の系統
    _registerInheritanceBonus(InheritanceBonus(
      id: 'bonus_merchant_line',
      lineageId: 'lineage_merchant',
      name: 'Merchant Dynasty',
      description: 'Economic advantages',
      bonusStats: {'gold_multiplier': 130}, // 1.3×
      level: 1,
      passdownGeneration: 2,
    ));

    // 王族の系統
    _registerInheritanceBonus(InheritanceBonus(
      id: 'bonus_royal_line',
      lineageId: 'lineage_royal',
      name: 'Royal Bloodline',
      description: 'Unmatched power and prestige',
      bonusStats: {
        'attack': 30,
        'defense': 30,
        'health': 150,
        'intelligence': 15,
        'mana': 75,
      },
      level: 3,
      passdownGeneration: 3,
    ));
  }

  /// 家族スキルを登録
  void _registerFamilySkill(FamilySkill skill) {
    _familySkills[skill.id] = skill;
  }

  /// 相続ボーナスを登録
  void _registerInheritanceBonus(InheritanceBonus bonus) {
    _inheritanceBonuses[bonus.id] = bonus;
  }

  /// プレイヤーの家族進行を初期化
  void initializeFamilyProgression(String playerId) {
    if (!_familyProgressions.containsKey(playerId)) {
      _familyProgressions[playerId] = FamilyProgression(
        playerId: playerId,
        familyLevel: 1,
        familyExperience: 0,
        generationCount: 1,
        lineageType: FamilyLineageType.commoner,
        totalWealth: 0,
        achievements: [],
        unlockedSkills: [],
        inheritanceLegacy: [],
      );
    }
  }

  /// 家族経験値を追加
  bool addFamilyExperience(String playerId, int amount) {
    if (!_familyProgressions.containsKey(playerId)) return false;

    final progression = _familyProgressions[playerId]!;
    progression.familyExperience += amount;

    // レベルアップ
    final experiencePerLevel = 1000 + (progression.familyLevel * 200);
    while (progression.familyExperience >= experiencePerLevel) {
      progression.familyExperience -= experiencePerLevel;
      progression.familyLevel++;
      progression.achievements.add('Family Level ${progression.familyLevel}');
    }

    return true;
  }

  /// 家族の系統を設定
  void setFamilyLineage(String playerId, FamilyLineageType lineageType) {
    if (!_familyProgressions.containsKey(playerId)) {
      initializeFamilyProgression(playerId);
    }

    final progression = _familyProgressions[playerId]!;
    progression.lineageType = lineageType;

    // 系統に基づいて初期ボーナスを決定
    final lineageId = switch (lineageType) {
      FamilyLineageType.commoner => 'lineage_commoner',
      FamilyLineageType.merchant => 'lineage_merchant',
      FamilyLineageType.warrior => 'lineage_warrior',
      FamilyLineageType.mage => 'lineage_mage',
      FamilyLineageType.noble => 'lineage_noble',
      FamilyLineageType.royal => 'lineage_royal',
    };

    _registerFamilyLineage(FamilyLineage(
      id: lineageId,
      playerId: playerId,
      name: lineageType.toString(),
      description: 'Family lineage type',
      bonusStats: _getLineageStats(lineageType),
      generation: 1,
    ));
  }

  /// 系統別ボーナスを取得
  Map<String, int> _getLineageStats(FamilyLineageType lineageType) {
    return switch (lineageType) {
      FamilyLineageType.commoner => {},
      FamilyLineageType.merchant => {'gold_multiplier': 110},
      FamilyLineageType.warrior => {'attack': 10, 'defense': 5},
      FamilyLineageType.mage => {'intelligence': 10, 'mana': 30},
      FamilyLineageType.noble => {
        'attack': 10,
        'defense': 10,
        'health': 50,
      },
      FamilyLineageType.royal => {
        'attack': 20,
        'defense': 20,
        'health': 100,
        'intelligence': 15,
      },
    };
  }

  /// 家族の系統を登録
  void _registerFamilyLineage(FamilyLineage lineage) {
    _familyLineages[lineage.id] = lineage;
  }

  /// 子供が継承者になったか確認
  bool canInherit(String playerId, String childId, int childAge) {
    // 18歳以上
    if (childAge < 18) return false;

    return true;
  }

  /// 相続を実行
  bool executeInheritance(
    String playerId,
    String childId,
    int inheritedWealth,
  ) {
    if (!_familyProgressions.containsKey(playerId)) return false;

    final progression = _familyProgressions[playerId]!;

    // 相続データを作成
    final inheritance = Inheritance(
      id: '${playerId}_inheritance_${DateTime.now().millisecondsSinceEpoch}',
      inheritingParentId: playerId,
      inheritingChildId: childId,
      inheritedWealth: inheritedWealth,
      inheritanceDate: DateTime.now().millisecondsSinceEpoch,
      inheritedSkills: progression.unlockedSkills.toList(),
      inheritedAchievements: progression.achievements.toList(),
    );

    _inheritances[inheritance.id] = inheritance;

    // 相続レガシーに追加
    progression.inheritanceLegacy.add(inheritance.id);
    progression.generationCount++;

    return true;
  }

  /// 家族スキルをアンロック
  bool unlockFamilySkill(String playerId, String skillId) {
    if (!_familyProgressions.containsKey(playerId)) return false;
    if (!_familySkills.containsKey(skillId)) return false;

    final progression = _familyProgressions[playerId]!;
    final skill = _familySkills[skillId]!;

    // 要件をチェック
    final minGenerations = (skill.requirements['generations'] ?? 0) as int;
    final minFamilyLevel = (skill.requirements['family_level'] ?? 0) as int;

    if (progression.generationCount < minGenerations) return false;
    if (progression.familyLevel < minFamilyLevel) return false;

    progression.unlockedSkills.add(skillId);
    return true;
  }

  /// 家族の総ボーナスを計算
  Map<String, int> calculateFamilyBonuses(String playerId) {
    if (!_familyProgressions.containsKey(playerId)) return {};

    final progression = _familyProgressions[playerId]!;
    final bonuses = <String, int>{};

    // 系統ボーナス
    for (final lineage in _familyLineages.values) {
      if (lineage.playerId == playerId) {
        bonuses.addAll(lineage.bonusStats);
      }
    }

    // アンロック済みスキルのボーナス
    for (final skillId in progression.unlockedSkills) {
      final skill = _familySkills[skillId];
      if (skill != null) {
        skill.bonusStats.forEach((key, value) {
          bonuses[key] = (bonuses[key] ?? 0) + value;
        });
      }
    }

    // 相続ボーナス
    for (final inheritanceId in progression.inheritanceLegacy) {
      final inheritance = _inheritances[inheritanceId];
      if (inheritance != null) {
        // 相続による追加ボーナス
        bonuses['inheritance_level'] =
            (bonuses['inheritance_level'] ?? 0) + 10;
      }
    }

    return bonuses;
  }

  /// 家族レベルの詳細を取得
  int getExperienceToNextLevel(String playerId) {
    if (!_familyProgressions.containsKey(playerId)) return 0;

    final progression = _familyProgressions[playerId]!;
    final experiencePerLevel = 1000 + (progression.familyLevel * 200);
    return experiencePerLevel - progression.familyExperience;
  }

  /// 家族進行を取得
  FamilyProgression? getFamilyProgression(String playerId) {
    return _familyProgressions[playerId];
  }

  /// 家族スキルを取得
  FamilySkill? getFamilySkill(String skillId) {
    return _familySkills[skillId];
  }

  /// すべての家族スキルを取得
  List<FamilySkill> getAllFamilySkills() {
    return _familySkills.values.toList();
  }

  /// 相続を取得
  Inheritance? getInheritance(String inheritanceId) {
    return _inheritances[inheritanceId];
  }

  /// 系統ボーナスを取得
  InheritanceBonus? getLineageBonus(String bonusId) {
    return _inheritanceBonuses[bonusId];
  }
}

/// 家族進行
class FamilyProgression {
  final String playerId;
  int familyLevel; // 家族レベル
  int familyExperience; // 家族経験値
  int generationCount; // 世代数
  FamilyLineageType lineageType; // 系統タイプ
  int totalWealth; // 総資産
  final List<String> achievements; // 成就
  final List<String> unlockedSkills; // アンロック済みスキル
  final List<String> inheritanceLegacy; // 相続レガシー

  FamilyProgression({
    required this.playerId,
    required this.familyLevel,
    required this.familyExperience,
    required this.generationCount,
    required this.lineageType,
    required this.totalWealth,
    required this.achievements,
    required this.unlockedSkills,
    required this.inheritanceLegacy,
  });

  /// 次のレベルアップまでの進捗 (%)
  int getProgressPercentage() {
    final experiencePerLevel = 1000 + (familyLevel * 200);
    return ((familyExperience / experiencePerLevel) * 100).toInt();
  }
}

/// 家族の系統
class FamilyLineage {
  final String id;
  final String playerId;
  final String name;
  final String description;
  final Map<String, int> bonusStats;
  int generation; // 世代

  FamilyLineage({
    required this.id,
    required this.playerId,
    required this.name,
    required this.description,
    required this.bonusStats,
    required this.generation,
  });
}

/// 家族スキル
class FamilySkill {
  final String id;
  final String name;
  final String description;
  final FamilySkillType skillType;
  final Map<String, int> requirements; // 要件 (generations, family_level等)
  final Map<String, int> bonusStats; // ボーナス統計
  int level; // スキルレベル

  FamilySkill({
    required this.id,
    required this.name,
    required this.description,
    required this.skillType,
    required this.requirements,
    required this.bonusStats,
    required this.level,
  });

  /// スキルが利用可能か確認
  bool isAvailable(int playerGenerations, int playerFamilyLevel) {
    final minGenerations = (requirements['generations'] ?? 0) as int;
    final minFamilyLevel = (requirements['family_level'] ?? 0) as int;

    return playerGenerations >= minGenerations &&
        playerFamilyLevel >= minFamilyLevel;
  }
}

/// 相続
class Inheritance {
  final String id;
  final String inheritingParentId;
  final String inheritingChildId;
  final int inheritedWealth;
  final int inheritanceDate;
  final List<String> inheritedSkills;
  final List<String> inheritedAchievements;

  Inheritance({
    required this.id,
    required this.inheritingParentId,
    required this.inheritingChildId,
    required this.inheritedWealth,
    required this.inheritanceDate,
    required this.inheritedSkills,
    required this.inheritedAchievements,
  });

  /// 相続日数を取得
  int getInheritanceAge() {
    return DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(inheritanceDate))
        .inDays;
  }
}

/// 相続ボーナス
class InheritanceBonus {
  final String id;
  final String lineageId;
  final String name;
  final String description;
  final Map<String, int> bonusStats;
  int level; // レベル
  int passdownGeneration; // 世代を超えて継承される

  InheritanceBonus({
    required this.id,
    required this.lineageId,
    required this.name,
    required this.description,
    required this.bonusStats,
    required this.level,
    required this.passdownGeneration,
  });
}

/// 家族系統タイプ
enum FamilyLineageType {
  commoner, // 庶民
  merchant, // 商人
  warrior, // 戦士
  mage, // 魔法使い
  noble, // 貴族
  royal, // 王族
}

/// 家族スキルタイプ
enum FamilySkillType {
  combat, // 戦闘
  magic, // 魔法
  economic, // 経済
  nobility, // 貴族
  exploration, // 探索
}
