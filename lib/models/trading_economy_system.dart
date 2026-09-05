/// 取引・経済システム
/// マーケットプレイス、動的価格、サプライ・デマンド、商人シス テム

/// 取引・経済システム
class TradingEconomySystem {
  static final TradingEconomySystem _instance =
      TradingEconomySystem._internal();

  factory TradingEconomySystem.getInstance() {
    return _instance;
  }

  TradingEconomySystem._internal();

  // マーケットプレイス: item_id -> MarketplaceListing
  final Map<String, MarketplaceListing> _marketplaceListings = {};

  // 商人: merchant_id -> Merchant
  final Map<String, Merchant> _merchants = {};

  // プレイヤー取引履歴: player_id -> List<Transaction>
  final Map<String, List<Transaction>> _transactionHistory = {};

  // 価格履歴: item_id -> PriceHistory
  final Map<String, PriceHistory> _priceHistories = {};

  // サプライ・デマンド: item_id -> SupplyDemandData
  final Map<String, SupplyDemandData> _supplyDemandData = {};

  // プレイヤーの売却リスト: player_id -> List<String> (listing_ids)
  final Map<String, List<String>> _playerListings = {};

  /// システムを初期化
  void initialize() {
    _marketplaceListings.clear();
    _merchants.clear();
    _transactionHistory.clear();
    _priceHistories.clear();
    _supplyDemandData.clear();
    _playerListings.clear();
    _initializeAllMerchants();
    _initializeBaselinePrices();
  }

  /// すべての商人を初期化
  void _initializeAllMerchants() {
    // アリアの魔法店
    _registerMerchant(Merchant(
      id: 'merchant_aria',
      name: 'Aria',
      shopName: 'Aria\'s Arcane Emporium',
      location: 'Mage Tower',
      merchantType: MerchantType.specialist,
      specialization: ItemCategory.magical,
      level: 3,
      reputation: 85,
      baseMarkup: 1.15,
      maxInventory: 50,
      currentGold: 5000,
      inventory: {
        'mana_potion': 10,
        'ancient_tome': 3,
        'crystal': 5,
      },
      buyPrices: {'mana_potion': 25, 'crystal': 150},
      sellPrices: {'mana_potion': 40, 'crystal': 200},
    ));

    // カイの武器店
    _registerMerchant(Merchant(
      id: 'merchant_kai',
      name: 'Kai',
      shopName: 'Kai\'s Weaponry',
      location: 'Adventurers Village',
      merchantType: MerchantType.specialist,
      specialization: ItemCategory.weapon,
      level: 2,
      reputation: 70,
      baseMarkup: 1.20,
      maxInventory: 40,
      currentGold: 8000,
      inventory: {
        'iron_sword': 5,
        'steel_sword': 2,
        'wooden_shield': 8,
      },
      buyPrices: {'iron_sword': 80, 'wooden_shield': 30},
      sellPrices: {'iron_sword': 100, 'wooden_shield': 40},
    ));

    // ゼファーの一般商人
    _registerMerchant(Merchant(
      id: 'merchant_zephyr',
      name: 'Zephyr',
      shopName: 'Zephyr\'s Trading Post',
      location: 'Merchants City',
      merchantType: MerchantType.general,
      specialization: ItemCategory.materials,
      level: 4,
      reputation: 90,
      baseMarkup: 1.10,
      maxInventory: 100,
      currentGold: 15000,
      inventory: {
        'iron_ore': 20,
        'herbs': 15,
        'wood': 25,
        'bottle': 30,
      },
      buyPrices: {
        'iron_ore': 20,
        'herbs': 10,
        'wood': 5,
        'bottle': 2,
      },
      sellPrices: {
        'iron_ore': 25,
        'herbs': 15,
        'wood': 8,
        'bottle': 3,
      },
    ));

    // ルナの防具店
    _registerMerchant(Merchant(
      id: 'merchant_luna',
      name: 'Luna',
      shopName: 'Luna\'s Armor Haven',
      location: 'Adventurers Village',
      merchantType: MerchantType.specialist,
      specialization: ItemCategory.armor,
      level: 2,
      reputation: 75,
      baseMarkup: 1.18,
      maxInventory: 35,
      currentGold: 6000,
      inventory: {
        'leather_armor': 4,
        'iron_armor': 2,
        'leather_helmet': 6,
      },
      buyPrices: {'leather_armor': 60, 'iron_armor': 180},
      sellPrices: {'leather_armor': 80, 'iron_armor': 250},
    ));
  }

