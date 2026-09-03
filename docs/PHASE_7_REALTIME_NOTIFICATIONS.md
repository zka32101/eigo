# Phase 7: Real-time Notifications & Activity Feed System

## Overview

Phase 7 implements a comprehensive real-time notifications and activity feed system for the English-Only Town game. This system tracks all player activities, detects significant events, and notifies players of achievements and rank changes.

## Architecture

### Core Components

#### 1. **Notification Service** (`english_town_notification_service.dart`)
- In-memory notification store
- Notification creation factory methods
- Notification type management
- Unread count tracking
- Mark as read/Clear functionality

**Key Classes:**
- `AppNotification`: Represents a single notification with metadata
- `NotificationType`: Enum for notification categories
- `EnglishTownNotificationService`: Singleton service managing notifications

**Notification Types:**
- `rankChanged`: Rank position changes
- `achievementUnlocked`: Achievement unlock events
- `streakMilestone`: Streak milestone reached
- `dailyChallenge`: Daily challenge events
- `friendActivity`: Friend activity (future feature)
- `leaderboardTop`: Top 10 entry achievement

#### 2. **Activity Feed Service** (`english_town_activity_feed_service.dart`)
- Tracks all game events
- Activity history with timestamps
- Activity filtering and searching
- Milestone detection

**Key Classes:**
- `ActivityEvent`: Represents a single activity with full context
- `ActivityEventType`: Enum for activity categories
- `EnglishTownActivityFeedService`: Manages activity history

**Activity Types:**
- `conversation`: NPC conversation completion
- `achievementUnlocked`: Achievement unlock
- `streakMilestone`: Streak milestone
- `levelUp`: Level progression
- `rankChange`: Rank changes
- `leaderboardEntry`: Leaderboard entry/update
- `challengeCompleted`: Challenge completion
- `friendAdded`: Friend addition (future)

#### 3. **Engagement Notifier Service** (`english_town_engagement_notifier_service.dart`)
- Orchestrates notifications and activities for game events
- Handles milestone detection
- Manages notification preferences
- Integrates with other services

**Methods:**
- `onAchievementUnlocked()`: Handle achievement events
- `onStreakMilestone()`: Handle streak milestones
- `onRankChange()`: Handle rank changes
- `onConversationComplete()`: Record conversations
- `onChallengeComplete()`: Handle challenge events
- `checkMilestones()`: Batch milestone checking

### Providers & State Management

#### Notification Providers (`english_town_notification_provider.dart`)

**Streams:**
- `notificationsStreamProvider`: Stream of all notifications
- `unreadNotificationsProvider`: Stream of unread notifications only
- `unreadNotificationCountProvider`: Count of unread notifications
- `allNotificationsProvider`: All notifications (non-stream)

**Preferences:**
- `enableRankChangeNotificationsProvider`: Toggle rank notifications
- `enableAchievementNotificationsProvider`: Toggle achievement notifications
- `enableStreakNotificationsProvider`: Toggle streak notifications
- `enableDailyChallengeNotificationsProvider`: Toggle challenge notifications
- `enableTopLeaderboardNotificationsProvider`: Toggle top 10 notifications
- `rankChangeNotificationThresholdProvider`: Minimum rank change to notify

**Tracking:**
- `previousUserRankProvider`: Previous rank for change detection
- `isInTopTenProvider`: Current top 10 status

**Actions:**
```dart
// Mark notification as read
markNotificationAsRead(ref, notificationId);

// Mark all as read
markAllNotificationsAsRead(ref);

// Clear all
clearAllNotifications(ref);
```

#### Activity Feed Providers (`english_town_activity_feed_provider.dart`)

**Streams:**
- `activityFeedProvider`: Stream of all activities
- `recentActivitiesProvider`: Last 20 activities
- `todayActivitiesProvider`: Today's activities
- `recentHourActivitiesProvider`: Last hour's activities

**Filtered Views:**
- `conversationActivitiesProvider`: Only conversations
- `achievementActivitiesProvider`: Only achievements
- `streakActivitiesProvider`: Only streaks
- `rankChangeActivitiesProvider`: Only rank changes
- `challengeActivitiesProvider`: Only challenges

**Statistics:**
- `todayConversationCountProvider`: Today's conversation count
- `todayAchievementCountProvider`: Today's achievement count
- `todayActivitySummaryProvider`: Summary map of all activities
- `conversationMilestoneProvider`: 5 conversations milestone
- `achievementMilestoneProvider`: 3 achievements milestone

**Activity Recording Functions:**
```dart
// Record activities with automatic timestamp and metadata
recordConversationActivity(ref, userId, playerName, npcName, ...);
recordAchievementActivity(ref, userId, playerName, achievementTitle, ...);
recordStreakActivity(ref, userId, playerName, streakDays, ...);
recordRankChangeActivity(ref, userId, playerName, previousRank, currentRank);
recordChallengeActivity(ref, userId, playerName, challengeTitle, ...);
```

