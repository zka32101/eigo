import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leaderboard.dart';
import '../models/leaderboard_model.dart' as ranking_model;
import 'logger_service.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();

  factory LeaderboardService() {
    return _instance;
  }

  LeaderboardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// プライバシー設定（showNameInRanking）に応じて表示名を解決する。
  /// showNameInRanking が false（デフォルト）の場合は実名を出さず、
  /// ranking_screen.dart の匿名化パターンに合わせて「ユーザー #XXXX」を返す。
  String _resolveDisplayName(Map<String, dynamic> data, String userId) {
    final actualName = data['name'] as String? ?? 'Unknown';
    final showNameInRanking = data['showNameInRanking'] as bool? ?? false;
    if (showNameInRanking) return actualName;
    return 'ユーザー #${userId.hashCode.abs() % 10000}';
  }

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
          userName: _resolveDisplayName(data, doc.id),
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
      LoggerService.error('Failed to fetch global leaderboard', exception: e);
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
          userName: _resolveDisplayName(data, doc.id),
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
      LoggerService.error('Failed to fetch level leaderboard', exception: e);
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
          userName: _resolveDisplayName(data, doc.id),
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
      LoggerService.error('Failed to fetch weekly leaderboard', exception: e);
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
          userName: _resolveDisplayName(data, doc.id),
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
      LoggerService.error('Failed to fetch friends leaderboard', exception: e);
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
        userName: _resolveDisplayName(userData, userId),
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
      LoggerService.error('Failed to fetch user rank', exception: e);
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
            userName: _resolveDisplayName(data, doc.id),
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
      LoggerService.error('Failed to stream global leaderboard', exception: e);
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
      LoggerService.error('Failed to update user score', exception: e);
      return false;
    }
  }

  // ==================== ranking_model (leaderboard_model.dart) API ====================
  //
  // lib/screens/leaderboard_screen.dart (routed at '/leaderboard' in main.dart) and
  // lib/providers/leaderboard_provider.dart consume the newer `Leaderboard` /
  // `LeaderboardEntry` / `PlayerRankStats` types defined in models/leaderboard_model.dart,
  // not the legacy models above. The methods below build those richer types on top of
  // the same Firestore `users` collection query patterns used elsewhere in this class.

  ranking_model.LeaderboardEntry _toRankingEntry(
    String userId,
    Map<String, dynamic> data,
    int rank, {
    String? currentUserId,
    Set<String> friendIds = const {},
  }) {
    final score = data['score'] as int? ?? 0;
    return ranking_model.LeaderboardEntry(
      userId: userId,
      userName: _resolveDisplayName(data, userId),
      userAvatar: data['avatar'] as String? ?? '?',
      rank: rank,
      score: score,
      level: data['level'] as int? ?? 1,
      xpTotal: data['xpTotal'] as int? ?? score,
      streakDays: data['streakCount'] as int? ?? 0,
      lessonsCompleted: data['lessonsCompleted'] as int? ?? 0,
      challengesWon: data['challengesWon'] as int? ?? 0,
      badgesEarned: data['badgesEarned'] as int? ?? 0,
      updatedAt: data['lastActivityAt'] != null
          ? DateTime.parse(data['lastActivityAt'] as String)
          : DateTime.now(),
      isFriend: friendIds.contains(userId),
      isCurrentUser: currentUserId != null && userId == currentUserId,
    );
  }

  ranking_model.Leaderboard _emptyRanking(
    String id,
    ranking_model.LeaderboardType type,
  ) {
    final now = DateTime.now();
    return ranking_model.Leaderboard(
      id: id,
      type: type,
      metric: ranking_model.RankingMetric.totalScore,
      entries: const [],
      generatedAt: now,
      validUntil: now,
      totalPlayers: 0,
    );
  }

  /// Global ranking using the ranking_model.Leaderboard shape (top users by score).
  Future<ranking_model.Leaderboard> getGlobalLeaderboardRanking({
    int limit = 100,
    String? currentUserId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <ranking_model.LeaderboardEntry>[];
      int rank = 1;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        entries.add(_toRankingEntry(doc.id, data, rank++, currentUserId: currentUserId));
      }

      final now = DateTime.now();
      return ranking_model.Leaderboard(
        id: 'global',
        type: ranking_model.LeaderboardType.global,
        metric: ranking_model.RankingMetric.totalScore,
        entries: entries,
        generatedAt: now,
        validUntil: now.add(const Duration(hours: 1)),
        totalPlayers: entries.length,
      );
    } catch (e) {
      LoggerService.error('Failed to fetch global leaderboard ranking', exception: e);
      return _emptyRanking('global', ranking_model.LeaderboardType.global);
    }
  }

  /// Weekly ranking (last 7 days of activity) using the ranking_model.Leaderboard shape.
  Future<ranking_model.Leaderboard> getWeeklyLeaderboardRanking({
    int limit = 100,
    String? currentUserId,
  }) async {
    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('users')
          .where('lastActivityAt', isGreaterThan: weekAgo.toIso8601String())
          .orderBy('lastActivityAt', descending: true)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <ranking_model.LeaderboardEntry>[];
      int rank = 1;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        entries.add(_toRankingEntry(doc.id, data, rank++, currentUserId: currentUserId));
      }

      final now = DateTime.now();
      return ranking_model.Leaderboard(
        id: 'weekly',
        type: ranking_model.LeaderboardType.weekly,
        metric: ranking_model.RankingMetric.totalScore,
        entries: entries,
        generatedAt: now,
        validUntil: now.add(const Duration(hours: 1)),
        totalPlayers: entries.length,
      );
    } catch (e) {
      LoggerService.error('Failed to fetch weekly leaderboard ranking', exception: e);
      return _emptyRanking('weekly', ranking_model.LeaderboardType.weekly);
    }
  }

  /// Monthly ranking (last 30 days of activity) using the ranking_model.Leaderboard shape.
  Future<ranking_model.Leaderboard> getMonthlyLeaderboardRanking({
    int limit = 100,
    String? currentUserId,
  }) async {
    try {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('users')
          .where('lastActivityAt', isGreaterThan: monthAgo.toIso8601String())
          .orderBy('lastActivityAt', descending: true)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <ranking_model.LeaderboardEntry>[];
      int rank = 1;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        entries.add(_toRankingEntry(doc.id, data, rank++, currentUserId: currentUserId));
      }

      final now = DateTime.now();
      return ranking_model.Leaderboard(
        id: 'monthly',
        type: ranking_model.LeaderboardType.monthly,
        metric: ranking_model.RankingMetric.totalScore,
        entries: entries,
        generatedAt: now,
        validUntil: now.add(const Duration(hours: 1)),
        totalPlayers: entries.length,
      );
    } catch (e) {
      LoggerService.error('Failed to fetch monthly leaderboard ranking', exception: e);
      return _emptyRanking('monthly', ranking_model.LeaderboardType.monthly);
    }
  }

  /// Friends ranking using the ranking_model.Leaderboard shape.
  Future<ranking_model.Leaderboard> getFriendsLeaderboardRanking(
    String userId, {
    int limit = 100,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      final friendIds = Set<String>.from(
        List<String>.from(userData['friends'] as List? ?? []),
      );

      if (friendIds.isEmpty) {
        return _emptyRanking('friends', ranking_model.LeaderboardType.friends);
      }

      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds.toList())
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = <ranking_model.LeaderboardEntry>[];
      int rank = 1;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        entries.add(_toRankingEntry(
          doc.id,
          data,
          rank++,
          currentUserId: userId,
          friendIds: friendIds,
        ));
      }

      final now = DateTime.now();
      return ranking_model.Leaderboard(
        id: 'friends-$userId',
        type: ranking_model.LeaderboardType.friends,
        metric: ranking_model.RankingMetric.totalScore,
        entries: entries,
        generatedAt: now,
        validUntil: now.add(const Duration(hours: 1)),
        totalPlayers: entries.length,
      );
    } catch (e) {
      LoggerService.error('Failed to fetch friends leaderboard ranking', exception: e);
      return _emptyRanking('friends', ranking_model.LeaderboardType.friends);
    }
  }

  /// Player rank stats (global/weekly/monthly rank + percentile) for the ranking screen's
  /// header card. globalRank == 999999 signals "unavailable" to the UI, which hides the
  /// card rather than showing a bogus rank.
  Future<ranking_model.PlayerRankStats> getPlayerRankStats(String userId) async {
    const unavailableRank = 999999;
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return _unavailablePlayerRankStats(userId, unavailableRank);
      }
      final userData = userDoc.data() ?? <String, dynamic>{};
      final userScore = userData['score'] as int? ?? 0;

      final totalUsersSnapshot = await _firestore.collection('users').count().get();
      final totalUsers = totalUsersSnapshot.count ?? 0;

      final globalHigherSnapshot = await _firestore
          .collection('users')
          .where('score', isGreaterThan: userScore)
          .count()
          .get();
      final globalRank = (globalHigherSnapshot.count ?? 0) + 1;

      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weeklyHigherSnapshot = await _firestore
          .collection('users')
          .where('lastActivityAt', isGreaterThan: weekAgo.toIso8601String())
          .where('score', isGreaterThan: userScore)
          .count()
          .get();
      final weeklyRank = (weeklyHigherSnapshot.count ?? 0) + 1;

      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      final monthlyHigherSnapshot = await _firestore
          .collection('users')
          .where('lastActivityAt', isGreaterThan: monthAgo.toIso8601String())
          .where('score', isGreaterThan: userScore)
          .count()
          .get();
      final monthlyRank = (monthlyHigherSnapshot.count ?? 0) + 1;

      int percentileFor(int rank) {
        if (totalUsers <= 0) return 0;
        final value = (((totalUsers - rank) / totalUsers) * 100).round();
        return value.clamp(0, 100);
      }

      return ranking_model.PlayerRankStats(
        userId: userId,
        userName: _resolveDisplayName(userData, userId),
        userAvatar: userData['avatar'] as String? ?? '?',
        globalRank: globalRank,
        weeklyRank: weeklyRank,
        monthlyRank: monthlyRank,
        globalPercentile: percentileFor(globalRank),
        weeklyPercentile: percentileFor(weeklyRank),
        skillRanks: const {},
        totalScore: userScore,
        // No historical snapshot is stored yet, so trend detection is not available.
        previousWeekRank: weeklyRank,
        previousMonthRank: monthlyRank,
        isRankingUp: false,
        isRankingDown: false,
      );
    } catch (e) {
      LoggerService.error('Failed to fetch player rank stats', exception: e);
      return _unavailablePlayerRankStats(userId, unavailableRank);
    }
  }

  ranking_model.PlayerRankStats _unavailablePlayerRankStats(String userId, int unavailableRank) {
    return ranking_model.PlayerRankStats(
      userId: userId,
      userName: 'Unknown',
      userAvatar: '?',
      globalRank: unavailableRank,
      weeklyRank: unavailableRank,
      monthlyRank: unavailableRank,
      globalPercentile: 0,
      weeklyPercentile: 0,
      skillRanks: const {},
      totalScore: 0,
      previousWeekRank: unavailableRank,
      previousMonthRank: unavailableRank,
      isRankingUp: false,
      isRankingDown: false,
    );
  }
}
