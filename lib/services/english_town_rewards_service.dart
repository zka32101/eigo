import '../models/english_town_model.dart';

/// Reward calculation and milestone tracking for English-Only Town
class EnglishTownRewardsService {
  /// Calculate XP reward based on difficulty and response quality
  ///
  /// Base XP values by difficulty:
  /// - Easy: 50 XP base
  /// - Medium: 100 XP base
  /// - Hard: 150 XP base
  /// - Expert: 200 XP base
  ///
  /// Multiplier by response correctness:
  /// - 90-100%: 1.5x multiplier
  /// - 70-89%: 1.25x multiplier
  /// - 50-69%: 1.0x multiplier
  /// - <50%: 0.75x multiplier
  static int calculateXpReward({
    required ConversationDifficulty difficulty,
    required int correctnessScore,
  }) {
    final baseXp = _getBaseXp(difficulty);
    final multiplier = _getScoreMultiplier(correctnessScore);
    return (baseXp * multiplier).toInt();
  }

  /// Calculate coin reward based on difficulty and streak bonus
  ///
  /// Base coin values by difficulty:
  /// - Easy: 25 coins
  /// - Medium: 50 coins
  /// - Hard: 75 coins
  /// - Expert: 100 coins
  ///
  /// Streak bonuses:
  /// - 3+ consecutive: +10 coins
  /// - 5+ consecutive: +25 coins
  /// - 7+ consecutive: +50 coins
  static int calculateCoinReward({
    required ConversationDifficulty difficulty,
    required int conversationStreak,
  }) {
    final baseCoins = _getBaseCoins(difficulty);
    final streakBonus = _getStreakBonus(conversationStreak);
    return baseCoins + streakBonus;
  }

  /// Determine if a location should be unlocked based on total conversations
  ///
  /// Unlock progression:
  /// - 0 conversations: School, Café, Library (starter locations)
  /// - 5+ conversations: Park, Bus Station
  /// - 10+ conversations: Shop, Museum
  /// - 20+ conversations: All locations unlocked
  static List<String> getUnlockedLocationIds(int totalConversations) {
    final unlockedIds = <String>[
      'loc_school',    // Always available
      'loc_cafe',      // Always available
      'loc_library',   // Always available
    ];

    if (totalConversations >= 5) {
      unlockedIds.addAll(['loc_park', 'loc_bus_station']);
    }

    if (totalConversations >= 10) {
      unlockedIds.addAll(['loc_shop', 'loc_museum']);
    }

    if (totalConversations >= 20) {
      unlockedIds.addAll(['loc_restaurant']);
    }

    return unlockedIds;
  }

  /// Get milestones achieved based on progress
  static List<Milestone> getMilestones(TownProgress progress) {
    final milestones = <Milestone>[];

    // Conversation milestones
    if (progress.totalConversations >= 1) {
      milestones.add(Milestone(
        id: 'milestone_first_chat',
        title: '💬 First Chat',
        description: 'Complete your first conversation',
        achieved: true,
        rewardXp: 50,
        icon: '💬',
      ));
    }

    if (progress.totalConversations >= 5) {
      milestones.add(Milestone(
        id: 'milestone_chatty',
        title: '🗣️ Chatty',
        description: 'Complete 5 conversations',
        achieved: true,
        rewardXp: 150,
        icon: '🗣️',
      ));
    }

    if (progress.totalConversations >= 10) {
      milestones.add(Milestone(
        id: 'milestone_conversationalist',
        title: '💡 Conversationalist',
        description: 'Complete 10 conversations',
        achieved: true,
        rewardXp: 300,
        icon: '💡',
      ));
    }

    if (progress.totalConversations >= 25) {
      milestones.add(Milestone(
        id: 'milestone_fluent',
        title: '🌟 Fluent',
        description: 'Complete 25 conversations',
        achieved: true,
        rewardXp: 500,
        icon: '🌟',
      ));
    }

    if (progress.totalConversations >= 50) {
      milestones.add(Milestone(
        id: 'milestone_expert',
        title: '👑 Expert',
        description: 'Complete 50 conversations',
        achieved: true,
        rewardXp: 1000,
        icon: '👑',
      ));
    }

    // Location milestones
    if (progress.visitedLocationIds.length >= 3) {
      milestones.add(Milestone(
        id: 'milestone_explorer',
        title: '🗺️ Explorer',
        description: 'Visit 3 different locations',
        achieved: true,
        rewardXp: 200,
        icon: '🗺️',
      ));
    }

    if (progress.visitedLocationIds.length >= 8) {
      milestones.add(Milestone(
        id: 'milestone_world_traveler',
        title: '✈️ World Traveler',
        description: 'Visit all 8 locations',
        achieved: true,
        rewardXp: 750,
        icon: '✈️',
      ));
    }

    // XP milestones
    if (progress.totalXpEarned >= 500) {
      milestones.add(Milestone(
        id: 'milestone_xp_500',
        title: '⚡ Rising Star',
        description: 'Earn 500 XP total',
        achieved: true,
        rewardXp: 0,
        icon: '⚡',
      ));
    }

    if (progress.totalXpEarned >= 1000) {
      milestones.add(Milestone(
        id: 'milestone_xp_1000',
        title: '🔥 On Fire',
        description: 'Earn 1000 XP total',
        achieved: true,
        rewardXp: 0,
        icon: '🔥',
      ));
    }

    // Achievement milestones
    if (progress.unlockedAchievements.length >= 5) {
      milestones.add(Milestone(
        id: 'milestone_achiever',
        title: '🏆 Achiever',
        description: 'Unlock 5 achievements',
        achieved: true,
        rewardXp: 400,
        icon: '🏆',
      ));
    }

    return milestones;
  }

