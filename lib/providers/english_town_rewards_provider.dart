import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../services/english_town_rewards_service.dart';
import 'english_town_provider.dart';

/// ==================== REWARDS SYSTEM (Phase 4) ====================

/// Calculate XP reward for a specific conversation
final conversationXpCalculatorProvider =
    Provider.family<int, ({
      ConversationDifficulty difficulty,
      int correctnessScore,
    })>((ref, params) {
  return EnglishTownRewardsService.calculateXpReward(
    difficulty: params.difficulty,
    correctnessScore: params.correctnessScore,
  );
});

/// Calculate coin reward for a specific conversation
final conversationCoinCalculatorProvider =
    Provider.family<int, ({
      ConversationDifficulty difficulty,
      int conversationStreak,
    })>((ref, params) {
  return EnglishTownRewardsService.calculateCoinReward(
    difficulty: params.difficulty,
    conversationStreak: params.conversationStreak,
  );
});

/// Get list of unlocked location IDs based on conversation count
final unlockedLocationsProvider = Provider<List<String>>((ref) {
  final progress = ref.watch(townProgressProvider);
  return EnglishTownRewardsService.getUnlockedLocationIds(
    progress.totalConversations,
  );
});

/// Check if a specific location is unlocked
final isLocationUnlockedProvider =
    Provider.family<bool, String>((ref, locationId) {
  final unlockedIds = ref.watch(unlockedLocationsProvider);
  return unlockedIds.contains(locationId);
});

/// Get all milestones for current progress
final milestonesProvider = Provider<List<Milestone>>((ref) {
  final progress = ref.watch(townProgressProvider);
  return EnglishTownRewardsService.getMilestones(progress);
});

/// Get milestone count (achieved)
final achievedMilestonesCountProvider = Provider<int>((ref) {
  final milestones = ref.watch(milestonesProvider);
  return milestones.where((m) => m.achieved).length;
});

/// Get total milestones available
final totalMilestonesProvider = Provider<int>((ref) {
  final milestones = ref.watch(milestonesProvider);
  return milestones.length;
});

/// Milestone progress percentage (0-100)
final milestoneProgressPercentageProvider = Provider<int>((ref) {
  final achieved = ref.watch(achievedMilestonesCountProvider);
  final total = ref.watch(totalMilestonesProvider);
  if (total == 0) return 0;
  return ((achieved / total) * 100).toInt();
});

/// Get daily bonus XP based on streak
final dailyBonusXpProvider = Provider<int>((ref) {
  final progress = ref.watch(townProgressProvider);
  // TODO: Implement streak tracking to use here
  return 0;
});

/// Get achievement criteria and check unlock status
final achievementCriteriaProvider = Provider<List<AchievementCriteria>>((ref) {
  return EnglishTownRewardsService.getAchievementCriteria();
});

/// Check if a specific achievement is unlocked
final isAchievementUnlockedProvider =
    Provider.family<bool, String>((ref, achievementId) {
  final progress = ref.watch(townProgressProvider);
  return progress.unlockedAchievements.contains(achievementId);
});

/// Get all unlockable achievements with their status
final achievementStatusProvider = Provider<List<({
  AchievementCriteria criteria,
  bool unlocked,
})>>((ref) {
  final criteria = ref.watch(achievementCriteriaProvider);
  final progress = ref.watch(townProgressProvider);

  return criteria.map((ach) {
    final unlocked = progress.unlockedAchievements.contains(ach.id);
    final meetsRequirements = ach.criteria(progress);

    return (
      criteria: ach,
      unlocked: unlocked || meetsRequirements,
    );
  }).toList();
});

/// Get count of unlocked achievements
final unlockedAchievementsCountProvider2 = Provider<int>((ref) {
  final achievements = ref.watch(achievementStatusProvider);
  return achievements.where((a) => a.unlocked).length;
});

/// Simulate reward popup data
class RewardPopup {
  final int xpEarned;
  final int coinsEarned;
  final List<String> achievementsUnlocked;
  final List<String> milestonesUnlocked;
  final String? npcMessage;

  RewardPopup({
    required this.xpEarned,
    required this.coinsEarned,
    this.achievementsUnlocked = const [],
    this.milestonesUnlocked = const [],
    this.npcMessage,
  });
}

/// Track current reward notification
final currentRewardNotificationProvider =
    StateProvider<RewardPopup?>((ref) => null);

/// ==================== LOCATION UNLOCK SYSTEM ====================

/// Get lock status for all locations
final locationLockStatusProvider = Provider<Map<String, bool>>((ref) {
  final locations = ref.watch(townLocationsProvider);
  final unlockedIds = ref.watch(unlockedLocationsProvider);

  return {
    for (final location in locations)
      location.id: unlockedIds.contains(location.id),
  };
});

/// Get next location unlock milestone
final nextLocationUnlockProvider = Provider<({
  String locationId,
  String locationName,
  int conversationsNeeded,
})?>((ref) {
  final progress = ref.watch(townProgressProvider);
  final townMap = ref.watch(townMapProvider);

  // Check which location should unlock next
  if (progress.totalConversations < 5) {
    return (
      locationId: 'loc_park',
      locationName: 'Park',
      conversationsNeeded: 5 - progress.totalConversations,
    );
  }

  if (progress.totalConversations < 10) {
    return (
      locationId: 'loc_shop',
      locationName: 'Shop',
      conversationsNeeded: 10 - progress.totalConversations,
    );
  }

  if (progress.totalConversations < 20) {
    return (
      locationId: 'loc_restaurant',
      locationName: 'Restaurant',
      conversationsNeeded: 20 - progress.totalConversations,
    );
  }

  // All locations unlocked
  return null;
});

/// ==================== PROGRESS INTEGRATION ====================

/// Extended progress stats including rewards
final extendedProgressStatsProvider = Provider<({
  int totalConversations,
  int totalXpEarned,
  int totalCoinsEarned,
  int unlockedAchievementsCount,
  int achievedMilestonesCount,
  int totalMilestonesCount,
  int milestoneProgressPercent,
  int locationProgressPercent,
})>((ref) {
  final progress = ref.watch(townProgressProvider);
  final locations = ref.watch(townLocationsProvider);
  final milestones = ref.watch(milestonesProvider);
  final achievedMilestones = milestones.where((m) => m.achieved).length;

  return (
    totalConversations: progress.totalConversations,
    totalXpEarned: progress.totalXpEarned,
    totalCoinsEarned: progress.totalCoinsEarned,
    unlockedAchievementsCount: progress.unlockedAchievements.length,
    achievedMilestonesCount: achievedMilestones,
    totalMilestonesCount: milestones.length,
    milestoneProgressPercent:
        milestones.isEmpty ? 0 : ((achievedMilestones / milestones.length) * 100).toInt(),
    locationProgressPercent:
        locations.isEmpty ? 0 : ((progress.visitedLocationIds.length / locations.length) * 100).toInt(),
  );
});

// Re-export types for convenience
export '../services/english_town_rewards_service.dart'
    show Milestone, AchievementCriteria, AchievementRarity;
