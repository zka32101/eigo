/// ギルド戦・領域戦システム
/// ギルド間戦争、領域支配、戦力システム

/// ギルド戦・領域戦システム
class GuildWarsSystem {
  static final GuildWarsSystem _instance = GuildWarsSystem._internal();

  factory GuildWarsSystem.getInstance() {
    return _instance;
  }

  GuildWarsSystem._internal();

  // ギルド戦: war_id -> GuildWar
  final Map<String, GuildWar> _wars = {};

  // 領域支配: territory_id -> ControlData
  final Map<String, TerritoryControl> _territoryControl = {};

  // ギルド戦力: guild_id -> GuildForce
  final Map<String, GuildForce> _guildForces = {};

  // 戦争履歴: war_id -> WarResult
  final Map<String, WarResult> _warHistory = {};

  // プレイヤー貢献度: player_id -> List<contribution>
  final Map<String, List<PlayerContribution>> _playerContributions = {};

  // 領域所有権: territory_id -> guild_id
  final Map<String, String> _territoryOwnership = {};

  // ギルド同盟: guild_id -> List<allied_guild_id>
  final Map<String, List<String>> _guildAlliances = {};

  /// システムを初期化
  void initialize() {
    _wars.clear();
    _territoryControl.clear();
    _guildForces.clear();
    _warHistory.clear();
    _playerContributions.clear();
    _territoryOwnership.clear();
    _guildAlliances.clear();

    _initializeGuildForces();
    _initializeTerritories();
  }

  /// ギルド戦力を初期化
  void _initializeGuildForces() {
    _guildForces['guild_mage_tower'] = GuildForce(
      guildId: 'guild_mage_tower',
      guildName: 'Mage Tower',
      totalMembers: 50,
      activeMembers: 35,
      averageLevel: 22,
      totalPower: 1750,
      morale: 85,
    );

    _guildForces['guild_adventurers'] = GuildForce(
      guildId: 'guild_adventurers',
      guildName: 'Adventurers Guild',
      totalMembers: 60,
      activeMembers: 40,
      averageLevel: 24,
      totalPower: 1920,
      morale: 90,
    );

    _guildForces['guild_merchants'] = GuildForce(
      guildId: 'guild_merchants',
      guildName: 'Merchant Cartel',
      totalMembers: 45,
      activeMembers: 30,
      averageLevel: 20,
      totalPower: 1500,
      morale: 75,
    );
  }

  /// 領域を初期化
  void _initializeTerritories() {
    const territories = [
      'arcane_citadel',
      'martial_fortress',
      'commerce_harbor',
      'natural_forest',
      'mineral_canyon',
      'maritime_coast',
    ];

    for (int i = 0; i < territories.length; i++) {
      final owner = ['guild_mage_tower', 'guild_adventurers', 'guild_merchants'][i % 3];
      _territoryOwnership[territories[i]] = owner;
      _territoryControl[territories[i]] = TerritoryControl(
        territoryId: territories[i],
        controllingGuild: owner,
        controlPercentage: 100,
        lastCapturedAt: DateTime.now().millisecondsSinceEpoch,
        defensePower: 100,
      );
    }
  }

  /// ギルド戦を宣言
  bool declareWar(
    String attackerGuildId,
    String defenderGuildId,
    String territory,
    int duration,
  ) {
    if (_territoryOwnership[territory] != defenderGuildId) {
      return false; // 防御ギルドが領域を支配していない
    }

    final warId = 'war_${DateTime.now().millisecondsSinceEpoch}';
    final war = GuildWar(
      id: warId,
      attackerGuildId: attackerGuildId,
      defenderGuildId: defenderGuildId,
      territory: territory,
      startTime: DateTime.now().millisecondsSinceEpoch,
      duration: duration,
      attackerScore: 0,
      defenderScore: 0,
      status: WarStatus.active,
    );

    _wars[warId] = war;
    return true;
  }

  /// プレイヤーが戦争に貢献
  bool contributeToWar(
    String playerId,
    String warId,
    int damage,
    int healingProvided,
  ) {
    final war = _wars[warId];
    if (war == null || war.status != WarStatus.active) {
      return false;
    }

    final contribution = PlayerContribution(
      playerId: playerId,
      warId: warId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      damageDealt: damage,
      healingProvided: healingProvided,
      score: (damage ~/ 10) + (healingProvided ~/ 20),
    );

    _playerContributions.putIfAbsent(playerId, () => []);
    _playerContributions[playerId]!.add(contribution);

    // スコアを更新（簡略版：プレイヤーの所属ギルドで判定）
    war.attackerScore += contribution.score ~/ 2;
    war.defenderScore += contribution.score ~/ 2;

    return true;
  }

