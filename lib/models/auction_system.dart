/// オークションシステム
/// 入札管理、オークションライフサイクル、手数料システム

/// オークションシステム
class AuctionSystem {
  static final AuctionSystem _instance = AuctionSystem._internal();

  factory AuctionSystem.getInstance() {
    return _instance;
  }

  AuctionSystem._internal();

  // オークション: auction_id -> Auction
  final Map<String, Auction> _auctions = {};

  // 入札: auction_id -> List<Bid>
  final Map<String, List<Bid>> _auctionBids = {};

  // プレイヤーのオークション: player_id -> List<auction_id>
  final Map<String, List<String>> _playerAuctions = {};

  // プレイヤーの入札: player_id -> List<auction_id>
  final Map<String, List<String>> _playerBids = {};

  // オークション履歴: auction_id -> AuctionResult
  final Map<String, AuctionResult> _auctionHistory = {};

  /// システムを初期化
  void initialize() {
    _auctions.clear();
    _auctionBids.clear();
    _playerAuctions.clear();
    _playerBids.clear();
    _auctionHistory.clear();
  }

  /// オークションを作成
  bool createAuction(
    String sellerId,
    String itemId,
    int quantity,
    int startingBid,
    int durationHours,
    int? buyoutPrice,
  ) {
    if (quantity <= 0 || startingBid < 0 || durationHours <= 0) return false;

    final auctionId = '${sellerId}_${itemId}_${DateTime.now().millisecondsSinceEpoch}';
    final auction = Auction(
      id: auctionId,
      sellerId: sellerId,
      itemId: itemId,
      quantity: quantity,
      startingBid: startingBid,
      currentHighBid: 0,
      buyoutPrice: buyoutPrice,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      endsAt: DateTime.now().add(Duration(hours: durationHours)).millisecondsSinceEpoch,
      status: AuctionStatus.active,
      highestBidderId: null,
    );

    _auctions[auctionId] = auction;
    _auctionBids[auctionId] = [];
    _playerAuctions.putIfAbsent(sellerId, () => []);
    _playerAuctions[sellerId]!.add(auctionId);

    return true;
  }

  /// 入札をする
  bool placeBid(
    String bidderId,
    String auctionId,
    int bidAmount,
    int playerGold,
  ) {
    final auction = _auctions[auctionId];
    if (auction == null ||
        auction.status != AuctionStatus.active ||
        auction.isExpired()) {
      return false;
    }

    // 最小入札額をチェック
    final minimumBid = auction.currentHighBid == 0
        ? auction.startingBid
        : auction.currentHighBid + (auction.startingBid ~/ 10);

    if (bidAmount < minimumBid || playerGold < bidAmount) {
      return false;
    }

    // バイアウト価格をチェック
    if (auction.buyoutPrice != null && bidAmount >= auction.buyoutPrice!) {
      // バイアウト
      _executeAuctionBuyout(auction, bidderId, bidAmount);
      return true;
    }

    // 新しい入札を記録
    final bid = Bid(
      id: '${auctionId}_${bidderId}_${DateTime.now().millisecondsSinceEpoch}',
      auctionId: auctionId,
      bidderId: bidderId,
      bidAmount: bidAmount,
      bidTime: DateTime.now().millisecondsSinceEpoch,
    );

    _auctionBids[auctionId]!.add(bid);

    // 最高入札者を更新
    auction.currentHighBid = bidAmount;
    auction.highestBidderId = bidderId;

    // プレイヤーの入札リストに追加
    _playerBids.putIfAbsent(bidderId, () => []);
    if (!_playerBids[bidderId]!.contains(auctionId)) {
      _playerBids[bidderId]!.add(auctionId);
    }

    return true;
  }

  /// オークション終了をチェック
  List<String> checkExpiredAuctions() {
    final expiredAuctionIds = <String>[];

    for (final auction in _auctions.values) {
      if (auction.status == AuctionStatus.active && auction.isExpired()) {
        _endAuction(auction);
        expiredAuctionIds.add(auction.id);
      }
    }

    return expiredAuctionIds;
  }

  /// オークションを終了
  void _endAuction(Auction auction) {
    if (auction.highestBidderId == null) {
      // 誰も入札しなかった
      auction.status = AuctionStatus.unsold;
      _auctionHistory[auction.id] = AuctionResult(
        auctionId: auction.id,
        sellerId: auction.sellerId,
        winnerId: null,
        finalPrice: 0,
        itemId: auction.itemId,
        quantity: auction.quantity,
        endedAt: DateTime.now().millisecondsSinceEpoch,
        status: AuctionResultStatus.unsold,
      );
    } else {
      // 落札者がいる
      auction.status = AuctionStatus.sold;

      // 手数料を計算
      final commission = _calculateCommission(auction.currentHighBid);
      final sellerPayout = auction.currentHighBid - commission;

      _auctionHistory[auction.id] = AuctionResult(
        auctionId: auction.id,
        sellerId: auction.sellerId,
        winnerId: auction.highestBidderId,
        finalPrice: auction.currentHighBid,
        itemId: auction.itemId,
        quantity: auction.quantity,
        endedAt: DateTime.now().millisecondsSinceEpoch,
        status: AuctionResultStatus.sold,
        commission: commission,
        sellerPayout: sellerPayout,
      );
    }
  }

