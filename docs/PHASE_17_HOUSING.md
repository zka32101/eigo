# Phase 17: Player Housing System

## Overview

Phase 17 implements a comprehensive player housing system with furniture placement, interior design themes, and progressive house upgrades. Players can decorate their homes with themed furniture, manage storage capacity, and watch their house grow through gameplay progression.

**Key Achievement**: Implemented a complete housing system with furniture collision detection, design theme recommendations, storage management, and interactive house customization with 1,900+ lines of code across data models, design system, and interactive examples.

## Architecture Overview

### 1. Housing System

**File**: `lib/models/housing_system.dart` (600+ lines)

Core housing management system with furniture placement, collision detection, and storage tracking.

#### Core Features
- **Player Houses**: Persistent housing tied to player accounts
- **Multi-Room System**: Living room, bedroom, kitchen, bathroom, garage, garden
- **Furniture Placement**: Grid-based placement with collision detection
- **Storage Management**: Limited inventory with upgrade capacity
- **House Progression**: Leveling system with experience tracking
- **Happiness Tracking**: Furniture and theme-based happiness scoring

#### Room Types
```dart
enum RoomType {
  livingRoom,    // Main relaxation and social space
  bedroom,       // Sleep and personal space
  kitchen,       // Cooking and dining
  bathroom,      // Hygiene and comfort
  garage,        // Storage and vehicles
  garden,        // Outdoor decoration
}
```

#### Furniture Categories
```dart
enum FurnitureCategory {
  seating,       // Sofas, chairs, benches
  storage,       // Bookshelves, cabinets, chests
  furniture,     // Tables, desks, beds
  decoration,    // Paintings, sculptures, rugs
  lighting,      // Lamps, chandeliers, torches
  plants,        // Potted plants, trees, flowers
}
```

#### Furniture Rarity Tiers
```dart
enum FurnitureRarity {
  common,        // Basic furniture (1x happiness multiplier)
  uncommon,      // Better quality (1.2x happiness multiplier)
  rare,          // High-quality (1.5x happiness multiplier)
  epic,          // Exceptional (2x happiness multiplier)
  legendary,     // Ultimate (3x happiness multiplier)
}
```

#### Core Data Structures

**PlayerHouse**
```dart
class PlayerHouse {
  final String playerId;           // Unique owner identifier
  String houseName;                // "My Home", "Cozy Cottage", etc.
  final List<Room> rooms;          // Living Room, Bedroom, Kitchen, etc.
  final List<HouseItem> storageItems;  // Inventory items
  final List<HouseUpgrade> upgrades;   // Applied upgrades
  int level;                       // House progression level (1-20+)
  int experience;                  // Experience towards next level
}
```

**Room**
```dart
class Room {
  final String id;                 // 'living_room', 'bedroom', etc.
  final String name;               // Display name
  final RoomType type;             // Type classification
  final int width;                 // Room width in grid units
  final int height;                // Room height in grid units
  final List<Decoration> decorations;  // Placed furniture
}
```

**Decoration** (Placed Furniture)
```dart
class Decoration {
  final String furnitureId;        // Reference to FurnitureDefinition
  int x;                           // Grid X coordinate
  int y;                           // Grid Y coordinate
  int rotation;                    // 0, 90, 180, or 270 degrees
  final DateTime placedAt;         // Placement timestamp
}
```

**FurnitureDefinition**
```dart
class FurnitureDefinition {
  final String id;                 // 'sofa_leather', 'bookshelf', etc.
  final String name;               // Display name
  final FurnitureCategory category; // Type of furniture
  final int width;                 // Grid width
  final int height;                // Grid height
  final int costGold;              // Gold cost to purchase
  final Map<String, int> costMaterials;  // Material requirements
  final String description;        // Flavor text
  final int happiness;             // Happiness contribution
  final FurnitureRarity rarity;    // Rarity classification
}
```

#### Key Methods

**Furniture Placement**
```dart
bool placeFurniture(
  String playerId,
  String roomId,
  String furnitureId,
  int x,
  int y,
  int rotation,
)
```
- Checks if furniture fits within room boundaries
- Detects collisions with existing furniture
- Uses `_rectsIntersect()` for AABB collision detection
- Accounts for rotation when calculating dimensions
- Returns success/failure status

