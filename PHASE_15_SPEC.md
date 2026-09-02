# Phase 15: 🕹️ English-Only Town (英語だけの街)
## 2D Exploration Mini-Game with AI NPC Interactions

**Status**: 🟡 Specification & Design  
**Target Completion**: 4-6 weeks  
**Priority**: High (Final roadmap feature)  
**Effort**: High (new 2D game mechanics)

---

## 📋 Feature Overview

### Concept
A 2D exploration game where the player explores an English-themed town and interacts with NPCs. All NPCs communicate **only in English**, providing immersive conversation practice without translations.

### Core Gameplay Loop
1. Player navigates a 2D town map (top-down view)
2. Encounters NPCs (café staff, shopkeeper, tourist, student, teacher, etc.)
3. Initiates conversation → AI generates dynamic English dialogue
4. Player responds using speech-to-text
5. Earn XP and coins based on response quality
6. Discover hidden dialogue variations by exploring different times/conditions

### Learning Impact
- **Natural conversation context**: Not isolated phrases, but location-specific dialogues
- **Immersion**: 100% English environment removes translation dependency
- **Replayability**: Dialogue varies based on player choices, NPC moods, time of day

---

## 🎮 Game Design Specifications

### Map Layout
```
┌─────────────────────────────┐
│    ENGLISH-ONLY TOWN        │
│                             │
│  [🏫] School              │
│     │                      │
│  [📚]─[☕]─[🛍️]─[🏠]    │
│  Library│Café│Shop│House   │
│     │  │     │   │         │
│  [🏞️]─[⚽]─[🍽️]─[🏨]    │
│  Park  │Field│Restaurant   │
│        │     │   │         │
│     [🌳]─[🚏]─[🎪]       │
│        │  Bus   │Fairground│
│     [🏛️]Station          │
│     Museum                  │
└─────────────────────────────┘
```

### 8 Key Locations (Leverage existing 59 conversation scenes)
1. **School** (🏫) - Teacher, Students talking about lessons
2. **Café** (☕) - Barista, Customers ordering, small talk
3. **Library** (📚) - Librarian, Readers studying, book recommendations
4. **Shop** (🛍️) - Shopkeeper, Customers buying items
5. **Restaurant** (🍽️) - Waiter, Diners ordering, food talk
6. **Park** (🏞️) - Jogger, Kids playing, nature observations
7. **Bus Station** (🚏) - Ticket agent, Travelers, directions
8. **Museum** (🏛️) - Guide, Visitors, history questions

### NPC Cast (8 main characters)
| NPC | Location | Role | Personality |
|-----|----------|------|-------------|
| Miss Sarah | School | English Teacher | Encouraging, educational |
| Tom | Café | Barista | Friendly, chatty |
| Emily | Library | Librarian | Knowledgeable, helpful |
| Mr. Chen | Shop | Store Owner | Business-like, polite |
| Marco | Restaurant | Chef/Waiter | Passionate, talkative |
| Lisa | Park | Jogger | Athletic, energetic |
| David | Bus Station | Ticket Agent | Professional, quick |
| Dr. Wilson | Museum | Curator | Intellectual, detailed |

---

## 🛠️ Technical Architecture

### Data Structure

#### Town Map Model
```dart
class TownMap {
  final String id;
  final List<Location> locations;
  final List<NPC> npcs;
  final Player playerState;
  final DateTime timeOfDay;
  final WeatherType weather;
}

class Location {
  final String id;
  final String name;
  final String emoji;
  final Offset position; // x, y coordinates
  final List<NPC> npcsPresent;
  final String description;
  final List<InteractionScene> scenes;
}

class NPC {
  final String id;
  final String name;
  final String emoji;
  final Location primaryLocation;
  final List<Location> visitableLocations;
  final Mood currentMood;
  final ConversationHistory conversationHistory;
  final String personality;
}

class InteractionScene {
  final String id;
  final String npcId;
  final String locationId;
  final String initialGreeting;
  final List<ConversationTurn> conversationFlow;
  final int xpReward;
  final int coinReward;
  final DifficultyLevel difficulty;
}
```

### AI Dialogue Generation (Claude API)

**Prompt Template**:
```
Context:
- Location: {location.name} ({location.description})
- NPC: {npc.name} ({npc.personality})
- Time: {timeOfDay}
- Player's last message: "{playerInput}"
- Conversation history: {conversationHistory}

Generate a NATURAL English response as {npc.name}:
1. Stay in character and location context
2. Respond to what the player said
3. Keep to 1-2 sentences for natural flow
4. Use vocabulary appropriate to {difficultyLevel}
5. Suggest a next topic or question naturally

Response:
```

---

## 📱 UI/UX Design

### Screens

#### 1. Town Hub Screen
```
┌─────────────────────────────┐
│  🕹️ English-Only Town       │
├─────────────────────────────┤
│                             │
│  [2D Map Display]           │
│  - Tap location → enter     │
│  - Show distance to NPCs    │
│  - Weather effects          │
│                             │
├─────────────────────────────┤
│ [⌚ Time] [📊 Progress]      │
│ [🎯 Quests] [👥 NPCs]       │
└─────────────────────────────┘
```

#### 2. Conversation Screen
```
┌─────────────────────────────┐
│ ☕ Café - Talking to Tom    │
├─────────────────────────────┤
│ Tom: "Hi! What can I get    │
│       for you today?"       │
│                             │
│ [🔊 Listen] [📝 Read]      │
│                             │
├─────────────────────────────┤
│ Your response:              │
│ [🎤 Speak] [⌨️ Type]       │
│                             │
│ Processing: ⏳             │
│ Tom: "Great choice! ..."   │
│                             │
├─────────────────────────────┤
│ ✅ Correct (+100 XP, +50C)  │
│ [Next] [Back to Map]        │
└─────────────────────────────┘
```

