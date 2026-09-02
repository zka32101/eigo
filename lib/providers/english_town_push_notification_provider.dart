import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/english_town_push_notification_service.dart';
import '../services/english_town_firebase_service.dart';
import 'english_town_firebase_provider.dart';

/// Push notification service instance
final pushNotificationServiceProvider =
    Provider<EnglishTownPushNotificationService>((ref) {
  return EnglishTownPushNotificationService();
});

// ==================== FCM DEVICE TOKEN ====================

/// Current device's FCM token
final fcmDeviceTokenProvider = StateProvider<String?>((ref) => null);

/// Store FCM token to Firebase
Future<void> storeFCMToken(WidgetRef ref, String token) async {
  ref.read(fcmDeviceTokenProvider.notifier).state = token;

  // TODO: Store token to Firestore under user document
  // This allows the backend to send targeted push notifications
  // Path: users/{userId}/devices/{deviceId}
}

// ==================== PUSH NOTIFICATION PREFERENCES ====================

/// Enable/disable push notifications globally
final pushNotificationsEnabledProvider = StateProvider<bool>((ref) => true);

/// Enable rank change push notifications
final enableRankChangePushProvider = StateProvider<bool>((ref) => true);

/// Enable achievement push notifications
final enableAchievementPushProvider = StateProvider<bool>((ref) => true);

/// Enable streak milestone push notifications
final enableStreakMilestonePushProvider = StateProvider<bool>((ref) => true);

/// Enable top 10 push notifications
final enableTop10PushProvider = StateProvider<bool>((ref) => true);

/// Enable daily reminder notifications
final enableDailyReminderPushProvider = StateProvider<bool>((ref) => true);

/// Push notification quiet hours (e.g., 10 PM to 8 AM)
final quietHoursStartProvider = StateProvider<int>((ref) => 22); // 10 PM
final quietHoursEndProvider = StateProvider<int>((ref) => 8); // 8 AM

// ==================== PUSH NOTIFICATION STREAMS ====================

/// Stream of push notifications from Firestore
final pushNotificationsStreamProvider =
    StreamProvider<List<PushNotificationPayload>>((ref) async* {
  final service = ref.watch(pushNotificationServiceProvider);
  final userId = ref.watch(cloudUserIdProvider);

  if (userId == null) {
    yield [];
    return;
  }

  // TODO: Implement Firestore listener
  // Listen to: notifications/{userId}/
  // For now, return empty stream
  yield service.getPendingNotifications();
});

/// Stream of unread push notifications
final unreadPushNotificationsProvider =
    StreamProvider<List<PushNotificationPayload>>((ref) async* {
  final notifications = ref.watch(pushNotificationsStreamProvider);

  yield notifications.whenData((notifs) {
    // Filter unread notifications
    return notifs.where((n) => !ref.read(pushNotificationServiceProvider)
        .isNotificationSent(n.notificationId)).toList();
  }).value ??
      [];
});

/// Count of unread push notifications
final unreadPushNotificationCountProvider =
    StreamProvider<int>((ref) async* {
  final unread = ref.watch(unreadPushNotificationsProvider);

  yield unread.whenData((notifs) => notifs.length).value ?? 0;
});

// ==================== DELIVERY STATUS ====================

/// Get push notification delivery status
final pushDeliveryStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  return service.getDeliveryStatus();
});

/// Pending push notifications count
final pendingPushCountProvider = Provider<int>((ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  return service.pendingNotificationsCount;
});

// ==================== ACTIONS ====================

/// Queue a push notification
Future<void> queuePushNotification(
  WidgetRef ref,
  PushNotificationPayload payload,
) async {
  final service = ref.read(pushNotificationServiceProvider);
  service.queuePushNotification(payload);

  // TODO: Send to Firebase Cloud Messaging
  // Call backend endpoint: POST /sendNotification with payload
}

