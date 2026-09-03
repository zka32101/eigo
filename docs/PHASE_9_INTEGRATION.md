# Phase 9: Social Features Integration Guide

## Overview

This document provides integration points and examples for connecting the Phase 9 social features system with existing game mechanics. The social system automatically tracks player activities, maintains leaderboards, and enables multiplayer challenges across the entire game.

## Integration Architecture

The integration layer (`SocialGameIntegrationService`) connects:
- **Conversation System** → Friend Activity Feed
- **Achievement System** → Achievement Unlocks + Friend Notifications
- **Leaderboard System** → Rank Change Activities + Challenge Completion
- **Streak System** → Milestone Activities
- **Challenge System** → Challenge Progress + Completion Awards

## Core Integration Points

### 1. Conversation Completion Integration

When a player completes a conversation successfully, record it in the social system:

```dart
// In conversation completion callback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/social_game_integration_service.dart';

Future<void> onConversationComplete(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required String npcName,
  required String location,
  required int xpGained,
}) async {
  // Record in social system
  await recordConversationInSocial(
    ref,
    userId: userId,
    displayName: displayName,
    npcName: npcName,
    location: location,
    xpGained: xpGained,
  );

  // Continue with existing logic
  // - Award XP
  // - Update user stats
  // - Check for achievements
}
```

**Integration Point Files:**
- `lib/screens/conversation_screen.dart` (conversation completion handler)
- `lib/services/conversation_service.dart` (if exists)

**Expected Behavior:**
- Activity recorded in `friendActivities/{userId}/activities/`
- Friend activity feed updated in real-time
- Friends notified (if privacy settings allow)
- Visible in social → Activity Feed

---

### 2. Achievement Unlock Integration

When player unlocks an achievement, record it socially:

```dart
// In achievement unlock detection
import '../services/social_game_integration_service.dart';

Future<void> onAchievementUnlocked(
  WidgetRef ref, {
  required Achievement achievement,
  required String userId,
  required String displayName,
}) async {
  // Record in social system
  await recordAchievementInSocial(
    ref,
    userId: userId,
    displayName: displayName,
    achievementTitle: achievement.title,
    rewardXp: achievement.rewardXp,
    achievementId: achievement.id,
  );

  // Existing achievement logic
  // - Show unlock animation
  // - Award XP/coins
  // - Update user progress
  // - Check for category badges
}
```

**Integration Point Files:**
- `lib/screens/reward_screen.dart` (achievement display)
- `lib/services/achievement_service.dart`
- `lib/providers/achievement_provider.dart`

**Expected Behavior:**
- Achievement activity recorded immediately
- Friend notifications sent (if enabled)
- Visible in friend activity feeds
- Tracked in Firestore `friendActivities` collection

---

### 3. Leaderboard Rank Change Integration

When player's leaderboard rank changes, record the activity:

```dart
// In leaderboard update logic
import '../services/social_game_integration_service.dart';

Future<void> onRankUpdated(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required int previousRank,
  required int currentRank,
  required int totalXp,
}) async {
  // Only record if rank actually changed
  if (previousRank == currentRank) return;

  // Record rank change in social system
  await recordRankChangeInSocial(
    ref,
    userId: userId,
    displayName: displayName,
    previousRank: previousRank,
    currentRank: currentRank,
  );

  // Existing leaderboard logic
  // - Update leaderboard position
  // - Send notifications (Phase 8)
  // - Update user profile
}
```

**Integration Point Files:**
- `lib/services/english_town_leaderboard_realtime_service.dart`
- `lib/screens/english_town_leaderboard_realtime_screen.dart`

**Expected Behavior:**
- Rank change activity recorded
- Top 50 players get friend notifications
- Milestone ranks (top 10, top 100) highlighted
- Visible in friend activity feeds

---

### 4. Streak Milestone Integration

Record when players reach streak milestones (7, 14, 30, 60, 100, 365 days):

```dart
// In streak tracking logic
import '../services/social_game_integration_service.dart';

Future<void> onStreakMilestoneReached(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required int streakDays,
  required int xpReward,
}) async {
  // Record milestone achievement
  await recordStreakMilestoneInSocial(
    ref,
    userId: userId,
    displayName: displayName,
    streakDays: streakDays,
    xpReward: xpReward,
  );

  // Existing streak logic
  // - Award milestone bonus XP
  // - Show celebration screen
  // - Update user achievements
  // - Check for streak badges
}
```

**Integration Point Files:**
- `lib/services/streak_service.dart` (if exists)
- `lib/providers/streak_provider.dart`

**Expected Behavior:**
- Milestone-only notifications (7, 14, 30+ days)
- Friend notifications for major milestones (30+)
- Visible in friend activity feeds
- Tracked for streak badges/achievements

---

### 5. Multiplayer Challenge Integration

