/// コンテンツ拡張システム
/// 新しい領域、NPC、スキル、装備

/// コンテンツ拡張システム
class ContentExpansionSystem {
  static final ContentExpansionSystem _instance =
      ContentExpansionSystem._internal();

  factory ContentExpansionSystem.getInstance() {
    return _instance;
  }

  ContentExpansionSystem._internal();

  // 領域: area_id -> Area
  final Map<String, Area> _areas = {};

  // NPC: npc_id -> ExpandedNPC
  final Map<String, ExpandedNPC> _npcs = {};

  // スキル: skill_id -> Skill
  final Map<String, Skill> _skills = {};

  // 装備: equipment_id -> Equipment
  final Map<String, Equipment> _equipment = {};

  // アイテム: item_id -> Item
  final Map<String, Item> _items = {};

  /// システムを初期化
  void initialize() {
    _areas.clear();
    _npcs.clear();
    _skills.clear();
    _equipment.clear();
    _items.clear();

    _initializeAreas();
    _initializeNPCs();
    _initializeSkills();
    _initializeEquipment();
    _initializeItems();
  }

  /// 領域を初期化
  void _initializeAreas() {
    _areas['sky_temple'] = Area(
      id: 'sky_temple',
      name: 'Sky Temple',
      difficulty: 4,
      minLevel: 25,
      features: ['boss_arena', 'treasure_vault', 'meditation_hall'],
      rewards: {'gold': 500, 'xp': 1000},
    );

    _areas['abyss_depths'] = Area(
      id: 'abyss_depths',
      name: 'Abyss Depths',
      difficulty: 5,
      minLevel: 35,
      features: ['dark_cavern', 'cursed_chamber', 'void_rift'],
      rewards: {'gold': 800, 'xp': 1500},
    );

    _areas['light_domain'] = Area(
      id: 'light_domain',
      name: 'Light Domain',
      difficulty: 3,
      minLevel: 20,
      features: ['sacred_grounds', 'blessing_altar', 'sanctuary'],
      rewards: {'gold': 400, 'xp': 800},
    );
  }

  /// NPCを初期化
  void _initializeNPCs() {
    _npcs['npc_06'] = ExpandedNPC(
      id: 'npc_06',
      name: 'Celestine',
      level: 18,
      marriageable: true,
      location: 'sky_temple',
      specialty: 'light_magic',
    );

    _npcs['npc_07'] = ExpandedNPC(
      id: 'npc_07',
      name: 'Vorthos',
      level: 22,
      marriageable: false,
      location: 'abyss_depths',
      specialty: 'dark_magic',
    );

    _npcs['npc_08'] = ExpandedNPC(
      id: 'npc_08',
      name: 'Aurora',
      level: 20,
      marriageable: true,
      location: 'light_domain',
      specialty: 'healing_magic',
    );
  }

  /// スキルを初期化
  void _initializeSkills() {
    _skills['skill_celestial_strike'] = Skill(
      id: 'skill_celestial_strike',
      name: 'Celestial Strike',
      type: SkillType.physical,
      level: 25,
      damage: 120,
      manaCost: 30,
      cooldown: 2,
    );

    _skills['skill_void_burst'] = Skill(
      id: 'skill_void_burst',
      name: 'Void Burst',
      type: SkillType.magical,
      level: 30,
      damage: 150,
      manaCost: 50,
      cooldown: 3,
    );

    _skills['skill_radiant_heal'] = Skill(
      id: 'skill_radiant_heal',
      name: 'Radiant Heal',
      type: SkillType.healing,
      level: 20,
      healing: 100,
      manaCost: 40,
      cooldown: 1,
    );
  }

  /// 装備を初期化
  void _initializeEquipment() {
    _equipment['celestial_sword'] = Equipment(
      id: 'celestial_sword',
      name: 'Celestial Sword',
      type: EquipmentType.weapon,
      rarity: Rarity.legendary,
      level: 25,
      attack: 85,
      special: 'light_damage_bonus',
    );

    _equipment['void_cloak'] = Equipment(
      id: 'void_cloak',
      name: 'Void Cloak',
      type: EquipmentType.armor,
      rarity: Rarity.legendary,
      level: 30,
      defense: 70,
      special: 'dark_resistance',
    );

    _equipment['radiant_ring'] = Equipment(
      id: 'radiant_ring',
      name: 'Radiant Ring',
      type: EquipmentType.accessory,
      rarity: Rarity.epic,
      level: 20,
      defense: 20,
      special: 'healing_boost_10percent',
    );
  }