/// Mark push notification as sent
Future<void> markPushNotificationSent(
  WidgetRef ref,
  String notificationId,
) async {
  final service = ref.read(pushNotificationServiceProvider);
  service.markNotificationSent(notificationId);

  // TODO: Update Firestore notification document
  // Set: {sent: true, sentAt: now()}
}

/// Handle incoming push notification from FCM
Future<void> handleIncomingPushNotification(
  WidgetRef ref,
  Map<String, dynamic> payload,
) async {
  final service = ref.read(pushNotificationServiceProvider);
  await service.handleIncomingPushNotification(payload);

  // Check if should show in-app notification
  final enablePush = ref.read(pushNotificationsEnabledProvider);
  if (enablePush) {
    // TODO: Show in-app notification or navigate based on payload
  }
}

/// Check quiet hours
bool isInQuietHours(WidgetRef ref) {
  final now = DateTime.now();
  final startHour = ref.read(quietHoursStartProvider);
  final endHour = ref.read(quietHoursEndProvider);

  if (startHour < endHour) {
    // Normal range (e.g., 10-14 hours)
    return now.hour >= startHour && now.hour < endHour;
  } else {
    // Wrapped range (e.g., 22-8 hours spanning midnight)
    return now.hour >= startHour || now.hour < endHour;
  }
}

// ==================== SCHEDULED NOTIFICATIONS ====================

/// Schedule a push notification for later
Future<void> schedulePushNotification(
  WidgetRef ref, {
  required String title,
  required String body,
  required DateTime scheduledFor,
  bool repeating = false,
  String? recurrencePattern,
}) async {
  // TODO: Store to Firestore notifications/{userId}/scheduled/
  // Backend will pick up and send at scheduled time
}

/// Get scheduled notifications
final scheduledNotificationsProvider =
    StreamProvider<List<ScheduledPushNotification>>((ref) async* {
  final userId = ref.watch(cloudUserIdProvider);

  if (userId == null) {
    yield [];
    return;
  }

  // TODO: Implement Firestore listener for scheduled notifications
  yield [];
});

/// Cancel a scheduled notification
Future<void> cancelScheduledNotification(
  WidgetRef ref,
  String notificationId,
) async {
  // TODO: Delete from Firestore scheduled notifications
}

// ==================== ANALYTICS ====================

/// Track notification engagement
Future<void> trackNotificationEngagement(
  WidgetRef ref, {
  required String notificationId,
  required String engagementType, // 'delivered', 'opened', 'dismissed'
}) async {
  // TODO: Send to Firebase Analytics
  // Event: notification_engagement
  // Parameters: notification_id, engagement_type, timestamp
}

/// Get notification statistics
final notificationStatsProvider =
    StreamProvider<Map<String, dynamic>>((ref) async* {
  // TODO: Query Firestore for statistics
  // delivered_count, opened_count, dismissed_count
  yield {
    'delivered': 0,
    'opened': 0,
    'dismissed': 0,
    'totalSent': 0,
  };
});

// ==================== HELPERS ====================

/// Get optimal notification sending time based on user activity
Future<DateTime> getOptimalNotificationTime(WidgetRef ref) async {
  // TODO: Query user's activity patterns
  // Return the time they're most likely to engage
  return DateTime.now().add(const Duration(hours: 1));
}

/// Should send notification based on preferences
bool shouldSendNotification(
  WidgetRef ref, {
  required String notificationType,
}) {
  final globalEnabled = ref.read(pushNotificationsEnabledProvider);
  if (!globalEnabled) return false;

  // Check quiet hours
  if (isInQuietHours(ref)) {
    // Could make quiet hours exemptions per type
    return false;
  }

  // Check specific type
  switch (notificationType) {
    case 'rankChanged':
      return ref.read(enableRankChangePushProvider);
    case 'achievement':
      return ref.read(enableAchievementPushProvider);
    case 'streak':
      return ref.read(enableStreakMilestonePushProvider);
    case 'top10':
      return ref.read(enableTop10PushProvider);
    case 'dailyReminder':
      return ref.read(enableDailyReminderPushProvider);
    default:
      return true;
  }
}
