import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import '../services/logger_service.dart';

/// Challenge Service instance provider
final challengeServiceProvider = Provider((ref) {
  return ChallengeService();
});

/// All active challenges provider
final activeChallengesProvider = FutureProvider<List<SocialChallenge>>((ref) async {
  final challengeService = ref.watch(challengeServiceProvider);
  return await challengeService.getActiveChallenges();
});

/// Challenges by type provider
final challengesByTypeProvider = FutureProvider.family<List<SocialChallenge>, ChallengeType>(
  (ref, type) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getChallengesByType(type);
  },
);

/// Specific challenge provider
final challengeProvider = FutureProvider.family<SocialChallenge?, String>(
  (ref, challengeId) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getChallenge(challengeId);
  },
);

/// User's active challenges provider
final userActiveChallengesProvider = FutureProvider.family<List<UserChallengeProgress>, String>(
  (ref, userId) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getUserActiveChallenges(userId);
  },
);

/// User's completed challenges provider
final userCompletedChallengesProvider = FutureProvider.family<List<UserChallengeProgress>, String>(
  (ref, userId) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getUserCompletedChallenges(userId);
  },
);

/// User's challenge progress provider
final userChallengeProgressProvider = FutureProvider.family<UserChallengeProgress?, String>(
  (ref, params) async {
    final parts = params.split(':');
    if (parts.length != 2) return null;

    final userId = parts[0];
    final challengeId = parts[1];

    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getUserChallengeProgress(userId, challengeId);
  },
);

/// Challenge leaderboard provider
final challengeLeaderboardProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, challengeId) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getChallengeLeaderboard(challengeId);
  },
);

/// User's challenge rank provider
final userChallengeRankProvider = FutureProvider.family<int?, String>(
  (ref, params) async {
    final parts = params.split(':');
    if (parts.length != 2) return null;

    final userId = parts[0];
    final challengeId = parts[1];

    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getUserChallengeRank(userId, challengeId);
  },
);

/// Challenge statistics provider
final challengeStatsProvider = FutureProvider.family<ChallengeStats?, String>(
  (ref, challengeId) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getChallengeStats(challengeId);
  },
);

/// User's challenge statistics provider
final userChallengeStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getUserChallengeStats(userId);
  },
);

/// User's friend challenges provider
final userFriendChallengesProvider = FutureProvider.family<List<FriendChallenge>, String>(
  (ref, userId) async {
    final challengeService = ref.watch(challengeServiceProvider);
    return await challengeService.getUserFriendChallenges(userId);
  },
);

// ===== Action Providers =====

/// Join challenge action
final joinChallengeActionProvider = FutureProvider.family<bool, JoinChallengeParams>(
  (ref, params) async {
    final challengeService = ref.watch(challengeServiceProvider);
    final result = await challengeService.joinChallenge(params.userId, params.challengeId);

    if (result) {
      // Invalidate related providers
      ref.invalidate(userActiveChallengesProvider(params.userId));
      ref.invalidate(activeChallengesProvider);
      ref.invalidate(challengeLeaderboardProvider(params.challengeId));
    }

    return result;
  },
);

/// Update challenge progress action
final updateChallengeProgressActionProvider =
    FutureProvider.family<void, UpdateChallengeProgressParams>(
  (ref, params) async {
    final challengeService = ref.watch(challengeServiceProvider);
    await challengeService.updateChallengeProgress(
      params.userId,
      params.challengeId,
      params.progress,
    );

    // Invalidate related providers
    ref.invalidate(
      userChallengeProgressProvider('${params.userId}:${params.challengeId}'),
    );
    ref.invalidate(challengeLeaderboardProvider(params.challengeId));
    ref.invalidate(userChallengeRankProvider('${params.userId}:${params.challengeId}'));
  },
);

/// Claim rewards action
final claimRewardsActionProvider = FutureProvider.family<List<ChallengeReward>, String>(
  (ref, params) async {
    final parts = params.split(':');
    if (parts.length != 2) return [];

    final userId = parts[0];
    final challengeId = parts[1];

    final challengeService = ref.watch(challengeServiceProvider);
    final rewards = await challengeService.claimChallengeRewards(userId, challengeId);

    if (rewards.isNotEmpty) {
      // Invalidate related providers
      ref.invalidate(userChallengeProgressProvider('$userId:$challengeId'));
      ref.invalidate(userChallengeStatsProvider(userId));
    }

    return rewards;
  },
);

/// Create friend challenge action
final createFriendChallengeActionProvider = FutureProvider.family<FriendChallenge?, CreateFriendChallengeParams>(
  (ref, params) async {
    final challengeService = ref.watch(challengeServiceProvider);
    final challenge = await challengeService.createFriendChallenge(
      params.userId,
      params.friendId,
      params.description,
      params.targetValue,
    );

    if (challenge != null) {
      // Invalidate related providers
      ref.invalidate(userFriendChallengesProvider(params.userId));
      ref.invalidate(userFriendChallengesProvider(params.friendId));
    }

    return challenge;
  },
);

/// Update friend challenge progress action
final updateFriendChallengeProgressActionProvider =
    FutureProvider.family<void, UpdateFriendChallengeProgressParams>(
  (ref, params) async {
    final challengeService = ref.watch(challengeServiceProvider);
    await challengeService.updateFriendChallengeProgress(
      params.challengeId,
      params.userId,
      params.progress,
    );

    // Invalidate related providers
    ref.invalidate(userFriendChallengesProvider(params.userId));
  },
);

// ===== Parameter Classes =====

class JoinChallengeParams {
  final String userId;
  final String challengeId;

  JoinChallengeParams({
    required this.userId,
    required this.challengeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JoinChallengeParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          challengeId == other.challengeId;

  @override
  int get hashCode => userId.hashCode ^ challengeId.hashCode;
}

class UpdateChallengeProgressParams {
  final String userId;
  final String challengeId;
  final int progress;

  UpdateChallengeProgressParams({
    required this.userId,
    required this.challengeId,
    required this.progress,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateChallengeProgressParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          challengeId == other.challengeId &&
          progress == other.progress;

  @override
  int get hashCode => userId.hashCode ^ challengeId.hashCode ^ progress.hashCode;
}

class CreateFriendChallengeParams {
  final String userId;
  final String friendId;
  final String description;
  final int targetValue;

  CreateFriendChallengeParams({
    required this.userId,
    required this.friendId,
    required this.description,
    required this.targetValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateFriendChallengeParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          friendId == other.friendId &&
          description == other.description &&
          targetValue == other.targetValue;

  @override
  int get hashCode =>
      userId.hashCode ^ friendId.hashCode ^ description.hashCode ^ targetValue.hashCode;
}

class UpdateFriendChallengeProgressParams {
  final String challengeId;
  final String userId;
  final int progress;

  UpdateFriendChallengeProgressParams({
    required this.challengeId,
    required this.userId,
    required this.progress,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateFriendChallengeProgressParams &&
          runtimeType == other.runtimeType &&
          challengeId == other.challengeId &&
          userId == other.userId &&
          progress == other.progress;

  @override
  int get hashCode => challengeId.hashCode ^ userId.hashCode ^ progress.hashCode;
}
