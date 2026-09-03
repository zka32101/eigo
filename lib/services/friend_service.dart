import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_request.dart';
import '../models/user_profile.dart';
import 'logger_service.dart';

/// Service for managing friend relationships and requests
/// Phase 14 Part 2: Friend System
class FriendService {
  static final FriendService _instance = FriendService._internal();

  factory FriendService() {
    return _instance;
  }

  FriendService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  /// Send a friend request from sender to receiver
  Future<bool> sendFriendRequest(
    String senderId,
    String senderName,
    String senderAvatar,
    String receiverId,
  ) async {
    try {
      // Check if already friends
      final isFriend = await _areFriends(senderId, receiverId);
      if (isFriend) {
        _logger.warning('Already friends', null);
        return false;
      }

      // Check if request already exists
      final requestId = '${senderId}_$receiverId';
      final existingRequest = await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (existingRequest.exists) {
        _logger.warning('Friend request already exists', null);
        return false;
      }

      // Create friend request
      await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .set({
        'id': requestId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'receiverId': receiverId,
        'sentAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      return true;
    } catch (e) {
      _logger.error('Failed to send friend request', e);
      return false;
    }
  }

  /// Accept a friend request
  Future<bool> acceptFriendRequest(
    String requestId,
    String userId1,
    String userId1Name,
    String userId1Avatar,
    int userId1Grade,
    int userId1Level,
    String userId2,
    String userId2Name,
    String userId2Avatar,
    int userId2Grade,
    int userId2Level,
  ) async {
    try {
      final now = DateTime.now();

      // Update request status
      await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .update({'status': 'accepted'});

      // Add to user1's friends
      await _firestore
          .collection('users')
          .doc(userId1)
          .collection('friends')
          .doc(userId2)
          .set({
        'userId': userId2,
        'name': userId2Name,
        'avatar': userId2Avatar,
        'grade': userId2Grade,
        'level': userId2Level,
        'isOnline': false,
        'lastSeenAt': null,
        'addedAt': now.toIso8601String(),
      });

      // Add to user2's friends
      await _firestore
          .collection('users')
          .doc(userId2)
          .collection('friends')
          .doc(userId1)
          .set({
        'userId': userId1,
        'name': userId1Name,
        'avatar': userId1Avatar,
        'grade': userId1Grade,
        'level': userId1Level,
        'isOnline': false,
        'lastSeenAt': null,
        'addedAt': now.toIso8601String(),
      });

      // Increment friend counts for both
      await Future.wait([
        _firestore
            .collection('users')
            .doc(userId1)
            .update({'friendCount': FieldValue.increment(1)}),
        _firestore
            .collection('users')
            .doc(userId2)
            .update({'friendCount': FieldValue.increment(1)}),
      ]);

      return true;
    } catch (e) {
      _logger.error('Failed to accept friend request', e);
      return false;
    }
  }

  /// Decline a friend request
  Future<bool> declineFriendRequest(String requestId) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .update({'status': 'declined'});
      return true;
    } catch (e) {
      _logger.error('Failed to decline friend request', e);
      return false;
    }
  }

  /// Remove a friend
  Future<bool> removeFriend(String userId1, String userId2) async {
    try {
      // Remove from user1's friends
      await _firestore
          .collection('users')
          .doc(userId1)
          .collection('friends')
          .doc(userId2)
          .delete();

      // Remove from user2's friends
      await _firestore
          .collection('users')
          .doc(userId2)
          .collection('friends')
          .doc(userId1)
          .delete();

      // Decrement friend counts
      await Future.wait([
        _firestore
            .collection('users')
            .doc(userId1)
            .update({'friendCount': FieldValue.increment(-1)}),
        _firestore
            .collection('users')
            .doc(userId2)
            .update({'friendCount': FieldValue.increment(-1)}),
      ]);

      return true;
    } catch (e) {
      _logger.error('Failed to remove friend', e);
      return false;
    }
  }

  /// Get received friend requests for a user
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friendRequests')
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequest.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch received friend requests', e);
      return [];
    }
  }

  /// Get sent friend requests for a user
  Future<List<FriendRequest>> getSentFriendRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequest.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch sent friend requests', e);
      return [];
    }
  }

  /// Get friend list for a user
  Future<List<Friend>> getFriendList(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Friend.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch friend list', e);
      return [];
    }
  }

  /// Check if two users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    return _areFriends(userId1, userId2);
  }

  /// Internal helper to check if two users are friends
  Future<bool> _areFriends(String userId1, String userId2) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId1)
          .collection('friends')
          .doc(userId2)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Block a user
  Future<bool> blockUser(String blockingUserId, String blockedUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(blockingUserId)
          .collection('blockedUsers')
          .doc(blockedUserId)
          .set({
        'blockedUserId': blockedUserId,
        'blockedAt': DateTime.now().toIso8601String(),
      });

      // If they were friends, remove friendship
      await removeFriend(blockingUserId, blockedUserId);

      return true;
    } catch (e) {
      _logger.error('Failed to block user', e);
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String blockingUserId, String blockedUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(blockingUserId)
          .collection('blockedUsers')
          .doc(blockedUserId)
          .delete();

      return true;
    } catch (e) {
      _logger.error('Failed to unblock user', e);
      return false;
    }
  }

  /// Get list of blocked users
  Future<List<String>> getBlockedUsers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('blockedUsers')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      _logger.error('Failed to fetch blocked users', e);
      return [];
    }
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String blockingUserId, String potentiallyBlockedUserId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(blockingUserId)
          .collection('blockedUsers')
          .doc(potentiallyBlockedUserId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get friend suggestions (users with similar grade/level)
  Future<List<UserProfile>> getFriendSuggestions(
    String userId,
    int userGrade,
    int userLevel,
  ) async {
    try {
      final userFriends = await getFriendList(userId);
      final friendIds = userFriends.map((f) => f.userId).toSet();
      final blockedUsers = await getBlockedUsers(userId);

      // Get users with similar grade
      final snapshot = await _firestore
          .collection('users')
          .where('grade', isEqualTo: userGrade)
          .limit(30)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
          .where((profile) =>
              profile.id != userId &&
              !friendIds.contains(profile.id) &&
              !blockedUsers.contains(profile.id))
          .toList()
          .sublist(0, (10).clamp(0, snapshot.docs.length)); // Return top 10
    } catch (e) {
      _logger.error('Failed to fetch friend suggestions', e);
      return [];
    }
  }

  /// Cancel sent friend request
  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .delete();

      return true;
    } catch (e) {
      _logger.error('Failed to cancel friend request', e);
      return false;
    }
  }
}
