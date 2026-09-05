/// 戦闘・バトルシステム
/// ターンベース戦闘、アクション選択、ダメージ計算、スキル

/// 戦闘システム
class CombatSystem {
  static final CombatSystem _instance = CombatSystem._internal();

  factory CombatSystem.getInstance() {
    return _instance;
  }

  CombatSystem._internal();

  // 進行中の戦闘: battle_id -> Battle
  final Map<String, Battle> _activeBattles = {};

  // 戦闘ログ: player_id -> BattleLog
  final Map<String, List<BattleLog>> _battleLogs = {};

  // スキル定義: skill_id -> CombatSkill
  final Map<String, CombatSkill> _skills = {};

  // ステータス効果: status_id -> StatusEffect
  final Map<String, StatusEffect> _statusEffects = {};

  // 敵テンプレート: enemy_id -> EnemyTemplate
  final Map<String, EnemyTemplate> _enemyTemplates = {};

  /// システムを初期化
  void initialize() {
    _activeBattles.clear();
    _battleLogs.clear();
    _skills.clear();
    _statusEffects.clear();
    _enemyTemplates.clear();
    _initializeAllSkills();
    _initializeAllStatusEffects();
    _initializeAllEnemyTemplates();
  }

  /// すべてのスキルを初期化
  void _initializeAllSkills() {
    // 基本攻撃
    _registerSkill(CombatSkill(
      id: 'skill_basic_attack',
      name: 'Basic Attack',
      description: 'A standard sword slash',
      skillType: SkillType.physical,
      costType: CostType.stamina,
      costAmount: 10,
      cooldown: 0,
      targetType: TargetType.singleEnemy,
      damageMultiplier: 1.0,
      accuracy: 0.95,
      criticalChance: 0.15,
      statusEffects: [],
    ));

    // 強化攻撃
    _registerSkill(CombatSkill(
      id: 'skill_power_strike',
      name: 'Power Strike',
      description: 'A powerful overhead swing',
      skillType: SkillType.physical,
      costType: CostType.stamina,
      costAmount: 25,
      cooldown: 2,
      targetType: TargetType.singleEnemy,
      damageMultiplier: 1.5,
      accuracy: 0.85,
      criticalChance: 0.25,
      statusEffects: [],
    ));

    // 防御
    _registerSkill(CombatSkill(
      id: 'skill_defend',
      name: 'Defend',
      description: 'Reduce damage taken this turn',
      skillType: SkillType.defensive,
      costType: CostType.stamina,
      costAmount: 5,
      cooldown: 0,
      targetType: TargetType.self,
      damageMultiplier: 0.0,
      defenseMultiplier: 2.0,
      accuracy: 1.0,
      criticalChance: 0.0,
      statusEffects: [],
    ));

    // 魔法攻撃
    _registerSkill(CombatSkill(
      id: 'skill_fireball',
      name: 'Fireball',
      description: 'Hurl a ball of flame at enemies',
      skillType: SkillType.magical,
      costType: CostType.mana,
      costAmount: 40,
      cooldown: 1,
      targetType: TargetType.areaOfEffect,
      damageMultiplier: 1.2,
      accuracy: 0.90,
      criticalChance: 0.10,
      statusEffects: ['status_burning'],
    ));

    // 回復スキル
    _registerSkill(CombatSkill(
      id: 'skill_heal',
      name: 'Heal',
      description: 'Restore health to an ally',
      skillType: SkillType.healing,
      costType: CostType.mana,
      costAmount: 30,
      cooldown: 1,
      targetType: TargetType.singleAlly,
      healAmount: 100,
      accuracy: 1.0,
      criticalChance: 0.0,
      statusEffects: [],
    ));

    // 全体回復
    _registerSkill(CombatSkill(
      id: 'skill_mass_heal',
      name: 'Mass Heal',
      description: 'Restore health to all allies',
      skillType: SkillType.healing,
      costType: CostType.mana,
      costAmount: 80,
      cooldown: 3,
      targetType: TargetType.allAllies,
      healAmount: 80,
      accuracy: 1.0,
      criticalChance: 0.0,
      statusEffects: [],
    ));

    // 必殺技
    _registerSkill(CombatSkill(
      id: 'skill_ultimate',
      name: 'Ultimate Strike',
      description: 'An overwhelming finishing move',
      skillType: SkillType.physical,
      costType: CostType.ultimate,
      costAmount: 100,
      cooldown: 5,
      targetType: TargetType.singleEnemy,
      damageMultiplier: 2.5,
      accuracy: 0.80,
      criticalChance: 0.50,
      statusEffects: [],
    ));
  }

