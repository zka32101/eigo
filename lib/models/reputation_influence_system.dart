/// 評判・影響力システム
/// プレイヤー評判、NPC意見、政治的同盟

/// 評判・影響力システム
class ReputationInfluenceSystem {
  static final ReputationInfluenceSystem _instance =
      ReputationInfluenceSystem._internal();

  factory ReputationInfluenceSystem.getInstance() {
    return _instance;
  }

  ReputationInfluenceSystem._internal();

  // プレイヤー評判: faction_id -> reputation (0-100)
  final Map<String, int> _playerReputation = {};

  // NPC意見: npc_id -> Map<faction, opinion>
  final Map<String, Map<String, int>> _npcOpinions = {};

  // 同盟: faction_id -> allied_faction_ids
  final Map<String, List<String>> _alliances = {};

  // 敵対: faction_id -> enemy_faction_ids
  final Map<String, List<String>> _rivalries = {};

  // 評判ショップ: faction_id -> ReputationShop
  final Map<String, ReputationShop> _shops = {};

  // 評判イベント履歴
  final Map<String, List<ReputationEvent>> _eventHistory = {};

  // プレイヤーアクセス権: faction_id -> List<access_level>
  final Map<String, List<AccessLevel>> _playerAccess = {};

  /// システムを初期化
  void initialize() {
    _playerReputation.clear();
    _npcOpinions.clear();
    _alliances.clear();
    _rivalries.clear();
    _shops.clear();
    _eventHistory.clear();
    _playerAccess.clear();

    _initializeFactions();
    _initializeReputationShops();
    _initializeAlliances();
  }

  /// 派閥を初期化
  void _initializeFactions() {
    const factions = ['mage_tower', 'adventurers_guild', 'merchant_cartel'];

    for (final faction in factions) {
      _playerReputation[faction] = 0;
      _npcOpinions[faction] = {};
      _eventHistory[faction] = [];
      _playerAccess[faction] = [];
    }
  }

  /// 評判ショップを初期化
  void _initializeReputationShops() {
    _shops['mage_tower'] = ReputationShop(
      factionId: 'mage_tower',
      name: 'Arcane Circle',
      items: [
        ReputationItem(
          id: 'spell_tier2',
          name: 'Advanced Spell Tome',
          reputation: 30,
          price: 1000,
        ),
        ReputationItem(
          id: 'mana_ring',
          name: 'Mana Ring',
          reputation: 50,
          price: 2000,
        ),
        ReputationItem(
          id: 'spell_master',
          name: 'Master Spell Tome',
          reputation: 80,
          price: 5000,
        ),
      ],
    );

    _shops['adventurers_guild'] = ReputationShop(
      factionId: 'adventurers_guild',
      name: 'Guild Armory',
      items: [
        ReputationItem(
          id: 'advanced_bow',
          name: 'Advanced Bow',
          reputation: 30,
          price: 1200,
        ),
        ReputationItem(
          id: 'legendary_blade',
          name: 'Legendary Blade',
          reputation: 60,
          price: 3000,
        ),
        ReputationItem(
          id: 'god_armor',
          name: 'God Armor',
          reputation: 90,
          price: 8000,
        ),
      ],
    );

    _shops['merchant_cartel'] = ReputationShop(
      factionId: 'merchant_cartel',
      name: 'Merchant Exchange',
      items: [
        ReputationItem(
          id: 'trade_license',
          name: 'Trade License',
          reputation: 25,
          price: 800,
        ),
        ReputationItem(
          id: 'discount_card',
          name: 'VIP Discount Card',
          reputation: 50,
          price: 2000,
        ),
        ReputationItem(
          id: 'noble_status',
          name: 'Noble Merchant Status',
          reputation: 85,
          price: 6000,
        ),
      ],
    );
  }

  /// 同盟を初期化
  void _initializeAlliances() {
    // Mage Tower は Merchant Cartel と同盟
    _alliances['mage_tower'] = ['merchant_cartel'];
    _alliances['merchant_cartel'] = ['mage_tower'];

    // Adventurers Guild は独立
    _alliances['adventurers_guild'] = [];

    // 敵対関係
    _rivalries['mage_tower'] = [];
    _rivalries['merchant_cartel'] = [];
    _rivalries['adventurers_guild'] = [];
  }

  /// 評判を変更
  bool changeReputation(String factionId, int amount, String reason) {
    if (!_playerReputation.containsKey(factionId)) return false;

    final oldRep = _playerReputation[factionId]!;
    final newRep = (oldRep + amount).clamp(0, 100);
    _playerReputation[factionId] = newRep;

    // イベント記録
    _eventHistory[factionId]!.add(ReputationEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      change: amount,
      reason: reason,
      previousReputation: oldRep,
      newReputation: newRep,
    ));

    // アクセス権を更新
    _updateAccessLevels(factionId);

    // アライアンス効果を適用
    _applyAllianceEffects(factionId, amount);

