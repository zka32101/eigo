import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/leaderboard_model.dart';
import 'leaderboard_service.dart';

/// Service for leaderboard optimization, caching, and real-time updates
class LeaderboardOptimizationService {
  static final LeaderboardOptimizationService _instance =
      LeaderboardOptimizationService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Cache management
  final Map<String, CachedLeaderboard> _leaderboardCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 15);

  // Real-time listeners
  final Map<String, StreamSubscription> _listeners = {};

  factory LeaderboardOptimizationService() {
    return _instance;
  }

  LeaderboardOptimizationService._internal();

  // ===== Caching Methods =====

  /// Get cached leaderboard or fetch if expired
  Future<GroupedLeaderboard> getCachedLeaderboard(
    String cacheKey,
    Future<GroupedLeaderboard> Function() fetchFunction,
  ) async {
    final now = DateTime.now();
    final lastFetch = _cacheTimestamps[cacheKey];

    // Check if cache is valid
    if (lastFetch != null && now.difference(lastFetch) < _cacheDuration) {
      final cached = _leaderboardCache[cacheKey];
      if (cached != null) {
        print('[LeaderboardOptimization] Cache hit: $cacheKey');
        return cached.leaderboard;
      }
    }

    // Fetch fresh data
    print('[LeaderboardOptimization] Cache miss/expired: $cacheKey');
    final leaderboard = await fetchFunction();

    // Store in cache
    _leaderboardCache[cacheKey] = CachedLeaderboard(
      leaderboard: leaderboard,
      cachedAt: now,
    );
    _cacheTimestamps[cacheKey] = now;

    return leaderboard;
  }

  /// Clear specific cache entry
  void clearCache(String cacheKey) {
    _leaderboardCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    print('[LeaderboardOptimization] Cache cleared: $cacheKey');
  }

  /// Clear all caches
  void clearAllCaches() {
    _leaderboardCache.clear();
    _cacheTimestamps.clear();
    print('[LeaderboardOptimization] All caches cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'totalCached': _leaderboardCache.length,
      'entries': _leaderboardCache.keys.toList(),
      'timestamps': _cacheTimestamps,
      'cacheSize': _estimateCacheSize(),
    };
  }

  /// Estimate cache memory usage
  int _estimateCacheSize() {
    int size = 0;
    for (final cached in _leaderboardCache.values) {
      size += cached.leaderboard.entries.length * 200; // Rough estimate
    }
    return size;
  }

  // ===== Real-Time Updates =====

  /// Stream overall leaderboard updates
  Stream<GroupedLeaderboard> streamOverallLeaderboard() {
    return _firestore
        .collection('leaderboard')
        .doc('overall')
        .collection('entries')
        .orderBy('score', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .asMap()
          .entries
          .map((entry) {
            final data = entry.value.data();
            final index = entry.key;
            data['rank'] = index + 1;
            return LeaderboardEntry.fromMap(data);
          })
          .toList();

      return GroupedLeaderboard(
        groupType: LeaderboardGroupType.overall,
        groupName: 'Overall',
        entries: entries,
        updatedAt: DateTime.now(),
      );
    });
  }

  /// Stream grade leaderboard updates
  Stream<GroupedLeaderboard> streamGradeLeaderboard(int grade) {
    return _firestore
        .collection('leaderboard')
        .doc('byGrade')
        .collection('grade_$grade')
        .orderBy('score', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .asMap()
          .entries
          .map((entry) {
            final data = entry.value.data();
            final index = entry.key;
            data['rank'] = index + 1;
            return LeaderboardEntry.fromMap(data);
          })
          .toList();

      return GroupedLeaderboard(
        groupType: LeaderboardGroupType.byGrade,
        groupName: 'Grade $grade',
        entries: entries,
        updatedAt: DateTime.now(),
      );
    });
  }

  /// Subscribe to user rank changes
  Stream<int?> streamUserRank(
    String userId,
    LeaderboardGroupType groupType,
  ) {
    return _firestore
        .collectionGroup('entries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return null;
      return _leaderboardService.getUserRankPosition(userId, groupType);
    });
  }

  /// Setup listener for user rank changes
  void listenToUserRankChanges(
    String userId,
    LeaderboardGroupType groupType,
    Function(int?) onRankChanged,
  ) {
    final listenerId = '$userId-$groupType';

    // Remove old listener if exists
    _listeners[listenerId]?.cancel();

    // Create new listener
    _listeners[listenerId] = streamUserRank(userId, groupType).listen(
      onRankChanged,
      onError: (error) {
        print('[LeaderboardOptimization] Error in rank listener: $error');
      },
    );

    print('[LeaderboardOptimization] Listener setup: $listenerId');
  }

  /// Remove listener
  void removeListener(String userId, LeaderboardGroupType groupType) {
    final listenerId = '$userId-$groupType';
    _listeners[listenerId]?.cancel();
    _listeners.remove(listenerId);
    print('[LeaderboardOptimization] Listener removed: $listenerId');
  }

  /// Remove all listeners
  void removeAllListeners() {
    for (final listener in _listeners.values) {
      listener.cancel();
    }
    _listeners.clear();
    print('[LeaderboardOptimization] All listeners removed');
  }

  // ===== Seasonal Reset =====

  /// Reset seasonal leaderboards
  Future<void> resetSeasonalLeaderboards({
    required DateTime seasonStartDate,
    required DateTime seasonEndDate,
  }) async {
    try {
      // Archive current leaderboards
      await _archiveLeaderboards(seasonStartDate, seasonEndDate);

      // Clear leaderboard collections
      await _clearLeaderboards();

      print('[LeaderboardOptimization] Seasonal reset complete');
    } catch (e) {
      print('[LeaderboardOptimization] Error in seasonal reset: $e');
    }
  }

  /// Archive leaderboards to history
  Future<void> _archiveLeaderboards(
    DateTime seasonStartDate,
    DateTime seasonEndDate,
  ) async {
    try {
      final seasonKey = '${seasonStartDate.year}-${seasonStartDate.month}';

      // Archive overall leaderboard
      final overallDocs = await _firestore
          .collection('leaderboard')
          .doc('overall')
          .collection('entries')
          .get();

      for (final doc in overallDocs.docs) {
        await _firestore
            .collection('leaderboard')
            .doc('archived')
            .collection('seasons')
            .doc(seasonKey)
            .collection('overall')
            .doc(doc.id)
            .set(doc.data());
      }

      print('[LeaderboardOptimization] Archive complete for season: $seasonKey');
    } catch (e) {
      print('[LeaderboardOptimization] Error archiving leaderboards: $e');
    }
  }

  /// Clear leaderboard collections
  Future<void> _clearLeaderboards() async {
    try {
      // Clear overall
      final overallDocs = await _firestore
          .collection('leaderboard')
          .doc('overall')
          .collection('entries')
          .get();

      for (final doc in overallDocs.docs) {
        await doc.reference.delete();
      }

      print('[LeaderboardOptimization] Leaderboards cleared');
    } catch (e) {
      print('[LeaderboardOptimization] Error clearing leaderboards: $e');
    }
  }

  /// Get archived season leaderboards
  Future<List<Map<String, dynamic>>> getArchivedSeason(String seasonKey) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .doc('archived')
          .collection('seasons')
          .doc(seasonKey)
          .collection('overall')
          .orderBy('score', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('[LeaderboardOptimization] Error getting archived season: $e');
      return [];
    }
  }

  // ===== Batch Operations =====

  /// Batch update leaderboards (for seasonal refreshes)
  Future<void> batchUpdateLeaderboards(
    List<LeaderboardEntry> entries,
    LeaderboardGroupType groupType,
  ) async {
    try {
      final batch = _firestore.batch();
      int operationCount = 0;

      for (final entry in entries) {
        String path = _getLeaderboardPath(groupType, entry);
        final ref = _firestore.doc(path);

        batch.set(ref, entry.toFirestore());
        operationCount++;

        // Firestore batch has 500 operation limit
        if (operationCount >= 500) {
          await batch.commit();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      print('[LeaderboardOptimization] Batch update complete: $groupType');
    } catch (e) {
      print('[LeaderboardOptimization] Error in batch update: $e');
    }
  }

  String _getLeaderboardPath(LeaderboardGroupType groupType, LeaderboardEntry entry) {
    switch (groupType) {
      case LeaderboardGroupType.overall:
        return 'leaderboard/overall/entries/${entry.userId}';
      case LeaderboardGroupType.byGrade:
        return 'leaderboard/byGrade/grade_${entry.grade}/entries/${entry.userId}';
      case LeaderboardGroupType.byStartMonth:
        final month = '${entry.startDate.year}-${entry.startDate.month.toString().padLeft(2, '0')}';
        return 'leaderboard/byMonth/month_$month/entries/${entry.userId}';
      case LeaderboardGroupType.combined:
        final month = '${entry.startDate.year}-${entry.startDate.month.toString().padLeft(2, '0')}';
        final groupId = 'grade${entry.grade}_month_$month';
        return 'leaderboard/combined/$groupId/entries/${entry.userId}';
    }
  }

  // ===== Cleanup =====

  /// Dispose service (cleanup listeners)
  void dispose() {
    removeAllListeners();
    clearAllCaches();
  }
}

/// Cached leaderboard with timestamp
class CachedLeaderboard {
  final GroupedLeaderboard leaderboard;
  final DateTime cachedAt;

  CachedLeaderboard({
    required this.leaderboard,
    required this.cachedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > const Duration(minutes: 15);
}