  /// 領域の支配権を更新
  bool updateTerritoryControl(
    String territory,
    String attackerGuild,
    int attackerScore,
    int defenderScore,
  ) {
    final control = _territoryControl[territory];
    if (control == null) return false;

    // 支配度を計算
    final totalScore = attackerScore + defenderScore;
    if (totalScore == 0) return false;

    final attackerPercentage = (attackerScore / totalScore * 100).toInt();

    if (attackerPercentage > 60) {
      // 攻撃ギルドが領域を奪取
      _territoryOwnership[territory] = attackerGuild;
      control.controllingGuild = attackerGuild;
      control.controlPercentage = attackerPercentage;
      control.lastCapturedAt = DateTime.now().millisecondsSinceEpoch;
      return true;
    } else if (attackerPercentage < 40) {
      // 防御ギルドが領域を保持
      control.controlPercentage = 100 - attackerPercentage;
      return false;
    }

    // 50-50は分割支配
    control.controlPercentage = attackerPercentage;
    return false;
  }

  /// 戦争を終了
  bool concludeWar(String warId) {
    final war = _wars[warId];
    if (war == null) return false;

    // 戦争が終了したかチェック
    final elapsed =
        (DateTime.now().millisecondsSinceEpoch - war.startTime) ~/ 3600000;
    if (elapsed < war.duration) return false;

    // 結果を決定
    WarResultStatus resultStatus;
    String winner;

    if (war.attackerScore > war.defenderScore) {
      resultStatus = WarResultStatus.attackerVictory;
      winner = war.attackerGuildId;
    } else if (war.defenderScore > war.attackerScore) {
      resultStatus = WarResultStatus.defenderVictory;
      winner = war.defenderGuildId;
    } else {
      resultStatus = WarResultStatus.draw;
      winner = '';
    }

    // 領域支配を更新
    if (resultStatus == WarResultStatus.attackerVictory) {
      updateTerritoryControl(
        war.territory,
        war.attackerGuildId,
        war.attackerScore,
        war.defenderScore,
      );
    }

    // 戦争結果を記録
    final result = WarResult(
      warId: warId,
      attackerGuildId: war.attackerGuildId,
      defenderGuildId: war.defenderGuildId,
      territory: war.territory,
      resultStatus: resultStatus,
      winner: winner,
      attackerFinalScore: war.attackerScore,
      defenderFinalScore: war.defenderScore,
      endedAt: DateTime.now().millisecondsSinceEpoch,
      reward: _calculateReward(war),
    );

    _warHistory[warId] = result;
    war.status = WarStatus.concluded;

    return true;
  }

  /// 報酬を計算
  int _calculateReward(GuildWar war) {
    final scoreDifference = (war.attackerScore - war.defenderScore).abs();
    return 100 + (scoreDifference ~/ 10);
  }

  /// ギルド戦力を取得
  GuildForce? getGuildForce(String guildId) {
    return _guildForces[guildId];
  }

  /// アクティブな戦争を取得
  List<GuildWar> getActiveWars() {
    return _wars.values
        .where((w) => w.status == WarStatus.active)
        .toList();
  }

  /// 領域の所有者を取得
  String? getTerritoryOwner(String territory) {
    return _territoryOwnership[territory];
  }

  /// 領域支配データを取得
  TerritoryControl? getTerritoryControl(String territory) {
    return _territoryControl[territory];
  }

  /// ギルドが支配する領域を取得
  List<String> getControlledTerritories(String guildId) {
    return _territoryOwnership.entries
        .where((e) => e.value == guildId)
        .map((e) => e.key)
        .toList();
  }

  /// プレイヤー貢献度を取得
  List<PlayerContribution> getPlayerContributions(String playerId) {
    return _playerContributions[playerId] ?? [];
  }

  /// 戦争結果を取得
  WarResult? getWarResult(String warId) {
    return _warHistory[warId];
  }

  /// ギルド同盟を設定
  void setGuildAlliance(String guildId1, String guildId2) {
    _guildAlliances.putIfAbsent(guildId1, () => []);
    _guildAlliances.putIfAbsent(guildId2, () => []);

    if (!_guildAlliances[guildId1]!.contains(guildId2)) {
      _guildAlliances[guildId1]!.add(guildId2);
    }
    if (!_guildAlliances[guildId2]!.contains(guildId1)) {
      _guildAlliances[guildId2]!.add(guildId1);
    }
  }