    return true;
  }

  /// アクセス権を更新
  void _updateAccessLevels(String factionId) {
    final rep = _playerReputation[factionId]!;
    final access = <AccessLevel>[];

    if (rep >= 0) access.add(AccessLevel.neutral);
    if (rep >= 25) access.add(AccessLevel.acquaintance);
    if (rep >= 50) access.add(AccessLevel.trusted);
    if (rep >= 75) access.add(AccessLevel.honored);
    if (rep >= 90) access.add(AccessLevel.legend);

    _playerAccess[factionId] = access;
  }

  /// 同盟効果を適用
  void _applyAllianceEffects(String factionId, int amount) {
    final allies = _alliances[factionId] ?? [];
    for (final ally in allies) {
      // 同盟派閥へ50%の評判ボーナス
      final allyAmount = (amount * 0.5).toInt();
      if (_playerReputation.containsKey(ally)) {
        _playerReputation[ally] =
            (_playerReputation[ally]! + allyAmount).clamp(0, 100);
      }
    }
  }

  /// NPC意見を取得
  int getNPCOpinion(String npcId, String factionId) {
    if (!_npcOpinions.containsKey(npcId)) {
      _npcOpinions[npcId] = {};
    }
    return _npcOpinions[npcId]![factionId] ?? 50;
  }

  /// NPC意見を設定
  void setNPCOpinion(String npcId, String factionId, int opinion) {
    if (!_npcOpinions.containsKey(npcId)) {
      _npcOpinions[npcId] = {};
    }
    _npcOpinions[npcId]![factionId] = opinion.clamp(0, 100);
  }

  /// クエストにアクセス可能か確認
  bool canAccessQuest(String factionId, int requiredReputation) {
    final playerRep = _playerReputation[factionId] ?? 0;
    return playerRep >= requiredReputation;
  }

  /// エリアにアクセス可能か確認
  bool canAccessArea(String factionId, int requiredReputation) {
    final playerRep = _playerReputation[factionId] ?? 0;
    return playerRep >= requiredReputation;
  }

  /// 評判ショップから購入
  bool purchaseFromShop(
    String factionId,
    String itemId,
    int playerGold,
  ) {
    final shop = _shops[factionId];
    if (shop == null) return false;

    final item = shop.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    final playerRep = _playerReputation[factionId] ?? 0;
    if (playerRep < item.reputation || playerGold < item.price) {
      return false;
    }

    // 購入成功
    _playerReputation[factionId] = playerRep - 5; // 評判コスト
    return true;
  }

  /// プレイヤー評判を取得
  int getPlayerReputation(String factionId) {
    return _playerReputation[factionId] ?? 0;
  }

  /// プレイヤーアクセスレベルを取得
  List<AccessLevel> getPlayerAccessLevels(String factionId) {
    return _playerAccess[factionId] ?? [];
  }

  /// 評判ランクを取得
  String getReputationRank(String factionId) {
    final rep = _playerReputation[factionId] ?? 0;

    if (rep < 0) return '敵対';
    if (rep < 25) return '中立';
    if (rep < 50) return '知人';
    if (rep < 75) return '信頼';
    if (rep < 90) return '尊敬';
    return '伝説';
  }

  /// 評判イベント履歴を取得
  List<ReputationEvent> getReputationHistory(String factionId, {int limit = 20}) {
    return (_eventHistory[factionId] ?? []).reversed.take(limit).toList();
  }

  /// 同盟派閥を取得
  List<String> getAlliedFactions(String factionId) {
    return _alliances[factionId] ?? [];
  }

  /// 敵対派閥を取得
  List<String> getRivalFactions(String factionId) {
    return _rivalries[factionId] ?? [];
  }

  /// 評判ショップを取得
  ReputationShop? getShop(String factionId) {
    return _shops[factionId];
  }

  /// すべての派閥の評判を取得
  Map<String, int> getAllReputation() {
    return Map.from(_playerReputation);
  }

  /// 派閥情報レポートを取得
  String getFactionReport(String factionId) {
    final rep = _playerReputation[factionId] ?? 0;
    final rank = getReputationRank(factionId);
    final access = _playerAccess[factionId] ?? [];
    final allies = _alliances[factionId] ?? [];
    final rivals = _rivalries[factionId] ?? [];

    return '''
Faction: $factionId
Reputation: $rep/100
Rank: $rank

Access Levels: ${access.length}
Allied Factions: ${allies.isEmpty ? 'None' : allies.join(', ')}
Rival Factions: ${rivals.isEmpty ? 'None' : rivals.join(', ')}
''';
  }
}

/// 評判イベント
class ReputationEvent {
  final int timestamp;
  final int change;
  final String reason;
  final int previousReputation;
  final int newReputation;

  ReputationEvent({
    required this.timestamp,
    required this.change,
    required this.reason,
    required this.previousReputation,
    required this.newReputation,
  });

  /// イベントの説明を取得
  String getDescription() {
    final changeStr = change > 0 ? '+$change' : '$change';
    return '$reason ($changeStr)';
  }
}

/// アクセスレベル
enum AccessLevel {
  neutral, // 中立
  acquaintance, // 知人
  trusted, // 信頼
  honored, // 尊敬
  legend, // 伝説
}

/// 評判ショップ
class ReputationShop {
  final String factionId;
  final String name;
  final List<ReputationItem> items;

  ReputationShop({
    required this.factionId,
    required this.name,
    required this.items,
  });

  /// ショップ説明を取得
  String getDescription() {
    return 'Exclusive items for $factionId members';
  }
}

/// 評判アイテム
class ReputationItem {
  final String id;
  final String name;
  final int reputation; // 必要な評判
  final int price; // 価格

  ReputationItem({
    required this.id,
    required this.name,
    required this.reputation,
    required this.price,
  });

  /// アイテムが購入可能か確認
  bool isPurchasable(int playerReputation, int playerGold) {
    return playerReputation >= reputation && playerGold >= price;
  }
}
