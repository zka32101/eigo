# Phase 23: Achievements & Progression System
## アチーブメント・進行度システム

## System Overview

Phase 23 implements a comprehensive achievement and progression tracking system:

- **11 Achievements**: Across 5 categories (Combat, Exploration, Economy, Social, Skills)
- **5 Milestones**: Major progression checkpoints with rewards
- **Progress Tracking**: Real-time achievement progress monitoring
- **Ranking System**: 5 ranks based on completion (Bronze → Legendary)
- **Reward System**: Gold and points for achievements and milestones
- **Statistics**: Detailed player progression analytics

## Core Classes

### AchievementsProgressionSystem (Singleton)

Main manager for all achievements and progression.

**Key Data Structures:**
```
_achievements         Map<String, Achievement>    // All achievements
_playerAchievements  Map<String, List>            // Earned achievements per player
_playerProgress      Map<String, List>            // Progress tracking per player
_milestones          Map<String, Milestone>       // Milestone definitions
_playerMilestones    Map<String, List>            // Achieved milestones per player
_statistics          Map<String, Statistics>      // Player statistics
```

## Achievement System

### 11 Achievements

**Combat (3 achievements)**
- First Victory: Win 1 battle (10 points, 100G)
- Battle Master: Win 50 battles (50 points, 500G)
- Boss Slayer: Defeat 10 bosses (75 points, 750G)

**Exploration (2 achievements)**
- Explorer: Visit all 6 areas (40 points, 400G)
- Dungeon Delver: Complete 20 dungeons (60 points, 600G)

**Economy (2 achievements)**
- Merchant: Trade 100 items (35 points, 350G)
- Wealthy: Accumulate 10,000 gold (50 points, 500G)

**Social (2 achievements)**
- Matchmaker: Marry an NPC (55 points, 550G)
- Family Tree: Have 3 children (65 points, 650G)

**Skills (2 achievements)**
- Skill Collector: Learn 10 skills (45 points, 450G)
- Master Crafter: Craft 50 items (55 points, 550G)

### Achievement Properties

```dart
class Achievement {
  id: String                           // Unique ID
  name: String                         // Display name
  description: String                  // Description
  category: AchievementCategory        // Category
  points: int                          // Points awarded
  reward: int                          // Gold reward
  requirement: int                     // Completion requirement
}
```

## Milestone System

### 5 Milestones

**Progression (3 milestones)**
- Level 10: Achieve level 10 (200G)
- Level 25: Achieve level 25 (500G)
- Level 50: Achieve level 50 (1,000G)

**Social (1 milestone)**
- Honored Reputation: Reach 100 total reputation (300G)

**Economy (1 milestone)**
- Prosperous: Accumulate 5,000 gold (400G)

### Milestone Properties

```dart
class Milestone {
  id: String                           // Unique ID
  name: String                         // Display name
  description: String                  // Description
  category: MilestoneCategory          // Category
  requirement: int                     // Completion requirement
  reward: int                          // Gold reward
}
```

## Progress Tracking

### ProgressTracker

Tracks ongoing achievement progress:

```dart
class ProgressTracker {
  id: String                           // Progress ID
  category: String                     // Category name
  currentValue: int                    // Current progress
  maxValue: int                        // Target value (usually 100)
  startedAt: int                       // Start timestamp
  lastUpdatedAt: int                   // Last update timestamp
}
```

### Progression Methods

**updateProgress()**
```dart
bool updateProgress(
  String playerId,
  String progressId,
  int currentValue,
  String category,
)
```
- Updates progress value
- Checks for achievement completion
- Validates milestone achievement

**_checkAchievementCompletion()**
- Called after progress update
- Compares current value against requirement
- Automatically unlocks achievements

## Ranking System

### 5 Ranks

Based on completion percentage:

- **Bronze**: 0-24% completion
- **Gold**: 25-49% completion
- **Platinum**: 50-74% completion
- **Diamond**: 75-89% completion
- **Legendary**: 90-100% completion

### Leveling

Player level calculated as: (totalPoints / 100) + 1

## Statistics Tracking

### AchievementStatistics

```dart
class AchievementStatistics {
  playerId: String
  totalAchievements: int               // Achievements earned
  totalMilestones: int                 // Milestones achieved
  totalPoints: int                     // Total points earned
  totalRewards: int                    // Total gold earned
  completionPercentage: int            // Overall completion %
}
```

## Core Methods

**unlockAchievement()**
```dart
bool unlockAchievement(String playerId, String achievementId)
```
- Unlocks achievement if not already unlocked
- Updates player statistics
- Returns success status

**updateProgress()**
```dart
bool updateProgress(String playerId, String progressId, int currentValue, String category)
```
- Updates progress tracker
- Checks achievement completion
- Updates statistics

**getPlayerAchievements()**
```dart
List<Achievement> getPlayerAchievements(String playerId)
```
- Returns earned achievements

**getPlayerProgress()**
```dart
List<ProgressTracker> getPlayerProgress(String playerId)
```
- Returns active progress trackers

**getStatistics()**
```dart
AchievementStatistics? getStatistics(String playerId)
```
- Returns player statistics

**getPlayerMilestones()**
```dart
List<Milestone> getPlayerMilestones(String playerId)
```
- Returns achieved milestones

## Integration Patterns

### With Combat System
- Track battles won
- Unlock combat achievements
- Record boss defeats

### With Exploration
- Track areas visited
- Count dungeon completions
- Monitor exploration progress

### With Economy
- Track item trades
- Monitor gold accumulation
- Count crafting completions

### With Inventory
- Track skill learning
- Monitor crafting activity
- Record item upgrades

### With Marriage System
- Track NPC marriages
- Count children born
- Monitor family progression

## Performance Characteristics

- **unlockAchievement()**: O(1)
- **updateProgress()**: O(1) + O(n) achievement check (n typically < 5)
- **getPlayerAchievements()**: O(1)
- **getStatistics()**: O(1)
- **Progression Updates**: < 2ms

## Quality Metrics

- ✅ 11 achievements across 5 categories
- ✅ 5 milestones with progression gates
- ✅ Real-time progress tracking
- ✅ 5-tier ranking system
- ✅ Automatic achievement detection
- ✅ Statistical analysis
- ✅ Reward system

## Example Usage

```dart
final system = AchievementsProgressionSystem.getInstance();
system.initialize();

// Unlock achievement
system.unlockAchievement('player_001', 'first_victory');

// Update progress
system.updateProgress(
  'player_001',
  'battles_won',
  50,
  'combat',
);

// Get statistics
final stats = system.getStatistics('player_001');
print('Rank: ${stats?.getRank()}');
print('Level: ${stats?.getLevel()}');

// Get achievements
final achievements = system.getPlayerAchievements('player_001');

// Get detailed report
print(system.getProgressionReport('player_001'));
```

## Testing Examples

See `lib/examples/achievements_progression_example.dart` for:
- 5-tab Flutter UI
- Overview with ranking and points
- Achievement list with unlock status
- Milestone tracking
- Real-time progress bars
- Detailed statistics

## Expansion Patterns

### Adding New Achievements
```dart
_addAchievement(Achievement(
  id: 'new_achievement',
  name: 'Achievement Name',
  description: 'Description',
  category: AchievementCategory.combat,
  points: 50,
  reward: 500,
  requirement: 10,
));
```

### Adding Progress Types
- Link to existing categories
- Create progress trackers
- Auto-unlock on completion

### Advanced Features (Phase 24+)
- Hidden achievements
- Seasonal achievements
- Daily challenges
- Achievement tiers
- Leaderboards
- Badge system
