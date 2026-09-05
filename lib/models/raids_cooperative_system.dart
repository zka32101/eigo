/// レイド・協力ダンジョンシステム
/// ギルド協力、ボス戦闘、報酬分配、進行度追跡

/// レイド・協力ダンジョンシステム
class RaidsCooperativeSystem {
  static final RaidsCooperativeSystem _instance =
      RaidsCooperativeSystem._internal();

  factory RaidsCooperativeSystem.getInstance() {
    return _instance;
  }

  RaidsCooperativeSystem._internal();

  // レイド: raid_id -> RaidInstance
  final Map<String, RaidInstance> _raids = {};

  // レイドボス: boss_id -> RaidBoss
  final Map<String, RaidBoss> _raidBosses = {};

  // プレイヤーパーティ: party_id -> RaidParty
  final Map<String, RaidParty> _raidParties = {};

  // ギルドレイド進行: guild_id -> List<RaidProgress>
  final Map<String, List<RaidProgress>> _guildRaidProgress = {};

  // プレイヤー戦利品: player_id -> List<LootDrop>
  final Map<String, List<LootDrop>> _playerLoot = {};

  // レイド結果履歴: raid_id -> RaidResult
  final Map<String, RaidResult> _raidHistory = {};

  // プレイヤー統計: player_id -> RaidStatistics
  final Map<String, RaidStatistics> _playerStats = {};

  // レイドスケジュール: schedule_id -> RaidSchedule
  final Map<String, RaidSchedule> _raidSchedules = {};

  /// システムを初期化
  void initialize() {
    _raids.clear();
    _raidBosses.clear();
    _raidParties.clear();
    _guildRaidProgress.clear();
    _playerLoot.clear();
    _raidHistory.clear();
    _playerStats.clear();
    _raidSchedules.clear();

    _initializeRaidBosses();
    _initializeRaidDifficulties();
  }

  /// レイドボスを初期化
  void _initializeRaidBosses() {
    _raidBosses['dragon_overlord'] = RaidBoss(
      id: 'dragon_overlord',
      name: 'Dragon Overlord',
      description: 'Ancient dragon ruling the sky',
      difficulty: 5,
      minPlayerLevel: 40,
      hpPool: 5000,
      damage: 150,
      mechanics: ['fire_breath', 'tail_sweep', 'flight_phase'],
      rewards: 2000,
    );

    _raidBosses['shadow_titan'] = RaidBoss(
      id: 'shadow_titan',
      name: 'Shadow Titan',
      description: 'Towering darkness entity',
      difficulty: 4,
      minPlayerLevel: 35,
      hpPool: 4000,
      damage: 120,
      mechanics: ['shadow_clone', 'darkness_aura', 'ground_slam'],
      rewards: 1500,
    );

    _raidBosses['celestial_guardian'] = RaidBoss(
      id: 'celestial_guardian',
      name: 'Celestial Guardian',
      description: 'Divine protector of light',
      difficulty: 3,
      minPlayerLevel: 30,
      hpPool: 3000,
      damage: 100,
      mechanics: ['holy_blast', 'shield_phase', 'light_judgment'],
      rewards: 1000,
    );

    _raidBosses['void_leviathan'] = RaidBoss(
      id: 'void_leviathan',
      name: 'Void Leviathan',
      description: 'Abyssal creature from the void',
      difficulty: 4,
      minPlayerLevel: 36,
      hpPool: 4200,
      damage: 130,
      mechanics: ['void_pulse', 'tentacle_strike', 'reality_warp'],
      rewards: 1600,
    );

    _raidBosses['infernal_phoenix'] = RaidBoss(
      id: 'infernal_phoenix',
      name: 'Infernal Phoenix',
      description: 'Eternal flame reborn',
      difficulty: 3,
      minPlayerLevel: 32,
      hpPool: 3200,
      damage: 110,
      mechanics: ['immolation', 'rebirth_phase', 'inferno_wave'],
      rewards: 1100,
    );
  }

  /// レイド難易度を初期化
  void _initializeRaidDifficulties() {
    // 難易度スケーリングは動的に計算される
  }

