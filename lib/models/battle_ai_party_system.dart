/// 戦闘AI・パーティシステム
/// 敵AI、パーティ管理、戦闘フロー制御

/// 戦闘AI・パーティシステム
class BattleAIPartySystem {
  static final BattleAIPartySystem _instance =
      BattleAIPartySystem._internal();

  factory BattleAIPartySystem.getInstance() {
    return _instance;
  }

  BattleAIPartySystem._internal();

  // パーティ: player_id -> Party
  final Map<String, Party> _parties = {};

  // AI戦略: enemy_id -> AIStrategy
  final Map<String, AIStrategy> _aiStrategies = {};

  // 戦闘フロー: battle_id -> BattleFlow
  final Map<String, BattleFlow> _battleFlows = {};

  /// システムを初期化
  void initialize() {
    _parties.clear();
    _aiStrategies.clear();
    _battleFlows.clear();
    _initializeAllAIStrategies();
  }

  /// すべてのAI戦略を初期化
  void _initializeAllAIStrategies() {
    // 攻撃型AI
    _registerAIStrategy(AIStrategy(
      id: 'ai_aggressive',
      name: 'Aggressive',
      description: 'Focus on dealing damage',
      aiType: AIType.aggressive,
      actionPriorities: ['skill_power_strike', 'skill_fireball', 'skill_basic_attack'],
      healthThreshold: 0.3,
      healingPriority: 0.2,
    ));

    // 防御型AI
    _registerAIStrategy(AIStrategy(
      id: 'ai_defensive',
      name: 'Defensive',
      description: 'Focus on reducing damage',
      aiType: AIType.defensive,
      actionPriorities: ['skill_defend', 'skill_mass_heal', 'skill_basic_attack'],
      healthThreshold: 0.5,
      healingPriority: 0.8,
    ));

    // バランス型AI
    _registerAIStrategy(AIStrategy(
      id: 'ai_balanced',
      name: 'Balanced',
      description: 'Mix offense and defense',
      aiType: AIType.balanced,
      actionPriorities: ['skill_heal', 'skill_power_strike', 'skill_defend'],
      healthThreshold: 0.4,
      healingPriority: 0.5,
    ));

    // 支援型AI
    _registerAIStrategy(AIStrategy(
      id: 'ai_support',
      name: 'Support',
      description: 'Focus on healing allies',
      aiType: AIType.support,
      actionPriorities: ['skill_mass_heal', 'skill_heal', 'skill_basic_attack'],
      healthThreshold: 0.6,
      healingPriority: 0.95,
    ));
  }

  /// AI戦略を登録
  void _registerAIStrategy(AIStrategy strategy) {
    _aiStrategies[strategy.id] = strategy;
  }

  /// プレイヤーパーティを作成
  bool createParty(String playerId) {
    if (_parties.containsKey(playerId)) return false;

    _parties[playerId] = Party(
      playerId: playerId,
      members: [],
      maxSize: 4,
      formation: PartyFormation.standard,
      battleCount: 0,
      totalVictories: 0,
      totalDefeats: 0,
    );

    return true;
  }

  /// パーティにメンバーを追加
  bool addPartyMember(String playerId, String characterId, String characterName) {
    final party = _parties[playerId];
    if (party == null || party.members.length >= party.maxSize) return false;

    party.members.add(
      PartyMember(
        id: characterId,
        name: characterName,
        position: party.members.length,
        level: 1,
        battleParticipation: 0,
      ),
    );

    return true;
  }

  /// パーティからメンバーを削除
  bool removePartyMember(String playerId, String characterId) {
    final party = _parties[playerId];
    if (party == null) return false;

    party.members.removeWhere((m) => m.id == characterId);

    // 位置を再調整
    for (int i = 0; i < party.members.length; i++) {
      party.members[i].position = i;
    }

    return true;
  }

  /// パーティを取得
  Party? getParty(String playerId) {
    return _parties[playerId];
  }

  /// 敵AIのアクションを決定
  String decideEnemyAction(
    BattleCharacter enemy,
    List<BattleCharacter> enemies,
    List<BattleCharacter> players,
    String strategyId,
  ) {
    final strategy = _aiStrategies[strategyId] ?? _aiStrategies['ai_aggressive']!;

    // 健康度をチェック
    final healthRatio = enemy.currentHealth / enemy.maxHealth;
    if (healthRatio < strategy.healthThreshold && strategy.healingPriority > 0.5) {
      // 回復スキルを使用
      return 'skill_heal';
    }

    // 優先度に基づいてアクションを選択
    for (final skillId in strategy.actionPriorities) {
      if (enemy.availableSkills.contains(skillId)) {
        return skillId;
      }
    }

    // デフォルト: 通常攻撃
    return 'skill_basic_attack';
  }

  /// 敵のターゲットを決定
  String decideEnemyTarget(
    BattleCharacter enemy,
    List<BattleCharacter> players,
    String skillId,
  ) {
    if (skillId == 'skill_heal') {
      // 最も傷ついた味方にヒール
      final mostWounded = players.reduce((a, b) =>
          a.currentHealth / a.maxHealth < b.currentHealth / b.maxHealth ? a : b);
      return mostWounded.id;
    }

    // ランダムなプレイヤーを選択
    final randomIndex = (DateTime.now().millisecondsSinceEpoch % players.length);
    return players[randomIndex].id;
  }

