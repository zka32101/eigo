import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/leaderboard_rank_notification_service.dart';

// ===== Service Provider =====

/// Leaderboard rank notification service provider
final leaderboardRankNotificationServiceProvider =
    Provider<LeaderboardRankNotificationService>((ref) {
  return LeaderboardRankNotificationService();
});

// ===== Notification Providers =====

/// Get unread notifications for a user
final unreadNotificationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final service = ref.watch(leaderboardRankNotificationServiceProvider);
  return service.getUnreadNotifications(userId);
});

/// Get notification statistics
final notificationStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.watch(leaderboardRankNotificationServiceProvider);
  return service.getNotificationStats(userId);
});

// ===== Action Functions =====

/// Notify user of rank change
Future<void> notifyRankChangeAction(
  WidgetRef ref, {
  required String userId,
  required int previousRank,
  required int newRank,
  required String groupType,
  String? groupName,
}) async {
  final service = ref.read(leaderboardRankNotificationServiceProvider);
  await service.notifyRankChange(
    userId: userId,
    previousRank: previousRank,
    newRank: newRank,
    groupType: groupType,
    groupName: groupName,
  );

  // Refresh notifications
  ref.refresh(unreadNotificationsProvider(userId));
}

/// Notify user of rank milestone
Future<void> notifyRankMilestoneAction(
  WidgetRef ref, {
  required String userId,
  required int currentRank,
  required String milestone,
  required String groupType,
  String? groupName,
}) async {
  final service = ref.read(leaderboardRankNotificationServiceProvider);
  await service.notifyRankMilestone(
    userId: userId,
    currentRank: currentRank,
    milestone: milestone,
    groupType: groupType,
    groupName: groupName,
  );

  // Refresh notifications
  ref.refresh(unreadNotificationsProvider(userId));
}

/// Notify user of top position
Future<void> notifyTopPositionAction(
  WidgetRef ref, {
  required String userId,
  required String groupType,
  String? groupName,
}) async {
  final service = ref.read(leaderboardRankNotificationServiceProvider);
  await service.notifyTopPosition(
    userId: userId,
    groupType: groupType,
    groupName: groupName,
  );

  // Refresh notifications
  ref.refresh(unreadNotificationsProvider(userId));
}

/// Mark notification as read
Future<void> markNotificationAsReadAction(
  WidgetRef ref, {
  required String userId,
  required String notificationId,
}) async {
  final service = ref.read(leaderboardRankNotificationServiceProvider);
  await service.markAsRead(notificationId);

  // Refresh notifications
  ref.refresh(unreadNotificationsProvider(userId));
}

/// Mark all notifications as read
Future<void> markAllNotificationsAsReadAction(
  WidgetRef ref, {
  required String userId,
}) async {
  final service = ref.read(leaderboardRankNotificationServiceProvider);
  await service.markAllAsRead(userId);

  // Refresh notifications
  ref.refresh(unreadNotificationsProvider(userId));
  ref.refresh(notificationStatsProvider(userId));
}

/// Notify about upcoming promotion
Future<void> notifyUpcomingPromotionAction(
  WidgetRef ref, {
  required String userId,
  required DateTime promotionDate,
  required int currentGrade,
  required int newGrade,
}) async {
  final service = ref.read(leaderboardRankNotificationServiceProvider);
  await service.notifyUpcomingPromotion(
    userId: userId,
    promotionDate: promotionDate,
    currentGrade: currentGrade,
    newGrade: newGrade,
  );

  // Refresh notifications
  ref.refresh(unreadNotificationsProvider(userId));
}

/// Notify about grade promotion
Future<void> notifyGradePromotionAction(
  WidgetRef ref, {
  required String userId,
  required int previousGrade,
  required int newGrade,
}) async {
  final service = ref.read(leaderboardRankNotificationServiceProvider);
  await service.notifyGradePromotion(
    userId: userId,
    previousGrade: previousGrade,
    newGrade: newGrade,
  );

  // Refresh notifications
  ref.refresh(unreadNotificationsProvider(userId));
}
