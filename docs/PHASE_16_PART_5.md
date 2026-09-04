# Phase 16 Part 5: NPC Relationship & Progression System

## Overview

Phase 16 Part 5 implements a comprehensive NPC relationship management system that tracks affection, dialogue progression, and relationship milestones. This system creates deep emotional connections between the player and NPCs through a progression-based relationship model.

## Key Features

### 1. Relationship Status System
- **6 Relationship Tiers**: Stranger → Acquaintance → Friend → Good Friend → Best Friend → Soulmate
- **Status-Based Progression**: Automatic status updates based on affection score (0-100)
- **Bilingual Support**: Both Japanese and English names for each status
- **Visual Indicators**: Each status has associated colors for UI representation

### 2. Affection Scoring System
- **Dynamic Affection Gains**: Affection increases based on dialogue score:
  - Score ≥90: +10 affection points
  - Score ≥80: +7 affection points
  - Score ≥70: +5 affection points
  - Score ≥60: +3 affection points
  - Score ≥50: +1 affection point
  - Score <50: +0 affection points
- **Score Clamping**: Affection always stays within 0-100 range
- **Interaction Tracking**: Counts total interactions and records last interaction time

### 3. Dialogue Chain System
- **Progressive Unlocking**: Dialogue chains unlock based on affection thresholds
- **Branching Dialogue**: Support for branching conversation paths
- **Choice Recording**: Tracks player dialogue choices for future context
- **Progress Tracking**: Calculates percentage completion of dialogue chains
- **Rewards**: Earn XP, coins, items, and badges upon chain completion

### 4. Milestone System
- **Achievement Milestones**: Define relationship progression checkpoints
- **Automatic Detection**: Automatically detect achieved milestones
- **Reward Tracking**: Each milestone provides XP and coin rewards
- **Achievement History**: Records when milestones are achieved

### 5. Bidirectional Affection
- **Player Perspective**: Tracks how much the player cares about the NPC
- **NPC Perspective**: Tracks the NPC's feelings towards the player
- **Asymmetric Relationships**: Allows unrequited or one-sided feelings
- **Independent Tracking**: Each perspective has its own 0-100 scale

### 6. Event Logging
- **Affection Events**: Records events that affect affection
- **Event History**: Maintains chronological log of relationship milestones
- **Event Data**: Flexible event data structure for custom event information
- **Special Events**: Achievements and special dialogue unlocks

## File Structure

### Models (`lib/models/npc_relationship_model.dart`)

**RelationshipStatus Enum**
- 6 levels: stranger, acquaintance, friend, goodFriend, bestFriend, soulmate
- Methods: `fromAffectionScore(int score)` to get status from score

**NPCRelationship Class**
Key properties:
- `npcId`: NPC identifier
- `userId`: Player identifier
- `affectionScore`: Main relationship score (0-100)
- `lastInteractionTime`: Last dialogue/interaction timestamp
- `totalInteractions`: Count of all interactions
- `affectionEvents`: List of relationship-affecting events
- `unlockedDialogues`: List of unlocked dialogue chain IDs
- `chosenDialoguePaths`: Map of dialogue choices made
- `specialEventAchievements`: List of achieved special events
- `playerAffectionLevel`: Player's feelings (0-100)
- `npcAffectionLevel`: NPC's feelings (0-100)

Key methods:
- `increaseAffection(int amount)`: Add affection points
- `decreaseAffection(int amount)`: Remove affection points
- `unlockDialogue(String dialogueId)`: Unlock a dialogue
- `recordDialoguePath(String dialogueId, String choicePath)`: Record player choice
- `achieveSpecialEvent(String eventId)`: Mark special achievement
- `addAffectionEvent(String eventDescription)`: Log relationship event
- `getStatus()`: Get current relationship status
- `copyWith()`: Create modified copy

**DialogueChain Class**
Represents a sequence of dialogues with branching points:
- `chainId`: Unique identifier
- `chainName`: Human-readable name
- `description`: What the chain is about
- `requiredAffectionLevel`: Minimum affection to access
- `dialogueSequence`: Ordered list of dialogue IDs
- `branchPoints`: Map of dialogue ID to available choices
- `reward`: Rewards for completing chain
- `unlockedByEvents`: Special events that unlock this chain

**DialogueChainReward Class**
Rewards upon chain completion:
- `xpEarned`: Experience points
- `coinsEarned`: In-game currency
- `specialItems`: Optional special items
- `unlocksSpecialDialogues`: Dialogues unlocked upon completion
- `achievementBadge`: Optional achievement badge

**RelationshipMilestone Class**
Progression checkpoints:
- `milestoneId`: Unique identifier
- `name`: Milestone name
- `description`: What the milestone represents
- `requiredAffectionScore`: Affection needed to unlock
- `achievedAt`: When milestone was achieved
- `reward`: Milestone rewards

**RelationshipMilestoneReward Class**
Milestone-specific rewards:
- `xp`: Experience points
- `coins`: Currency reward
- `badge`: Optional badge name
- `specialContent`: Optional special content unlock

