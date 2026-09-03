import 'package:flutter/foundation.dart';

/// Represents a user's social profile
class SocialProfile {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int totalXp;
  final int totalConversations;
  final int currentStreak;
  final int longestStreak;
  final int friendsCount;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final String? bio;
  final List<String> badges; // Achievement badge IDs
  final Map<String, dynamic> metadata;

  SocialProfile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.totalXp,
    required this.totalConversations,
    required this.currentStreak,
    required this.longestStreak,
    required this.friendsCount,
    required this.joinedAt,
    this.lastActiveAt,
    this.bio,
    this.badges = const [],
    this.metadata = const {},
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'level': level,
      'totalXp': totalXp,
      'totalConversations': totalConversations,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'friendsCount': friendsCount,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'bio': bio,
      'badges': badges,
      'metadata': metadata,
    };
  }

  /// Create from Firestore document
  factory SocialProfile.fromFirestore(Map<String, dynamic> doc) {
    return SocialProfile(
      userId: doc['userId'] as String,
      displayName: doc['displayName'] as String,
      avatarUrl: doc['avatarUrl'] as String?,
      level: doc['level'] as int? ?? 1,
      totalXp: doc['totalXp'] as int? ?? 0,
      totalConversations: doc['totalConversations'] as int? ?? 0,
      currentStreak: doc['currentStreak'] as int? ?? 0,
      longestStreak: doc['longestStreak'] as int? ?? 0,
      friendsCount: doc['friendsCount'] as int? ?? 0,
      joinedAt: DateTime.parse(doc['joinedAt'] as String),
      lastActiveAt: doc['lastActiveAt'] != null
          ? DateTime.parse(doc['lastActiveAt'] as String)
          : null,
      bio: doc['bio'] as String?,
      badges: List<String>.from(doc['badges'] as List? ?? []),
      metadata: Map<String, dynamic>.from(doc['metadata'] as Map? ?? {}),
    );
  }

  SocialProfile copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    int? level,
    int? totalXp,
    int? totalConversations,
    int? currentStreak,
    int? longestStreak,
    int? friendsCount,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    String? bio,
    List<String>? badges,
    Map<String, dynamic>? metadata,
  }) {
    return SocialProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      totalConversations: totalConversations ?? this.totalConversations,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      friendsCount: friendsCount ?? this.friendsCount,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      bio: bio ?? this.bio,
      badges: badges ?? this.badges,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Represents a friendship relationship
class Friendship {
  final String friendshipId;
  final String userId1;
  final String userId2;
  final DateTime connectedAt;
  final FriendshipStatus status; // pending, accepted, blocked
  final String? initiatedBy;
  final DateTime? statusChangedAt;

  Friendship({
    required this.friendshipId,
    required this.userId1,
    required this.userId2,
    required this.connectedAt,
    required this.status,
    this.initiatedBy,
    this.statusChangedAt,
  });

  /// Get the friend ID given the current user ID
  String getFriendId(String currentUserId) {
    return currentUserId == userId1 ? userId2 : userId1;
  }

  /// Check if friendship is active
  bool get isActive => status == FriendshipStatus.accepted;

  /// Check if pending
  bool get isPending => status == FriendshipStatus.pending;

  /// Check if blocked
  bool get isBlocked => status == FriendshipStatus.blocked;

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'friendshipId': friendshipId,
      'userId1': userId1,
      'userId2': userId2,
      'connectedAt': connectedAt.toIso8601String(),
      'status': status.toString(),
      'initiatedBy': initiatedBy,
      'statusChangedAt': statusChangedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory Friendship.fromFirestore(Map<String, dynamic> doc) {
    return Friendship(
      friendshipId: doc['friendshipId'] as String,
      userId1: doc['userId1'] as String,
      userId2: doc['userId2'] as String,
      connectedAt: DateTime.parse(doc['connectedAt'] as String),
      status: _parseFriendshipStatus(doc['status'] as String),
      initiatedBy: doc['initiatedBy'] as String?,
      statusChangedAt: doc['statusChangedAt'] != null
          ? DateTime.parse(doc['statusChangedAt'] as String)
          : null,
    );
  }

  static FriendshipStatus _parseFriendshipStatus(String status) {
    return FriendshipStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => FriendshipStatus.pending,
    );
  }
}

/// Friendship status enum
enum FriendshipStatus {
  pending, // Request sent but not accepted
  accepted, // Friends
  blocked, // Blocked by one party
}

/// Represents a multiplayer challenge
class MultiplayerChallenge {
  final String challengeId;
  final String title;
  final String description;
  final List<String> participantIds;
  final String creatorId;
  final ChallengeObjective objective;
  final DateTime createdAt;
  final DateTime endsAt;
  final int targetValue; // e.g., 10 conversations
  final String? prizePool; // XP or coins pool
  final bool completed;
  final Map<String, int> participantProgress; // userId -> progress value
  final List<String> winnersIds;

  MultiplayerChallenge({
    required this.challengeId,
    required this.title,
    required this.description,
    required this.participantIds,
    required this.creatorId,
    required this.objective,
    required this.createdAt,
    required this.endsAt,
    required this.targetValue,
    this.prizePool,
    this.completed = false,
    this.participantProgress = const {},
    this.winnersIds = const [],
  });

  /// Check if challenge is active
  bool get isActive {
    return !completed && DateTime.now().isBefore(endsAt);
  }