## UI Components

### 1. **Notification Bell Widget** (`notification_bell_widget.dart`)
- App bar notification indicator
- Unread count badge
- Opens notification center on tap

**Usage:**
```dart
NotificationBell(
  onPressed: () {
    Navigator.push(context, 
      MaterialPageRoute(
        builder: (context) => const EnglishTownNotificationsScreen(),
      ),
    );
  },
),
```

### 2. **Notifications Screen** (`english_town_notifications_screen.dart`)
Two-tab interface:

**Tab 1: Inbox**
- List of all notifications
- Mark individual notifications as read
- Mark all as read button
- Dismiss by swiping
- Empty state

**Tab 2: Settings**
- Toggle each notification type
- Rank change threshold slider (1-10 positions)
- Clear all notifications button
- Notification preference documentation

### 3. **Real-time Leaderboard Screen** (`english_town_leaderboard_realtime_screen.dart`)
- Live leaderboard with rank change detection
- Visual indicators (🔼 improved, 🔽 declined)
- Animated rank card showing user's position
- Green/orange highlights for recent changes
- Trending indicators (📈 climbing, etc.)

**Features:**
- Detects rank changes between updates
- Animates rank number and indicators
- Shows improvement/decline visually
- Updates in real-time (2-second polling)

### 4. **Activity Feed Screen** (`english_town_activity_feed_screen.dart`)
- Today's activity summary with counts
- Recent activity list with timestamps
- Color-coded activity type badges
- Activity type indicators
- Empty and error states

**Summary Section:**
- Conversation count (💬)
- Achievement count (🏆)
- Streak count (🔥)
- Challenge count (⭐)

**Activity Cards:**
- Emoji indicator
- Title and description
- Time ago (e.g., "5m ago")
- Activity type badge with color
- Delete by swiping

## Integration Points

### Conversation Screen Integration
When a conversation completes, trigger:
```dart
// Record the conversation
await recordConversationActivity(ref, 
  userId: currentUserId,
  playerName: playerName,
  npcName: npc.name,
  locationName: location.name,
  xpEarned: xpEarned,
  difficulty: difficulty,
);

// Check for daily conversation milestones
if (todayConversationCount == 5) {
  // Notify player
}
```

### Achievement Screen Integration
When an achievement unlocks:
```dart
await onAchievementUnlocked(ref,
  userId: currentUserId,
  playerName: playerName,
  achievementTitle: achievement.title,
  achievementDescription: achievement.description,
  rewardXp: achievement.rewardXp,
);
```

### Reward Screen Integration
Achievements are automatically notified when displayed in the reward screen.

### Leaderboard Integration
When a player's rank changes:
```dart
await onRankChange(ref,
  userId: currentUserId,
  playerName: playerName,
  previousRank: oldRank,
  currentRank: newRank,
);
```

## Notification Thresholds & Rules

### Rank Change Notifications
- **Default threshold**: 3 position changes
- **Configurable**: Slider from 1-10
- **Auto-trigger**: Top 10 entry (always notified)
- **Visual**: Shows improvement/decline status

### Streak Milestone Notifications
- **3-day**: First milestone
- **7-day**: Weekly streak
- **14-day**: Bi-weekly achievement
- **30-day**: Monthly milestone
- **60-day**: Extended commitment
- **100-day**: Century achievement

### Achievement Notifications
- **Immediate**: On unlock
- **Always visible**: In notifications center
- **Recorded**: In activity feed

### Challenge Notifications
- **New daily challenges**: Optional toggle
- **Milestones**: 5, 10, 15 daily conversations
- **Completion**: On challenge finish

## Data Flow Diagram

```
Game Event (Conversation Complete)
    ↓
Conversation Screen
    ↓
recordConversationActivity() → Activity Feed Service
    ↓
Activity Feed Provider (triggers update)
    ↓
Activity Feed Screen (shows activity)

Simultaneous:
Achievement Detected → onAchievementUnlocked() 
    ↓
Notification Service + Activity Feed Service
    ↓
NotificationBell (badge updates) + Activity Feed Screen
    ↓
User taps notification → Notification Center
```

## Future Enhancements (Phase 8+)

1. **Firebase Real-time Integration**
   - Firestore listeners for rank changes
   - Multi-player notifications
   - Push notifications to device

2. **Social Features**
   - Friend activity notifications
   - Multiplayer challenges
   - Leaderboard comparisons

3. **Advanced Analytics**
   - Activity patterns
   - Engagement trends
   - Personalized recommendations

4. **Notification Channels**
   - Push notifications
   - Email digests
   - In-app only (current)
   - SMS (future)