  /// ベース価格を初期化
  void _initializeBaselinePrices() {
    final baseItems = [
      ('iron_sword', 100),
      ('steel_sword', 300),
      ('leather_armor', 80),
      ('iron_armor', 250),
      ('health_potion', 25),
      ('mana_potion', 40),
      ('iron_ore', 25),
      ('herbs', 15),
      ('crystal', 200),
      ('wood', 8),
    ];

    for (final (itemId, basePrice) in baseItems) {
      _priceHistories[itemId] = PriceHistory(
        itemId: itemId,
        currentPrice: basePrice,
        averagePrice: basePrice,
        minPrice: (basePrice * 0.8).toInt(),
        maxPrice: (basePrice * 1.5).toInt(),
        priceHistory: [basePrice],
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      _supplyDemandData[itemId] = SupplyDemandData(
        itemId: itemId,
        supply: 50,
        demand: 40,
        marketPrice: basePrice,
        priceMultiplier: 1.0,
        trend: PriceTrend.stable,
      );
    }
  }

  /// 商人を登録
  void _registerMerchant(Merchant merchant) {
    _merchants[merchant.id] = merchant;
  }

  /// マーケットプレイスにアイテムをリスト
  bool listItemForSale(
    String playerId,
    String itemId,
    int quantity,
    int askingPrice,
  ) {
    if (quantity <= 0 || askingPrice < 0) return false;

    final listingId = '${playerId}_${itemId}_${DateTime.now().millisecondsSinceEpoch}';
    final listing = MarketplaceListing(
      id: listingId,
      sellerId: playerId,
      itemId: itemId,
      quantity: quantity,
      askingPrice: askingPrice,
      listingTime: DateTime.now().millisecondsSinceEpoch,
      expiresAt: DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch,
      status: ListingStatus.active,
    );

    _marketplaceListings[listingId] = listing;
    _playerListings.putIfAbsent(playerId, () => []);
    _playerListings[playerId]!.add(listingId);

    // サプライを更新
    _updateSupplyDemand(itemId, quantity, SupplyDemandChange.increase);

    return true;
  }

  /// マーケットプレイスからアイテムを削除
  bool removeListingFromMarketplace(String listingId, String playerId) {
    final listing = _marketplaceListings[listingId];
    if (listing == null || listing.sellerId != playerId) return false;

    listing.status = ListingStatus.cancelled;

    // サプライを更新
    _updateSupplyDemand(listing.itemId, listing.quantity, SupplyDemandChange.decrease);

    return true;
  }

  /// マーケットプレイスからアイテムを購入
  bool buyFromMarketplace(
    String buyerId,
    String listingId,
    int quantity,
    int buyerGold,
  ) {
    final listing = _marketplaceListings[listingId];
    if (listing == null || listing.status != ListingStatus.active) return false;

    final totalCost = listing.askingPrice * quantity;
    if (buyerGold < totalCost || quantity > listing.quantity) return false;

    listing.quantity -= quantity;
    if (listing.quantity <= 0) {
      listing.status = ListingStatus.sold;
    }

    // トランザクション履歴を記録
    _recordTransaction(
      TransactionType.marketplace,
      buyerId,
      listing.sellerId,
      listing.itemId,
      quantity,
      listing.askingPrice,
    );

    // デマンドを更新
    _updateSupplyDemand(listing.itemId, quantity, SupplyDemandChange.decrease);

    return true;
  }

  /// 商人から購入
  bool buyFromMerchant(
    String playerId,
    String merchantId,
    String itemId,
    int quantity,
    int playerGold,
  ) {
    final merchant = _merchants[merchantId];
    if (merchant == null) return false;

    final itemQty = merchant.inventory[itemId] ?? 0;
    if (itemQty < quantity) return false;

    final price = (merchant.sellPrices[itemId] ?? 100) * quantity;
    if (playerGold < price) return false;

    merchant.inventory[itemId] = itemQty - quantity;
    merchant.currentGold += price;

    // トランザクション履歴を記録
    _recordTransaction(
      TransactionType.npc_trade,
      playerId,
      merchantId,
      itemId,
      quantity,
      merchant.sellPrices[itemId] ?? 100,
    );

    return true;
  }

  /// 商人に売却
  bool sellToMerchant(
    String playerId,
    String merchantId,
    String itemId,
    int quantity,
  ) {
    final merchant = _merchants[merchantId];
    if (merchant == null) return false;

    final buyPrice = merchant.buyPrices[itemId] ?? 0;
    if (buyPrice == 0) return false;

    final totalPayment = buyPrice * quantity;
    if (merchant.currentGold < totalPayment) return false;

    merchant.inventory[itemId] = (merchant.inventory[itemId] ?? 0) + quantity;
    merchant.currentGold -= totalPayment;

    // トランザクション履歴を記録
    _recordTransaction(
      TransactionType.npc_trade,
      merchantId,
      playerId,
      itemId,
      quantity,
      buyPrice,
    );

    return true;
  }

  /// プレイヤー間でトレード
  bool tradeWithPlayer(
    String player1Id,
    String player2Id,
    String itemId,
    int quantity,
    int pricePerItem,
    int player2Gold,
  ) {
    final totalCost = pricePerItem * quantity;
    if (player2Gold < totalCost) return false;

    // トランザクション履歴を記録
    _recordTransaction(
      TransactionType.player_trade,
      player1Id,
      player2Id,
      itemId,
      quantity,
      pricePerItem,
    );

    return true;
  }

  /// トランザクション履歴を記録
  void _recordTransaction(
    TransactionType type,
    String buyerId,
    String sellerId,
    String itemId,
    int quantity,
    int pricePerItem,
  ) {
    final transaction = Transaction(
      id: '${buyerId}_${sellerId}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      buyerId: buyerId,
      sellerId: sellerId,
      itemId: itemId,
      quantity: quantity,
      pricePerItem: pricePerItem,
      totalValue: pricePerItem * quantity,
    );

    _transactionHistory.putIfAbsent(buyerId, () => []);
    _transactionHistory[buyerId]!.add(transaction);
    _transactionHistory.putIfAbsent(sellerId, () => []);
    _transactionHistory[sellerId]!.add(transaction);
  }

  /// サプライ・デマンドを更新
  void _updateSupplyDemand(
    String itemId,
    int amount,
    SupplyDemandChange change,
  ) {
    final data = _supplyDemandData[itemId];
    if (data == null) return;

    if (change == SupplyDemandChange.increase) {
      data.supply += amount;
    } else {
      data.demand += amount;
    }

    // 価格を更新
    final ratio = data.demand / (data.supply + 1);
    data.priceMultiplier = ratio.clamp(0.5, 2.0);

    // 動向を判定
    if (ratio > 1.2) {
      data.trend = PriceTrend.rising;
    } else if (ratio < 0.8) {
      data.trend = PriceTrend.falling;
    } else {
      data.trend = PriceTrend.stable;
    }

    // 新しい市場価格を計算
    final priceHistory = _priceHistories[itemId];
    if (priceHistory != null) {
      final newPrice =
          (priceHistory.currentPrice * data.priceMultiplier).toInt();
      priceHistory.currentPrice = newPrice;
      priceHistory.priceHistory.add(newPrice);
      priceHistory.lastUpdated = DateTime.now().millisecondsSinceEpoch;

      // 平均価格を計算
      final avgPrice = priceHistory.priceHistory.fold<int>(
            0,
            (sum, price) => sum + price,
          ) ~/
          priceHistory.priceHistory.length;
      priceHistory.averagePrice = avgPrice;

      // 最小・最大価格を更新
      priceHistory.minPrice = priceHistory.priceHistory.reduce((a, b) => a < b ? a : b);
      priceHistory.maxPrice = priceHistory.priceHistory.reduce((a, b) => a > b ? a : b);
    }
  }

    /// 指定アイテムの現在価格を取得
  int getCurrentPrice(String itemId) {
    return _priceHistories[itemId]?.currentPrice ?? 100;
  }

  /// アクティブなマーケットプレイスリストを取得
  List<MarketplaceListing> getActiveListings() {
    return _marketplaceListings.values
        .where((l) => l.status == ListingStatus.active)
        .toList();
  }

  /// プレイヤーのリストを取得
  List<MarketplaceListing> getPlayerListings(String playerId) {
    final listingIds = _playerListings[playerId] ?? [];
    return listingIds
        .map((id) => _marketplaceListings[id])
        .whereType<MarketplaceListing>()
        .toList();
  }

  /// 商人を取得
  Merchant? getMerchant(String merchantId) {
    return _merchants[merchantId];
  }

  /// すべての商人を取得
  List<Merchant> getAllMerchants() {
    return _merchants.values.toList();
  }

  /// 価格履歴を取得
  PriceHistory? getPriceHistory(String itemId) {
    return _priceHistories[itemId];
  }

  /// トランザクション履歴を取得
  List<Transaction> getTransactionHistory(String playerId) {
    return _transactionHistory[playerId] ?? [];
  }

  /// サプライ・デマンドデータを取得
  SupplyDemandData? getSupplyDemandData(String itemId) {
    return _supplyDemandData[itemId];
  }

  /// 商人の在庫を更新
  bool updateMerchantInventory(
    String merchantId,
    String itemId,
    int quantity,
    bool isAddition,
  ) {
    final merchant = _merchants[merchantId];
    if (merchant == null) return false;

    if (isAddition) {
      merchant.inventory[itemId] = (merchant.inventory[itemId] ?? 0) + quantity;
    } else {
      final current = merchant.inventory[itemId] ?? 0;
      if (current < quantity) return false;
      merchant.inventory[itemId] = current - quantity;
    }

    return true;
  }
}

/// マーケットプレイスリスト
class MarketplaceListing {
  final String id;
  final String sellerId;
  final String itemId;
  int quantity;
  final int askingPrice;
  final int listingTime;
  final int expiresAt;
  ListingStatus status;

