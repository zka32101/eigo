import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/english_town_activity_feed_service.dart';

/// Activity feed service instance
final activityFeedServiceProvider =
    Provider<EnglishTownActivityFeedService>((ref) {
  return EnglishTownActivityFeedService();
});

/// Stream of all activities
final activityFeedProvider = StreamProvider<List<ActivityEvent>>((ref) async* {
  final service = ref.watch(activityFeedServiceProvider);

  // Emit current activities and update periodically
  while (true) {
    yield service.activities;
    await Future.delayed(const Duration(seconds: 2));
  }
});

/// Recent activities (last 20)
final recentActivitiesProvider = Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getRecentActivities(limit: 20);
});

/// Today's activities
final todayActivitiesProvider = Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitiesSince(const Duration(hours: 24));
});

/// Activities from the last hour
final recentHourActivitiesProvider =
    Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitiesSince(const Duration(hours: 1));
});

/// Conversation activities
final conversationActivitiesProvider =
    Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitiesByType(ActivityEventType.conversation);
});

/// Achievement activities
final achievementActivitiesProvider =
    Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitiesByType(ActivityEventType.achievementUnlocked);
});

/// Streak activities
final streakActivitiesProvider = Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitiesByType(ActivityEventType.streakMilestone);
});

/// Rank change activities
final rankChangeActivitiesProvider =
    Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitiesByType(ActivityEventType.rankChange);
});

/// Challenge completion activities
final challengeActivitiesProvider =
    Provider<List<ActivityEvent>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitiesByType(ActivityEventType.challengeCompleted);
});

/// Count of today's conversations
final todayConversationCountProvider = Provider<int>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service
      .getActivitiesSince(const Duration(hours: 24))
      .where((a) => a.type == ActivityEventType.conversation)
      .length;
});

/// Count of today's achievements
final todayAchievementCountProvider = Provider<int>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service
      .getActivitiesSince(const Duration(hours: 24))
      .where((a) => a.type == ActivityEventType.achievementUnlocked)
      .length;
});

/// Activity summary for today
final todayActivitySummaryProvider =
    Provider<Map<String, int>>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.getActivitySummary(timeRange: const Duration(hours: 24));
});

/// Check if milestone achieved (e.g., 5 conversations today)
final conversationMilestoneProvider = Provider<bool>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.checkMilestone(
    ActivityEventType.conversation,
    5,
    timeRange: const Duration(hours: 24),
  );
});

/// Check if achievement milestone achieved (3 achievements today)
final achievementMilestoneProvider = Provider<bool>((ref) {
  final service = ref.watch(activityFeedServiceProvider);
  return service.checkMilestone(
    ActivityEventType.achievementUnlocked,
    3,
    timeRange: const Duration(hours: 24),
  );
});

/// Record a conversation activity
Future<void> recordConversationActivity(
  WidgetRef ref, {
  required String userId,
  required String playerName,
  required String npcName,
  required String locationName,
  required int xpEarned,
  required int difficulty,
}) async {
  final service = ref.read(activityFeedServiceProvider);
  service.recordConversation(
    userId: userId,
    playerName: playerName,
    npcName: npcName,
    locationName: locationName,
    xpEarned: xpEarned,
    difficulty: difficulty,
  );
}

/// Record an achievement unlock activity
Future<void> recordAchievementActivity(
  WidgetRef ref, {
  required String userId,
  required String playerName,
  required String achievementTitle,
  required String achievementDescription,
  required int rewardXp,
}) async {
  final service = ref.read(activityFeedServiceProvider);
  service.recordAchievementUnlock(
    userId: userId,
    playerName: playerName,
    achievementTitle: achievementTitle,
    achievementDescription: achievementDescription,
    rewardXp: rewardXp,
  );
}

/// Record a streak milestone activity
Future<void> recordStreakActivity(
  WidgetRef ref, {
  required String userId,
  required String playerName,
  required int streakDays,
  required int milestone,
}) async {
  final service = ref.read(activityFeedServiceProvider);
  service.recordStreakMilestone(
    userId: userId,
    playerName: playerName,
    streakDays: streakDays,
    milestone: milestone,
  );
}

/// Record a rank change activity
Future<void> recordRankChangeActivity(
  WidgetRef ref, {
  required String userId,
  required String playerName,
  required int previousRank,
  required int currentRank,
}) async {
  final service = ref.read(activityFeedServiceProvider);
  service.recordRankChange(
    userId: userId,
    playerName: playerName,
    previousRank: previousRank,
    currentRank: currentRank,
  );
}

/// Record a challenge completion activity
Future<void> recordChallengeActivity(
  WidgetRef ref, {
  required String userId,
  required String playerName,
  required String challengeTitle,
  required int xpReward,
}) async {
  final service = ref.read(activityFeedServiceProvider);
  service.recordChallengeCompletion(
    userId: userId,
    playerName: playerName,
    challengeTitle: challengeTitle,
    xpReward: xpReward,
  );
}