  /// 戦闘フローを開始
  BattleFlow startBattleFlow(
    String battleId,
    List<BattleCharacter> players,
    List<BattleCharacter> enemies,
  ) {
    final flow = BattleFlow(
      battleId: battleId,
      currentPhase: BattlePhase.preparation,
      players: players,
      enemies: enemies,
      round: 0,
      actionsThisRound: [],
      turnHistory: [],
    );

    _battleFlows[battleId] = flow;
    return flow;
  }

  /// 戦闘フローを進める
  bool advanceBattleFlow(String battleId) {
    final flow = _battleFlows[battleId];
    if (flow == null) return false;

    switch (flow.currentPhase) {
      case BattlePhase.preparation:
        flow.currentPhase = BattlePhase.playerTurn;
        break;
      case BattlePhase.playerTurn:
        flow.currentPhase = BattlePhase.enemyTurn;
        break;
      case BattlePhase.enemyTurn:
        flow.round++;
        flow.currentPhase = BattlePhase.playerTurn;
        flow.actionsThisRound.clear();
        break;
      case BattlePhase.victory:
      case BattlePhase.defeat:
        return false; // 戦闘終了
    }

    return true;
  }

  /// ラウンド報告を取得
  String getRoundReport(String battleId) {
    final flow = _battleFlows[battleId];
    if (flow == null) return 'No battle';

    final playerHealth = flow.players
        .map((p) => '${p.name}: ${p.currentHealth}/${p.maxHealth}')
        .join(', ');
    final enemyHealth = flow.enemies
        .map((e) => '${e.name}: ${e.currentHealth}/${e.maxHealth}')
        .join(', ');

    return 'Round ${flow.round}\nPlayers: $playerHealth\nEnemies: $enemyHealth';
  }

  /// パーティ情報を取得
  String getPartyInfo(String playerId) {
    final party = _parties[playerId];
    if (party == null) return 'No party';

    final memberInfo = party.members
        .map((m) => '${m.name} (Lvl ${m.level}) - Position ${m.position + 1}')
        .join('\n');

    return '''
Party: ${party.playerId}
Size: ${party.members.length}/${party.maxSize}
Formation: ${party.formation.toString()}
Battles: ${party.battleCount} | Victories: ${party.totalVictories}

Members:
$memberInfo
''';
  }

  /// 戦闘フローを取得
  BattleFlow? getBattleFlow(String battleId) {
    return _battleFlows[battleId];
  }

  /// AI戦略を取得
  AIStrategy? getAIStrategy(String strategyId) {
    return _aiStrategies[strategyId];
  }
}

/// パーティ
class Party {
  final String playerId;
  final List<PartyMember> members;
  final int maxSize;
  PartyFormation formation;
  int battleCount; // 戦闘総数
  int totalVictories; // 勝利数
  int totalDefeats; // 敗北数

  Party({
    required this.playerId,
    required this.members,
    required this.maxSize,
    required this.formation,
    required this.battleCount,
    required this.totalVictories,
    required this.totalDefeats,
  });

  /// 勝率を計算
  double getWinRate() {
    if (battleCount == 0) return 0.0;
    return totalVictories / battleCount;
  }

  /// パーティは準備完了か
  bool isReady() {
    return members.isNotEmpty;
  }
}

/// パーティメンバー
class PartyMember {
  final String id;
  final String name;
  int position; // パーティ内の位置 (0-3)
  int level;
  int battleParticipation; // 参加した戦闘数

  PartyMember({
    required this.id,
    required this.name,
    required this.position,
    required this.level,
    required this.battleParticipation,
  });

  /// 有効な位置か
  bool isValidPosition() {
    return position >= 0 && position < 4;
  }
}

/// パーティ編成
enum PartyFormation {
  standard, // 標準編成
  aggressive, // 攻撃編成
  defensive, // 防御編成
  balanced, // バランス編成
}

/// AI戦略
class AIStrategy {
  final String id;
  final String name;
  final String description;
  final AIType aiType;
  final List<String> actionPriorities; // スキルID順
  final double healthThreshold; // 回復を始める健康度
  final double healingPriority; // 回復重視度

  AIStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.aiType,
    required this.actionPriorities,
    required this.healthThreshold,
    required this.healingPriority,
  });
}

/// AIタイプ
enum AIType {
  aggressive, // 攻撃重視
  defensive, // 防御重視
  balanced, // バランス
  support, // 支援重視
  intelligent, // 知的 (戦況判断)
}

/// 戦闘フロー
class BattleFlow {
  final String battleId;
  BattlePhase currentPhase;
  final List<BattleCharacter> players;
  final List<BattleCharacter> enemies;
  int round; // ラウンド数
  final List<String> actionsThisRound;
  final List<String> turnHistory;

  BattleFlow({
    required this.battleId,
    required this.currentPhase,
    required this.players,
    required this.enemies,
    required this.round,
    required this.actionsThisRound,
    required this.turnHistory,
  });

  /// 戦闘は続行中か
  bool isActive() {
    return currentPhase != BattlePhase.victory &&
        currentPhase != BattlePhase.defeat;
  }

  /// すべてのプレイヤーが敗北したか
  bool allPlayersDefeated() {
    return players.every((p) => p.currentHealth <= 0);
  }

  /// すべての敵が敗北したか
  bool allEnemiesDefeated() {
    return enemies.every((e) => e.currentHealth <= 0);
  }
}

/// 戦闘フェーズ
enum BattlePhase {
  preparation, // 準備フェーズ
  playerTurn, // プレイヤーのターン
  enemyTurn, // 敵のターン
  victory, // 勝利
  defeat, // 敗北
}

/// 戦闘キャラクター (戦闘システムから再エクスポート)
import 'combat_system.dart';
