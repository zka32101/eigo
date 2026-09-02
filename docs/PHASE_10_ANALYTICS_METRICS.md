# Phase 10: Advanced Analytics & Metrics System

## Overview

Phase 10 implements comprehensive analytics and metrics tracking across all game systems. This enables data-driven insights into player engagement, social features usage, progression patterns, and game health metrics. The system tracks events, aggregates data, and provides analytics dashboards for players and administrators.

## Architecture

### Core Components

#### 1. **Analytics Event System** (`english_town_analytics_event.dart`)
Defines all trackable events across the game.

```dart
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
  milestoneMilestoneReached,
  
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

class AnalyticsEvent {
  final String eventId;
  final String userId;
  final AnalyticsEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final String? sessionId;
  final String? deviceId;
  
  // Additional context
  final int? xpGained;
  final int? coinsGained;
  final String? relatedUserId;
  final String? relatedChallengeId;
  final int? currentLevel;
  final int? currentRank;
}
```

#### 2. **Analytics Service** (`english_town_analytics_service.dart`)
Manages event tracking and aggregation.

**Key Methods:**
```dart
trackEvent(userId, eventType, properties)
trackConversation(userId, npcName, success, xpGained, duration)
trackAchievement(userId, achievementId, title, rewardXp)
trackChallenge(userId, challengeId, action, success)
trackRankChange(userId, previousRank, currentRank)
trackSession(userId, duration, eventsCount)
trackPurchase(userId, itemId, amount, currency)

// Aggregations
getPlayerAnalytics(userId) -> PlayerAnalytics
getDailyMetrics(date) -> DailyMetrics
getWeeklyMetrics(weekStart) -> WeeklyMetrics
getMonthlyMetrics(yearMonth) -> MonthlyMetrics
```

#### 3. **Player Analytics Model** (`player_analytics_model.dart`)
Represents aggregated player metrics.

```dart
class PlayerAnalytics {
  final String userId;
  final String period; // 'daily', 'weekly', 'monthly', 'all_time'
  
  // Conversation metrics
  final int totalConversations;
  final int successfulConversations;
  final double conversionRate; // Success rate
  final int averageResponseTime;
  
  // Achievement metrics
  final int achievementsUnlocked;
  final int totalAchievementProgress;
  final int averageTimeToAchievement;
  
  // Social metrics
  final int friendsAdded;
  final int challengesCreated;
  final int challengesCompleted;
  final int challengeWinRate;
  final int totalFriendInteractions;
  
  // Progression metrics
  final int xpGained;
  final int coinsGained;
  final int levelGains;
  final int currentRank;
  final int rankChanges;
  final int bestRankAchieved;
  
  // Engagement metrics
  final int sessionCount;
  final int totalPlayTime;
  final int averageSessionDuration;
  final int daysActive;
  final int currentStreak;
  final int longestStreak;
  
  // Retention metrics
  final bool isActive;
  final bool isChurned;
  final DateTime? lastActiveAt;
  final int daysSinceLastActive;
}
```

#### 4. **Leaderboard Analytics** (`leaderboard_analytics_model.dart`)
Segment-based analytics for rankings.

```dart
class LeaderboardSegment {
  final String segmentName; // 'top_10', 'top_100', 'mid_tier', 'casual'
  final int minRank;
  final int maxRank;
  final int playerCount;
  
  // Segment metrics
  final double averageXp;
  final double averageLevel;
  final double averageConversations;
  final double churnRate;
  final double avgEngagementScore;
}

class LeaderboardAnalytics {
  final DateTime period;
  final Map<String, LeaderboardSegment> segments;
  
  // Dynamics
  final int playerMomentum; // Rank changes per day
  final int newPlayersLastWeek;
  final int churned PlayersLastWeek;
  final double competitivenessScore; // How competitive is top 100
}
```

#### 5. **Cohort Analysis** (`cohort_analysis_model.dart`)
Group players by signup date and track behavior.

```dart
class CohortAnalysis {
  final DateTime cohortDate; // Signup date
  final int cohortSize; // Players who signed up this week
  
  // Week-over-week retention
  final Map<int, double> retentionByWeek; // {week: retention %}
  
  // Day-over-day engagement
  final Map<int, double> engagementByDay; // {day: avg engagement score}
  
  // Progression rates
  final double lvl5ReachRate; // % reaching level 5
  final double lvl10ReachRate;
  final double lvl20ReachRate;
  final Map<int, double> levelReachRates;
  
  // Monetization (if applicable)
  final double conversionRate; // % making purchase
  final double averageRevenuePerUser;
  final double lifetimeValue;
}
```

#### 6. **Engagement Score** (`engagement_score_calculator.dart`)
Calculates comprehensive engagement metrics.

