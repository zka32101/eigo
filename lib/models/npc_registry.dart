import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/models/dialogue_model.dart';
import 'package:eigo/models/quest_model.dart';

/// NPCレジストリ
/// ゲーム内のすべてのNPCを一元管理
class NPCRegistry {
  static final NPCRegistry _instance = NPCRegistry._internal();

  factory NPCRegistry.getInstance() {
    return _instance;
  }

  NPCRegistry._internal();

  final Map<String, NPCData> _npcs = {};

  /// すべてのNPCデータを初期化
  void initializeAllNPCs() {
    _npcs.clear();

    // 魔法使いの塔のNPC
    _registerAriaTheMage();
    _registerLunaTheScholar();
    _registerMorvanTheArchemist();

    // 冒険者の村のNPC
    _registerKaiTheWarrior();
    _registerEloiseTheRogue();
    _registerThornTheHealerette();

    // 商人の街のNPC
    _registerZephyrTheMerchant();
    _registerMaeTheBlacksmith();
    _registerOliverTheAlchemist();
    _registerIsabellaTheBard();
  }

  // ==== 魔法使いの塔のNPC ====

  void _registerAriaTheMage() {
    _npcs['aria_001'] = NPCData(
      id: 'aria_001',
      name: 'Aria',
      title: '若き魔法使い',
      region: 'Mage Tower',
      emoticon: '✨',
      personality: PersonalityTraits(
        openness: 75,
        conscientiousness: 60,
        extraversion: 65,
        agreeableness: 80,
        neuroticism: 40,
      ),
      baseAffection: 50,
      level: 5,
      description: '魔法の才能を持つ若い魔法使い。友好的でプレイヤーを助けたいと思っている。',
      skills: ['Fireball', 'Ice Storm', 'Teleport'],
      quests: ['Learn Fireball', 'Gather Crystals', 'Defeat Shadow Mage'],
    );
  }

  void _registerLunaTheScholar() {
    _npcs['luna_002'] = NPCData(
      id: 'luna_002',
      name: 'Luna',
      title: '古書の守者',
      region: 'Mage Tower',
      emoticon: '📚',
      personality: PersonalityTraits(
        openness: 85,
        conscientiousness: 90,
        extraversion: 35,
        agreeableness: 70,
        neuroticism: 25,
      ),
      baseAffection: 40,
      level: 6,
      description: '知識を求める真摯な学者。古い魔法について教えることを好む。',
      skills: ['Arcane Knowledge', 'Mana Shield', 'Spell Research'],
      quests: ['Research Ancient Spells', 'Find Lost Books', 'Decode Runes'],
    );
  }

  void _registerMorvanTheArchemist() {
    _npcs['morvan_003'] = NPCData(
      id: 'morvan_003',
      name: 'Morvan',
      title: '錬金術師',
      region: 'Mage Tower',
      emoticon: '⚗️',
      personality: PersonalityTraits(
        openness: 80,
        conscientiousness: 75,
        extraversion: 45,
        agreeableness: 55,
        neuroticism: 60,
      ),
      baseAffection: 30,
      level: 8,
      description: '不安定だが才能のある錬金術師。危険な実験を行っている。',
      skills: ['Potion Brewing', 'Transmutation', 'Elemental Fusion'],
      quests: ['Gather Reagents', 'Test Potions', 'Create Elixir'],
    );
  }

  // ==== 冒険者の村のNPC ====

  void _registerKaiTheWarrior() {
    _npcs['kai_004'] = NPCData(
      id: 'kai_004',
      name: 'Kai',
      title: '勇敢な戦士',
      region: 'Adventurers Village',
      emoticon: '⚔️',
      personality: PersonalityTraits(
        openness: 60,
        conscientiousness: 65,
        extraversion: 80,
        agreeableness: 75,
        neuroticism: 30,
      ),
      baseAffection: 55,
      level: 7,
      description: '正義感あふれる戦士。パーティリーダーとして他の冒険者から尊敬されている。',
      skills: ['Sword Mastery', 'Shield Defense', 'Battle Cry'],
      quests: ['Defeat Bandits', 'Protect Village', 'Find Legendary Sword'],
    );
  }

  void _registerEloiseTheRogue() {
    _npcs['eloise_005'] = NPCData(
      id: 'eloise_005',
      name: 'Eloise',
      title: '影の盗賊',
      region: 'Adventurers Village',
      emoticon: '🗡️',
      personality: PersonalityTraits(
        openness: 70,
        conscientiousness: 50,
        extraversion: 65,
        agreeableness: 45,
        neuroticism: 55,
      ),
      baseAffection: 45,
      level: 6,
      description: '機知に富んだ盗賊。秘密を多く持っており、信頼を得るのは難しい。',
      skills: ['Backstab', 'Stealth', 'Lock Picking'],
      quests: ['Steal from Nobles', 'Retrieve Lost Items', 'Infiltrate Castle'],
    );
  }

