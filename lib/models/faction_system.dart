/// ゲーム内ファクション/評判システム

class FactionSystem {
  static final FactionSystem _instance = FactionSystem._internal();

  factory FactionSystem.getInstance() {
    return _instance;
  }

  FactionSystem._internal();

  // プレイヤーの各ファクションに対する評判: 'faction_id' -> reputation
  final Map<String, int> _factionReputations = {};

  // 各ファクションの定義
  final Map<String, FactionData> _factions = {};

  /// システムを初期化
  void initialize() {
    _factionReputations.clear();
    _factions.clear();
    _initializeAllFactions();
  }

  /// すべてのファクションを初期化
  void _initializeAllFactions() {
    // 魔法使いの塔ファクション
    _registerFaction(FactionData(
      id: 'mage_tower',
      name: 'Mage Tower Collective',
      description: 'The prestigious magical research organization',
      region: 'Mage Tower',
      relatedNPCs: ['aria_001', 'luna_002', 'morvan_003'],
      perks: [
        FactionPerk(
          id: 'spell_discount',
          name: 'Spell Discount',
          description: 'Get 10% discount on spells',
          requiredReputation: 30,
        ),
        FactionPerk(
          id: 'advanced_spells',
          name: 'Advanced Magic Access',
          description: 'Learn advanced magical spells',
          requiredReputation: 60,
        ),
        FactionPerk(
          id: 'arcane_mastery',
          name: 'Arcane Mastery',
          description: 'Master all magical arts',
          requiredReputation: 90,
        ),
      ],
    ));

    // 冒険者の村ファクション
    _registerFaction(FactionData(
      id: 'adventurers_guild',
      name: 'Adventurers Guild',
      description: 'The legendary guild of brave adventurers',
      region: 'Adventurers Village',
      relatedNPCs: ['kai_004', 'eloise_005', 'thorn_006'],
      perks: [
        FactionPerk(
          id: 'guild_missions',
          name: 'Guild Missions Access',
          description: 'Take on exclusive guild missions',
          requiredReputation: 20,
        ),
        FactionPerk(
          id: 'combat_training',
          name: 'Combat Training',
          description: 'Receive advanced combat training',
          requiredReputation: 50,
        ),
        FactionPerk(
          id: 'legendary_equipment',
          name: 'Legendary Equipment',
          description: 'Access to legendary weapons and armor',
          requiredReputation: 80,
        ),
      ],
    ));

    // 商人の街ファクション
    _registerFaction(FactionData(
      id: 'merchant_cartel',
      name: 'Merchant Cartel',
      description: 'The influential trade organization',
      region: 'Merchants City',
      relatedNPCs: ['zephyr_007', 'mae_008', 'oliver_009', 'isabella_010'],
      perks: [
        FactionPerk(
          id: 'trading_discount',
          name: 'Trading Discount',
          description: 'Get better prices on trades',
          requiredReputation: 25,
        ),
        FactionPerk(
          id: 'business_partnership',
          name: 'Business Partnership',
          description: 'Become a business partner',
          requiredReputation: 55,
        ),
        FactionPerk(
          id: 'trade_monopoly',
          name: 'Trade Monopoly Control',
          description: 'Control trade routes and prices',
          requiredReputation: 85,
        ),
      ],
    ));
  }

  /// ファクションを登録
  void _registerFaction(FactionData faction) {
    _factions[faction.id] = faction;
    _factionReputations[faction.id] = 0; // デフォルト評判: 0
  }

  /// ファクションを取得
  FactionData? getFaction(String factionId) {
    return _factions[factionId];
  }

  /// すべてのファクションを取得
  List<FactionData> getAllFactions() {
    return _factions.values.toList();
  }

  /// ファクション評判を取得
  int getReputation(String factionId) {
    return _factionReputations[factionId] ?? 0;
  }

