import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider((ref) {
  return NotificationService();
});

// User notifications provider
final userNotificationsProvider =
    FutureProvider.family<List<Notification>, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getUserNotifications(userId, limit: 100);
});

// Unread notifications provider
final unreadNotificationsProvider =
    FutureProvider.family<List<Notification>, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadNotifications(userId);
});

// Unread count provider
final unreadCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount(userId);
});

// Notification preferences provider
final notificationPreferencesProvider =
    FutureProvider.family<NotificationPreference, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getPreferences(userId);
});

// Notification stats provider
final notificationStatsProvider =
    FutureProvider.family<NotificationStats, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getStats(userId);
});

// Send notification action provider
class SendNotificationParams {
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? icon;
  final String? imageUrl;
  final String? actionRoute;
  final Map<String, dynamic>? actionData;
  final DateTime? expiresAt;
  final NotificationPriority priority;

  SendNotificationParams({
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.icon,
    this.imageUrl,
    this.actionRoute,
    this.actionData,
    this.expiresAt,
    required this.priority,
  });
}

final sendNotificationActionProvider =
    FutureProvider.family<void, SendNotificationParams>(
  (ref, params) async {
    final service = ref.watch(notificationServiceProvider);
    await service.sendNotification(
      userId: params.userId,
      type: params.type,
      title: params.title,
      message: params.message,
      icon: params.icon,
      imageUrl: params.imageUrl,
      actionRoute: params.actionRoute,
      actionData: params.actionData,
      expiresAt: params.expiresAt,
      priority: params.priority,
    );
    // Invalidate related providers
    ref.invalidate(userNotificationsProvider(params.userId));
    ref.invalidate(unreadCountProvider(params.userId));
    ref.invalidate(notificationStatsProvider(params.userId));
  },
);

// Mark as read action provider
class MarkAsReadParams {
  final String notificationId;
  final String userId;

  MarkAsReadParams({
    required this.notificationId,
    required this.userId,
  });
}

final markAsReadActionProvider =
    FutureProvider.family<void, MarkAsReadParams>(
  (ref, params) async {
    final service = ref.watch(notificationServiceProvider);
    await service.markAsRead(params.notificationId);
    // Invalidate related providers
    ref.invalidate(userNotificationsProvider(params.userId));
    ref.invalidate(unreadCountProvider(params.userId));
    ref.invalidate(unreadNotificationsProvider(params.userId));
    ref.invalidate(notificationStatsProvider(params.userId));
  },
);

// Mark all as read action provider
final markAllAsReadActionProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  await service.markAllAsRead(userId);
  // Invalidate related providers
  ref.invalidate(userNotificationsProvider(userId));
  ref.invalidate(unreadCountProvider(userId));
  ref.invalidate(unreadNotificationsProvider(userId));
  ref.invalidate(notificationStatsProvider(userId));
});

// Delete notification action provider
class DeleteNotificationParams {
  final String notificationId;
  final String userId;

  DeleteNotificationParams({
    required this.notificationId,
    required this.userId,
  });
}

final deleteNotificationActionProvider =
    FutureProvider.family<void, DeleteNotificationParams>(
  (ref, params) async {
    final service = ref.watch(notificationServiceProvider);
    await service.deleteNotification(params.notificationId);
    // Invalidate related providers
    ref.invalidate(userNotificationsProvider(params.userId));
    ref.invalidate(unreadCountProvider(params.userId));
    ref.invalidate(notificationStatsProvider(params.userId));
  },
);

// Update preferences action provider
final updatePreferencesActionProvider =
    FutureProvider.family<void, NotificationPreference>(
  (ref, preferences) async {
    final service = ref.watch(notificationServiceProvider);
    await service.setPreferences(preferences.userId, preferences);
    // Invalidate related providers
    ref.invalidate(
      notificationPreferencesProvider(preferences.userId),
    );
  },
);
