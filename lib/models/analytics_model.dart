import 'package:flutter/foundation.dart';

/// Analytics event types tracked throughout the game
enum AnalyticsEventType {
  // Conversation events
  conversationStarted,
  conversationCompleted,
  conversationFailed,
  npcInteraction,

  // Achievement events
  achievementUnlocked,
  achievementProgressed,

  // Social events
  friendRequestSent,
  friendRequestAccepted,
  friendRemoved,
  challengeCreated,
  challengeStarted,
  challengeCompleted,
  challengeFailed,

  // Leaderboard events
  rankChanged,
  topTenAchieved,
  top50Achieved,

  // Streak events
  streakStarted,
  streakMaintained,
  streakBroken,
  streakMilestoneReached,

  // Session events
  sessionStarted,
  sessionEnded,
  appOpened,
  appClosed,

  // Store/Purchase events
  coinsPurchased,
  premiumActivated,
  itemPurchased,

  // Engagement events
  dailyLoginMilestone,
  weeklyActiveCheck,
  monthlyActiveCheck,
}

/// Single analytics event
class AnalyticsEvent {
  final String eventId;
  final String userId;
  final AnalyticsEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final String? sessionId;
  final String? deviceId;

  // Context fields
  final int? xpGained;
  final int? coinsGained;
  final String? relatedUserId;
  final String? relatedChallengeId;
  final int? currentLevel;
  final int? currentRank;

  AnalyticsEvent({
    required this.eventId,
    required this.userId,
    required this.type,
    required this.timestamp,
    this.properties = const {},
    this.sessionId,
    this.deviceId,
    this.xpGained,
    this.coinsGained,
    this.relatedUserId,
    this.relatedChallengeId,
    this.currentLevel,
    this.currentRank,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'properties': properties,
      'sessionId': sessionId,
      'deviceId': deviceId,
      'xpGained': xpGained,
      'coinsGained': coinsGained,
      'relatedUserId': relatedUserId,
      'relatedChallengeId': relatedChallengeId,
      'currentLevel': currentLevel,
      'currentRank': currentRank,
    };
  }

  factory AnalyticsEvent.fromFirestore(Map<String, dynamic> doc) {
    return AnalyticsEvent(
      eventId: doc['eventId'] as String,
      userId: doc['userId'] as String,
      type: _parseEventType(doc['type'] as String),
      timestamp: DateTime.parse(doc['timestamp'] as String),
      properties: Map<String, dynamic>.from(doc['properties'] as Map? ?? {}),
      sessionId: doc['sessionId'] as String?,
      deviceId: doc['deviceId'] as String?,
      xpGained: doc['xpGained'] as int?,
      coinsGained: doc['coinsGained'] as int?,
      relatedUserId: doc['relatedUserId'] as String?,
      relatedChallengeId: doc['relatedChallengeId'] as String?,
      currentLevel: doc['currentLevel'] as int?,
      currentRank: doc['currentRank'] as int?,
    );
  }

  static AnalyticsEventType _parseEventType(String typeStr) {
    return AnalyticsEventType.values.firstWhere(
      (e) => e.toString() == typeStr,
      orElse: () => AnalyticsEventType.conversationCompleted,
    );
  }
}

/// Analytics period types
enum AnalyticsPeriod {
  daily,
  weekly,
  monthly,
  allTime,
}

/// Aggregated player analytics for a period
class PlayerAnalytics {
  final String userId;
  final AnalyticsPeriod period;
  final DateTime dateStart;
  final DateTime dateEnd;

  // Conversation metrics
  final int totalConversations;
  final int successfulConversations;
  final double conversionRate;
  final int totalConversationDuration;

  // Achievement metrics
  final int achievementsUnlocked;
  final int achievementProgress;

  // Social metrics
  final int friendsAdded;
  final int friendsRemoved;
  final int challengesCreated;
  final int challengesCompleted;
  final int challengeWins;
  final double challengeWinRate;

  // Progression metrics
  final int xpGained;
  final int coinsGained;
  final int levelGains;
  final int? currentRank;
  final int rankImprovement;

  // Engagement metrics
  final int sessionCount;
  final int totalPlayTime; // seconds
  final int averageSessionDuration; // seconds
  final int daysActive;
  final int? currentStreak;

  // Derived scores
  final double engagementScore;
  final String engagementTier;

