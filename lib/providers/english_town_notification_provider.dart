import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/english_town_notification_service.dart';
import '../services/english_town_firebase_service.dart';
import 'english_town_firebase_provider.dart';

/// ==================== NOTIFICATION SERVICE ====================

/// Notification service instance
final notificationServiceProvider =
    Provider<EnglishTownNotificationService>((ref) {
  return EnglishTownNotificationService();
});

// ==================== NOTIFICATION STREAMS ====================

/// Stream of all notifications
final notificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) async* {
  final service = ref.watch(notificationServiceProvider);

  // For now, emit current state periodically
  // In production, this would listen to Firestore changes
  while (true) {
    yield service.notifications;
    await Future.delayed(const Duration(seconds: 1));
  }
});

/// Stream of unread notifications
final unreadNotificationsProvider =
    StreamProvider<List<AppNotification>>((ref) async* {
  final notifications = ref.watch(notificationsStreamProvider);

  yield notifications.whenData((notifs) {
    return notifs.where((n) => !n.isRead).toList();
  }).value ??
      [];
});

/// Count of unread notifications
final unreadNotificationCountProvider = StreamProvider<int>((ref) async* {
  final unread = ref.watch(unreadNotificationsProvider);

  yield unread.whenData((notifs) => notifs.length).value ?? 0;
});

/// List of all notifications
final allNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider);

  return Stream.value(service.notifications);
});

// ==================== NOTIFICATION PREFERENCES ====================

/// Enable rank change notifications
final enableRankChangeNotificationsProvider =
    StateProvider<bool>((ref) => true);

/// Enable achievement notifications
final enableAchievementNotificationsProvider =
    StateProvider<bool>((ref) => true);

/// Enable streak notifications
final enableStreakNotificationsProvider = StateProvider<bool>((ref) => true);

/// Enable daily challenge notifications
final enableDailyChallengeNotificationsProvider =
    StateProvider<bool>((ref) => true);

/// Enable top 10 notifications
final enableTopLeaderboardNotificationsProvider =
    StateProvider<bool>((ref) => true);

/// Minimum rank change to notify (e.g., only notify if changed by 5+)
final rankChangeNotificationThresholdProvider =
    StateProvider<int>((ref) => 3);

// ==================== RANK TRACKING ====================

/// Previous user rank for change detection
final previousUserRankProvider = StateProvider<int?>((ref) => null);

/// Track rank changes and create notifications
Future<void> checkRankChange(WidgetRef ref) async {
  final currentRank = ref.read(userLeaderboardRankProvider).value;
  final previousRank = ref.read(previousUserRankProvider);
  final enableNotifications =
      ref.read(enableRankChangeNotificationsProvider);
  final threshold =
      ref.read(rankChangeNotificationThresholdProvider);

  if (currentRank == null) return;

  if (previousRank != null && enableNotifications) {
    final rankDiff = (previousRank - currentRank).abs();

    if (rankDiff >= threshold) {
      final notification =
          EnglishTownNotificationService().createRankChangeNotification(
        previousRank: previousRank,
        currentRank: currentRank,
        playerName: 'Player',
      );

      ref.read(notificationServiceProvider).addNotification(notification);
    }
  }

  // Update previous rank
  ref.read(previousUserRankProvider.notifier).state = currentRank;
}

/// Monitor leaderboard for rank changes
final leaderboardChangeMonitorProvider = FutureProvider<void>((ref) async {
  // This provider watches the leaderboard and checks for rank changes
  final leaderboard = ref.watch(globalLeaderboardProvider);
  final userRank = ref.watch(userLeaderboardRankProvider);

  leaderboard.whenData((_) {
    checkRankChange(ref);
  });
});

// ==================== TOP 10 TRACKING ====================

/// Track if user just entered top 10
final isInTopTenProvider = FutureProvider<bool>((ref) async {
  final rank = await ref.watch(userLeaderboardRankProvider.future);
  return rank != null && rank <= 10;
});

/// Check for top 10 entry
Future<void> checkTopTenEntry(WidgetRef ref) async {
  final isInTopTen = ref.read(isInTopTenProvider).value ?? false;
  final userRank = ref.read(userLeaderboardRankProvider).value;
  final enableNotifications =
      ref.read(enableTopLeaderboardNotificationsProvider);

  if (isInTopTen && enableNotifications && userRank != null) {
    final notification = EnglishTownNotificationService()
        .createTopLeaderboardNotification(rank: userRank);
    ref.read(notificationServiceProvider).addNotification(notification);
  }
}

// ==================== NOTIFICATION ACTIONS ====================

/// Mark notification as read
Future<void> markNotificationAsRead(
  WidgetRef ref,
  String notificationId,
) async {
  ref.read(notificationServiceProvider).markAsRead(notificationId);
}

/// Mark all notifications as read
Future<void> markAllNotificationsAsRead(WidgetRef ref) async {
  ref.read(notificationServiceProvider).markAllAsRead();
}

/// Clear all notifications
Future<void> clearAllNotifications(WidgetRef ref) async {
  ref.read(notificationServiceProvider).clearAll();
}

// ==================== NOTIFICATION FILTERING ====================

/// Get notifications by type
final notificationsByTypeProvider =
    Provider.family<List<AppNotification>, NotificationType>((ref, type) {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotificationsByType(type);
});

/// Get recent notifications (last 10)
final recentNotificationsProvider =
    Provider<List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final notifications = service.notifications;
  return notifications.take(10).toList();
});

/// Get notifications from last 24 hours
final todayNotificationsProvider =
    Provider<List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  return service.notifications
      .where((n) => n.createdAt.isAfter(yesterday))
      .toList();
});

/// Count of notifications by type
final notificationCountByTypeProvider =
    Provider.family<int, NotificationType>((ref, type) {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotificationsByType(type).length;
});
