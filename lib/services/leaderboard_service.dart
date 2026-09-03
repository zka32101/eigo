import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';
import 'logger_service.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();

  factory LeaderboardService() {
    return _instance;
  }

  LeaderboardService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _logger = LoggerService();

  // Get global leaderboard
  Future<Leaderboard> getGlobalLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc('global')
          .get();

      if (!snapshot.exists) {
        return _createEmptyLeaderboard('global', LeaderboardType.global);
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Leaderboard.fromJson(data);
    } catch (e) {
      _logger.error('Error fetching global leaderboard', e);
      return _createEmptyLeaderboard('global', LeaderboardType.global);
    }
  }

  // Get weekly leaderboard
  Future<Leaderboard> getWeeklyLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc('weekly')
          .get();

      if (!snapshot.exists) {
        return _createEmptyLeaderboard('weekly', LeaderboardType.weekly);
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Leaderboard.fromJson(data);
    } catch (e) {
      _logger.error('Error fetching weekly leaderboard', e);
      return _createEmptyLeaderboard('weekly', LeaderboardType.weekly);
    }
  }

  // Get monthly leaderboard
  Future<Leaderboard> getMonthlyLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc('monthly')
          .get();

      if (!snapshot.exists) {
        return _createEmptyLeaderboard('monthly', LeaderboardType.monthly);
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Leaderboard.fromJson(data);
    } catch (e) {
      _logger.error('Error fetching monthly leaderboard', e);
      return _createEmptyLeaderboard('monthly', LeaderboardType.monthly);
    }
  }

  // Get friend leaderboard
  Future<Leaderboard> getFriendsLeaderboard(String userId, {int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc('friends_$userId')
          .get();

      if (!snapshot.exists) {
        return _createEmptyLeaderboard('friends_$userId', LeaderboardType.friends);
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Leaderboard.fromJson(data);
    } catch (e) {
      _logger.error('Error fetching friend leaderboard', e);
      return _createEmptyLeaderboard('friends_$userId', LeaderboardType.friends);
    }
  }

  // Get skill-based leaderboard (listening, speaking, reading, writing)
  Future<Leaderboard> getSkillLeaderboard(String skill, {int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc('skill_$skill')
          .get();

      if (!snapshot.exists) {
        return _createEmptyLeaderboard('skill_$skill', LeaderboardType.skillBased);
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Leaderboard.fromJson(data);
    } catch (e) {
      _logger.error('Error fetching skill leaderboard for $skill', e);
      return _createEmptyLeaderboard('skill_$skill', LeaderboardType.skillBased);
    }
  }

  // Get player's ranking statistics
  Future<PlayerRankStats> getPlayerRankStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('player_ranks')
          .doc(userId)
          .get();

      if (!snapshot.exists) {
        return _createDefaultPlayerStats(userId);
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return PlayerRankStats.fromJson(data);
    } catch (e) {
      _logger.error('Error fetching player rank stats', e);
      return _createDefaultPlayerStats(userId);
    }
  }

  // Compare two players' rankings
  Future<RankingComparison> comparePlayerRankings(
    String userId1,
    String userId2,
  ) async {
    try {
      final stats1 = await getPlayerRankStats(userId1);
      final stats2 = await getPlayerRankStats(userId2);

      final scoreDiff = stats1.totalScore - stats2.totalScore;

      return RankingComparison(
        userId1: userId1,
        userId2: userId2,
        userName1: stats1.userName,
        userName2: stats2.userName,
        userAvatar1: stats1.userAvatar,
        userAvatar2: stats2.userAvatar,
        rank1: stats1.globalRank,
        rank2: stats2.globalRank,
        score1: stats1.totalScore,
        score2: stats2.totalScore,
        scoreDifference: scoreDiff,
        user1IsAhead: scoreDiff > 0,
        skillComparison: _compareSkills(stats1.skillRanks, stats2.skillRanks),
      );
    } catch (e) {
      _logger.error('Error comparing player rankings', e);
      throw Exception('ランキング比較に失敗しました');
    }
  }

  // Get leaderboard statistics
  Future<LeaderboardStats> getLeaderboardStats() async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc('stats')
          .get();

      if (!snapshot.exists) {
        return _createDefaultStats();
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return LeaderboardStats.fromJson(data);
    } catch (e) {
      _logger.error('Error fetching leaderboard stats', e);
      return _createDefaultStats();
    }
  }

  // Search leaderboard entries by username
  Future<List<LeaderboardEntry>> searchLeaderboard(
    String query, {
    LeaderboardType type = LeaderboardType.global,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboards')
          .doc(type.toString())
          .collection('entries')
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThan: '${query}z')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error searching leaderboard', e);
      return [];
    }
  }

  // Get entries around player's rank (top 10, player's rank ±5)
  Future<List<LeaderboardEntry>> getEntriesAroundRank(
    String userId,
    LeaderboardType type,
  ) async {
    try {
      final leaderboard = await _getLeaderboardByType(type);
      final playerEntry = leaderboard.findCurrentUserEntry(userId);

      if (playerEntry == null) {
        return leaderboard.entries.take(20).toList();
      }

      final startRank = (playerEntry.rank - 5).clamp(1, leaderboard.entries.length);
      final endRank = (playerEntry.rank + 5).clamp(1, leaderboard.entries.length);

      return leaderboard.entries
          .where((e) => e.rank >= startRank && e.rank <= endRank)
          .toList();
    } catch (e) {
      _logger.error('Error getting entries around rank', e);
      return [];
    }
  }

  // Helper methods

  Future<Leaderboard> _getLeaderboardByType(LeaderboardType type) async {
    switch (type) {
      case LeaderboardType.global:
        return getGlobalLeaderboard();
      case LeaderboardType.weekly:
        return getWeeklyLeaderboard();
      case LeaderboardType.monthly:
        return getMonthlyLeaderboard();
      default:
        return getGlobalLeaderboard();
    }
  }

  Map<String, int> _compareSkills(
    Map<String, int> skills1,
    Map<String, int> skills2,
  ) {
    final comparison = <String, int>{};
    final allSkills = {...skills1.keys, ...skills2.keys};

    for (final skill in allSkills) {
      final rank1 = skills1[skill] ?? 999;
      final rank2 = skills2[skill] ?? 999;
      comparison[skill] = rank2 - rank1; // Positive = player 1 ahead
    }

    return comparison;
  }

  Leaderboard _createEmptyLeaderboard(String id, LeaderboardType type) {
    final now = DateTime.now();
    return Leaderboard(
      id: id,
      type: type,
      metric: RankingMetric.totalScore,
      entries: [],
      generatedAt: now,
      validUntil: now.add(const Duration(days: 7)),
      totalPlayers: 0,
    );
  }

  PlayerRankStats _createDefaultPlayerStats(String userId) {
    return PlayerRankStats(
      userId: userId,
      userName: 'Unknown',
      userAvatar: '👤',
      globalRank: 999999,
      weeklyRank: 999999,
      monthlyRank: 999999,
      globalPercentile: 0,
      weeklyPercentile: 0,
      skillRanks: {},
      totalScore: 0,
      previousWeekRank: 999999,
      previousMonthRank: 999999,
      isRankingUp: false,
      isRankingDown: false,
    );
  }

  LeaderboardStats _createDefaultStats() {
    return LeaderboardStats(
      id: 'stats',
      totalLeaderboards: 0,
      totalPlayers: 0,
      newPlayersThisWeek: 0,
      avgPlayersPerLeaderboard: 0,
      topSkillsRanked: {},
      lastUpdated: DateTime.now(),
    );
  }
}
