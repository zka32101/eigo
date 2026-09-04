/// ファクション戦争/競争システム
/// 派閥戦争、スコア追跡、報酬、イベント駆動型競争

/// ファクション戦争システム
class FactionWarSystem {
  static final FactionWarSystem _instance = FactionWarSystem._internal();

  factory FactionWarSystem.getInstance() {
    return _instance;
  }

  FactionWarSystem._internal();

  // 戦争: war_id -> War
  final Map<String, War> _wars = {};

  // アクティブな戦争: 常に最大3つ並行実施可能
  final List<String> _activeWars = [];

  // ファクション戦争スコア: faction_id -> total_score
  final Map<String, int> _factionWarScores = {};

  // ファクション勝利数: faction_id -> victories
  final Map<String, int> _factionVictories = {};

  /// システムを初期化
  void initialize() {
    _wars.clear();
    _activeWars.clear();
    _factionWarScores.clear();
    _factionVictories.clear();
    _initializeAllWars();
  }

  /// すべての戦争を初期化
  void _initializeAllWars() {
    // 現在のアクティブな戦争を作成
    _registerWar(War(
      id: 'war_001',
      name: 'Battle for Forest Territory',
      description: 'Three factions compete for control of the Ancient Forest',
      territory: 'forest_region',
      participants: ['mage_tower', 'adventurers_guild', 'merchant_cartel'],
      status: WarStatus.active,
      duration: const Duration(days: 30),
      startTime: DateTime.now(),
      rewards: WarReward(
        winnerGold: 5000,
        winnerExperience: 1000,
        participantGold: 1000,
        participantExperience: 300,
        reputationBoost: 50,
      ),
      scoreboard: {
        'mage_tower': 0,
        'adventurers_guild': 0,
        'merchant_cartel': 0,
      },
      objectives: [
        WarObjective(
          id: 'obj_001',
          description: 'Defeat 50 enemy units',
          progress: {'mage_tower': 12, 'adventurers_guild': 18, 'merchant_cartel': 5},
          target: 50,
          pointsPerCompletion: 100,
        ),
        WarObjective(
          id: 'obj_002',
          description: 'Control territory for 24 hours',
          progress: {'mage_tower': 18, 'adventurers_guild': 0, 'merchant_cartel': 6},
          target: 24,
          pointsPerCompletion: 150,
        ),
        WarObjective(
          id: 'obj_003',
          description: 'Gather 500 resources',
          progress: {'mage_tower': 180, 'adventurers_guild': 320, 'merchant_cartel': 95},
          target: 500,
          pointsPerCompletion: 75,
        ),
      ],
      playerContributions: {},
    ));

    _activeWars.add('war_001');

    // 次の戦争（計画中）
    _registerWar(War(
      id: 'war_002',
      name: 'Mountain Pass Supremacy',
      description: 'Competition for crystal mining rights in the mountains',
      territory: 'mountain_region',
      participants: ['mage_tower', 'adventurers_guild'],
      status: WarStatus.planning,
      duration: const Duration(days: 25),
      startTime: DateTime.now().add(const Duration(days: 5)),
      rewards: WarReward(
        winnerGold: 4000,
        winnerExperience: 800,
        participantGold: 800,
        participantExperience: 250,
        reputationBoost: 40,
      ),
      scoreboard: {
        'mage_tower': 0,
        'adventurers_guild': 0,
      },
      objectives: [
        WarObjective(
          id: 'obj_201',
          description: 'Mine 1000 crystals',
          progress: {'mage_tower': 0, 'adventurers_guild': 0},
          target: 1000,
          pointsPerCompletion: 50,
        ),
      ],
      playerContributions: {},
    ));

    // スコア初期化
    for (final faction in ['mage_tower', 'adventurers_guild', 'merchant_cartel']) {
      _factionWarScores[faction] = 0;
      _factionVictories[faction] = 0;
    }
  }

  /// 戦争を登録
  void _registerWar(War war) {
    _wars[war.id] = war;
  }

  /// 戦争を取得
  War? getWar(String warId) {
    return _wars[warId];
  }

  /// すべての戦争を取得
  List<War> getAllWars() {
    return _wars.values.toList();
  }

  /// アクティブな戦争を取得
  List<War> getActiveWars() {
    return _activeWars
        .map((id) => _wars[id])
        .whereType<War>()
        .where((w) => w.status == WarStatus.active)
        .toList();
  }