  /// ファクション評判を更新
  void updateReputation(String factionId, int delta) {
    final current = getReputation(factionId);
    final newValue = (current + delta).clamp(-100, 100);
    _factionReputations[factionId] = newValue;
  }

  /// 評判ステータスを取得
  String getReputationStatus(String factionId) {
    final reputation = getReputation(factionId);

    if (reputation >= 80) return 'revered';
    if (reputation >= 50) return 'honored';
    if (reputation >= 20) return 'liked';
    if (reputation >= -20) return 'neutral';
    if (reputation >= -50) return 'disliked';
    return 'hated';
  }

  /// 利用可能なパークを取得
  List<FactionPerk> getAvailablePerks(String factionId) {
    final faction = getFaction(factionId);
    if (faction == null) return [];

    final reputation = getReputation(factionId);
    return faction.perks
        .where((perk) => reputation >= perk.requiredReputation)
        .toList();
  }

  /// パークが利用可能かチェック
  bool hasPerkAccess(String factionId, String perkId) {
    final perks = getAvailablePerks(factionId);
    return perks.any((p) => p.id == perkId);
  }

  /// 関連するNPCを取得
  List<String> getRelatedNPCs(String factionId) {
    final faction = getFaction(factionId);
    return faction?.relatedNPCs ?? [];
  }

  /// NPCが属するファクションを取得
  List<String> getNPCFactions(String npcId) {
    final factions = <String>[];
    _factions.forEach((factionId, faction) {
      if (faction.relatedNPCs.contains(npcId)) {
        factions.add(factionId);
      }
    });
    return factions;
  }

  /// ファクション評判の詳細情報を取得
  FactionStatus getFactionStatus(String factionId) {
    final faction = getFaction(factionId);
    if (faction == null) {
      return FactionStatus(
        factionId: factionId,
        reputation: 0,
        status: 'unknown',
      );
    }

    return FactionStatus(
      factionId: factionId,
      factionName: faction.name,
      reputation: getReputation(factionId),
      status: getReputationStatus(factionId),
      availablePerks: getAvailablePerks(factionId),
    );
  }

  /// すべてのファクション評判を取得
  Map<String, int> getAllReputations() {
    return Map.from(_factionReputations);
  }
}

/// ファクションデータ
class FactionData {
  final String id;
  final String name;
  final String description;
  final String region;
  final List<String> relatedNPCs; // このファクションに属するNPCのID
  final List<FactionPerk> perks; // 利用可能なパーク

  FactionData({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.relatedNPCs,
    required this.perks,
  });

  String getDisplayName() => name;
}

/// ファクションパーク
class FactionPerk {
  final String id;
  final String name;
  final String description;
  final int requiredReputation;

  FactionPerk({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredReputation,
  });

  @override
  String toString() => '$name (Requires $requiredReputation reputation)';
}

/// ファクションステータス
class FactionStatus {
  final String factionId;
  final String? factionName;
  final int reputation;
  final String status; // 'revered', 'honored', 'liked', 'neutral', 'disliked', 'hated'
  final List<FactionPerk> availablePerks;

  FactionStatus({
    required this.factionId,
    this.factionName,
    required this.reputation,
    required this.status,
    this.availablePerks = const [],
  });

  String getStatusText() {
    switch (status) {
      case 'revered':
        return 'Revered: They respect you greatly';
      case 'honored':
        return 'Honored: They hold you in high regard';
      case 'liked':
        return 'Liked: They view you favorably';
      case 'neutral':
        return 'Neutral: No strong feelings either way';
      case 'disliked':
        return 'Disliked: They view you unfavorably';
      case 'hated':
        return 'Hated: They despise you';
      default:
        return 'Unknown: No reputation established';
    }
  }

  String getProgressBar() {
    final bars = (reputation + 100) ~/ 20; // -100 to 100 -> 0 to 10
    final filled = '█' * bars.clamp(0, 10);
    final empty = '░' * (10 - bars.clamp(0, 10));
    return '[$filled$empty]';
  }
}
