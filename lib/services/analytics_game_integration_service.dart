import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../providers/analytics_provider.dart';
import 'english_town_analytics_service.dart';

/// Service to integrate analytics tracking with core game mechanics
class AnalyticsGameIntegrationService {
  static final AnalyticsGameIntegrationService _instance =
      AnalyticsGameIntegrationService._internal();

  factory AnalyticsGameIntegrationService() {
    return _instance;
  }

  AnalyticsGameIntegrationService._internal();

  /// Track conversation completion event
  Future<void> trackConversationCompletion(
    WidgetRef ref, {
    required String userId,
    required String npcName,
    required bool success,
    required int xpGained,
    required Duration duration,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackConversation(
        userId: userId,
        npcName: npcName,
        success: success,
        xpGained: xpGained,
        duration: duration,
      );

      print('[Analytics] Conversation tracked: $userId with $npcName');
    } catch (e) {
      print('[Analytics] Error tracking conversation: $e');
    }
  }

  /// Track achievement unlock event
  Future<void> trackAchievementUnlock(
    WidgetRef ref, {
    required String userId,
    required String achievementId,
    required String achievementTitle,
    required int rewardXp,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackAchievement(
        userId: userId,
        achievementId: achievementId,
        title: achievementTitle,
        rewardXp: rewardXp,
      );

      print('[Analytics] Achievement tracked: $userId unlocked $achievementTitle');
    } catch (e) {
      print('[Analytics] Error tracking achievement: $e');
    }
  }

  /// Track leaderboard rank change event
  Future<void> trackRankChange(
    WidgetRef ref, {
    required String userId,
    required int previousRank,
    required int currentRank,
    required int totalXp,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackRankChange(
        userId: userId,
        previousRank: previousRank,
        currentRank: currentRank,
        totalXp: totalXp,
      );

      print('[Analytics] Rank change tracked: $userId #$previousRank → #$currentRank');
    } catch (e) {
      print('[Analytics] Error tracking rank change: $e');
    }
  }

  /// Track multiplayer challenge completion
  Future<void> trackChallengeCompletion(
    WidgetRef ref, {
    required String userId,
    required String challengeId,
    required String challengeTitle,
    required bool isWinner,
    required int? xpReward,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackChallenge(
        userId: userId,
        challengeId: challengeId,
        action: 'completed',
        success: isWinner,
        xpEarned: xpReward,
      );

      print('[Analytics] Challenge tracked: $userId completed $challengeTitle');
    } catch (e) {
      print('[Analytics] Error tracking challenge: $e');
    }
  }