#### 3. NPC Directory/Progress
```
┌─────────────────────────────┐
│ 👥 NPCs Met                 │
├─────────────────────────────┤
│ ✅ Sarah (School)   7/10    │
│ ✅ Tom (Café)       5/8     │
│ ✅ Emily (Library)  3/6     │
│ ⭕ Mr. Chen (Shop)  0/5     │
│ ...                         │
├─────────────────────────────┤
│ Total Conversations: 42/59  │
│ Next milestone: 50 (50C)    │
└─────────────────────────────┘
```

---

## 🎯 Implementation Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Create TownMap model and NPC data structure
- [ ] Build basic 2D map visualization (CustomPaint)
- [ ] Implement navigation between locations
- [ ] Create Location list provider
- [ ] Set up location transition animations

### Phase 2: NPC System (Week 2-3)
- [ ] Design 8 NPC characters with personalities
- [ ] Create NPC model and provider
- [ ] Implement NPC appearance in locations
- [ ] Add NPC tap interactions
- [ ] Build NPC directory screen

### Phase 3: Conversation Engine (Week 3-4)
- [ ] Integrate Claude API for dialogue generation
- [ ] Implement conversation state management
- [ ] Add speech-to-text input handling
- [ ] Create response evaluation logic (correctness scoring)
- [ ] Add conversation history tracking

### Phase 4: Rewards & Progression (Week 4-5)
- [ ] Implement XP/coin reward system
- [ ] Add location unlock progression
- [ ] Create milestone badges
- [ ] Build stats and achievement tracking
- [ ] Integrate with existing progression systems

### Phase 5: Polish & Optimization (Week 5-6)
- [ ] Add animations and visual polish
- [ ] Weather/time-of-day system
- [ ] NPC mood variations
- [ ] Performance optimization
- [ ] Edge case handling and testing

---

## 🎨 Design System Integration

### Colors
- Primary (Exploration): `AppColors.readingColor`
- NPCs: Different accent colors per personality
- Buttons: `AppColors.accentGreen` (actions)
- Danger/Error: `AppColors.error`

### Typography
- Location names: `AppTypography.headlineSmall`
- NPC dialogue: `AppTypography.bodyMedium`
- System messages: `AppTypography.labelSmall`

### Spacing
- Map padding: `AppSpacing.allPaddingLg`
- NPC icons: 48x48 px
- Dialogue boxes: Full width with `AppSpacing.allPaddingMd`

---

## 📊 Data Integration

### Reusing Existing Scenes
Map the 59 conversation scenes to 8 locations:
```
School (10 scenes):
  - Greeting teacher
  - Asking about homework
  - Reporting grades
  - School activities
  - etc.

Café (8 scenes):
  - Ordering drinks
  - Small talk with strangers
  - Asking for directions
  - etc.

[Distribute remaining 41 scenes across other 6 locations]
```

### Firebase Integration
```dart
users/{userId}/town-progress/
  - visitedLocations: [list]
  - npcConversations: {npcId: conversationCount}
  - totalXP: int
  - unlockedAchievements: [list]
  - lastPlayedTime: timestamp
```

---

## 🎮 Engagement Mechanics

### Daily Challenges
- "Talk to 3 new NPCs today" → +100 XP
- "Visit all 8 locations" → +250 XP
- "Have 5 conversations" → +150 XP

### Achievements
- 🏅 "Town Explorer" - Visit all 8 locations
- 🏆 "Conversationalist" - 50+ conversations
- ⭐ "Perfect Scores" - Get 10 perfect responses
- 🎯 "NPC Master" - Complete all dialogues with one NPC

### Progression
- Unlock new NPC dialogue variations at conversation milestones
- Unlock hidden locations after 30+ conversations
- Unlock time-of-day variations (morning/afternoon/night dialogues)

---

## 🚀 Success Metrics

### Engagement
- Average session duration: 15+ minutes
- Daily active conversations: 5+
- Weekly return rate: 60%+

### Learning
- Conversation quality improvement over 30 days
- Vocabulary retention from NPC interactions
- Correlation with speaking score improvements

### Monetization
- "Unlimited conversations" premium feature
- "Skip cooldown" power-up
- NPC cosmetics (clothing, accessories)

---

## 📝 Development Checklist

### Models & Data
- [ ] TownMap model
- [ ] Location model
- [ ] NPC model
- [ ] Conversation model
- [ ] InteractionScene model
- [ ] Write 59 scene variations mapped to locations

### Providers (Riverpod)
- [ ] townMapProvider
- [ ] playerLocationProvider
- [ ] activeNPCProvider
- [ ] conversationHistoryProvider
- [ ] townProgressProvider
- [ ] aiDialogueProvider (Claude API)

### Screens & Widgets
- [ ] TownHubScreen
- [ ] ConversationScreen
- [ ] NPCDirectoryScreen
- [ ] TownMapWidget (CustomPaint)
- [ ] NPCCardWidget
- [ ] DialogueBoxWidget
- [ ] LocationEntryTransition

### Services
- [ ] Enhance ClaudeAPIService for contextual dialogue
- [ ] SpeechToText integration for town context
- [ ] TownProgressService

### Testing
- [ ] Unit tests for dialogue generation
- [ ] Widget tests for map interaction
- [ ] Integration tests for conversation flow
- [ ] Performance tests for map rendering

---

## 🔗 Related Files to Reference
- `lib/models/conversation_model.dart` (for scene structure)
- `lib/services/claude_api_service.dart` (for dialogue API)
- `lib/providers/speech_provider.dart` (for speech input)
- `lib/design_system/design_system.dart` (for styling)

---

**Next Step**: Begin Phase 1 implementation with TownMap model and data structure design.
