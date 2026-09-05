/// レイド・協力ダンジョンシステム例

import 'package:flutter/material.dart';
import '../models/raids_cooperative_system.dart';

void main() {
  runApp(const RaidsCooperativeExample());
}

class RaidsCooperativeExample extends StatefulWidget {
  const RaidsCooperativeExample({Key? key}) : super(key: key);

  @override
  State<RaidsCooperativeExample> createState() =>
      _RaidsCooperativeExampleState();
}

class _RaidsCooperativeExampleState extends State<RaidsCooperativeExample> {
  final system = RaidsCooperativeSystem.getInstance();
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    system.initialize();
    _addDemoRaids();
  }

  void _addDemoRaids() {
    // Create raid party
    system.createRaidParty(
      'party_001',
      'guild_adventurers',
      'player_001',
      ['player_001', 'player_002', 'player_003', 'player_004'],
    );

    // Start a raid
    system.startRaid(
      'raid_001',
      'dragon_overlord',
      'guild_adventurers',
      ['player_001', 'player_002', 'player_003', 'player_004'],
    );

    // Add contributions
    system.contributeToRaid('raid_001', 'player_001', 400, 0);
    system.contributeToRaid('raid_001', 'player_002', 350, 100);
    system.contributeToRaid('raid_001', 'player_003', 300, 200);
    system.contributeToRaid('raid_001', 'player_004', 250, 150);

    // Schedule a raid
    system.scheduleRaid(
      'schedule_001',
      'guild_adventurers',
      'shadow_titan',
      DateTime.now().millisecondsSinceEpoch + 7200000,
      ['player_001', 'player_002', 'player_003'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raids & Cooperative Dungeons',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('レイド・協力ダンジョンシステム')),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildRaidsTab(),
            _buildBossesTab(),
            _buildPartiesTab(),
            _buildLootTab(),
            _buildStatsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => selectedTabIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'レイド'),
            BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: 'ボス'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'パーティ'),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: '戦利品'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '統計'),
          ],
        ),
      ),
    );
  }

  Widget _buildRaidsTab() {
    final activeRaids = system.getActiveRaids();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アクティブなレイド',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${activeRaids.length}件進行中',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (activeRaids.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('アクティブなレイドがありません',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ),
          )
        else
          ...activeRaids.map((raid) {
            final boss = system.getBoss(raid.bossId);
            final elapsedTime = raid.getElapsedSeconds();

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
                              Text(boss?.name ?? 'Unknown Boss',
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('パーティ: ${raid.partyMembers.length}人',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '進行中',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ボスHP',
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('${raid.getBossHealthPercentage()}%',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: raid.getBossHealthPercentage() / 100,
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('パーティHP',
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('${raid.getPartyHealthPercentage()}%',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: raid.getPartyHealthPercentage() / 100,
                                minHeight: 8,
                                backgroundColor: Colors.red.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('経過: ${elapsedTime}秒',
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('ダメージ: ${raid.damageDealt}',
                            style: const TextStyle(fontSize: 11, color: Colors.red)),
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

  Widget _buildBossesTab() {
    final allBosses = system.getAllBosses();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('レイドボス',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${allBosses.length}体のボス',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...allBosses.map((boss) {
          final color = boss.difficulty >= 4
              ? Colors.red
              : boss.difficulty >= 3
                  ? Colors.orange
                  : Colors.yellow;

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
                            Text(boss.name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(boss.description,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          boss.getDifficultyLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('推奨レベル: ${boss.minPlayerLevel}',
                              style: const TextStyle(fontSize: 12)),
                          Text('HP: ${boss.hpPool}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('ダメージ: ${boss.damage}',
                              style: const TextStyle(fontSize: 12)),
                          Text('報酬: ${boss.rewards}G',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: boss.mechanics
                        .map((m) => Chip(
                              label: Text(m,
                                  style: const TextStyle(fontSize: 10)),
                              avatar: const Icon(Icons.flash_on, size: 16),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPartiesTab() {
    const parties = [
      {'name': 'Dragon Slayers', 'members': 4, 'completed': 12},
      {'name': 'Shadow Hunters', 'members': 5, 'completed': 8},
      {'name': 'Light Guardians', 'members': 3, 'completed': 15},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('レイドパーティ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${parties.length}個のパーティ',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...parties.map((party) {
          final completed = party['completed'] as int;
          final successRate = ((completed / (completed + 3)) * 100).toInt();

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
                          Text(party['name'].toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('メンバー: ${party['members']}人',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$successRate%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('完成: $completed回',
                          style: const TextStyle(fontSize: 12)),
                      Text('失敗: 3回',
                          style: const TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: successRate / 100,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLootTab() {
    final lootData = [
      {'player': 'player_001', 'item': '竜の剣', 'value': 500, 'rarity': 'legendary'},
      {'player': 'player_002', 'item': '影の兜', 'value': 400, 'rarity': 'epic'},
      {'player': 'player_003', 'item': '光の盾', 'value': 300, 'rarity': 'rare'},
      {'player': 'player_004', 'item': '天柔の鎧', 'value': 250, 'rarity': 'uncommon'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('レイド戦利品',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${lootData.length}件のドロップ',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...lootData.map((loot) {
          final rarityColors = {
            'legendary': Colors.amber,
            'epic': Colors.purple,
            'rare': Colors.blue,
            'uncommon': Colors.green,
          };

          final color = rarityColors[loot['rarity']] ?? Colors.grey;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loot['item'].toString(),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(loot['player'].toString(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          loot['rarity'].toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${loot['value']}G',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildStatsTab() {
    const playerStats = [
      {
        'player': 'player_001',
        'completed': 18,
        'damage': 6800,
        'loot': 2500,
      },
      {
        'player': 'player_002',
        'completed': 15,
        'damage': 5200,
        'loot': 1800,
      },
      {
        'player': 'player_003',
        'completed': 12,
        'damage': 4100,
        'loot': 1400,
      },
      {
        'player': 'player_004',
        'completed': 10,
        'damage': 3200,
        'loot': 900,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('プレイヤー統計',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${playerStats.length}人のレイダー',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...playerStats.map((stat) {
          final completed = stat['completed'] as int;
          final damage = stat['damage'] as int;

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
                      Text(stat['player'].toString(),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'レイドレベル ${(completed / 5).toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('完成: $completed回',
                              style: const TextStyle(fontSize: 12)),
                          Text('総ダメージ: $damage',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text('獲得: ${stat['loot']}G',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completed / 20,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
