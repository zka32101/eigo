import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_social_model.dart';
import '../providers/english_town_social_provider.dart';
import 'english_town_social_service.dart';
import 'english_town_engagement_notifier_service.dart';

/// Service to integrate social features with core game mechanics
class SocialGameIntegrationService {
  static final SocialGameIntegrationService _instance =
      SocialGameIntegrationService._internal();

  factory SocialGameIntegrationService() {
    return _instance;
  }

  SocialGameIntegrationService._internal();

  /// Record activity when user completes a conversation
  Future<void> recordConversationActivity(
    WidgetRef ref, {
    required String userId,
    required String displayName,
    required String npcName,
    required String location,
    required int xpGained,
  }) async {
    try {
      final socialService = ref.read(socialServiceProvider);

      await socialService.recordFriendActivity(
        userId: userId,
        displayName: displayName,
        type: FriendActivityType.conversation,
        title: '$displayName talked to $npcName',
        description: 'Had a conversation with $npcName at $location',
        relatedId: npcName,
        xpGained: xpGained,
      );

      // Notify friends if privacy settings allow
      final showConversations = ref.read(showConversationsOnFeedProvider);
      if (showConversations) {
        // TODO: Send push notifications to friends
      }
    } catch (e) {
      print('[SocialIntegration] Error recording conversation activity: $e');
    }
  }

  /// Record activity when user unlocks an achievement
  Future<void> recordAchievementUnlockedActivity(
    WidgetRef ref, {
    required String userId,
    required String displayName,
    required String achievementTitle,
    required int rewardXp,
    String? achievementId,
  }) async {
    try {
      final socialService = ref.read(socialServiceProvider);

      await socialService.recordFriendActivity(
        userId: userId,
        displayName: displayName,
        type: FriendActivityType.achievementUnlocked,
        title: '$displayName unlocked $achievementTitle',
        description: 'Unlocked achievement: $achievementTitle',
        relatedId: achievementId,
        xpGained: rewardXp,
      );

      // Notify friends if privacy settings allow
      final showAchievements = ref.read(showAchievementsOnFeedProvider);
      if (showAchievements) {
        // TODO: Send push notifications to friends
      }
    } catch (e) {
      print('[SocialIntegration] Error recording achievement activity: $e');
    }
  }

  /// Record activity when user reaches a streak milestone
  Future<void> recordStreakMilestoneActivity(
    WidgetRef ref, {
    required String userId,
    required String displayName,
    required int streakDays,
    required int xpReward,
  }) async {
    try {
      final socialService = ref.read(socialServiceProvider);

      await socialService.recordFriendActivity(
        userId: userId,
        displayName: displayName,
        type: FriendActivityType.streakMilestone,
        title: '$displayName reached a $streakDays day streak',
        description: 'Reached $streakDays consecutive days of learning!',
        xpGained: xpReward,
      );

      // Notify friends if privacy settings allow
      await _notifyFriendsOfStreakMilestone(ref, userId, displayName, streakDays);
    } catch (e) {
      print('[SocialIntegration] Error recording streak milestone: $e');
    }
  }

  /// Record activity when user changes rank
  Future<void> recordRankChangeActivity(
    WidgetRef ref, {
    required String userId,
    required String displayName,
    required int previousRank,
    required int currentRank,
    required int rankChange,
  }) async {
    try {
      final socialService = ref.read(socialServiceProvider);

      final direction = rankChange > 0 ? 'climbed' : 'dropped';
      final distance = rankChange.abs();

      await socialService.recordFriendActivity(
        userId: userId,
        displayName: displayName,
        type: FriendActivityType.rankChange,
        title: '$displayName $direction $distance positions!',
        description: 'New rank: #$currentRank (was #$previousRank)',
      );

      // Notify friends if privacy settings allow and user is top 50
      if (currentRank <= 50) {
        // TODO: Send push notifications to friends
      }
    } catch (e) {
      print('[SocialIntegration] Error recording rank change: $e');
    }
  }

  /// Record activity when user completes a multiplayer challenge
  Future<void> recordChallengeCompletedActivity(
    WidgetRef ref, {
    required String userId,
    required String displayName,
    required String challengeTitle,
    required bool isWinner,
    required int? xpReward,
  }) async {
    try {
      final socialService = ref.read(socialServiceProvider);

      await socialService.recordFriendActivity(
        userId: userId,
        displayName: displayName,
        type: FriendActivityType.challengeCompleted,
        title: '$displayName completed "$challengeTitle" challenge${isWinner ? ' and won!' : ''}',
        description: isWinner
            ? 'Won the "$challengeTitle" challenge!'
            : 'Completed the "$challengeTitle" challenge',
        xpGained: xpReward,
      );

      // Notify friends if privacy settings allow
      final showChallenges = ref.read(showChallengesOnFeedProvider);
      if (showChallenges) {
        // TODO: Send push notifications to friends
      }
    } catch (e) {
      print('[SocialIntegration] Error recording challenge completion: $e');
    }
  }