  /// すべてのステータス効果を初期化
  void _initializeAllStatusEffects() {
    // 燃焼
    _registerStatusEffect(StatusEffect(
      id: 'status_burning',
      name: 'Burning',
      description: 'Takes fire damage each turn',
      effectType: EffectType.damage,
      damagePerTurn: 15,
      durationTurns: 3,
      stackable: false,
      icon: '🔥',
    ));

    // 麻痺
    _registerStatusEffect(StatusEffect(
      id: 'status_paralysis',
      name: 'Paralysis',
      description: 'Attack speed reduced by 50%',
      effectType: EffectType.debuff,
      statModifier: {'speed': -50},
      durationTurns: 2,
      stackable: false,
      icon: '⚡',
    ));

    // 中毒
    _registerStatusEffect(StatusEffect(
      id: 'status_poison',
      name: 'Poison',
      description: 'Takes poison damage each turn',
      effectType: EffectType.damage,
      damagePerTurn: 10,
      durationTurns: 5,
      stackable: true,
      icon: '☠️',
    ));

    // 強化
    _registerStatusEffect(StatusEffect(
      id: 'status_strength_boost',
      name: 'Strength Boost',
      description: 'Attack increased by 30%',
      effectType: EffectType.buff,
      statModifier: {'attack': 30},
      durationTurns: 4,
      stackable: false,
      icon: '💪',
    ));

    // 防御強化
    _registerStatusEffect(StatusEffect(
      id: 'status_defense_boost',
      name: 'Defense Boost',
      description: 'Defense increased by 40%',
      effectType: EffectType.buff,
      statModifier: {'defense': 40},
      durationTurns: 4,
      stackable: false,
      icon: '🛡️',
    ));

    // 気絶
    _registerStatusEffect(StatusEffect(
      id: 'status_stun',
      name: 'Stun',
      description: 'Cannot act this turn',
      effectType: EffectType.crowd_control,
      durationTurns: 1,
      stackable: false,
      preventAction: true,
      icon: '💫',
    ));
  }

  /// すべての敵テンプレートを初期化
  void _initializeAllEnemyTemplates() {
    // ゴブリン
    _registerEnemyTemplate(EnemyTemplate(
      id: 'enemy_goblin',
      name: 'Goblin',
      description: 'A small green creature',
      level: 1,
      health: 30,
      mana: 0,
      stamina: 50,
      attack: 5,
      defense: 2,
      speed: 3,
      accuracy: 0.80,
      rarity: EnemyRarity.common,
      skills: ['skill_basic_attack'],
      dropsGold: 50,
      dropsExperience: 100,
    ));

    // オークウォーリア
    _registerEnemyTemplate(EnemyTemplate(
      id: 'enemy_orc_warrior',
      name: 'Orc Warrior',
      description: 'A large muscular green creature',
      level: 5,
      health: 80,
      mana: 0,
      stamina: 100,
      attack: 12,
      defense: 6,
      speed: 2,
      accuracy: 0.85,
      rarity: EnemyRarity.uncommon,
      skills: ['skill_basic_attack', 'skill_power_strike'],
      dropsGold: 200,
      dropsExperience: 400,
    ));

    // ファイアエレメンタル
    _registerEnemyTemplate(EnemyTemplate(
      id: 'enemy_fire_elemental',
      name: 'Fire Elemental',
      description: 'A creature of pure flame',
      level: 8,
      health: 60,
      mana: 80,
      stamina: 60,
      attack: 15,
      defense: 4,
      speed: 4,
      accuracy: 0.90,
      rarity: EnemyRarity.rare,
      skills: ['skill_fireball', 'skill_basic_attack'],
      dropsGold: 300,
      dropsExperience: 600,
      resistances: {'fire': 50},
    ));

    // ボスドラゴン
    _registerEnemyTemplate(EnemyTemplate(
      id: 'enemy_boss_dragon',
      name: 'Ancient Dragon',
      description: 'A powerful ancient dragon',
      level: 20,
      health: 500,
      mana: 200,
      stamina: 150,
      attack: 40,
      defense: 25,
      speed: 3,
      accuracy: 0.95,
      rarity: EnemyRarity.legendary,
      skills: ['skill_fireball', 'skill_power_strike', 'skill_ultimate'],
      dropsGold: 2000,
      dropsExperience: 5000,
      isBoss: true,
    ));
  }

