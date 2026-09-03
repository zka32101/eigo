import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/english_town_fcm_service.dart';

/// Firebase Cloud Messaging service instance
final fcmServiceProvider = Provider<EnglishTownFCMService>((ref) {
  return EnglishTownFCMService();
});

/// FCM initialization
final fcmInitProvider = FutureProvider<void>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);

  if (fcmService.isInitialized) return;

  // Initialize FCM and request permissions
  await fcmService.initialize();
  await fcmService.requestNotificationPermission();

  // Get and store token
  final token = await fcmService.getToken();
  if (token != null) {
    // TODO: Store token to Firestore
    print('[FCM Provider] Token obtained: ${token.substring(0, 20)}...');
  }
});

/// Get current FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);

  // Ensure initialized first
  await ref.watch(fcmInitProvider.future);

  return await fcmService.getToken();
});

/// Check if notifications are enabled
final fcmNotificationsEnabledProvider =
    FutureProvider<bool>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);

  // Ensure initialized first
  await ref.watch(fcmInitProvider.future);

  return await fcmService.areNotificationsEnabled();
});

/// FCM initialization state
final fcmInitializedProvider = StateProvider<bool>((ref) => false);

/// Subscribe to a topic after initialization
Future<void> subscribeToFCMTopic(WidgetRef ref, String topic) async {
  final fcmService = ref.read(fcmServiceProvider);

  // Ensure initialized
  await ref.watch(fcmInitProvider.future);

  await fcmService.subscribeToTopic(topic);
}

/// Unsubscribe from a topic
Future<void> unsubscribeFromFCMTopic(WidgetRef ref, String topic) async {
  final fcmService = ref.read(fcmServiceProvider);

  // Ensure initialized
  await ref.watch(fcmInitProvider.future);

  await fcmService.unsubscribeFromTopic(topic);
}

// ==================== TOPIC SUBSCRIPTIONS ====================

/// Subscribe users to topics based on their tier/achievements
class FCMTopicManager {
  /// Topic for all users
  static const String allUsers = 'announcements';

  /// Topic for top 10 users
  static const String topTen = 'top_10_players';

  /// Topic for top 50 users
  static const String top50 = 'top_50_players';

  /// Topic for achievement milestones
  static const String achievements = 'achievements';

  /// Topic for daily reminders
  static const String dailyReminders = 'daily_reminders';

  /// Topic for rank changes
  static const String rankUpdates = 'rank_updates';

  /// Topic for special events
  static const String events = 'special_events';

  /// Subscribe to default topics for all users
  static Future<void> subscribeToDefaultTopics(WidgetRef ref) async {
    await subscribeToFCMTopic(ref, allUsers);
    await subscribeToFCMTopic(ref, dailyReminders);
  }

  /// Subscribe to top-tier topics if rank qualifies
  static Future<void> updateTopicsForRank(
    WidgetRef ref, {
    required int currentRank,
  }) async {
    if (currentRank <= 10) {
      await subscribeToFCMTopic(ref, topTen);
    } else {
      await unsubscribeFromFCMTopic(ref, topTen);
    }

    if (currentRank <= 50) {
      await subscribeToFCMTopic(ref, top50);
    } else {
      await unsubscribeFromFCMTopic(ref, top50);
    }
  }

  /// Update topics based on achievements
  static Future<void> updateTopicsForAchievements(
    WidgetRef ref, {
    required List<String> unlockedAchievements,
  }) async {
    if (unlockedAchievements.isNotEmpty) {
      await subscribeToFCMTopic(ref, achievements);
    }
  }
}
