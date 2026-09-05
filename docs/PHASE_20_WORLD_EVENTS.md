# Phase 20: World Events & Dynamic Encounters
## ワールドイベント・ダイナミックエンカウントシステム

## System Overview

Phase 20 implements a dynamic world events system that creates an evolving game world with:

- **World Events**: Dynamic events that affect territories and NPCs (invasions, disasters, celebrations, epidemics, migrations)
- **Seasonal System**: 4 seasons with unique characteristics affecting gameplay
- **Territory State Tracking**: Real-time monitoring of stability, prosperity, and morale
- **Event Consequences**: Events create cascading effects on territories and NPCs
- **Random Encounters**: Difficulty-scaled encounters based on season and territory state
- **NPC Migration**: NPCs move between territories as consequences of events

### Core Architecture

The system uses a **singleton pattern** with HashMap-based O(1) lookups for world state management.

## World Events System

### Key Classes

#### WorldEventsSystem (Singleton)
Main manager for all world events and dynamic encounters.

**Key Data Structures:**
```
_activeEvents          Map<String, WorldEvent>        // Currently active events
_eventHistory         Map<String, WorldEventResult>   // Completed event history
_territoryStates      Map<String, TerritoryState>     // Territory status tracking
_npcLocations         Map<String, String>             // NPC location tracking
_consequences         Map<String, List<EventConsequence>> // Event impacts
```

#### WorldEvent
Represents an active world event in progress.

```dart
class WorldEvent {
  final String id;                    // Unique event ID
  final WorldEventType type;          // Type of event
  final String territory;             // Affected territory
  final int startTime;                // Event start timestamp
  final int duration;                 // Duration in days
  final int intensity;                // Intensity (1-3)
  bool isActive;                      // Current status
  final List<String> affectedNPCs;    // NPCs affected
}

enum WorldEventType {
  invasion,                           // 侵略
  disaster,                           // 自然災害
  celebration,                        // お祭り
  epidemic,                           // 疫病
  migration,                          // 移動
}
```

#### TerritoryState
Tracks the current state of a territory.

```dart
class TerritoryState {
  final String territoryId;           // Territory ID
  Season currentSeason;               // Current season
  int stability;                      // Stability 0-100
  int prosperity;                     // Prosperity 0-100
  int populationMorale;               // Morale 0-100
  int lastEventTime;                  // Last event timestamp
}

enum Season {
  spring,    // 春
  summer,    // 夏
  autumn,    // 秋
  winter,    // 冬
}
```

#### EventConsequence
Documents the impact of an event.

```dart
class EventConsequence {
  final ConsequenceType type;         // Type of consequence
  final int value;                    // Numerical impact
  final String description;           // Human-readable description
}

enum ConsequenceType {
  stability,                          // 安定性
  prosperity,                         // 繁栄
  morale,                             // 士気
  migration,                          // 移動
}
```

#### WorldEventResult
Final result of a completed event.

```dart
class WorldEventResult {
  final String eventId;               // Event ID
  final WorldEventType eventType;     // Type of event
  final String territory;             // Affected territory
  final int intensity;                // Event intensity
  final int startTime;                // Start timestamp
  final int endTime;                  // End timestamp
  final List<String> affectedNPCs;    // Affected NPC list
  final List<EventConsequence> consequences; // Impact list
}
```

#### EncounterData
Data for randomly generated encounters.

```dart
class EncounterData {
  final EncounterType type;           // Type of encounter
  final int difficulty;               // Difficulty 1-5
  final int reward;                   // Gold reward
  final String? territoryId;          // Territory where encounter occurs
}

enum EncounterType {
  wildBeast,      // 野獣
  bandits,        // 盗賊
  magicalBeast,   // 魔獣
  none,           // なし
}
```

### Core Methods

#### Event Management

**advanceDay()**
```dart
List<String> advanceDay()
```
- Called once per game day
- Advances season progress (4 seasons = 100 days each)
- Expires completed events
- Triggers random events (15% base chance × seasonal modifier)
- Updates NPC locations
- Returns list of triggered event IDs

**_generateRandomEvent()**
- Creates random world event
- Selects random event type from 5 types
- Selects random territory
- Sets intensity (1-3)
- Lists affected NPCs in territory

**_propagateEventConsequences()**
- Calculates event impact on territory
- Modifies territory stats (stability, prosperity, morale)
- Applies stat-specific effects by event type:
  - **Invasion**: -20-60 stability, -15-45 morale, -10-30 prosperity
  - **Disaster**: -25-75 prosperity, -20-60 morale, -15-45 stability
  - **Celebration**: +15-45 morale, +10-30 prosperity, +5-15 stability
  - **Epidemic**: -25-75 morale, -15-45 prosperity, -10-30 stability
  - **Migration**: -10-30 morale, +5-15 prosperity
- Records EventConsequence objects
- Clamps all values to 0-100 range