  PlayerAnalytics({
    required this.userId,
    required this.period,
    required this.dateStart,
    required this.dateEnd,
    required this.totalConversations,
    required this.successfulConversations,
    required this.conversionRate,
    required this.totalConversationDuration,
    required this.achievementsUnlocked,
    required this.achievementProgress,
    required this.friendsAdded,
    required this.friendsRemoved,
    required this.challengesCreated,
    required this.challengesCompleted,
    required this.challengeWins,
    required this.challengeWinRate,
    required this.xpGained,
    required this.coinsGained,
    required this.levelGains,
    this.currentRank,
    required this.rankImprovement,
    required this.sessionCount,
    required this.totalPlayTime,
    required this.averageSessionDuration,
    required this.daysActive,
    this.currentStreak,
    required this.engagementScore,
    required this.engagementTier,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'period': period.toString(),
      'dateStart': dateStart.toIso8601String(),
      'dateEnd': dateEnd.toIso8601String(),
      'totalConversations': totalConversations,
      'successfulConversations': successfulConversations,
      'conversionRate': conversionRate,
      'totalConversationDuration': totalConversationDuration,
      'achievementsUnlocked': achievementsUnlocked,
      'achievementProgress': achievementProgress,
      'friendsAdded': friendsAdded,
      'friendsRemoved': friendsRemoved,
      'challengesCreated': challengesCreated,
      'challengesCompleted': challengesCompleted,
      'challengeWins': challengeWins,
      'challengeWinRate': challengeWinRate,
      'xpGained': xpGained,
      'coinsGained': coinsGained,
      'levelGains': levelGains,
      'currentRank': currentRank,
      'rankImprovement': rankImprovement,
      'sessionCount': sessionCount,
      'totalPlayTime': totalPlayTime,
      'averageSessionDuration': averageSessionDuration,
      'daysActive': daysActive,
      'currentStreak': currentStreak,
      'engagementScore': engagementScore,
      'engagementTier': engagementTier,
    };
  }

  factory PlayerAnalytics.fromFirestore(Map<String, dynamic> doc) {
    return PlayerAnalytics(
      userId: doc['userId'] as String,
      period: AnalyticsPeriod.values.firstWhere(
        (e) => e.toString() == doc['period'],
        orElse: () => AnalyticsPeriod.daily,
      ),
      dateStart: DateTime.parse(doc['dateStart'] as String),
      dateEnd: DateTime.parse(doc['dateEnd'] as String),
      totalConversations: doc['totalConversations'] as int? ?? 0,
      successfulConversations: doc['successfulConversations'] as int? ?? 0,
      conversionRate: doc['conversionRate'] as double? ?? 0.0,
      totalConversationDuration: doc['totalConversationDuration'] as int? ?? 0,
      achievementsUnlocked: doc['achievementsUnlocked'] as int? ?? 0,
      achievementProgress: doc['achievementProgress'] as int? ?? 0,
      friendsAdded: doc['friendsAdded'] as int? ?? 0,
      friendsRemoved: doc['friendsRemoved'] as int? ?? 0,
      challengesCreated: doc['challengesCreated'] as int? ?? 0,
      challengesCompleted: doc['challengesCompleted'] as int? ?? 0,
      challengeWins: doc['challengeWins'] as int? ?? 0,
      challengeWinRate: doc['challengeWinRate'] as double? ?? 0.0,
      xpGained: doc['xpGained'] as int? ?? 0,
      coinsGained: doc['coinsGained'] as int? ?? 0,
      levelGains: doc['levelGains'] as int? ?? 0,
      currentRank: doc['currentRank'] as int?,
      rankImprovement: doc['rankImprovement'] as int? ?? 0,
      sessionCount: doc['sessionCount'] as int? ?? 0,
      totalPlayTime: doc['totalPlayTime'] as int? ?? 0,
      averageSessionDuration: doc['averageSessionDuration'] as int? ?? 0,
      daysActive: doc['daysActive'] as int? ?? 0,
      currentStreak: doc['currentStreak'] as int?,
      engagementScore: doc['engagementScore'] as double? ?? 0.0,
      engagementTier: doc['engagementTier'] as String? ?? 'medium',
    );
  }
}

/// Engagement score and tier
class EngagementScore {
  final String userId;
  final double score; // 0-100
  final EngagementTier tier;
  final DateTime calculatedAt;

  // Component scores
  final double conversationScore;
  final double socialScore;
  final double progressionScore;
  final double consistencyScore;
  final double retentionScore;

  EngagementScore({
    required this.userId,
    required this.score,
    required this.tier,
    required this.calculatedAt,
    required this.conversationScore,
    required this.socialScore,
    required this.progressionScore,
    required this.consistencyScore,
    required this.retentionScore,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'score': score,
      'tier': tier.toString(),
      'calculatedAt': calculatedAt.toIso8601String(),
      'conversationScore': conversationScore,
      'socialScore': socialScore,
      'progressionScore': progressionScore,
      'consistencyScore': consistencyScore,
      'retentionScore': retentionScore,
    };
  }

  factory EngagementScore.fromFirestore(Map<String, dynamic> doc) {
    return EngagementScore(
      userId: doc['userId'] as String,
      score: doc['score'] as double? ?? 0.0,
      tier: EngagementTier.values.firstWhere(
        (e) => e.toString().contains(doc['tier'] as String? ?? 'medium'),
        orElse: () => EngagementTier.medium,
      ),
      calculatedAt: DateTime.parse(doc['calculatedAt'] as String),
      conversationScore: doc['conversationScore'] as double? ?? 0.0,
      socialScore: doc['socialScore'] as double? ?? 0.0,
      progressionScore: doc['progressionScore'] as double? ?? 0.0,
      consistencyScore: doc['consistencyScore'] as double? ?? 0.0,
      retentionScore: doc['retentionScore'] as double? ?? 0.0,
    );
  }
}

