import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/english_town_model.dart';
import '../models/english_town_advanced.dart';
import 'firebase_service.dart';

/// English-Only Town Firebase Service
/// Handles persistent storage and cloud sync for English-Only Town game data
class EnglishTownFirebaseService {
  static final EnglishTownFirebaseService _instance = EnglishTownFirebaseService._internal();

  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  final FirebaseService _baseService = FirebaseService();

  bool _initialized = false;

  EnglishTownFirebaseService._internal();

  factory EnglishTownFirebaseService() {
    return _instance;
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _initialized = true;
    } catch (e) {
      print('English Town Firebase initialization error: $e');
    }
  }

  bool get isInitialized => _initialized;
  bool get isAvailable => _baseService.isAvailable;
  String? get userId => _auth.currentUser?.uid ?? _baseService.userId;

  /// Collection paths
  static const String townProgressCollection = 'english_town_progress';
  static const String townStreaksCollection = 'english_town_streaks';
  static const String townAnalyticsCollection = 'english_town_analytics';
  static const String townLeaderboardCollection = 'english_town_leaderboard';
  static const String townAchievementsCollection = 'english_town_achievements';

  // ==================== PROGRESS SYNC ====================

  /// Sync town progress to cloud
  Future<void> syncTownProgress({
    required TownProgress progress,
    required String displayName,
  }) async {
    if (!isAvailable || userId == null) return;

    try {
      await _firestore.collection(townProgressCollection).doc(userId).set({
        'userId': userId,
        'displayName': displayName,
        'totalConversations': progress.totalConversations,
        'totalXpEarned': progress.totalXpEarned,
        'totalCoinsEarned': progress.totalCoinsEarned,
        'visitedLocationIds': progress.visitedLocationIds.toList(),
        'unlockedAchievements': progress.unlockedAchievements.toList(),
        'npcConversationCounts': progress.npcConversationCounts,
        'currentTimeOfDay': progress.currentTimeOfDay.toString(),
        'currentWeather': progress.currentWeather.toString(),
        'lastSyncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing progress: $e');
    }
  }

  /// Fetch town progress from cloud
  Future<Map<String, dynamic>?> fetchTownProgress() async {
    if (!isAvailable || userId == null) return null;

    try {
      final doc = await _firestore.collection(townProgressCollection).doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error fetching progress: $e');
      return null;
    }
  }

  // ==================== STREAK TRACKING ====================

  /// Update streak for today
  Future<void> updateStreak({
    required int currentStreak,
    required int longestStreak,
    required int totalDaysActive,
  }) async {
    if (!isAvailable || userId == null) return;

    try {
      final today = DateTime.now();
      await _firestore.collection(townStreaksCollection).doc(userId).set({
        'userId': userId,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalDaysActive': totalDaysActive,
        'lastActivityDate': Timestamp.fromDate(today),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  /// Fetch streak data from cloud
  Future<Map<String, dynamic>?> fetchStreak() async {
    if (!isAvailable || userId == null) return null;

    try {
      final doc = await _firestore.collection(townStreaksCollection).doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error fetching streak: $e');
      return null;
    }
  }

  // ==================== ANALYTICS SYNC ====================

  /// Record a single conversation to analytics
  Future<void> recordConversation({
    required String npcId,
    required String locationId,
    required int xpEarned,
    required int coinsEarned,
    required int responseScore,
    required ConversationDifficulty difficulty,
  }) async {
    if (!isAvailable || userId == null) return;

    try {
      final timestamp = DateTime.now();
      final dateKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

      // Record to user's daily analytics
      await _firestore
          .collection(townAnalyticsCollection)
          .doc(userId)
          .collection('daily_records')
          .doc(dateKey)
          .update({
        'conversationCount': FieldValue.increment(1),
        'totalXpEarned': FieldValue.increment(xpEarned),
        'totalCoinsEarned': FieldValue.increment(coinsEarned),
        'averageResponseScore': FieldValue.increment(responseScore.toDouble()),
      }).catchError((_) {
        // Document doesn't exist, create it
        return _firestore
            .collection(townAnalyticsCollection)
            .doc(userId)
            .collection('daily_records')
            .doc(dateKey)
            .set({
          'date': dateKey,
          'conversationCount': 1,
          'totalXpEarned': xpEarned,
          'totalCoinsEarned': coinsEarned,
          'averageResponseScore': responseScore.toDouble(),
          'recordedAt': FieldValue.serverTimestamp(),
        });
      });

      // Record individual conversation
      await _firestore
          .collection(townAnalyticsCollection)
          .doc(userId)
          .collection('conversations')
          .add({
        'npcId': npcId,
        'locationId': locationId,
        'xpEarned': xpEarned,
        'coinsEarned': coinsEarned,
        'responseScore': responseScore,
        'difficulty': difficulty.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording conversation: $e');
    }
  }

  /// Fetch today's analytics
  Future<Map<String, dynamic>?> fetchTodayAnalytics() async {
    if (!isAvailable || userId == null) return null;

    try {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection(townAnalyticsCollection)
          .doc(userId)
          .collection('daily_records')
          .doc(dateKey)
          .get();

      return doc.data();
    } catch (e) {
      print('Error fetching today analytics: $e');
      return null;
    }
  }

  /// Fetch all-time analytics
  Future<Map<String, dynamic>?> fetchAllTimeAnalytics() async {
    if (!isAvailable || userId == null) return null;

    try {
      final doc = await _firestore.collection(townAnalyticsCollection).doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error fetching analytics: $e');
      return null;
    }
  }

  // ==================== LEADERBOARD ====================

  /// Update user's leaderboard entry
  Future<void> updateLeaderboardEntry({
    required String displayName,
    required int totalXp,
    required int totalConversations,
    required int currentStreak,
  }) async {
    if (!isAvailable || userId == null) return;

    try {
      await _firestore.collection(townLeaderboardCollection).doc(userId).set({
        'userId': userId,
        'displayName': displayName,
        'totalXp': totalXp,
        'totalConversations': totalConversations,
        'currentStreak': currentStreak,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating leaderboard: $e');
    }
  }

  /// Fetch global leaderboard (top 50 by XP)
  Future<List<Map<String, dynamic>>> fetchGlobalLeaderboard({
    int limit = 50,
  }) async {
    if (!isAvailable) return [];

    try {
      final snap = await _firestore
          .collection(townLeaderboardCollection)
          .orderBy('totalXp', descending: true)
          .limit(limit)
          .get();

      return snap.docs.asMap().entries.map((entry) {
        final data = entry.value.data();
        data['rank'] = entry.key + 1;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Fetch user's rank on leaderboard
  Future<int?> fetchUserRank() async {
    if (!isAvailable || userId == null) return null;

    try {
      final userDoc = await _firestore.collection(townLeaderboardCollection).doc(userId).get();
      if (!userDoc.exists) return null;

      final userXp = userDoc['totalXp'] ?? 0;
      final snap = await _firestore
          .collection(townLeaderboardCollection)
          .where('totalXp', isGreaterThan: userXp)
          .count()
          .get();

      return snap.count + 1;
    } catch (e) {
      print('Error fetching user rank: $e');
      return null;
    }
  }

  // ==================== ACHIEVEMENTS ====================

  /// Record achievement unlock
  Future<void> recordAchievementUnlock({
    required String achievementId,
    required String achievementTitle,
    required int rewardXp,
  }) async {
    if (!isAvailable || userId == null) return;

    try {
      await _firestore
          .collection(townAchievementsCollection)
          .doc(userId)
          .collection('unlocked')
          .doc(achievementId)
          .set({
        'achievementId': achievementId,
        'achievementTitle': achievementTitle,
        'rewardXp': rewardXp,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording achievement: $e');
    }
  }

  /// Fetch all unlocked achievements
  Future<List<Map<String, dynamic>>> fetchUnlockedAchievements() async {
    if (!isAvailable || userId == null) return [];

    try {
      final snap = await _firestore
          .collection(townAchievementsCollection)
          .doc(userId)
          .collection('unlocked')
          .orderBy('unlockedAt', descending: true)
          .get();

      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  // ==================== ENGAGEMENT ====================

  /// Update engagement score periodically
  Future<void> updateEngagementScore({
    required int engagementScore,
    required int totalSessions,
  }) async {
    if (!isAvailable || userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('english_town')
          .doc('engagement')
          .set({
        'engagementScore': engagementScore,
        'totalSessions': totalSessions,
        'lastCalculatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating engagement score: $e');
    }
  }

  /// Fetch engagement metrics
  Future<Map<String, dynamic>?> fetchEngagementMetrics() async {
    if (!isAvailable || userId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('english_town')
          .doc('engagement')
          .get();

      return doc.data();
    } catch (e) {
      print('Error fetching engagement metrics: $e');
      return null;
    }
  }
}
