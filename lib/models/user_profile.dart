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
  final Set<String> purchasedAvatars; // avatar IDs that have been purchased
  final bool showNameInRanking; // プライバシー設定：ランキングに名前を表示するか（デフォルト false）

  /// Phase 14: Enhanced Social Features
  final String? bio; // User bio/about section
  final String? title; // User title (based on achievements)
  final int level; // User level
  final int currentXP; // Current XP toward next level
  final int friendCount; // Number of friends
  final int followerCount; // Number of followers
  final int followingCount; // Number of users following
  final List<String> topAchievementIds; // Top 5 achievements to display
  final bool isOnline; // Online status
  final DateTime? lastSeenAt; // Last time user was active
  final bool allowFriendRequests; // Can others send friend requests
  final bool showOnlineStatus; // Show online/offline status to friends
  final bool allowMessages; // Can others message this user
  final bool showAchievements; // Show achievements publicly
  final bool showStatistics; // Show learning stats publicly

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
    this.purchasedAvatars = const {},
    this.showNameInRanking = false,
    this.bio,
    this.title,
    this.level = 1,
    this.currentXP = 0,
    this.friendCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.topAchievementIds = const [],
    this.isOnline = false,
    this.lastSeenAt,
    this.allowFriendRequests = true,
    this.showOnlineStatus = true,
    this.allowMessages = true,
    this.showAchievements = true,
    this.showStatistics = true,
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
    Set<String>? purchasedAvatars,
    bool? showNameInRanking,
    String? bio,
    String? title,
    int? level,
    int? currentXP,
    int? friendCount,
    int? followerCount,
    int? followingCount,
    List<String>? topAchievementIds,
    bool? isOnline,
    DateTime? lastSeenAt,
    bool? allowFriendRequests,
    bool? showOnlineStatus,
    bool? allowMessages,
    bool? showAchievements,
    bool? showStatistics,
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
      purchasedAvatars: purchasedAvatars ?? this.purchasedAvatars,
      showNameInRanking: showNameInRanking ?? this.showNameInRanking,
      bio: bio ?? this.bio,
      title: title ?? this.title,
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      friendCount: friendCount ?? this.friendCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      topAchievementIds: topAchievementIds ?? this.topAchievementIds,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowMessages: allowMessages ?? this.allowMessages,
      showAchievements: showAchievements ?? this.showAchievements,
      showStatistics: showStatistics ?? this.showStatistics,
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
    'purchasedAvatars': purchasedAvatars.toList(),
    'showNameInRanking': showNameInRanking,
    'bio': bio,
    'title': title,
    'level': level,
    'currentXP': currentXP,
    'friendCount': friendCount,
    'followerCount': followerCount,
    'followingCount': followingCount,
    'topAchievementIds': topAchievementIds,
    'isOnline': isOnline,
    'lastSeenAt': lastSeenAt?.toIso8601String(),
    'allowFriendRequests': allowFriendRequests,
    'showOnlineStatus': showOnlineStatus,
    'allowMessages': allowMessages,
    'showAchievements': showAchievements,
    'showStatistics': showStatistics,
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
      purchasedAvatars: Set.from(json['purchasedAvatars'] as List? ?? []),
      showNameInRanking: json['showNameInRanking'] as bool? ?? false,
      bio: json['bio'] as String?,
      title: json['title'] as String?,
      level: json['level'] as int? ?? 1,
      currentXP: json['currentXP'] as int? ?? 0,
      friendCount: json['friendCount'] as int? ?? 0,
      followerCount: json['followerCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      topAchievementIds: List<String>.from(json['topAchievementIds'] as List? ?? []),
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt'] as String) : null,
      allowFriendRequests: json['allowFriendRequests'] as bool? ?? true,
      showOnlineStatus: json['showOnlineStatus'] as bool? ?? true,
      allowMessages: json['allowMessages'] as bool? ?? true,
      showAchievements: json['showAchievements'] as bool? ?? true,
      showStatistics: json['showStatistics'] as bool? ?? true,
    );
  }
}