```dart
class EngagementScore {
  final String userId;
  final double score; // 0-100
  final EngagementTier tier; // Churned, Low, Medium, High, Hardcore
  
  // Component scores
  final double conversationScore; // Based on activity
  final double socialScore; // Friend interactions, challenges
  final double progressionScore; // Level, XP, streak
  final double consistencyScore; // Daily activity patterns
  final double retentionScore; // Days active last 30 days
}

enum EngagementTier {
  churned,      // No activity in 30+ days
  low,          // Some activity but irregular
  medium,       // Regular player, few daily logins
  high,         // Very active, consistent engagement
  hardcore,     // Daily player with high social engagement
}
```

### Services

#### EnglishTownAnalyticsService

Core analytics service managing event tracking and aggregation.

**Initialization:**
```dart
final service = EnglishTownAnalyticsService();
await service.initialize();
```

**Event Tracking:**
```dart
// Track conversation completion
await service.trackConversation(
  userId: userId,
  npcName: npcName,
  success: true,
  xpGained: 50,
  duration: Duration(minutes: 2),
);

// Track achievement unlock
await service.trackAchievement(
  userId: userId,
  achievementId: achievementId,
  title: 'First Conversation',
  rewardXp: 100,
);

// Track challenge participation
await service.trackChallenge(
  userId: userId,
  challengeId: challengeId,
  action: 'completed',
  success: true,
);
```

**Data Retrieval:**
```dart
// Get player metrics for specific period
final dailyMetrics = await service.getPlayerAnalytics(
  userId: userId,
  period: AnalyticsPeriod.daily,
);

// Get leaderboard segment analytics
final leaderboardAnalytics = await service.getLeaderboardAnalytics();

// Get cohort analysis
final cohortAnalysis = await service.getCohortAnalysis(
  cohortDate: DateTime.now().subtract(Duration(days: 7)),
);

// Calculate engagement score
final engagement = await service.calculateEngagementScore(userId);
```

### Providers

#### Analytics Providers

```dart
// Analytics service provider
final analyticsServiceProvider = 
  Provider<EnglishTownAnalyticsService>((ref) {
    return EnglishTownAnalyticsService();
  });

// Player analytics by period
final playerAnalyticsProvider = 
  FutureProvider.family<PlayerAnalytics, String>((ref, userId) async {
    final service = ref.watch(analyticsServiceProvider);
    return service.getPlayerAnalytics(userId);
  });

// Leaderboard analytics
final leaderboardAnalyticsProvider = 
  FutureProvider<LeaderboardAnalytics>((ref) async {
    final service = ref.watch(analyticsServiceProvider);
    return service.getLeaderboardAnalytics();
  });

// Engagement score
final engagementScoreProvider = 
  FutureProvider.family<EngagementScore, String>((ref, userId) async {
    final service = ref.watch(analyticsServiceProvider);
    return service.calculateEngagementScore(userId);
  });

// Cohort analysis
final cohortAnalysisProvider = 
  FutureProvider.family<CohortAnalysis, DateTime>((ref, date) async {
    final service = ref.watch(analyticsServiceProvider);
    return service.getCohortAnalysis(date);
  });

// Daily game metrics (for admin dashboard)
final dailyMetricsProvider = 
  FutureProvider.family<DailyMetrics, DateTime>((ref, date) async {
    final service = ref.watch(analyticsServiceProvider);
    return service.getDailyMetrics(date);
  });
```

## Firestore Schema

### Collections

```
analytics/
├── events/{eventId}
│   ├─ userId: string
│   ├─ type: string (AnalyticsEventType)
│   ├─ timestamp: timestamp
│   ├─ properties: {key: value}
│   ├─ sessionId: string
│   ├─ xpGained: number
│   └─ [other context fields]
│
├── playerMetrics/{userId}/
│   ├─ daily/{date}
│   │  └─ PlayerAnalytics document
│   ├─ weekly/{weekStart}
│   │  └─ PlayerAnalytics document
│   ├─ monthly/{monthStart}
│   │  └─ PlayerAnalytics document
│   └─ allTime
│      └─ PlayerAnalytics document
│
├── leaderboardAnalytics/{date}
│   └─ LeaderboardAnalytics document with segments
│
├── cohortAnalysis/{cohortDate}
│   └─ CohortAnalysis document
│
└── engagementScores/{date}
   ├─ {userId}: EngagementScore
   └─ [indexed by userId for leaderboard]
```

## Tracking Implementation

### Integration Points

#### Conversation Tracking
```dart
// In conversation completion handler
await recordConversationInSocial(ref, {...});

// Also track analytics
final analytics = ref.read(analyticsServiceProvider);
await analytics.trackConversation(
  userId: userId,
  npcName: npcName,
  success: responseScore > 70,
  xpGained: xpEarned,
  duration: conversationDuration,
);
```

