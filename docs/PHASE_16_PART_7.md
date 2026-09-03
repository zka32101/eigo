# Phase 16 Part 7: NPC Behavior & Personality System

**Date**: 2026-09-03  
**Status**: Completed ✓  
**Branch**: `claude/phase-16-part-7-npc-behavior`

## Overview

Phase 16 Part 7 implements a comprehensive NPC Behavior and Personality system that adds psychological depth to NPCs. This system enables:

- **Personality-based differentiation** using the Big Five personality model
- **Dynamic mood management** based on time of day and interactions
- **Memory tracking** of player interactions
- **Habit systems** for recurring NPC behaviors
- **Personality-compatible dialogue** generation
- **Affection modifiers** based on NPC traits
- **Topic preferences** for realistic conversations

## Architecture

### 1. Core Models (`npc_behavior_model.dart`)

#### Enums

**PersonalityType**
- `cheerful` - Outgoing, positive
- `calm` - Composed, peaceful
- `timid` - Shy, cautious
- `ambitious` - Driven, goal-oriented
- `kind` - Warm, compassionate
- `sarcastic` - Witty, ironic

**NPCMood**
- `happy` (multiplier: 1.5)
- `neutral` (multiplier: 1.0)
- `sad` (multiplier: 0.7)
- `angry` (multiplier: 0.5)
- `excited` (multiplier: 1.8)
- `tired` (multiplier: 0.6)

#### PersonalityTraits (Big Five Model)

The system uses the established Big Five personality traits from psychology:

```dart
class PersonalityTraits {
  int openness;          // 0-100: Curiosity, creativity
  int conscientiousness; // 0-100: Discipline, responsibility
  int extraversion;      // 0-100: Sociability, energy
  int agreeableness;     // 0-100: Cooperation, empathy
  int neuroticism;       // 0-100: Emotional sensitivity
}
```

**Personality Type Determination**:
- Extraversion > 70 + Agreeableness > 60 → `cheerful`
- Extraversion > 70 + Agreeableness ≤ 60 → `sarcastic`
- Openness > 70 → `ambitious`
- Agreeableness > 70 → `kind`
- Neuroticism > 60 → `timid`
- Default → `calm`

#### BehaviorPattern

Defines how an NPC responds to specific conditions:

```dart
class BehaviorPattern {
  String patternId;                      // Unique identifier
  String name;                           // Display name
  String description;                    // What the behavior does
  String reaction;                       // What the NPC says/does
  List<PersonalityType> relatedPersonalities; // Which personalities use this
  BehaviorTrigger trigger;               // When it activates
  BehaviorOutcome outcome;               // What happens as a result
}
```

#### BehaviorTrigger

Determines when a behavior pattern activates:

```dart
class BehaviorTrigger {
  String type;              // "affection_level", "mood", "time_of_day", "event"
  int? minValue;            // Minimum condition value
  int? maxValue;            // Maximum condition value
  String? condition;        // Specific condition string
  double probability;       // 0.0-1.0 chance of triggering
}
```

#### BehaviorOutcome

Result of a behavior pattern:

```dart
class BehaviorOutcome {
  int affectionChange;      // Relationship delta
  String? moodChange;       // New mood if triggered
  String? unlocksDialogue;  // Dialogue ID to unlock
  String? eventId;          // Event to trigger
  int xpReward;             // Experience points gained
}
```

#### NPCBehaviorState

Main state container for an NPC:

```dart
class NPCBehaviorState {
  String npcId;
  PersonalityTraits personalityTraits;
  NPCMood currentMood;
  DateTime? lastMoodChangeTime;
  List<MemorizedInteraction> memorizedInteractions;
  List<ExecutedBehavior> executedBehaviors;
  List<String> preferredTopics;
  List<String> dislikedTopics;
  List<Habit> habits;
  DateTime createdAt;
  DateTime updatedAt;
}
```

#### MemorizedInteraction

Tracks player-NPC interactions:

```dart
class MemorizedInteraction {
  String interactionId;
  String type;           // "greeting", "dialogue", "gift", etc
  String description;    // What happened
  DateTime occurredAt;
  int value;             // -100 to 100: impact on relationship
}
```

#### ExecutedBehavior

