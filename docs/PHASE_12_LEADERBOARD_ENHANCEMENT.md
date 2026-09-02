# Phase 12: Leaderboard Enhancement System

## Overview

Phase 12 implements advanced leaderboard features including automatic grade level promotion aligned with the Japanese school year (April 1st) and flexible grouping options for competitive gameplay variety.

## Architecture

### Core Features

#### 1. **Auto-Grade Promotion System**
Automatic advancement of student grade levels on April 1st each year.

```dart
class GradePromotionConfig {
  final DateTime promotionDate; // April 1st
  final bool isEnabled;
  final int maxGrade; // Highest achievable grade
  
  // Promotion logic
  DateTime nextPromotionDate(DateTime currentDate);
  bool shouldPromoteToday(DateTime today);
}
```

**Features:**
- Automatic promotion on April 1st
- Respects maximum grade limits
- Tracks promotion history
- Retroactive promotion support (for latecomers)
- Optional automatic/manual promotion toggling

**Implementation Details:**
- Check promotion eligibility on user login
- Update user grade level
- Create promotion record in Firestore
- Trigger promotion notifications
- Update leaderboard rankings automatically

#### 2. **Leaderboard Grouping Types**
Four distinct leaderboard filtering options.

```dart
enum LeaderboardGroupType {
  overall,      // All users, single ranking
  byGrade,      // Separate leaderboards per grade (4, 5, 6, etc.)
  byStartMonth, // Separate leaderboards per month started
  combined,     // Grade × Start Month combinations
}
```

**Grouping Details:**

**A. Overall Leaderboard**
- Single global ranking
- All users compared equally
- Ranked by XP or achievement score
- Use case: Season finales, major competitions

**B. By Grade Leaderboard**
- Separate ranking per grade (Grade 4, 5, 6, etc.)
- Users compete only within their grade
- Fairness for different skill levels
- Use case: Grade-appropriate competitions

**C. By Start Month Leaderboard**
- Separate ranking per cohort (started January, February, etc.)
- Users compete with same-month joiners
- Newer players don't compete against veterans
- Use case: Retention tracking, fair onboarding

**D. Combined Leaderboard (Grade × Month)**
- Separate ranking per (Grade, StartMonth) pair
- Example: "Grade 5 Started January 2026"
- Most granular competition
- Use case: Precise demographic tracking

#### 3. **Leaderboard Data Model**
Core leaderboard entry structure.

```dart
class LeaderboardEntry {
  final String userId;
  final String userName;
  final int rank;
  final int totalXp;
  final int achievementScore;
  final int level;
  final int grade;
  final DateTime startDate;
  final int streak;
  final DateTime lastActivityAt;
  
  // Computed fields
  double getScore() => totalXp * 0.7 + achievementScore * 0.3;
}

class GroupedLeaderboard {
  final LeaderboardGroupType groupType;
  final String groupName; // "Grade 5", "January 2026", etc.
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  
  int get topScore => entries.first.getScore();
  int getUserRank(String userId) => ...;
}
```

#### 4. **User Grade Progression Model**
Track user grade levels and promotion history.

```dart
class UserGradeInfo {
  final String userId;
  final int currentGrade;
  final DateTime startDate;
  final List<GradePromotion> promotionHistory;
  final DateTime nextPromotionDate;
  
  bool canPromote(int maxGrade) => currentGrade < maxGrade;
  bool shouldPromoteToday(DateTime today) => ...;
}

class GradePromotion {
  final DateTime promotionDate;
  final int previousGrade;
  final int newGrade;
  final String reason; // 'automatic', 'manual', 'retroactive'
  final String? performedBy; // admin user for manual promotions
}
```

#### 5. **Leaderboard Filtering Service**
Query and calculate leaderboards by group type.

