class UserProfile {
  final String id;
  final String name;
  final int grade; // 1-6
  final String avatar; // emoji
  final int coinsEarned;
  final int totalStudyMinutes;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final Map<String, int> stageProgress; // stageId -> highestScore
  final Set<String> completedMissions; // TPR mission IDs
  final Set<String> unlockedBadges;

  const UserProfile({
    required this.id,
    required this.name,
    required this.grade,
    required this.avatar,
    this.coinsEarned = 0,
    this.totalStudyMinutes = 0,
    this.longestStreak = 0,
    required this.createdAt,
    required this.lastAccessedAt,
    this.stageProgress = const {},
    this.completedMissions = const {},
    this.unlockedBadges = const {},
  });

  UserProfile copyWith({
    String? id,
    String? name,
    int? grade,
    String? avatar,
    int? coinsEarned,
    int? totalStudyMinutes,
    int? longestStreak,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    Map<String, int>? stageProgress,
    Set<String>? completedMissions,
    Set<String>? unlockedBadges,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      avatar: avatar ?? this.avatar,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      stageProgress: stageProgress ?? this.stageProgress,
      completedMissions: completedMissions ?? this.completedMissions,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'grade': grade,
    'avatar': avatar,
    'coinsEarned': coinsEarned,
    'totalStudyMinutes': totalStudyMinutes,
    'longestStreak': longestStreak,
    'createdAt': createdAt.toIso8601String(),
    'lastAccessedAt': lastAccessedAt.toIso8601String(),
    'stageProgress': stageProgress,
    'completedMissions': completedMissions.toList(),
    'unlockedBadges': unlockedBadges.toList(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      grade: json['grade'] as int,
      avatar: json['avatar'] as String,
      coinsEarned: json['coinsEarned'] as int? ?? 0,
      totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
      stageProgress: Map<String, int>.from(json['stageProgress'] as Map? ?? {}),
      completedMissions: Set.from(json['completedMissions'] as List? ?? []),
      unlockedBadges: Set.from(json['unlockedBadges'] as List? ?? []),
    );
  }
}