5. **Smart Scheduling**
   - Best time to notify
   - Daily digests
   - Do not disturb hours

## Testing & Debugging

### Manual Testing Checklist

- [ ] Notifications appear when achievements unlock
- [ ] Rank changes trigger notifications
- [ ] Threshold setting prevents over-notification
- [ ] Mark as read works correctly
- [ ] Clear all notifications works
- [ ] Activity feed records all events
- [ ] Daily summary counts are accurate
- [ ] Real-time leaderboard shows changes
- [ ] Swipe to dismiss works
- [ ] Empty states display correctly

### Debug Console Commands (TODO)

```dart
// Force achievement unlock for testing
ref.read(notificationServiceProvider)
  .addNotification(notification);

// Clear all for reset
ref.read(notificationServiceProvider).clearAll();

// View current state
print(ref.read(notificationServiceProvider).notifications);
```

## Performance Considerations

1. **Activity Limit**: Max 500 activities in memory (auto-trim)
2. **Notification Limit**: Max 50 notifications in memory
3. **Polling Interval**: 2 seconds for leaderboard updates
4. **Stream Debounce**: None (future optimization)
5. **Database Sync**: Async, doesn't block UI

## Code Examples

### Example: Complete Achievement Workflow

```dart
// 1. Detect achievement in conversation flow
if (responseScore >= threshold) {
  final achievement = Achievement(
    id: 'perfect_response',
    title: 'Perfect Response',
    description: 'Got a perfect score response',
    xpReward: 250,
  );
  
  // 2. Trigger notification and activity
  await ref.read(engagementNotifierProvider)
    .onAchievementUnlocked(
      ref,
      userId: userId,
      playerName: playerName,
      achievementTitle: achievement.title,
      achievementDescription: achievement.description,
      rewardXp: achievement.xpReward,
    );
}

// 3. User sees:
// - Notification in notifications center
// - Activity in activity feed
// - Badge on notification bell
```

### Example: Rank Change Detection

```dart
// In leaderboard monitoring
final previousRank = ref.read(previousUserRankProvider);
final currentRank = await ref.read(userLeaderboardRankProvider.future);

if (previousRank != null && previousRank != currentRank) {
  await ref.read(engagementNotifierProvider)
    .onRankChange(
      ref,
      userId: userId,
      playerName: playerName,
      previousRank: previousRank,
      currentRank: currentRank,
    );
}
```

## File Structure

```
lib/
├── services/
│   ├── english_town_notification_service.dart
│   ├── english_town_activity_feed_service.dart
│   └── english_town_engagement_notifier_service.dart
├── providers/
│   ├── english_town_notification_provider.dart
│   └── english_town_activity_feed_provider.dart
├── screens/
│   ├── english_town_notifications_screen.dart
│   ├── english_town_leaderboard_realtime_screen.dart
│   └── english_town_activity_feed_screen.dart
└── widgets/
    └── notification_bell_widget.dart
```

## API Reference

### EnglishTownNotificationService

```dart
// Create notifications
createRankChangeNotification(previousRank, currentRank, playerName)
createAchievementNotification(achievementTitle, rewardXp)
createStreakNotification(streakDays, milestone)
createDailyChallengeNotification(challengeTitle, xpReward)
createTopLeaderboardNotification(rank)

// Manage notifications
addNotification(notification)
markAsRead(notificationId)
markAllAsRead()
clearAll()

// Query notifications
getNotificationsByType(type)
getUnreadNotifications()
```

### EnglishTownActivityFeedService

```dart
// Record activities
recordConversation(userId, playerName, npcName, ...)
recordAchievementUnlock(userId, playerName, ...)
recordStreakMilestone(userId, playerName, ...)
recordRankChange(userId, playerName, ...)
recordChallengeCompletion(userId, playerName, ...)

// Query activities
getRecentActivities(limit)
getActivitiesByType(type)
getActivitiesSince(duration)
getActivitySummary(timeRange)
checkMilestone(type, count, timeRange)
```

## Configuration

### Notification Preferences (StateProviders)

```dart
// Users can configure these settings
enableRankChangeNotificationsProvider        // bool
enableAchievementNotificationsProvider       // bool
enableStreakNotificationsProvider            // bool
enableDailyChallengeNotificationsProvider    // bool
enableTopLeaderboardNotificationsProvider    // bool
rankChangeNotificationThresholdProvider      // int (1-10)
```

## Notes

- Notifications persist in memory during app session only (not persisted to disk)
- Firebase integration for persistent notifications is planned for Phase 8
- Real-time leaderboard polling currently uses 2-second interval
- Activity feed auto-trims to keep memory usage reasonable
- All timestamps use device local time (future: server time sync)

---

**Phase 7 Status**: ✅ Complete (Notifications & Activity Feed)
**Next Phase**: Phase 8 - Firebase Real-time Integration & Push Notifications
