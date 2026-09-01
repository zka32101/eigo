# 英語コレ！ Features Documentation

## Overview
英語コレ! (Eigo Kore) is a comprehensive English learning application built with Flutter and Riverpod state management. This document outlines all implemented features across 5 major phases.

---

## Phase 1-3: Core Learning Features (Previous Phases)
- **Lesson System**: Interactive lesson completion with scoring
- **Item Purchase & Inventory**: In-app shop system with coin transactions
- **Learning Pace Recommendation**: Personalized pace adjustment with streak tracking
- **Character Collection**: Collectable characters with rarity and affection system
- **Advertisement System**: AdMob integration with placement and frequency controls
- **Cross Promotion**: Campaign management and interaction tracking

---

## Phase 4: Advanced User Features

### Phase 4-1: User/Profile Management
**File**: `lib/screens/profile_management_screen.dart`

#### Features:
- **Statistics Tab**
  - User profile header with avatar and basic info
  - 4-stat card display grid (study time, coins, streak, cleared stages)
  - Achievement breakdown (badges and missions unlocked)
  - Gradient-styled containers with consistent theming

- **Privacy Tab**
  - Toggle switch for ranking visibility setting
  - Privacy policy information display
  - Auto-save to profile using Riverpod notifier
  - Color-coded toggle states (green for enabled)

- **Data Management Tab**
  - Auto-backup status indicator
  - JSON export functionality for profile data
  - Import placeholder for future implementation
  - Clear action buttons with distinct styling

#### Models:
- `UserProfile`: Core user data with stats and preferences
- Uses existing `userProfilesProvider` and `currentUserProvider`

#### Technical Details:
- Uses `ConsumerWidget` and `ConsumerStatefulWidget` patterns
- `DefaultTabController` for tab management
- SharedPreferences for persistence (via provider)
- Material Design 3 compliance

---

### Phase 4-2: Social/Leaderboard Features
**Files**: 
- `lib/models/friend_model.dart`
- `lib/models/leaderboard_model.dart`
- `lib/providers/friend_provider.dart`
- `lib/providers/leaderboard_provider.dart`
- `lib/screens/friends_screen.dart`
- `lib/screens/leaderboard_screen.dart`

#### Friend System:

**Models**:
- `Friend`: Friend profile with stats and favorite toggle
- `FriendRequest`: Request tracking with status (pending/accepted/rejected)

**Providers**:
- `friendListProvider`: StateNotifierProvider managing friend list
- `friendRequestsProvider`: StateNotifierProvider for pending requests

**Functionality**:
- Add/remove friends with duplicate prevention
- Toggle favorite status with auto-save
- Accept/reject friend requests
- Automatic friend addition on request acceptance

**Screen - Friends Tab 1: Friend List**
- Display friend count and favorite count
- Separate sections for favorites and others
- Context menu for toggle favorite/delete
- Quick access to friend management

**Screen - Friends Tab 2: Friend Requests**
- Display pending requests with user info
- Accept/reject buttons for each request
- Badge showing number of pending requests
- Auto-friend addition on acceptance

**Screen - Friends Tab 3: Search**
- Text search with real-time filtering
- Display matching users with level/stats
- Add friend button for each result
- Sample data for demonstration

#### Leaderboard System:

**Models**:
- `LeaderboardEntry`: Individual ranking entry with stats
- `LeaderboardData`: Complete ranking with current user position
- `UserComparison`: Head-to-head user comparison

**Providers**:
- `globalLeaderboardProvider`: FutureProvider for global rankings
- `friendLeaderboardProvider`: FutureProvider for friend-only rankings
- `weeklyLeaderboardProvider`: FutureProvider for weekly rankings
- `userComparisonProvider`: Comparison data between two users

**Screen - Leaderboard Tab 1: Global**
- Top users with rank badges (gold/silver/bronze)
- Current user highlight card
- Display name, level, score, streak, and study time
- Sorted by score descending

**Screen - Leaderboard Tab 2: Friends**
- Friend-only rankings
- Current user position in friend group
- Encourages friendly competition
- Empty state with call-to-action to add friends

**Screen - Leaderboard Tab 3: Weekly**
- Week information header
- Weekly rankings with daily reset notice
- Current user weekly position
- Incentivizes consistent weekly learning

#### Technical Details:
- JSON serialization/deserialization for all models
- FutureProvider with autoDispose for memory efficiency
- Ref.watch for state reactivity
- Ref.read for notifier access
- 3-tab interface with DefaultTabController

---

### Phase 4-3: Analytics/Reports Features
**Files**:
- `lib/models/analytics_model.dart` (enhanced)
- `lib/providers/analytics_provider.dart` (existing)
- `lib/screens/analytics_screen.dart`

#### Models:
- `DailyStats`: Daily learning statistics
- `MonthlyStats`: Monthly aggregated statistics
- `WeeklyReport`: Week-specific learning data
- `DailyStudyRecord`: Detailed daily records
- `LearningProgressStats`: Current progress and proficiency
- `AchievementLog`: Achievement tracking

