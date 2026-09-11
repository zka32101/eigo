import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/achievement.dart';
import 'logger_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();

  factory AchievementService() {
    return _instance;
  }

  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new achievement (admin only)
  Future<String?> createAchievement(
    String name,
    String description,
    String icon,
    AchievementCategory category,
    int requiredValue,
    int rewardPoints,
  ) async {
    try {
      final achievementId = _firestore.collection('achievements').doc().id;
      final now = DateTime.now();

      await _firestore.collection('achievements').doc(achievementId).set({
        'id': achievementId,
        'name': name,
        'description': description,
        'icon': icon,
        'category': category.toString().split('.').last,
        'requiredValue': requiredValue,
        'rewardPoints': rewardPoints,
        'createdAt': now.toIso8601String(),
      });

      return achievementId;
    } catch (e) {
      LoggerService.error('Failed to create achievement', exception: e);
      return null;
    }
  }

  /// Create a new badge (admin only)
  Future<String?> createBadge(
    String name,
    String description,
    String icon,
    BadgeRarity rarity,
    String? achievementId,
  ) async {
    try {
      final badgeId = _firestore.collection('badges').doc().id;
      final now = DateTime.now();

      await _firestore.collection('badges').doc(badgeId).set({
        'id': badgeId,
        'name': name,
        'description': description,
        'icon': icon,
        'rarity': rarity.toString().split('.').last,
        'achievementId': achievementId,
        'createdAt': now.toIso8601String(),
      });

      return badgeId;
    } catch (e) {
      LoggerService.error('Failed to create badge', exception: e);
      return null;
    }
  }

  /// Unlock an achievement for a user
  Future<bool> unlockAchievement(
    String userId,
    String achievementId,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Check if already unlocked
      final achievements = List<String>.from(userData['achievements'] as List? ?? []);
      if (achievements.contains(achievementId)) {
        return false;
      }

      // Get achievement details
      final achievementDoc = await _firestore.collection('achievements').doc(achievementId).get();
      final achievementData = achievementDoc.data() as Map<String, dynamic>;
      final rewardPoints = achievementData['rewardPoints'] as int? ?? 0;

      // Add to user achievements
      achievements.add(achievementId);

      // Add reward points
      final currentScore = userData['score'] as int? ?? 0;

      await userRef.update({
        'achievements': achievements,
        'score': currentScore + rewardPoints,
      });

      // Record achievement unlock
      await userRef
          .collection('achievements')
          .doc(achievementId)
          .set({
        'achievementId': achievementId,
        'unlockedAt': DateTime.now().toIso8601String(),
        'progress': 100,
      });

      return true;
    } catch (e) {
      LoggerService.error('Failed to unlock achievement', exception: e);
      return false;
    }
  }

  /// Update achievement progress
  Future<bool> updateAchievementProgress(
    String userId,
    String achievementId,
    int progress,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef
          .collection('achievements')
          .doc(achievementId)
          .set({
        'achievementId': achievementId,
        'progress': progress,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      LoggerService.error('Failed to update achievement progress', exception: e);
      return false;
    }
  }

  /// Award a badge to a user
  Future<bool> awardBadge(
    String userId,
    String badgeId,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Check if already earned
      final badges = List<String>.from(userData['badges'] as List? ?? []);
      if (badges.contains(badgeId)) {
        return false;
      }

      badges.add(badgeId);

      await userRef.update({
        'badges': badges,
      });

      // Record badge earn
      await userRef
          .collection('badges')
          .doc(badgeId)
          .set({
        'badgeId': badgeId,
        'earnedAt': DateTime.now().toIso8601String(),
        'isEquipped': false,
      });

      return true;
    } catch (e) {
      LoggerService.error('Failed to award badge', exception: e);
      return false;
    }
  }

  /// Equip a badge
  Future<bool> equipBadge(
    String userId,
    String badgeId,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Unequip previous badge
      final previousBadge = await userRef
          .collection('badges')
          .where('isEquipped', isEqualTo: true)
          .limit(1)
          .get();

      if (previousBadge.docs.isNotEmpty) {
        await previousBadge.docs.first.reference.update({
          'isEquipped': false,
        });
      }

      // Equip new badge
      await userRef
          .collection('badges')
          .doc(badgeId)
          .update({
        'isEquipped': true,
      });

      return true;
    } catch (e) {
      LoggerService.error('Failed to equip badge', exception: e);
      return false;
    }
  }

  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final snapshot = await _firestore
          .collection('achievements')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to fetch achievements', exception: e);
      return [];
    }
  }

  /// Get user's achievements
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final userAchievements = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .orderBy('unlockedAt', descending: true)
          .get();

      final results = <UserAchievement>[];

      for (final doc in userAchievements.docs) {
        final achievementId = doc.data()['achievementId'] as String;
        final achievementDoc = await _firestore
            .collection('achievements')
            .doc(achievementId)
            .get();

        if (achievementDoc.exists) {
          results.add(UserAchievement(
            userId: userId,
            achievementId: achievementId,
            achievement: Achievement.fromJson(
              achievementDoc.data() as Map<String, dynamic>,
            ),
            unlockedAt: DateTime.parse(doc.data()['unlockedAt'] as String),
            progress: doc.data()['progress'] as int? ?? 100,
          ));
        }
      }

      return results;
    } catch (e) {
      LoggerService.error('Failed to fetch user achievements', exception: e);
      return [];
    }
  }

  /// Get all badges
  Future<List<Badge>> getAllBadges() async {
    try {
      final snapshot = await _firestore
          .collection('badges')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Badge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to fetch badges', exception: e);
      return [];
    }
  }

  /// Get user's badges
  Future<List<UserBadge>> getUserBadges(String userId) async {
    try {
      final userBadges = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .orderBy('earnedAt', descending: true)
          .get();

      final results = <UserBadge>[];

      for (final doc in userBadges.docs) {
        final badgeId = doc.data()['badgeId'] as String;
        final badgeDoc = await _firestore
            .collection('badges')
            .doc(badgeId)
            .get();

        if (badgeDoc.exists) {
          results.add(UserBadge(
            userId: userId,
            badgeId: badgeId,
            badge: Badge.fromJson(badgeDoc.data() as Map<String, dynamic>),
            earnedAt: DateTime.parse(doc.data()['earnedAt'] as String),
            isEquipped: doc.data()['isEquipped'] as bool? ?? false,
          ));
        }
      }

      return results;
    } catch (e) {
      LoggerService.error('Failed to fetch user badges', exception: e);
      return [];
    }
  }

  /// Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(
    AchievementCategory category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('achievements')
          .where('category', isEqualTo: category.toString().split('.').last)
          .orderBy('requiredValue')
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to fetch achievements by category', exception: e);
      return [];
    }
  }

  /// Get badges by rarity
  Future<List<Badge>> getBadgesByRarity(BadgeRarity rarity) async {
    try {
      final snapshot = await _firestore
          .collection('badges')
          .where('rarity', isEqualTo: rarity.toString().split('.').last)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Badge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to fetch badges by rarity', exception: e);
      return [];
    }
  }

  /// Stream user achievements for real-time updates
  Stream<List<UserAchievement>> streamUserAchievements(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .orderBy('unlockedAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final results = <UserAchievement>[];

        for (final doc in snapshot.docs) {
          final achievementId = doc.data()['achievementId'] as String;
          final achievementDoc = await _firestore
              .collection('achievements')
              .doc(achievementId)
              .get();

          if (achievementDoc.exists) {
            results.add(UserAchievement(
              userId: userId,
              achievementId: achievementId,
              achievement: Achievement.fromJson(
                achievementDoc.data() as Map<String, dynamic>,
              ),
              unlockedAt: DateTime.parse(doc.data()['unlockedAt'] as String),
              progress: doc.data()['progress'] as int? ?? 100,
            ));
          }
        }

        return results;
      });
    } catch (e) {
      LoggerService.error('Failed to stream user achievements', exception: e);
      return Stream.value([]);
    }
  }
}
