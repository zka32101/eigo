import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard.dart';
import 'logger_service.dart';

/// Service for managing leaderboards and rankings
/// Phase 15 Part 1: Leaderboards System
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();

  factory LeaderboardService() {
    return _instance;
  }

  LeaderboardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  /// Get global leaderboard (top users by score)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        entries.add(LeaderboardEntry(
          userId: doc.id,
          userName: data['name'] as String? ?? 'Unknown',
          userAvatar: data['avatar'] as String? ?? '?',
          rank: rank++,
          score: data['score'] as int? ?? 0,
          level: data['level'] as int? ?? 1,
          streakCount: data['streakCount'] as int? ?? 0,
          lastActivityAt: data['lastActivityAt'] != null
              ? DateTime.parse(data['lastActivityAt'] as String)
              : DateTime.now(),
          lessonsCompleted: data['lessonsCompleted'] as int? ?? 0,
          averageAccuracy: data['averageAccuracy'] as int? ?? 0,
        ));
      }

      return entries;
    } catch (e) {
      _logger.error('Failed to fetch global leaderboard', e);
      return [];
    }
  }

  /// Get leaderboard for users at a specific level
  Future<List<LeaderboardEntry>> getLevelLeaderboard(
    int level, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('level', isEqualTo: level)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        entries.add(LeaderboardEntry(
          userId: doc.id,
          userName: data['name'] as String? ?? 'Unknown',
          userAvatar: data['avatar'] as String? ?? '?',
          rank: rank++,
          score: data['score'] as int? ?? 0,
          level: level,
          streakCount: data['streakCount'] as int? ?? 0,
          lastActivityAt: data['lastActivityAt'] != null
              ? DateTime.parse(data['lastActivityAt'] as String)
              : DateTime.now(),
          lessonsCompleted: data['lessonsCompleted'] as int? ?? 0,
          averageAccuracy: data['averageAccuracy'] as int? ?? 0,
        ));
      }

      return entries;
    } catch (e) {
      _logger.error('Failed to fetch level leaderboard', e);
      return [];
    }
  }

  /// Get weekly leaderboard (last 7 days)
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard({
    int limit = 100,
  }) async {
    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('users')
          .where('lastActivityAt',
              isGreaterThan: weekAgo.toIso8601String())
          .orderBy('lastActivityAt', descending: true)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        entries.add(LeaderboardEntry(
          userId: doc.id,
          userName: data['name'] as String? ?? 'Unknown',
          userAvatar: data['avatar'] as String? ?? '?',
          rank: rank++,
          score: data['score'] as int? ?? 0,
          level: data['level'] as int? ?? 1,
          streakCount: data['streakCount'] as int? ?? 0,
          lastActivityAt: data['lastActivityAt'] != null
              ? DateTime.parse(data['lastActivityAt'] as String)
              : DateTime.now(),
          lessonsCompleted: data['lessonsCompleted'] as int? ?? 0,
          averageAccuracy: data['averageAccuracy'] as int? ?? 0,
        ));
      }

      return entries;
    } catch (e) {
      _logger.error('Failed to fetch weekly leaderboard', e);
      return [];
    }
  }

  /// Get friends leaderboard
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(
    String userId, {
    int limit = 100,
  }) async {
    try {
      // Get user's friends list
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final friendIds = List<String>.from(userData['friends'] as List? ?? []);

      if (friendIds.isEmpty) {
        return [];
      }

      // Get top entries for friends
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        entries.add(LeaderboardEntry(
          userId: doc.id,
          userName: data['name'] as String? ?? 'Unknown',
          userAvatar: data['avatar'] as String? ?? '?',
          rank: rank++,
          score: data['score'] as int? ?? 0,
          level: data['level'] as int? ?? 1,
          streakCount: data['streakCount'] as int? ?? 0,
          lastActivityAt: data['lastActivityAt'] != null
              ? DateTime.parse(data['lastActivityAt'] as String)
              : DateTime.now(),
          lessonsCompleted: data['lessonsCompleted'] as int? ?? 0,
          averageAccuracy: data['averageAccuracy'] as int? ?? 0,
        ));
      }

      return entries;
    } catch (e) {
      _logger.error('Failed to fetch friends leaderboard', e);
      return [];
    }
  }

  /// Get user's rank and position in global leaderboard
  Future<LeaderboardEntry?> getUserRank(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final userScore = userData['score'] as int? ?? 0;

      // Count users with higher score
      final higherScoreSnapshot = await _firestore
          .collection('users')
          .where('score', isGreaterThan: userScore)
          .count
          .get();

      final rank = (higherScoreSnapshot.count ?? 0) + 1;

      return LeaderboardEntry(
        userId: userId,
        userName: userData['name'] as String? ?? 'Unknown',
        userAvatar: userData['avatar'] as String? ?? '?',
        rank: rank,
        score: userScore,
        level: userData['level'] as int? ?? 1,
        streakCount: userData['streakCount'] as int? ?? 0,
        lastActivityAt: userData['lastActivityAt'] != null
            ? DateTime.parse(userData['lastActivityAt'] as String)
            : DateTime.now(),
        lessonsCompleted: userData['lessonsCompleted'] as int? ?? 0,
        averageAccuracy: userData['averageAccuracy'] as int? ?? 0,
      );
    } catch (e) {
      _logger.error('Failed to fetch user rank', e);
      return null;
    }
  }

  /// Stream global leaderboard for real-time updates
  Stream<List<LeaderboardEntry>> streamGlobalLeaderboard({
    int limit = 100,
  }) {
    try {
      return _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        final entries = <LeaderboardEntry>[];
        int rank = 1;

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          entries.add(LeaderboardEntry(
            userId: doc.id,
            userName: data['name'] as String? ?? 'Unknown',
            userAvatar: data['avatar'] as String? ?? '?',
            rank: rank++,
            score: data['score'] as int? ?? 0,
            level: data['level'] as int? ?? 1,
            streakCount: data['streakCount'] as int? ?? 0,
            lastActivityAt: data['lastActivityAt'] != null
                ? DateTime.parse(data['lastActivityAt'] as String)
                : DateTime.now(),
            lessonsCompleted: data['lessonsCompleted'] as int? ?? 0,
            averageAccuracy: data['averageAccuracy'] as int? ?? 0,
          ));
        }

        return entries;
      });
    } catch (e) {
      _logger.error('Failed to stream global leaderboard', e);
      return Stream.value([]);
    }
  }

  /// Update user's score (called by quiz/lesson completion)
  Future<bool> updateUserScore(
    String userId,
    int pointsEarned,
  ) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final currentScore = userData['score'] as int? ?? 0;

      await _firestore.collection('users').doc(userId).update({
        'score': currentScore + pointsEarned,
        'lastActivityAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.error('Failed to update user score', e);
      return false;
    }
  }
}
