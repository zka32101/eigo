import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_request.dart';
import '../models/user_profile.dart';
import '../services/friend_service.dart';
import 'user_profile_service_provider.dart';

/// Singleton provider for FriendService
final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService();
});

/// Parameter classes for actions
class SendFriendRequestParams {
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String receiverId;

  SendFriendRequestParams({
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.receiverId,
  });
}

class AcceptFriendRequestParams {
  final String requestId;
  final String userId1;
  final String userId1Name;
  final String userId1Avatar;
  final int userId1Grade;
  final int userId1Level;
  final String userId2;
  final String userId2Name;
  final String userId2Avatar;
  final int userId2Grade;
  final int userId2Level;

  AcceptFriendRequestParams({
    required this.requestId,
    required this.userId1,
    required this.userId1Name,
    required this.userId1Avatar,
    required this.userId1Grade,
    required this.userId1Level,
    required this.userId2,
    required this.userId2Name,
    required this.userId2Avatar,
    required this.userId2Grade,
    required this.userId2Level,
  });
}

class BlockUserParams {
  final String blockingUserId;
  final String blockedUserId;

  BlockUserParams({
    required this.blockingUserId,
    required this.blockedUserId,
  });
}

/// ==================== FRIEND LIST PROVIDERS ====================

/// Get friend list for a user
final friendListProvider = FutureProvider.family<List<Friend>, String>((ref, userId) async {
  final service = ref.watch(friendServiceProvider);
  return service.getFriendList(userId);
});

/// Get received friend requests for a user
final receivedFriendRequestsProvider = FutureProvider.family<List<FriendRequest>, String>((ref, userId) async {
  final service = ref.watch(friendServiceProvider);
  return service.getReceivedFriendRequests(userId);
});

/// Get sent friend requests for a user
final sentFriendRequestsProvider = FutureProvider.family<List<FriendRequest>, String>((ref, userId) async {
  final service = ref.watch(friendServiceProvider);
  return service.getSentFriendRequests(userId);
});

/// Get friend suggestions for a user
final friendSuggestionsProvider = FutureProvider.family<List<UserProfile>, String>((ref, userId) async {
  final service = ref.watch(friendServiceProvider);
  final profile = await ref.watch(userProfileProvider(userId).future);

  if (profile == null) return [];

  return service.getFriendSuggestions(userId, profile.grade, profile.level);
});

/// Check if two users are friends
final areFriendsProvider = FutureProvider.family<bool, ({String user1, String user2})>((ref, params) async {
  final service = ref.watch(friendServiceProvider);
  return service.areFriends(params.user1, params.user2);
});

/// Get blocked users list
final blockedUsersProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final service = ref.watch(friendServiceProvider);
  return service.getBlockedUsers(userId);
});

/// ==================== ACTION PROVIDERS ====================

/// Send friend request action
final sendFriendRequestActionProvider = StateProvider<SendFriendRequestParams?>((ref) => null);

final sendFriendRequestProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(sendFriendRequestActionProvider);
  if (params == null) return false;

  final service = ref.watch(friendServiceProvider);
  final result = await service.sendFriendRequest(
    params.senderId,
    params.senderName,
    params.senderAvatar,
    params.receiverId,
  );

  // Invalidate related providers
  if (result) {
    ref.invalidate(sentFriendRequestsProvider(params.senderId));
    ref.invalidate(friendSuggestionsProvider(params.senderId));
  }

  return result;
});

/// Accept friend request action
final acceptFriendRequestActionProvider = StateProvider<AcceptFriendRequestParams?>((ref) => null);

final acceptFriendRequestProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(acceptFriendRequestActionProvider);
  if (params == null) return false;

  final service = ref.watch(friendServiceProvider);
  final result = await service.acceptFriendRequest(
    params.requestId,
    params.userId1,
    params.userId1Name,
    params.userId1Avatar,
    params.userId1Grade,
    params.userId1Level,
    params.userId2,
    params.userId2Name,
    params.userId2Avatar,
    params.userId2Grade,
    params.userId2Level,
  );

  // Invalidate related providers
  if (result) {
    ref.invalidate(friendListProvider(params.userId1));
    ref.invalidate(friendListProvider(params.userId2));
    ref.invalidate(receivedFriendRequestsProvider(params.userId2));
    ref.invalidate(userProfileProvider(params.userId1));
    ref.invalidate(userProfileProvider(params.userId2));
    ref.invalidate(friendSuggestionsProvider(params.userId1));
  }

  return result;
});

/// Decline friend request action
final declineFriendRequestActionProvider = StateProvider<String?>((ref) => null);

final declineFriendRequestProvider = FutureProvider<bool>((ref) async {
  final requestId = ref.watch(declineFriendRequestActionProvider);
  if (requestId == null) return false;

  final service = ref.watch(friendServiceProvider);
  return service.declineFriendRequest(requestId);
});

/// Remove friend action
final removeFriendActionProvider = StateProvider<({String user1, String user2})?>((ref) => null);

final removeFriendProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(removeFriendActionProvider);
  if (params == null) return false;

  final service = ref.watch(friendServiceProvider);
  final result = await service.removeFriend(params.user1, params.user2);

  // Invalidate related providers
  if (result) {
    ref.invalidate(friendListProvider(params.user1));
    ref.invalidate(friendListProvider(params.user2));
    ref.invalidate(userProfileProvider(params.user1));
    ref.invalidate(userProfileProvider(params.user2));
    ref.invalidate(friendSuggestionsProvider(params.user1));
  }

  return result;
});

/// Block user action
final blockUserActionProvider = StateProvider<BlockUserParams?>((ref) => null);

final blockUserProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(blockUserActionProvider);
  if (params == null) return false;

  final service = ref.watch(friendServiceProvider);
  final result = await service.blockUser(params.blockingUserId, params.blockedUserId);

  // Invalidate related providers
  if (result) {
    ref.invalidate(blockedUsersProvider(params.blockingUserId));
    ref.invalidate(friendListProvider(params.blockingUserId));
    ref.invalidate(friendSuggestionsProvider(params.blockingUserId));
  }

  return result;
});

/// Unblock user action
final unblockUserActionProvider = StateProvider<({String blockingUserId, String unblockedUserId})?>((ref) => null);

final unblockUserProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(unblockUserActionProvider);
  if (params == null) return false;

  final service = ref.watch(friendServiceProvider);
  final result = await service.unblockUser(params.blockingUserId, params.unblockedUserId);

  // Invalidate blocked users list
  if (result) {
    ref.invalidate(blockedUsersProvider(params.blockingUserId));
  }

  return result;
});

/// ==================== UI STATE PROVIDERS ====================

/// Selected tab in friends screen (requests, friends, suggestions, blocked)
final friendsScreenTabProvider = StateProvider<FriendsScreenTab>((ref) => FriendsScreenTab.friends);

enum FriendsScreenTab {
  requests,
  friends,
  suggestions,
  blocked,
}