  /// Calculate daily bonus XP based on streak
  static int getDailyBonusXp(int streakDays) {
    if (streakDays < 7) return 0;
    if (streakDays < 14) return 100;
    if (streakDays < 30) return 250;
    return 500;
  }

  /// Get achievement unlock criteria
  static List<AchievementCriteria> getAchievementCriteria() {
    return [
      AchievementCriteria(
        id: 'ach_first_step',
        title: 'はじめの一歩 (First Steps)',
        description: 'Complete 1 conversation',
        icon: '👣',
        rarity: AchievementRarity.common,
        criteria: (progress) => progress.totalConversations >= 1,
        rewardXp: 50,
      ),
      AchievementCriteria(
        id: 'ach_opener',
        title: '会話者 (Conversationalist)',
        description: 'Complete 10 conversations',
        icon: '💬',
        rarity: AchievementRarity.uncommon,
        criteria: (progress) => progress.totalConversations >= 10,
        rewardXp: 200,
      ),
      AchievementCriteria(
        id: 'ach_marathon',
        title: 'マラソンランナー (Marathon Runner)',
        description: 'Complete 30 conversations',
        icon: '🏃',
        rarity: AchievementRarity.rare,
        criteria: (progress) => progress.totalConversations >= 30,
        rewardXp: 500,
      ),
      AchievementCriteria(
        id: 'ach_accuracy',
        title: '精密射手 (Accuracy Master)',
        description: 'Achieve 90% average correctness',
        icon: '🎯',
        rarity: AchievementRarity.rare,
        criteria: (progress) => _calculateAverageAccuracy(progress) >= 90,
        rewardXp: 300,
      ),
      AchievementCriteria(
        id: 'ach_social',
        title: 'ソーシャルバタフライ (Social Butterfly)',
        description: 'Talk to all 8 NPCs',
        icon: '🦋',
        rarity: AchievementRarity.uncommon,
        criteria: (progress) => progress.npcConversationCounts.length >= 8,
        rewardXp: 400,
      ),
      AchievementCriteria(
        id: 'ach_explorer',
        title: '世界探検家 (World Explorer)',
        description: 'Visit all 8 locations',
        icon: '🌍',
        rarity: AchievementRarity.rare,
        criteria: (progress) => progress.visitedLocationIds.length >= 8,
        rewardXp: 600,
      ),
      AchievementCriteria(
        id: 'ach_collector',
        title: 'コインコレクター (Coin Collector)',
        description: 'Earn 500 coins',
        icon: '💰',
        rarity: AchievementRarity.uncommon,
        criteria: (progress) => progress.totalCoinsEarned >= 500,
        rewardXp: 250,
      ),
      AchievementCriteria(
        id: 'ach_streak',
        title: '連勝記録 (Hot Streak)',
        description: 'Achieve 7-day conversation streak',
        icon: '🔥',
        rarity: AchievementRarity.rare,
        criteria: (progress) => true, // TODO: Implement streak tracking
        rewardXp: 350,
      ),
    ];
  }

  // Private helper methods

  static int _getBaseXp(ConversationDifficulty difficulty) {
    switch (difficulty) {
      case ConversationDifficulty.easy:
        return 50;
      case ConversationDifficulty.medium:
        return 100;
      case ConversationDifficulty.hard:
        return 150;
      case ConversationDifficulty.expert:
        return 200;
    }
  }

  static int _getBaseCoins(ConversationDifficulty difficulty) {
    switch (difficulty) {
      case ConversationDifficulty.easy:
        return 25;
      case ConversationDifficulty.medium:
        return 50;
      case ConversationDifficulty.hard:
        return 75;
      case ConversationDifficulty.expert:
        return 100;
    }
  }

  static double _getScoreMultiplier(int correctnessScore) {
    if (correctnessScore >= 90) return 1.5;
    if (correctnessScore >= 70) return 1.25;
    if (correctnessScore >= 50) return 1.0;
    return 0.75;
  }

  static int _getStreakBonus(int conversationStreak) {
    if (conversationStreak >= 7) return 50;
    if (conversationStreak >= 5) return 25;
    if (conversationStreak >= 3) return 10;
    return 0;
  }

  static double _calculateAverageAccuracy(TownProgress progress) {
    // TODO: Implement when scene completion tracking includes scores
    return 0.0;
  }
}

/// Milestone data class
class Milestone {
  final String id;
  final String title;
  final String description;
  final bool achieved;
  final int rewardXp;
  final String icon;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.achieved,
    required this.rewardXp,
    required this.icon,
  });
}

/// Achievement criteria for tracking unlocks
class AchievementCriteria {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final bool Function(TownProgress) criteria;
  final int rewardXp;

  AchievementCriteria({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.criteria,
    required this.rewardXp,
  });
}

/// Achievement rarity levels
enum AchievementRarity {
  common,
  uncommon,
  rare,
  legendary,
}
