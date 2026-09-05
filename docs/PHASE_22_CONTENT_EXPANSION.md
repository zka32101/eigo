# Phase 22: Content Expansion System
## コンテンツ拡張システム

## System Overview

Phase 22 provides extensible systems for:

- **3 New Areas**: Sky Temple, Abyss Depths, Light Domain (Difficulty 3-5)
- **3 New NPCs**: Celestine, Vorthos, Aurora (2 marriageable)
- **3 New Skills**: Celestial Strike, Void Burst, Radiant Heal
- **3 New Equipment**: Celestial Sword, Void Cloak, Radiant Ring
- **3 New Items**: Ancient Scroll, Celestial Stone, Supreme Potion

## Core Classes

### ContentExpansionSystem (Singleton)

Manages all expandable game content.

**Features:**
- Area management with difficulty and level requirements
- NPC management with specialties and locations
- Skill system with type and stat tracking
- Equipment with rarity and special properties
- Item catalog with type and value

### Key Data Structures

```dart
_areas              Map<String, Area>       // New exploration areas
_npcs               Map<String, ExpandedNPC> // New NPCs
_skills             Map<String, Skill>      // New combat skills
_equipment          Map<String, Equipment>  // New gear
_items              Map<String, Item>       // New items
```

## Content Details

### Areas

1. **Sky Temple** (Difficulty 4, Level 25+)
   - Features: Boss Arena, Treasure Vault, Meditation Hall
   - Rewards: 500G, 1000 XP

2. **Abyss Depths** (Difficulty 5, Level 35+)
   - Features: Dark Cavern, Cursed Chamber, Void Rift
   - Rewards: 800G, 1500 XP

3. **Light Domain** (Difficulty 3, Level 20+)
   - Features: Sacred Grounds, Blessing Altar, Sanctuary
   - Rewards: 400G, 800 XP

### NPCs

1. **Celestine** (Level 18, Marriageable)
   - Specialty: Light Magic
   - Location: Sky Temple

2. **Vorthos** (Level 22, Not Marriageable)
   - Specialty: Dark Magic
   - Location: Abyss Depths

3. **Aurora** (Level 20, Marriageable)
   - Specialty: Healing Magic
   - Location: Light Domain

### Skills

1. **Celestial Strike** (Level 25, Physical)
   - Damage: 120, Mana: 30, Cooldown: 2s

2. **Void Burst** (Level 30, Magical)
   - Damage: 150, Mana: 50, Cooldown: 3s

3. **Radiant Heal** (Level 20, Healing)
   - Healing: 100, Mana: 40, Cooldown: 1s

### Equipment

1. **Celestial Sword** (Legendary, Level 25)
   - Attack: 85, Special: Light Damage Bonus

2. **Void Cloak** (Legendary, Level 30)
   - Defense: 70, Special: Dark Resistance

3. **Radiant Ring** (Epic, Level 20)
   - Defense: 20, Special: Healing Boost +10%

### Items

1. **Ancient Scroll** (Rare, 500G)
   - Type: Quest item

2. **Celestial Stone** (Legendary, 1000G)
   - Type: Material

3. **Supreme Potion** (Epic, 300G)
   - Type: Consumable

## API Methods

```dart
// Area queries
Area? getArea(String areaId)
Map<String, Area> getAllAreas()
List<Area> getAvailableAreas(int playerLevel)

// NPC queries
ExpandedNPC? getNPC(String npcId)
List<ExpandedNPC> getMarriageableNPCs()

// Skill queries
Skill? getSkill(String skillId)
List<Skill> getAvailableSkills(int playerLevel)

// Equipment/Item queries
Equipment? getEquipment(String equipmentId)
Item? getItem(String itemId)

// Reports
String getAreaReport(String areaId)
String getSkillReport(String skillId)
```

## Integration Patterns

### With Level System
- Areas gated by level requirements
- Skills require level thresholds
- Equipment has level minimums

### With Combat System
- New skills integrate into combat
- Equipment bonuses add to stats
- Area bosses use new difficulty scaling

### With Marriage System
- Celestine and Aurora are marriageable
- Located in new areas
- Unique marriage bonuses

### With Quest System
- Areas have reward gold/XP
- Items used in quests
- NPCs offer new quest chains

## Expansion Patterns

### Adding New Areas
```dart
_areas['new_area'] = Area(
  id: 'new_area',
  name: 'New Area Name',
  difficulty: 4,
  minLevel: 25,
  features: ['feature1', 'feature2'],
  rewards: {'gold': 500, 'xp': 1000},
);
```

### Adding New NPCs
```dart
_npcs['npc_xx'] = ExpandedNPC(
  id: 'npc_xx',
  name: 'NPC Name',
  level: 20,
  marriageable: true,
  location: 'area_id',
  specialty: 'magic_type',
);
```

### Adding New Skills
```dart
_skills['skill_new'] = Skill(
  id: 'skill_new',
  name: 'Skill Name',
  type: SkillType.magical,
  level: 25,
  damage: 100,
  manaCost: 40,
  cooldown: 2,
);
```

## Quality Metrics

- ✅ 3 new areas with unique features
- ✅ 3 new NPCs with specialties
- ✅ 3 new skills with varied types
- ✅ 3 new equipment pieces
- ✅ 3 new items with purposes
- ✅ Level-gated progression
- ✅ Complete integration ready

## Example Usage

```dart
final system = ContentExpansionSystem.getInstance();
system.initialize();

// Get available areas for player level
final areas = system.getAvailableAreas(25);

// Check if skill is available
final skill = system.getSkill('skill_void_burst');
if (skill != null && 30 <= playerLevel) {
  print('Can learn: ${skill.name}');
}

// Get marriageable NPCs
final spouses = system.getMarriageableNPCs();

// Get area details
final report = system.getAreaReport('sky_temple');
```

## Testing Examples

See `lib/examples/content_expansion_example.dart` for:
- 5-tab Flutter UI
- Area browser with level filtering
- Skill availability by player level
- Equipment showcase with rarity colors
- NPC roster with marriage indicators
- Item catalog with values