  /// プレイヤーが参加している戦争を取得
  List<War> getPlayerWars(String playerId, String factionId) {
    return getActiveWars()
        .where((w) => w.participants.contains(factionId))
        .toList();
  }

  /// 戦争にプレイヤーの貢献を記録
  bool recordPlayerContribution(
    String warId,
    String playerId,
    String factionId,
    int score,
    Map<String, int> objectiveProgress,
  ) {
    final war = _wars[warId];
    if (war == null || !war.participants.contains(factionId)) return false;

    // プレイヤーの貢献を記録
    war.playerContributions[playerId] = PlayerContribution(
      factionId: factionId,
      totalScore: score,
      timestamp: DateTime.now(),
      objectiveContributions: objectiveProgress,
    );

    // ファクションスコアを更新
    war.scoreboard[factionId] = (war.scoreboard[factionId] ?? 0) + score;
    _factionWarScores[factionId] = (_factionWarScores[factionId] ?? 0) + score;

    // オブジェクティブの進捗を更新
    for (final entry in objectiveProgress.entries) {
      final objId = entry.key;
      final progress = entry.value;

      final objective = war.objectives.cast<WarObjective?>().firstWhere(
        (obj) => obj?.id == objId,
        orElse: () => null,
      );

      if (objective != null) {
        objective.progress[factionId] =
            (objective.progress[factionId] ?? 0) + progress;
      }
    }

    return true;
  }

  /// 戦争の勝者を決定して終了
  bool concludeWar(String warId) {
    final war = _wars[warId];
    if (war == null || war.status != WarStatus.active) return false;

    // スコアボードから勝者を決定
    int maxScore = 0;
    String? winner;

    for (final entry in war.scoreboard.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        winner = entry.key;
      }
    }

    if (winner == null) return false;

    // 戦争を完了状態に
    war.status = WarStatus.concluded;
    war.winner = winner;

    _factionVictories[winner] = (_factionVictories[winner] ?? 0) + 1;

    return true;
  }

  /// ファクションの戦争スコアを取得
  int getFactionWarScore(String factionId) {
    return _factionWarScores[factionId] ?? 0;
  }

  /// ファクションの戦争勝利数を取得
  int getFactionVictories(String factionId) {
    return _factionVictories[factionId] ?? 0;
  }

  /// ファクションの戦争統計を取得
  WarStats getFactionWarStats(String factionId) {
    final participatedWars = _wars.values
        .where((w) => w.participants.contains(factionId))
        .toList();

    final wins = participatedWars
        .where((w) => w.winner == factionId && w.status == WarStatus.concluded)
        .length;

    final totalScore = _factionWarScores[factionId] ?? 0;
    final victories = _factionVictories[factionId] ?? 0;

    return WarStats(
      totalParticipations: participatedWars.length,
      wins: wins,
      losses: participatedWars.length - wins,
      totalScore: totalScore,
      victories: victories,
      averageScore: participatedWars.isEmpty ? 0 : totalScore ~/ participatedWars.length,
    );
  }

  /// 戦争ランキングを取得
  List<WarRanking> getWarRankings(String warId) {
    final war = _wars[warId];
    if (war == null) return [];

    final rankings = <WarRanking>[];

    for (final entry in war.scoreboard.entries) {
      rankings.add(WarRanking(
        factionId: entry.key,
        score: entry.value,
        rank: 0, // 後で設定される
      ));
    }

    // スコアでソート
    rankings.sort((a, b) => b.score.compareTo(a.score));

    // ランクを設定
    for (int i = 0; i < rankings.length; i++) {
      rankings[i].rank = i + 1;
    }

    return rankings;
  }

  /// プレイヤーの戦争報酬を計算
  WarParticipantReward calculatePlayerReward(
    String warId,
    String playerId,
    String factionId,
  ) {
    final war = _wars[warId];
    if (war == null) return WarParticipantReward(gold: 0, experience: 0, reputation: 0);

    final contribution = war.playerContributions[playerId];
    if (contribution == null) {
      return WarParticipantReward(gold: 0, experience: 0, reputation: 0);
    }

    final isFactionWinner = war.winner == factionId;

    return WarParticipantReward(
      gold: isFactionWinner
          ? war.rewards.winnerGold + (contribution.totalScore ~/ 10)
          : war.rewards.participantGold,
      experience: isFactionWinner
          ? war.rewards.winnerExperience + (contribution.totalScore ~/ 5)
          : war.rewards.participantExperience,
      reputation: war.rewards.reputationBoost + (contribution.totalScore ~/ 20),
    );
  }

  /// 新しい戦争を開始
  bool startNewWar(War newWar) {
    if (_activeWars.length >= 3) return false; // 最大3つまで

    _registerWar(newWar);
    _activeWars.add(newWar.id);
    return true;
  }

  /// 戦争オブジェクティブの進捗を取得
  double getObjectiveProgress(String warId, String objectiveId, String factionId) {
    final war = _wars[warId];
    if (war == null) return 0.0;

    final objective = war.objectives.cast<WarObjective?>().firstWhere(
      (obj) => obj?.id == objectiveId,
      orElse: () => null,
    );

    if (objective == null) return 0.0;

    final progress = objective.progress[factionId] ?? 0;
    return (progress / objective.target).clamp(0.0, 1.0);
  }
}