  /// スキルを登録
  void _registerSkill(CombatSkill skill) {
    _skills[skill.id] = skill;
  }

  /// ステータス効果を登録
  void _registerStatusEffect(StatusEffect effect) {
    _statusEffects[effect.id] = effect;
  }

  /// 敵テンプレートを登録
  void _registerEnemyTemplate(EnemyTemplate template) {
    _enemyTemplates[template.id] = template;
  }

  /// 戦闘を開始
  Battle startBattle(
    String battleId,
    List<BattleCharacter> players,
    List<BattleCharacter> enemies,
  ) {
    final battle = Battle(
      id: battleId,
      players: players,
      enemies: enemies,
      currentTurn: 0,
      battleState: BattleState.active,
      turnOrder: _calculateTurnOrder(players + enemies),
      turnIndex: 0,
      winner: null,
    );

    _activeBattles[battleId] = battle;
    return battle;
  }

  /// ターンオーダーを計算
  List<BattleCharacter> _calculateTurnOrder(List<BattleCharacter> characters) {
    final sorted = [...characters];
    sorted.sort((a, b) => b.speed.compareTo(a.speed));
    return sorted;
  }

  /// プレイヤーアクションを実行
  bool executeAction(
    String battleId,
    String characterId,
    String skillId,
    String targetId,
  ) {
    final battle = _activeBattles[battleId];
    if (battle == null) return false;

    final character = battle.getCharacterById(characterId);
    final skill = _skills[skillId];
    final target = battle.getCharacterById(targetId);

    if (character == null || skill == null || target == null) return false;

    // コストをチェック
    if (skill.costType == CostType.stamina &&
        character.currentStamina < skill.costAmount) {
      return false;
    }

    if (skill.costType == CostType.mana &&
        character.currentMana < skill.costAmount) {
      return false;
    }

    // コストを消費
    if (skill.costType == CostType.stamina) {
      character.currentStamina -= skill.costAmount;
    } else if (skill.costType == CostType.mana) {
      character.currentMana -= skill.costAmount;
    }

    // ダメージまたは回復を計算
    if (skill.skillType == SkillType.healing) {
      int healAmount = skill.healAmount;
      target.currentHealth =
          (target.currentHealth + healAmount).clamp(0, target.maxHealth);
    } else {
      int damage = _calculateDamage(character, target, skill);

      // 命中判定
      if (_isAccurate(skill.accuracy)) {
        // クリティカル判定
        if (_isCritical(skill.criticalChance)) {
          damage = (damage * 1.5).toInt();
        }
        target.currentHealth =
            (target.currentHealth - damage).clamp(0, target.maxHealth);
      }
    }

    // ステータス効果を適用
    for (final statusId in skill.statusEffects) {
      final status = _statusEffects[statusId];
      if (status != null) {
        target.applyStatusEffect(status);
      }
    }

    battle.addActionLog(
      '$characterId used $skillId on $targetId',
    );

    return true;
  }

  /// ダメージを計算
  int _calculateDamage(
    BattleCharacter attacker,
    BattleCharacter defender,
    CombatSkill skill,
  ) {
    final baseDamage =
        (attacker.attack * skill.damageMultiplier).toInt();
    final defenseFactor = defender.defense;
    final rawDamage = (baseDamage - defenseFactor / 2).toInt();
    return rawDamage.clamp(1, 999);
  }

  /// 命中判定
  bool _isAccurate(double accuracy) {
    final random = (DateTime.now().millisecondsSinceEpoch % 100).toDouble() / 100;
    return random < accuracy;
  }

  /// クリティカル判定
  bool _isCritical(double criticalChance) {
    final random = (DateTime.now().millisecondsSinceEpoch % 100).toDouble() / 100;
    return random < criticalChance;
  }

  /// ターンを進める
  bool advanceTurn(String battleId) {
    final battle = _activeBattles[battleId];
    if (battle == null) return false;

    // 次のキャラクターを取得
    battle.turnIndex = (battle.turnIndex + 1) % battle.turnOrder.length;
    battle.currentTurn++;

    // ステータス効果を処理
    for (final character in battle.turnOrder) {
      character.updateStatusEffects();
    }

    // 勝利/敗北条件をチェック
    _checkBattleEnd(battle);

    return true;
  }

  /// 戦闘終了を確認
  void _checkBattleEnd(Battle battle) {
    final allPlayersDefeated =
        battle.players.every((p) => p.currentHealth <= 0);
    final allEnemiesDefeated =
        battle.enemies.every((e) => e.currentHealth <= 0);

    if (allPlayersDefeated) {
      battle.battleState = BattleState.defeat;
      battle.winner = BattleWinner.enemies;
    } else if (allEnemiesDefeated) {
      battle.battleState = BattleState.victory;
      battle.winner = BattleWinner.players;
    }
  }