  /// オークションのバイアウト
  void _executeAuctionBuyout(
    Auction auction,
    String buyerId,
    int buyoutPrice,
  ) {
    auction.status = AuctionStatus.sold;
    auction.highestBidderId = buyerId;
    auction.currentHighBid = buyoutPrice;

    final commission = _calculateCommission(buyoutPrice);
    final sellerPayout = buyoutPrice - commission;

    _auctionHistory[auction.id] = AuctionResult(
      auctionId: auction.id,
      sellerId: auction.sellerId,
      winnerId: buyerId,
      finalPrice: buyoutPrice,
      itemId: auction.itemId,
      quantity: auction.quantity,
      endedAt: DateTime.now().millisecondsSinceEpoch,
      status: AuctionResultStatus.sold,
      commission: commission,
      sellerPayout: sellerPayout,
      wasBuyout: true,
    );
  }

  /// 手数料を計算
  int _calculateCommission(int salePrice) {
    // 基本手数料: 5%
    const baseCommissionRate = 0.05;
    return (salePrice * baseCommissionRate).toInt();
  }

  /// オークションをキャンセル
  bool cancelAuction(String auctionId, String playerId) {
    final auction = _auctions[auctionId];
    if (auction == null ||
        auction.sellerId != playerId ||
        auction.status != AuctionStatus.active) {
      return false;
    }

    // 入札がない場合のみキャンセル可能
    if ((auction.highestBidderId != null)) {
      return false;
    }

    auction.status = AuctionStatus.cancelled;
    return true;
  }

  /// オークションを取得
  Auction? getAuction(String auctionId) {
    return _auctions[auctionId];
  }

  /// アクティブなオークションを取得
  List<Auction> getActiveAuctions() {
    return _auctions.values
        .where((a) => a.status == AuctionStatus.active && !a.isExpired())
        .toList();
  }

  /// アイテムのオークションを検索
  List<Auction> searchAuctionsByItem(String itemId) {
    return _auctions.values
        .where((a) => a.itemId == itemId && a.status == AuctionStatus.active)
        .toList();
  }

  /// プレイヤーのオークションを取得
  List<Auction> getPlayerAuctions(String playerId) {
    final auctionIds = _playerAuctions[playerId] ?? [];
    return auctionIds
        .map((id) => _auctions[id])
        .whereType<Auction>()
        .toList();
  }

  /// プレイヤーの入札を取得
  List<Auction> getPlayerBids(String playerId) {
    final auctionIds = _playerBids[playerId] ?? [];
    return auctionIds
        .map((id) => _auctions[id])
        .whereType<Auction>()
        .toList();
  }

  /// オークションの入札を取得
  List<Bid> getAuctionBids(String auctionId) {
    return _auctionBids[auctionId] ?? [];
  }

  /// オークション履歴を取得
  AuctionResult? getAuctionResult(String auctionId) {
    return _auctionHistory[auctionId];
  }

  /// プレイヤーのオークション履歴を取得
  List<AuctionResult> getPlayerAuctionHistory(String playerId) {
    return _auctionHistory.values
        .where((r) => r.sellerId == playerId || r.winnerId == playerId)
        .toList();
  }
}

/// オークション
class Auction {
  final String id;
  final String sellerId;
  final String itemId;
  final int quantity;
  final int startingBid;
  int currentHighBid;
  final int? buyoutPrice;
  final int createdAt;
  final int endsAt;
  AuctionStatus status;
  String? highestBidderId;

  Auction({
    required this.id,
    required this.sellerId,
    required this.itemId,
    required this.quantity,
    required this.startingBid,
    required this.currentHighBid,
    required this.buyoutPrice,
    required this.createdAt,
    required this.endsAt,
    required this.status,
    required this.highestBidderId,
  });

  /// オークションが期限切れか確認
  bool isExpired() {
    return DateTime.now().millisecondsSinceEpoch > endsAt;
  }

  /// 残り時間をスロット数で取得
  String getRemainingTime() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = endsAt - now;

    if (remaining < 0) return '期限切れ';

    final seconds = remaining ~/ 1000;
    if (seconds < 60) return '$seconds秒';

    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes分';

    final hours = minutes ~/ 60;
    if (hours < 24) return '${hours}時間';

    final days = hours ~/ 24;
    return '${days}日';
  }

  /// 入札段階を取得
  int getMinimumNextBid() {
    return currentHighBid == 0
        ? startingBid
        : currentHighBid + (startingBid ~/ 10);
  }
}

/// 入札
class Bid {
  final String id;
  final String auctionId;
  final String bidderId;
  final int bidAmount;
  final int bidTime;

  Bid({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.bidAmount,
    required this.bidTime,
  });
}

/// オークション結果
class AuctionResult {
  final String auctionId;
  final String sellerId;
  final String? winnerId;
  final int finalPrice;
  final String itemId;
  final int quantity;
  final int endedAt;
  final AuctionResultStatus status;
  final int? commission;
  final int? sellerPayout;
  final bool wasBuyout;

  AuctionResult({
    required this.auctionId,
    required this.sellerId,
    required this.winnerId,
    required this.finalPrice,
    required this.itemId,
    required this.quantity,
    required this.endedAt,
    required this.status,
    this.commission,
    this.sellerPayout,
    this.wasBuyout = false,
  });
}

/// オークションステータス
enum AuctionStatus {
  active,
  sold,
  unsold,
  cancelled,
}

/// オークション結果ステータス
enum AuctionResultStatus {
  sold,
  unsold,
  cancelled,
}