  /// レイドを開始
  bool startRaid(
    String raidId,
    String bossId,
    String guildId,
    List<String> partyMembers,
  ) {
    if (_raidBosses[bossId] == null) return false;
    if (partyMembers.isEmpty || partyMembers.length > 5) return false;

    final boss = _raidBosses[bossId]!;
    final raid = RaidInstance(
      id: raidId,
      bossId: bossId,
      guildId: guildId,
      partyMembers: partyMembers,
      startTime: DateTime.now().millisecondsSinceEpoch,
      bossHpRemaining: boss.hpPool,
      partyHpRemaining: partyMembers.length * 100,
      status: RaidStatus.active,
      damageDealt: 0,
      healingProvided: 0,
    );

    _raids[raidId] = raid;

    // プレイヤー統計を初期化
    for (final playerId in partyMembers) {
      _playerStats.putIfAbsent(
        playerId,
        () => RaidStatistics(
          playerId: playerId,
          raidsBossesFaced: 0,
          raidsCompleted: 0,
          raidsWiped: 0,
          totalDamageDealt: 0,
          totalHealingProvided: 0,
          lootCollected: 0,
        ),
      );
    }

    return true;
  }

  /// プレイヤーがレイドに貢献
  bool contributeToRaid(
    String raidId,
    String playerId,
    int damage,
    int healing,
  ) {
    final raid = _raids[raidId];
    if (raid == null || raid.status != RaidStatus.active) return false;

    // ボスHP削減
    raid.bossHpRemaining = (raid.bossHpRemaining - damage).clamp(0, 5000);
    raid.damageDealt += damage;

    // パーティHP復旧
    raid.partyHpRemaining = (raid.partyHpRemaining + healing).clamp(0, 500);
    raid.healingProvided += healing;

    // プレイヤー統計更新
    _playerStats.putIfAbsent(
      playerId,
      () => RaidStatistics(
        playerId: playerId,
        raidsBossesFaced: 0,
        raidsCompleted: 0,
        raidsWiped: 0,
        totalDamageDealt: 0,
        totalHealingProvided: 0,
        lootCollected: 0,
      ),
    );

    final stats = _playerStats[playerId]!;
    stats.totalDamageDealt += damage;
    stats.totalHealingProvided += healing;

    // ボスが倒されたかチェック
    if (raid.bossHpRemaining <= 0) {
      _concludeRaidVictory(raidId);
    }

    // パーティが全滅したかチェック
    if (raid.partyHpRemaining <= 0) {
      _concludeRaidWipe(raidId);
    }

    return true;
  }