  /// 戦闘を終了
  BattleReward? endBattle(String battleId) {
    final battle = _activeBattles[battleId];
    if (battle == null) return null;

    if (battle.winner == BattleWinner.players) {
      final reward = _calculateReward(battle);
      _saveBattleLog(battle);
      _activeBattles.remove(battleId);
      return reward;
    }

    return null;
  }

  /// 報酬を計算
  BattleReward _calculateReward(Battle battle) {
    int totalGold = 0;
    int totalXP = 0;

    for (final enemy in battle.enemies) {
      totalGold += enemy.dropsGold;
      totalXP += enemy.dropsExperience;
    }

    return BattleReward(
      goldReward: totalGold,
      experienceReward: totalXP,
      items: [],
      achievements: [],
    );
  }

  /// 戦闘ログを保存
  void _saveBattleLog(Battle battle) {
    // プレイヤーごとにログを保存
    for (final player in battle.players) {
      _battleLogs.putIfAbsent(player.id, () => []);
      _battleLogs[player.id]!.add(
        BattleLog(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          enemyNames: battle.enemies.map((e) => e.name).toList(),
          goldReward: 0,
          experienceReward: 0,
          victory: true,
        ),
      );
    }
  }

  /// スキルを取得
  CombatSkill? getSkill(String skillId) {
    return _skills[skillId];
  }

  /// すべてのスキルを取得
  List<CombatSkill> getAllSkills() {
    return _skills.values.toList();
  }

  /// 敵テンプレートを取得
  EnemyTemplate? getEnemyTemplate(String templateId) {
    return _enemyTemplates[templateId];
  }

  /// 敵を生成
  BattleCharacter createEnemyFromTemplate(String templateId) {
    final template = _enemyTemplates[templateId];
    if (template == null) {
      throw Exception('Enemy template not found: $templateId');
    }

    return BattleCharacter(
      id: '${templateId}_${DateTime.now().millisecondsSinceEpoch}',
      name: template.name,
      level: template.level,
      maxHealth: template.health,
      currentHealth: template.health,
      maxMana: template.mana,
      currentMana: template.mana,
      maxStamina: template.stamina,
      currentStamina: template.stamina,
      attack: template.attack,
      defense: template.defense,
      speed: template.speed,
      accuracy: template.accuracy,
      dropsGold: template.dropsGold,
      dropsExperience: template.dropsExperience,
      availableSkills: template.skills,
      statusEffects: [],
      isBoss: template.isBoss,
      isPlayer: false,
    );
  }

  /// 戦闘ログを取得
  List<BattleLog> getBattleLogs(String playerId) {
    return _battleLogs[playerId] ?? [];
  }
}

/// 戦闘
class Battle {
  final String id;
  final List<BattleCharacter> players;
  final List<BattleCharacter> enemies;
  int currentTurn;
  BattleState battleState;
  final List<BattleCharacter> turnOrder;
  int turnIndex;
  BattleWinner? winner;
  final List<String> actionLog = [];

  Battle({
    required this.id,
    required this.players,
    required this.enemies,
    required this.currentTurn,
    required this.battleState,
    required this.turnOrder,
    required this.turnIndex,
    required this.winner,
  });