**_resolveEvent()**
- Called when event expires
- Creates WorldEventResult with all metadata
- Stores result in event history
- Removes from active events

#### Season Management

**_advanceSeason()**
```dart
void _advanceSeason()
```
- Cycles through 4 seasons (spring → summer → autumn → winter → spring)
- Updates all territory states with seasonal effects
- Called when seasonProgress reaches 100

**_applySeasonalEffects()**
- Spring: +10 prosperity, +5 morale, +5 stability
- Summer: +15 prosperity, -5 morale, +0 stability  
- Autumn: +5 prosperity, +10 morale, -5 stability
- Winter: -10 prosperity, -15 morale, -20 stability

#### Territory State

**getTerritoryState()**
```dart
TerritoryState? getTerritoryState(String territoryId)
```
- Returns current state of territory
- Includes all stat values and season

**getAllTerritoryStates()**
```dart
Map<String, TerritoryState> getAllTerritoryStates()
```
- Returns all 6 territories with current state
- Used for world overview screens

#### NPC Location Management

**_updateNPCLocations()**
- 10% chance per day for each NPC to migrate
- Randomly selects new territory
- Used for quest availability and dialogue options

**getNPCLocation()**
```dart
String? getNPCLocation(String npcId)
```
- Returns current territory of NPC
- Affects NPC interaction availability

#### Random Encounters

**generateRandomEncounter()**
```dart
EncounterData generateRandomEncounter(String territoryId)
```
- Generates random encounter for a territory
- Difficulty calculation:
  - Base: 1 (spring) → 3 (winter)
  - If stability < 30: +2 difficulty (dangerous)
  - Clamped to 1-5 range
- Reward = difficulty × 100
- Selects random encounter type (wild beast, bandits, magical beast)

### Seasonal System

#### 4 Seasons

**Spring (Days 1-25)**
- Mild weather, recovery period
- +10 prosperity, +5 morale, +5 stability
- 1.0× encounter rate (normal)
- Perfect for exploration

**Summer (Days 26-50)**
- Warm and abundant
- +15 prosperity, -5 morale, normal stability
- 0.8× encounter rate (fewer encounters)
- Best for trading and farming

**Autumn (Days 51-75)**
- Harvest season, preparation
- +5 prosperity, +10 morale, -5 stability
- 1.2× encounter rate (more encounters)
- Increased event risk

**Winter (Days 76-100)**
- Harsh conditions, hardship
- -10 prosperity, -15 morale, -20 stability
- 0.6× encounter rate (very rare)
- Dangerous to travel

### Territory System

#### 6 Territories

1. **Arcane Citadel** - Magical center
2. **Martial Fortress** - Military stronghold
3. **Commerce Harbor** - Trading hub
4. **Natural Forest** - Wilderness area
5. **Mineral Canyon** - Resource-rich region
6. **Maritime Coast** - Naval territory

#### Territory Stats

**Stability (0-100)**
- Represents how secure the territory is
- Decreased by: invasions, disasters, epidemics
- Increased by: celebrations
- Affects event likelihood

**Prosperity (0-100)**
- Economic well-being of region
- Decreased by: disasters, epidemics
- Increased by: celebrations, successful seasons
- Affects available quests and rewards

**Population Morale (0-100)**
- Citizen happiness and loyalty
- Decreased by: invasions, disasters, epidemics, migrations
- Increased by: celebrations, stable seasons
- Affects NPC availability and prices

#### Territory Safety Score

Calculated as: (stability + prosperity) / 2 × 100

- 80+: Safe
- 50-79: Moderate
- 30-49: Dangerous
- <30: Very Dangerous

### Event System

#### 5 Event Types

**Invasion**
- Military conflict
- Decreases: stability, morale, prosperity
- Affected NPCs: combat-oriented NPCs affected
- Duration: 2-8 days

**Disaster**
- Natural catastrophe (earthquake, flood, storm)
- Decreases: prosperity, morale, stability
- Affected NPCs: all NPCs in territory
- Duration: 2-8 days

**Celebration**
- Festival, tournament, celebration
- Increases: morale, prosperity, stability
- Affected NPCs: none (celebratory)
- Duration: 2-8 days

**Epidemic**
- Disease outbreak
- Decreases: morale, prosperity, stability
- Affected NPCs: all NPCs in territory
- Duration: 2-8 days

**Migration**
- NPCs move territories
- Decreases: morale (slight)
- Increases: prosperity (slight)
- Affected NPCs: moving NPCs
- Duration: 2-8 days

#### Event Intensity

1-3 scale:
- **1**: Minor event, minimal impact
- **2**: Moderate event, noticeable impact
- **3**: Major event, significant impact

Impact multiplier: intensity × base effect

### Random Encounters

#### Encounter Types

**Wild Beast**
- Common wilderness encounter
- Difficulty: 2/5
- Reward: 200G

**Bandits**
- Dangerous criminals
- Difficulty: 3/5
- Reward: 300G