```dart
class LeaderboardService {
  // Calculate leaderboards
  Future<GroupedLeaderboard> getOverallLeaderboard({int limit = 100});
  Future<GroupedLeaderboard> getGradeLeaderboard(int grade, {int limit = 100});
  Future<GroupedLeaderboard> getStartMonthLeaderboard(DateTime month, {int limit = 100});
  Future<GroupedLeaderboard> getCombinedLeaderboard(int grade, DateTime month, {int limit = 100});
  
  // User-specific queries
  Future<LeaderboardEntry?> getUserRank(String userId, LeaderboardGroupType groupType);
  Future<int> getUserRankPosition(String userId, LeaderboardGroupType groupType);
  Future<List<GroupedLeaderboard>> getAllLeaderboards();
  
  // Promotion management
  Future<void> checkAndPromoteUsers(); // Called daily/on schedule
  Future<void> promoteUser(String userId, int newGrade, {String? reason});
  Future<List<GradePromotion>> getUserPromotionHistory(String userId);
}
```

### Services & Providers

#### LeaderboardService
Singleton service for all leaderboard operations.

**Core Methods:**
- `getOverallLeaderboard()` - Global ranking
- `getGradeLeaderboard(grade)` - Grade-specific ranking
- `getStartMonthLeaderboard(month)` - Cohort ranking
- `getCombinedLeaderboard(grade, month)` - Demographic ranking
- `getUserRankPosition(userId, groupType)` - User's position in any group
- `checkAndPromoteUsers()` - Automatic promotion check
- `promoteUser(userId, newGrade)` - Manual promotion

#### GradePromotionService
Singleton service for grade management.

**Core Methods:**
- `getPromotionConfig()` - Get global promotion settings
- `updatePromotionConfig()` - Update settings (admin only)
- `checkEligibilityForPromotion(userId)` - Verify promotion eligibility
- `promoteUser(userId, newGrade, reason)` - Perform promotion
- `getPromotionHistory(userId)` - View user's promotion history
- `getPromotionStats()` - Statistics on promotions

### Riverpod Provider Architecture

```dart
// Service providers
final leaderboardServiceProvider = Provider<LeaderboardService>(...);
final gradePromotionServiceProvider = Provider<GradePromotionService>(...);

// Leaderboard data providers
final overallLeaderboardProvider = FutureProvider<GroupedLeaderboard>(...);
final gradeLeaderboardProvider = FutureProvider.family<GroupedLeaderboard, int>(...);
final startMonthLeaderboardProvider = FutureProvider.family<GroupedLeaderboard, DateTime>(...);
final combinedLeaderboardProvider = FutureProvider.family<GroupedLeaderboard, (int, DateTime)>(...);

// User-specific providers
final userRankProvider = FutureProvider.family<LeaderboardEntry?, (String, LeaderboardGroupType)>(...);
final userGradeInfoProvider = FutureProvider.family<UserGradeInfo, String>(...);

// Configuration providers
final promotionConfigProvider = FutureProvider<GradePromotionConfig>(...);
final promotionHistoryProvider = FutureProvider.family<List<GradePromotion>, String>(...);

// Action functions
await promoteUserAction(ref, userId: userId, newGrade: newGrade);
await checkPromotionsAction(ref);
await updatePromotionConfigAction(ref, config: config);
```

## Firestore Schema

```
leaderboard/
├── overall/
│   ├── entries/{entryId}
│   │   ├─ userId: string
│   │   ├─ userName: string
│   │   ├─ rank: int
│   │   ├─ totalXp: int
│   │   ├─ achievementScore: int
│   │   ├─ level: int
│   │   ├─ grade: int
│   │   ├─ startDate: Timestamp
│   │   ├─ streak: int
│   │   ├─ score: double (computed)
│   │   └─ lastActivityAt: Timestamp
│   └── metadata
│       ├─ updatedAt: Timestamp
│       ├─ totalEntries: int
│       └─ topScore: double
│
├── byGrade/{gradeId}/
│   ├── entries/{entryId}
│   └── metadata
│
├── byMonth/{monthId}/
│   ├── entries/{entryId}
│   └── metadata
│
└── combined/{gradeId}_{monthId}/
    ├── entries/{entryId}
    └── metadata

userGrades/
├── {userId}
│   ├─ currentGrade: int
│   ├─ startDate: Timestamp
│   ├─ nextPromotionDate: Timestamp
│   ├─ promotionHistory: array
│   │  └─ {date, previousGrade, newGrade, reason}
│   └─ gradeHistory: map
│      └─ {date: grade}

gradePromotion/
├── config
│   ├─ promotionDate: string (MM-DD format, "04-01" for April 1st)
│   ├─ isEnabled: boolean
│   ├─ maxGrade: int
│   └─ lastCheckDate: Timestamp
│
└── history/{promotionId}
    ├─ userId: string
    ├─ previousGrade: int
    ├─ newGrade: int
    ├─ promotionDate: Timestamp
    ├─ reason: string (automatic|manual|retroactive)
    ├─ performedBy: string (admin user for manual)
    └─ createdAt: Timestamp
```

