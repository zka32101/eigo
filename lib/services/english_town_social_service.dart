import '../models/english_town_social_model.dart';

/// Service for managing social features (friends, challenges, activities)
class EnglishTownSocialService {
  static final EnglishTownSocialService _instance =
      EnglishTownSocialService._internal();

  factory EnglishTownSocialService() {
    return _instance;
  }

  EnglishTownSocialService._internal();

  // In-memory stores for development
  final Map<String, SocialProfile> _profiles = {};
  final Map<String, Friendship> _friendships = {};
  final Map<String, MultiplayerChallenge> _challenges = {};
  final Map<String, ChallengeInvitation> _invitations = {};
  final List<FriendActivity> _activities = [];

  /// Get user's social profile
  Future<SocialProfile?> getUserProfile(String userId) async {
    // TODO: Fetch from Firestore
    return _profiles[userId];
  }

  /// Update user's social profile
  Future<void> updateUserProfile(SocialProfile profile) async {
    // TODO: Save to Firestore
    _profiles[profile.userId] = profile;
  }

  /// Get friend list
  Future<List<SocialProfile>> getFriendsList(String userId) async {
    // TODO: Query Firestore friendships and get friend profiles
    // For now, return empty
    return [];
  }

  /// Send friend request
  Future<bool> sendFriendRequest(
    String fromUserId,
    String toUserId,
  ) async {
    try {
      final friendshipId = '${fromUserId}_${toUserId}';

      final friendship = Friendship(
        friendshipId: friendshipId,
        userId1: fromUserId,
        userId2: toUserId,
        connectedAt: DateTime.now(),
        status: FriendshipStatus.pending,
        initiatedBy: fromUserId,
      );

      // TODO: Save to Firestore
      _friendships[friendshipId] = friendship;

      return true;
    } catch (e) {
      print('[Social] Error sending friend request: $e');
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String friendshipId) async {
    try {
      final friendship = _friendships[friendshipId];
      if (friendship == null) return false;

      final updated = Friendship(
        friendshipId: friendship.friendshipId,
        userId1: friendship.userId1,
        userId2: friendship.userId2,
        connectedAt: friendship.connectedAt,
        status: FriendshipStatus.accepted,
        initiatedBy: friendship.initiatedBy,
        statusChangedAt: DateTime.now(),
      );

      // TODO: Update in Firestore
      _friendships[friendshipId] = updated;

      return true;
    } catch (e) {
      print('[Social] Error accepting friend request: $e');
      return false;
    }
  }

  /// Decline friend request
  Future<bool> declineFriendRequest(String friendshipId) async {
    try {
      // TODO: Delete from Firestore or mark as declined
      _friendships.remove(friendshipId);
      return true;
    } catch (e) {
      print('[Social] Error declining friend request: $e');
      return false;
    }
  }

  /// Block a friend
  Future<bool> blockFriend(String friendshipId) async {
    try {
      final friendship = _friendships[friendshipId];
      if (friendship == null) return false;

      final updated = Friendship(
        friendshipId: friendship.friendshipId,
        userId1: friendship.userId1,
        userId2: friendship.userId2,
        connectedAt: friendship.connectedAt,
        status: FriendshipStatus.blocked,
        initiatedBy: friendship.initiatedBy,
        statusChangedAt: DateTime.now(),
      );

      // TODO: Update in Firestore
      _friendships[friendshipId] = updated;

      return true;
    } catch (e) {
      print('[Social] Error blocking friend: $e');
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend(String friendshipId) async {
    try {
      // TODO: Delete from Firestore
      _friendships.remove(friendshipId);
      return true;
    } catch (e) {
      print('[Social] Error removing friend: $e');
      return false;
    }
  }

  /// Get pending friend requests
  Future<List<Friendship>> getPendingFriendRequests(String userId) async {
    // TODO: Query Firestore for pending friendships
    return _friendships.values
        .where((f) =>
            f.status == FriendshipStatus.pending &&
            f.userId2 == userId)
        .toList();
  }

  /// Create a multiplayer challenge
  Future<MultiplayerChallenge?> createMultiplayerChallenge({
    required String title,
    required String description,
    required List<String> participantIds,
    required String creatorId,
    required ChallengeObjective objective,
    required int targetValue,
    required Duration duration,
    String? prizePool,
  }) async {
    try {
      final challengeId =
          'challenge_${DateTime.now().millisecondsSinceEpoch}';

      final challenge = MultiplayerChallenge(
        challengeId: challengeId,
        title: title,
        description: description,
        participantIds: participantIds,
        creatorId: creatorId,
        objective: objective,
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(duration),
        targetValue: targetValue,
        prizePool: prizePool,
        participantProgress: {
          for (final id in participantIds) id: 0,
        },
      );

      // TODO: Save to Firestore
      _challenges[challengeId] = challenge;

      return challenge;
    } catch (e) {
      print('[Social] Error creating challenge: $e');
      return null;
    }
  }

  /// Get active challenges for user
  Future<List<MultiplayerChallenge>> getActiveChallenges(
      String userId) async {
    // TODO: Query Firestore for user's active challenges
    return _challenges.values
        .where((c) => c.participantIds.contains(userId) && c.isActive)
        .toList();
  }

  /// Update challenge progress
  Future<bool> updateChallengeProgress(
    String challengeId,
    String userId,
    int progressValue,
  ) async {
    try {
      final challenge = _challenges[challengeId];
      if (challenge == null) return false;

      final newProgress = Map<String, int>.from(challenge.participantProgress);
      newProgress[userId] = progressValue;

      final updated = challenge.copyWith(participantProgress: newProgress);

      // TODO: Update in Firestore
      _challenges[challengeId] = updated;

      return true;
    } catch (e) {
      print('[Social] Error updating challenge progress: $e');
      return false;
    }
  }

  /// Complete a challenge
  Future<bool> completeChallenge(
    String challengeId,
    List<String> winnersIds,
  ) async {
    try {
      final challenge = _challenges[challengeId];
      if (challenge == null) return false;

      final updated = challenge.copyWith(
        completed: true,
        winnersIds: winnersIds,
      );

      // TODO: Update in Firestore
      _challenges[challengeId] = updated;

      return true;
    } catch (e) {
      print('[Social] Error completing challenge: $e');
      return false;
    }
  }

  /// Invite friend to challenge
  Future<ChallengeInvitation?> inviteToChallenges({
    required String challengeId,
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      final invitationId = '${challengeId}_${fromUserId}_${toUserId}';

      final invitation = ChallengeInvitation(
        invitationId: invitationId,
        challengeId: challengeId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        createdAt: DateTime.now(),
        status: InvitationStatus.pending,
      );

      // TODO: Save to Firestore
      _invitations[invitationId] = invitation;

      return invitation;
    } catch (e) {
      print('[Social] Error inviting to challenge: $e');
      return null;
    }
  }

  /// Accept challenge invitation
  Future<bool> acceptChallengeInvitation(String invitationId) async {
    try {
      final invitation = _invitations[invitationId];
      if (invitation == null) return false;

      final updated = ChallengeInvitation(
        invitationId: invitation.invitationId,
        challengeId: invitation.challengeId,
        fromUserId: invitation.fromUserId,
        toUserId: invitation.toUserId,
        createdAt: invitation.createdAt,
        status: InvitationStatus.accepted,
        respondedAt: DateTime.now(),
      );

      // TODO: Update in Firestore and add user to challenge
      _invitations[invitationId] = updated;

      return true;
    } catch (e) {
      print('[Social] Error accepting invitation: $e');
      return false;
    }
  }

  /// Record friend activity
  Future<FriendActivity?> recordFriendActivity({
    required String userId,
    required String displayName,
    required FriendActivityType type,
    required String title,
    required String description,
    String? relatedId,
    int? xpGained,
    int? coinsGained,
  }) async {
    try {
      final activityId =
          'activity_${DateTime.now().millisecondsSinceEpoch}';

      final activity = FriendActivity(
        activityId: activityId,
        userId: userId,
        displayName: displayName,
        type: type,
        title: title,
        description: description,
        relatedId: relatedId,
        createdAt: DateTime.now(),
        xpGained: xpGained,
        coinsGained: coinsGained,
      );

      // TODO: Save to Firestore
      _activities.insert(0, activity);

      // Keep only recent activities (max 1000)
      if (_activities.length > 1000) {
        _activities.removeRange(1000, _activities.length);
      }

      return activity;
    } catch (e) {
      print('[Social] Error recording activity: $e');
      return null;
    }
  }

  /// Get friend activity feed (for followed friends)
  Future<List<FriendActivity>> getFriendActivityFeed(
    String userId, {
    int limit = 50,
  }) async {
    // TODO: Query Firestore for activities from friends
    return _activities.take(limit).toList();
  }

  /// Search users by display name
  Future<List<SocialProfile>> searchUsers(String query) async {
    // TODO: Query Firestore for users matching query
    return _profiles.values
        .where((p) =>
            p.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get user leaderboard with friends highlighted
  Future<List<Map<String, dynamic>>> getLeaderboardWithFriends(
    String userId, {
    int limit = 50,
  }) async {
    // TODO: Query Firestore leaderboard and mark which are friends
    return [];
  }

  /// Get friend statistics comparison
  Future<Map<String, dynamic>?> compareFriendStats(
    String userId,
    String friendId,
  ) async {
    try {
      final userProfile = await getUserProfile(userId);
      final friendProfile = await getUserProfile(friendId);

      if (userProfile == null || friendProfile == null) return null;

      return {
        'user': {
          'displayName': userProfile.displayName,
          'level': userProfile.level,
          'totalXp': userProfile.totalXp,
          'totalConversations': userProfile.totalConversations,
          'currentStreak': userProfile.currentStreak,
        },
        'friend': {
          'displayName': friendProfile.displayName,
          'level': friendProfile.level,
          'totalXp': friendProfile.totalXp,
          'totalConversations': friendProfile.totalConversations,
          'currentStreak': friendProfile.currentStreak,
        },
        'comparison': {
          'xpDifference': userProfile.totalXp - friendProfile.totalXp,
          'conversationDifference':
              userProfile.totalConversations - friendProfile.totalConversations,
          'streakDifference': userProfile.currentStreak - friendProfile.currentStreak,
          'levelDifference': userProfile.level - friendProfile.level,
        },
      };
    } catch (e) {
      print('[Social] Error comparing stats: $e');
      return null;
    }
  }
}

/// Extension on MultiplayerChallenge for convenience
extension MultiplexChallengeExt on MultiplayerChallenge {
  MultiplayerChallenge copyWith({
    String? challengeId,
    String? title,
    String? description,
    List<String>? participantIds,
    String? creatorId,
    ChallengeObjective? objective,
    DateTime? createdAt,
    DateTime? endsAt,
    int? targetValue,
    String? prizePool,
    bool? completed,
    Map<String, int>? participantProgress,
    List<String>? winnersIds,
  }) {
    return MultiplayerChallenge(
      challengeId: challengeId ?? this.challengeId,
      title: title ?? this.title,
      description: description ?? this.description,
      participantIds: participantIds ?? this.participantIds,
      creatorId: creatorId ?? this.creatorId,
      objective: objective ?? this.objective,
      createdAt: createdAt ?? this.createdAt,
      endsAt: endsAt ?? this.endsAt,
      targetValue: targetValue ?? this.targetValue,
      prizePool: prizePool ?? this.prizePool,
      completed: completed ?? this.completed,
      participantProgress: participantProgress ?? this.participantProgress,
      winnersIds: winnersIds ?? this.winnersIds,
    );
  }
}