**Collision Detection**
```dart
bool _rectsIntersect(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2)
```
- Axis-Aligned Bounding Box (AABB) collision detection
- O(1) lookup complexity
- Handles rotated furniture dimensions correctly

**Happiness Calculation**
```dart
int calculateHappiness(String playerId, String roomId)
```
- Sums all furniture happiness values in room
- Applies rarity multipliers (common=1x, legendary=3x)
- Accounts for active design theme bonuses
- Returns total happiness for room

**Storage Management**
```dart
int getTotalStorageCapacity()
int getUsedStorageCapacity()
double getStoragePercentage()
```
- Base capacity: 20 items
- Increases with house upgrades (+5 per upgrade)
- Tracks storage usage for UI representation

---

### 2. Interior Design System

**File**: `lib/models/interior_design_system.dart` (400+ lines)

Design theme and layout recommendation system for coordinated home decoration.

#### Core Features
- **Design Themes**: 5 distinct aesthetic themes with color schemes
- **Recommended Layouts**: 6+ pre-configured room layouts
- **Theme Compatibility**: Scoring system for furniture-theme matching
- **Color Schemes**: HEX color definitions for each theme
- **Difficulty Levels**: Easy, medium, hard layouts for progression

#### Design Aesthetics
```dart
enum DesignAesthetic {
  modern,        // Sleek, minimalist, contemporary
  classic,       // Traditional, ornate, elegant
  natural,       // Organic, earthy, plant-focused
  luxury,        // Opulent, premium, prestigious
  cozy,          // Warm, comfortable, intimate
  industrial,    // Raw, functional, urban
  bohemian,      // Eclectic, artistic, free-spirited
}
```

#### 5 Design Themes

**１. Modern Theme**
- Description: "Sleek and minimalist design with clean lines"
- Color Scheme: `['#FFFFFF', '#000000', '#808080']` (White, Black, Gray)
- Happiness Bonus: +20
- Recommended Furniture: sofa_leather, bookshelf, painting_sunset
- Aesthetic: modern, contemporary, tech-forward

**２. Classic Theme**
- Description: "Traditional elegance with ornate details"
- Color Scheme: `['#8B4513', '#D2691E', '#A0522D']` (Browns, taupes)
- Happiness Bonus: +25
- Recommended Furniture: fireplace, chandelier_crystal, dining_table
- Aesthetic: classic, traditional, timeless

**３. Natural Theme**
- Description: "Nature-inspired with plants and wood elements"
- Color Scheme: `['#90EE90', '#228B22', '#8B7355']` (Greens, browns)
- Happiness Bonus: +22
- Recommended Furniture: plant_potted, bookshelf, wooden_chairs
- Aesthetic: natural, organic, living

**４. Luxury Theme**
- Description: "Opulent design with premium materials"
- Color Scheme: `['#FFD700', '#C0C0C0', '#8B0000']` (Gold, silver, deep red)
- Happiness Bonus: +35 (Highest bonus)
- Recommended Furniture: bed_king, chandelier_crystal, fireplace
- Aesthetic: luxury, exclusive, prestigious

**５. Cozy Theme**
- Description: "Warm and comfortable for relaxation"
- Color Scheme: `['#FF6347', '#DC143C', '#8B0000']` (Warm reds, deep red)
- Happiness Bonus: +30
- Recommended Furniture: sofa_leather, fireplace, plant_potted
- Aesthetic: cozy, intimate, welcoming

#### Theme Structure
```dart
class DesignTheme {
  final String id;                 // 'modern', 'classic', etc.
  final String name;               // Display name
  final String description;        // Theme description
  final List<String> colorScheme;  // HEX colors ['#FFFFFF', '#000000', ...]
  final List<String> recommendedFurniture;  // Recommended item IDs
  final int happinessBonus;        // Additional happiness when activated
  final DesignAesthetic aesthetic; // Aesthetic category
}
```

#### Theme Compatibility
```dart
double calculateThemeCompatibility(
  List<String> appliedFurniture,
  DesignTheme theme,
)
```
- Calculates 0.0-1.0 compatibility score
- Compares furniture with theme recommendations
- Formula: `matches / totalFurniture`
- Helps guide furniture selection for thematic consistency

