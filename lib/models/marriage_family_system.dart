/// NPC結婚・家族システム
/// 結婚、離婚、子供、家族の絆、相続

/// 結婚・家族システム
class MarriageFamilySystem {
  static final MarriageFamilySystem _instance =
      MarriageFamilySystem._internal();

  factory MarriageFamilySystem.getInstance() {
    return _instance;
  }

  MarriageFamilySystem._internal();

  // プレイヤーの家族データ: player_id -> FamilyData
  final Map<String, FamilyData> _playerFamilies = {};

  // NPCデータ: npc_id -> NPCProfile
  final Map<String, NPCProfile> _npcProfiles = {};

  // 結婚可能なNPC: npc_id -> MarriageCandidate
  final Map<String, MarriageCandidate> _marriageCandidates = {};

  // 結婚イベント: marriage_id -> MarriageEvent
  final Map<String, MarriageEvent> _marriageEvents = {};

  // 家族の絆: family_id -> FamilyBond
  final Map<String, FamilyBond> _familyBonds = {};

  /// システムを初期化
  void initialize() {
    _playerFamilies.clear();
    _npcProfiles.clear();
    _marriageCandidates.clear();
    _marriageEvents.clear();
    _familyBonds.clear();
    _initializeNPCProfiles();
    _initializeMarriageCandidates();
    _initializeMarriageEvents();
  }

  /// すべてのNPCプロフィールを初期化
  void _initializeNPCProfiles() {
    // 女性NPC
    _registerNPCProfile(NPCProfile(
      id: 'npc_serena',
      name: 'Serena',
      gender: Gender.female,
      age: 24,
      personality: Personality.gentle,
      affinity: 45,
      maxAffinity: 100,
      marriageAvailable: true,
      bachelorDays: 0,
      traits: ['caring', 'intelligent', 'patient'],
      description: 'A kind-hearted mage from the tower',
      imageAsset: 'assets/npc/serena.png',
    ));

    _registerNPCProfile(NPCProfile(
      id: 'npc_luna',
      name: 'Luna',
      gender: Gender.female,
      age: 22,
      personality: Personality.energetic,
      affinity: 35,
      maxAffinity: 100,
      marriageAvailable: true,
      bachelorDays: 0,
      traits: ['adventurous', 'brave', 'cheerful'],
      description: 'A skilled warrior seeking adventure',
      imageAsset: 'assets/npc/luna.png',
    ));

    _registerNPCProfile(NPCProfile(
      id: 'npc_iris',
      name: 'Iris',
      gender: Gender.female,
      age: 26,
      personality: Personality.mysterious,
      affinity: 40,
      maxAffinity: 100,
      marriageAvailable: true,
      bachelorDays: 0,
      traits: ['mysterious', 'wise', 'elegant'],
      description: 'An enigmatic scholar with ancient knowledge',
      imageAsset: 'assets/npc/iris.png',
    ));

    // 男性NPC
    _registerNPCProfile(NPCProfile(
      id: 'npc_aldric',
      name: 'Aldric',
      gender: Gender.male,
      age: 28,
      personality: Personality.stoic,
      affinity: 50,
      maxAffinity: 100,
      marriageAvailable: true,
      bachelorDays: 0,
      traits: ['strong', 'loyal', 'honorable'],
      description: 'A seasoned knight with a noble heart',
      imageAsset: 'assets/npc/aldric.png',
    ));

    _registerNPCProfile(NPCProfile(
      id: 'npc_kael',
      name: 'Kael',
      gender: Gender.male,
      age: 25,
      personality: Personality.mischievous,
      affinity: 30,
      maxAffinity: 100,
      marriageAvailable: true,
      bachelorDays: 0,
      traits: ['charming', 'witty', 'clever'],
      description: 'A roguish treasure hunter with a silver tongue',
      imageAsset: 'assets/npc/kael.png',
    ));
  }

