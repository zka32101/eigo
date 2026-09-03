import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/english_town_firebase_service.dart';
import '../models/english_town_model.dart';

/// ==================== FIREBASE SERVICE PROVIDER ====================

/// Firebase service instance
final englishTownFirebaseServiceProvider = Provider<EnglishTownFirebaseService>((ref) {
  return EnglishTownFirebaseService();
});

/// Firebase initialization
final firebaseInitProvider = FutureProvider<void>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  await firebase.initialize();
});

// ==================== PROGRESS SYNC ====================

/// Sync town progress to cloud
final syncTownProgressProvider = FutureProvider.family<void, ({
  TownProgress progress,
  String displayName,
})>((ref, params) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  await firebase.syncTownProgress(
    progress: params.progress,
    displayName: params.displayName,
  );
});

/// Fetch town progress from cloud
final fetchTownProgressProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchTownProgress();
});

// ==================== STREAK TRACKING ====================

/// Update daily streak
final updateStreakProvider = FutureProvider.family<void, ({
  int currentStreak,
  int longestStreak,
  int totalDaysActive,
})>((ref, params) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  await firebase.updateStreak(
    currentStreak: params.currentStreak,
    longestStreak: params.longestStreak,
    totalDaysActive: params.totalDaysActive,
  );
});

/// Fetch current streak data
final fetchStreakProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchStreak();
});

/// Current streak display (derived from firestore)
final currentStreakProvider = FutureProvider<int>((ref) async {
  final streakData = await ref.watch(fetchStreakProvider.future);
  return streakData?['currentStreak'] ?? 0;
});

/// Longest streak (derived from firestore)
final longestStreakProvider = FutureProvider<int>((ref) async {
  final streakData = await ref.watch(fetchStreakProvider.future);
  return streakData?['longestStreak'] ?? 0;
});

/// Total active days (derived from firestore)
final totalActiveDaysProvider = FutureProvider<int>((ref) async {
  final streakData = await ref.watch(fetchStreakProvider.future);
  return streakData?['totalDaysActive'] ?? 0;
});

// ==================== ANALYTICS SYNC ====================

/// Record single conversation to analytics
final recordConversationProvider = FutureProvider.family<void, ({
  String npcId,
  String locationId,
  int xpEarned,
  int coinsEarned,
  int responseScore,
  ConversationDifficulty difficulty,
})>((ref, params) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  await firebase.recordConversation(
    npcId: params.npcId,
    locationId: params.locationId,
    xpEarned: params.xpEarned,
    coinsEarned: params.coinsEarned,
    responseScore: params.responseScore,
    difficulty: params.difficulty,
  );
});

/// Fetch today's analytics
final fetchTodayAnalyticsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchTodayAnalytics();
});

/// Fetch all-time analytics summary
final fetchAllTimeAnalyticsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchAllTimeAnalytics();
});

/// Today's conversation count
final todayConversationCountProvider = FutureProvider<int>((ref) async {
  final analytics = await ref.watch(fetchTodayAnalyticsProvider.future);
  return analytics?['conversationCount'] ?? 0;
});

/// Today's total XP earned
final todayXpEarnedProvider = FutureProvider<int>((ref) async {
  final analytics = await ref.watch(fetchTodayAnalyticsProvider.future);
  return analytics?['totalXpEarned'] ?? 0;
});

/// Today's average response score
final todayAverageScoreProvider = FutureProvider<double>((ref) async {
  final analytics = await ref.watch(fetchTodayAnalyticsProvider.future);
  if (analytics == null || analytics['conversationCount'] == 0) return 0.0;
  return (analytics['averageResponseScore'] ?? 0.0) / analytics['conversationCount'];
});

// ==================== LEADERBOARD ====================

/// Update user's leaderboard entry
final updateLeaderboardProvider = FutureProvider.family<void, ({
  String displayName,
  int totalXp,
  int totalConversations,
  int currentStreak,
})>((ref, params) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  await firebase.updateLeaderboardEntry(
    displayName: params.displayName,
    totalXp: params.totalXp,
    totalConversations: params.totalConversations,
    currentStreak: params.currentStreak,
  );
});

/// Fetch global leaderboard (top 50)
final globalLeaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchGlobalLeaderboard(limit: 50);
});

/// Fetch user's current rank
final userLeaderboardRankProvider = FutureProvider<int?>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchUserRank();
});

/// Top 10 leaderboard entries
final topLeaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final leaderboard = await ref.watch(globalLeaderboardProvider.future);
  return leaderboard.take(10).toList();
});

// ==================== ACHIEVEMENTS ====================

/// Record achievement unlock
final recordAchievementProvider = FutureProvider.family<void, ({
  String achievementId,
  String achievementTitle,
  int rewardXp,
})>((ref, params) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  await firebase.recordAchievementUnlock(
    achievementId: params.achievementId,
    achievementTitle: params.achievementTitle,
    rewardXp: params.rewardXp,
  );
});

/// Fetch all unlocked achievements
final unlockedAchievementsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchUnlockedAchievements();
});

/// Count of unlocked achievements
final unlockedAchievementCountProvider = FutureProvider<int>((ref) async {
  final achievements = await ref.watch(unlockedAchievementsProvider.future);
  return achievements.length;
});

// ==================== ENGAGEMENT ====================

/// Update engagement score in cloud
final updateEngagementScoreProvider = FutureProvider.family<void, ({
  int engagementScore,
  int totalSessions,
})>((ref, params) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  await firebase.updateEngagementScore(
    engagementScore: params.engagementScore,
    totalSessions: params.totalSessions,
  );
});

/// Fetch engagement metrics from cloud
final fetchEngagementMetricsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return await firebase.fetchEngagementMetrics();
});

/// Cloud engagement score
final cloudEngagementScoreProvider = FutureProvider<int>((ref) async {
  final metrics = await ref.watch(fetchEngagementMetricsProvider.future);
  return metrics?['engagementScore'] ?? 0;
});

/// Cloud total sessions
final cloudTotalSessionsProvider = FutureProvider<int>((ref) async {
  final metrics = await ref.watch(fetchEngagementMetricsProvider.future);
  return metrics?['totalSessions'] ?? 0;
});

// ==================== SYNC STATUS ====================

/// Whether cloud sync is available
final cloudSyncAvailableProvider = Provider<bool>((ref) {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return firebase.isAvailable;
});

/// Current user ID in cloud
final cloudUserIdProvider = Provider<String?>((ref) {
  final firebase = ref.watch(englishTownFirebaseServiceProvider);
  return firebase.userId;
});

/// Last sync timestamp (stored locally via StateProvider)
final lastCloudSyncProvider = StateProvider<DateTime?>((ref) => null);

/// Mark that sync just occurred
Future<void> markCloudSyncComplete(WidgetRef ref) async {
  ref.read(lastCloudSyncProvider.notifier).state = DateTime.now();
}