## UI Implementation Plan (Part 2)

### Screens to Create
1. **Leaderboard Selector Screen**
   - Choose grouping type (Overall, By Grade, By Month, Combined)
   - Visual tabs or pill buttons
   - Preview leaderboard data

2. **Leaderboard Display Screen**
   - Selected grouping leaderboard view
   - Rank listings with user cards
   - User's current rank highlighted
   - Pull-to-refresh
   - Infinite scroll/pagination

3. **Grade Info Screen**
   - Current grade display
   - Next promotion date countdown
   - Promotion history timeline
   - Achievement progress toward next grade

4. **Leaderboard Stats Screen**
   - Statistics dashboard
   - Top performers by category
   - Grade distribution charts
   - Cohort comparison

## Implementation Phases

### Phase 12 Part 1: Core Infrastructure ✅
- [x] Leaderboard and grade models
- [x] LeaderboardService with query methods
- [x] GradePromotionService with promotion logic
- [x] Riverpod providers and action functions
- [x] Firestore schema setup
- [x] Auto-promotion job scheduler setup
- [x] Comprehensive documentation

### Phase 12 Part 2: UI Screens ✅
- [x] Leaderboard selector/grouping UI
- [x] Leaderboard display screen
- [x] Grade info screen
- [x] Stats and analytics screens
- [x] Integration with existing game screens

### Phase 12 Part 3: Polish & Optimization ✅
- [x] Performance optimization (caching, batching)
- [x] Real-time leaderboard updates
- [x] Push notifications for rank changes
- [x] Seasonal leaderboard resets
- [x] Admin controls for manual promotion

## Configuration

### Default Settings
- **Promotion Date**: April 1st (日本の学年始まり)
- **Maximum Grade**: 6 (Elementary school max)
- **Auto-Promotion**: Enabled by default
- **Leaderboard Update**: Hourly refresh
- **Score Calculation**: 70% XP + 30% Achievements

### Thresholds
- Minimum activity for leaderboard: 1 session
- Leaderboard entry limit: 1000 entries per group
- Cache duration: 1 hour
- Promotion notification: 1 week before, on promotion date

## Performance Characteristics

### Query Performance
- Overall leaderboard: < 200ms
- Grade leaderboard: < 150ms
- Start month leaderboard: < 150ms
- Combined leaderboard: < 200ms
- User rank lookup: < 100ms

### Update Performance
- Auto-promotion batch: < 5 minutes for 10,000 users
- Leaderboard recalculation: < 2 minutes
- Individual promotion: < 500ms

## Testing Checklist

- [ ] Grade promotion logic (april 1st check)
- [ ] Promotion history tracking
- [ ] Overall leaderboard calculation
- [ ] Grade-specific leaderboard filtering
- [ ] Start month grouping logic
- [ ] Combined grouping (grade × month)
- [ ] User rank position accuracy
- [ ] Score calculation (70/30 split)
- [ ] Leaderboard caching
- [ ] Batch promotion performance
- [ ] Edge cases (new users, max grade)
- [ ] Retroactive promotions
- [ ] Timezone handling (JST)

## Future Enhancements

1. **Seasonal Leaderboards**
   - Monthly/quarterly competitions
   - Seasonal rewards
   - Leaderboard resets

