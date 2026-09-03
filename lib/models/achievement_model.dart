import 'package:json_annotation/json_annotation.dart';

part 'achievement_model.g.dart';

enum AchievementType {
  learning, // Lesson and stage related
  social, // Friend and community related
  challenge, // Challenge and competition related
  skill, // Skill-specific achievements
  milestone, // Milestone achievements (100 lessons, etc)
  streak, // Streak-related achievements
  exploration, // Feature discovery achievements
  seasonal, // Limited-time seasonal achievements
  special, // Special event achievements
  ranking, // Ranking and leaderboard achievements
}

enum AchievementTier {
  bronze, // Easy
  silver, // Medium
  gold, // Hard
  platinum, // Very Hard
  legendary, // Extreme
}

enum AchievementStatus {
  locked,
  unlocked,
  claimed,
}

@JsonSerializable()
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final AchievementTier tier;
  final String icon; // Emoji icon
  final int requiredValue; // Value to unlock
  final String? requirement; // Description of requirement
  final int rewardXp;
  final int rewardCoins;
  final List<String> rewardBadges; // Badge IDs
  final bool isHidden; // Hidden until unlocked
  final int? maxCount; // If null, can be earned once
  final DateTime releasedAt;
  final DateTime? expiresAt; // For limited-time achievements
  final List<String> tags; // Achievement categories/tags

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    required this.icon,
    required this.requiredValue,
    this.requirement,
    required this.rewardXp,
    required this.rewardCoins,
    required this.rewardBadges,
    required this.isHidden,
    this.maxCount,
    required this.releasedAt,
    this.expiresAt,
    required this.tags,
  });

  String get tierLabel {
    switch (tier) {
      case AchievementTier.bronze:
        return 'ブロンズ';
      case AchievementTier.silver:
        return 'シルバー';
      case AchievementTier.gold:
        return 'ゴールド';
      case AchievementTier.platinum:
        return 'プラチナ';
      case AchievementTier.legendary:
        return 'レジェンダリー';
    }
  }

  String get typeLabel {
    switch (type) {
      case AchievementType.learning:
        return '学習';
      case AchievementType.social:
        return 'ソーシャル';
      case AchievementType.challenge:
        return 'チャレンジ';
      case AchievementType.skill:
        return 'スキル';
      case AchievementType.milestone:
        return 'マイルストーン';
      case AchievementType.streak:
        return 'ストリーク';
      case AchievementType.exploration:
        return '探索';
      case AchievementType.seasonal:
        return 'シーズン';
      case AchievementType.special:
        return 'スペシャル';
      case AchievementType.ranking:
        return 'ランキング';
    }
  }

  String get tierEmoji {
    switch (tier) {
      case AchievementTier.bronze:
        return '🥉';
      case AchievementTier.silver:
        return '🥈';
      case AchievementTier.gold:
        return '🥇';
      case AchievementTier.platinum:
        return '💎';
      case AchievementTier.legendary:
        return '⭐';
    }
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    AchievementType? type,
    AchievementTier? tier,
    String? icon,
    int? requiredValue,
    String? requirement,
    int? rewardXp,
    int? rewardCoins,
    List<String>? rewardBadges,
    bool? isHidden,
    int? maxCount,
    DateTime? releasedAt,
    DateTime? expiresAt,
    List<String>? tags,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      tier: tier ?? this.tier,
      icon: icon ?? this.icon,
      requiredValue: requiredValue ?? this.requiredValue,
      requirement: requirement ?? this.requirement,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardBadges: rewardBadges ?? this.rewardBadges,
      isHidden: isHidden ?? this.isHidden,
      maxCount: maxCount ?? this.maxCount,
      releasedAt: releasedAt ?? this.releasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      tags: tags ?? this.tags,
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

@JsonSerializable()
class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final int unlockedCount; // How many times earned (for repeatable achievements)
  final bool isNewlySeen; // Notification shown
  final bool isRewarded; // Rewards claimed
  final DateTime? claimedAt;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    required this.unlockedCount,
    required this.isNewlySeen,
    required this.isRewarded,
    this.claimedAt,
  });

  bool get hasUnclaimed => !isRewarded;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(unlockedAt);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${unlockedAt.month}月${unlockedAt.day}日';
    }
  }

  UserAchievement copyWith({
    String? id,
    String? userId,
    String? achievementId,
    DateTime? unlockedAt,
    int? unlockedCount,
    bool? isNewlySeen,
    bool? isRewarded,
    DateTime? claimedAt,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockedCount: unlockedCount ?? this.unlockedCount,
      isNewlySeen: isNewlySeen ?? this.isNewlySeen,
      isRewarded: isRewarded ?? this.isRewarded,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$UserAchievementToJson(this);
}

@JsonSerializable()
class AchievementProgress {
  final String id;
  final String userId;
  final String achievementId;
  final int currentProgress;
  final int targetProgress;
  final DateTime lastUpdatedAt;
  final bool isUnlocked;

  AchievementProgress({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.currentProgress,
    required this.targetProgress,
    required this.lastUpdatedAt,
    required this.isUnlocked,
  });

  double get progressPercent => (currentProgress / targetProgress * 100).clamp(0, 100);

  String get progressDisplay => '$currentProgress / $targetProgress';

  bool get isComplete => currentProgress >= targetProgress;

  AchievementProgress copyWith({
    String? id,
    String? userId,
    String? achievementId,
    int? currentProgress,
    int? targetProgress,
    DateTime? lastUpdatedAt,
    bool? isUnlocked,
  }) {
    return AchievementProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  factory AchievementProgress.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementProgressToJson(this);
}

@JsonSerializable()
class AchievementStats {
  final String userId;
  final int totalAchievements;
  final int unlockedCount;
  final int claimedCount;
  final int totalXpEarned;
  final int totalCoinsEarned;
  final List<String> unlockedBadges;
  final Map<String, int> typeBreakdown; // type -> count
  final Map<String, int> tierBreakdown; // tier -> count
  final DateTime lastAchievementAt;
  final int currentStreak; // Consecutive days with achievements

  AchievementStats({
    required this.userId,
    required this.totalAchievements,
    required this.unlockedCount,
    required this.claimedCount,
    required this.totalXpEarned,
    required this.totalCoinsEarned,
    required this.unlockedBadges,
    required this.typeBreakdown,
    required this.tierBreakdown,
    required this.lastAchievementAt,
    required this.currentStreak,
  });

  double get completionPercent => (unlockedCount / totalAchievements * 100).clamp(0, 100);

  String get completionDisplay => '$unlockedCount / $totalAchievements';

  AchievementStats copyWith({
    String? userId,
    int? totalAchievements,
    int? unlockedCount,
    int? claimedCount,
    int? totalXpEarned,
    int? totalCoinsEarned,
    List<String>? unlockedBadges,
    Map<String, int>? typeBreakdown,
    Map<String, int>? tierBreakdown,
    DateTime? lastAchievementAt,
    int? currentStreak,
  }) {
    return AchievementStats(
      userId: userId ?? this.userId,
      totalAchievements: totalAchievements ?? this.totalAchievements,
      unlockedCount: unlockedCount ?? this.unlockedCount,
      claimedCount: claimedCount ?? this.claimedCount,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      typeBreakdown: typeBreakdown ?? this.typeBreakdown,
      tierBreakdown: tierBreakdown ?? this.tierBreakdown,
      lastAchievementAt: lastAchievementAt ?? this.lastAchievementAt,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  factory AchievementStats.fromJson(Map<String, dynamic> json) =>
      _$AchievementStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementStatsToJson(this);
}

@JsonSerializable()
class AchievementNotification {
  final String id;
  final String userId;
  final String achievementId;
  final String achievementName;
  final String icon;
  final int rewardXp;
  final int rewardCoins;
  final DateTime createdAt;
  final bool isRead;
  final bool isRewarded;

  AchievementNotification({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.achievementName,
    required this.icon,
    required this.rewardXp,
    required this.rewardCoins,
    required this.createdAt,
    required this.isRead,
    required this.isRewarded,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }

  AchievementNotification copyWith({
    String? id,
    String? userId,
    String? achievementId,
    String? achievementName,
    String? icon,
    int? rewardXp,
    int? rewardCoins,
    DateTime? createdAt,
    bool? isRead,
    bool? isRewarded,
  }) {
    return AchievementNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      achievementName: achievementName ?? this.achievementName,
      icon: icon ?? this.icon,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isRewarded: isRewarded ?? this.isRewarded,
    );
  }

  factory AchievementNotification.fromJson(Map<String, dynamic> json) =>
      _$AchievementNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementNotificationToJson(this);
}
