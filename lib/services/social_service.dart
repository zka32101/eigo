import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_model.dart';
import 'logger_service.dart';

class SocialService {
  static final SocialService _instance = SocialService._internal();

  factory SocialService() {
    return _instance;
  }

  SocialService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('userProfiles').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      _logger.error('Failed to get user profile: $e', 'SocialService');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      await _firestore
          .collection('userProfiles')
          .doc(userId)
          .set(profile.toJson());
      _logger.info('User profile updated: $userId', 'SocialService');
    } catch (e) {
      _logger.error('Failed to update user profile: $e', 'SocialService');
      rethrow;
    }
  }

  // Send friend request
  Future<void> sendFriendRequest(String userId, String friendId) async {
    try {
      final friendRequestId = _firestore.collection('friends').doc().id;
      final friendRequest = Friend(
        id: friendRequestId,
        userId: userId,
        friendId: friendId,
        status: FriendStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('friends')
          .doc(friendRequestId)
          .set(friendRequest.toJson());

      // Create activity
      await recordActivity(
        userId: userId,
        type: ActivityType.friendAdded,
        title: 'フレンドリクエスト送信',
        description: 'フレンドリクエストを送信しました',
        isShared: false,
      );

      _logger.info(
        'Friend request sent from $userId to $friendId',
        'SocialService',
      );
    } catch (e) {
      _logger.error('Failed to send friend request: $e', 'SocialService');
      rethrow;
    }
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String friendRequestId, String userId) async {
    try {
      await _firestore
          .collection('friends')
          .doc(friendRequestId)
          .update({
            'status': 'accepted',
            'acceptedAt': DateTime.now(),
          });

      _logger.info(
        'Friend request accepted: $friendRequestId',
        'SocialService',
      );
    } catch (e) {
      _logger.error('Failed to accept friend request: $e', 'SocialService');
      rethrow;
    }
  }

  // Decline friend request
  Future<void> declineFriendRequest(String friendRequestId) async {
    try {
      await _firestore.collection('friends').doc(friendRequestId).delete();
      _logger.info(
        'Friend request declined: $friendRequestId',
        'SocialService',
      );
    } catch (e) {
      _logger.error('Failed to decline friend request: $e', 'SocialService');
      rethrow;
    }
  }

  // Remove friend
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      final snapshot = await _firestore
          .collection('friends')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Also remove reverse relationship
      final reverseSnapshot = await _firestore
          .collection('friends')
          .where('userId', isEqualTo: friendId)
          .where('friendId', isEqualTo: userId)
          .get();

      for (final doc in reverseSnapshot.docs) {
        await doc.reference.delete();
      }

      _logger.info('Friend removed: $userId, $friendId', 'SocialService');
    } catch (e) {
      _logger.error('Failed to remove friend: $e', 'SocialService');
      rethrow;
    }
  }

  // Get user's friends
  Future<List<Friend>> getUserFriends(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friends')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .orderBy('acceptedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Friend.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Failed to get user friends: $e', 'SocialService');
      rethrow;
    }
  }

  // Get pending friend requests
  Future<List<Friend>> getPendingFriendRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friends')
          .where('friendId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Friend.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error(
        'Failed to get pending friend requests: $e',
        'SocialService',
      );
      rethrow;
    }
  }

  // Check if users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final snapshot = await _firestore
          .collection('friends')
          .where('userId', isEqualTo: userId1)
          .where('friendId', isEqualTo: userId2)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      _logger.error('Failed to check friend status: $e', 'SocialService');
      rethrow;
    }
  }

  // Record activity
  Future<Activity> recordActivity({
    required String userId,
    required ActivityType type,
    required String title,
    required String description,
    String? icon,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    required bool isShared,
    int? xpReward,
    int? coinReward,
  }) async {
    try {
      final activityId = _firestore.collection('activities').doc().id;
      final activity = Activity(
        id: activityId,
        userId: userId,
        type: type,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        icon: icon ?? type.toString().split('.').last,
        imageUrl: imageUrl,
        metadata: metadata,
        isShared: isShared,
        xpReward: xpReward,
        coinReward: coinReward,
      );

      await _firestore
          .collection('activities')
          .doc(activityId)
          .set(activity.toJson());

      _logger.info(
        'Activity recorded for user $userId: $activityId',
        'SocialService',
      );
      return activity;
    } catch (e) {
      _logger.error('Failed to record activity: $e', 'SocialService');
      rethrow;
    }
  }

  // Get user's activities
  Future<List<Activity>> getUserActivities(String userId,
      {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Activity.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Failed to get user activities: $e', 'SocialService');
      rethrow;
    }
  }

  // Get friend feed (activities from friends)
  Future<List<Activity>> getFriendFeed(String userId, {int limit = 50}) async {
    try {
      final friends = await getUserFriends(userId);
      final friendIds = friends.map((f) => f.friendId).toList();

      if (friendIds.isEmpty) {
        return [];
      }

      final snapshot = await _firestore
          .collection('activities')
          .where('userId', whereIn: friendIds)
          .where('isShared', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Activity.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Failed to get friend feed: $e', 'SocialService');
      rethrow;
    }
  }

  // Get social stats
  Future<SocialStats> getSocialStats(String userId) async {
    try {
      final friends = await getUserFriends(userId);
      final pendingRequests = await getPendingFriendRequests(userId);
      final activities = await getUserActivities(userId, limit: 100);

      final now = DateTime.now();
      final monthAgo =
          now.subtract(const Duration(days: 30));
      final weekAgo = now.subtract(const Duration(days: 7));

      final activitiesThisMonth =
          activities.where((a) => a.createdAt.isAfter(monthAgo)).length;
      final activitiesThisWeek =
          activities.where((a) => a.createdAt.isAfter(weekAgo)).length;

      return SocialStats(
        userId: userId,
        totalFriends: friends.length,
        pendingFriendRequests: pendingRequests.length,
        sentFriendRequests: 0, // Could be calculated separately
        totalActivities: activities.length,
        activitiesThisMonth: activitiesThisMonth,
        activitiesThisWeek: activitiesThisWeek,
        likes: 0, // Would require a separate likes system
        comments: 0, // Would require a separate comments system
        recentFriendIds: friends.take(5).map((f) => f.friendId).toList(),
        lastActivityAt: activities.isNotEmpty
            ? activities.first.createdAt
            : DateTime.now(),
      );
    } catch (e) {
      _logger.error('Failed to get social stats: $e', 'SocialService');
      rethrow;
    }
  }

  // Search users
  Future<List<UserProfile>> searchUsers(String query, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('userProfiles')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Failed to search users: $e', 'SocialService');
      rethrow;
    }
  }

  // Compare users
  Future<UserComparison?> compareUsers(String userId1, String userId2) async {
    try {
      final profile1 = await getUserProfile(userId1);
      final profile2 = await getUserProfile(userId2);

      if (profile1 == null || profile2 == null) {
        return null;
      }

      final levelDifference = profile1.level - profile2.level;
      final xpDifference = profile1.totalXp - profile2.totalXp;

      // Determine top skill comparison
      final skill1 = profile1.skillScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final skill2 = profile2.skillScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      return UserComparison(
        userId1: userId1,
        userId2: userId2,
        profile1: profile1,
        profile2: profile2,
        levelDifference: levelDifference,
        xpDifference: xpDifference,
        topSkillComparison: skill1 == skill2 ? skill1 : '$skill1 vs $skill2',
      );
    } catch (e) {
      _logger.error('Failed to compare users: $e', 'SocialService');
      rethrow;
    }
  }

  // Update online status
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore
          .collection('userProfiles')
          .doc(userId)
          .update({
            'isOnline': isOnline,
            'lastActiveAt': DateTime.now(),
          });
    } catch (e) {
      _logger.error('Failed to update online status: $e', 'SocialService');
      // Don't rethrow as this is not critical
    }
  }
}
