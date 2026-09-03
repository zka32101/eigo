import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/english_town_model.dart';
import 'english_town_provider.dart';
import 'english_town_firebase_provider.dart';
import 'english_town_polish_provider.dart';

/// ==================== AUTO-SYNC PROVIDERS ====================

/// Auto-sync progress to cloud whenever it changes
/// This provider watches the local progress and syncs to Firebase
final autoSyncProgressProvider = FutureProvider<void>((ref) async {
  final progress = ref.watch(townProgressProvider);
  final firebaseAvailable = ref.watch(cloudSyncAvailableProvider);

  if (!firebaseAvailable) return;

  // Sync progress to Firebase (with display name placeholder)
  await ref.watch(syncTownProgressProvider((
    progress: progress,
    displayName: 'Player ${progress.totalConversations}',
  )).future);
});

/// Auto-sync leaderboard entry whenever progress changes
final autoSyncLeaderboardProvider = FutureProvider<void>((ref) async {
  final progress = ref.watch(townProgressProvider);
  final firebaseAvailable = ref.watch(cloudSyncAvailableProvider);

  if (!firebaseAvailable) return;

  // Update leaderboard entry with current stats
  await ref.watch(updateLeaderboardProvider((
    displayName: 'Player ${progress.totalConversations}',
    totalXp: progress.totalXpEarned,
    totalConversations: progress.totalConversations,
    currentStreak: 0, // TODO: Get from streak provider
  )).future);
});

/// Auto-sync engagement score periodically
final autoSyncEngagementProvider = FutureProvider<void>((ref) async {
  final score = ref.watch(engagementScoreProvider);
  final firebaseAvailable = ref.watch(cloudSyncAvailableProvider);

  if (!firebaseAvailable) return;

  // Sync engagement score to cloud
  await ref.watch(updateEngagementScoreProvider((
    engagementScore: score,
    totalSessions: 0, // TODO: Track sessions
  )).future);
});

/// Record a conversation to cloud analytics
Future<void> recordConversationToCloud(
  WidgetRef ref, {
  required String npcId,
  required String locationId,
  required int xpEarned,
  required int coinsEarned,
  required int responseScore,
  required ConversationDifficulty difficulty,
}) async {
  final firebaseAvailable = ref.read(cloudSyncAvailableProvider);

  if (!firebaseAvailable) return;

  await ref.read(recordConversationProvider((
    npcId: npcId,
    locationId: locationId,
    xpEarned: xpEarned,
    coinsEarned: coinsEarned,
    responseScore: responseScore,
    difficulty: difficulty,
  )).future);
}

/// Record achievement unlock to cloud
Future<void> recordAchievementToCloud(
  WidgetRef ref, {
  required String achievementId,
  required String achievementTitle,
  required int rewardXp,
}) async {
  final firebaseAvailable = ref.read(cloudSyncAvailableProvider);

  if (!firebaseAvailable) return;

  await ref.read(recordAchievementProvider((
    achievementId: achievementId,
    achievementTitle: achievementTitle,
    rewardXp: rewardXp,
  )).future);
}

/// Update streak in cloud
Future<void> updateStreakInCloud(
  WidgetRef ref, {
  required int currentStreak,
  required int longestStreak,
  required int totalDaysActive,
}) async {
  final firebaseAvailable = ref.read(cloudSyncAvailableProvider);

  if (!firebaseAvailable) return;

  await ref.read(updateStreakProvider((
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalDaysActive: totalDaysActive,
  )).future);
}

// ==================== SYNC STATUS MONITORING ====================

/// Monitor if cloud sync is currently working
final cloudSyncStatusProvider = StateProvider<CloudSyncStatus>((ref) {
  return CloudSyncStatus.idle;
});

/// Possible cloud sync statuses
enum CloudSyncStatus {
  idle,
  syncing,
  success,
  error,
}

/// Get human-readable sync status
String getCloudSyncStatusText(CloudSyncStatus status) {
  switch (status) {
    case CloudSyncStatus.idle:
      return 'Ready';
    case CloudSyncStatus.syncing:
      return 'Syncing...';
    case CloudSyncStatus.success:
      return 'Synced';
    case CloudSyncStatus.error:
      return 'Sync failed';
  }
}

/// Get color for sync status
Color getCloudSyncStatusColor(CloudSyncStatus status) {
  switch (status) {
    case CloudSyncStatus.idle:
      return Colors.grey;
    case CloudSyncStatus.syncing:
      return Colors.blue;
    case CloudSyncStatus.success:
      return Colors.green;
    case CloudSyncStatus.error:
      return Colors.red;
  }
}

// ==================== BACKUP & RESTORE ====================

/// Backup current local progress to cloud
Future<void> backupProgressToCloud(WidgetRef ref) async {
  try {
    ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.syncing;

    final progress = ref.read(townProgressProvider);
    const displayName = 'Backed up Player';

    await ref.read(syncTownProgressProvider((
      progress: progress,
      displayName: displayName,
    )).future);

    ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.success;
  } catch (e) {
    print('Backup error: $e');
    ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.error;
  }
}

/// Restore progress from cloud to local
Future<void> restoreProgressFromCloud(WidgetRef ref) async {
  try {
    ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.syncing;

    final cloudProgress = await ref.read(fetchTownProgressProvider.future);

    if (cloudProgress == null) {
      throw Exception('No cloud progress found');
    }

    // TODO: Merge cloud progress into local state
    // This requires updating the TownProgressNotifier

    ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.success;
  } catch (e) {
    print('Restore error: $e');
    ref.read(cloudSyncStatusProvider.notifier).state = CloudSyncStatus.error;
  }
}

// ==================== PROFILE MANAGEMENT ====================

/// Get or create user profile in cloud
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = ref.watch(cloudUserIdProvider);

  if (userId == null) return null;

  // TODO: Fetch user profile from Firebase
  // For now, return a placeholder
  return {
    'userId': userId,
    'displayName': 'Player',
    'createdAt': DateTime.now().toIso8601String(),
  };
});

/// Update user display name
Future<void> updateUserDisplayName(
  WidgetRef ref,
  String newDisplayName,
) async {
  final firebaseAvailable = ref.read(cloudSyncAvailableProvider);

  if (!firebaseAvailable) return;

  // TODO: Update user profile with new display name
}

// ==================== SYNC HISTORY ====================

/// Track when last sync occurred
final lastSyncTimeProvider = StateProvider<DateTime?>((ref) => null);

/// Get time elapsed since last sync
String getTimeSinceLastSync(DateTime? lastSync) {
  if (lastSync == null) return 'Never';

  final now = DateTime.now();
  final difference = now.difference(lastSync);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}

/// Pending sync items counter
final pendingSyncItemsProvider = StateProvider<int>((ref) => 0);