/// Engagement tier classification
enum EngagementTier {
  churned,      // No activity in 30+ days
  low,          // Some activity but irregular
  medium,       // Regular player, few daily logins
  high,         // Very active, consistent engagement
  hardcore,     // Daily player with high social engagement
}

extension EngagementTierHelper on EngagementTier {
  String displayName() {
    switch (this) {
      case EngagementTier.churned:
        return 'Churned';
      case EngagementTier.low:
        return 'Low Engagement';
      case EngagementTier.medium:
        return 'Regular Player';
      case EngagementTier.high:
        return 'Very Active';
      case EngagementTier.hardcore:
        return 'Hardcore';
    }
  }

  String description() {
    switch (this) {
      case EngagementTier.churned:
        return 'No activity in 30+ days';
      case EngagementTier.low:
        return 'Some activity but irregular';
      case EngagementTier.medium:
        return 'Regular player, few daily logins';
      case EngagementTier.high:
        return 'Very active, consistent engagement';
      case EngagementTier.hardcore:
        return 'Daily player with high social engagement';
    }
  }

  int minScore() {
    switch (this) {
      case EngagementTier.churned:
        return 0;
      case EngagementTier.low:
        return 20;
      case EngagementTier.medium:
        return 40;
      case EngagementTier.high:
        return 70;
      case EngagementTier.hardcore:
        return 85;
    }
  }
}

/// Daily game-wide metrics
class DailyMetrics {
  final DateTime date;
  final int dailyActiveUsers;
  final int newPlayers;
  final int churnedPlayers;

  // Engagement
  final double averageSessionDuration;
  final double averageConversationsPerUser;
  final double conversationCompletionRate;

  // Social
  final int friendRequestsSent;
  final int challengesCreated;
  final int challengesCompleted;

  // Progression
  final int totalXpDistributed;
  final int totalCoinsDistributed;
  final int achievementsUnlocked;

  // Retention
  final double dayOneRetention;
  final double day7Retention;
  final double day30Retention;

  DailyMetrics({
    required this.date,
    required this.dailyActiveUsers,
    required this.newPlayers,
    required this.churnedPlayers,
    required this.averageSessionDuration,
    required this.averageConversationsPerUser,
    required this.conversationCompletionRate,
    required this.friendRequestsSent,
    required this.challengesCreated,
    required this.challengesCompleted,
    required this.totalXpDistributed,
    required this.totalCoinsDistributed,
    required this.achievementsUnlocked,
    required this.dayOneRetention,
    required this.day7Retention,
    required this.day30Retention,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'date': date.toIso8601String(),
      'dailyActiveUsers': dailyActiveUsers,
      'newPlayers': newPlayers,
      'churnedPlayers': churnedPlayers,
      'averageSessionDuration': averageSessionDuration,
      'averageConversationsPerUser': averageConversationsPerUser,
      'conversationCompletionRate': conversationCompletionRate,
      'friendRequestsSent': friendRequestsSent,
      'challengesCreated': challengesCreated,
      'challengesCompleted': challengesCompleted,
      'totalXpDistributed': totalXpDistributed,
      'totalCoinsDistributed': totalCoinsDistributed,
      'achievementsUnlocked': achievementsUnlocked,
      'dayOneRetention': dayOneRetention,
      'day7Retention': day7Retention,
      'day30Retention': day30Retention,
    };
  }

  factory DailyMetrics.fromFirestore(Map<String, dynamic> doc) {
    return DailyMetrics(
      date: DateTime.parse(doc['date'] as String),
      dailyActiveUsers: doc['dailyActiveUsers'] as int? ?? 0,
      newPlayers: doc['newPlayers'] as int? ?? 0,
      churnedPlayers: doc['churnedPlayers'] as int? ?? 0,
      averageSessionDuration: doc['averageSessionDuration'] as double? ?? 0.0,
      averageConversationsPerUser: doc['averageConversationsPerUser'] as double? ?? 0.0,
      conversationCompletionRate: doc['conversationCompletionRate'] as double? ?? 0.0,
      friendRequestsSent: doc['friendRequestsSent'] as int? ?? 0,
      challengesCreated: doc['challengesCreated'] as int? ?? 0,
      challengesCompleted: doc['challengesCompleted'] as int? ?? 0,
      totalXpDistributed: doc['totalXpDistributed'] as int? ?? 0,
      totalCoinsDistributed: doc['totalCoinsDistributed'] as int? ?? 0,
      achievementsUnlocked: doc['achievementsUnlocked'] as int? ?? 0,
      dayOneRetention: doc['dayOneRetention'] as double? ?? 0.0,
      day7Retention: doc['day7Retention'] as double? ?? 0.0,
      day30Retention: doc['day30Retention'] as double? ?? 0.0,
    );
  }
}
