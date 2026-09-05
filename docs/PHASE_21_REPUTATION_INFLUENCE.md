# Phase 21: Reputation & Influence System
## 評判・影響力システム

## System Overview

Phase 21 implements faction reputation, influence gates, and political relationships:

- **Player Reputation**: Track standing with 3 major factions (0-100 scale)
- **Access Levels**: 5 levels (Neutral, Acquaintance, Trusted, Honored, Legend)
- **Reputation Shops**: Exclusive items locked behind reputation thresholds
- **NPC Opinions**: Individual NPC attitudes toward factions
- **Political Alliances**: Factions with allied/rival relationships
- **Consequence System**: Reputation changes propagate to allies

## Core Classes

### ReputationInfluenceSystem (Singleton)

Main manager for reputation and influence operations.

**Key Data Structures:**
```
_playerReputation      Map<String, int>  // Faction → reputation (0-100)
_npcOpinions          Map<String, Map>   // NPC → faction opinions
_alliances            Map<String, List>  // Faction → allied factions
_rivalries            Map<String, List>  // Faction → rival factions
_shops                Map<String, ReputationShop> // Faction shops
_eventHistory         Map<String, List>  // Reputation change logs
_playerAccess         Map<String, List>  // Available access levels
```

### Reputation Ranks

```dart
reputation < 0:      敵対 (Enemy)
0 - 24:             中立 (Neutral)
25 - 49:            知人 (Acquaintance)
50 - 74:            信頼 (Trusted)
75 - 89:            尊敬 (Honored)
90 - 100:           伝説 (Legend)
```

### Access Levels

Each rank unlocks access level:
- **Neutral (0 rep)**: Basic access
- **Acquaintance (25 rep)**: Merchant discounts
- **Trusted (50 rep)**: Quest access
- **Honored (75 rep)**: Area access
- **Legend (90 rep)**: Exclusive items/quests

### Reputation Shops

3 faction shops with exclusive items:

**Mage Tower - Arcane Circle**
- Advanced Spell Tome: 30 rep, 1000G
- Mana Ring: 50 rep, 2000G
- Master Spell Tome: 80 rep, 5000G

**Adventurers Guild - Guild Armory**
- Advanced Bow: 30 rep, 1200G
- Legendary Blade: 60 rep, 3000G
- God Armor: 90 rep, 8000G

**Merchant Cartel - Merchant Exchange**
- Trade License: 25 rep, 800G
- VIP Discount Card: 50 rep, 2000G
- Noble Merchant Status: 85 rep, 6000G

### Political Relationships

**Alliances:**
- Mage Tower ↔ Merchant Cartel
- Reputation gains: 50% propagated to allies

**Rivalries:**
- None defined (extensible)

**Effects:**
- Gaining reputation with faction automatically gives 50% to allies
- Losing reputation with faction gives -50% to allies
- Rival factions remain independent

## Core Methods

### Reputation Management

**changeReputation()**
```dart
bool changeReputation(String factionId, int amount, String reason)
```
- Modify player reputation (-100 to +100 per change)
- Records event with timestamp and reason
- Updates access levels
- Applies alliance effects
- Returns success status

**getPlayerReputation()**
```dart
int getPlayerReputation(String factionId)
```
- Returns current reputation (0-100)

**getReputationRank()**
```dart
String getReputationRank(String factionId)
```
- Returns human-readable rank name

### Access Control

**getPlayerAccessLevels()**
```dart
List<AccessLevel> getPlayerAccessLevels(String factionId)
```
- Returns all unlocked access levels

**canAccessQuest()**
```dart
bool canAccessQuest(String factionId, int requiredReputation)
```
- Check quest availability

**canAccessArea()**
```dart
bool canAccessArea(String factionId, int requiredReputation)
```
- Check area access

### NPC System Integration

**getNPCOpinion()**
```dart
int getNPCOpinion(String npcId, String factionId)
```
- Get NPC's opinion of faction (0-100)

**setNPCOpinion()**
```dart
void setNPCOpinion(String npcId, String factionId, int opinion)
```
- Set NPC opinion (affects quest outcomes)

### Shops

**getShop()**
```dart
ReputationShop? getShop(String factionId)
```
- Returns shop with all items and requirements

**purchaseFromShop()**
```dart
bool purchaseFromShop(String factionId, String itemId, int playerGold)
```
- Purchase restricted item
- Validates reputation and gold
- Deducts 5 reputation as usage cost

### Queries

**getAllReputation()**
- Returns all faction reputations as map

**getAlliedFactions()**
- Returns list of allied factions

**getRivalFactions()**
- Returns list of rival factions

**getReputationHistory()**
- Returns recent reputation events

**getFactionReport()**
- Returns formatted faction status

## Integration Patterns

### With Quest System
- Quests require reputation thresholds
- Quest rewards modify reputation
- Failed quests may decrease reputation

### With Combat System
- Faction enemies appear as combat encounters
- Faction allies provide assistance bonuses

### With Economy
- Reputation affects merchant prices
- Higher reputation = better prices
- Shops sell exclusive items

### With NPC System
- NPC dialogue changes by reputation
- NPC opinions independently track per faction
- NPC quests available at reputation thresholds

## Performance Characteristics

- **changeReputation()**: O(1) lookup + O(1) alliance updates
- **getPlayerReputation()**: O(1)
- **getAccessLevels()**: O(1) with caching
- **getShop()**: O(1) map lookup
- **Reputation Propagation**: O(a) where a = allies (typically 1-2)

## Quality Metrics

- ✅ 3 faction reputation tracking
- ✅ 5 access level system
- ✅ 3 reputation shops
- ✅ Political alliance system with effects
- ✅ NPC opinion tracking
- ✅ Complete event history
- ✅ Purchase restrictions

## Example Usage

```dart
final system = ReputationInfluenceSystem.getInstance();
system.initialize();

// Gain reputation
system.changeReputation('mage_tower', 30, 'Completed Arcane Quest');

// Check rank
final rank = system.getReputationRank('mage_tower'); // "Trusted"

// Check quest access
bool canAccess = system.canAccessQuest('mage_tower', 50); // true

// Get shop items
final shop = system.getShop('mage_tower');
for (final item in shop!.items) {
  final buyable = item.isPurchasable(30, 1000); // rep, gold
}

// Check alliances
final allies = system.getAlliedFactions('mage_tower');
// Reputation with merchant_cartel also increased by 15
```

## Expansion Patterns

### Adding Rivalries
- Define in _initializeAlliances()
- Create opposing effects
- Reputation loss multiplied for rivals

### Quest Tier Gates
- Easy (25 rep), Medium (50 rep), Hard (75 rep), Legend (90 rep)
- Quest rewards scale with reputation investment

### Faction Wars
- Low reputation triggers hostile encounters
- High reputation unlocks faction support
- Allies assist in marked conflicts

### Merchant Pricing
- Base price × (1 - reputation/200)
- Higher reputation = up to 50% discount

## Testing Examples

See `lib/examples/reputation_influence_example.dart` for:
- 5-tab Flutter UI
- Reputation overview with progress bars
- Faction management and testing
- Shop system demonstration
- History tracking
- Access level visualization