  MarketplaceListing({
    required this.id,
    required this.sellerId,
    required this.itemId,
    required this.quantity,
    required this.askingPrice,
    required this.listingTime,
    required this.expiresAt,
    required this.status,
  });

  /// リストが期限切れか
  bool isExpired() {
    return DateTime.now().millisecondsSinceEpoch > expiresAt;
  }

  /// リストの経過時間を取得
  int getAgeInHours() {
    return DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(listingTime))
        .inHours;
  }
}

/// 商人
class Merchant {
  final String id;
  final String name;
  final String shopName;
  final String location;
  final MerchantType merchantType;
  final ItemCategory specialization;
  int level;
  int reputation; // 0-100
  final double baseMarkup; // マークアップ率
  final int maxInventory;
  int currentGold;
  final Map<String, int> inventory;
  final Map<String, int> buyPrices;
  final Map<String, int> sellPrices;

  Merchant({
    required this.id,
    required this.name,
    required this.shopName,
    required this.location,
    required this.merchantType,
    required this.specialization,
    required this.level,
    required this.reputation,
    required this.baseMarkup,
    required this.maxInventory,
    required this.currentGold,
    required this.inventory,
    required this.buyPrices,
    required this.sellPrices,
  });

  /// 評判レベルを取得
  int getReputationLevel() {
    if (reputation < 20) return 1;
    if (reputation < 40) return 2;
    if (reputation < 60) return 3;
    if (reputation < 80) return 4;
    return 5;
  }