  void _registerThornTheHealerette() {
    _npcs['thorn_006'] = NPCData(
      id: 'thorn_006',
      name: 'Thorn',
      title: '優しい治療者',
      region: 'Adventurers Village',
      emoticon: '🩹',
      personality: PersonalityTraits(
        openness: 65,
        conscientiousness: 85,
        extraversion: 50,
        agreeableness: 90,
        neuroticism: 20,
      ),
      baseAffection: 60,
      level: 5,
      description: '傷ついた冒険者を助けることに喜びを感じる治療者。誰にでも親切。',
      skills: ['Heal Wounds', 'Cure Poison', 'Revival'],
      quests: ['Gather Herbs', 'Help Sick Villagers', 'Create Antidote'],
    );
  }

  // ==== 商人の街のNPC ====

  void _registerZephyrTheMerchant() {
    _npcs['zephyr_007'] = NPCData(
      id: 'zephyr_007',
      name: 'Zephyr',
      title: '行商人',
      region: 'Merchants City',
      emoticon: '🛍️',
      personality: PersonalityTraits(
        openness: 75,
        conscientiousness: 70,
        extraversion: 85,
        agreeableness: 60,
        neuroticism: 35,
      ),
      baseAffection: 50,
      level: 5,
      description: '商売上手な行商人。利益を求めるが、信頼できるビジネスパートナー。',
      skills: ['Trading', 'Negotiation', 'Business Sense'],
      quests: ['Deliver Goods', 'Negotiate Prices', 'Build Trade Routes'],
    );
  }

  void _registerMaeTheBlacksmith() {
    _npcs['mae_008'] = NPCData(
      id: 'mae_008',
      name: 'Mae',
      title: '鍛冶職人',
      region: 'Merchants City',
      emoticon: '🔨',
      personality: PersonalityTraits(
        openness: 55,
        conscientiousness: 90,
        extraversion: 45,
        agreeableness: 70,
        neuroticism: 25,
      ),
      baseAffection: 50,
      level: 8,
      description: '完璧さを求める職人。最高の武器を作ることに人生をかけている。',
      skills: ['Weapon Crafting', 'Armor Smithing', 'Enchanting'],
      quests: ['Gather Ore', 'Craft Legendary Weapons', 'Forge for Heroes'],
    );
  }

  void _registerOliverTheAlchemist() {
    _npcs['oliver_009'] = NPCData(
      id: 'oliver_009',
      name: 'Oliver',
      title: '隠遁者錬金術師',
      region: 'Merchants City',
      emoticon: '🧪',
      personality: PersonalityTraits(
        openness: 80,
        conscientiousness: 60,
        extraversion: 30,
        agreeableness: 50,
        neuroticism: 50,
      ),
      baseAffection: 35,
      level: 7,
      description: '謎めいた錬金術師。人間関係に興味がなく、研究にのみ集中している。',
      skills: ['Advanced Alchemy', 'Potion Mastery', 'Mutation'],
      quests: ['Find Rare Ingredients', 'Experiment on Subjects', 'Create Philosopher Stone'],
    );
  }

  void _registerIsabellaTheBard() {
    _npcs['isabella_010'] = NPCData(
      id: 'isabella_010',
      name: 'Isabella',
      title: '吟遊詩人',
      region: 'Merchants City',
      emoticon: '🎵',
      personality: PersonalityTraits(
        openness: 90,
        conscientiousness: 40,
        extraversion: 95,
        agreeableness: 85,
        neuroticism: 45,
      ),
      baseAffection: 55,
      level: 4,
      description: '自由奔放な吟遊詩人。誰とでも友達になれる魅力的なキャラクター。',
      skills: ['Inspire', 'Charm', 'Storytelling'],
      quests: ['Collect Stories', 'Inspire Town', 'Perform at Festival'],
    );
  }

  /// NPCを取得
  NPCData? getNPC(String npcId) {
    return _npcs[npcId];
  }

  /// すべてのNPCを取得
  List<NPCData> getAllNPCs() {
    return _npcs.values.toList();
  }

  /// 地域ごとのNPCを取得
  List<NPCData> getNPCsByRegion(String region) {
    return _npcs.values.where((npc) => npc.region == region).toList();
  }

  /// NPCの数を取得
  int getNPCCount() {
    return _npcs.length;
  }

  /// 特定のスキルを持つNPCを検索
  List<NPCData> getNPCsBySkill(String skill) {
    return _npcs.values.where((npc) => npc.skills.contains(skill)).toList();
  }
}

/// NPCデータモデル
class NPCData {
  final String id;
  final String name;
  final String title;
  final String region;
  final String emoticon;
  final PersonalityTraits personality;
  final int baseAffection;
  final int level;
  final String description;
  final List<String> skills;
  final List<String> quests;

  NPCData({
    required this.id,
    required this.name,
    required this.title,
    required this.region,
    required this.emoticon,
    required this.personality,
    required this.baseAffection,
    required this.level,
    required this.description,
    required this.skills,
    required this.quests,
  });

  /// NPCの表示名を取得
  String getDisplayName() => '$name - $title';

  /// NPCの説明を取得
  String getDescription() => description;

  /// NPCの気分を取得（親密度から推測）
  String getMoodFromAffection(int currentAffection) {
    if (currentAffection >= 80) return 'very_happy';
    if (currentAffection >= 60) return 'happy';
    if (currentAffection >= 40) return 'neutral';
    if (currentAffection >= 20) return 'sad';
    return 'angry';
  }
}
