/// Leaderboard models for ranking and competition
/// Phase 15 Part 1: Leaderboards System

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String userAvatar;
  final int rank;
  final int score;
  final int level;
  final int streakCount;
  final DateTime lastActivityAt;
  final int lessonsCompleted;
  final int averageAccuracy; // percentage 0-100

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rank,
    required this.score,
    required this.level,
    required this.streakCount,
    required this.lastActivityAt,
    required this.lessonsCompleted,
    required this.averageAccuracy,
  });

  LeaderboardEntry copyWith({
    String? userId,
    String? userName,
    String? userAvatar,
    int? rank,
    int? score,
    int? level,
    int? streakCount,
    DateTime? lastActivityAt,
    int? lessonsCompleted,
    int? averageAccuracy,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      level: level ?? this.level,
      streakCount: streakCount ?? this.streakCount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'rank': rank,
    'score': score,
    'level': level,
    'streakCount': streakCount,
    'lastActivityAt': lastActivityAt.toIso8601String(),
    'lessonsCompleted': lessonsCompleted,
    'averageAccuracy': averageAccuracy,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      rank: json['rank'] as int,
      score: json['score'] as int,
      level: json['level'] as int,
      streakCount: json['streakCount'] as int,
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      lessonsCompleted: json['lessonsCompleted'] as int,
      averageAccuracy: json['averageAccuracy'] as int,
    );
  }
}

enum LeaderboardType {
  global,
  level,
  weekly,
  friends,
}