  /// 在庫容量を使用中か確認
  bool isInventoryFull() {
    return inventory.values.fold(0, (sum, qty) => sum + qty) >= maxInventory;
  }

  /// 在庫使用率を取得
  double getInventoryUsagePercent() {
    final used = inventory.values.fold(0, (sum, qty) => sum + qty);
    return (used / maxInventory) * 100;
  }
}

/// トランザクション
class Transaction {
  final String id;
  final TransactionType type;
  final int timestamp;
  final String buyerId;
  final String sellerId;
  final String itemId;
  final int quantity;
  final int pricePerItem;
  final int totalValue;

  Transaction({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.buyerId,
    required this.sellerId,
    required this.itemId,
    required this.quantity,
    required this.pricePerItem,
    required this.totalValue,
  });

  /// トランザクションの経過時間を取得
  int getAgeInMinutes() {
    return DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(timestamp))
        .inMinutes;
  }
}

/// 価格履歴
class PriceHistory {
  final String itemId;
  int currentPrice;
  int averagePrice;
  int minPrice;
  int maxPrice;
  final List<int> priceHistory;
  int lastUpdated;

  PriceHistory({
    required this.itemId,
    required this.currentPrice,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.priceHistory,
    required this.lastUpdated,
  });

  /// 価格の変化率を計算
  double getPriceChangePercent() {
    if (priceHistory.length < 2) return 0.0;
    final previous = priceHistory[priceHistory.length - 2];
    return ((currentPrice - previous) / previous) * 100;
  }