#### Layout Difficulty System
```dart
enum LayoutDifficulty {
  easy,          // Beginner layouts, basic arrangements
  medium,        // Intermediate, more complex positioning
  hard,          // Advanced, tight space, intricate design
}
```

#### 6 Recommended Room Layouts

**１. Simple Living Room (Living Room)**
- Difficulty: Easy
- Required Space: 30 sq units
- Estimated Happiness: 35
- Furniture: sofa_leather (2,2), bookshelf (7,2), plant_potted (7,6)
- Best For: Starting players, basic comfort

**２. Elegant Living Room (Living Room)**
- Difficulty: Medium
- Required Space: 50 sq units
- Estimated Happiness: 80
- Furniture: fireplace (0,0), sofa_leather (3,2), bookshelf (7,1), painting_sunset (1,5), chandelier_crystal (4,0)
- Best For: Aesthetically refined spaces, entertaining

**３. Compact Bedroom (Bedroom)**
- Difficulty: Easy
- Required Space: 24 sq units
- Estimated Happiness: 50
- Furniture: bed_king (1,1), wardrobe (5,1), plant_potted (6,5)
- Best For: Efficient small spaces

**４. Luxury Bedroom (Bedroom)**
- Difficulty: Medium
- Required Space: 35 sq units
- Estimated Happiness: 90
- Furniture: bed_king (1,1), wardrobe (5,1), chandelier_crystal (3,0), painting_sunset (1,5)
- Best For: Premium sleeping quarters

**５. Simple Kitchen (Kitchen)**
- Difficulty: Easy
- Required Space: 18 sq units
- Estimated Happiness: 35
- Furniture: stove (1,1), dining_table (4,2)
- Best For: Basic food preparation

**６. Upscale Kitchen (Kitchen)**
- Difficulty: Medium
- Required Space: 30 sq units
- Estimated Happiness: 70
- Furniture: stove (0,0), dining_table (3,1), chandelier_crystal (4,0), plant_potted (6,4)
- Best For: High-end dining and cooking experiences

---

## Core Data Models

### 9 Pre-Defined Furniture Items

**1. Leather Sofa** (sofa_leather)
- Category: Seating
- Dimensions: 3×2 grid units
- Cost: 500 gold + 10 wood, 5 leather
- Happiness: 15
- Rarity: Common
- Description: "A comfortable leather sofa for relaxation"

**2. Wooden Bookshelf** (bookshelf)
- Category: Storage
- Dimensions: 2×3 grid units
- Cost: 300 gold + 8 wood
- Happiness: 10
- Rarity: Common
- Description: "A sturdy bookshelf to display your collection"

**3. Marble Fireplace** (fireplace)
- Category: Decoration
- Dimensions: 2×3 grid units
- Cost: 800 gold + 15 stone
- Happiness: 25
- Rarity: Uncommon
- Description: "A beautiful marble fireplace providing warmth"

**4. King Bed** (bed_king)
- Category: Furniture
- Dimensions: 3×2 grid units
- Cost: 1200 gold + 20 wood, 10 fabric
- Happiness: 30
- Rarity: Rare
- Description: "A luxurious king-sized bed for restful sleep"

**5. Wooden Wardrobe** (wardrobe)
- Category: Storage
- Dimensions: 2×2 grid units
- Cost: 400 gold + 12 wood
- Happiness: 8
- Rarity: Common
- Description: "A spacious wardrobe for clothing storage"

**6. Iron Stove** (stove)
- Category: Furniture
- Dimensions: 2×2 grid units
- Cost: 600 gold + 10 iron
- Happiness: 12
- Rarity: Common
- Description: "A sturdy iron stove for cooking meals"

**7. Dining Table** (dining_table)
- Category: Furniture
- Dimensions: 3×2 grid units
- Cost: 400 gold + 12 wood
- Happiness: 18
- Rarity: Common
- Description: "A wooden dining table for shared meals"

**8. Sunset Painting** (painting_sunset)
- Category: Decoration
- Dimensions: 1×1 grid units
- Cost: 350 gold
- Happiness: 20
- Rarity: Uncommon
- Description: "A beautiful painting of a golden sunset"