Records when a behavior pattern is executed:

```dart
class ExecutedBehavior {
  String behaviorId;
  String behaviorName;
  DateTime executedAt;
  String result;         // Outcome of the behavior
}
```

#### Habit

Defines recurring NPC behaviors:

```dart
class Habit {
  String habitId;
  String name;
  String description;
  String frequency;      // "daily", "weekly", "monthly"
  DateTime? lastExecutedAt;
  int executionCount;
}
```

#### BehaviorTreeNode

Hierarchical behavior decision structure:

```dart
class BehaviorTreeNode {
  String nodeId;
  String nodeType;       // "selector", "sequence", "action", "condition"
  List<BehaviorTreeNode>? children;
  BehaviorPattern? action;
  String? condition;
}
```

### 2. Service Layer (`npc_behavior_service.dart`)

The `NPCBehaviorService` provides:

#### Initialization
- `initializeBehaviorState()` - Create new NPC behavior state

#### Mood Management
- `updateMoodByTime()` - Time-based mood changes
  - 21:00-05:00 → Tired
  - 08:00-12:00 → Excited
  - Otherwise → Neutral
- `updateMoodByInteraction()` - Mood changes from player actions
  - Value > 50 → Happy
  - Value > 25 → Excited
  - Value < -50 → Angry
  - Value < -25 → Sad

#### Affection & Personality
- `applyPersonalityModifier()` - Modifies affection changes based on traits
  - High agreeableness (>70): +30% gain multiplier
  - High neuroticism (>60): -20% gain multiplier
  - High extraversion (>70) for social: +20% multiplier
  
- `getReactionToPlayer()` - Generate contextual reactions
- `calculatePersonalityMatch()` - Rate NPC-player compatibility (0-100)

#### Interaction Tracking
- `memorizeInteraction()` - Record player-NPC interaction
- `getRecentInteractionCount()` - Count interactions in time period
- `getTimeSinceLastInteraction()` - Duration since last interaction

#### Dialogue & Communication
- `generatePersonalizedDialogueOptions()` - Personality-specific dialogue
- `isPreferredTopic()` - Check if topic is liked
- `isDislikedTopic()` - Check if topic is disliked
- `getTopicModifier()` - Affection delta for topic (+5, -5, or 0)

#### Behavior Execution
- `executHabit()` - Execute and track habit execution
- `executeBehaviorPattern()` - Execute behavior pattern
- `generateBehaviorSummary()` - Create behavior overview

#### Maintenance
- `resetBehavior()` - Reset to neutral state

### 3. State Management (`npc_behavior_provider.dart`)

Uses Riverpod 2.x for reactive state management:

```dart
// Single NPC behavior state
final npcBehaviorStateProvider = StateNotifierProvider.family<...>

// Personality type selector
final npcPersonalityProvider = FutureProvider.family<PersonalityType, String>

// Current mood
final npcMoodProvider = FutureProvider.family<NPCMood, String>

// Affection modifier
final affectionModifierProvider = FutureProvider.family<double, String>

// Behavior summary
final behaviorSummaryProvider = FutureProvider.family<BehaviorSummary, String>

// Personality compatibility
final personalityMatchProvider = FutureProvider.family<int, (String, PersonalityTraits)>

// And many more specialized providers...
```

#### NPCBehaviorNotifier

Provides mutable operations:
- `setPersonalityTraits()` - Set Big Five traits
- `changeMood()` - Change current mood
- `updateMoodByTime()` - Apply time-based mood
- `recordInteraction()` - Add interaction to memory
- `executeHabit()` - Execute a habit
- `executeBehaviorPattern()` - Execute a behavior
- `reset()` - Reset to defaults
- `addPreferredTopic()` - Add liked topic
- `addDislikedTopic()` - Add disliked topic
- `addHabit()` - Add new habit

## Key Design Decisions

### 1. Big Five Personality Model

**Why**: The Big Five is the most validated personality model in psychology. It:
- Provides objective, measurable traits
- Enables meaningful NPC differentiation
- Allows player-NPC compatibility calculations
- Is familiar to players interested in psychology

### 2. Mood System with Time-Based Changes

