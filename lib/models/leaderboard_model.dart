import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_model.g.dart';

enum LeaderboardType {
  global,
  weekly,
  monthly,
  skillBased, // Leaderboards for specific skills (listening, speaking, etc.)
  friends,
  grade, // School grade based
}

enum RankingMetric {
  totalScore,
  level,
  streakDays,
  lessonsCompleted,
  challengesWon,
  xpEarned,
  badgesEarned,
}

@JsonSerializable()
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String userAvatar;
  final int rank;
  final int score;
  final int level;
  final int xpTotal;
  final int streakDays;
  final int lessonsCompleted;
  final int challengesWon;
  final int badgesEarned;
  final DateTime updatedAt;
  final bool isFriend;
  final bool isCurrentUser;
  final String? skillFocus; // For skill-based leaderboards
  final Map<String, int>? skillScores; // skill -> score mapping

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rank,
    required this.score,
    required this.level,
    required this.xpTotal,
    required this.streakDays,
    required this.lessonsCompleted,
    required this.challengesWon,
    required this.badgesEarned,
    required this.updatedAt,
    required this.isFriend,
    required this.isCurrentUser,
    this.skillFocus,
    this.skillScores,
  });

  String get rankDisplay {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  String get scoreLabel {
    if (score >= 100000) return '${(score / 1000).toStringAsFixed(0)}K';
    return score.toString();
  }

  LeaderboardEntry copyWith({
    String? userId,
    String? userName,
    String? userAvatar,
    int? rank,
    int? score,
    int? level,
    int? xpTotal,
    int? streakDays,
    int? lessonsCompleted,
    int? challengesWon,
    int? badgesEarned,
    DateTime? updatedAt,
    bool? isFriend,
    bool? isCurrentUser,
    String? skillFocus,
    Map<String, int>? skillScores,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      level: level ?? this.level,
      xpTotal: xpTotal ?? this.xpTotal,
      streakDays: streakDays ?? this.streakDays,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      challengesWon: challengesWon ?? this.challengesWon,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      updatedAt: updatedAt ?? this.updatedAt,
      isFriend: isFriend ?? this.isFriend,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      skillFocus: skillFocus ?? this.skillFocus,
      skillScores: skillScores ?? this.skillScores,
    );
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
}

@JsonSerializable()
class Leaderboard {
  final String id;
  final LeaderboardType type;
  final RankingMetric metric;
  final List<LeaderboardEntry> entries;
  final DateTime generatedAt;
  final DateTime validUntil;
  final int totalPlayers;

  Leaderboard({
    required this.id,
    required this.type,
    required this.metric,
    required this.entries,
    required this.generatedAt,
    required this.validUntil,
    required this.totalPlayers,
  });

  String get typeLabel {
    switch (type) {
      case LeaderboardType.global:
        return 'グローバル';
      case LeaderboardType.weekly:
        return 'ウィークリー';
      case LeaderboardType.monthly:
        return 'マンスリー';
      case LeaderboardType.skillBased:
        return 'スキル別';
      case LeaderboardType.friends:
        return 'フレンド';
      case LeaderboardType.grade:
        return '学年別';
    }
  }

  String get metricLabel {
    switch (metric) {
      case RankingMetric.totalScore:
        return 'トータルスコア';
      case RankingMetric.level:
        return 'レベル';
      case RankingMetric.streakDays:
        return 'ストリーク';
      case RankingMetric.lessonsCompleted:
        return 'ステージ完了';
      case RankingMetric.challengesWon:
        return 'チャレンジ勝利';
      case RankingMetric.xpEarned:
        return 'XP獲得';
      case RankingMetric.badgesEarned:
        return 'バッジ獲得';
    }
  }

  LeaderboardEntry? findCurrentUserEntry(String userId) {
    try {
      return entries.firstWhere((e) => e.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Leaderboard copyWith({
    String? id,
    LeaderboardType? type,
    RankingMetric? metric,
    List<LeaderboardEntry>? entries,
    DateTime? generatedAt,
    DateTime? validUntil,
    int? totalPlayers,
  }) {
    return Leaderboard(
      id: id ?? this.id,
      type: type ?? this.type,
      metric: metric ?? this.metric,
      entries: entries ?? this.entries,
      generatedAt: generatedAt ?? this.generatedAt,
      validUntil: validUntil ?? this.validUntil,
      totalPlayers: totalPlayers ?? this.totalPlayers,
    );
  }

  factory Leaderboard.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardToJson(this);
}

@JsonSerializable()
class PlayerRankStats {
  final String userId;
  final String userName;
  final String userAvatar;
  final int globalRank;
  final int weeklyRank;
  final int monthlyRank;
  final int globalPercentile; // 0-100 (100 = top 1%)
  final int weeklyPercentile;
  final Map<String, int> skillRanks; // skill -> rank
  final int totalScore;
  final int previousWeekRank;
  final int previousMonthRank;
  final bool isRankingUp; // Improved rank from last week
  final bool isRankingDown; // Declined rank from last week

  PlayerRankStats({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.globalRank,
    required this.weeklyRank,
    required this.monthlyRank,
    required this.globalPercentile,
    required this.weeklyPercentile,
    required this.skillRanks,
    required this.totalScore,
    required this.previousWeekRank,
    required this.previousMonthRank,
    required this.isRankingUp,
    required this.isRankingDown,
  });

  String get globalRankDisplay {
    if (globalRank == 1) return '🥇 1位';
    if (globalRank == 2) return '🥈 2位';
    if (globalRank == 3) return '🥉 3位';
    return '#$globalRank';
  }

  String get rankingTrend {
    if (isRankingUp) return '📈 上昇中';
    if (isRankingDown) return '📉 下降中';
    return '➡️ 変わらず';
  }

  factory PlayerRankStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerRankStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerRankStatsToJson(this);
}

@JsonSerializable()
class RankingComparison {
  final String userId1;
  final String userId2;
  final String userName1;
  final String userName2;
  final String userAvatar1;
  final String userAvatar2;
  final int rank1;
  final int rank2;
  final int score1;
  final int score2;
  final int scoreDifference; // score1 - score2
  final bool user1IsAhead;
  final Map<String, int> skillComparison; // skill -> score difference

  RankingComparison({
    required this.userId1,
    required this.userId2,
    required this.userName1,
    required this.userName2,
    required this.userAvatar1,
    required this.userAvatar2,
    required this.rank1,
    required this.rank2,
    required this.score1,
    required this.score2,
    required this.scoreDifference,
    required this.user1IsAhead,
    required this.skillComparison,
  });

  String get scoreDifferenceLabel {
    if (scoreDifference == 0) return 'タイ';
    final abs = scoreDifference.abs();
    final leader = scoreDifference > 0 ? userName1 : userName2;
    return '$leader が $abs ポイント先行';
  }

  factory RankingComparison.fromJson(Map<String, dynamic> json) =>
      _$RankingComparisonFromJson(json);
  Map<String, dynamic> toJson() => _$RankingComparisonToJson(this);
}

@JsonSerializable()
class LeaderboardStats {
  final String id;
  final int totalLeaderboards;
  final int totalPlayers;
  final int newPlayersThisWeek;
  final int avgPlayersPerLeaderboard;
  final Map<String, int> topSkillsRanked; // skill -> number of leaderboards
  final DateTime lastUpdated;

  LeaderboardStats({
    required this.id,
    required this.totalLeaderboards,
    required this.totalPlayers,
    required this.newPlayersThisWeek,
    required this.avgPlayersPerLeaderboard,
    required this.topSkillsRanked,
    required this.lastUpdated,
  });

  factory LeaderboardStats.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardStatsToJson(this);
}
