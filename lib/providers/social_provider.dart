import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_model.dart';
import '../services/social_service.dart';

final socialServiceProvider = Provider((ref) {
  return SocialService();
});

// User profile provider
final userProfileProvider =
    FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final service = ref.watch(socialServiceProvider);
  return service.getUserProfile(userId);
});

// User's friends provider
final userFriendsProvider =
    FutureProvider.family<List<Friend>, String>((ref, userId) async {
  final service = ref.watch(socialServiceProvider);
  return service.getUserFriends(userId);
});

// Pending friend requests provider
final pendingFriendRequestsProvider =
    FutureProvider.family<List<Friend>, String>((ref, userId) async {
  final service = ref.watch(socialServiceProvider);
  return service.getPendingFriendRequests(userId);
});

// User activities provider
final userActivitiesProvider =
    FutureProvider.family<List<Activity>, String>((ref, userId) async {
  final service = ref.watch(socialServiceProvider);
  return service.getUserActivities(userId);
});

// Friend feed provider
final friendFeedProvider =
    FutureProvider.family<List<Activity>, String>((ref, userId) async {
  final service = ref.watch(socialServiceProvider);
  return service.getFriendFeed(userId);
});

// Social stats provider
final socialStatsProvider =
    FutureProvider.family<SocialStats, String>((ref, userId) async {
  final service = ref.watch(socialServiceProvider);
  return service.getSocialStats(userId);
});

// User comparison provider
final userComparisonProvider = FutureProvider.family<UserComparison?, ({String userId1, String userId2})>(
  (ref, params) async {
    final service = ref.watch(socialServiceProvider);
    return service.compareUsers(params.userId1, params.userId2);
  },
);

// Search users provider
final searchUsersProvider =
    FutureProvider.family<List<UserProfile>, String>((ref, query) async {
  final service = ref.watch(socialServiceProvider);
  return service.searchUsers(query);
});

// Check if users are friends
final areFriendsProvider = FutureProvider.family<bool, ({String userId1, String userId2})>(
  (ref, params) async {
    final service = ref.watch(socialServiceProvider);
    return service.areFriends(params.userId1, params.userId2);
  },
);

// Send friend request action
class SendFriendRequestParams {
  final String userId;
  final String friendId;

  SendFriendRequestParams({
    required this.userId,
    required this.friendId,
  });
}

final sendFriendRequestActionProvider =
    FutureProvider.family<void, SendFriendRequestParams>(
  (ref, params) async {
    final service = ref.watch(socialServiceProvider);
    await service.sendFriendRequest(params.userId, params.friendId);
    
    // Invalidate related providers
    ref.invalidate(userFriendsProvider(params.userId));
    ref.invalidate(socialStatsProvider(params.userId));
  },
);

// Accept friend request action
class AcceptFriendRequestParams {
  final String friendRequestId;
  final String userId;

  AcceptFriendRequestParams({
    required this.friendRequestId,
    required this.userId,
  });
}

final acceptFriendRequestActionProvider =
    FutureProvider.family<void, AcceptFriendRequestParams>(
  (ref, params) async {
    final service = ref.watch(socialServiceProvider);
    await service.acceptFriendRequest(params.friendRequestId, params.userId);
    
    // Invalidate related providers
    ref.invalidate(userFriendsProvider(params.userId));
    ref.invalidate(pendingFriendRequestsProvider(params.userId));
    ref.invalidate(socialStatsProvider(params.userId));
  },
);

// Decline friend request action
final declineFriendRequestActionProvider =
    FutureProvider.family<void, String>((ref, friendRequestId) async {
  final service = ref.watch(socialServiceProvider);
  await service.declineFriendRequest(friendRequestId);
  
  // Note: Would need userId to invalidate specific provider
  // This is a limitation of the current approach
});

// Remove friend action
class RemoveFriendParams {
  final String userId;
  final String friendId;

  RemoveFriendParams({
    required this.userId,
    required this.friendId,
  });
}

final removeFriendActionProvider =
    FutureProvider.family<void, RemoveFriendParams>(
  (ref, params) async {
    final service = ref.watch(socialServiceProvider);
    await service.removeFriend(params.userId, params.friendId);
    
    // Invalidate related providers
    ref.invalidate(userFriendsProvider(params.userId));
    ref.invalidate(socialStatsProvider(params.userId));
  },
);

// Record activity action
class RecordActivityParams {
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final String? icon;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final bool isShared;
  final int? xpReward;
  final int? coinReward;

  RecordActivityParams({
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.icon,
    this.imageUrl,
    this.metadata,
    required this.isShared,
    this.xpReward,
    this.coinReward,
  });
}

final recordActivityActionProvider =
    FutureProvider.family<Activity, RecordActivityParams>(
  (ref, params) async {
    final service = ref.watch(socialServiceProvider);
    final activity = await service.recordActivity(
      userId: params.userId,
      type: params.type,
      title: params.title,
      description: params.description,
      icon: params.icon,
      imageUrl: params.imageUrl,
      metadata: params.metadata,
      isShared: params.isShared,
      xpReward: params.xpReward,
      coinReward: params.coinReward,
    );
    
    // Invalidate related providers
    ref.invalidate(userActivitiesProvider(params.userId));
    ref.invalidate(socialStatsProvider(params.userId));
    
    return activity;
  },
);

// Update user profile action
final updateUserProfileActionProvider =
    FutureProvider.family<void, UserProfile>((ref, profile) async {
  final service = ref.watch(socialServiceProvider);
  await service.updateUserProfile(profile.id, profile);
  
  // Invalidate related providers
  ref.invalidate(userProfileProvider(profile.id));
});

// Update online status action
class UpdateOnlineStatusParams {
  final String userId;
  final bool isOnline;

  UpdateOnlineStatusParams({
    required this.userId,
    required this.isOnline,
  });
}

final updateOnlineStatusActionProvider =
    FutureProvider.family<void, UpdateOnlineStatusParams>(
  (ref, params) async {
    final service = ref.watch(socialServiceProvider);
    await service.updateOnlineStatus(params.userId, params.isOnline);
    
    // Invalidate related providers
    ref.invalidate(userProfileProvider(params.userId));
  },
);
