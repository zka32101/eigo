import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Get notifications for a user
final userNotificationsProvider = FutureProvider.family<List<Notification>, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getUserNotifications(userId, limit: 100);
});

/// Stream notifications for real-time updates
final notificationsStreamProvider = StreamProvider.family<List<Notification>, String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return service.streamUserNotifications(userId);
});

/// Get unread notification count
final unreadNotificationCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount(userId);
});

/// Mark notification as read action
final markNotificationAsReadActionProvider = StateProvider<String?>((ref) => null);

final markNotificationAsReadProvider = FutureProvider<bool>((ref) async {
  final notificationId = ref.watch(markNotificationAsReadActionProvider);
  if (notificationId == null) return false;

  final service = ref.watch(notificationServiceProvider);
  return service.markNotificationAsRead(notificationId);
});

/// Mark all as read action
final markAllAsReadActionProvider = StateProvider<String?>((ref) => null);

final markAllAsReadProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(markAllAsReadActionProvider);
  if (userId == null) return false;

  final service = ref.watch(notificationServiceProvider);
  final result = await service.markAllNotificationsAsRead(userId);

  if (result) {
    ref.invalidate(userNotificationsProvider(userId));
    ref.invalidate(unreadNotificationCountProvider(userId));
  }

  return result;
});

/// Delete notification action
final deleteNotificationActionProvider = StateProvider<String?>((ref) => null);

final deleteNotificationProvider = FutureProvider<bool>((ref) async {
  final notificationId = ref.watch(deleteNotificationActionProvider);
  if (notificationId == null) return false;

  final service = ref.watch(notificationServiceProvider);
  return service.deleteNotification(notificationId);
});
