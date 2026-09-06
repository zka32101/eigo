/// アリーナ・トーナメントシステム
/// プレイヤー対人戦闘、トーナメント括弧、季節的ランキング、競争的進行

/// アリーナ・トーナメントシステム
class ArenaTournamentsSystem {
  static final ArenaTournamentsSystem _instance =
      ArenaTournamentsSystem._internal();

  factory ArenaTournamentsSystem.getInstance() {
    return _instance;
  }

  ArenaTournamentsSystem._internal();

  // トーナメント: tournament_id -> Tournament
  final Map<String, Tournament> _tournaments = {};

  // アリーナマッチ: match_id -> ArenaMatch
  final Map<String, ArenaMatch> _arenaMatches = {};

  // プレイヤーランキング: player_id -> PlayerRanking
  final Map<String, PlayerRanking> _playerRankings = {};

  // トーナメント括弧: tournament_id -> TournamentBracket
  final Map<String, TournamentBracket> _tournamentBrackets = {};

  // プレイヤー戦績: player_id -> List<Match Result>
  final Map<String, List<MatchResult>> _playerMatchHistory = {};

  // 季節データ: season_id -> Season
  final Map<String, Season> _seasons = {};

  // シーズン統計: player_id -> SeasonStatistics
  final Map<String, Map<String, SeasonStatistics>> _seasonStatistics = {};

  // アリーナリーダーボード: season_id -> List<ranking>
  final Map<String, List<ArenaLeaderboard>> _leaderboards = {};

  /// システムを初期化
  void initialize() {
    _tournaments.clear();
    _arenaMatches.clear();
    _playerRankings.clear();
    _tournamentBrackets.clear();
    _playerMatchHistory.clear();
    _seasons.clear();
    _seasonStatistics.clear();
    _leaderboards.clear();

    _initializeSeasons();
    _initializePlayerRankings();
  }

  /// シーズンを初期化
  void _initializeSeasons() {
    _seasons['season_001'] = Season(
      id: 'season_001',
      name: 'Spring Arena Season',
      number: 1,
      startTime: DateTime.now().millisecondsSinceEpoch,
      endTime: DateTime.now().millisecondsSinceEpoch + (86400000 * 90),
      rewardPool: 50000,
      status: 'active',
    );

    _seasons['season_002'] = Season(
      id: 'season_002',
      name: 'Summer Arena Season',
      number: 2,
      startTime: DateTime.now().millisecondsSinceEpoch + (86400000 * 90),
      endTime: DateTime.now().millisecondsSinceEpoch + (86400000 * 180),
      rewardPool: 60000,
      status: 'upcoming',
    );
  }

  /// プレイヤーランキングを初期化
  void _initializePlayerRankings() {
    const players = [
      'player_001',
      'player_002',
      'player_003',
      'player_004',
      'player_005',
    ];

    for (final playerId in players) {
      _playerRankings[playerId] = PlayerRanking(
        playerId: playerId,
        rating: 1500 + (players.indexOf(playerId) * 100),
        tier: _calculateTier(1500 + (players.indexOf(playerId) * 100)),
        wins: 0,
        losses: 0,
        streak: 0,
        totalMatches: 0,
      );
    }
  }

  /// ティアを計算
  String _calculateTier(int rating) {
    if (rating >= 2400) return 'Legendary';
    if (rating >= 2000) return 'Diamond';
    if (rating >= 1600) return 'Platinum';
    if (rating >= 1200) return 'Gold';
    return 'Silver';
  }

  /// トーナメントを作成
  bool createTournament(
    String tournamentId,
    String name,
    String seasonId,
    int maxPlayers,
    int entryFee,
  ) {
    if (_seasons[seasonId] == null) return false;

    final tournament = Tournament(
      id: tournamentId,
      name: name,
      seasonId: seasonId,
      maxPlayers: maxPlayers,
      entryFee: entryFee,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      status: 'registration',
      participants: [],
      rewardPool: 0,
      bracket: null,
    );

    _tournaments[tournamentId] = tournament;
    _tournamentBrackets[tournamentId] = TournamentBracket(
      id: 'bracket_$tournamentId',
      tournamentId: tournamentId,
      rounds: [],
      status: 'pending',
    );

    return true;
  }