#### Achievement Tracking
```dart
// In achievement unlock handler
await recordAchievementInSocial(ref, {...});

// Also track analytics
final analytics = ref.read(analyticsServiceProvider);
await analytics.trackAchievement(
  userId: userId,
  achievementId: achievement.id,
  title: achievement.title,
  rewardXp: achievement.rewardXp,
);
```

#### Challenge Tracking
```dart
// In challenge completion handler
await recordChallengeCompletionInSocial(ref, {...});

// Also track analytics
final analytics = ref.read(analyticsServiceProvider);
await analytics.trackChallenge(
  userId: userId,
  challengeId: challengeId,
  action: 'completed',
  success: isWinner,
);
```

#### Session Tracking
```dart
// In app lifecycle handlers
// On app open
final analytics = ref.read(analyticsServiceProvider);
sessionId = await analytics.trackEvent(
  userId: userId,
  eventType: AnalyticsEventType.sessionStarted,
  properties: {'timestamp': DateTime.now()},
);

// On app close
await analytics.trackSession(
  userId: userId,
  duration: sessionDuration,
  eventsCount: eventCount,
);
```

## Analytics Dashboards

### Player Stats Dashboard

Shows individual player analytics:
- Daily/Weekly/Monthly metrics
- Engagement score and tier
- Progression timeline
- Social engagement metrics
- Conversation performance
- Achievement progress
- Challenge history

### Global Metrics Dashboard (Admin)

System-wide analytics:
- Daily active users (DAU)
- Monthly active users (MAU)
- Average session duration
- Conversation completion rates
- New player retention
- Top players by engagement
- Leaderboard dynamics
- Revenue metrics (if applicable)

### Cohort Analysis Dashboard

Shows player lifecycle:
- Retention curves by signup week
- Progression rates by cohort
- Churn analysis by level
- Engagement trends over time
- Level reach rates

## Performance Considerations

1. **Event Batching**
   - Batch events before writing to Firestore
   - 50+ events per batch
   - Flush every 30 seconds

2. **Aggregation Frequency**
   - Daily metrics: Calculate every night
   - Weekly metrics: Calculate on Monday
   - Monthly metrics: Calculate on 1st
   - Real-time: Calculate on-demand with cache

3. **Data Retention**
   - Raw events: 90 days
   - Daily metrics: 1 year
   - Monthly metrics: Unlimited
   - Retention curves: 2 years

4. **Query Optimization**
   - Index on (userId, timestamp)
   - Index on (type, timestamp)
   - Index on (rank, date) for leaderboard
   - Partition by date for analytics events

## Future Enhancements

1. **Predictive Analytics**
   - Churn prediction (ML model)
   - Next level prediction
   - Recommendation engine

2. **Real-time Dashboards**
   - Live DAU/MAU
   - Real-time top players
   - Live engagement heatmaps

3. **A/B Testing Framework**
   - Experiment tracking
   - Statistical significance testing
   - Variant performance comparison

4. **Advanced Segmentation**
   - Behavior-based segments
   - Value-based segments
   - Geographic segments

5. **Push Notification Analytics**
   - Delivery rates by notification type
   - Click-through rates
   - Optimal send times

6. **Revenue Analytics** (if monetized)
   - ARPPU (Average Revenue Per Paying User)
   - LTV (Lifetime Value)
   - Purchase funnel analysis
   - Item popularity tracking

## Configuration

### Default Settings
```
- Event batch size: 50
- Event flush interval: 30 seconds
- Metrics calculation: Daily at 00:00 UTC
- Retention: 90 days raw, unlimited aggregated
- Engagement scoring: Updated daily
- Cohort tracking: By signup week
```

### Privacy Considerations
- Anonymize analytics data for reporting
- Exclude sensitive information from events
- Comply with data protection regulations
- Allow users to opt-out of analytics
- Secure analytics storage

## Testing Checklist

- [ ] Event tracking for all event types
- [ ] Analytics event batching
- [ ] Player metrics aggregation (daily/weekly/monthly)
- [ ] Leaderboard segment analytics
- [ ] Cohort analysis calculation
- [ ] Engagement score calculation
- [ ] Retention curve generation
- [ ] Analytics provider caching
- [ ] Data integrity (no duplicates)
- [ ] Query performance (< 1s for most queries)
- [ ] Data retention policies
- [ ] Privacy compliance
- [ ] Admin dashboard functionality
- [ ] Real-time metric updates
- [ ] Historical data queries

---

**Phase 10 Status**: 🚀 In Progress (Advanced Analytics & Metrics)
**Next Phase**: Phase 11 - Admin Dashboard & Reporting