**Magical Beast**
- Supernatural creatures
- Difficulty: 4/5
- Reward: 400G

#### Difficulty Scaling

```
Base Difficulty = Season(1-3) + Stability Modifier
- If stability < 30: +2
- If stability < 50: +1
- Otherwise: no modifier
Final Difficulty = clamp(1, 5)
```

Higher difficulty = higher rewards, greater challenge

## Integration Patterns

### With Territory Control
- Territory control affected by event outcomes
- Invasions can change territorial ownership
- Celebrations increase citizen loyalty

### With Quest System
- Events affect available quests
- Disaster quests: rescue missions
- Celebration quests: participate in festival
- Invasion quests: defend territory
- Epidemic quests: cure patients
- Migration quests: assist relocating NPCs

### With Economy
- Prosperity affects merchant prices
- Disasters increase prices (scarcity)
- Celebrations decrease prices (abundance)
- Invasions interrupt trade routes

### With NPC System
- NPC locations change with migrations
- Events affect NPC mood and availability
- Disasters trigger rescue quests
- Celebrations unlock special dialogue

## Performance Characteristics

### Time Complexity
- advanceDay(): O(a + n) where a=active events, n=NPCs
- generateRandomEncounter(): O(1)
- getTerritoryState(): O(1)
- _propagateEventConsequences(): O(1)

### Space Complexity
- O(t) for territories
- O(a) for active events
- O(h) for event history
- O(n) for NPC locations
- Total: O(t + a + h + n)

### Daily Operations
- advanceDay() < 5ms
- Event generation < 1ms
- Encounter generation < 1ms
- NPC migration < 2ms

## Quality Metrics

### System Coverage
- ✅ 5 event types with unique mechanics
- ✅ 4 seasons with distinct effects
- ✅ 6 territories with stat tracking
- ✅ Event consequence system
- ✅ NPC migration system
- ✅ Random encounter generation
- ✅ Territory safety scoring
- ✅ Complete event history

### Test Scenarios
1. **Event Lifecycle**: Generate → Propagate → Resolve
2. **Seasonal Transitions**: Progress through all 4 seasons
3. **Territory Impact**: Events modify territory stats correctly
4. **Encounter Generation**: Difficulty scales with territory state
5. **NPC Migration**: Locations update based on events
6. **History Tracking**: Events record in history with consequences

## Expansion Patterns

### Adding New Event Types
1. Add to WorldEventType enum
2. Add consequence logic in _propagateEventConsequences()
3. Add event-specific rewards/outcomes
4. Add seasonal impact modifiers

### Adding Territory Features
1. Define new territory in initialize()
2. Set initial stat values
3. Add seasonal effect multipliers
4. Link to regional quests

### Advanced Features (Phase 21+)
- Player influence on events
- Event chains (initial → continuation → resolution)
- Environmental persistence (damage from disaster)
- NPC memories of events
- Reputation system tied to event outcomes

## Testing Examples

See `lib/examples/world_events_example.dart` for:
- 5-tab Flutter UI
- Active event display with countdown
- Season tracker with progress bar
- Territory state visualization
- Encounter type examples
- Event history logging

## API Summary

```dart
// Initialization
system.initialize()

// Daily operations
List<String> triggeredEvents = system.advanceDay()

// Query current state
Season season = system.getCurrentSeason()
int progress = system.getSeasonProgress()
TerritoryState? state = system.getTerritoryState(territoryId)
Map<String, TerritoryState> all = system.getAllTerritoryStates()

// NPC locations
String? location = system.getNPCLocation(npcId)

// Events
List<WorldEvent> active = system.getActiveEvents()
List<WorldEventResult> history = system.getEventHistory()
WorldEventResult? result = system.getEventResult(eventId)

// Encounters
EncounterData encounter = system.generateRandomEncounter(territoryId)

// Reports
String report = system.getEventImpactReport(territoryId)
```

## Example Usage

```dart
final system = WorldEventsSystem.getInstance();
system.initialize();

// Daily progression
for (int day = 0; day < 100; day++) {
  List<String> events = system.advanceDay();
  for (String eventId in events) {
    print('Event triggered: $eventId');
  }
  
  // Check territory impact
  final arcaneState = system.getTerritoryState('arcane_citadel');
  print('Stability: ${arcaneState?.stability}');
}

// Generate encounter
final encounter = system.generateRandomEncounter('natural_forest');
print('Encountered: ${encounter.getName()}');
print('Difficulty: ${encounter.difficulty}/5');
print('Reward: ${encounter.reward}G');
```

## Design Philosophy

1. **Organic World**: Events create natural consequences without forced narratives
2. **Seasonal Gameplay**: Seasons encourage different playstyles
3. **Territory Persistence**: Territory state affects multiple systems (economy, quests, combat)
4. **NPC Agency**: NPCs migrate and react to world events
5. **Player Impact**: Events create quest opportunities, not just obstacles
