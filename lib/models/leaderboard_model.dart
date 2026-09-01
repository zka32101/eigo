/// ランキングエントリー
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String avatar;
  final int score;
  final int level;
  final int totalStudyMinutes;
  final int longestStreak;
  final DateTime lastActiveAt;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.score,
    required this.level,
    required this.totalStudyMinutes,
    required this.longestStreak,
    required this.lastActiveAt,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    int? rank,
    String? userId,
    String? name,
    String? avatar,
    int? score,
    int? level,
    int? totalStudyMinutes,
    int? longestStreak,
    DateTime? lastActiveAt,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      score: score ?? this.score,
      level: level ?? this.level,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'userId': userId,
        'name': name,
        'avatar': avatar,
        'score': score,
        'level': level,
        'totalStudyMinutes': totalStudyMinutes,
        'longestStreak': longestStreak,
        'lastActiveAt': lastActiveAt.toIso8601String(),
        'isCurrentUser': isCurrentUser,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: json['rank'] as int,
        userId: json['userId'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String,
        score: json['score'] as int,
        level: json['level'] as int,
        totalStudyMinutes: json['totalStudyMinutes'] as int,
        longestStreak: json['longestStreak'] as int,
        lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
        isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      );
}

/// ランキングタイプ
enum LeaderboardType {
  global, // グローバルランキング
  friends, // フレンドランキング
  weekly, // 週間ランキング
  stage, // ステージ別ランキング
}

/// ランキングデータ
class LeaderboardData {
  final LeaderboardType type;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final DateTime updatedAt;

  const LeaderboardData({
    required this.type,
    required this.entries,
    this.currentUserEntry,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'currentUserEntry': currentUserEntry?.toJson(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LeaderboardData.fromJson(Map<String, dynamic> json) =>
      LeaderboardData(
        type: LeaderboardType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => LeaderboardType.global,
        ),
        entries: (json['entries'] as List<dynamic>)
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentUserEntry: json['currentUserEntry'] != null
            ? LeaderboardEntry.fromJson(
                json['currentUserEntry'] as Map<String, dynamic>)
            : null,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// ユーザー比較データ
class UserComparison {
  final String userId1;
  final String name1;
  final String avatar1;
  final int level1;
  final int score1;
  final int studyMinutes1;

  final String userId2;
  final String name2;
  final String avatar2;
  final int level2;
  final int score2;
  final int studyMinutes2;

  const UserComparison({
    required this.userId1,
    required this.name1,
    required this.avatar1,
    required this.level1,
    required this.score1,
    required this.studyMinutes1,
    required this.userId2,
    required this.name2,
    required this.avatar2,
    required this.level2,
    required this.score2,
    required this.studyMinutes2,
  });

  // スコア差分（userId1 - userId2）
  int get scoreDifference => score1 - score2;

  // レベル差分
  int get levelDifference => level1 - level2;

  // 勉強時間差分（分）
  int get studyMinutesDifference => studyMinutes1 - studyMinutes2;

  Map<String, dynamic> toJson() => {
        'userId1': userId1,
        'name1': name1,
        'avatar1': avatar1,
        'level1': level1,
        'score1': score1,
        'studyMinutes1': studyMinutes1,
        'userId2': userId2,
        'name2': name2,
        'avatar2': avatar2,
        'level2': level2,
        'score2': score2,
        'studyMinutes2': studyMinutes2,
      };

  factory UserComparison.fromJson(Map<String, dynamic> json) =>
      UserComparison(
        userId1: json['userId1'] as String,
        name1: json['name1'] as String,
        avatar1: json['avatar1'] as String,
        level1: json['level1'] as int,
        score1: json['score1'] as int,
        studyMinutes1: json['studyMinutes1'] as int,
        userId2: json['userId2'] as String,
        name2: json['name2'] as String,
        avatar2: json['avatar2'] as String,
        level2: json['level2'] as int,
        score2: json['score2'] as int,
        studyMinutes2: json['studyMinutes2'] as int,
      );
}
