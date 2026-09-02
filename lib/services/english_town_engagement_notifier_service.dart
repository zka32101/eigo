import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/english_town_notification_service.dart';
import '../providers/english_town_notification_provider.dart';
import '../providers/english_town_activity_feed_provider.dart';

/// Service that triggers notifications and activities based on game events
class EnglishTownEngagementNotifierService {
  static final EnglishTownEngagementNotifierService _instance =
      EnglishTownEngagementNotifierService._internal();

  factory EnglishTownEngagementNotifierService() {
    return _instance;
  }

  EnglishTownEngagementNotifierService._internal();

  /// Handle achievement unlock and create notifications/activities
  Future<void> onAchievementUnlocked(
    WidgetRef ref, {
    required String userId,
    required String playerName,
    required String achievementTitle,
    required String achievementDescription,
    required int rewardXp,
  }) async {
    final notificationService = ref.read(notificationServiceProvider);
    final enableNotifications =
        ref.read(enableAchievementNotificationsProvider);

    // Create notification
    if (enableNotifications) {
      final notification = notificationService.createAchievementNotification(
        achievementTitle: achievementTitle,
        rewardXp: rewardXp,
      );
      notificationService.addNotification(notification);
    }

    // Record activity
    await recordAchievementActivity(
      ref,
      userId: userId,
      playerName: playerName,
      achievementTitle: achievementTitle,
      achievementDescription: achievementDescription,
      rewardXp: rewardXp,
    );
  }

  /// Handle streak milestone and create notifications/activities
  Future<void> onStreakMilestone(
    WidgetRef ref, {
    required String userId,
    required String playerName,
    required int streakDays,
    required int milestone,
  }) async {
    final notificationService = ref.read(notificationServiceProvider);
    final enableNotifications =
        ref.read(enableStreakNotificationsProvider);

    // Create notification only for key milestones (3, 7, 14, 30, 60, 100)
    if (enableNotifications &&
        (streakDays == 3 ||
            streakDays == 7 ||
            streakDays == 14 ||
            streakDays == 30 ||
            streakDays == 60 ||
            streakDays == 100)) {
      final notification = notificationService.createStreakNotification(
        streakDays: streakDays,
        milestone: milestone,
      );
      notificationService.addNotification(notification);
    }

    // Record activity
    await recordStreakActivity(
      ref,
      userId: userId,
      playerName: playerName,
      streakDays: streakDays,
      milestone: milestone,
    );
  }

  /// Handle rank change and create notifications/activities
  Future<void> onRankChange(
    WidgetRef ref, {
    required String userId,
    required String playerName,
    required int previousRank,
    required int currentRank,
  }) async {
    final notificationService = ref.read(notificationServiceProvider);
    final enableRankNotifications =
        ref.read(enableRankChangeNotificationsProvider);
    final threshold = ref.read(rankChangeNotificationThresholdProvider);

    final rankDiff = (previousRank - currentRank).abs();

    // Create notification if threshold is met
    if (enableRankNotifications && rankDiff >= threshold) {
      final notification =
          notificationService.createRankChangeNotification(
        previousRank: previousRank,
        currentRank: currentRank,
        playerName: playerName,
      );
      notificationService.addNotification(notification);
    }

    // Check for top 10 achievement
    if (currentRank <= 10 && previousRank > 10) {
      if (ref.read(enableTopLeaderboardNotificationsProvider)) {
        final topNotification = notificationService
            .createTopLeaderboardNotification(rank: currentRank);
        notificationService.addNotification(topNotification);
      }
    }

    // Record activity
    await recordRankChangeActivity(
      ref,
      userId: userId,
      playerName: playerName,
      previousRank: previousRank,
      currentRank: currentRank,
    );
  }

  /// Handle conversation completion and create activity
  Future<void> onConversationComplete(
    WidgetRef ref, {
    required String userId,
    required String playerName,
    required String npcName,
    required String locationName,
    required int xpEarned,
    required int difficulty,
  }) async {
    // Record activity
    await recordConversationActivity(
      ref,
      userId: userId,
      playerName: playerName,
      npcName: npcName,
      locationName: locationName,
      xpEarned: xpEarned,
      difficulty: difficulty,
    );
  }

  /// Handle challenge completion and create notifications/activities
  Future<void> onChallengeComplete(
    WidgetRef ref, {
    required String userId,
    required String playerName,
    required String challengeTitle,
    required int xpReward,
  }) async {
    final notificationService = ref.read(notificationServiceProvider);
    final enableNotifications =
        ref.read(enableDailyChallengeNotificationsProvider);

    // Create notification
    if (enableNotifications) {
      final notification = notificationService.createDailyChallengeNotification(
        challengeTitle: challengeTitle,
        xpReward: xpReward,
      );
      notificationService.addNotification(notification);
    }

    // Record activity
    await recordChallengeActivity(
      ref,
      userId: userId,
      playerName: playerName,
      challengeTitle: challengeTitle,
      xpReward: xpReward,
    );
  }

  /// Handle multiple daily conversations milestone
  Future<void> onDailyConversationMilestone(
    WidgetRef ref, {
    required String userId,
    required String playerName,
    required int count,
  }) async {
    final notificationService = ref.read(notificationServiceProvider);

    // Create special notification for 5, 10, 15 daily conversations
    if (count == 5 || count == 10 || count == 15) {
      final notification = notificationService.addNotification(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NotificationType.dailyChallenge,
          title: '🔥 Amazing Performance!',
          body: 'You\'ve completed $count conversations today!',
          data: {
            'count': count,
          },
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  /// Batch check for milestone notifications
  Future<void> checkMilestones(WidgetRef ref, {required String userId}) async {
    // This would check various milestone conditions and trigger notifications
    // Examples:
    // - First achievement
    // - 100 total conversations
    // - All locations visited
    // - Etc.
  }
}
