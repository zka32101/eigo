import 'package:json_annotation/json_annotation.dart';

part 'social_model.g.dart';

enum ActivityType {
  levelUp,
  stageCompleted,
  challengeWon,
  achievementUnlocked,
  streakMilestone,
  purchaseMade,
  friendAdded,
  badgeEarned,
  courseCompleted,
  scoreRecord,
}

enum FriendStatus {
  pending,
  accepted,
  blocked,
}

@JsonSerializable()
class UserProfile {
  final String id;
  final String name;
  final String avatar;
  final String? bio;
  final int level;
  final int totalXp;
  final int totalCoins;
  final int streakDays;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final int totalLessonsCompleted;
  final int totalChallengesWon;
  final int totalBadgesEarned;
  final int friendCount;
  final bool isOnline;
  final String? location;
  final String? favoriteSkill; // 'listening', 'speaking', 'reading', 'writing'
  final DateTime? birthdayDate;
  final List<String> badges; // Badge IDs
  final Map<String, int> skillScores; // skill -> score

  UserProfile({
    required this.id,
    required this.name,
    required this.avatar,
    this.bio,
    required this.level,
    required this.totalXp,
    required this.totalCoins,
    required this.streakDays,
    required this.createdAt,
    required this.lastActiveAt,
    required this.totalLessonsCompleted,
    required this.totalChallengesWon,
    required this.totalBadgesEarned,
    required this.friendCount,
    required this.isOnline,
    this.location,
    this.favoriteSkill,
    this.birthdayDate,
    required this.badges,
    required this.skillScores,
  });

  int get age {
    if (birthdayDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthdayDate!.year;
    if (now.month < birthdayDate!.month ||
        (now.month == birthdayDate!.month && now.day < birthdayDate!.day)) {
      age--;
    }
    return age;
  }

  String get joinedDaysAgo {
    final days = DateTime.now().difference(createdAt).inDays;
    return '$days日前に参加';
  }

  double get averageSkillScore {
    if (skillScores.isEmpty) return 0;
    final sum = skillScores.values.fold(0, (a, b) => a + b);
    return sum / skillScores.length;
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatar,
    String? bio,
    int? level,
    int? totalXp,
    int? totalCoins,
    int? streakDays,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? totalLessonsCompleted,
    int? totalChallengesWon,
    int? totalBadgesEarned,
    int? friendCount,
    bool? isOnline,
    String? location,
    String? favoriteSkill,
    DateTime? birthdayDate,
    List<String>? badges,
    Map<String, int>? skillScores,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      totalCoins: totalCoins ?? this.totalCoins,
      streakDays: streakDays ?? this.streakDays,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalLessonsCompleted:
          totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalChallengesWon: totalChallengesWon ?? this.totalChallengesWon,
      totalBadgesEarned: totalBadgesEarned ?? this.totalBadgesEarned,
      friendCount: friendCount ?? this.friendCount,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      favoriteSkill: favoriteSkill ?? this.favoriteSkill,
      birthdayDate: birthdayDate ?? this.birthdayDate,
      badges: badges ?? this.badges,
      skillScores: skillScores ?? this.skillScores,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class Friend {
  final String id;
  final String userId;
  final String friendId;
  final FriendStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final UserProfile? friendProfile;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.friendProfile,
  });

  bool get isPending => status == FriendStatus.pending;
  bool get isAccepted => status == FriendStatus.accepted;
  bool get isBlocked => status == FriendStatus.blocked;

  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    FriendStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    UserProfile? friendProfile,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      friendProfile: friendProfile ?? this.friendProfile,
    );
  }

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
  Map<String, dynamic> toJson() => _$FriendToJson(this);
}

@JsonSerializable()
class Activity {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? icon;
  final String? imageUrl;
  final Map<String, dynamic>? metadata; // Additional data
  final bool isShared; // Visible to friends
  final int? xpReward;
  final int? coinReward;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.icon,
    this.imageUrl,
    this.metadata,
    required this.isShared,
    this.xpReward,
    this.coinReward,
  });

  String get typeLabel {
    switch (type) {
      case ActivityType.levelUp:
        return 'レベルアップ';
      case ActivityType.stageCompleted:
        return 'ステージ完了';
      case ActivityType.challengeWon:
        return 'チャレンジ勝利';
      case ActivityType.achievementUnlocked:
        return 'アチーブメント解除';
      case ActivityType.streakMilestone:
        return 'ストリーク達成';
      case ActivityType.purchaseMade:
        return '購入完了';
      case ActivityType.friendAdded:
        return 'フレンド追加';
      case ActivityType.badgeEarned:
        return 'バッジ獲得';
      case ActivityType.courseCompleted:
        return 'コース完了';
      case ActivityType.scoreRecord:
        return 'スコア記録';
    }
  }

  String get typeEmoji {
    switch (type) {
      case ActivityType.levelUp:
        return '⭐';
      case ActivityType.stageCompleted:
        return '✅';
      case ActivityType.challengeWon:
        return '🏆';
      case ActivityType.achievementUnlocked:
        return '🎉';
      case ActivityType.streakMilestone:
        return '🔥';
      case ActivityType.purchaseMade:
        return '🛍️';
      case ActivityType.friendAdded:
        return '👥';
      case ActivityType.badgeEarned:
        return '🏅';
      case ActivityType.courseCompleted:
        return '📚';
      case ActivityType.scoreRecord:
        return '📈';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${createdAt.month}月${createdAt.day}日';
    }
  }

  Activity copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    String? icon,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    bool? isShared,
    int? xpReward,
    int? coinReward,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      isShared: isShared ?? this.isShared,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

@JsonSerializable()
class SocialStats {
  final String userId;
  final int totalFriends;
  final int pendingFriendRequests;
  final int sentFriendRequests;
  final int totalActivities;
  final int activitiesThisMonth;
  final int activitiesThisWeek;
  final int likes; // Activities liked
  final int comments; // Comments received
  final List<String> recentFriendIds;
  final DateTime lastActivityAt;

  SocialStats({
    required this.userId,
    required this.totalFriends,
    required this.pendingFriendRequests,
    required this.sentFriendRequests,
    required this.totalActivities,
    required this.activitiesThisMonth,
    required this.activitiesThisWeek,
    required this.likes,
    required this.comments,
    required this.recentFriendIds,
    required this.lastActivityAt,
  });

  factory SocialStats.fromJson(Map<String, dynamic> json) =>
      _$SocialStatsFromJson(json);
  Map<String, dynamic> toJson() => _$SocialStatsToJson(this);
}

@JsonSerializable()
class UserComparison {
  final String userId1;
  final String userId2;
  final UserProfile profile1;
  final UserProfile profile2;
  final int levelDifference;
  final int xpDifference;
  final String topSkillComparison;

  UserComparison({
    required this.userId1,
    required this.userId2,
    required this.profile1,
    required this.profile2,
    required this.levelDifference,
    required this.xpDifference,
    required this.topSkillComparison,
  });

  factory UserComparison.fromJson(Map<String, dynamic> json) =>
      _$UserComparisonFromJson(json);
  Map<String, dynamic> toJson() => _$UserComparisonToJson(this);
}
