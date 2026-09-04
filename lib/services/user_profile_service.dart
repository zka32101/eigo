import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'logger_service.dart';

/// Service for managing user profiles and social features
/// Phase 14 Part 1: Enhanced User Profile System
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();

  factory UserProfileService() {
    return _instance;
  }

  UserProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        _logger.warning('User profile not found', null);
        return null;
      }

      return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Failed to fetch user profile', e);
      return null;
    }
  }

  /// Update user bio
  Future<bool> updateBio(String userId, String bio) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'bio': bio});
      return true;
    } catch (e) {
      _logger.error('Failed to update bio', e);
      return false;
    }
  }

  /// Update user title
  Future<bool> updateTitle(String userId, String title) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'title': title});
      return true;
    } catch (e) {
      _logger.error('Failed to update title', e);
      return false;
    }
  }

  /// Update online status
  Future<bool> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'isOnline': isOnline,
        'lastSeenAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to update online status', e);
      return false;
    }
  }

  /// Add XP and potentially level up
  Future<bool> addXP(String userId, int xpAmount) async {
    try {
      final profile = await getUserProfile(userId);
      if (profile == null) return false;

      int newXP = profile.currentXP + xpAmount;
      int newLevel = profile.level;

      // Level up every 1000 XP
      while (newXP >= 1000) {
        newXP -= 1000;
        newLevel++;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'currentXP': newXP,
        'level': newLevel,
      });

      return true;
    } catch (e) {
      _logger.error('Failed to add XP', e);
      return false;
    }
  }

  /// Increment friend count
  Future<bool> incrementFriendCount(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'friendCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to increment friend count', e);
      return false;
    }
  }

  /// Decrement friend count
  Future<bool> decrementFriendCount(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'friendCount': FieldValue.increment(-1),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to decrement friend count', e);
      return false;
    }
  }

  /// Increment follower count
  Future<bool> incrementFollowerCount(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'followerCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to increment follower count', e);
      return false;
    }
  }

  /// Decrement follower count
  Future<bool> decrementFollowerCount(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'followerCount': FieldValue.increment(-1),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to decrement follower count', e);
      return false;
    }
  }

  /// Increment following count
  Future<bool> incrementFollowingCount(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'followingCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to increment following count', e);
      return false;
    }
  }

  /// Decrement following count
  Future<bool> decrementFollowingCount(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'followingCount': FieldValue.increment(-1),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to decrement following count', e);
      return false;
    }
  }

  /// Update top achievements
  Future<bool> updateTopAchievements(String userId, List<String> achievementIds) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'topAchievementIds': achievementIds.take(5).toList(),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to update top achievements', e);
      return false;
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(
    String userId, {
    bool? allowFriendRequests,
    bool? showOnlineStatus,
    bool? allowMessages,
    bool? showAchievements,
    bool? showStatistics,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (allowFriendRequests != null) updates['allowFriendRequests'] = allowFriendRequests;
      if (showOnlineStatus != null) updates['showOnlineStatus'] = showOnlineStatus;
      if (allowMessages != null) updates['allowMessages'] = allowMessages;
      if (showAchievements != null) updates['showAchievements'] = showAchievements;
      if (showStatistics != null) updates['showStatistics'] = showStatistics;

      if (updates.isEmpty) return true;

      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
      return true;
    } catch (e) {
      _logger.error('Failed to update privacy settings', e);
      return false;
    }
  }

  /// Search users by name
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to search users', e);
      return [];
    }
  }

  /// Get users by level (for leaderboards)
  Future<List<UserProfile>> getUsersByLevel() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('level', descending: true)
          .orderBy('currentXP', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch users by level', e);
      return [];
    }
  }

  /// Get top users by friend count (most social)
  Future<List<UserProfile>> getTopSocialUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('friendCount', descending: true)
          .orderBy('followerCount', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch top social users', e);
      return [];
    }
  }

  /// Update last seen timestamp
  Future<bool> updateLastSeen(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'lastSeenAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _logger.error('Failed to update last seen', e);
      return false;
    }
  }
}