2. **Real-Time Updates**
   - WebSocket for live rank changes
   - Notifications on rank improvements
   - Push alerts for milestones

3. **Regional Leaderboards**
   - Regional competitions
   - School-based rankings
   - Prefecture-wide competitions

4. **Special Leaderboards**
   - Daily top performers
   - Weekly streaks
   - Achievement-specific rankings
   - Speed run leaderboards

5. **Rewards System**
   - Weekly rank rewards
   - Season-end prizes
   - Ranking milestones
   - Grade promotion bonuses

## Part 3: Optimization & Polish

### Leaderboard Optimization Service
Comprehensive caching and real-time update system.

**Components:**
- `LeaderboardOptimizationService` (lib/services/leaderboard_optimization_service.dart)
  - 15-minute TTL cache for leaderboard queries
  - Real-time stream subscriptions for live updates
  - Listener management for rank change tracking
  - Seasonal reset with archival of old leaderboards
  - Batch update operations (500 op limit per write)
  - Cache statistics and memory estimation

**Key Features:**
- `getCachedLeaderboard()` - Returns cached data or fetches fresh
- `streamOverallLeaderboard()` - Real-time overall rankings
- `streamGradeLeaderboard(grade)` - Real-time per-grade rankings
- `streamUserRank(userId, groupType)` - Real-time user position tracking
- `listenToUserRankChanges()` - Setup rank change listener with callback
- `resetSeasonalLeaderboards()` - Archive and reset for new season
- `batchUpdateLeaderboards()` - Efficient multi-entry updates

### Rank Change Notification System
Notification service for competitive feedback.

**Components:**
- `LeaderboardRankNotificationService` (lib/services/leaderboard_rank_notification_service.dart)
  - Rank improvement notifications
  - Milestone badges (top 10, top 50, top 100)
  - Top position notifications
  - Grade promotion notifications (automatic, manual, retroactive)
  - Upcoming promotion reminders (1 week before)
  - Unread notification tracking
  - Notification cleanup with expiry

**Notification Types:**
- `rankImprovement` - User improved rank (with improvement amount)
- `rankMilestone` - User reached milestone rank (top 10/50/100)
- `topPosition` - User achieved rank #1
- `gradePromotion` - User was promoted to new grade
- `upcomingPromotion` - Reminder 1 week before April 1st

**Features:**
- `notifyRankChange()` - Create rank improvement notification
- `notifyRankMilestone()` - Create milestone notification
- `notifyTopPosition()` - Notify rank #1 achievement
- `notifyGradePromotion()` - Notify grade change
- `notifyUpcomingPromotion()` - Pre-promotion reminder
- `sendPushNotification()` - FCM integration (for Cloud Functions)
- `getUnreadNotifications()` - User's unread notifications
- `getNotificationStats()` - Count of read/unread
- `markAsRead()` / `markAllAsRead()` - Mark notifications read
- `deleteExpiredNotifications()` - Cleanup old notifications

### Admin Grade Promotion Management
Admin screen for manual grade management.

**Components:**
- `AdminGradePromotionScreen` (lib/screens/admin_grade_promotion_screen.dart)
  - Promotion configuration display (date, max grade, auto-enabled)
  - Manual single-user promotion
  - Bulk promotion (by grade or all users)
  - Promotion history timeline with reasons

**Sections:**
1. **Promotion Configuration**
   - Display current promotion date (April 1st)
   - Show maximum grade level
   - Toggle auto-promotion on/off
   - Track last promotion check

2. **Manual Promotion**
   - Input user ID
   - Select target grade (4-9)
   - Create manual promotion record

3. **Bulk Promotion**
   - Choose promotion mode (by grade, all users)
   - Select source grade for bulk operation
   - Confirmation dialog with warning
   - Progress feedback

4. **Promotion History**
   - Timeline of recent promotions
   - User name, grade transition (X年生 → Y年生)
   - Reason badge (自動/手動/遡及)
   - Timestamp with relative time display

### Notification Provider Architecture

