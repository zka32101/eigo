/// 評判・影響力システム例

import 'package:flutter/material.dart';
import '../models/reputation_influence_system.dart';

void main() {
  runApp(const ReputationInfluenceExample());
}

class ReputationInfluenceExample extends StatefulWidget {
  const ReputationInfluenceExample({Key? key}) : super(key: key);

  @override
  State<ReputationInfluenceExample> createState() =>
      _ReputationInfluenceExampleState();
}

class _ReputationInfluenceExampleState
    extends State<ReputationInfluenceExample> {
  final system = ReputationInfluenceSystem.getInstance();
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    system.initialize();
    _addDemoData();
  }

  void _addDemoData() {
    system.changeReputation('mage_tower', 30, 'Completed Arcane Quest');
    system.changeReputation('adventurers_guild', 20, 'Joined Guild');
    system.changeReputation('merchant_cartel', 15, 'First Trade');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reputation & Influence System',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('評判・影響力システム')),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildOverviewTab(),
            _buildFactionsTab(),
            _buildShopsTab(),
            _buildHistoryTab(),
            _buildAccessTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => selectedTabIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '概要'),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: '派閥'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'ショップ'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
            BottomNavigationBarItem(icon: Icon(Icons.key), label: 'アクセス'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final allRep = system.getAllReputation();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('派閥評判概要',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...allRep.entries.map((e) {
                  final rank = system.getReputationRank(e.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(rank,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / 100,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('${e.value}/100',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFactionsTab() {
    final factions = ['mage_tower', 'adventurers_guild', 'merchant_cartel'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('派閥情報',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...factions.map((f) {
                  final rep = system.getPlayerReputation(f);
                  final allies = system.getAlliedFactions(f);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('評判: $rep/100',
                              style: const TextStyle(fontSize: 12)),
                          if (allies.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('同盟: ${allies.join(", ")}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.green)),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  system.changeReputation(f, 10, 'Test Action');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('+10'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  system.changeReputation(
                                      f, -5, 'Test Penalty');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.remove, size: 16),
                                label: const Text('-5'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopsTab() {
    final factions = ['mage_tower', 'adventurers_guild', 'merchant_cartel'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('評判ショップ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...factions
                    .map((f) => system.getShop(f))
                    .whereType<ReputationShop>()
                    .map((shop) {
                  final playerRep = system.getPlayerReputation(shop.factionId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shop.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...shop.items.map((item) {
                            final canBuy =
                                playerRep >= item.reputation && 5000 >= item.price;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style:
                                              const TextStyle(fontSize: 12)),
                                      Text(
                                          'req: ${item.reputation}, ${item.price}G',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        canBuy ? () {} : null,
                                    child: const Text('Buy'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final factions = ['mage_tower', 'adventurers_guild', 'merchant_cartel'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('評判履歴',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...factions.map((f) {
                  final history = system.getReputationHistory(f, limit: 5);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...history.map((e) {
                            final changeColor =
                                e.change > 0 ? Colors.green : Colors.red;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(e.reason,
                                        style: const TextStyle(fontSize: 11),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(
                                    '${e.change > 0 ? '+' : ''}${e.change}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: changeColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessTab() {
    final factions = ['mage_tower', 'adventurers_guild', 'merchant_cartel'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アクセス権',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...factions.map((f) {
                  final access = system.getPlayerAccessLevels(f);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: access.map((a) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(a.toString().split('.').last,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.green)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