  /// ギルド情報レポートを取得
  String getGuildReport(String guildId) {
    final force = _guildForces[guildId];
    if (force == null) return 'Guild not found';

    final territories = getControlledTerritories(guildId);

    return '''
Guild: ${force.guildName}
Members: ${force.activeMembers}/${force.totalMembers}
Average Level: ${force.averageLevel}

Combat Power: ${force.totalPower}
Morale: ${force.morale}/100

Controlled Territories: ${territories.length}
${territories.map((t) => '  - $t').join('\n')}
''';
  }

  /// 戦争統計を取得
  String getWarStatistics(String warId) {
    final war = _wars[warId];
    if (war == null) return 'War not found';

    return '''
War: $warId
Status: ${war.status}

Attacker: ${war.attackerGuildId} (${war.attackerScore})
Defender: ${war.defenderGuildId} (${war.defenderScore})
Territory: ${war.territory}

Duration: ${war.duration}h
''';
  }
}

/// ギルド戦
class GuildWar {
  final String id;
  final String attackerGuildId;
  final String defenderGuildId;
  final String territory;
  final int startTime;
  final int duration;
  int attackerScore;
  int defenderScore;
  WarStatus status;

  GuildWar({
    required this.id,
    required this.attackerGuildId,
    required this.defenderGuildId,
    required this.territory,
    required this.startTime,
    required this.duration,
    required this.attackerScore,
    required this.defenderScore,
    required this.status,
  });

  /// 戦争の経過時間（時間）を取得
  int getElapsedHours() {
    return (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 3600000;
  }

  /// 戦争が終了したかチェック
  bool isExpired() {
    return getElapsedHours() >= duration;
  }
}

/// ギルド戦ステータス
enum WarStatus {
  pending,
  active,
  concluded,
}

/// ギルド戦力
class GuildForce {
  final String guildId;
  final String guildName;
  final int totalMembers;
  int activeMembers;
  final int averageLevel;
  int totalPower;
  int morale;

  GuildForce({
    required this.guildId,
    required this.guildName,
    required this.totalMembers,
    required this.activeMembers,
    required this.averageLevel,
    required this.totalPower,
    required this.morale,
  });

  /// ギルドの戦闘力レベルを取得
  String getPowerLevel() {
    if (totalPower > 2000) return '最強';
    if (totalPower > 1500) return '強力';
    if (totalPower > 1000) return '中程度';
    return '弱小';
  }

  /// ギルドの状態を取得
  String getStatus() {
    if (morale < 50) return '低迷中';
    if (morale < 75) return '安定';
    return '好調';
  }
}

/// 領域支配
class TerritoryControl {
  final String territoryId;
  String controllingGuild;
  int controlPercentage;
  int lastCapturedAt;
  int defensePower;

  TerritoryControl({
    required this.territoryId,
    required this.controllingGuild,
    required this.controlPercentage,
    required this.lastCapturedAt,
    required this.defensePower,
  });

  /// 支配がどのくらい安定しているか
  bool isStableControl() {
    return controlPercentage >= 80;
  }

  /// 支配日数を取得
  int getControlDays() {
    return (DateTime.now().millisecondsSinceEpoch - lastCapturedAt) ~/ 86400000;
  }
}

/// プレイヤー貢献度
class PlayerContribution {
  final String playerId;
  final String warId;
  final int timestamp;
  final int damageDealt;
  final int healingProvided;
  final int score;

  PlayerContribution({
    required this.playerId,
    required this.warId,
    required this.timestamp,
    required this.damageDealt,
    required this.healingProvided,
    required this.score,
  });
}

/// 戦争結果
class WarResult {
  final String warId;
  final String attackerGuildId;
  final String defenderGuildId;
  final String territory;
  final WarResultStatus resultStatus;
  final String winner;
  final int attackerFinalScore;
  final int defenderFinalScore;
  final int endedAt;
  final int reward;

  WarResult({
    required this.warId,
    required this.attackerGuildId,
    required this.defenderGuildId,
    required this.territory,
    required this.resultStatus,
    required this.winner,
    required this.attackerFinalScore,
    required this.defenderFinalScore,
    required this.endedAt,
    required this.reward,
  });
}

/// 戦争結果ステータス
enum WarResultStatus {
  attackerVictory,
  defenderVictory,
  draw,
}