  /// すべての結婚候補者を初期化
  void _initializeMarriageCandidates() {
    // 各NPCの好みの条件を設定
    _registerMarriageCandidate(MarriageCandidate(
      npcId: 'npc_serena',
      minimumAffinity: 60,
      requiredLevel: 10,
      requiredGold: 5000,
      preferredTraits: ['intelligent', 'patient', 'kind'],
      marriageBonuses: {
        'intelligence': 10,
        'mana': 50,
        'magic_affinity': 15,
      },
      preferredGifts: ['flower_bouquet', 'magic_tome', 'jewelry'],
      specialEventId: 'event_serena_proposal',
    ));

    _registerMarriageCandidate(MarriageCandidate(
      npcId: 'npc_luna',
      minimumAffinity: 55,
      requiredLevel: 15,
      requiredGold: 8000,
      preferredTraits: ['brave', 'adventurous', 'strong'],
      marriageBonuses: {
        'strength': 12,
        'health': 80,
        'agility': 10,
      },
      preferredGifts: ['weapon', 'adventure_map', 'ring'],
      specialEventId: 'event_luna_proposal',
    ));

    _registerMarriageCandidate(MarriageCandidate(
      npcId: 'npc_iris',
      minimumAffinity: 65,
      requiredLevel: 20,
      requiredGold: 10000,
      preferredTraits: ['wise', 'mysterious', 'elegant'],
      marriageBonuses: {
        'wisdom': 15,
        'knowledge': 20,
        'magic_affinity': 20,
      },
      preferredGifts: ['ancient_tome', 'crystal', 'rare_artifact'],
      specialEventId: 'event_iris_proposal',
    ));

    _registerMarriageCandidate(MarriageCandidate(
      npcId: 'npc_aldric',
      minimumAffinity: 60,
      requiredLevel: 18,
      requiredGold: 7000,
      preferredTraits: ['honorable', 'loyal', 'strong'],
      marriageBonuses: {
        'defense': 15,
        'health': 100,
        'honor': 25,
      },
      preferredGifts: ['sword', 'shield', 'armor'],
      specialEventId: 'event_aldric_proposal',
    ));

    _registerMarriageCandidate(MarriageCandidate(
      npcId: 'npc_kael',
      minimumAffinity: 50,
      requiredLevel: 12,
      requiredGold: 6000,
      preferredTraits: ['charming', 'clever', 'witty'],
      marriageBonuses: {
        'agility': 15,
        'luck': 20,
        'charisma': 12,
      },
      preferredGifts: ['treasure_map', 'jeweled_ring', 'rare_wine'],
      specialEventId: 'event_kael_proposal',
    ));
  }

  /// すべての結婚イベントを初期化
  void _initializeMarriageEvents() {
    // セレナとの結婚イベント
    _registerMarriageEvent(MarriageEvent(
      id: 'event_serena_proposal',
      npcId: 'npc_serena',
      eventType: MarriageEventType.proposal,
      storyText: 'Serena gazes into your eyes with affection...',
      requirementsMet: true,
      rewardGold: 1000,
      rewardXP: 5000,
      unlockFamily: true,
    ));

    // ルナとの結婚イベント
    _registerMarriageEvent(MarriageEvent(
      id: 'event_luna_proposal',
      npcId: 'npc_luna',
      eventType: MarriageEventType.proposal,
      storyText: 'Luna smiles brightly and takes your hand...',
      requirementsMet: true,
      rewardGold: 1500,
      rewardXP: 6000,
      unlockFamily: true,
    ));

    // アイリスとの結婚イベント
    _registerMarriageEvent(MarriageEvent(
      id: 'event_iris_proposal',
      npcId: 'npc_iris',
      eventType: MarriageEventType.proposal,
      storyText: 'Iris reveals her heart to you with a knowing smile...',
      requirementsMet: true,
      rewardGold: 2000,
      rewardXP: 7000,
      unlockFamily: true,
    ));

    // アルドリックとの結婚イベント
    _registerMarriageEvent(MarriageEvent(
      id: 'event_aldric_proposal',
      npcId: 'npc_aldric',
      eventType: MarriageEventType.proposal,
      storyText: 'Aldric kneels and pledges his loyalty to you forever...',
      requirementsMet: true,
      rewardGold: 1500,
      rewardXP: 5500,
      unlockFamily: true,
    ));

    // カエルとの結婚イベント
    _registerMarriageEvent(MarriageEvent(
      id: 'event_kael_proposal',
      npcId: 'npc_kael',
      eventType: MarriageEventType.proposal,
      storyText: 'Kael grins mischievously and asks for your hand...',
      requirementsMet: true,
      rewardGold: 1200,
      rewardXP: 5000,
      unlockFamily: true,
    ));

    // 出産イベント
    _registerMarriageEvent(MarriageEvent(
      id: 'event_birth',
      npcId: '',
      eventType: MarriageEventType.birth,
      storyText: 'Your child is born! A new chapter begins...',
      requirementsMet: true,
      rewardGold: 5000,
      rewardXP: 10000,
      unlockFamily: false,
    ));

    // 結婚記念日イベント
    _registerMarriageEvent(MarriageEvent(
      id: 'event_anniversary',
      npcId: '',
      eventType: MarriageEventType.anniversary,
      storyText: 'You celebrate another year of marriage!',
      requirementsMet: true,
      rewardGold: 2000,
      rewardXP: 3000,
      unlockFamily: false,
    ));
  }