**RelationshipEvent Class**
Event record:
- `eventType`: Type of event (e.g., "affection_increase", "dialogue_unlock")
- `npcId`: Related NPC
- `description`: Event description
- `affectionChange`: Amount affection changed
- `timestamp`: When event occurred
- `eventData`: Flexible data for custom properties

### Services (`lib/services/npc_relationship_service.dart`)

**NPCRelationshipService Class**
Singleton service managing all relationship operations.

Core Methods:

**Initialization**
- `initializeRelationship(String npcId, String userId)`: Create new relationship

**Affection Management**
- `updateAffectionAfterDialogue(NPCRelationship relationship, int score, String? feedback)`: 
  Update affection based on dialogue score
- `updateNPCAffection(NPCRelationship relationship, int changeAmount, String reason)`:
  Change NPC's feelings towards player
- `updatePlayerAffection(NPCRelationship relationship, int changeAmount, String reason)`:
  Change player's feelings towards NPC

**Dialogue Unlocking**
- `unlockDialoguesForAffectionLevel(NPCRelationship relationship, List<DialogueChain> availableChains)`:
  Unlock chains based on affection threshold
- `unlockSpecialDialogue(NPCRelationship relationship, String dialogueId)`:
  Unlock individual special dialogue
- `recordDialogueChoice(NPCRelationship relationship, String dialogueId, String choicePath)`:
  Record player choice in dialogue

**Progression Tracking**
- `getDialogueChainProgress(NPCRelationship relationship, DialogueChain chain)`:
  Calculate percentage completion (0.0-1.0) of dialogue chain
- `checkMilestones(NPCRelationship relationship, List<RelationshipMilestone> milestones)`:
  Detect newly achieved milestones
- `getRelationshipStatus(NPCRelationship relationship)`: Get current status

**Relationship Management**
- `generateRelationshipSummary(NPCRelationship relationship)`: Create summary view
- `rankRelationshipsByAffection(List<NPCRelationship> relationships)`: Sort by affection
- `resetRelationship(NPCRelationship relationship)`: Clear all relationship progress

**Event Creation**
- `createRelationshipEvent(String eventType, String npcId, String description, ...)`:
  Create event record with custom data

**RelationshipSummary Class**
Display-friendly relationship data:
- `npcId`, `status`, `affectionScore`, `totalInteractions`
- `unlockedDialoguesCount`, `achievementsCount`
- `lastInteractionTime`

Methods:
- `getProgressPercentage()`: Returns affectionScore / 100.0
- `getPointsToNextStatus()`: Calculate points needed for next tier

### Providers (`lib/providers/npc_relationship_provider.dart`)

**State Management with Riverpod**

- `npcRelationshipServiceProvider`: Singleton service provider
- `npcRelationshipProvider.family(npcId, userId)`: StateNotifierProvider for relationship state
  - Family: keyed by (npcId, userId)
  - Type: StateNotifierProvider<NPCRelationshipNotifier, AsyncValue<NPCRelationship>>
  - Methods:
    - `updateAffectionAfterDialogue(score, feedback)`
    - `unlockDialoguesForAffectionLevel(chains)`
    - `recordDialogueChoice(dialogueId, choicePath)`
    - `updateNPCAffection(changeAmount, reason)`
    - `updatePlayerAffection(changeAmount, reason)`

- `relationshipStatusProvider.family(npcId, userId)`: Status selector
- `affectionScoreProvider.family(npcId, userId)`: Score selector
- `unlockedDialoguesProvider.family(npcId, userId)`: Unlocked dialogues selector
- `relationshipSummaryProvider.family(npcId, userId)`: Summary selector

**NPCRelationshipNotifier Class**
Manages state updates:
- Handles all async operations
- Updates relationships immutably
- Fires state changes for UI updates

### Widgets (`lib/widgets/npc_relationship_widget.dart`)

**NPCRelationshipWidget**
Main relationship display card:
- Shows NPC emoji and name
- Displays relationship status (color-coded)
- Affection progress bar (0-100)
- Next threshold indicator
- Statistics tiles:
  - Total conversations
  - Unlocked dialogues count
  - Achievements count
- Last interaction time
- Status colors:
  - Grey: Stranger (0-9)
  - Blue: Acquaintance (10-24)
  - Green: Friend (25-49)
  - Orange: Good Friend (50-74)
  - Red: Best Friend (75-89)
  - Pink: Soulmate (90+)

**DialogueChainProgressWidget**
Shows chain completion status:
- Chain name and description
- Progress bar
- Dialogue count (completed/total)
- Unlock points indicator

**MilestoneWidget**
Milestone display:
- Milestone name and description
- Required affection score
- Achieved/not achieved state
- Reward display
- Points needed to achieve

## Affection Scoring System

### Dialogue Score to Affection Mapping

```
Score ≥90  → +10 points (Excellent)
Score ≥80  → +7 points  (Very Good)
Score ≥70  → +5 points  (Good)
Score ≥60  → +3 points  (Fair)
Score ≥50  → +1 point   (Acceptable)
Score <50  → +0 points  (Poor)
```

