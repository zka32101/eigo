/// Achievement and badge models for user progression
/// Phase 15 Part 3: Achievements & Badges System

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int requiredValue; // Value needed to unlock
  final int rewardPoints;
  final DateTime createdAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.requiredValue,
    required this.rewardPoints,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'category': category.toString().split('.').last,
    'requiredValue': requiredValue,
    'rewardPoints': rewardPoints,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: _categoryFromString(json['category'] as String? ?? 'milestone'),
      requiredValue: json['requiredValue'] as int,
      rewardPoints: json['rewardPoints'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static AchievementCategory _categoryFromString(String category) {
    switch (category) {
      case 'milestone':
        return AchievementCategory.milestone;
      case 'streak':
        return AchievementCategory.streak;
      case 'accuracy':
        return AchievementCategory.accuracy;
      case 'social':
        return AchievementCategory.social;
      case 'challenge':
        return AchievementCategory.challenge;
      case 'collection':
        return AchievementCategory.collection;
      default:
        return AchievementCategory.milestone;
    }
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeRarity rarity;
  final String? achievementId; // Associated achievement
  final DateTime createdAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    this.achievementId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'rarity': rarity.toString().split('.').last,
    'achievementId': achievementId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      rarity: _rarityFromString(json['rarity'] as String? ?? 'common'),
      achievementId: json['achievementId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static BadgeRarity _rarityFromString(String rarity) {
    switch (rarity) {
      case 'common':
        return BadgeRarity.common;
      case 'uncommon':
        return BadgeRarity.uncommon;
      case 'rare':
        return BadgeRarity.rare;
      case 'epic':
        return BadgeRarity.epic;
      case 'legendary':
        return BadgeRarity.legendary;
      default:
        return BadgeRarity.common;
    }
  }
}

class UserAchievement {
  final String userId;
  final String achievementId;
  final Achievement achievement;
  final DateTime unlockedAt;
  final int progress; // Current progress (0-100)

  const UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.achievement,
    required this.unlockedAt,
    required this.progress,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'achievementId': achievementId,
    'achievement': achievement.toJson(),
    'unlockedAt': unlockedAt.toIso8601String(),
    'progress': progress,
  };

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: json['userId'] as String,
      achievementId: json['achievementId'] as String,
      achievement: Achievement.fromJson(json['achievement'] as Map<String, dynamic>),
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      progress: json['progress'] as int? ?? 0,
    );
  }
}

class UserBadge {
  final String userId;
  final String badgeId;
  final Badge badge;
  final DateTime earnedAt;
  final bool isEquipped; // Currently displayed badge

  const UserBadge({
    required this.userId,
    required this.badgeId,
    required this.badge,
    required this.earnedAt,
    required this.isEquipped,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'badgeId': badgeId,
    'badge': badge.toJson(),
    'earnedAt': earnedAt.toIso8601String(),
    'isEquipped': isEquipped,
  };

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      userId: json['userId'] as String,
      badgeId: json['badgeId'] as String,
      badge: Badge.fromJson(json['badge'] as Map<String, dynamic>),
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      isEquipped: json['isEquipped'] as bool? ?? false,
    );
  }
}

enum AchievementCategory {
  milestone,
  streak,
  accuracy,
  social,
  challenge,
  collection,
}

enum BadgeRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}