#### Providers:
- `analyticsProvider`: StateNotifierProvider for daily stats
- Methods for calculating monthly statistics

#### Screen - Analytics Tab 1: Progress
- **Level Progression**
  - Current level display with progress bar
  - Visual percentage indicator
  
- **Learning Statistics Grid**
  - 4-card grid: lessons, study time, coins, streak
  - Color-coded by stat type
  - Large readable numbers

- **Understanding Metrics**
  - Overall accuracy rate display
  - Progress bar visualization
  - Consistent metric presentation

#### Screen - Analytics Tab 2: Weekly
- **Week Information Header**
  - Date range display (Monday-Sunday)
  - Visual calendar icon

- **Weekly Statistics Grid**
  - 4-card grid: lessons, time, coins, days active
  - Week-specific data aggregation

- **Daily Performance Breakdown**
  - 7-day view (Mon-Sun)
  - Visual checkmarks for active days
  - Minutes studied per day
  - Grey/inactive state for inactive days

#### Screen - Analytics Tab 3: Monthly
- **Month Information Card**
  - Month/year display
  - Visual calendar icon
  - Progress summary text

- **Monthly Statistics Grid**
  - 4-card grid with monthly aggregates
  - Lessons, time, coins, days active

- **Goal Achievement Tracking**
  - Multiple goal progress cards
  - Time-based goals
  - Coin collection goals
  - Streak maintenance goals
  - Visual progress bars with target values
  - Achieved/not achieved indicators

#### Technical Details:
- Uses existing analytics provider
- StatelessWidget for progress cards
- Linear progress indicators for visual feedback
- Percentage calculations for progress display

---

### Phase 4-4: Notifications/Reminders Features
**Files**:
- `lib/models/notification_model.dart`
- `lib/providers/notification_settings_provider.dart`
- `lib/screens/notification_management_screen.dart`

#### Models:
- `NotificationSettings`: User notification preferences
- `NotificationRecord`: Recorded notification history
- `ScheduledNotification`: Scheduled/recurring notifications
- `NotificationType`: Enum for notification types

**Notification Types**:
- `dailyReminder`: Daily study reminders
- `streakMaintenance`: Streak protection reminders
- `achievement`: Badge/milestone notifications
- `levelUp`: Level advancement notifications
- `friendRequest`: Friend-related notifications
- `promotionalOffer`: Campaign notifications
- `systemMessage`: System announcements

#### Providers:
- `notificationSettingsProvider`: StateNotifierProvider for preferences
- `notificationHistoryProvider`: StateNotifierProvider for history

**Notification Settings**:
- Daily reminder toggle + customizable hour (0-23)
- Streak reminder toggle + customizable hour
- Achievement notification toggle
- Friend notification toggle
- Promotional notification toggle
- Sound toggle (system-wide)
- Vibration toggle (system-wide)
- Last updated timestamp tracking

#### Screen - Notification Tab 1: Settings
- **Basic Notifications Section**
  - Sound toggle with description
  - Vibration toggle with description
  - Individual toggles for each notification type

- **Learning Notifications Section**
  - Daily reminder toggle with time picker
  - Streak reminder toggle with time picker
  - Hour-based time selection (±1 buttons)
  - Display format: HH:00

- **Other Notifications Section**
  - Achievement notifications
  - Friend notifications
  - Promotional notifications

#### Screen - Notification Tab 2: History
- **Unread Indicator Badge**
  - Shows count of unread notifications
  - Red badge styling
  - Auto-updates as user reads notifications

- **Notification Cards**
  - Notification type label with emoji
  - Unread indicator dot (if unread)
  - Title and message text
  - Relative time display (e.g., "5分前")
  - Delete button for each notification
  - Mark as read on tap

- **Notification Management**
  - Mark all as read button
  - Delete individual notifications
  - Filter by type available

#### Technical Details:
- Riverpod for state management
- SharedPreferences for persistence
- CustomTime picker with increment/decrement buttons
- Switch widgets for toggles with color indicators
- Relative time formatting for history

---

### Phase 4-5: Achievements/Badges Features
**Files**:
- `lib/models/badge_model.dart` (enhanced)
- `lib/providers/badge_provider.dart` (enhanced)
- `lib/screens/achievements_screen.dart`

#### Models:
- `BadgeRarity`: Enum (common/uncommon/rare/legendary)
- `UnlockedBadge`: Earned badge with unlock date and new status
- `BadgeProgress`: Badge progress tracking toward unlock
- `Badge`: Badge definition (from shared_core)
- `EarnedBadge`: Previously earned badge tracking

#### Predefined Badges:
1. **はじめの一歩** (First Steps) - 🌱 Common
   - Condition: 1 lesson completed

2. **勉強仲間** (Study Buddy) - 📚 Uncommon
   - Condition: 10 lessons completed

3. **献身的な学習者** (Dedicated Learner) - 🎓 Rare
   - Condition: 100 lessons completed

4. **マラソンランナー** (Marathon Runner) - 🏃 Rare
   - Condition: 1000 minutes studied

5. **コインコレクター** (Coin Collector) - 🪙 Uncommon
   - Condition: 500 coins earned