  /// トーナメントに参加
  bool registerForTournament(String tournamentId, String playerId) {
    final tournament = _tournaments[tournamentId];
    if (tournament == null) return false;
    if (tournament.participants.length >= tournament.maxPlayers) return false;
    if (tournament.participants.contains(playerId)) return false;

    tournament.participants.add(playerId);
    tournament.rewardPool += tournament.entryFee;

    // プレイヤー統計を初期化
    _playerMatchHistory.putIfAbsent(playerId, () => []);

    return true;
  }

  /// トーナメントを開始
  bool startTournament(String tournamentId) {
    final tournament = _tournaments[tournamentId];
    if (tournament == null) return false;
    if (tournament.status != 'registration') return false;

    tournament.status = 'active';

    // 括弧を生成
    _generateBracket(tournamentId);

    return true;
  }

  /// 括弧を生成
  void _generateBracket(String tournamentId) {
    final tournament = _tournaments[tournamentId]!;
    final bracket = _tournamentBrackets[tournamentId]!;

    // ラウンド1を作成（16人用）
    bracket.rounds.clear();

    // シード処理
    final seededPlayers = tournament.participants
        .asMap()
        .entries
        .toList()
        .cast<MapEntry<int, String>>();
    seededPlayers.sort((a, b) {
      final ratingA = _playerRankings[a.value]?.rating ?? 1500;
      final ratingB = _playerRankings[b.value]?.rating ?? 1500;
      return ratingB.compareTo(ratingA);
    });

    // ラウンド1マッチ
    final round1Matches = <TournamentMatch>[];
    for (int i = 0; i < seededPlayers.length; i += 2) {
      if (i + 1 < seededPlayers.length) {
        round1Matches.add(
          TournamentMatch(
            id: 'match_${tournamentId}_${round1Matches.length}',
            player1: seededPlayers[i].value,
            player2: seededPlayers[i + 1].value,
            round: 1,
            status: 'pending',
            winner: null,
          ),
        );
      }
    }

    bracket.rounds.add(TournamentRound(
      roundNumber: 1,
      matches: round1Matches,
      status: 'active',
    ));

    bracket.status = 'active';
  }

  /// トーナメントマッチを完了
  bool completeTournamentMatch(
    String tournamentId,
    int matchIndex,
    String winnerId,
  ) {
    final bracket = _tournamentBrackets[tournamentId];
    if (bracket == null || bracket.rounds.isEmpty) return false;

    final round = bracket.rounds.first;
    if (matchIndex >= round.matches.length) return false;

    final match = round.matches[matchIndex];
    match.status = 'completed';
    match.winner = winnerId;

    // プレイヤー統計を更新
    final loser = match.player1 == winnerId ? match.player2 : match.player1;
    _recordMatchResult(winnerId, loser, true);

    // ラウンドが完了したかチェック
    if (round.matches.every((m) => m.status == 'completed')) {
      _advanceTournamentRound(tournamentId);
    }

    return true;
  }

  /// トーナメントラウンドを進める
  void _advanceTournamentRound(String tournamentId) {
    final bracket = _tournamentBrackets[tournamentId]!;
    final currentRound = bracket.rounds.last;
    final winners =
        currentRound.matches.map((m) => m.winner).whereType<String>().toList();

    if (winners.length == 1) {
      // トーナメント完了
      _completeTournament(tournamentId, winners.first);
      return;
    }

    // 次のラウンドを作成
    final nextRoundMatches = <TournamentMatch>[];
    for (int i = 0; i < winners.length; i += 2) {
      if (i + 1 < winners.length) {
        nextRoundMatches.add(
          TournamentMatch(
            id: 'match_${tournamentId}_${nextRoundMatches.length}',
            player1: winners[i],
            player2: winners[i + 1],
            round: currentRound.roundNumber + 1,
            status: 'pending',
            winner: null,
          ),
        );
      }
    }

    bracket.rounds.add(TournamentRound(
      roundNumber: currentRound.roundNumber + 1,
      matches: nextRoundMatches,
      status: 'active',
    ));
  }

