import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_social_model.dart';
import '../services/english_town_social_service.dart';

/// Social service instance
final socialServiceProvider =
    Provider<EnglishTownSocialService>((ref) {
  return EnglishTownSocialService();
});

// ==================== USER PROFILE ====================

/// Get current user's social profile
final currentUserProfileProvider =
    FutureProvider<SocialProfile?>((ref) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Get current user ID from auth
  return null;
});

/// Get any user's profile
final userProfileProvider =
    FutureProvider.family<SocialProfile?, String>((ref, userId) async {
  final service = ref.watch(socialServiceProvider);
  return await service.getUserProfile(userId);
});

// ==================== FRIENDS ====================

/// Get current user's friends list
final friendsListProvider = FutureProvider<List<SocialProfile>>((ref) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Get current user ID from auth
  return [];
});

/// Get friends count
final friendsCountProvider = FutureProvider<int>((ref) async {
  final friends = ref.watch(friendsListProvider);
  return friends.whenData((f) => f.length).value ?? 0;
});

/// Get pending friend requests
final pendingFriendRequestsProvider =
    FutureProvider<List<Friendship>>((ref) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Get current user ID from auth
  return [];
});

/// Get pending request count
final pendingRequestsCountProvider =
    FutureProvider<int>((ref) async {
  final requests = ref.watch(pendingFriendRequestsProvider);
  return requests.whenData((r) => r.length).value ?? 0;
});

/// Send friend request
Future<bool> sendFriendRequest(
  WidgetRef ref,
  String toUserId,
) async {
  final service = ref.read(socialServiceProvider);
  // TODO: Get current user ID from auth
  return false; // await service.sendFriendRequest(currentUserId, toUserId);
}

/// Accept friend request
Future<bool> acceptFriendRequest(
  WidgetRef ref,
  String friendshipId,
) async {
  final service = ref.read(socialServiceProvider);
  return await service.acceptFriendRequest(friendshipId);
}

/// Decline friend request
Future<bool> declineFriendRequest(
  WidgetRef ref,
  String friendshipId,
) async {
  final service = ref.read(socialServiceProvider);
  return await service.declineFriendRequest(friendshipId);
}

/// Block friend
Future<bool> blockFriend(
  WidgetRef ref,
  String friendshipId,
) async {
  final service = ref.read(socialServiceProvider);
  return await service.blockFriend(friendshipId);
}

/// Remove friend
Future<bool> removeFriend(
  WidgetRef ref,
  String friendshipId,
) async {
  final service = ref.read(socialServiceProvider);
  return await service.removeFriend(friendshipId);
}

// ==================== MULTIPLAYER CHALLENGES ====================

/// Get active challenges for current user
final activeChallengesProvider =
    FutureProvider<List<MultiplayerChallenge>>((ref) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Get current user ID from auth
  return [];
});

/// Get active challenges count
final activeChallengesCountProvider =
    FutureProvider<int>((ref) async {
  final challenges = ref.watch(activeChallengesProvider);
  return challenges.whenData((c) => c.length).value ?? 0;
});

/// Get specific challenge
final multiplayerChallengeProvider =
    FutureProvider.family<MultiplayerChallenge?, String>((ref, challengeId) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Fetch from Firestore
  return null;
});

/// Create multiplayer challenge
Future<MultiplayerChallenge?> createMultiplayerChallenge(
  WidgetRef ref, {
  required String title,
  required String description,
  required List<String> participantIds,
  required ChallengeObjective objective,
  required int targetValue,
  required Duration duration,
  String? prizePool,
}) async {
  final service = ref.read(socialServiceProvider);
  // TODO: Get current user ID from auth
  return await service.createMultiplayerChallenge(
    title: title,
    description: description,
    participantIds: participantIds,
    creatorId: '', // currentUserId
    objective: objective,
    targetValue: targetValue,
    duration: duration,
    prizePool: prizePool,
  );
}

/// Update challenge progress
Future<bool> updateChallengeProgress(
  WidgetRef ref,
  String challengeId,
  int progressValue,
) async {
  final service = ref.read(socialServiceProvider);
  // TODO: Get current user ID from auth
  return await service.updateChallengeProgress(
    challengeId,
    '', // currentUserId
    progressValue,
  );
}

// ==================== CHALLENGE INVITATIONS ====================

/// Get pending challenge invitations
final pendingChallengeInvitationsProvider =
    FutureProvider<List<ChallengeInvitation>>((ref) async {
  // TODO: Query Firestore for pending invitations for current user
  return [];
});

/// Invite friend to challenge
Future<ChallengeInvitation?> inviteFriendToChallenge(
  WidgetRef ref, {
  required String challengeId,
  required String friendId,
}) async {
  final service = ref.read(socialServiceProvider);
  // TODO: Get current user ID from auth
  return await service.inviteToChallenges(
    challengeId: challengeId,
    fromUserId: '', // currentUserId
    toUserId: friendId,
  );
}

/// Accept challenge invitation
Future<bool> acceptChallengeInvitation(
  WidgetRef ref,
  String invitationId,
) async {
  final service = ref.read(socialServiceProvider);
  return await service.acceptChallengeInvitation(invitationId);
}

// ==================== FRIEND ACTIVITY ====================

/// Get friend activity feed
final friendActivityFeedProvider =
    FutureProvider<List<FriendActivity>>((ref) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Get current user ID from auth
  return await service.getFriendActivityFeed('', limit: 50);
});

/// Record friend activity
Future<FriendActivity?> recordFriendActivity(
  WidgetRef ref, {
  required FriendActivityType type,
  required String title,
  required String description,
  String? relatedId,
  int? xpGained,
  int? coinsGained,
}) async {
  final service = ref.read(socialServiceProvider);
  // TODO: Get current user ID and display name from auth/profile
  return await service.recordFriendActivity(
    userId: '',
    displayName: '',
    type: type,
    title: title,
    description: description,
    relatedId: relatedId,
    xpGained: xpGained,
    coinsGained: coinsGained,
  );
}

// ==================== USER SEARCH ====================

/// Search users by display name
final userSearchProvider =
    FutureProvider.family<List<SocialProfile>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final service = ref.watch(socialServiceProvider);
  return await service.searchUsers(query);
});

// ==================== LEADERBOARD WITH FRIENDS ====================

/// Get leaderboard with friends highlighted
final leaderboardWithFriendsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Get current user ID from auth
  return await service.getLeaderboardWithFriends('', limit: 50);
});

// ==================== FRIEND COMPARISON ====================

/// Compare stats with a friend
final friendComparisonProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, friendId) async {
  final service = ref.watch(socialServiceProvider);
  // TODO: Get current user ID from auth
  return await service.compareFriendStats('', friendId);
});

// ==================== PREFERENCES ====================

/// Show achievements on friend feed
final showAchievementsOnFeedProvider =
    StateProvider<bool>((ref) => true);

/// Show conversations on friend feed
final showConversationsOnFeedProvider =
    StateProvider<bool>((ref) => true);

/// Show challenge activities on friend feed
final showChallengesOnFeedProvider =
    StateProvider<bool>((ref) => true);

/// Allow friend requests from anyone
final allowFriendRequestsProvider =
    StateProvider<bool>((ref) => true);

/// Allow challenge invitations from anyone
final allowChallengeInvitesProvider =
    StateProvider<bool>((ref) => true);

/// Make profile public
final publicProfileProvider =
    StateProvider<bool>((ref) => true);