6. **熱いストリーク** (Hot Streak) - 🔥 Uncommon
   - Condition: 7 days consecutive

7. **伝説のストリーク** (Legendary Streak) - 👑 Legendary
   - Condition: 30 days consecutive

8. **精密射手** (Accuracy Master) - 🎯 Rare
   - Condition: 90% accuracy rate

9. **ソーシャルバタフライ** (Social Butterfly) - 🦋 Uncommon
   - Condition: 10 friends added

10-12. **Stage Completion Badges**

#### Providers:
- `badgeProvider`: StateNotifierProvider from shared_core
- `badgeProgressProvider`: Enhanced progress tracking (new)

**BadgeProgressNotifier Methods**:
- `updateProgress(badgeId, newValue)`: Update progress with auto-unlock
- `getUnlockedBadges()`: Filter unlocked badges
- `getNearbyBadges()`: Find badges at 50%+ progress
- `getOverallProgress()`: Calculate total completion %

#### Screen - Achievements Tab 1: Unlocked Badges
- **Earned Count Card**
  - Number of badges earned
  - Checkmark icon for visual clarity
  - Green accent color

- **Badge Grid Display**
  - 3-column grid layout
  - Tap for detailed badge information
  - Modal popup with:
    - Large badge icon
    - Badge title and description
    - Unlock date in Japanese format
    - Close button

#### Screen - Achievements Tab 2: Progress
- **Overall Progress Card**
  - Percentage complete (0-100%)
  - Linear progress bar with animation
  - Count of earned vs total badges
  - Gradient background styling

- **Individual Badge Progress Cards**
  - Badge icon and title
  - Current/target value display
  - Percentage progress circle
  - Color coding (green for earned, orange for in-progress)
  - Linear progress bar for progress visualization
  - Checkmark for earned badges

#### Screen - Achievements Tab 3: All Badges
- **Complete Badge Collection**
  - Grid view of all possible badges
  - Dimmed/greyed-out appearance for locked badges
  - Lock icon overlay for locked badges
  - Bold/bright display for earned badges
  - Opacity changes for visual hierarchy

#### Technical Details:
- JSON serialization for persistence
- Automatic unlock detection on progress update
- Visual rarity indicators via gradient backgrounds
- Progress bar animations
- Badge collection grid layout with variable visibility

---

## Data Persistence
All features use SharedPreferences for local data storage with the following keys:
- `eigo_kore_friend_requests`
- `eigo_kore_friends`
- `eigo_kore_ad_placements`
- `eigo_kore_ad_limits`
- `eigo_kore_ad_history`
- `eigo_kore_notification_settings`
- `eigo_kore_notification_history`
- `eigo_kore_badge_progress`
- Plus existing keys for profiles, analytics, etc.

---

## Navigation Routes
Added in `lib/main.dart`:
- `/profile-management`: Profile management screen
- `/leaderboard`: Leaderboard and rankings
- `/friends`: Friend management and search
- `/analytics`: Learning analytics and reports
- `/notifications`: Notification settings and history
- `/achievements`: Achievements and badges

---

## State Management Pattern
All features follow the Riverpod state management pattern:

```dart
// Creation
final myProvider = StateNotifierProvider<MyNotifier, StateType>((ref) {
  return MyNotifier();
});

// Usage
final state = ref.watch(myProvider);
final notifier = ref.read(myProvider.notifier);
```

**Key Principles**:
- StateNotifierProvider for mutable state
- FutureProvider for async data
- Family for parameterized providers
- AutoDispose for memory efficiency
- Ref.watch for reactive updates
- Ref.read for notifier access

---

## UI/UX Consistency
All screens follow consistent design patterns:

**Colors**:
- Primary: `kPrimaryColor` (blue)
- Accent Orange: `kAccentOrange`
- Accent Green: `kAccentGreen`
- Accent Red: `kAccentRed`
- Text Muted: `kTextMuted` (grey)

**Spacing**:
- Uses `AppSpacing` constants (xs, sm, md, lg, xl, xxl)
- Consistent padding and margins

**Typography**:
- Uses `AppTypography` styles
- Headlines, labels, body text with proper hierarchy

**Components**:
- Material Design 3 widgets
- Rounded corners with `AppSizes.borderRadius`
- Elevated buttons with color coding
- Switch widgets with color indicators
- Linear progress bars with animations

**Layouts**:
- Tab-based interfaces with DefaultTabController
- Grid layouts for data display
- Card-based layouts for grouping
- Responsive padding and scaling

---

## Testing Considerations
Features can be tested by:
1. Creating test profiles with various stats
2. Adding/removing friends and requests
3. Checking analytics calculations across periods
4. Toggling notification settings and verifying persistence
5. Completing badges and verifying progress tracking

---

## Future Enhancements
Potential areas for expansion:
- Real-time synchronization with backend
- Multiplayer leaderboards with live updates
- Advanced analytics with charts and graphs
- Notification scheduling with background tasks
- Badge-based rewards and unlockables
- Social sharing of achievements
- Custom badge creation system

