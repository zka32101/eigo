import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';

// Service provider
final achievementServiceProvider = Provider((ref) => AchievementService());

// FutureProviders

final achievementsProvider = FutureProvider((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return await service.getAchievements();
});

final achievementsByTypeProvider = FutureProvider.family<List<Achievement>, AchievementType>(
  (ref, type) async {
    final service = ref.watch(achievementServiceProvider);
    return await service.getAchievementsByType(type);
  },
);

final userAchievementsProvider = FutureProvider.family<List<UserAchievement>, String>(
  (ref, userId) async {
    final service = ref.watch(achievementServiceProvider);
    return await service.getUserAchievements(userId);
  },
);

final unclaimedAchievementsProvider = FutureProvider.family<List<UserAchievement>, String>(
  (ref, userId) async {
    final service = ref.watch(achievementServiceProvider);
    return await service.getUnclaimedAchievements(userId);
  },
);

final achievementProgressProvider =
    FutureProvider.family<AchievementProgress?, ({String userId, String achievementId})>(
  (ref, params) async {
    final service = ref.watch(achievementServiceProvider);
    return await service.getAchievementProgress(params.userId, params.achievementId);
  },
);

final achievementStatsProvider = FutureProvider.family<AchievementStats?, String>(
  (ref, userId) async {
    final service = ref.watch(achievementServiceProvider);
    return await service.getAchievementStats(userId);
  },
);

final recentAchievementsProvider = FutureProvider.family<List<UserAchievement>, String>(
  (ref, userId) async {
    final service = ref.watch(achievementServiceProvider);
    return await service.getRecentUnlockedAchievements(userId, 5);
  },
);

final achievementNotificationsProvider = FutureProvider.family<List<AchievementNotification>, String>(
  (ref, userId) async {
    final service = ref.watch(achievementServiceProvider);
    return await service.getAchievementNotifications(userId);
  },
);

// Action providers

class UnlockAchievementParams {
  final String userId;
  final String achievementId;

  UnlockAchievementParams({
    required this.userId,
    required this.achievementId,
  });
}

final unlockAchievementActionProvider =
    StateNotifierProvider<_ActionStateNotifier<UnlockAchievementParams>, UnlockAchievementParams?>(
  (ref) => _ActionStateNotifier(
    onAction: (params, service) async {
      final result = await service.unlockAchievement(params.userId, params.achievementId);
      if (result) {
        // Invalidate related caches
        ref.refresh(userAchievementsProvider(params.userId));
        ref.refresh(achievementStatsProvider(params.userId));
        ref.refresh(unclaimedAchievementsProvider(params.userId));
      }
      return result;
    },
    serviceProvider: achievementServiceProvider,
  ),
);

class ClaimRewardsParams {
  final String userId;
  final String achievementId;

  ClaimRewardsParams({
    required this.userId,
    required this.achievementId,
  });
}

final claimRewardsActionProvider =
    StateNotifierProvider<_ActionStateNotifier<ClaimRewardsParams>, ClaimRewardsParams?>(
  (ref) => _ActionStateNotifier(
    onAction: (params, service) async {
      final result = await service.claimAchievementRewards(params.userId, params.achievementId);
      if (result['success'] as bool) {
        // Invalidate related caches
        ref.refresh(userAchievementsProvider(params.userId));
        ref.refresh(unclaimedAchievementsProvider(params.userId));
        ref.refresh(achievementStatsProvider(params.userId));
      }
      return result;
    },
    serviceProvider: achievementServiceProvider,
  ),
);

class MarkNotificationAsReadParams {
  final String userId;
  final String notificationId;

  MarkNotificationAsReadParams({
    required this.userId,
    required this.notificationId,
  });
}

final markNotificationAsReadActionProvider = StateNotifierProvider<
    _ActionStateNotifier<MarkNotificationAsReadParams>,
    MarkNotificationAsReadParams?>(
  (ref) => _ActionStateNotifier(
    onAction: (params, service) async {
      await service.markNotificationAsRead(params.userId, params.notificationId);
      ref.refresh(achievementNotificationsProvider(params.userId));
      return true;
    },
    serviceProvider: achievementServiceProvider,
  ),
);

// UI State Providers

final achievementTypeFilterProvider = StateProvider<AchievementType?>((ref) => null);

final achievementTierFilterProvider = StateProvider<AchievementTier?>((ref) => null);

final achievementSearchQueryProvider = StateProvider<String>((ref) => '');

final showOnlyUnlockedProvider = StateProvider<bool>((ref) => false);

// Generic action state notifier
class _ActionStateNotifier<T> extends StateNotifier<T?> {
  final Future<dynamic> Function(T, AchievementService) onAction;
  final Provider<AchievementService> serviceProvider;

  _ActionStateNotifier({
    required this.onAction,
    required this.serviceProvider,
  }) : super(null);

  void execute(T params, AchievementService service) async {
    state = params;
    await onAction(params, service);
    state = null;
  }
}
