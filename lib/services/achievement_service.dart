import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';
import 'logger_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();

  factory AchievementService() {
    return _instance;
  }

  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  // Get all available achievements
  Future<List<Achievement>> getAchievements() async {
    try {
      final snapshot = await _firestore
          .collection('achievements')
          .orderBy('tier')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch achievements', e);
      return [];
    }
  }

  // Get achievements by type
  Future<List<Achievement>> getAchievementsByType(AchievementType type) async {
    try {
      final snapshot = await _firestore
          .collection('achievements')
          .where('type', isEqualTo: type.toString().split('.').last)
          .orderBy('tier')
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch achievements by type', e);
      return [];
    }
  }

  // Get user's unlocked achievements
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserAchievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch user achievements', e);
      return [];
    }
  }

  // Get unclaimed achievements
  Future<List<UserAchievement>> getUnclaimedAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .where('isRewarded', isEqualTo: false)
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserAchievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch unclaimed achievements', e);
      return [];
    }
  }

  // Unlock achievement for user
  Future<bool> unlockAchievement(String userId, String achievementId) async {
    try {
      // Get achievement details
      final achievementDoc = await _firestore
          .collection('achievements')
          .doc(achievementId)
          .get();

      if (!achievementDoc.exists) {
        _logger.error('Achievement not found', null);
        return false;
      }

      final achievement = Achievement.fromJson(achievementDoc.data() as Map<String, dynamic>);

      // Check if already unlocked
      final existingDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .get();

      if (existingDoc.exists && achievement.maxCount == null) {
        // Non-repeatable achievement already unlocked
        return false;
      }

      // Create or update user achievement
      final userAchievementId = '${userId}_$achievementId';
      final userAchievement = UserAchievement(
        id: userAchievementId,
        userId: userId,
        achievementId: achievementId,
        unlockedAt: DateTime.now(),
        unlockedCount: (existingDoc.exists
                ? (existingDoc.data()!['unlockedCount'] as int? ?? 0) + 1
                : 1),
        isNewlySeen: true,
        isRewarded: false,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .set(userAchievement.toJson(), SetOptions(merge: true));

      // Create achievement notification
      await _createAchievementNotification(userId, achievement);

      // Update stats
      await _updateAchievementStats(userId);

      return true;
    } catch (e) {
      _logger.error('Failed to unlock achievement', e);
      return false;
    }
  }

  // Claim achievement rewards
  Future<Map<String, dynamic>> claimAchievementRewards(
    String userId,
    String achievementId,
  ) async {
    try {
      // Get achievement
      final achievementDoc = await _firestore
          .collection('achievements')
          .doc(achievementId)
          .get();

      if (!achievementDoc.exists) {
        return {'success': false, 'message': 'Achievement not found'};
      }

      final achievement = Achievement.fromJson(achievementDoc.data() as Map<String, dynamic>);

      // Get user achievement
      final userAchievementDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .get();

      if (!userAchievementDoc.exists) {
        return {'success': false, 'message': 'Achievement not unlocked'};
      }

      final userAchievement =
          UserAchievement.fromJson(userAchievementDoc.data() as Map<String, dynamic>);

      if (userAchievement.isRewarded) {
        return {'success': false, 'message': 'Rewards already claimed'};
      }

      // Update user achievement
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .update({
        'isRewarded': true,
        'claimedAt': DateTime.now().toIso8601String(),
        'isNewlySeen': false,
      });

      return {
        'success': true,
        'xp': achievement.rewardXp,
        'coins': achievement.rewardCoins,
        'badges': achievement.rewardBadges,
      };
    } catch (e) {
      _logger.error('Failed to claim achievement rewards', e);
      return {'success': false, 'message': 'Error claiming rewards'};
    }
  }

  // Get achievement progress
  Future<AchievementProgress?> getAchievementProgress(
    String userId,
    String achievementId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievementProgress')
          .doc(achievementId)
          .get();

      if (!doc.exists) return null;

      return AchievementProgress.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Failed to fetch achievement progress', e);
      return null;
    }
  }

  // Record user activity and check achievements
  Future<void> recordActivityAndCheckAchievements(
    String userId,
    String activityType,
    int value,
  ) async {
    try {
      // Update relevant achievement progress based on activity type
      // This is called from other services when activities occur

      // Get all achievement requirements that match this activity
      final achievementsSnapshot = await _firestore
          .collection('achievements')
          .where('tags', arrayContains: activityType)
          .get();

      for (final doc in achievementsSnapshot.docs) {
        final achievement = Achievement.fromJson(doc.data() as Map<String, dynamic>);

        // Get current progress
        var progressDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('achievementProgress')
            .doc(achievement.id)
            .get();

        int currentProgress = 0;
        if (progressDoc.exists) {
          currentProgress = (progressDoc.data()!['currentProgress'] as int? ?? 0);
        }

        int newProgress = currentProgress + value;

        // Save progress
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('achievementProgress')
            .doc(achievement.id)
            .set({
          'id': '${userId}_${achievement.id}',
          'userId': userId,
          'achievementId': achievement.id,
          'currentProgress': newProgress,
          'targetProgress': achievement.requiredValue,
          'lastUpdatedAt': DateTime.now().toIso8601String(),
          'isUnlocked': newProgress >= achievement.requiredValue,
        });

        // Unlock if target reached
        if (newProgress >= achievement.requiredValue) {
          await unlockAchievement(userId, achievement.id);
        }
      }
    } catch (e) {
      _logger.error('Failed to record activity and check achievements', e);
    }
  }

  // Get achievement statistics for user
  Future<AchievementStats?> getAchievementStats(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('achievements')
          .get();

      if (!doc.exists) return null;

      return AchievementStats.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Failed to fetch achievement stats', e);
      return null;
    }
  }

  // Get recently unlocked achievements
  Future<List<UserAchievement>> getRecentUnlockedAchievements(
    String userId,
    int limit,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .where('isRewarded', isEqualTo: true)
          .orderBy('unlockedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserAchievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch recent achievements', e);
      return [];
    }
  }

  // Get achievement notifications
  Future<List<AchievementNotification>> getAchievementNotifications(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievementNotifications')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => AchievementNotification.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch achievement notifications', e);
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievementNotifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      _logger.error('Failed to mark notification as read', e);
    }
  }

  // Private helper methods

  Future<void> _createAchievementNotification(
    String userId,
    Achievement achievement,
  ) async {
    try {
      final notification = AchievementNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        achievementId: achievement.id,
        achievementName: achievement.name,
        icon: achievement.icon,
        rewardXp: achievement.rewardXp,
        rewardCoins: achievement.rewardCoins,
        createdAt: DateTime.now(),
        isRead: false,
        isRewarded: false,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievementNotifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      _logger.error('Failed to create achievement notification', e);
    }
  }

  Future<void> _updateAchievementStats(String userId) async {
    try {
      final userAchievementsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      final achievements = userAchievementsSnapshot.docs
          .map((doc) => UserAchievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      int totalXp = 0;
      int totalCoins = 0;
      List<String> badges = [];

      for (final userAch in achievements) {
        if (userAch.isRewarded) {
          final achDoc = await _firestore
              .collection('achievements')
              .doc(userAch.achievementId)
              .get();

          if (achDoc.exists) {
            final ach = Achievement.fromJson(achDoc.data() as Map<String, dynamic>);
            totalXp += ach.rewardXp;
            totalCoins += ach.rewardCoins;
            badges.addAll(ach.rewardBadges);
          }
        }
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('achievements')
          .set({
        'userId': userId,
        'totalAchievements': 0, // TODO: Fetch from achievements collection
        'unlockedCount': achievements.length,
        'claimedCount': achievements.where((a) => a.isRewarded).length,
        'totalXpEarned': totalXp,
        'totalCoinsEarned': totalCoins,
        'unlockedBadges': badges,
        'typeBreakdown': {},
        'tierBreakdown': {},
        'lastAchievementAt': DateTime.now().toIso8601String(),
        'currentStreak': 0,
      });
    } catch (e) {
      _logger.error('Failed to update achievement stats', e);
    }
  }
}