  /// トーナメントを完了
  void _completeTournament(String tournamentId, String winnerId) {
    final tournament = _tournaments[tournamentId]!;
    tournament.status = 'completed';

    final reward = (tournament.rewardPool * 0.5).toInt(); // 50% to winner
    _playerRankings[winnerId]?.rating += 100;
    _playerRankings[winnerId]?.tier =
        _calculateTier(_playerRankings[winnerId]?.rating ?? 1500);

    // トーナメント統計を記録
    for (final playerId in tournament.participants) {
      _seasonStatistics.putIfAbsent(playerId, () => {});
      _seasonStatistics[playerId]![tournament.seasonId] = SeasonStatistics(
        playerId: playerId,
        seasonId: tournament.seasonId,
        tournamentsParticipated: (_seasonStatistics[playerId]![tournament.seasonId]
                ?.tournamentsParticipated ??
            0) +
        1,
        tournamentsWon:
            playerId == winnerId ? 1 : 0,
        totalWins: _playerRankings[playerId]?.wins ?? 0,
        totalLosses: _playerRankings[playerId]?.losses ?? 0,
        tournamentRewards: playerId == winnerId ? reward : 0,
      );
    }
  }

  /// アリーナマッチをアレンジ
  bool arrangeArenaMatch(
    String matchId,
    String player1Id,
    String player2Id,
  ) {
    final match = ArenaMatch(
      id: matchId,
      player1Id: player1Id,
      player2Id: player2Id,
      player1Rating: _playerRankings[player1Id]?.rating ?? 1500,
      player2Rating: _playerRankings[player2Id]?.rating ?? 1500,
      startTime: DateTime.now().millisecondsSinceEpoch,
      status: 'active',
      winner: null,
      player1Damage: 0,
      player2Damage: 0,
      durationSeconds: 0,
    );

    _arenaMatches[matchId] = match;
    return true;
  }

  /// アリーナマッチを完了
  bool completeArenaMatch(
    String matchId,
    String winnerId,
    int player1Damage,
    int player2Damage,
  ) {
    final match = _arenaMatches[matchId];
    if (match == null) return false;

    match.status = 'completed';
    match.winner = winnerId;
    match.player1Damage = player1Damage;
    match.player2Damage = player2Damage;
    match.durationSeconds =
        (DateTime.now().millisecondsSinceEpoch - match.startTime) ~/ 1000;

    final loser = match.player1Id == winnerId ? match.player2Id : match.player1Id;
    _recordMatchResult(winnerId, loser, false);

    // レーティング変更を計算
    final ratingChange = _calculateRatingChange(match, winnerId);
    _playerRankings[winnerId]?.rating += ratingChange;
    _playerRankings[loser]?.rating -= ratingChange;

    // ティアを更新
    _playerRankings[winnerId]?.tier =
        _calculateTier(_playerRankings[winnerId]?.rating ?? 1500);
    _playerRankings[loser]?.tier =
        _calculateTier(_playerRankings[loser]?.rating ?? 1500);

    return true;
  }

  /// マッチ結果を記録
  void _recordMatchResult(String winnerId, String loserId, bool isTournament) {
    _playerMatchHistory.putIfAbsent(winnerId, () => []);
    _playerMatchHistory.putIfAbsent(loserId, () => []);

    _playerMatchHistory[winnerId]!.add(
      MatchResult(
        matchId: 'result_${DateTime.now().millisecondsSinceEpoch}',
        playerId: winnerId,
        opponent: loserId,
        result: 'win',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isTournament: isTournament,
      ),
    );

    _playerMatchHistory[loserId]!.add(
      MatchResult(
        matchId: 'result_${DateTime.now().millisecondsSinceEpoch}',
        playerId: loserId,
        opponent: winnerId,
        result: 'loss',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isTournament: isTournament,
      ),
    );

    // プレイヤーランキング統計を更新
    _playerRankings[winnerId]!.wins++;
    _playerRankings[winnerId]!.totalMatches++;
    _playerRankings[winnerId]!.streak++;

    _playerRankings[loserId]!.losses++;
    _playerRankings[loserId]!.totalMatches++;
    _playerRankings[loserId]!.streak = 0;
  }