  /// レイド勝利を終了
  void _concludeRaidVictory(String raidId) {
    final raid = _raids[raidId]!;
    final boss = _raidBosses[raid.bossId]!;

    raid.status = RaidStatus.victory;

    // 報酬を計算
    final reward = _calculateRaidReward(raid, boss, true);

    // 戦利品をドロップ
    for (final playerId in raid.partyMembers) {
      final loot = LootDrop(
        playerId: playerId,
        raidId: raidId,
        itemId: 'raid_loot_${DateTime.now().millisecondsSinceEpoch}',
        value: reward,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        rarity: _determineRarity(),
      );

      _playerLoot.putIfAbsent(playerId, () => []);
      _playerLoot[playerId]!.add(loot);

      final stats = _playerStats[playerId]!;
      stats.raidsCompleted++;
      stats.lootCollected += reward;
    }

    // レイド進行を記録
    _guildRaidProgress.putIfAbsent(raid.guildId, () => []);
    _guildRaidProgress[raid.guildId]!.add(
      RaidProgress(
        raidId: raidId,
        bossId: raid.bossId,
        completedAt: DateTime.now().millisecondsSinceEpoch,
        reward: reward,
        status: 'completed',
      ),
    );

    // レイド結果を記録
    _raidHistory[raidId] = RaidResult(
      raidId: raidId,
      bossId: raid.bossId,
      guildId: raid.guildId,
      partyMembers: raid.partyMembers,
      status: 'victory',
      damageDealt: raid.damageDealt,
      healingProvided: raid.healingProvided,
      totalReward: reward * raid.partyMembers.length,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// レイド全滅を終了
  void _concludeRaidWipe(String raidId) {
    final raid = _raids[raidId]!;

    raid.status = RaidStatus.wipe;

    // プレイヤー統計を更新
    for (final playerId in raid.partyMembers) {
      _playerStats[playerId]?.raidsWiped++;
      _playerStats[playerId]?.raidsBossesFaced++;
    }

    // レイド進行を記録
    _guildRaidProgress.putIfAbsent(raid.guildId, () => []);
    _guildRaidProgress[raid.guildId]!.add(
      RaidProgress(
        raidId: raidId,
        bossId: raid.bossId,
        completedAt: DateTime.now().millisecondsSinceEpoch,
        reward: 0,
        status: 'wipe',
      ),
    );

    // レイド結果を記録
    _raidHistory[raidId] = RaidResult(
      raidId: raidId,
      bossId: raid.bossId,
      guildId: raid.guildId,
      partyMembers: raid.partyMembers,
      status: 'wipe',
      damageDealt: raid.damageDealt,
      healingProvided: raid.healingProvided,
      totalReward: 0,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// レイド報酬を計算
  int _calculateRaidReward(RaidInstance raid, RaidBoss boss, bool victory) {
    if (!victory) return 0;

    final baseReward = boss.rewards;
    final damageBonus = (raid.damageDealt / 100).toInt();
    final healingBonus = (raid.healingProvided / 50).toInt();

    return baseReward + damageBonus + healingBonus;
  }

  /// レアリティを決定
  String _determineRarity() {
    final rand = DateTime.now().millisecondsSinceEpoch % 100;
    if (rand < 5) return 'legendary';
    if (rand < 15) return 'epic';
    if (rand < 40) return 'rare';
    return 'uncommon';
  }

  /// レイドパーティを作成
  bool createRaidParty(
    String partyId,
    String guildId,
    String leaderId,
    List<String> members,
  ) {
    if (members.length > 5) return false;

    final party = RaidParty(
      id: partyId,
      guildId: guildId,
      leaderId: leaderId,
      members: members,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      totalRaidsAttempted: 0,
      totalRaidsCompleted: 0,
      averageDPS: 0,
    );

    _raidParties[partyId] = party;
    return true;
  }

  /// レイドスケジュールを設定
  bool scheduleRaid(
    String scheduleId,
    String guildId,
    String bossId,
    int scheduledTime,
    List<String> invitedPlayers,
  ) {
    final schedule = RaidSchedule(
      id: scheduleId,
      guildId: guildId,
      bossId: bossId,
      scheduledTime: scheduledTime,
      invitedPlayers: invitedPlayers,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      status: 'scheduled',
    );

    _raidSchedules[scheduleId] = schedule;
    return true;
  }

  /// ボスをスポーン
  RaidBoss? getBoss(String bossId) {
    return _raidBosses[bossId];
  }

  /// アクティブなレイドを取得
  List<RaidInstance> getActiveRaids() {
    return _raids.values
        .where((r) => r.status == RaidStatus.active)
        .toList();
  }

  /// ギルドレイド進行を取得
  List<RaidProgress> getGuildRaidProgress(String guildId) {
    return _guildRaidProgress[guildId] ?? [];
  }

  /// プレイヤー戦利品を取得
  List<LootDrop> getPlayerLoot(String playerId) {
    return _playerLoot[playerId] ?? [];
  }

  /// プレイヤー統計を取得
  RaidStatistics? getPlayerStats(String playerId) {
    return _playerStats[playerId];
  }

  /// レイド結果を取得
  RaidResult? getRaidResult(String raidId) {
    return _raidHistory[raidId];
  }

  /// すべてのボスを取得
  List<RaidBoss> getAllBosses() {
    return _raidBosses.values.toList();
  }

  /// 難易度別ボスを取得
  List<RaidBoss> getBossesByDifficulty(int difficulty) {
    return _raidBosses.values
        .where((b) => b.difficulty == difficulty)
        .toList();
  }

  /// プレイヤーレベル別利用可能なボスを取得
  List<RaidBoss> getAvailableBossesForLevel(int playerLevel) {
    return _raidBosses.values
        .where((b) => b.minPlayerLevel <= playerLevel)
        .toList();
  }

  /// ギルドレイド報告を取得
  String getGuildRaidReport(String guildId) {
    final progress = _guildRaidProgress[guildId] ?? [];
    final completed = progress.where((p) => p.status == 'completed').length;
    final wipes = progress.where((p) => p.status == 'wipe').length;
    final totalReward =
        progress.fold<int>(0, (sum, p) => sum + p.reward);

    return '''
Guild Raid Report: $guildId

Statistics:
  Raids Completed: $completed
  Wipes: $wipes
  Total Attempts: ${progress.length}
  Total Rewards: ${totalReward}G
  Success Rate: ${progress.isNotEmpty ? ((completed / progress.length) * 100).toInt() : 0}%
''';
  }

  /// プレイヤーレイド統計を取得
  String getPlayerRaidReport(String playerId) {
    final stats = _playerStats[playerId];
    if (stats == null) return 'No raid data';

    final successRate = stats.raidsBossesFaced > 0
        ? ((stats.raidsCompleted / stats.raidsBossesFaced) * 100).toInt()
        : 0;

    return '''
Player Raid Statistics: $playerId

Experience:
  Bosses Faced: ${stats.raidsBossesFaced}
  Raids Completed: ${stats.raidsCompleted}
  Wipes: ${stats.raidsWiped}
  Success Rate: $successRate%

Performance:
  Total Damage: ${stats.totalDamageDealt}
  Total Healing: ${stats.totalHealingProvided}
  Loot Collected: ${stats.lootCollected}G
''';
  }

  /// レイドスケジュール一覧を取得
  List<RaidSchedule> getScheduledRaids(String guildId) {
    return _raidSchedules.values
        .where((s) => s.guildId == guildId && s.status == 'scheduled')
        .toList();
  }
}

/// レイドインスタンス
class RaidInstance {
  final String id;
  final String bossId;
  final String guildId;
  final List<String> partyMembers;
  final int startTime;
  int bossHpRemaining;
  int partyHpRemaining;
  RaidStatus status;
  int damageDealt;
  int healingProvided;

  RaidInstance({
    required this.id,
    required this.bossId,
    required this.guildId,
    required this.partyMembers,
    required this.startTime,
    required this.bossHpRemaining,
    required this.partyHpRemaining,
    required this.status,
    required this.damageDealt,
    required this.healingProvided,
  });

  /// レイド経過時間（秒）を取得
  int getElapsedSeconds() {
    return (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
  }

  /// ボスHP率を取得（0-100）
  int getBossHealthPercentage() {
    return ((bossHpRemaining / 5000) * 100).toInt().clamp(0, 100);
  }

  /// パーティHP率を取得（0-100）
  int getPartyHealthPercentage() {
    return ((partyHpRemaining / (partyMembers.length * 100)) * 100)
        .toInt()
        .clamp(0, 100);
  }
}

/// レイドステータス
enum RaidStatus {
  active,
  victory,
  wipe,
  abandoned,
}

/// レイドボス
class RaidBoss {
  final String id;
  final String name;
  final String description;
  final int difficulty;
  final int minPlayerLevel;
  final int hpPool;
  final int damage;
  final List<String> mechanics;
  final int rewards;

  RaidBoss({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.minPlayerLevel,
    required this.hpPool,
    required this.damage,
    required this.mechanics,
    required this.rewards,
  });

  /// ボス難易度レベルを取得
  String getDifficultyLabel() {
    switch (difficulty) {
      case 5:
        return 'Legendary';
      case 4:
        return 'Epic';
      case 3:
        return 'Hard';
      case 2:
        return 'Normal';
      default:
        return 'Easy';
    }
  }

  /// 推奨パーティサイズを取得
  int getRecommendedPartySize() {
    return (difficulty * 1.5).toInt().clamp(3, 5);
  }
}

/// レイドパーティ
class RaidParty {
  final String id;
  final String guildId;
  final String leaderId;
  final List<String> members;
  final int createdAt;
  int totalRaidsAttempted;
  int totalRaidsCompleted;
  int averageDPS;

  RaidParty({
    required this.id,
    required this.guildId,
    required this.leaderId,
    required this.members,
    required this.createdAt,
    required this.totalRaidsAttempted,
    required this.totalRaidsCompleted,
    required this.averageDPS,
  });

  /// パーティ成功率を取得（0-100）
  int getSuccessRate() {
    if (totalRaidsAttempted == 0) return 0;
    return ((totalRaidsCompleted / totalRaidsAttempted) * 100).toInt();
  }
}

/// レイド進行
class RaidProgress {
  final String raidId;
  final String bossId;
  final int completedAt;
  final int reward;
  final String status; // completed, wipe

  RaidProgress({
    required this.raidId,
    required this.bossId,
    required this.completedAt,
    required this.reward,
    required this.status,
  });
}

/// 戦利品ドロップ
class LootDrop {
  final String playerId;
  final String raidId;
  final String itemId;
  final int value;
  final int timestamp;
  final String rarity;

  LootDrop({
    required this.playerId,
    required this.raidId,
    required this.itemId,
    required this.value,
    required this.timestamp,
    required this.rarity,
  });

  /// レアリティ色を取得
  String getRarityColor() {
    switch (rarity) {
      case 'legendary':
        return 'gold';
      case 'epic':
        return 'purple';
      case 'rare':
        return 'blue';
      default:
        return 'green';
    }
  }
}

/// レイド結果
class RaidResult {
  final String raidId;
  final String bossId;
  final String guildId;
  final List<String> partyMembers;
  final String status; // victory, wipe
  final int damageDealt;
  final int healingProvided;
  final int totalReward;
  final int completedAt;

  RaidResult({
    required this.raidId,
    required this.bossId,
    required this.guildId,
    required this.partyMembers,
    required this.status,
    required this.damageDealt,
    required this.healingProvided,
    required this.totalReward,
    required this.completedAt,
  });

  /// DPS（秒あたりダメージ）を計算
  int calculateDPS(int elapsedSeconds) {
    if (elapsedSeconds == 0) return 0;
    return damageDealt ~/ elapsedSeconds;
  }
}

/// レイドスケジュール
class RaidSchedule {
  final String id;
  final String guildId;
  final String bossId;
  final int scheduledTime;
  final List<String> invitedPlayers;
  final int createdAt;
  String status; // scheduled, started, completed, cancelled

  RaidSchedule({
    required this.id,
    required this.guildId,
    required this.bossId,
    required this.scheduledTime,
    required this.invitedPlayers,
    required this.createdAt,
    required this.status,
  });

  /// スケジュール時間までの時間を取得（ミリ秒）
  int getTimeUntilRaid() {
    return (scheduledTime - DateTime.now().millisecondsSinceEpoch)
        .clamp(0, scheduledTime);
  }

  /// スケジュール時間までの時間を取得（時間単位）
  int getHoursUntilRaid() {
    return getTimeUntilRaid() ~/ 3600000;
  }
}

/// プレイヤーレイド統計
class RaidStatistics {
  final String playerId;
  int raidsBossesFaced;
  int raidsCompleted;
  int raidsWiped;
  int totalDamageDealt;
  int totalHealingProvided;
  int lootCollected;

  RaidStatistics({
    required this.playerId,
    required this.raidsBossesFaced,
    required this.raidsCompleted,
    required this.raidsWiped,
    required this.totalDamageDealt,
    required this.totalHealingProvided,
    required this.lootCollected,
  });

  /// 成功率を取得（0-100）
  int getSuccessRate() {
    if (raidsBossesFaced == 0) return 0;
    return ((raidsCompleted / raidsBossesFaced) * 100).toInt();
  }

  /// 平均DPSを計算
  int getAverageDPS() {
    if (raidsCompleted == 0) return 0;
    return totalDamageDealt ~/ raidsCompleted;
  }

  /// 平均HPS（秒あたり回復）を計算
  int getAverageHPS() {
    if (raidsCompleted == 0) return 0;
    return totalHealingProvided ~/ raidsCompleted;
  }

  /// レイダーランクを取得
  String getRaiderRank() {
    if (raidsCompleted >= 50) return 'Mythic Raider';
    if (raidsCompleted >= 30) return 'Legendary Raider';
    if (raidsCompleted >= 15) return 'Epic Raider';
    if (raidsCompleted >= 5) return 'Rare Raider';
    return 'Novice Raider';
  }
}
