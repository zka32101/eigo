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

### Phase 12 Part 1: Core Infrastructure (Current)
- [ ] Leaderboard and grade models
- [ ] LeaderboardService with query methods
- [ ] GradePromotionService with promotion logic
- [ ] Riverpod providers and action functions
- [ ] Firestore schema setup
- [ ] Auto-promotion job scheduler setup
- [ ] Comprehensive documentation

### Phase 12 Part 2: UI Screens (Next)
- [ ] Leaderboard selector/grouping UI
- [ ] Leaderboard display screen
- [ ] Grade info screen
- [ ] Stats and analytics screens
- [ ] Integration with existing game screens

### Phase 12 Part 3: Polish & Optimization
- [ ] Performance optimization (caching, batching)
- [ ] Real-time leaderboard updates
- [ ] Push notifications for rank changes
- [ ] Seasonal leaderboard resets
- [ ] Admin controls for manual promotion

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

---

**Phase 12 Status**: 🚀 Part 1 - Core Infrastructure (In Progress)
**Next**: Phase 12 Part 2 - Leaderboard UI Screens