  /// レーティング変更を計算
  int _calculateRatingChange(ArenaMatch match, String winnerId) {
    final winnerRating = match.player1Id == winnerId
        ? match.player1Rating
        : match.player2Rating;
    final loserRating = match.player1Id == winnerId
        ? match.player2Rating
        : match.player1Rating;

    final expectedWinRate = 1 / (1 + pow(10, (loserRating - winnerRating) / 400));
    final kFactor = 32;
    final ratingChange = (kFactor * (1 - expectedWinRate)).toInt();

    return ratingChange.clamp(1, 32);
  }

  double pow(num x, num y) {
    return x ^ y;
  }

  /// リーダーボードを取得
  List<ArenaLeaderboard> getLeaderboard(String seasonId) {
    if (_leaderboards[seasonId] != null) {
      return _leaderboards[seasonId]!;
    }

    final leaderboard = _playerRankings.values
        .map((r) => ArenaLeaderboard(
              playerId: r.playerId,
              rating: r.rating,
              tier: r.tier,
              rank: 0,
              wins: r.wins,
              losses: r.losses,
              winRate: r.totalMatches > 0
                  ? ((r.wins / r.totalMatches) * 100).toInt()
                  : 0,
            ))
        .toList();

    leaderboard.sort((a, b) => b.rating.compareTo(a.rating));

    for (int i = 0; i < leaderboard.length; i++) {
      leaderboard[i].rank = i + 1;
    }

    _leaderboards[seasonId] = leaderboard;
    return leaderboard;
  }

  /// プレイヤーランキングを取得
  PlayerRanking? getPlayerRanking(String playerId) {
    return _playerRankings[playerId];
  }

  /// アクティブなトーナメントを取得
  List<Tournament> getActiveTournaments() {
    return _tournaments.values
        .where((t) => t.status == 'active' || t.status == 'registration')
        .toList();
  }

  /// プレイヤーマッチ履歴を取得
  List<MatchResult> getPlayerMatchHistory(String playerId) {
    return _playerMatchHistory[playerId] ?? [];
  }

  /// 季節を取得
  Season? getSeason(String seasonId) {
    return _seasons[seasonId];
  }

  /// アクティブな季節を取得
  Season? getActiveSeason() {
    return _seasons.values.firstWhere(
      (s) => s.status == 'active',
      orElse: () => _seasons.values.first,
    );
  }

  /// トーナメント統計レポートを取得
  String getTournamentReport(String tournamentId) {
    final tournament = _tournaments[tournamentId];
    if (tournament == null) return 'Tournament not found';

    final bracket = _tournamentBrackets[tournamentId];
    final rounds = bracket?.rounds.length ?? 0;

    return '''
Tournament: ${tournament.name}
Status: ${tournament.status}

Participants: ${tournament.participants.length}/${tournament.maxPlayers}
Entry Fee: ${tournament.entryFee}G
Reward Pool: ${tournament.rewardPool}G

Rounds: $rounds
${bracket?.status ?? 'pending'}
''';
  }

  /// プレイヤーアリーナレポートを取得
  String getPlayerArenaReport(String playerId) {
    final ranking = _playerRankings[playerId];
    if (ranking == null) return 'Player not found';

    final winRate =
        ranking.totalMatches > 0 ? ((ranking.wins / ranking.totalMatches) * 100) : 0;

    return '''
Arena Report: $playerId

Tier: ${ranking.tier}
Rating: ${ranking.rating}

Statistics:
  Wins: ${ranking.wins}
  Losses: ${ranking.losses}
  Win Rate: ${winRate.toStringAsFixed(1)}%
  Streak: ${ranking.streak}
  Total Matches: ${ranking.totalMatches}
''';
  }
}

/// トーナメント
class Tournament {
  final String id;
  final String name;
  final String seasonId;
  final int maxPlayers;
  final int entryFee;
  final int createdAt;
  String status; // registration, active, completed
  List<String> participants;
  int rewardPool;
  TournamentBracket? bracket;

