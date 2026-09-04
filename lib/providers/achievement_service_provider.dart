import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

/// Singleton provider for AchievementService
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

/// Parameter classes for actions
class UnlockAchievementParams {
  final String userId;
  final String achievementId;

  UnlockAchievementParams({
    required this.userId,
    required this.achievementId,
  });
}

class UpdateAchievementProgressParams {
  final String userId;
  final String achievementId;
  final int progress;

  UpdateAchievementProgressParams({
    required this.userId,
    required this.achievementId,
    required this.progress,
  });
}

class AwardBadgeParams {
  final String userId;
  final String badgeId;

  AwardBadgeParams({
    required this.userId,
    required this.badgeId,
  });
}

class EquipBadgeParams {
  final String userId;
  final String badgeId;

  EquipBadgeParams({
    required this.userId,
    required this.badgeId,
  });
}

/// ==================== ACHIEVEMENT QUERY PROVIDERS ====================

/// Get all achievements
final allAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAllAchievements();
});

/// Get user's achievements
final userAchievementsProvider = FutureProvider.family<List<UserAchievement>, String>((ref, userId) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getUserAchievements(userId);
});

/// Stream user achievements for real-time updates
final userAchievementsStreamProvider = StreamProvider.family<List<UserAchievement>, String>((ref, userId) {
  final service = ref.watch(achievementServiceProvider);
  return service.streamUserAchievements(userId);
});

/// Get achievements by category
final achievementsByCategoryProvider = FutureProvider.family<List<Achievement>, AchievementCategory>((ref, category) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAchievementsByCategory(category);
});

/// ==================== BADGE QUERY PROVIDERS ====================

/// Get all badges
final allBadgesProvider = FutureProvider<List<Badge>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAllBadges();
});

/// Get user's badges
final userBadgesProvider = FutureProvider.family<List<UserBadge>, String>((ref, userId) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getUserBadges(userId);
});

/// Get badges by rarity
final badgesByRarityProvider = FutureProvider.family<List<Badge>, BadgeRarity>((ref, rarity) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getBadgesByRarity(rarity);
});

/// ==================== ACTION PROVIDERS ====================

/// Unlock achievement action
final unlockAchievementActionProvider = StateProvider<UnlockAchievementParams?>((ref) => null);

final unlockAchievementProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(unlockAchievementActionProvider);
  if (params == null) return false;

  final service = ref.watch(achievementServiceProvider);
  final result = await service.unlockAchievement(params.userId, params.achievementId);

  // Invalidate related providers
  if (result) {
    ref.invalidate(userAchievementsProvider(params.userId));
    ref.invalidate(userAchievementsStreamProvider(params.userId));
  }

  return result;
});

/// Update achievement progress action
final updateAchievementProgressActionProvider = StateProvider<UpdateAchievementProgressParams?>((ref) => null);

final updateAchievementProgressProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(updateAchievementProgressActionProvider);
  if (params == null) return false;

  final service = ref.watch(achievementServiceProvider);
  final result = await service.updateAchievementProgress(
    params.userId,
    params.achievementId,
    params.progress,
  );

  // Invalidate related providers
  if (result) {
    ref.invalidate(userAchievementsProvider(params.userId));
    ref.invalidate(userAchievementsStreamProvider(params.userId));
  }

  return result;
});

/// Award badge action
final awardBadgeActionProvider = StateProvider<AwardBadgeParams?>((ref) => null);

final awardBadgeProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(awardBadgeActionProvider);
  if (params == null) return false;

  final service = ref.watch(achievementServiceProvider);
  final result = await service.awardBadge(params.userId, params.badgeId);

  // Invalidate related providers
  if (result) {
    ref.invalidate(userBadgesProvider(params.userId));
  }

  return result;
});

/// Equip badge action
final equipBadgeActionProvider = StateProvider<EquipBadgeParams?>((ref) => null);

final equipBadgeProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(equipBadgeActionProvider);
  if (params == null) return false;

  final service = ref.watch(achievementServiceProvider);
  final result = await service.equipBadge(params.userId, params.badgeId);

  // Invalidate related providers
  if (result) {
    ref.invalidate(userBadgesProvider(params.userId));
  }

  return result;
});

/// ==================== UI STATE PROVIDERS ====================

/// Selected achievement category
final selectedAchievementCategoryProvider = StateProvider<AchievementCategory>((ref) => AchievementCategory.milestone);

/// Selected badge rarity filter
final selectedBadgeRarityProvider = StateProvider<BadgeRarity?>((ref) => null);

/// Achievement detail view
final achievementDetailProvider = StateProvider<String?>((ref) => null);