  /// Record activity when user starts a multiplayer challenge
  Future<void> recordChallengeStartedActivity(
    WidgetRef ref, {
    required String userId,
    required String displayName,
    required String challengeTitle,
  }) async {
    try {
      final socialService = ref.read(socialServiceProvider);

      await socialService.recordFriendActivity(
        userId: userId,
        displayName: displayName,
        type: FriendActivityType.challengeStarted,
        title: '$displayName started "$challengeTitle"',
        description: 'Started a new multiplayer challenge',
      );
    } catch (e) {
      print('[SocialIntegration] Error recording challenge start: $e');
    }
  }

  /// Update challenge progress during gameplay
  Future<void> updateChallengeProgress(
    WidgetRef ref, {
    required String challengeId,
    required String userId,
    required int newProgress,
  }) async {
    try {
      final socialService = ref.read(socialServiceProvider);
      await socialService.updateChallengeProgress(
        challengeId,
        userId,
        newProgress,
      );
    } catch (e) {
      print('[SocialIntegration] Error updating challenge progress: $e');
    }
  }

  /// Helper: Notify friends about streak milestone
  Future<void> _notifyFriendsOfStreakMilestone(
    WidgetRef ref,
    String userId,
    String displayName,
    int streakDays,
  ) async {
    // Only notify on milestone days (7, 14, 30, 60, 100, etc.)
    final isMilestone = _isStreakMilestone(streakDays);

    if (isMilestone) {
      // TODO: Send notifications to friends subscribed to streak updates
    }
  }

  /// Helper: Check if a streak day is a milestone
  bool _isStreakMilestone(int days) {
    const milestones = [7, 14, 21, 30, 60, 90, 100, 365];
    return milestones.contains(days);
  }
}

/// Provider for social game integration service
final socialGameIntegrationProvider =
    Provider<SocialGameIntegrationService>((ref) {
  return SocialGameIntegrationService();
});

/// Record conversation activity - call this after each successful conversation
Future<void> recordConversationInSocial(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required String npcName,
  required String location,
  required int xpGained,
}) async {
  final integration = ref.read(socialGameIntegrationProvider);
  await integration.recordConversationActivity(
    ref,
    userId: userId,
    displayName: displayName,
    npcName: npcName,
    location: location,
    xpGained: xpGained,
  );
}

/// Record achievement unlocked - call this when achievement is unlocked
Future<void> recordAchievementInSocial(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required String achievementTitle,
  required int rewardXp,
  String? achievementId,
}) async {
  final integration = ref.read(socialGameIntegrationProvider);
  await integration.recordAchievementUnlockedActivity(
    ref,
    userId: userId,
    displayName: displayName,
    achievementTitle: achievementTitle,
    rewardXp: rewardXp,
    achievementId: achievementId,
  );
}

/// Record streak milestone - call this when streak reaches milestone
Future<void> recordStreakMilestoneInSocial(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required int streakDays,
  required int xpReward,
}) async {
  final integration = ref.read(socialGameIntegrationProvider);
  await integration.recordStreakMilestoneActivity(
    ref,
    userId: userId,
    displayName: displayName,
    streakDays: streakDays,
    xpReward: xpReward,
  );
}

/// Record rank change - call this when user's rank changes on leaderboard
Future<void> recordRankChangeInSocial(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required int previousRank,
  required int currentRank,
}) async {
  final rankChange = previousRank - currentRank; // Positive = improved
  final integration = ref.read(socialGameIntegrationProvider);
  await integration.recordRankChangeActivity(
    ref,
    userId: userId,
    displayName: displayName,
    previousRank: previousRank,
    currentRank: currentRank,
    rankChange: rankChange,
  );
}

/// Record challenge completion - call this when multiplayer challenge ends
Future<void> recordChallengeCompletionInSocial(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required String challengeTitle,
  required bool isWinner,
  required int? xpReward,
}) async {
  final integration = ref.read(socialGameIntegrationProvider);
  await integration.recordChallengeCompletedActivity(
    ref,
    userId: userId,
    displayName: displayName,
    challengeTitle: challengeTitle,
    isWinner: isWinner,
    xpReward: xpReward,
  );
}

/// Record challenge start - call this when user joins/starts a challenge
Future<void> recordChallengeStartInSocial(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required String challengeTitle,
}) async {
  final integration = ref.read(socialGameIntegrationProvider);
  await integration.recordChallengeStartedActivity(
    ref,
    userId: userId,
    displayName: displayName,
    challengeTitle: challengeTitle,
  );
}

/// Update active challenge progress - call this during gameplay
Future<void> updateChallengeSocialProgress(
  WidgetRef ref, {
  required String challengeId,
  required String userId,
  required int newProgress,
}) async {
  final integration = ref.read(socialGameIntegrationProvider);
  await integration.updateChallengeProgress(
    ref,
    challengeId: challengeId,
    userId: userId,
    newProgress: newProgress,
  );
}
