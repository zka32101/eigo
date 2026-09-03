# Phase 9: Social Features & Multiplayer System

## Overview

Phase 9 implements a complete social ecosystem enabling players to connect with friends, participate in multiplayer challenges, and view friend activities. This system transforms the game from a solo experience into a collaborative social platform.

## Architecture

### Core Models

#### 1. **SocialProfile**
Represents a user's social presence and public statistics.

```dart
class SocialProfile {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int totalXp;
  final int totalConversations;
  final int currentStreak;
  final int longestStreak;
  final int friendsCount;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final String? bio;
  final List<String> badges;
  final Map<String, dynamic> metadata;
}
```

#### 2. **Friendship**
Manages relationships between users with status tracking.

```dart
class Friendship {
  final String friendshipId;
  final String userId1;
  final String userId2;
  final FriendshipStatus status;    // pending, accepted, blocked
  final DateTime connectedAt;
  final String? initiatedBy;
  final DateTime? statusChangedAt;
}

enum FriendshipStatus {
  pending,   // Request sent but not accepted
  accepted,  // Friends
  blocked,   // Blocked by one party
}
```

**Lifecycle:**
1. User A sends friend request → `FriendshipStatus.pending`
2. User B accepts request → `FriendshipStatus.accepted`
3. Either user can block → `FriendshipStatus.blocked`
4. Either user can remove → Record deleted

#### 3. **MultiplayerChallenge**
Represents collaborative challenges between players.

```dart
class MultiplayerChallenge {
  final String challengeId;
  final String title;
  final String description;
  final List<String> participantIds;
  final String creatorId;
  final ChallengeObjective objective;
  final DateTime createdAt;
  final DateTime endsAt;
  final int targetValue;
  final String? prizePool;
  final bool completed;
  final Map<String, int> participantProgress;
  final List<String> winnersIds;
}

enum ChallengeObjective {
  totalConversations,  // Talk to NPCs
  totalXp,            // Earn XP
  totalCoins,         // Earn coins
  consecutiveDays,    // Maintain streak
  uniqueNpcs,         // Talk to different NPCs
  uniqueLocations,    // Visit different locations
}
```

**Example:** "Complete 10 conversations this week"
- 5 participants
- Objective: `totalConversations`
- TargetValue: 10
- Duration: 7 days
- Prize: 500 XP pool (100 XP per winner)

#### 4. **ChallengeInvitation**
Represents an invitation to join a challenge.

```dart
class ChallengeInvitation {
  final String invitationId;
  final String challengeId;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final InvitationStatus status;  // pending, accepted, declined
  final DateTime? respondedAt;
}

enum InvitationStatus {
  pending,   // Awaiting response
  accepted,  // User joined challenge
  declined,  // User declined
}
```

#### 5. **FriendActivity**
Records activities visible to friends.

```dart
class FriendActivity {
  final String activityId;
  final String userId;
  final String displayName;
  final FriendActivityType type;
  final String title;
  final String description;
  final String? relatedId;
  final DateTime createdAt;
  final int? xpGained;
  final int? coinsGained;
}

enum FriendActivityType {
  conversation,        // Had a conversation
  achievementUnlocked, // Unlocked achievement
  streakMilestone,     // Reached streak milestone
  rankChange,          // Rank changed
  challengeStarted,    // Started a challenge
  challengeCompleted,  // Completed a challenge
  joinedFriends,       // Joined the game
}
```

### Services

#### EnglishTownSocialService

Core service implementing all social features:

**Friend Management:**
```dart
// Sending and accepting requests
sendFriendRequest(fromUserId, toUserId)
acceptFriendRequest(friendshipId)
declineFriendRequest(friendshipId)

// Blocking and removing friends
blockFriend(friendshipId)
removeFriend(friendshipId)

// Querying
getFriendsList(userId)
getPendingFriendRequests(userId)
```

**Challenge Management:**
```dart
// Creating and managing
createMultiplayerChallenge(...)
getActiveChallenges(userId)
updateChallengeProgress(challengeId, userId, value)
completeChallenge(challengeId, winnersIds)

// Invitations
inviteToChallenges(challengeId, fromUserId, toUserId)
acceptChallengeInvitation(invitationId)
```

**Activity Recording:**
```dart
// Recording activities
recordFriendActivity(userId, displayName, type, ...)

// Viewing activities
getFriendActivityFeed(userId, limit)
```

**Discovery:**
```dart
// Finding users and friends
searchUsers(query)
getLeaderboardWithFriends(userId, limit)
compareFriendStats(userId, friendId)
```

### Providers

#### Friend Management Providers
```dart
friendsListProvider              // Current user's friends
pendingFriendRequestsProvider    // Incoming requests
friendsCountProvider             // Friend count
sendFriendRequest(ref, userId)   // Action
acceptFriendRequest(ref, friendshipId)  // Action
declineFriendRequest(ref, friendshipId) // Action
```