#### Challenge Start

When player joins or creates a multiplayer challenge:

```dart
// In challenge creation/joining
import '../services/social_game_integration_service.dart';

Future<void> onChallengeStart(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required String challengeTitle,
  required String challengeId,
  required List<String> participantIds,
}) async {
  // Record challenge start
  await recordChallengeStartInSocial(
    ref,
    userId: userId,
    displayName: displayName,
    challengeTitle: challengeTitle,
  );

  // Create social challenge entry
  // This is handled by social service
  await createMultiplayerChallenge(
    ref,
    title: challengeTitle,
    description: '',
    participantIds: participantIds,
    objective: ChallengeObjective.totalConversations,
    targetValue: 10,
    duration: const Duration(days: 7),
  );
}
```

#### Challenge Progress Update

During gameplay, update challenge progress:

```dart
// In conversation or activity completion within a challenge
import '../services/social_game_integration_service.dart';

Future<void> onActivityDuringChallenge(
  WidgetRef ref, {
  required String userId,
  required String challengeId,
  required int activityValue, // 1 for conversation, XP amount, etc.
}) async {
  // Update user's challenge progress
  await updateChallengeSocialProgress(
    ref,
    challengeId: challengeId,
    userId: userId,
    newProgress: activityValue,
  );

  // Existing activity logic continues
}
```

#### Challenge Completion

When challenge period ends or completes:

```dart
// In challenge completion logic
import '../services/social_game_integration_service.dart';

Future<void> onChallengeCompleted(
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required String challengeTitle,
  required bool isWinner,
  required int? xpReward,
  required List<String> winnerIds,
}) async {
  // Record completion in social system
  await recordChallengeCompletionInSocial(
    ref,
    userId: userId,
    displayName: displayName,
    challengeTitle: challengeTitle,
    isWinner: isWinner,
    xpReward: xpReward,
  );

  // Award prizes to all participants
  for (final winnerId in winnerIds) {
    // Distribute XP/coins based on rank
    // Send completion notifications
    // Update challenge completion badges
  }
}
```

**Integration Point Files:**
- `lib/screens/social_multiplayer_challenges_screen.dart`
- `lib/services/english_town_social_service.dart`

---

## Privacy & Settings Integration

### Activity Feed Privacy

The social system respects user privacy settings when recording and broadcasting activities:

```dart
// Check privacy settings before sending notifications
final showAchievements = ref.read(showAchievementsOnFeedProvider);
final showConversations = ref.read(showConversationsOnFeedProvider);
final showChallenges = ref.read(showChallengesOnFeedProvider);

if (showAchievements) {
  // Send notification to friends
}
```

**Privacy Settings:**
- `showAchievementsOnFeedProvider` - Control achievement visibility
- `showConversationsOnFeedProvider` - Control conversation visibility
- `showChallengesOnFeedProvider` - Control challenge visibility
- `allowFriendRequestsProvider` - Accept friend requests
- `allowChallengeInvitesProvider` - Accept challenge invitations
- `publicProfileProvider` - Make profile public

Integration screens should provide UI for these settings:

```dart
// In settings screen
SettingsSwitch(
  title: 'アチーブメントを共有',
  value: ref.watch(showAchievementsOnFeedProvider),
  onChanged: (value) {
    ref.read(showAchievementsOnFeedProvider.notifier).state = value;
  },
)
```

---

## Notification Integration

The social system integrates with Phase 8 FCM push notifications:

```dart
// Phase 8 notification is sent automatically when:
// 1. Friend completes achievement (if achievement sharing enabled)
// 2. Friend reaches top 50 on leaderboard
// 3. Friend completes a challenge
// 4. Streak milestone reached (30+ days)
// 5. Friend joins same challenge

// These use the quietHours settings from Phase 8
// and respect user notification preferences
```

---

## Real-Time Updates

### Leaderboard Updates

After rank changes, leaderboard screen should refresh:

```dart
// In leaderboard screen
ref.refresh(leaderboardWithFriendsProvider);
```

### Challenge Progress

Challenge leaderboard updates as participants make progress:

```dart
// Challenge participants see live progress
final challenge = ref.watch(multiplayerChallengeProvider(challengeId));

challenge.whenData((c) {
  // Display current participant progress
  // Show live ranking updates
});
```

### Activity Feed

Friend activity feed updates in real-time:

```dart
// Activity feed auto-refreshes
final activities = ref.watch(friendActivityFeedProvider);

activities.whenData((list) {
  // Display latest activities from friends
  // Sorted by recency
});
```

---

## Firestore Schema References

When implementing integrations, these Firestore paths are used:

```
friendActivities/{userId}/activities/{activityId}
  └─ Type: FriendActivity (see Phase 9 docs)
  └─ Recorded by: SocialGameIntegrationService

challenges/{challengeId}
  └─ Type: MultiplayerChallenge
  └─ Updated by: Challenge progress updates

leaderboard/{rank}
  └─ Updated by: Rank change detection
  └─ Fields: userId, displayName, totalXp, etc.

friendships/{friendshipId}
  └─ Type: Friendship
  └─ Status: pending, accepted, blocked
```

---

## Testing Integration Points

### Manual Testing Checklist

- [ ] **Conversation Recording**
  - Complete conversation → Activity appears in friend feed
  - Check privacy setting respected
  - Verify timestamps correct

- [ ] **Achievement Recording**
  - Unlock achievement → Activity recorded immediately
  - Friend receives notification (if enabled)
  - Verify in friend feed

- [ ] **Rank Change Recording**
  - Rank improves/drops → Activity recorded
  - Top 50 players get notifications
  - Friends see updated rank

- [ ] **Streak Milestone**
  - Reach 30-day streak → Activity recorded
  - Friend notifications sent
  - Badge/achievement updates

- [ ] **Challenge Integration**
  - Create challenge → Listed in active challenges
  - Complete activity during challenge → Progress updates
  - Challenge ends → Completion recorded, prizes awarded

- [ ] **Privacy Settings**
  - Disable achievement sharing → No achievements in feed
  - Disable friend requests → Cannot receive requests
  - Disable challenge invites → Cannot be invited

### Debugging

Enable logging to monitor integration:

```dart
// In integration service
print('[SocialIntegration] Recording conversation for $userId');
print('[SocialIntegration] Challenge progress: $userId: $newProgress');
print('[SocialIntegration] Rank change: $previousRank → $currentRank');
```

---

## Migration from Existing Systems

If replacing older friend/social systems:

1. **Backup old data** to Firestore under `legacy_data/` collection
2. **Map old friend models** to `SocialProfile` format
3. **Import existing friends** as `Friendship` entities with `status: accepted`
4. **Migrate historical activities** to `friendActivities/` collection
5. **Update navigation** to use new social screens

Example migration:

```dart
// Convert old Friend model to SocialProfile
Future<void> migrateOldFriends(List<OldFriend> oldFriends) async {
  for (final old in oldFriends) {
    final profile = SocialProfile(
      userId: old.userId,
      displayName: old.name,
      level: old.level,
      totalXp: old.coinsEarned,  // Map coins to XP
      totalConversations: 0,      // Would need data source
      currentStreak: 0,
      longestStreak: 0,
      friendsCount: 0,
      joinedAt: old.addedAt,
      badges: [],
    );
    // Save to Firestore
  }
}
```

---

## Performance Optimization

### Activity Feed Pagination

Load activities in batches to avoid UI lag:

```dart
// Fetch 50 activities at a time
final activities = ref.watch(
  friendActivityFeedProvider.select(
    (a) => a.when(
      data: (list) => list.take(50).toList(),
      loading: () => [],
      error: (_, __) => [],
    ),
  ),
);
```

### Challenge Participant Limit

Recommended max 10 participants per challenge for performance:

```dart
// Validate before creating
if (participantIds.length > 10) {
  throw Exception('Maximum 10 participants per challenge');
}
```

### Leaderboard Caching

Cache leaderboard data for 5 minutes before refresh:

```dart
// Leaderboard updates every 5 minutes
// Set poll interval in leaderboard service
```

---

## Future Enhancement Hooks

Reserved integration points for future phases:

```dart
// Planned integrations:

// 1. Chat/DM system (Phase X)
// - Send direct messages to friends
// - Message notifications

// 2. Guilds/Groups (Phase X)
// - Guild challenges
// - Guild leaderboards
// - Guild chat

// 3. Seasonal events (Phase X)
// - Limited-time challenges
// - Event-specific rewards
// - Event leaderboards

// 4. Streaming integration (Phase X)
// - Share video highlights
// - Live streaming status
// - Replay sharing

// 5. AI recommendations (Phase X)
// - Suggest friends by interests
// - Recommend challenges
// - Matchmaking by skill
```

---

## Summary

Phase 9 social features are designed to integrate seamlessly with existing game systems through:

1. **Activity Recording** - Automatic logging of major events
2. **Real-Time Updates** - Live leaderboards, challenges, feeds
3. **Privacy Controls** - User-controlled sharing preferences
4. **Push Notifications** - Phase 8 integration for friend updates
5. **Challenge System** - Full multiplayer experience
6. **Leaderboard Sync** - Social rankings with friend highlighting

All integration points are marked with `recordXXXInSocial()` functions for easy discovery and implementation.

---

**Phase 9 Status**: ✅ Complete (Social Features - Infrastructure + UI + Integration)
**Next Phase**: Phase 10 - Advanced Analytics & Metrics