  /// Get time remaining
  Duration get timeRemaining {
    final remaining = endsAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get participant progress percentage
  double getProgressPercentage(String userId) {
    final progress = participantProgress[userId] ?? 0;
    return (progress / targetValue).clamp(0.0, 1.0);
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'title': title,
      'description': description,
      'participantIds': participantIds,
      'creatorId': creatorId,
      'objective': objective.toString(),
      'createdAt': createdAt.toIso8601String(),
      'endsAt': endsAt.toIso8601String(),
      'targetValue': targetValue,
      'prizePool': prizePool,
      'completed': completed,
      'participantProgress': participantProgress,
      'winnersIds': winnersIds,
    };
  }

  /// Create from Firestore document
  factory MultiplayerChallenge.fromFirestore(Map<String, dynamic> doc) {
    return MultiplayerChallenge(
      challengeId: doc['challengeId'] as String,
      title: doc['title'] as String,
      description: doc['description'] as String,
      participantIds: List<String>.from(doc['participantIds'] as List),
      creatorId: doc['creatorId'] as String,
      objective: _parseChallengeObjective(doc['objective'] as String),
      createdAt: DateTime.parse(doc['createdAt'] as String),
      endsAt: DateTime.parse(doc['endsAt'] as String),
      targetValue: doc['targetValue'] as int,
      prizePool: doc['prizePool'] as String?,
      completed: doc['completed'] as bool? ?? false,
      participantProgress: Map<String, int>.from(
          doc['participantProgress'] as Map? ?? {}),
      winnersIds: List<String>.from(doc['winnersIds'] as List? ?? []),
    );
  }

  static ChallengeObjective _parseChallengeObjective(String objective) {
    return ChallengeObjective.values.firstWhere(
      (e) => e.toString() == objective,
      orElse: () => ChallengeObjective.totalConversations,
    );
  }
}

/// Multiplayer challenge objective types
enum ChallengeObjective {
  totalConversations, // Total conversations completed
  totalXp, // Total XP earned
  totalCoins, // Total coins earned
  consecutiveDays, // Maintain streak
  uniqueNpcs, // Talk to unique NPCs
  uniqueLocations, // Visit unique locations
}

/// Challenge invitation
class ChallengeInvitation {
  final String invitationId;
  final String challengeId;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final InvitationStatus status; // pending, accepted, declined
  final DateTime? respondedAt;

  ChallengeInvitation({
    required this.invitationId,
    required this.challengeId,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    required this.status,
    this.respondedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'invitationId': invitationId,
      'challengeId': challengeId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory ChallengeInvitation.fromFirestore(Map<String, dynamic> doc) {
    return ChallengeInvitation(
      invitationId: doc['invitationId'] as String,
      challengeId: doc['challengeId'] as String,
      fromUserId: doc['fromUserId'] as String,
      toUserId: doc['toUserId'] as String,
      createdAt: DateTime.parse(doc['createdAt'] as String),
      status: _parseInvitationStatus(doc['status'] as String),
      respondedAt: doc['respondedAt'] != null
          ? DateTime.parse(doc['respondedAt'] as String)
          : null,
    );
  }

  static InvitationStatus _parseInvitationStatus(String status) {
    return InvitationStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => InvitationStatus.pending,
    );
  }
}

/// Invitation status enum
enum InvitationStatus {
  pending,
  accepted,
  declined,
}

/// Friend activity event
class FriendActivity {
  final String activityId;
  final String userId;
  final String displayName;
  final FriendActivityType type;
  final String title;
  final String description;
  final String? relatedId; // NPC ID, location ID, achievement ID, etc.
  final DateTime createdAt;
  final int? xpGained;
  final int? coinsGained;

  FriendActivity({
    required this.activityId,
    required this.userId,
    required this.displayName,
    required this.type,
    required this.title,
    required this.description,
    this.relatedId,
    required this.createdAt,
    this.xpGained,
    this.coinsGained,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'activityId': activityId,
      'userId': userId,
      'displayName': displayName,
      'type': type.toString(),
      'title': title,
      'description': description,
      'relatedId': relatedId,
      'createdAt': createdAt.toIso8601String(),
      'xpGained': xpGained,
      'coinsGained': coinsGained,
    };
  }

  /// Create from Firestore document
  factory FriendActivity.fromFirestore(Map<String, dynamic> doc) {
    return FriendActivity(
      activityId: doc['activityId'] as String,
      userId: doc['userId'] as String,
      displayName: doc['displayName'] as String,
      type: _parseFriendActivityType(doc['type'] as String),
      title: doc['title'] as String,
      description: doc['description'] as String,
      relatedId: doc['relatedId'] as String?,
      createdAt: DateTime.parse(doc['createdAt'] as String),
      xpGained: doc['xpGained'] as int?,
      coinsGained: doc['coinsGained'] as int?,
    );
  }

  static FriendActivityType _parseFriendActivityType(String type) {
    return FriendActivityType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => FriendActivityType.conversation,
    );
  }
}

/// Friend activity types
enum FriendActivityType {
  conversation, // Had a conversation
  achievementUnlocked, // Unlocked achievement
  streakMilestone, // Reached streak milestone
  rankChange, // Rank changed
  challengeStarted, // Started a challenge
  challengeCompleted, // Completed a challenge
  joinedFriends, // Joined friends
}