#### Challenge Providers
```dart
activeChallengesProvider         // Active challenges for user
activeChallengesCountProvider    // Count of active challenges
multiplayerChallengeProvider     // Specific challenge by ID
createMultiplayerChallenge(ref, ...) // Action
updateChallengeProgress(ref, ...)    // Action
pendingChallengeInvitationsProvider  // Invitations awaiting response
inviteFriendToChallenge(ref, ...)    // Action
acceptChallengeInvitation(ref, ...)  // Action
```

#### Activity Providers
```dart
friendActivityFeedProvider       // Friend activities
recordFriendActivity(ref, ...)   // Action
```

#### Discovery Providers
```dart
userSearchProvider               // Search users by name
leaderboardWithFriendsProvider   // Leaderboard with friend highlighting
friendComparisonProvider         // Stats comparison with friend
```

#### Privacy Providers
```dart
showAchievementsOnFeedProvider       // Privacy toggle
showConversationsOnFeedProvider      // Privacy toggle
showChallengesOnFeedProvider         // Privacy toggle
allowFriendRequestsProvider          // Privacy toggle
allowChallengeInvitesProvider        // Privacy toggle
publicProfileProvider                // Profile visibility
```

## Firestore Schema

### Collections

```
users/{userId}/
├── profile: SocialProfile data
└── socialSettings: {
    privacy: {
      publicProfile: boolean,
      allowFriendRequests: boolean,
      allowChallengeInvites: boolean,
      showAchievements: boolean,
      showConversations: boolean,
      showChallenges: boolean,
    }
  }

friendships/{friendshipId}: {
  userId1: string,
  userId2: string,
  status: 'pending'|'accepted'|'blocked',
  connectedAt: timestamp,
  initiatedBy: string,
  statusChangedAt: timestamp,
}

challenges/{challengeId}: MultiplayerChallenge
├── Challenge details with all participants
└── Progress tracking for each participant

challengeInvitations/{invitationId}: ChallengeInvitation
└── Invitation with status and response tracking

friendActivities/{userId}/activities/{activityId}: FriendActivity
└── User's activity visible to friends

leaderboard/{rank}: {
  userId: string,
  displayName: string,
  totalXp: number,
  totalConversations: number,
  currentStreak: number,
  friendsCount: number,
  friends: [string] // List of connected friend IDs
}
```

## Features & Workflows

### 1. Friend System

**Add Friend Workflow:**
```
User A → Search User B
       ↓
    View User B's Profile
       ↓
    Send Friend Request
       ↓
User B ← Receives Notification
       ↓
    Views Friend Request
       ↓
    Accept/Decline
       ↓
Friendship Created/Rejected
```

**Friend List:**
- Display all accepted friendships
- Show mutual friends count
- Filter by activity
- Quick access to friend profiles
- One-tap message (future)

**Privacy Controls:**
- Block friends
- Remove friends
- Control visibility of activities
- Manage friend request permissions

### 2. Multiplayer Challenges

**Challenge Creation Workflow:**
```
User A → Creates Challenge
       ↓
    Selects Objective (conversations, XP, etc.)
       ↓
    Sets Target & Duration
       ↓
    Invites Friends
       ↓
Friends Receive Invitations
       ↓
    Accept to Join
       ↓
Challenge Starts
```

**Challenge Types:**

1. **Conversation Challenge**
   - Objective: Complete N conversations
   - Example: "10 conversations this week"
   - Perfect for group motivation

2. **XP Challenge**
   - Objective: Earn N XP
   - Example: "Earn 1000 XP"
   - Encourages consistent play

3. **Streak Challenge**
   - Objective: Maintain N consecutive days
   - Example: "30-day streak challenge"
   - Builds consistency habits

4. **Discovery Challenge**
   - Objective: Talk to N unique NPCs
   - Example: "Talk to all 20 NPCs"
   - Encourages exploration

5. **Location Challenge**
   - Objective: Visit N unique locations
   - Example: "Visit all 8 locations"
   - Rewards adventure

**Challenge Leaderboard:**
- Ranks participants by progress
- Shows time remaining
- Displays winners
- Prizes distributed on completion

**Prize Distribution:**
```
Total Prize Pool: 500 XP
Participants: 5

1st Place: 150 XP (30%)
2nd Place: 100 XP (20%)
3rd Place: 100 XP (20%)
Participants: 75 XP each (15% each)
```

### 3. Friend Activity Feed

**Activity Types:**
- 💬 Conversation: "Started conversation with Alex at Café"
- 🏆 Achievement: "Unlocked Perfect Response achievement"
- 🔥 Streak: "Reached 30-day streak!"
- 📈 Rank: "Climbed to rank #42"
- ⭐ Challenge: "Completed 'Weekly Champion' challenge"
- 🎮 Joined: "Joined English-Only Town"