  /// 価格トレンドを判定
  PriceTrend getTrend() {
    if (priceHistory.length < 2) return PriceTrend.stable;
    final change = getPriceChangePercent();
    if (change > 5) return PriceTrend.rising;
    if (change < -5) return PriceTrend.falling;
    return PriceTrend.stable;
  }
}

/// サプライ・デマンドデータ
class SupplyDemandData {
  final String itemId;
  int supply;
  int demand;
  int marketPrice;
  double priceMultiplier;
  PriceTrend trend;

  SupplyDemandData({
    required this.itemId,
    required this.supply,
    required this.demand,
    required this.marketPrice,
    required this.priceMultiplier,
    required this.trend,
  });

  /// サプライ・デマンド比を計算
  double getSupplyDemandRatio() {
    return (supply + 1) / (demand + 1);
  }

  /// 価格が上昇する可能性が高いか
  bool isPriceLikelyToRise() {
    return trend == PriceTrend.rising && priceMultiplier > 1.1;
  }

  /// 価格が下降する可能性が高いか
  bool isPriceLikelyToFall() {
    return trend == PriceTrend.falling && priceMultiplier < 0.9;
  }
}

/// リストステータス
enum ListingStatus {
  active,
  sold,
  cancelled,
  expired,
}

/// 商人タイプ
enum MerchantType {
  general, // 一般商人
  specialist, // 専門商人
  rare, // レアアイテム商人
  blackmarket, // ブラックマーケット
}

/// アイテムカテゴリー
enum ItemCategory {
  weapon,
  armor,
  accessory,
  consumable,
  materials,
  magical,
  quest,
}

/// トランザクションタイプ
enum TransactionType {
  marketplace, // マーケットプレイス
  npc_trade, // NPC取引
  player_trade, // プレイヤー間取引
  auction, // オークション
}

/// 価格トレンド
enum PriceTrend {
  rising, // 上昇
  falling, // 下降
  stable, // 安定
}

/// サプライ・デマンド変更
enum SupplyDemandChange {
  increase, // 増加
  decrease, // 減少
}