  /// キャラクターを取得
  BattleCharacter? getCharacterById(String id) {
    try {
      return turnOrder.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// アクションログを追加
  void addActionLog(String action) {
    actionLog.add('Turn $currentTurn: $action');
  }
}

/// 戦闘キャラクター
class BattleCharacter {
  final String id;
  final String name;
  final int level;
  int maxHealth;
  int currentHealth;
  int maxMana;
  int currentMana;
  int maxStamina;
  int currentStamina;
  int attack;
  int defense;
  int speed;
  double accuracy;
  int dropsGold;
  int dropsExperience;
  final List<String> availableSkills;
  final List<StatusEffect> statusEffects;
  bool isBoss;
  bool isPlayer;

  BattleCharacter({
    required this.id,
    required this.name,
    required this.level,
    required this.maxHealth,
    required this.currentHealth,
    required this.maxMana,
    required this.currentMana,
    required this.maxStamina,
    required this.currentStamina,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.accuracy,
    required this.dropsGold,
    required this.dropsExperience,
    required this.availableSkills,
    required this.statusEffects,
    this.isBoss = false,
    this.isPlayer = true,
  });

  /// ステータス効果を適用
  void applyStatusEffect(StatusEffect effect) {
    if (!effect.stackable) {
      // 同じ効果があれば除去
      statusEffects.removeWhere((s) => s.id == effect.id);
    }
    statusEffects.add(effect);
  }

  /// ステータス効果を更新
  void updateStatusEffects() {
    for (final effect in statusEffects) {
      if (effect.effectType == EffectType.damage) {
        currentHealth =
            (currentHealth - effect.damagePerTurn).clamp(0, maxHealth);
      }
    }

    // 期間終了した効果を削除
    statusEffects.removeWhere((s) => (s.durationTurns--) <= 0);
  }

  /// 戦闘不能か確認
  bool isDefeated() {
    return currentHealth <= 0;
  }
}

/// 戦闘スキル
class CombatSkill {
  final String id;
  final String name;
  final String description;
  final SkillType skillType;
  final CostType costType;
  final int costAmount;
  final int cooldown;
  final TargetType targetType;
  final double damageMultiplier;
  final double defenseMultiplier;
  final int healAmount;
  final double accuracy;
  final double criticalChance;
  final List<String> statusEffects;

  CombatSkill({
    required this.id,
    required this.name,
    required this.description,
    required this.skillType,
    required this.costType,
    required this.costAmount,
    required this.cooldown,
    required this.targetType,
    this.damageMultiplier = 1.0,
    this.defenseMultiplier = 1.0,
    this.healAmount = 0,
    required this.accuracy,
    required this.criticalChance,
    required this.statusEffects,
  });
}

/// ステータス効果
class StatusEffect {
  final String id;
  final String name;
  final String description;
  final EffectType effectType;
  final int damagePerTurn;
  int durationTurns;
  final bool stackable;
  final Map<String, int> statModifier;
  final bool preventAction;
  final String icon;

  StatusEffect({
    required this.id,
    required this.name,
    required this.description,
    required this.effectType,
    this.damagePerTurn = 0,
    required this.durationTurns,
    required this.stackable,
    this.statModifier = const {},
    this.preventAction = false,
    this.icon = '',
  });
}

/// 敵テンプレート
class EnemyTemplate {
  final String id;
  final String name;
  final String description;
  final int level;
  final int health;
  final int mana;
  final int stamina;
  final int attack;
  final int defense;
  final int speed;
  final double accuracy;
  final EnemyRarity rarity;
  final List<String> skills;
  final int dropsGold;
  final int dropsExperience;
  final Map<String, int> resistances;
  final bool isBoss;

  EnemyTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.health,
    required this.mana,
    required this.stamina,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.accuracy,
    required this.rarity,
    required this.skills,
    required this.dropsGold,
    required this.dropsExperience,
    this.resistances = const {},
    this.isBoss = false,
  });
}

/// 戦闘報酬
class BattleReward {
  final int goldReward;
  final int experienceReward;
  final List<String> items;
  final List<String> achievements;

  BattleReward({
    required this.goldReward,
    required this.experienceReward,
    required this.items,
    required this.achievements,
  });
}

/// 戦闘ログ
class BattleLog {
  final int timestamp;
  final List<String> enemyNames;
  final int goldReward;
  final int experienceReward;
  final bool victory;

  BattleLog({
    required this.timestamp,
    required this.enemyNames,
    required this.goldReward,
    required this.experienceReward,
    required this.victory,
  });
}

/// 戦闘状態
enum BattleState {
  active,
  victory,
  defeat,
  paused,
}

/// 戦闘勝者
enum BattleWinner {
  players,
  enemies,
}

/// スキルタイプ
enum SkillType {
  physical, // 物理攻撃
  magical, // 魔法攻撃
  healing, // 回復
  defensive, // 防御
  utility, // 補助
}

/// コストタイプ
enum CostType {
  stamina, // スタミナ
  mana, // マナ
  health, // HP (自傷)
  ultimate, // 必殺技ゲージ
}

/// ターゲットタイプ
enum TargetType {
  self, // 自分
  singleAlly, // 単体味方
  allAllies, // 全味方
  singleEnemy, // 単体敵
  allEnemies, // 全敵
  areaOfEffect, // 範囲効果
}

/// 効果タイプ
enum EffectType {
  buff, // バフ (良い効果)
  debuff, // デバフ (悪い効果)
  damage, // ダメージ
  crowd_control, // CC (行動制限)
}

/// 敵レアリティ
enum EnemyRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}
