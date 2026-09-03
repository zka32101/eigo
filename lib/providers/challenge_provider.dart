import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';

// Service provider
final challengeServiceProvider = Provider((ref) {
  return ChallengeService();
});

// Active challenges provider
final activeChallengesProvider = FutureProvider<List<SocialChallenge>>((ref) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getActiveChallenges();
});

// User created challenges provider
final userCreatedChallengesProvider =
    FutureProvider.family<List<SocialChallenge>, String>((ref, userId) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getUserCreatedChallenges(userId);
});

// User joined challenges provider
final userJoinedChallengesProvider =
    FutureProvider.family<List<SocialChallenge>, String>((ref, userId) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getUserJoinedChallenges(userId);
});

// Challenge by type provider
final challengesByTypeProvider =
    FutureProvider.family<List<SocialChallenge>, ChallengeType>(
  (ref, type) async {
    final service = ref.watch(challengeServiceProvider);
    return service.getChallengesByType(type);
  },
);

// Single challenge provider
final challengeProvider =
    FutureProvider.family<SocialChallenge, String>((ref, challengeId) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getChallengeById(challengeId);
});

// Challenge invitations provider
final challengeInvitationsProvider =
    FutureProvider.family<List<ChallengeInvitation>, String>((ref, userId) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getChallengeInvitations(userId);
});

// Challenge statistics provider
final challengeStatsProvider =
    FutureProvider.family<ChallengeStats, String>((ref, userId) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getUserChallengeStats(userId);
});

// Search challenges provider
final searchChallengesProvider =
    FutureProvider.family<List<SocialChallenge>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final service = ref.watch(challengeServiceProvider);
    return service.searchChallenges(query);
  },
);

// Create challenge action
class CreateChallengeParams {
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeGoalMetric goalMetric;
  final int goalValue;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final bool isPublic;
  final int? firstPlacePrize;
  final int? secondPlacePrize;
  final int? thirdPlacePrize;
  final List<String>? tags;

  CreateChallengeParams({
    required this.title,
    required this.description,
    required this.type,
    required this.goalMetric,
    required this.goalValue,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.isPublic,
    this.firstPlacePrize,
    this.secondPlacePrize,
    this.thirdPlacePrize,
    this.tags,
  });
}

final createChallengeActionProvider =
    FutureProvider.family<SocialChallenge, CreateChallengeParams>(
  (ref, params) async {
    final service = ref.watch(challengeServiceProvider);
    final challenge = SocialChallenge(
      id: '', // Will be set by service
      creatorId: '', // TODO: Get from auth
      creatorName: '', // TODO: Get from user profile
      creatorAvatar: '', // TODO: Get from user profile
      title: params.title,
      description: params.description,
      type: params.type,
      status: ChallengeStatus.active,
      goalMetric: params.goalMetric,
      goalValue: params.goalValue,
      startDate: params.startDate,
      endDate: params.endDate,
      createdAt: DateTime.now(),
      maxParticipants: params.maxParticipants,
      currentParticipants: 1, // Creator is participant
      isPublic: params.isPublic,
      invitedUserIds: [],
      participants: {},
      firstPlacePrize: params.firstPlacePrize,
      secondPlacePrize: params.secondPlacePrize,
      thirdPlacePrize: params.thirdPlacePrize,
      tags: params.tags,
    );

    final created = await service.createChallenge(challenge);
    ref.refresh(activeChallengesProvider);
    return created;
  },
);

// Join challenge action
class JoinChallengeParams {
  final String challengeId;
  final String userId;
  final String userName;
  final String userAvatar;

  JoinChallengeParams({
    required this.challengeId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });
}

final joinChallengeActionProvider =
    FutureProvider.family<ChallengeParticipation, JoinChallengeParams>(
  (ref, params) async {
    final service = ref.watch(challengeServiceProvider);
    final participation = await service.joinChallenge(
      params.challengeId,
      params.userId,
      params.userName,
      params.userAvatar,
    );
    
    ref.refresh(activeChallengesProvider);
    ref.refresh(challengeProvider(params.challengeId));
    ref.refresh(userJoinedChallengesProvider(params.userId));
    
    return participation;
  },
);

// Complete challenge action
class CompleteChallengeParams {
  final String challengeId;
  final String userId;
  final int finalScore;
  final int xpEarned;
  final int coinsEarned;

  CompleteChallengeParams({
    required this.challengeId,
    required this.userId,
    required this.finalScore,
    required this.xpEarned,
    required this.coinsEarned,
  });
}

final completeChallengeActionProvider =
    FutureProvider.family<ChallengeResult, CompleteChallengeParams>(
  (ref, params) async {
    final service = ref.watch(challengeServiceProvider);
    final result = await service.completeChallenge(
      params.challengeId,
      params.userId,
      params.finalScore,
      params.xpEarned,
      params.coinsEarned,
    );
    
    ref.refresh(challengeProvider(params.challengeId));
    ref.refresh(challengeStatsProvider(params.userId));
    
    return result;
  },
);

// Invite to challenge action
class InviteToChallengeParams {
  final String challengeId;
  final List<String> userIds;
  final String inviterName;

  InviteToChallengeParams({
    required this.challengeId,
    required this.userIds,
    required this.inviterName,
  });
}

final inviteToChallengeActionProvider =
    FutureProvider.family<void, InviteToChallengeParams>(
  (ref, params) async {
    final service = ref.watch(challengeServiceProvider);
    await service.inviteUsersToChallenge(
      params.challengeId,
      params.userIds,
      params.inviterName,
    );
    
    ref.refresh(challengeProvider(params.challengeId));
  },
);

// Accept invitation action
class AcceptInvitationParams {
  final String invitationId;
  final String challengeId;
  final String userId;

  AcceptInvitationParams({
    required this.invitationId,
    required this.challengeId,
    required this.userId,
  });
}

final acceptChallengeInvitationActionProvider =
    FutureProvider.family<void, AcceptInvitationParams>(
  (ref, params) async {
    final service = ref.watch(challengeServiceProvider);
    await service.acceptChallengeInvitation(
      params.invitationId,
      params.challengeId,
      params.userId,
    );
    
    ref.refresh(challengeInvitationsProvider(params.userId));
    ref.refresh(userJoinedChallengesProvider(params.userId));
  },
);

// Challenge search query state
final challengeSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Challenge filter state
final challengeTypeFilterProvider = StateProvider<ChallengeType?>((ref) {
  return null;
});

// Challenge sort state
enum ChallengeSortBy { newest, mostPopular, endingSoon }

final challengeSortProvider = StateProvider<ChallengeSortBy>((ref) {
  return ChallengeSortBy.newest;
});
