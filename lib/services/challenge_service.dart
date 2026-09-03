import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import 'logger_service.dart';

/// Service for managing social challenges and rewards
class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();

  factory ChallengeService() {
    return _instance;
  }

  ChallengeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== Challenge Management =====

  /// Get all active challenges
  Future<List<SocialChallenge>> getActiveChallenges() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('challenges')
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: Timestamp.fromDate(now))
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching active challenges',
        tag: 'ChallengeService',
        exception: e,
      );
      return [];
    }
  }

  /// Get challenges by type
  Future<List<SocialChallenge>> getChallengesByType(ChallengeType type) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('challenges')
          .where('type', isEqualTo: type.name)
          .where('endDate', isGreaterThan: Timestamp.fromDate(now))
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching challenges by type',
        tag: 'ChallengeService',
        exception: e,
      );
      return [];
    }
  }

  /// Get specific challenge
  Future<SocialChallenge?> getChallenge(String challengeId) async {
    try {
      final doc = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) return null;

      return SocialChallenge.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching challenge',
        tag: 'ChallengeService',
        exception: e,
      );
      return null;
    }
  }

  /// Join challenge
  Future<bool> joinChallenge(String userId, String challengeId) async {
    try {
      final challenge = await getChallenge(challengeId);
      if (challenge == null) return false;

      // Create user challenge progress
      await _firestore
          .collection('userChallengeProgress')
          .doc(userId)
          .collection('challenges')
          .doc(challengeId)
          .set({
            'userId': userId,
            'challengeId': challengeId,
            'progress': 0,
            'isCompleted': false,
            'joinedAt': Timestamp.now(),
            'completedAt': null,
            'earnedRewardIds': [],
            'isAchieved': false,
          });

      // Add user to challenge participants
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .update({
            'participantIds': FieldValue.arrayUnion([userId]),
            'participantCount': FieldValue.increment(1),
          });

      LoggerService.info(
        'User $userId joined challenge $challengeId',
        tag: 'ChallengeService',
      );

      return true;
    } catch (e) {
      LoggerService.error(
        'Error joining challenge',
        tag: 'ChallengeService',
        exception: e,
      );
      return false;
    }
  }

  // ===== Progress Tracking =====

  /// Update user challenge progress
  Future<void> updateChallengeProgress(
    String userId,
    String challengeId,
    int newProgress,
  ) async {
    try {
      final challenge = await getChallenge(challengeId);
      if (challenge == null) return;

      final isCompleted = newProgress >= challenge.targetValue;
      final completedAt = isCompleted ? DateTime.now() : null;

      await _firestore
          .collection('userChallengeProgress')
          .doc(userId)
          .collection('challenges')
          .doc(challengeId)
          .update({
            'progress': newProgress,
            'isCompleted': isCompleted,
            if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt),
          });

      // Update challenge leaderboard
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .update({
            'leaderboard.$userId': newProgress,
          });

      LoggerService.info(
        'Challenge progress updated: $challengeId, progress: $newProgress',
        tag: 'ChallengeService',
      );
    } catch (e) {
      LoggerService.error(
        'Error updating challenge progress',
        tag: 'ChallengeService',
        exception: e,
      );
    }
  }

  /// Get user challenge progress
  Future<UserChallengeProgress?> getUserChallengeProgress(
    String userId,
    String challengeId,
  ) async {
    try {
      final doc = await _firestore
          .collection('userChallengeProgress')
          .doc(userId)
          .collection('challenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) return null;

      return UserChallengeProgress.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching user challenge progress',
        tag: 'ChallengeService',
        exception: e,
      );
      return null;
    }
  }

  /// Get user's active challenges
  Future<List<UserChallengeProgress>> getUserActiveChallenges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userChallengeProgress')
          .doc(userId)
          .collection('challenges')
          .where('isCompleted', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) => UserChallengeProgress.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching user active challenges',
        tag: 'ChallengeService',
        exception: e,
      );
      return [];
    }
  }

  /// Get user's completed challenges
  Future<List<UserChallengeProgress>> getUserCompletedChallenges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userChallengeProgress')
          .doc(userId)
          .collection('challenges')
          .where('isCompleted', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserChallengeProgress.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching user completed challenges',
        tag: 'ChallengeService',
        exception: e,
      );
      return [];
    }
  }

  // ===== Rewards =====

  /// Claim rewards for challenge
  Future<List<ChallengeReward>> claimChallengeRewards(
    String userId,
    String challengeId,
  ) async {
    try {
      final challenge = await getChallenge(challengeId);
      final progress = await getUserChallengeProgress(userId, challengeId);

      if (challenge == null || progress == null) return [];

      // Calculate earned rewards based on progress percentage
      final progressPercent = (progress.progress / challenge.targetValue * 100).toInt();
      final earnedRewards = <ChallengeReward>[];
      final earnedRewardIds = <String>[];

      for (final reward in challenge.rewards) {
        if (progressPercent >= reward.minProgress && !progress.earnedRewardIds.contains(reward.id)) {
          earnedRewards.add(reward);
          earnedRewardIds.add(reward.id);
        }
      }

      if (earnedRewardIds.isNotEmpty) {
        // Update earned rewards
        await _firestore
            .collection('userChallengeProgress')
            .doc(userId)
            .collection('challenges')
            .doc(challengeId)
            .update({
              'earnedRewardIds': FieldValue.arrayUnion(earnedRewardIds),
              'isAchieved': true,
            });

        // Award coins and XP
        int totalCoins = 0;
        int totalXp = 0;

        for (final reward in earnedRewards) {
          totalCoins += reward.coinReward;
          totalXp += reward.xpReward;
        }

        // Update user stats (would integrate with user service)
        LoggerService.info(
          'Rewards claimed: $challengeId, coins: $totalCoins, xp: $totalXp',
          tag: 'ChallengeService',
        );
      }

      return earnedRewards;
    } catch (e) {
      LoggerService.error(
        'Error claiming rewards',
        tag: 'ChallengeService',
        exception: e,
      );
      return [];
    }
  }

  // ===== Leaderboard =====

  /// Get challenge leaderboard (top participants)
  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
    String challengeId, {
    int limit = 100,
  }) async {
    try {
      final challenge = await getChallenge(challengeId);
      if (challenge == null) return [];

      // Sort leaderboard by progress
      final leaderboardEntries = challenge.leaderboard.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return leaderboardEntries.take(limit).map((entry) {
        return {
          'userId': entry.key,
          'progress': entry.value,
        };
      }).toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching challenge leaderboard',
        tag: 'ChallengeService',
        exception: e,
      );
      return [];
    }
  }

  /// Get user's rank in challenge
  Future<int?> getUserChallengeRank(String userId, String challengeId) async {
    try {
      final leaderboard = await getChallengeLeaderboard(challengeId, limit: 1000);

      int rank = 0;
      for (final entry in leaderboard) {
        rank++;
        if (entry['userId'] == userId) {
          return rank;
        }
      }

      return null;
    } catch (e) {
      LoggerService.error(
        'Error fetching user challenge rank',
        tag: 'ChallengeService',
        exception: e,
      );
      return null;
    }
  }

  // ===== Friend Challenges =====

  /// Create friend challenge (invite)
  Future<FriendChallenge?> createFriendChallenge(
    String userId,
    String friendId,
    String description,
    int targetValue,
  ) async {
    try {
      final challengeId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 7));

      final friendChallenge = FriendChallenge(
        id: challengeId,
        initiatorId: userId,
        opponentId: friendId,
        description: description,
        startDate: now,
        endDate: endDate,
        targetValue: targetValue,
      );

      await _firestore
          .collection('friendChallenges')
          .doc(challengeId)
          .set(friendChallenge.toJson());

      LoggerService.info(
        'Friend challenge created: $userId vs $friendId',
        tag: 'ChallengeService',
      );

      return friendChallenge;
    } catch (e) {
      LoggerService.error(
        'Error creating friend challenge',
        tag: 'ChallengeService',
        exception: e,
      );
      return null;
    }
  }

  /// Get friend challenges for user
  Future<List<FriendChallenge>> getUserFriendChallenges(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('friendChallenges')
          .where('endDate', isGreaterThan: Timestamp.fromDate(now))
          .get();

      final challenges = snapshot.docs
          .map((doc) => FriendChallenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter for user (as initiator or opponent)
      return challenges
          .where((c) => c.initiatorId == userId || c.opponentId == userId)
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching user friend challenges',
        tag: 'ChallengeService',
        exception: e,
      );
      return [];
    }
  }

  /// Update friend challenge progress
  Future<void> updateFriendChallengeProgress(
    String challengeId,
    String userId,
    int progress,
  ) async {
    try {
      final doc = await _firestore
          .collection('friendChallenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) return;

      final challenge = FriendChallenge.fromJson(doc.data() as Map<String, dynamic>);

      late FriendChallenge updatedChallenge;

      if (challenge.initiatorId == userId) {
        updatedChallenge = challenge.copyWith(initiatorProgress: progress);
      } else {
        updatedChallenge = challenge.copyWith(opponentProgress: progress);
      }

      // Check if completed
      if (updatedChallenge.initiatorProgress >= challenge.targetValue ||
          updatedChallenge.opponentProgress >= challenge.targetValue) {
        updatedChallenge = updatedChallenge.copyWith(
          isCompleted: true,
          winnerId: updatedChallenge.initiatorProgress > updatedChallenge.opponentProgress
              ? challenge.initiatorId
              : challenge.opponentId,
        );
      }

      await _firestore
          .collection('friendChallenges')
          .doc(challengeId)
          .update(updatedChallenge.toJson());

      LoggerService.info(
        'Friend challenge progress updated: $challengeId',
        tag: 'ChallengeService',
      );
    } catch (e) {
      LoggerService.error(
        'Error updating friend challenge progress',
        tag: 'ChallengeService',
        exception: e,
      );
    }
  }

  // ===== Statistics =====

  /// Get challenge statistics
  Future<ChallengeStats?> getChallengeStats(String challengeId) async {
    try {
      final doc = await _firestore
          .collection('challengeStats')
          .doc(challengeId)
          .get();

      if (!doc.exists) return null;

      return ChallengeStats.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching challenge stats',
        tag: 'ChallengeService',
        exception: e,
      );
      return null;
    }
  }

  /// Get user's challenge statistics
  Future<Map<String, dynamic>> getUserChallengeStats(String userId) async {
    try {
      final activeChallenges = await getUserActiveChallenges(userId);
      final completedChallenges = await getUserCompletedChallenges(userId);

      return {
        'activeChallenges': activeChallenges.length,
        'completedChallenges': completedChallenges.length,
        'totalCoinsEarned': _calculateTotalCoinsEarned(completedChallenges),
        'totalXpEarned': _calculateTotalXpEarned(completedChallenges),
        'successRate': completedChallenges.isEmpty
            ? 0.0
            : (completedChallenges.where((c) => c.isAchieved).length /
                    (activeChallenges.length + completedChallenges.length)) *
                100,
      };
    } catch (e) {
      LoggerService.error(
        'Error fetching user challenge stats',
        tag: 'ChallengeService',
        exception: e,
      );
      return {};
    }
  }

  // ===== Private Helpers =====

  int _calculateTotalCoinsEarned(List<UserChallengeProgress> challenges) {
    int total = 0;
    // This would need to access rewards data, simplified here
    return total;
  }

  int _calculateTotalXpEarned(List<UserChallengeProgress> challenges) {
    int total = 0;
    // This would need to access rewards data, simplified here
    return total;
  }
}