  /// アイテムを初期化
  void _initializeItems() {
    _items['ancient_scroll'] = Item(
      id: 'ancient_scroll',
      name: 'Ancient Scroll',
      type: ItemType.quest,
      rarity: Rarity.rare,
      value: 500,
    );

    _items['celestial_stone'] = Item(
      id: 'celestial_stone',
      name: 'Celestial Stone',
      type: ItemType.material,
      rarity: Rarity.legendary,
      value: 1000,
    );

    _items['potion_supreme'] = Item(
      id: 'potion_supreme',
      name: 'Supreme Potion',
      type: ItemType.consumable,
      rarity: Rarity.epic,
      value: 300,
    );
  }

  /// 領域を取得
  Area? getArea(String areaId) {
    return _areas[areaId];
  }

  /// すべての領域を取得
  Map<String, Area> getAllAreas() {
    return Map.from(_areas);
  }

  /// NPCを取得
  ExpandedNPC? getNPC(String npcId) {
    return _npcs[npcId];
  }

  /// スキルを取得
  Skill? getSkill(String skillId) {
    return _skills[skillId];
  }

  /// 装備を取得
  Equipment? getEquipment(String equipmentId) {
    return _equipment[equipmentId];
  }

  /// アイテムを取得
  Item? getItem(String itemId) {
    return _items[itemId];
  }

  /// レベル別に利用可能な領域を取得
  List<Area> getAvailableAreas(int playerLevel) {
    return _areas.values
        .where((a) => playerLevel >= a.minLevel)
        .toList();
  }

  /// レベル別に利用可能なスキルを取得
  List<Skill> getAvailableSkills(int playerLevel) {
    return _skills.values
        .where((s) => playerLevel >= s.level)
        .toList();
  }

  /// 結婚可能なNPCを取得
  List<ExpandedNPC> getMarriageableNPCs() {
    return _npcs.values
        .where((n) => n.marriageable)
        .toList();
  }

  /// 領域情報レポートを取得
  String getAreaReport(String areaId) {
    final area = _areas[areaId];
    if (area == null) return 'Area not found';

    return '''
Area: ${area.name}
Difficulty: ${area.difficulty}/5
Required Level: ${area.minLevel}+

Features:
${area.features.map((f) => '  - $f').join('\n')}

Rewards:
${area.rewards.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}
''';
  }

  /// スキル情報レポートを取得
  String getSkillReport(String skillId) {
    final skill = _skills[skillId];
    if (skill == null) return 'Skill not found';

    return '''
Skill: ${skill.name}
Type: ${skill.type}
Level Required: ${skill.level}

Stats:
  Damage: ${skill.damage}
  Mana Cost: ${skill.manaCost}
  Cooldown: ${skill.cooldown}s
''';
  }
}

/// 領域
class Area {
  final String id;
  final String name;
  final int difficulty;
  final int minLevel;
  final List<String> features;
  final Map<String, int> rewards;

  Area({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.minLevel,
    required this.features,
    required this.rewards,
  });
}

/// 拡張NPC
class ExpandedNPC {
  final String id;
  final String name;
  final int level;
  final bool marriageable;
  final String location;
  final String specialty;

  ExpandedNPC({
    required this.id,
    required this.name,
    required this.level,
    required this.marriageable,
    required this.location,
    required this.specialty,
  });
}

/// スキル
class Skill {
  final String id;
  final String name;
  final SkillType type;
  final int level;
  final int damage;
  final int manaCost;
  final int cooldown;
  int? healing;

  Skill({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.damage,
    required this.manaCost,
    required this.cooldown,
    this.healing,
  });
}

/// スキルタイプ
enum SkillType {
  physical,
  magical,
  healing,
  utility,
}

/// 装備
class Equipment {
  final String id;
  final String name;
  final EquipmentType type;
  final Rarity rarity;
  final int level;
  final int attack;
  final int defense;
  final String? special;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.level,
    required this.attack,
    required this.defense,
    this.special,
  });
}

/// 装備タイプ
enum EquipmentType {
  weapon,
  armor,
  accessory,
}

/// アイテム
class Item {
  final String id;
  final String name;
  final ItemType type;
  final Rarity rarity;
  final int value;

  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.value,
  });
}

/// アイテムタイプ
enum ItemType {
  weapon,
  armor,
  accessory,
  consumable,
  material,
  quest,
}

/// レアリティ
enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}
