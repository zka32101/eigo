/// 取引・経済システム例
/// マーケットプレイス、オークション、価格トレンド、NPC商人との取引

import 'package:flutter/material.dart';
import '../models/trading_economy_system.dart';
import '../models/auction_system.dart';

void main() {
  runApp(const TradingEconomyExample());
}

class TradingEconomyExample extends StatefulWidget {
  const TradingEconomyExample({Key? key}) : super(key: key);

  @override
  State<TradingEconomyExample> createState() => _TradingEconomyExampleState();
}

class _TradingEconomyExampleState extends State<TradingEconomyExample> {
  final tradingSystem = TradingEconomySystem.getInstance();
  final auctionSystem = AuctionSystem.getInstance();
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    tradingSystem.initialize();
    auctionSystem.initialize();
    _initializeDemoData();
  }

  void _initializeDemoData() {
    // デモ用マーケットプレイス出品
    tradingSystem.listItemForSale(
      'player_001',
      'iron_sword',
      2,
      150,
    );
    tradingSystem.listItemForSale(
      'player_002',
      'health_potion',
      10,
      50,
    );

    // デモ用オークション作成
    auctionSystem.createAuction(
      'player_003',
      'rare_artifact',
      1,
      500,
      24,
      1500,
    );
    auctionSystem.createAuction(
      'player_004',
      'enchanted_armor',
      1,
      800,
      48,
      2500,
    );

    // サンプル取引
    tradingSystem.buyFromMarketplace(
      'player_buyer',
      'iron_sword',
      1,
      5000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading Economy System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('取引・経済システム'),
          elevation: 0,
        ),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildMarketplaceTab(),
            _buildAuctionsTab(),
            _buildMerchantsTab(),
            _buildPriceAnalysisTab(),
            _buildHistoryTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              selectedTabIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'マーケット',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.gavel),
              label: 'オークション',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: '商人',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: '価格分析',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: '履歴',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    final listings = tradingSystem.getActiveMarketplaceListings();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'マーケットプレイス',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'アクティブな出品: ${listings.length}件',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...listings.map((listing) {
          final currentPrice = tradingSystem.getCurrentPrice(listing.itemId);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.itemId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '販売者: ${listing.sellerId}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${listing.askingPrice}G',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '市場価格: ${currentPrice}G',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('数量: ${listing.quantity}'),
                      ElevatedButton(
                        onPressed: () {
                          final success = tradingSystem.buyFromMarketplace(
                            'player_buyer',
                            listing.itemId,
                            listing.quantity,
                            5000,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? '購入しました' : '購入に失敗しました',
                              ),
                            ),
                          );
                        },
                        child: const Text('購入'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAuctionsTab() {
    final auctions = auctionSystem.getActiveAuctions();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'オークション',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'アクティブなオークション: ${auctions.length}件',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...auctions.map((auction) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auction.itemId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '開始価格: ${auction.startingBid}G',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '現在: ${auction.currentHighBid}G',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            auction.getRemainingTime(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (auction.buyoutPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'バイアウト: ${auction.buyoutPrice}G',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('数量: ${auction.quantity}'),
                      ElevatedButton(
                        onPressed: () {
                          final success = auctionSystem.placeBid(
                            'player_buyer',
                            auction.id,
                            auction.getMinimumNextBid(),
                            5000,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? '入札しました' : '入札に失敗しました',
                              ),
                            ),
                          );
                        },
                        child: const Text('入札'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMerchantsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NPC商人',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '各商人から商品を購入・販売できます',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildMerchantCard('Aria', 'magical', 'レベル 15', '評判: 75/100'),
        _buildMerchantCard('Kai', 'weapon', 'レベル 20', '評判: 85/100'),
        _buildMerchantCard('Zephyr', 'general', 'レベル 18', '評判: 80/100'),
        _buildMerchantCard('Luna', 'armor', 'レベル 19', '評判: 90/100'),
      ],
    );
  }

  Widget _buildMerchantCard(String name, String type, String level, String reputation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(level, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(reputation, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('購入'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sell),
                  label: const Text('販売'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAnalysisTab() {
    final priceHistory = tradingSystem.getPriceHistoriesForAnalysis();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '市場価格分析',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'リアルタイムの価格トレンドと需給分析',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPriceChartCard(
          'iron_sword',
          150,
          120,
          200,
          180,
          'rising',
          '↑ 上昇トレンド',
        ),
        _buildPriceChartCard(
          'health_potion',
          50,
          40,
          80,
          45,
          'falling',
          '↓ 下降トレンド',
        ),
        _buildPriceChartCard(
          'copper_ore',
          100,
          95,
          105,
          100,
          'stable',
          '→ 安定',
        ),
      ],
    );
  }

  Widget _buildPriceChartCard(
    String item,
    int current,
    int min,
    int max,
    int average,
    String trend,
    String trendLabel,
  ) {
    final trendColor = trend == 'rising'
        ? Colors.green
        : trend == 'falling'
            ? Colors.red
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trendLabel,
                    style: TextStyle(
                      color: trendColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceInfo('現在', current, Colors.blue),
                _buildPriceInfo('最低', min, Colors.green),
                _buildPriceInfo('最高', max, Colors.red),
                _buildPriceInfo('平均', average, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${value}G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '取引履歴',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'すべての取引記録を確認できます',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildHistoryItem(
          'マーケットプレイス',
          'iron_sword × 1',
          '購入者: player_buyer',
          '150G',
          Colors.blue,
          '2時間前',
        ),
        _buildHistoryItem(
          'NPC取引',
          'health_potion × 5',
          'Zephyr から購入',
          '250G',
          Colors.green,
          '1時間前',
        ),
        _buildHistoryItem(
          'プレイヤー間取引',
          'copper_ore × 10',
          'player_trader とトレード',
          '1000G',
          Colors.purple,
          '30分前',
        ),
        _buildHistoryItem(
          'オークション落札',
          'rare_artifact × 1',
          '売却者: player_003',
          '1200G',
          Colors.orange,
          '15分前',
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    String type,
    String item,
    String details,
    String price,
    Color color,
    String time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