  Tournament({
    required this.id,
    required this.name,
    required this.seasonId,
    required this.maxPlayers,
    required this.entryFee,
    required this.createdAt,
    required this.status,
    required this.participants,
    required this.rewardPool,
    required this.bracket,
  });
}

/// トーナメント括弧
class TournamentBracket {
  final String id;
  final String tournamentId;
  List<TournamentRound> rounds;
  String status; // pending, active, completed

  TournamentBracket({
    required this.id,
    required this.tournamentId,
    required this.rounds,
    required this.status,
  });
}

/// トーナメントラウンド
class TournamentRound {
  final int roundNumber;
  final List<TournamentMatch> matches;
  final String status;

  TournamentRound({
    required this.roundNumber,
    required this.matches,
    required this.status,
  });
}

/// トーナメントマッチ
class TournamentMatch {
  final String id;
  final String player1;
  final String player2;
  final int round;
  String status; // pending, active, completed
  String? winner;

  TournamentMatch({
    required this.id,
    required this.player1,
    required this.player2,
    required this.round,
    required this.status,
    required this.winner,
  });
}

/// アリーナマッチ
class ArenaMatch {
  final String id;
  final String player1Id;
  final String player2Id;
  final int player1Rating;
  final int player2Rating;
  final int startTime;
  String status; // active, completed
  String? winner;
  int player1Damage;
  int player2Damage;
  int durationSeconds;

  ArenaMatch({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.player1Rating,
    required this.player2Rating,
    required this.startTime,
    required this.status,
    required this.winner,
    required this.player1Damage,
    required this.player2Damage,
    required this.durationSeconds,
  });

  /// DPS（秒あたりダメージ）を計算
  int calculateDPS(String playerId) {
    if (durationSeconds == 0) return 0;
    final damage = playerId == player1Id ? player1Damage : player2Damage;
    return damage ~/ durationSeconds;
  }
}

/// プレイヤーランキング
class PlayerRanking {
  final String playerId;
  int rating;
  String tier;
  int wins;
  int losses;
  int streak;
  int totalMatches;

  PlayerRanking({
    required this.playerId,
    required this.rating,
    required this.tier,
    required this.wins,
    required this.losses,
    required this.streak,
    required this.totalMatches,
  });

  /// 勝率を取得（0-100）
  int getWinRate() {
    if (totalMatches == 0) return 0;
    return ((wins / totalMatches) * 100).toInt();
  }
}

/// マッチ結果
class MatchResult {
  final String matchId;
  final String playerId;
  final String opponent;
  final String result; // win, loss
  final int timestamp;
  final bool isTournament;

  MatchResult({
    required this.matchId,
    required this.playerId,
    required this.opponent,
    required this.result,
    required this.timestamp,
    required this.isTournament,
  });
}

/// 季節
class Season {
  final String id;
  final String name;
  final int number;
  final int startTime;
  final int endTime;
  final int rewardPool;
  String status; // active, upcoming, ended

  Season({
    required this.id,
    required this.name,
    required this.number,
    required this.startTime,
    required this.endTime,
    required this.rewardPool,
    required this.status,
  });

  /// シーズン時間までの時間を取得（日単位）
  int getDaysRemaining() {
    return ((endTime - DateTime.now().millisecondsSinceEpoch) ~/ 86400000)
        .clamp(0, 90);
  }
}

/// シーズン統計
class SeasonStatistics {
  final String playerId;
  final String seasonId;
  int tournamentsParticipated;
  int tournamentsWon;
  int totalWins;
  int totalLosses;
  int tournamentRewards;

  SeasonStatistics({
    required this.playerId,
    required this.seasonId,
    required this.tournamentsParticipated,
    required this.tournamentsWon,
    required this.totalWins,
    required this.totalLosses,
    required this.tournamentRewards,
  });
}

/// アリーナリーダーボード
class ArenaLeaderboard {
  final String playerId;
  final int rating;
  final String tier;
  int rank;
  final int wins;
  final int losses;
  final int winRate;

  ArenaLeaderboard({
    required this.playerId,
    required this.rating,
    required this.tier,
    required this.rank,
    required this.wins,
    required this.losses,
    required this.winRate,
  });
}