**9. Crystal Chandelier** (chandelier_crystal)
- Category: Lighting
- Dimensions: 2×1 grid units
- Cost: 900 gold + 5 crystal, 3 gold
- Happiness: 28
- Rarity: Rare
- Description: "An elegant crystal chandelier providing brilliant light"

**10. Potted Plant** (plant_potted)
- Category: Plants
- Dimensions: 1×1 grid units
- Cost: 150 gold
- Happiness: 8
- Rarity: Common
- Description: "A vibrant potted plant bringing nature indoors"

---

## Storage System

### Storage Mechanics

**Base Capacity**: 20 items
- Each player starts with 20-item storage
- Storage is shared across house

**Upgrade Capacity**: +5 per house upgrade
- House upgrades increase storage space
- Example: Level 3 house (2 upgrades) = 20 + (2×5) = 30 items

**Storage Tracking**
```dart
class HouseItem {
  final String itemId;             // Item identifier
  final String name;               // Display name
  int quantity;                    // Stack size
  final String description;        // Item description
}
```

### Storage Operations

**Add Item**
```dart
bool addItemToStorage(String playerId, String itemId, int quantity)
```
- Checks available storage capacity
- Stacks items with same ID
- Returns success/failure

**Remove Item**
```dart
bool removeItemFromStorage(String playerId, String itemId, int quantity)
```
- Validates item exists and quantity sufficient
- Decreases stack or removes entry
- Frees storage space

**Query Storage**
```dart
int getUsedStorageCapacity(String playerId)
int getTotalStorageCapacity(String playerId)
double getStoragePercentage(String playerId)
List<HouseItem> getAllStorageItems(String playerId)
```

---

## House Progression

### Experience and Leveling

**Experience Sources**
- Placing furniture: +10 XP per item
- Completing design themes: +50 XP
- Room completion: +25 XP per room
- Interior decorating achievements: +100+ XP

**Level Requirements**
```
Level 1: 0 XP (Start)
Level 2: 200 XP
Level 3: 400 XP
Level 4: 600 XP
Level 5: 800 XP
Level 10: 2000 XP (example)
Level 20: 4000 XP (maximum)
```

### House Upgrades

**Upgrade Types**
- Storage Expansion: +5 item slots
- Room Addition: Unlock new room type
- Appearance Enhancement: Better visual themes
- Utility Improvement: Faster item processing

**Upgrade System**
```dart
class HouseUpgrade {
  final String id;                 // 'storage_expand_1'
  final String name;               // Display name
  final String description;        // What upgrade does
  final int level;                 // Upgrade tier
  final int costGold;              // Gold requirement
  final int costExperience;        // Experience requirement
  final DateTime appliedAt;        // When installed
}
```

---

## Integration Patterns

### With NPC Affection System

```dart
// Players can earn affection by having NPCs visit their decorated home
// High happiness rooms increase affection gains from visits
// Design themes can match NPC aesthetic preferences
```

### With Quest System

```dart
// Furniture acquisition quests: "Gather materials for bookshelf"
// Interior design challenges: "Decorate room using natural theme"
// House level achievements: "Reach house level 10"
```

### With Faction System

```dart
// Faction-themed furniture: Guild weapons, Cartel goods, Tower artifacts
// Faction rep affects furniture availability and pricing
// Different factions prefer different design aesthetics
```

### With Game Events

```dart
// HouseDecorated event: Fired when completing room
// FurniturePlaced event: Fired when placing new item
// ThemeActivated event: Fired when theme requirements met
// StorageFull event: Fired when storage reaches capacity
```

---

## Implementation Details

### Collision Detection Algorithm

**AABB (Axis-Aligned Bounding Box) Detection**
```dart
bool _rectsIntersect(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2) {
  return x1 < x2 + w2 && x1 + w1 > x2 && 
         y1 < y2 + h2 && y1 + h1 > y2;
}
```

**Complexity**: O(1) per check
- No nested loops
- Simple integer comparisons
- Handles arbitrary rotations through dimension swapping

### Happiness Scoring

**Formula**
```
Total Happiness = Base + Theme Bonus + Furniture Happiness
```

