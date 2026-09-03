import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../services/english_town_analytics_service.dart';

/// Analytics service provider
final analyticsServiceProvider = Provider<EnglishTownAnalyticsService>((ref) {
  return EnglishTownAnalyticsService();
});

/// Get player analytics for specific period
final playerAnalyticsProvider =
    FutureProvider.family<PlayerAnalytics?, String>((ref, userId) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getPlayerAnalytics(userId);
});

/// Get engagement score for user
final engagementScoreProvider =
    FutureProvider.family<EngagementScore?, String>((ref, userId) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.calculateEngagementScore(userId);
});

/// Get daily metrics
final dailyMetricsProvider =
    FutureProvider.family<DailyMetrics?, DateTime>((ref, date) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getDailyMetrics(date);
});

/// Get user's recent events
final userEventsProvider =
    FutureProvider.family<List<AnalyticsEvent>, String>((ref, userId) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getUserEvents(userId, limit: 50);
});

/// Get events by type
final eventsByTypeProvider = FutureProvider.family<List<AnalyticsEvent>, AnalyticsEventType>(
  (ref, eventType) async {
    final service = ref.watch(analyticsServiceProvider);
    return await service.getEventsByType(eventType, limit: 50);
  },
);

/// Track event (action function)
Future<String> trackAnalyticsEvent(
  WidgetRef ref, {
  required String userId,
  required AnalyticsEventType type,
  required Map<String, dynamic> properties,
  String? sessionId,
  String? deviceId,
  int? xpGained,
  int? coinsGained,
  String? relatedUserId,
  String? relatedChallengeId,
  int? currentLevel,
  int? currentRank,
}) async {
  final service = ref.read(analyticsServiceProvider);
  return await service.trackEvent(
    userId,
    type,
    properties,
    sessionId: sessionId,
    deviceId: deviceId,
    xpGained: xpGained,
    coinsGained: coinsGained,
    relatedUserId: relatedUserId,
    relatedChallengeId: relatedChallengeId,
    currentLevel: currentLevel,
    currentRank: currentRank,
  );
}

/// Track conversation (helper)
Future<void> trackConversationEvent(
  WidgetRef ref, {
  required String userId,
  required String npcName,
  required bool success,
  required int xpGained,
  required Duration duration,
}) async {
  final service = ref.read(analyticsServiceProvider);
  await service.trackConversation(userId, npcName, success, xpGained, duration);
}

/// Track achievement (helper)
Future<void> trackAchievementEvent(
  WidgetRef ref, {
  required String userId,
  required String achievementId,
  required String title,
  required int rewardXp,
}) async {
  final service = ref.read(analyticsServiceProvider);
  await service.trackAchievement(userId, achievementId, title, rewardXp);
}

/// Track challenge (helper)
Future<void> trackChallengeEvent(
  WidgetRef ref, {
  required String userId,
  required String challengeId,
  required String action,
  required bool success,
}) async {
  final service = ref.read(analyticsServiceProvider);
  await service.trackChallenge(userId, challengeId, action, success);
}

/// Track rank change (helper)
Future<void> trackRankChangeEvent(
  WidgetRef ref, {
  required String userId,
  required int previousRank,
  required int currentRank,
}) async {
  final service = ref.read(analyticsServiceProvider);
  await service.trackRankChange(userId, previousRank, currentRank);
}

/// Track session end (helper)
Future<void> trackSessionEvent(
  WidgetRef ref, {
  required String userId,
  required Duration duration,
  required int eventCount,
}) async {
  final service = ref.read(analyticsServiceProvider);
  await service.trackSession(userId, duration, eventCount);
}
