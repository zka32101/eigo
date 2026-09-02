import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';

/// Service for leaderboard operations and grade management
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory LeaderboardService() {
    return _instance;
  }

  LeaderboardService._internal();

  // ===== Leaderboard Query Methods =====

  /// Get overall global leaderboard (all users)
  Future<GroupedLeaderboard> getOverallLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .doc('overall')
          .collection('entries')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

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
    } catch (e) {
      print('[LeaderboardService] Error getting overall leaderboard: $e');
      return GroupedLeaderboard(
        groupType: LeaderboardGroupType.overall,
        groupName: 'Overall',
        entries: [],
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get leaderboard for specific grade
  Future<GroupedLeaderboard> getGradeLeaderboard(
    int grade, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .doc('byGrade')
          .collection('grade_$grade')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

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
    } catch (e) {
      print('[LeaderboardService] Error getting grade leaderboard: $e');
      return GroupedLeaderboard(
        groupType: LeaderboardGroupType.byGrade,
        groupName: 'Grade $grade',
        entries: [],
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get leaderboard for specific start month
  Future<GroupedLeaderboard> getStartMonthLeaderboard(
    int year,
    int month, {
    int limit = 100,
  }) async {
    try {
      final monthStr = '${year}-${month.toString().padLeft(2, '0')}';
      final snapshot = await _firestore
          .collection('leaderboard')
          .doc('byMonth')
          .collection('month_$monthStr')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

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
        groupType: LeaderboardGroupType.byStartMonth,
        groupName: 'Started $monthStr',
        entries: entries,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('[LeaderboardService] Error getting month leaderboard: $e');
      return GroupedLeaderboard(
        groupType: LeaderboardGroupType.byStartMonth,
        groupName: 'Started $year-${month.toString().padLeft(2, '0')}',
        entries: [],
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get combined leaderboard (grade × month)
  Future<GroupedLeaderboard> getCombinedLeaderboard(
    int grade,
    int year,
    int month, {
    int limit = 100,
  }) async {
    try {
      final monthStr = '${year}-${month.toString().padLeft(2, '0')}';
      final groupId = 'grade${grade}_month_${monthStr}';
      final snapshot = await _firestore
          .collection('leaderboard')
          .doc('combined')
          .collection(groupId)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

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
        groupType: LeaderboardGroupType.combined,
        groupName: 'Grade $grade - $monthStr',
        entries: entries,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('[LeaderboardService] Error getting combined leaderboard: $e');
      return GroupedLeaderboard(
        groupType: LeaderboardGroupType.combined,
        groupName: 'Grade $grade - Combined',
        entries: [],
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get user's rank in a leaderboard group
  Future<int?> getUserRankPosition(
    String userId,
    LeaderboardGroupType groupType, {
    int? grade,
    int? year,
    int? month,
  }) async {
    try {
      switch (groupType) {
        case LeaderboardGroupType.overall:
          return _getUserRankInLeaderboard(
            'leaderboard/overall/entries',
            userId,
          );
        case LeaderboardGroupType.byGrade:
          if (grade == null) return null;
          return _getUserRankInLeaderboard(
            'leaderboard/byGrade/grade_$grade/entries',
            userId,
          );
        case LeaderboardGroupType.byStartMonth:
          if (year == null || month == null) return null;
          final monthStr = '${year}-${month.toString().padLeft(2, '0')}';
          return _getUserRankInLeaderboard(
            'leaderboard/byMonth/month_$monthStr/entries',
            userId,
          );
        case LeaderboardGroupType.combined:
          if (grade == null || year == null || month == null) return null;
          final monthStr = '${year}-${month.toString().padLeft(2, '0')}';
          final groupId = 'grade${grade}_month_${monthStr}';
          return _getUserRankInLeaderboard(
            'leaderboard/combined/$groupId/entries',
            userId,
          );
      }
    } catch (e) {
      print('[LeaderboardService] Error getting user rank: $e');
      return null;
    }
  }

  /// Helper: Get user rank in specific leaderboard path
  Future<int?> _getUserRankInLeaderboard(
    String leaderboardPath,
    String userId,
  ) async {
    final snapshot = await _firestore
        .collectionGroup('entries')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final allEntries = await _firestore
        .collection(leaderboardPath)
        .orderBy('score', descending: true)
        .get();

    for (int i = 0; i < allEntries.docs.length; i++) {
      if (allEntries.docs[i]['userId'] == userId) {
        return i + 1;
      }
    }

    return null;
  }

  // ===== Grade Management =====

  /// Get user's grade information
  Future<UserGradeInfo?> getUserGradeInfo(String userId) async {
    try {
      final doc = await _firestore
          .collection('userGrades')
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return UserGradeInfo.fromFirestore(doc);
    } catch (e) {
      print('[LeaderboardService] Error getting user grade info: $e');
      return null;
    }
  }

  /// Promote user to next grade
  Future<bool> promoteUser(
    String userId,
    int newGrade, {
    String reason = 'automatic',
    String? performedBy,
  }) async {
    try {
      final gradeInfo = await getUserGradeInfo(userId);
      if (gradeInfo == null) return false;

      final promotion = GradePromotion(
        promotionDate: DateTime.now(),
        previousGrade: gradeInfo.currentGrade,
        newGrade: newGrade,
        reason: reason,
        performedBy: performedBy,
      );

      final updatedInfo = gradeInfo.copyWith(
        currentGrade: newGrade,
        promotionHistory: [promotion, ...gradeInfo.promotionHistory],
        nextPromotionDate: _calculateNextPromotionDate(newGrade),
      );

      await _firestore
          .collection('userGrades')
          .doc(userId)
          .set(updatedInfo.toFirestore());

      print('[LeaderboardService] User promoted: $userId ($newGrade)');
      return true;
    } catch (e) {
      print('[LeaderboardService] Error promoting user: $e');
      return false;
    }
  }

  /// Get promotion configuration
  Future<GradePromotionConfig> getPromotionConfig() async {
    try {
      final doc = await _firestore
          .collection('gradePromotion')
          .doc('config')
          .get();

      if (!doc.exists) {
        return GradePromotionConfig(
          promotionDateStr: '04-01',
          isEnabled: true,
          maxGrade: 6,
        );
      }

      return GradePromotionConfig.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('[LeaderboardService] Error getting promotion config: $e');
      return GradePromotionConfig(
        promotionDateStr: '04-01',
        isEnabled: true,
        maxGrade: 6,
      );
    }
  }

  /// Check and process automatic promotions
  Future<int> checkAndPromoteUsers() async {
    try {
      final config = await getPromotionConfig();
      if (!config.shouldPromoteToday(DateTime.now())) {
        return 0;
      }

      final usersSnapshot = await _firestore
          .collection('userGrades')
          .where('currentGrade', isLessThan: config.maxGrade)
          .get();

      int promotedCount = 0;
      for (final doc in usersSnapshot.docs) {
        final gradeInfo = UserGradeInfo.fromFirestore(doc);
        if (gradeInfo.currentGrade < config.maxGrade) {
          final promoted = await promoteUser(
            gradeInfo.userId,
            gradeInfo.currentGrade + 1,
            reason: 'automatic',
          );
          if (promoted) promotedCount++;
        }
      }

      print('[LeaderboardService] Promoted $promotedCount users');
      return promotedCount;
    } catch (e) {
      print('[LeaderboardService] Error in auto-promotion: $e');
      return 0;
    }
  }

  /// Calculate next promotion date (April 1st of next year)
  DateTime _calculateNextPromotionDate(int newGrade) {
    final now = DateTime.now();
    if (now.month < 4 || (now.month == 4 && now.day < 1)) {
      return DateTime(now.year, 4, 1);
    } else {
      return DateTime(now.year + 1, 4, 1);
    }
  }

  /// Get promotion history for user
  Future<List<GradePromotion>> getUserPromotionHistory(String userId) async {
    try {
      final gradeInfo = await getUserGradeInfo(userId);
      return gradeInfo?.promotionHistory ?? [];
    } catch (e) {
      print('[LeaderboardService] Error getting promotion history: $e');
      return [];
    }
  }
}