**Base Happiness**: Room type foundation value
**Theme Bonus**: +20 to +35 depending on theme
**Furniture Happiness**: Sum of all placed furniture
- Common furniture: 1x multiplier
- Legendary furniture: 3x multiplier

**Example Calculation**
- Room base: 10
- Modern theme bonus: +20
- sofa_leather (15 happiness × 1.0): 15
- bookshelf (10 happiness × 1.0): 10
- painting_sunset (20 happiness × 1.5 rare): 30
- **Total: 10 + 20 + 15 + 10 + 30 = 85 happiness**

---

## System Performance

### Lookup Complexity
- Furniture retrieval: O(1) hash map
- Room furniture list: O(n) where n = furniture count per room
- House retrieval: O(1) hash map
- Theme retrieval: O(1) hash map
- Layout retrieval: O(1) hash map

### Collision Detection
- Per-placement check: O(m) where m = existing furniture count
- Typically m < 20 per room, making effective O(1)

### Storage Operations
- Add/remove item: O(1) average case with hash map
- List all items: O(k) where k = unique item types
- Query storage capacity: O(1)

---

## Expansion Patterns

### Adding New Furniture

1. Define FurnitureDefinition
```dart
_registerFurniture(FurnitureDefinition(
  id: 'new_item_id',
  name: 'New Item Name',
  category: FurnitureCategory.decoration,
  width: 2,
  height: 2,
  costGold: 500,
  costMaterials: {'material': 10},
  description: 'Description',
  happiness: 15,
  rarity: FurnitureRarity.uncommon,
));
```

2. Reference in theme recommendations
```dart
recommendedFurniture: ['sofa_leather', 'new_item_id', 'bookshelf']
```

3. Add to layout if appropriate
```dart
FurniturePosition(furnitureId: 'new_item_id', x: 3, y: 2, rotation: 0)
```

### Adding New Themes

1. Define DesignTheme with unique aesthetic
```dart
DesignTheme(
  id: 'steampunk',
  name: 'Steampunk',
  aesthetic: DesignAesthetic.industrial,
  colorScheme: ['#8B7355', '#FFD700', '#A9A9A9'],
  recommendedFurniture: ['industrial_lamp', 'copper_gear', 'gear_wall'],
  happinessBonus: 28,
)
```

2. Add new furniture to match theme
3. Create layout templates using new furniture

### Adding New Rooms

1. Add to RoomType enum
```dart
enum RoomType {
  livingRoom, bedroom, kitchen, bathroom, garage, garden, 
  library, // NEW
}
```

2. Create default room in house initialization
```dart
Room(
  id: 'library',
  name: 'Library',
  type: RoomType.library,
  width: 10,
  height: 8,
  decorations: [],
)
```

3. Create layout templates
```dart
RoomLayout(
  id: 'library_scholarly',
  name: 'Scholarly Library',
  roomType: 'library',
  furniturePositions: [...],
)
```

---

## Files Generated

| File | Lines | Purpose |
|------|-------|---------|
| `lib/models/housing_system.dart` | 600+ | Core housing, furniture placement, collision detection |
| `lib/models/interior_design_system.dart` | 400+ | Design themes, room layouts, theme compatibility |
| `lib/examples/housing_system_example.dart` | 700+ | Interactive UI for house customization demo |
| `docs/PHASE_17_HOUSING.md` | 500+ | Complete architecture documentation |
| **Total** | **2,200+** | **Complete player housing system** |

---

## System Summary

The Phase 17 Player Housing System provides:

✅ **Complete house management** with multiple rooms and progressive upgrades  
✅ **Grid-based furniture placement** with AABB collision detection  
✅ **5 design themes** with aesthetic recommendations and compatibility scoring  
✅ **6+ room layouts** across multiple room types with difficulty progression  
✅ **10 pre-defined furniture items** with rarity tiers and customizable properties  
✅ **Storage system** with capacity management and item tracking  
✅ **Happiness scoring** based on furniture, themes, and room arrangement  
✅ **Efficient O(1) lookups** for houses, furniture, themes, and layouts  
✅ **Integration hooks** for NPC affection, quests, factions, and game events  
✅ **Extensible architecture** for adding new furniture, themes, and room types  

The system is production-ready with comprehensive data models, efficient algorithms, and clear expansion patterns for future enhancement.