  /// NPC プロフィールを登録
  void _registerNPCProfile(NPCProfile profile) {
    _npcProfiles[profile.id] = profile;
  }

  /// 結婚候補者を登録
  void _registerMarriageCandidate(MarriageCandidate candidate) {
    _marriageCandidates[candidate.npcId] = candidate;
  }

  /// 結婚イベントを登録
  void _registerMarriageEvent(MarriageEvent event) {
    _marriageEvents[event.id] = event;
  }

  /// プレイヤーと NPCのアフィニティを増加
  bool increaseAffinity(String playerId, String npcId, int amount) {
    if (!_npcProfiles.containsKey(npcId)) return false;

    if (!_playerFamilies.containsKey(playerId)) {
      _playerFamilies[playerId] = FamilyData(
        playerId: playerId,
        married: false,
        spouse: null,
        children: [],
        marriedSince: 0,
        totalAffinity: 0,
        familyWealth: 0,
        inheritanceReady: false,
      );
    }

    final npc = _npcProfiles[npcId]!;
    npc.affinity = (npc.affinity + amount).clamp(0, npc.maxAffinity);
    return true;
  }

  /// プロポーズが可能か確認
  bool canPropose(
    String playerId,
    String npcId,
    int playerLevel,
    int playerGold,
  ) {
    final candidate = _marriageCandidates[npcId];
    if (candidate == null) return false;

    final npc = _npcProfiles[npcId];
    if (npc == null) return false;

    // 最小アフィニティをチェック
    if (npc.affinity < candidate.minimumAffinity) return false;

    // 必要レベルをチェック
    if (playerLevel < candidate.requiredLevel) return false;

    // 必要ゴールドをチェック
    if (playerGold < candidate.requiredGold) return false;

    // 既に結婚していないかチェック
    final family = _playerFamilies[playerId];
    if (family != null && family.married) return false;

    return true;
  }

  /// NPCと結婚
  bool proposalAccepted(
    String playerId,
    String npcId,
  ) {
    if (!_playerFamilies.containsKey(playerId)) {
      _playerFamilies[playerId] = FamilyData(
        playerId: playerId,
        married: false,
        spouse: null,
        children: [],
        marriedSince: 0,
        totalAffinity: 0,
        familyWealth: 0,
        inheritanceReady: false,
      );
    }

    final family = _playerFamilies[playerId]!;
    final npc = _npcProfiles[npcId];

    if (npc == null || family.married) return false;

    family.married = true;
    family.spouse = npcId;
    family.marriedSince = DateTime.now().millisecondsSinceEpoch;
    family.totalAffinity += npc.affinity;

    // NPCの独身期間を更新
    npc.marriageAvailable = false;
    npc.bachelorDays = 0;

    return true;
  }

  /// 子供を産む
  bool giveBirth(String playerId, String childName) {
    final family = _playerFamilies[playerId];
    if (family == null || !family.married) return false;

    final child = Child(
      id: '${playerId}_child_${family.children.length + 1}',
      name: childName,
      parentPlayerId: playerId,
      parentNpcId: family.spouse!,
      ageInDays: 0,
      traits: [],
      health: 100,
      happiness: 80,
      educationLevel: 0,
    );

    family.children.add(child);
    return true;
  }

  /// 子供を教育する
  bool educateChild(String playerId, int childIndex) {
    final family = _playerFamilies[playerId];
    if (family == null || childIndex >= family.children.length) return false;

    final child = family.children[childIndex];
    child.educationLevel += 10;
    child.happiness -= 5;
    return true;
  }

  /// 子供と時間を過ごす
  bool spendTimeWithChild(String playerId, int childIndex) {
    final family = _playerFamilies[playerId];
    if (family == null || childIndex >= family.children.length) return false;

    final child = family.children[childIndex];
    child.happiness += 15;
    child.health = (child.health + 10).clamp(0, 100);
    return true;
  }