**Feed Customization:**
- Toggle activity types visibility
- Filter by friend
- Sort by recency or importance
- Archive old activities

**Social Engagement:**
- Celebrate friend achievements
- Get inspired by friend progress
- Join ongoing challenges
- Learn from friend strategies

### 4. Friend Profiles & Comparison

**Friend Profile View:**
```
Avatar & Display Name
├── Stats
│   ├── Level & XP
│   ├── Conversations
│   ├── Current Streak
│   └── Longest Streak
├── Badges & Achievements
├── Bio
└── Actions
    ├── Remove Friend
    ├── Block
    ├── Invite to Challenge
    ├── Compare Stats
    └── View Activities
```

**Stats Comparison:**
```
Stat              | You    | Friend | Difference
────────────────────────────────────────────────
Total XP          | 5,200  | 4,800  | +400 ↑
Conversations     | 150    | 132    | +18 ↑
Current Streak    | 12     | 8      | +4 ↑
Level             | 15     | 14     | +1 ↑
```

### 5. Friend Leaderboard

**Features:**
- Global ranking with friend highlights
- Friend rankings
- Comparison mode (top friends)
- Friend vs friend challenges
- Mutual friends connections

**Badges & Recognition:**
- 👑 Top 10 Badge
- 🏆 Most Consistent (Longest Streak)
- 🚀 Most Conversations
- 💬 Most Talkative
- 🤝 Most Social (Friend Count)

## Integration Points

### During Conversation
```dart
// Record friend activity
await recordFriendActivity(ref,
  type: FriendActivityType.conversation,
  title: 'Conversed with Alex',
  description: 'Talked to Alex at Café',
  xpGained: 50,
);

// Notify friends via push notification
// (if privacy settings allow)
```

### On Achievement Unlock
```dart
// Record for friend feed
await recordFriendActivity(ref,
  type: FriendActivityType.achievementUnlocked,
  title: 'Unlocked Perfect Response',
  description: 'Scored 100 on a response',
);

// Send notifications to friends
```

### On Rank Change
```dart
// Record for friend feed
await recordFriendActivity(ref,
  type: FriendActivityType.rankChange,
  title: 'Climbed 3 positions!',
  description: 'New rank: #42',
);
```

### On Challenge Completion
```dart
// Mark challenge as complete
await completeChallenge(ref, challengeId, winnersIds);

// Record activity for all participants
await recordFriendActivity(ref,
  type: FriendActivityType.challengeCompleted,
  title: 'Completed Weekly Champion',
  description: 'Won the challenge!',
  xpGained: 150,
);

// Distribute prizes
// Send push notifications to winners
```

## Performance Considerations

1. **Friend Limit**: No hard limit, but UI optimized for 100+ friends
2. **Activity Feed**: Pagination with 50 items per load
3. **Challenge Participants**: Recommended max 10 per challenge
4. **Real-time Sync**: Updates every 2-5 minutes (batch processing)
5. **Search Index**: Indexed on displayName for instant results

## Future Enhancements

1. **Direct Messaging**
   - Private chat between friends
   - In-game notifications
   - Message history

2. **Guilds/Groups**
   - Invite-only communities
   - Guild leaderboards
   - Guild challenges
   - Guild chat

3. **Advanced Challenges**
   - Time-based bonuses
   - Difficulty scaling
   - Tournament brackets
   - Seasonal events

4. **Social Rewards**
   - Cosmetics for social interactions
   - Badges for milestones
   - Titles for achievements
   - Profile customization

5. **Friend Requests AI**
   - Suggest friends by interests
   - Find players in same region
   - Recommend challenges
   - Auto-matching by skill level

6. **Stream Integration**
   - Share replays/highlights
   - Live streaming via Twitch
   - Community content hub
   - Creator program

## Configuration

### Privacy Settings (Default: Privacy-Conscious)
```
- Public Profile: false
- Allow Friend Requests: true
- Allow Challenge Invites: true
- Show Achievements: true
- Show Conversations: true
- Show Challenges: true
```

### Challenge Defaults
```
- Max Participants: 10
- Default Duration: 7 days
- Min Target: 1
- Max Target: 1000
- Prize Pool: 100 XP per participant
```

## Testing Checklist

- [ ] Send and accept friend requests
- [ ] Block and unblock friends
- [ ] Remove friend relationship
- [ ] Search users by name
- [ ] View friend profiles
- [ ] Compare stats with friend
- [ ] Create multiplayer challenge
- [ ] Invite friends to challenge
- [ ] Accept challenge invitation
- [ ] Update challenge progress
- [ ] Complete challenge and distribute prizes
- [ ] Record friend activities
- [ ] View friend activity feed
- [ ] Filter activities by type
- [ ] Privacy settings work correctly
- [ ] Friend leaderboard shows correctly

---

**Phase 9 Status**: ✅ Complete (Social Features Infrastructure)
**Next Phase**: Phase 10 - UI Screens for Social Features