  /// Track challenge start/join event
  Future<void> trackChallengeStart(
    WidgetRef ref, {
    required String userId,
    required String challengeId,
    required String challengeTitle,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackEvent(
        userId: userId,
        eventType: AnalyticsEventType.challengeStarted,
        properties: {
          'challengeId': challengeId,
          'challengeTitle': challengeTitle,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('[Analytics] Challenge start tracked: $userId started $challengeTitle');
    } catch (e) {
      print('[Analytics] Error tracking challenge start: $e');
    }
  }

  /// Track session start (app opened)
  Future<String?> trackSessionStart(
    WidgetRef ref, {
    required String userId,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      final sessionId = await analytics.trackEvent(
        userId: userId,
        eventType: AnalyticsEventType.sessionStarted,
        properties: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('[Analytics] Session started: $userId - $sessionId');
      return sessionId;
    } catch (e) {
      print('[Analytics] Error tracking session start: $e');
      return null;
    }
  }

  /// Track session end (app closed)
  Future<void> trackSessionEnd(
    WidgetRef ref, {
    required String userId,
    required Duration sessionDuration,
    required int eventCount,
    String? sessionId,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackSession(
        userId: userId,
        duration: sessionDuration,
        eventsCount: eventCount,
        sessionId: sessionId,
      );

      print('[Analytics] Session ended: $userId - duration: ${sessionDuration.inMinutes}m');
    } catch (e) {
      print('[Analytics] Error tracking session end: $e');
    }
  }

  /// Track streak milestone
  Future<void> trackStreakMilestone(
    WidgetRef ref, {
    required String userId,
    required int streakDays,
    required int xpReward,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackEvent(
        userId: userId,
        eventType: AnalyticsEventType.streakMilestone,
        properties: {
          'streakDays': streakDays,
          'xpReward': xpReward,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('[Analytics] Streak milestone tracked: $userId - $streakDays days');
    } catch (e) {
      print('[Analytics] Error tracking streak milestone: $e');
    }
  }

  /// Track login activity
  Future<void> trackDailyLogin(
    WidgetRef ref, {
    required String userId,
    required int loginStreak,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackEvent(
        userId: userId,
        eventType: AnalyticsEventType.dailyLoginMilestone,
        properties: {
          'loginStreak': loginStreak,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('[Analytics] Daily login tracked: $userId - streak: $loginStreak');
    } catch (e) {
      print('[Analytics] Error tracking daily login: $e');
    }
  }

  /// Track in-app purchase
  Future<void> trackPurchase(
    WidgetRef ref, {
    required String userId,
    required String itemId,
    required String itemName,
    required int amount,
    required String currency,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackPurchase(
        userId: userId,
        itemId: itemId,
        amount: amount,
        currency: currency,
        itemName: itemName,
      );

      print('[Analytics] Purchase tracked: $userId - $itemName for $amount $currency');
    } catch (e) {
      print('[Analytics] Error tracking purchase: $e');
    }
  }

  /// Track generic event with custom properties
  Future<void> trackCustomEvent(
    WidgetRef ref, {
    required String userId,
    required AnalyticsEventType eventType,
    required Map<String, dynamic> properties,
    String? sessionId,
  }) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);

      await analytics.trackEvent(
        userId: userId,
        eventType: eventType,
        properties: properties,
        sessionId: sessionId,
      );

      print('[Analytics] Custom event tracked: $userId - ${eventType.toString()}');
    } catch (e) {
      print('[Analytics] Error tracking custom event: $e');
    }
  }
}

/// Provider for analytics game integration service
final analyticsGameIntegrationProvider =
    Provider<AnalyticsGameIntegrationService>((ref) {
  return AnalyticsGameIntegrationService();
});

// ===== Helper Functions for Integration Points =====

/// Record conversation completion - call after successful conversation
Future<void> recordConversationAnalytics(
  WidgetRef ref, {
  required String userId,
  required String npcName,
  required bool success,
  required int xpGained,
  required Duration duration,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackConversationCompletion(
    ref,
    userId: userId,
    npcName: npcName,
    success: success,
    xpGained: xpGained,
    duration: duration,
  );
}

/// Record achievement unlock - call when achievement is unlocked
Future<void> recordAchievementAnalytics(
  WidgetRef ref, {
  required String userId,
  required String achievementId,
  required String achievementTitle,
  required int rewardXp,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackAchievementUnlock(
    ref,
    userId: userId,
    achievementId: achievementId,
    achievementTitle: achievementTitle,
    rewardXp: rewardXp,
  );
}

/// Record rank change - call when user's leaderboard rank changes
Future<void> recordRankChangeAnalytics(
  WidgetRef ref, {
  required String userId,
  required int previousRank,
  required int currentRank,
  required int totalXp,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackRankChange(
    ref,
    userId: userId,
    previousRank: previousRank,
    currentRank: currentRank,
    totalXp: totalXp,
  );
}

/// Record challenge completion - call when multiplayer challenge ends
Future<void> recordChallengeCompletionAnalytics(
  WidgetRef ref, {
  required String userId,
  required String challengeId,
  required String challengeTitle,
  required bool isWinner,
  required int? xpReward,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackChallengeCompletion(
    ref,
    userId: userId,
    challengeId: challengeId,
    challengeTitle: challengeTitle,
    isWinner: isWinner,
    xpReward: xpReward,
  );
}

/// Record challenge start - call when user joins/starts a challenge
Future<void> recordChallengeStartAnalytics(
  WidgetRef ref, {
  required String userId,
  required String challengeId,
  required String challengeTitle,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackChallengeStart(
    ref,
    userId: userId,
    challengeId: challengeId,
    challengeTitle: challengeTitle,
  );
}

/// Record session start - call when app is opened
Future<String?> recordSessionStartAnalytics(
  WidgetRef ref, {
  required String userId,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  return await integration.trackSessionStart(
    ref,
    userId: userId,
  );
}

/// Record session end - call when app is closed
Future<void> recordSessionEndAnalytics(
  WidgetRef ref, {
  required String userId,
  required Duration sessionDuration,
  required int eventCount,
  String? sessionId,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackSessionEnd(
    ref,
    userId: userId,
    sessionDuration: sessionDuration,
    eventCount: eventCount,
    sessionId: sessionId,
  );
}

/// Record streak milestone - call when streak reaches 7, 14, 30, 60, 100, 365 days
Future<void> recordStreakMilestoneAnalytics(
  WidgetRef ref, {
  required String userId,
  required int streakDays,
  required int xpReward,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackStreakMilestone(
    ref,
    userId: userId,
    streakDays: streakDays,
    xpReward: xpReward,
  );
}

/// Record daily login - call when user logs in
Future<void> recordDailyLoginAnalytics(
  WidgetRef ref, {
  required String userId,
  required int loginStreak,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackDailyLogin(
    ref,
    userId: userId,
    loginStreak: loginStreak,
  );
}

/// Record in-app purchase - call when user makes purchase
Future<void> recordPurchaseAnalytics(
  WidgetRef ref, {
  required String userId,
  required String itemId,
  required String itemName,
  required int amount,
  required String currency,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackPurchase(
    ref,
    userId: userId,
    itemId: itemId,
    itemName: itemName,
    amount: amount,
    currency: currency,
  );
}

/// Record custom event - call for game-specific events
Future<void> recordCustomAnalyticsEvent(
  WidgetRef ref, {
  required String userId,
  required AnalyticsEventType eventType,
  required Map<String, dynamic> properties,
  String? sessionId,
}) async {
  final integration = ref.read(analyticsGameIntegrationProvider);
  await integration.trackCustomEvent(
    ref,
    userId: userId,
    eventType: eventType,
    properties: properties,
    sessionId: sessionId,
  );
}