  /// 夫婦の親密度を上げる
  bool spendTimeWithSpouse(String playerId, int time) {
    final family = _playerFamilies[playerId];
    if (family == null || !family.married) return false;

    final npc = _npcProfiles[family.spouse]!;
    npc.affinity = (npc.affinity + time ~/ 10).clamp(0, npc.maxAffinity);
    return true;
  }

  /// 離婚
  bool getDivorce(String playerId) {
    final family = _playerFamilies[playerId];
    if (family == null || !family.married) return false;

    final npc = _npcProfiles[family.spouse];
    if (npc != null) {
      npc.affinity = (npc.affinity * 0.3).toInt(); // アフィニティ大幅低下
      npc.marriageAvailable = true;
    }

    family.married = false;
    family.spouse = null;
    family.marriedSince = 0;

    // 子供は元配偶者と一緒に留まる
    family.children.clear();

    return true;
  }

  /// 家族の総合パワーを計算
  int calculateFamilyPower(String playerId) {
    final family = _playerFamilies[playerId];
    if (family == null) return 0;

    int power = 0;

    // 配偶者からのボーナス
    if (family.married && family.spouse != null) {
      final spouse = _npcProfiles[family.spouse];
      if (spouse != null) {
        power += spouse.affinity * 2;
      }
    }

    // 子供からのボーナス
    for (final child in family.children) {
      power += child.educationLevel * 10;
      power += (child.happiness * 5) ~/ 100;
    }

    return power;
  }

  /// 家族ボーナスを計算
  Map<String, int> calculateFamilyBonuses(String playerId) {
    final family = _playerFamilies[playerId];
    final bonuses = <String, int>{};

    if (family == null || !family.married) return bonuses;

    final candidate = _marriageCandidates[family.spouse];
    if (candidate != null) {
      bonuses.addAll(candidate.marriageBonuses);
    }

    // 子供のボーナス
    if (family.children.isNotEmpty) {
      bonuses['family_strength'] =
          (bonuses['family_strength'] ?? 0) + (family.children.length * 5);
    }

    return bonuses;
  }

  /// 家族データを取得
  FamilyData? getFamilyData(String playerId) {
    return _playerFamilies[playerId];
  }

  /// NPC プロフィールを取得
  NPCProfile? getNPCProfile(String npcId) {
    return _npcProfiles[npcId];
  }

  /// すべてのNPCプロフィールを取得
  List<NPCProfile> getAllNPCProfiles() {
    return _npcProfiles.values.toList();
  }

  /// 結婚可能なNPCを取得
  List<NPCProfile> getMarriageCandidates() {
    return _npcProfiles.values
        .where((npc) => npc.marriageAvailable)
        .toList();
  }

  /// 結婚イベントを取得
  MarriageEvent? getMarriageEvent(String eventId) {
    return _marriageEvents[eventId];
  }

  /// 女性NPCを取得
  List<NPCProfile> getFemaleNPCs() {
    return _npcProfiles.values
        .where((npc) => npc.gender == Gender.female)
        .toList();
  }

  /// 男性NPCを取得
  List<NPCProfile> getMaleNPCs() {
    return _npcProfiles.values
        .where((npc) => npc.gender == Gender.male)
        .toList();
  }
}

/// プレイヤーの家族データ
class FamilyData {
  final String playerId;
  bool married; // 既婚状態
  String? spouse; // 配偶者のNPC ID
  final List<Child> children; // 子供たち
  int marriedSince; // 結婚日時のタイムスタンプ
  int totalAffinity; // 総合アフィニティ
  int familyWealth; // 家族の総資産
  bool inheritanceReady; // 相続準備完了

  FamilyData({
    required this.playerId,
    required this.married,
    required this.spouse,
    required this.children,
    required this.marriedSince,
    required this.totalAffinity,
    required this.familyWealth,
    required this.inheritanceReady,
  });

  /// 結婚期間を日数で取得
  int getMarriedDays() {
    if (marriedSince == 0) return 0;
    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(marriedSince)).inDays;
  }

  /// 結婚記念日か確認
  bool isAnniversary() {
    return getMarriedDays() > 0 && getMarriedDays() % 365 == 0;
  }
}

/// NPC プロフィール
class NPCProfile {
  final String id;
  final String name;
  final Gender gender;
  final int age;
  final Personality personality;
  int affinity; // 現在のアフィニティ
  final int maxAffinity; // 最大アフィニティ
  bool marriageAvailable; // 結婚可能か
  int bachelorDays; // 独身期間
  final List<String> traits; // 性質
  final String description; // 説明
  final String imageAsset; // 画像ファイル

  NPCProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.personality,
    required this.affinity,
    required this.maxAffinity,
    required this.marriageAvailable,
    required this.bachelorDays,
    required this.traits,
    required this.description,
    required this.imageAsset,
  });

  /// アフィニティレベルを取得
  int getAffinityLevel() {
    if (affinity < 20) return 1; // 親友以下
    if (affinity < 40) return 2; // 友達
    if (affinity < 60) return 3; // 親友
    if (affinity < 80) return 4; // 想い人
    return 5; // 真の愛
  }

  /// アフィニティの説明を取得
  String getAffinityDescription() {
    switch (getAffinityLevel()) {
      case 1:
        return 'Acquaintance';
      case 2:
        return 'Friend';
      case 3:
        return 'Close Friend';
      case 4:
        return 'Love Interest';
      case 5:
        return 'True Love';
      default:
        return 'Unknown';
    }
  }
}

/// 結婚候補者
class MarriageCandidate {
  final String npcId;
  final int minimumAffinity; // 最小アフィニティ
  final int requiredLevel; // 必要レベル
  final int requiredGold; // 必要ゴールド
  final List<String> preferredTraits; // 好みの性質
  final Map<String, int> marriageBonuses; // 結婚ボーナス
  final List<String> preferredGifts; // 好みのギフト
  final String specialEventId; // 特別イベントID

  MarriageCandidate({
    required this.npcId,
    required this.minimumAffinity,
    required this.requiredLevel,
    required this.requiredGold,
    required this.preferredTraits,
    required this.marriageBonuses,
    required this.preferredGifts,
    required this.specialEventId,
  });
}

/// 結婚イベント
class MarriageEvent {
  final String id;
  final String npcId;
  final MarriageEventType eventType;
  final String storyText; // イベントストーリー
  bool requirementsMet; // 条件満たしたか
  final int rewardGold; // 報酬ゴールド
  final int rewardXP; // 報酬経験値
  final bool unlockFamily; // 家族機能をアンロック

  MarriageEvent({
    required this.id,
    required this.npcId,
    required this.eventType,
    required this.storyText,
    required this.requirementsMet,
    required this.rewardGold,
    required this.rewardXP,
    required this.unlockFamily,
  });
}

/// 結婚イベントタイプ
enum MarriageEventType {
  meetingNPC, // NPC出会い
  gifting, // プレゼント
  dateNight, // デート
  proposal, // プロポーズ
  wedding, // 結婚式
  birth, // 出産
  anniversary, // 結婚記念日
  holiday, // 休日
}

/// 子供クラス
class Child {
  final String id;
  final String name;
  final String parentPlayerId;
  final String parentNpcId;
  int ageInDays; // 日数での年齢
  final List<String> traits; // 子供の性質
  int health; // 健康度
  int happiness; // 幸福度
  int educationLevel; // 教育レベル

  Child({
    required this.id,
    required this.name,
    required this.parentPlayerId,
    required this.parentNpcId,
    required this.ageInDays,
    required this.traits,
    required this.health,
    required this.happiness,
    required this.educationLevel,
  });

  /// 子供の年齢を取得
  int getAgeInYears() {
    return ageInDays ~/ 365;
  }

  /// 子供が大人か確認
  bool isAdult() {
    return getAgeInYears() >= 18;
  }

  /// 相続が可能か確認
  bool canInherit() {
    return isAdult() && health > 50 && happiness > 40;
  }
}

/// 家族の絆
class FamilyBond {
  final String id;
  final String playerId;
  final String memberId; // 家族メンバーID (子供またはNPC)
  int bondStrength; // 絆の強さ (0-100)
  int interactionCount; // 相互作用の回数
  final int createdAt;

  FamilyBond({
    required this.id,
    required this.playerId,
    required this.memberId,
    required this.bondStrength,
    required this.interactionCount,
    required this.createdAt,
  });

  /// 絆レベルを取得
  int getBondLevel() {
    if (bondStrength < 20) return 1;
    if (bondStrength < 40) return 2;
    if (bondStrength < 60) return 3;
    if (bondStrength < 80) return 4;
    return 5;
  }
}

/// 性別
enum Gender {
  male,
  female,
}

/// 性格タイプ
enum Personality {
  gentle, // 優しい
  energetic, // 元気
  mysterious, // 神秘的
  stoic, // 沈着
  mischievous, // いたずら好き
}
