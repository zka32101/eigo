import '../models/analytics_model.dart';

/// Service for tracking and aggregating player analytics
class EnglishTownAnalyticsService {
  static final EnglishTownAnalyticsService _instance =
      EnglishTownAnalyticsService._internal();

  factory EnglishTownAnalyticsService() {
    return _instance;
  }

  EnglishTownAnalyticsService._internal();

  // In-memory stores for development
  final Map<String, AnalyticsEvent> _events = {};
  final Map<String, PlayerAnalytics> _playerMetrics = {};
  final Map<String, EngagementScore> _engagementScores = {};
  final Map<DateTime, DailyMetrics> _dailyMetrics = {};

  /// Initialize analytics service
  Future<void> initialize() async {
    print('[Analytics] Service initialized');
    // TODO: Initialize Firestore listeners
  }

  /// Track a generic event
  Future<String> trackEvent(
    String userId,
    AnalyticsEventType type,
    Map<String, dynamic> properties, {
    String? sessionId,
    String? deviceId,
    int? xpGained,
    int? coinsGained,
    String? relatedUserId,
    String? relatedChallengeId,
    int? currentLevel,
    int? currentRank,
  }) async {
    try {
      final eventId = 'event_${DateTime.now().millisecondsSinceEpoch}';

      final event = AnalyticsEvent(
        eventId: eventId,
        userId: userId,
        type: type,
        timestamp: DateTime.now(),
        properties: properties,
        sessionId: sessionId,
        deviceId: deviceId,
        xpGained: xpGained,
        coinsGained: coinsGained,
        relatedUserId: relatedUserId,
        relatedChallengeId: relatedChallengeId,
        currentLevel: currentLevel,
        currentRank: currentRank,
      );

      // TODO: Save to Firestore analytics/events/{eventId}
      _events[eventId] = event;

      print('[Analytics] Event tracked: $type for $userId');
      return eventId;
    } catch (e) {
      print('[Analytics] Error tracking event: $e');
      return '';
    }
  }

  /// Track conversation completion
  Future<void> trackConversation(
    String userId,
    String npcName,
    bool success,
    int xpGained,
    Duration duration,
  ) async {
    await trackEvent(
      userId,
      success
          ? AnalyticsEventType.conversationCompleted
          : AnalyticsEventType.conversationFailed,
      {
        'npcName': npcName,
        'success': success,
        'duration': duration.inSeconds,
      },
      xpGained: xpGained,
    );
  }

  /// Track achievement unlock
  Future<void> trackAchievement(
    String userId,
    String achievementId,
    String title,
    int rewardXp,
  ) async {
    await trackEvent(
      userId,
      AnalyticsEventType.achievementUnlocked,
      {
        'achievementId': achievementId,
        'title': title,
      },
      xpGained: rewardXp,
      relatedChallengeId: achievementId,
    );
  }

  /// Track challenge participation
  Future<void> trackChallenge(
    String userId,
    String challengeId,
    String action, // 'created', 'started', 'completed', 'failed'
    bool success,
  ) async {
    final typeMap = {
      'created': AnalyticsEventType.challengeCreated,
      'started': AnalyticsEventType.challengeStarted,
      'completed': success
          ? AnalyticsEventType.challengeCompleted
          : AnalyticsEventType.challengeFailed,
      'failed': AnalyticsEventType.challengeFailed,
    };

    await trackEvent(
      userId,
      typeMap[action] ?? AnalyticsEventType.challengeStarted,
      {
        'action': action,
        'success': success,
      },
      relatedChallengeId: challengeId,
    );
  }

  /// Track rank change
  Future<void> trackRankChange(
    String userId,
    int previousRank,
    int currentRank,
  ) async {
    final improved = currentRank < previousRank;
    final change = (previousRank - currentRank).abs();

    AnalyticsEventType type = AnalyticsEventType.rankChanged;
    if (currentRank <= 10) type = AnalyticsEventType.topTenAchieved;
    if (currentRank <= 50) type = AnalyticsEventType.top50Achieved;

    await trackEvent(
      userId,
      type,
      {
        'previousRank': previousRank,
        'currentRank': currentRank,
        'improved': improved,
        'change': change,
      },
      currentRank: currentRank,
    );
  }

  /// Track session
  Future<void> trackSession(
    String userId,
    Duration duration,
    int eventCount,
  ) async {
    await trackEvent(
      userId,
      AnalyticsEventType.sessionEnded,
      {
        'duration': duration.inSeconds,
        'eventCount': eventCount,
      },
    );
  }