/// 戦争定義
class War {
  final String id;
  final String name;
  final String description;
  final String territory;
  final List<String> participants;
  WarStatus status;
  final Duration duration;
  final DateTime startTime;
  final WarReward rewards;
  final Map<String, int> scoreboard;
  final List<WarObjective> objectives;
  final Map<String, PlayerContribution> playerContributions;
  String? winner;

  War({
    required this.id,
    required this.name,
    required this.description,
    required this.territory,
    required this.participants,
    required this.status,
    required this.duration,
    required this.startTime,
    required this.rewards,
    required this.scoreboard,
    required this.objectives,
    required this.playerContributions,
    this.winner,
  });

  /// 戦争の終了時刻を取得
  DateTime get endTime => startTime.add(duration);

  /// 戦争の残り時間を取得
  Duration get timeRemaining {
    final remaining = endTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 戦争が完了したか確認
  bool get isExpired => DateTime.now().isAfter(endTime);

  /// 戦争の進捗率を計算
  double getProgressPercentage() {
    final elapsed = DateTime.now().difference(startTime);
    return (elapsed.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
  }
}

/// 戦争ステータス
enum WarStatus {
  planning,     // 計画中
  active,       // アクティブ
  concluded,    // 完了
  cancelled,    // キャンセル
}

/// 戦争報酬
class WarReward {
  final int winnerGold;
  final int winnerExperience;
  final int participantGold;
  final int participantExperience;
  final int reputationBoost;

  WarReward({
    required this.winnerGold,
    required this.winnerExperience,
    required this.participantGold,
    required this.participantExperience,
    required this.reputationBoost,
  });
}

/// 戦争オブジェクティブ
class WarObjective {
  final String id;
  final String description;
  final Map<String, int> progress;
  final int target;
  final int pointsPerCompletion;

  WarObjective({
    required this.id,
    required this.description,
    required this.progress,
    required this.target,
    required this.pointsPerCompletion,
  });

  /// オブジェクティブの進捗率を取得
  double getCompletionPercentage(String factionId) {
    final factionProgress = progress[factionId] ?? 0;
    return (factionProgress / target).clamp(0.0, 1.0);
  }
}

/// プレイヤーの戦争貢献
class PlayerContribution {
  final String factionId;
  final int totalScore;
  final DateTime timestamp;
  final Map<String, int> objectiveContributions;

  PlayerContribution({
    required this.factionId,
    required this.totalScore,
    required this.timestamp,
    required this.objectiveContributions,
  });
}

/// 戦争参加者報酬
class WarParticipantReward {
  final int gold;
  final int experience;
  final int reputation;

  WarParticipantReward({
    required this.gold,
    required this.experience,
    required this.reputation,
  });
}

/// 戦争ランキング
class WarRanking {
  final String factionId;
  final int score;
  int rank;

  WarRanking({
    required this.factionId,
    required this.score,
    required this.rank,
  });
}

/// 戦争統計
class WarStats {
  final int totalParticipations;
  final int wins;
  final int losses;
  final int totalScore;
  final int victories;
  final int averageScore;

  WarStats({
    required this.totalParticipations,
    required this.wins,
    required this.losses,
    required this.totalScore,
    required this.victories,
    required this.averageScore,
  });

  /// 勝率を計算
  double getWinRate() {
    if (totalParticipations == 0) return 0.0;
    return wins / totalParticipations;
  }
}