**Providers:**
- `leaderboardRankNotificationServiceProvider` - Service instance
- `unreadNotificationsProvider(userId)` - Get unread for user
- `notificationStatsProvider(userId)` - Stats (read/unread counts)

**Action Functions:**
- `notifyRankChangeAction()` - Trigger rank change notification
- `notifyRankMilestoneAction()` - Trigger milestone notification
- `notifyTopPositionAction()` - Trigger top position notification
- `notifyGradePromotionAction()` - Trigger grade promotion notification
- `notifyUpcomingPromotionAction()` - Trigger pre-promotion reminder
- `markNotificationAsReadAction()` - Mark single read
- `markAllNotificationsAsReadAction()` - Mark all read

### Firestore Collections (Part 3)

```
notifications/{notificationId}
├─ userId: string
├─ type: string (rankImprovement|rankMilestone|topPosition|gradePromotion|upcomingPromotion)
├─ createdAt: Timestamp
├─ isRead: boolean
├─ expiresAt: Timestamp (30-day TTL)
├─ previousRank: int (for rankImprovement)
├─ newRank: int (for rankImprovement)
├─ rankImprovement: int (for rankImprovement)
├─ groupType: string (for rank notifications)
├─ groupName: string (for rank notifications)
├─ milestone: string (for rankMilestone)
├─ currentRank: int (for rankMilestone)
├─ previousGrade: int (for gradePromotion)
├─ newGrade: int (for gradePromotion)
└─ promotionDate: Timestamp (for upcomingPromotion)

leaderboard/archived/{seasonKey}/
├─ overall/entries/{entryId}
├─ byGrade/{gradeId}/entries/{entryId}
├─ byMonth/{monthId}/entries/{entryId}
└─ combined/{combined_id}/entries/{entryId}
```

### Performance Optimizations

**Cache Duration**: 15 minutes
- Automatic expiry checking
- Manual cache invalidation
- Per-query cache keys
- Memory-efficient storage

**Real-time Streaming**:
- Efficient listener cleanup
- Per-user listener subscription
- Automatic resubscription on disconnect
- Minimal database reads

**Batch Operations**:
- 500 Firestore operation limit
- Automatic batch splitting
- Transaction safety
- Error handling per batch

### Integration Points

1. **Leaderboard Display Screen**
   - Listen to real-time rank changes
   - Display rank badges (medals for top 3)
   - Show user rank position

2. **Grade Info Screen**
   - Display promotion countdown
   - Show upcoming promotion date
   - List promotion history

3. **Admin Dashboard**
   - New "학年昇進" (Grade Promotion) tab
   - Access admin controls
   - View promotion history
   - Manual and bulk operations

4. **User Profile / Home Screen**
   - Show unread notifications count
   - Display notification badges
   - Quick access to notifications

---

**Phase 12 Status**: ✅ Complete (All 3 Parts)
- Part 1: Core Infrastructure (Leaderboard models, services, providers)
- Part 2: UI Screens (Selector, display, grade info, stats screens)
- Part 3: Optimization & Polish (Caching, streaming, notifications, admin controls)

**Key Files Implemented:**
1. `lib/models/leaderboard_model.dart` - Data models
2. `lib/services/leaderboard_service.dart` - Leaderboard queries
3. `lib/services/leaderboard_optimization_service.dart` - Caching & streaming
4. `lib/services/leaderboard_rank_notification_service.dart` - Notifications
5. `lib/screens/leaderboard_selector_screen.dart` - Type selection
6. `lib/screens/leaderboard_display_screen.dart` - Main leaderboard view
7. `lib/screens/grade_info_screen.dart` - Grade progression info
8. `lib/screens/leaderboard_stats_screen.dart` - Statistics dashboard
9. `lib/screens/admin_grade_promotion_screen.dart` - Admin controls
10. `lib/providers/leaderboard_provider.dart` - Riverpod providers
11. `lib/providers/leaderboard_notification_provider.dart` - Notification providers

**Next**: Phase 13 - Additional Features or Polish Phases