  /// Get player analytics for a specific period
  Future<PlayerAnalytics?> getPlayerAnalytics(
    String userId, {
    AnalyticsPeriod period = AnalyticsPeriod.daily,
  }) async {
    try {
      // TODO: Query Firestore for playerMetrics/{userId}/{period}/{date}
      final key = '${userId}_${period.toString()}';
      return _playerMetrics[key];
    } catch (e) {
      print('[Analytics] Error getting player analytics: $e');
      return null;
    }
  }

  /// Calculate engagement score for user
  Future<EngagementScore?> calculateEngagementScore(String userId) async {
    try {
      // Get recent player metrics
      final analytics = await getPlayerAnalytics(userId, period: AnalyticsPeriod.daily);
      if (analytics == null) return null;

      // Calculate component scores (0-20 each = 0-100 total)
      double conversationScore = (analytics.totalConversations / 50).clamp(0, 1) * 20;
      double socialScore = ((analytics.friendsAdded + analytics.challengesCompleted) / 20).clamp(0, 1) * 20;
      double progressionScore = (analytics.levelGains / 5).clamp(0, 1) * 20;
      double consistencyScore = (analytics.daysActive / 30).clamp(0, 1) * 20;
      double retentionScore = 20; // Full points if data exists

      final totalScore = conversationScore + socialScore + progressionScore + consistencyScore + retentionScore;

      // Determine tier
      final tier = _getTierFromScore(totalScore);

      final score = EngagementScore(
        userId: userId,
        score: totalScore,
        tier: tier,
        calculatedAt: DateTime.now(),
        conversationScore: conversationScore,
        socialScore: socialScore,
        progressionScore: progressionScore,
        consistencyScore: consistencyScore,
        retentionScore: retentionScore,
      );

      // TODO: Save to Firestore engagementScores/{date}/{userId}
      _engagementScores[userId] = score;

      return score;
    } catch (e) {
      print('[Analytics] Error calculating engagement score: $e');
      return null;
    }
  }

  /// Get leaderboard analytics
  Future<LeaderboardAnalytics?> getLeaderboardAnalytics() async {
    try {
      // TODO: Query Firestore for leaderboardAnalytics/{date}
      // For now, return null
      return null;
    } catch (e) {
      print('[Analytics] Error getting leaderboard analytics: $e');
      return null;
    }
  }

  /// Get daily game-wide metrics
  Future<DailyMetrics?> getDailyMetrics(DateTime date) async {
    try {
      // TODO: Query Firestore for analytics/dailyMetrics/{date}
      return _dailyMetrics[date];
    } catch (e) {
      print('[Analytics] Error getting daily metrics: $e');
      return null;
    }
  }

  /// Get cohort analysis (players grouped by signup date)
  Future<Map<DateTime, double>> getCohortRetention(DateTime cohortDate) async {
    try {
      // TODO: Query Firestore for cohortAnalysis/{cohortDate}
      // Returns week-by-week retention rates
      return {};
    } catch (e) {
      print('[Analytics] Error getting cohort analysis: $e');
      return {};
    }
  }

  /// Determine engagement tier from score
  EngagementTier _getTierFromScore(double score) {
    if (score >= 85) return EngagementTier.hardcore;
    if (score >= 70) return EngagementTier.high;
    if (score >= 40) return EngagementTier.medium;
    if (score >= 20) return EngagementTier.low;
    return EngagementTier.churned;
  }

  /// Get all events for a user
  Future<List<AnalyticsEvent>> getUserEvents(
    String userId, {
    int limit = 100,
  }) async {
    try {
      // TODO: Query Firestore for analytics/events with userId filter
      return _events.values
          .where((e) => e.userId == userId)
          .take(limit)
          .toList();
    } catch (e) {
      print('[Analytics] Error getting user events: $e');
      return [];
    }
  }

  /// Get events by type
  Future<List<AnalyticsEvent>> getEventsByType(
    AnalyticsEventType type, {
    int limit = 100,
  }) async {
    try {
      // TODO: Query Firestore for analytics/events with type filter
      return _events.values
          .where((e) => e.type == type)
          .take(limit)
          .toList();
    } catch (e) {
      print('[Analytics] Error getting events by type: $e');
      return [];
    }
  }
}

/// Extension for LeaderboardAnalytics (placeholder for future)
class LeaderboardAnalytics {
  final DateTime date;
  // TODO: Add segment data and analytics
}