### Relationship Threshold Progression

```
0-9      → Stranger
10-24    → Acquaintance
25-49    → Friend
50-74    → Good Friend
75-89    → Best Friend
90-100   → Soulmate
```

### Example Progression

To reach Soulmate (90 points) with excellent dialogues (90+ score):
- Required dialogues: 9 (10 points per dialogue)
- Time: Depends on interaction frequency
- Expected gameplay: ~30-60 minutes of regular interactions

## Integration with Other Systems

### Phase 16 Part 2: Dialogue Engine
- Dialogue score comes from dialogue engine performance
- Dialogue chains reference dialogue IDs from Phase 2
- Special dialogues integrate with dialogue system

### Phase 16 Part 4: Town NPC System
- NPC locations (Phase 4) provide context for interactions
- Proximity detection enables natural dialogue initiation
- NPC state integrates with relationship status

## Test Coverage

### Unit Tests (`test/services/npc_relationship_service_test.dart`)
40+ test cases covering:
- Service initialization
- Affection updates
- Status transitions
- Dialogue unlocking
- Milestone detection
- Choice recording
- Affection updates (player/NPC perspectives)
- Event creation
- Relationship ranking and reset

### Integration Tests (`test/integration/npc_relationship_integration_test.dart`)
30+ test cases covering:
- Complete relationship progression
- Dialogue chain workflows
- Milestone achievement flows
- Bidirectional affection scenarios
- Multiple NPC management
- Event logging and tracking

### Widget Tests
To be implemented in Phase 16 Part 6+:
- NPCRelationshipWidget rendering
- Progress bar updates
- Status color changes
- Interaction callbacks

## Usage Example

```dart
// Initialize relationship with NPC
var relationship = service.initializeRelationship('npc-alice', 'player-1');

// After dialogue interaction
relationship = service.updateAffectionAfterDialogue(
  relationship,
  dialogueScore,  // 0-100
  'Excellent dialogue!',
);

// Check for milestone achievements
final milestones = [
  RelationshipMilestone(
    milestoneId: 'milestone-1',
    name: 'First Contact',
    description: 'First conversation',
    requiredAffectionScore: 10,
    reward: RelationshipMilestoneReward(xp: 50, coins: 10),
  ),
];

final achieved = service.checkMilestones(relationship, milestones);
for (final milestone in achieved) {
  // Grant rewards
  player.addXP(milestone.reward.xp);
}

// Unlock dialogues based on affection
final chains = [/* available dialogue chains */];
relationship = service.unlockDialoguesForAffectionLevel(relationship, chains);

// Generate UI summary
final summary = service.generateRelationshipSummary(relationship);
// Use summary to display relationship status UI
```

## JSON Serialization

All model classes are decorated with `@JsonSerializable()`:
- Automatic to/from JSON conversion
- Enables easy data persistence
- Supports cloud save/load functionality

**Note**: JSON serialization code (.g.dart files) must be generated:
```bash
flutter pub run build_runner build
```

## Future Enhancements

1. **Relationship Decay**: Affection gradually decreases if not interacting
2. **Branching Storylines**: Different dialogue paths based on relationship history
3. **Relationship Conflicts**: Disagreements affecting affection negatively
4. **Love Interests**: Special romance-path relationships
5. **Jealousy System**: Competing interests between NPCs
6. **Gift System**: Gift-giving to increase affection
7. **Scheduling**: Track when NPCs are available
8. **Breakups**: Ability to end relationships
9. **Cloud Sync**: Save relationships to cloud
10. **Multiplayer**: Shared relationship events between players

## Performance Considerations

- Relationships stored in memory for current session
- Lazy loading from persistence layer
- Efficient affection calculation (O(1))
- Milestone checking is O(n) where n = number of milestones
- Summary generation is O(1)

## Error Handling

All methods use immutable copyWith pattern to ensure data integrity:
- No direct field mutations
- State changes return new instances
- Safe concurrent access
- Easy undo/redo functionality

## Database Schema (Future)

When integrated with persistent storage:

```
relationships
├── id (npcId + userId)
├── affectionScore
├── totalInteractions
├── playerAffectionLevel
├── npcAffectionLevel
├── createdAt
├── updatedAt
├── unlockedDialogues (JSON array)
├── chosenDialoguePaths (JSON map)
├── affectionEvents (JSON array)
└── specialEventAchievements (JSON array)

milestones
├── id (npcId + milestoneId)
├── achievedAt
└── reward (JSON)
```

## Contributing

When adding new features:
1. Update model classes to include new data
2. Add service methods for business logic
3. Create provider wrapper if needed
4. Add unit tests (test/services/)
5. Add integration tests (test/integration/)
6. Update widget representations
7. Document changes in this file

## Related Documentation

- [Phase 16 Part 2: Dialogue Engine](./PHASE_16_PART_2.md)
- [Phase 16 Part 4: Town NPC System](./PHASE_16_PART_4.md)
- [Eigo Architecture Guide](./ARCHITECTURE.md)