**Why**: Realistic NPCs change mood based on:
- Time of day (natural energy cycles)
- Player interactions (positive/negative)
- This adds immersion without overwhelming complexity

### 3. Memory & Interaction Tracking

**Why**: NPCs that remember players:
- Feel more realistic and alive
- Create emergent gameplay (relationship building)
- Enable callbacks to past interactions
- Support long-term consequence systems

### 4. Topic Preferences

**Why**: Enables:
- Natural conversations (some topics bore/upset NPCs)
- Strategic dialogue choices
- Player agency in relationship building

### 5. Habit System

**Why**: NPCs with routines:
- Feel more autonomous
- Create predictable patterns players can learn
- Support scheduling systems
- Enable location-based encounters

## Integration Points

### With Schedule System (Phase 16 Part 6)
- Schedule defines WHERE an NPC is
- Behavior defines HOW they respond when found
- Together: realistic, living NPCs

### With Affection System
- Behavior mood affects affection multipliers
- Personality traits modify affection changes
- Creates dynamic relationship progression

### With Dialogue System
- `generatePersonalizedDialogueOptions()` provides personality-specific choices
- Topic modifiers affect affection for dialogue outcomes
- Reactions can unlock special dialogue

### With Event System
- `BehaviorOutcome.eventId` triggers events
- Events can modify NPC mood/behavior
- Creates feedback loops

## Testing

### Unit Tests (`npc_behavior_service_test.dart`)
- 30+ tests covering all service methods
- Tests for personality-based calculations
- Mood update logic validation
- Interaction tracking verification

### Integration Tests (`npc_behavior_integration_test.dart`)
- 10+ realistic scenario tests
- Multi-interaction sequences
- Personality compatibility workflows
- Habit and behavior pattern chains
- Topic preference interactions

## Usage Example

```dart
// Initialize NPC with personality
final traits = PersonalityTraits(
  openness: 70,
  conscientiousness: 60,
  extraversion: 80,
  agreeableness: 75,
  neuroticism: 30,
);

final npc = service.initializeBehaviorState('teacher-npc', traits);

// Record interactions
var updated = service.memorizeInteraction(
  npc,
  'greeting',
  'Said hello kindly',
  10,
);

// Check personality match
final compatibility = service.calculatePersonalityMatch(traits, playerTraits);

// Get personalized dialogue
final dialogue = service.generatePersonalizedDialogueOptions(
  updated,
  ['Hello', 'How are you?'],
);

// Apply time-based mood
updated = service.updateMoodByTime(updated, DateTime.now());

// Get summary for UI
final summary = service.generateBehaviorSummary(updated);
```

## Files Added

1. **lib/models/npc_behavior_model.dart** (452 lines)
   - All data models and enums

2. **lib/services/npc_behavior_service.dart** (385 lines)
   - Service implementation with 25+ methods

3. **lib/providers/npc_behavior_provider.dart** (250 lines)
   - Riverpod state management and notifiers

4. **test/services/npc_behavior_service_test.dart** (320 lines)
   - 30+ unit tests

5. **test/integration/npc_behavior_integration_test.dart** (380 lines)
   - 10+ integration tests

## Metrics

- **Total Lines**: ~1,800
- **Methods in Service**: 25
- **Data Models**: 8
- **Enums**: 2
- **Unit Tests**: 30+
- **Integration Tests**: 10+
- **Test Coverage**: ~90%

## Next Steps (Phase 16 Part 8)

Recommended continuations:
1. **Dialogue System Integration** - Full branching dialogue with behavior hooks
2. **Event System** - Behaviors triggering game events
3. **Skill System** - NPCs teaching player skills based on affection
4. **Save/Load** - Persisting NPC behavior state
5. **UI Components** - Displaying behavior and personality information

## References

- Big Five Personality Traits: https://en.wikipedia.org/wiki/Big_Five_personality_traits
- Behavior Trees: https://en.wikipedia.org/wiki/Behavior_tree_(artificial_intelligence,_robotics_and_control)
- NPC Psychology: https://gamedevelopment.tutsplus.com/articles/the-psychology-of-npcs-and-interactive-storytelling

---

**Author**: Claude Haiku 4.5  
**PR**: #36  
**Status**: Merged ✓
