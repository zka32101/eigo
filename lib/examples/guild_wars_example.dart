/// ギルド戦・領域戦システム例

import 'package:flutter/material.dart';
import '../models/guild_wars_system.dart';

void main() {
  runApp(const GuildWarsExample());
}

class GuildWarsExample extends StatefulWidget {
  const GuildWarsExample({Key? key}) : super(key: key);

  @override
  State<GuildWarsExample> createState() => _GuildWarsExampleState();
}

class _GuildWarsExampleState extends State<GuildWarsExample> {
  final system = GuildWarsSystem.getInstance();
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    system.initialize();
    _addDemoWars();
  }

  void _addDemoWars() {
    // Declare a war between guilds
    system.declareWar(
      'guild_adventurers',
      'guild_merchants',
      'commerce_harbor',
      24,
    );

    // Get the active wars to contribute to
    final activeWars = system.getActiveWars();
    if (activeWars.isNotEmpty) {
      final warId = activeWars.first.id;

      // Add player contributions
      system.contributeToWar(warId, 'player_001', 150, 50);
      system.contributeToWar(warId, 'player_002', 120, 80);
      system.contributeToWar(warId, 'player_003', 100, 40);
    }

    // Set up alliances
    system.setGuildAlliance('guild_mage_tower', 'guild_adventurers');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guild Wars & Territory System',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('ギルド戦・領域戦システム')),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildWarsTab(),
            _buildForcesTab(),
            _buildTerritoriesTab(),
            _buildContributionsTab(),
            _buildResultsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => selectedTabIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.sword), label: '戦争'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: '戦力'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: '領域'),
            BottomNavigationBarItem(
                icon: Icon(Icons.trending_up), label: '貢献'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: '結果'),
          ],
        ),
      ),
    );
  }

  Widget _buildWarsTab() {
    final activeWars = system.getActiveWars();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アクティブな戦争',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${activeWars.length}件の戦争が進行中',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (activeWars.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('アクティブな戦争がありません',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ),
          )
        else
          ...activeWars.map((war) {
            final attackerForce = system.getGuildForce(war.attackerGuildId);
            final defenderForce = system.getGuildForce(war.defenderGuildId);
            final elapsedHours = war.getElapsedHours();
            final progress = (elapsedHours / war.duration * 100).clamp(0, 100);

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
                              Text('${attackerForce?.guildName} vs ${defenderForce?.guildName}',
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('領域: ${war.territory}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '進行中',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
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
                        Text('${war.attackerScore}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const Text('vs'),
                        Text('${war.defenderScore}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$elapsedHours/${war.duration}時間経過 (${progress.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildForcesTab() {
    final mageForce = system.getGuildForce('guild_mage_tower');
    final adventurerForce = system.getGuildForce('guild_adventurers');
    final merchantForce = system.getGuildForce('guild_merchants');

    final forces = [mageForce, adventurerForce, merchantForce]
        .whereType<GuildForce>()
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ギルド戦力',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${forces.length}個のギルド登録',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...forces.map((force) {
          final powerLevel = force.getPowerLevel();
          final status = force.getStatus();
          final powerColor = force.totalPower > 1500
              ? Colors.amber
              : force.totalPower > 1000
                  ? Colors.orange
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(force.guildName,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('戦力レベル: $powerLevel',
                              style: TextStyle(
                                  fontSize: 12, color: powerColor)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
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
                          Text('メンバー: ${force.activeMembers}/${force.totalMembers}',
                              style: const TextStyle(fontSize: 12)),
                          Text('平均レベル: ${force.averageLevel}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('戦闘力: ${force.totalPower}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('士気: ${force.morale}/100',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: force.morale / 100,
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

  Widget _buildTerritoriesTab() {
    const territories = [
      'arcane_citadel',
      'martial_fortress',
      'commerce_harbor',
      'natural_forest',
      'mineral_canyon',
      'maritime_coast',
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
                const Text('領域支配',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${territories.length}つの領域',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...territories.map((territory) {
          final owner = system.getTerritoryOwner(territory);
          final control = system.getTerritoryControl(territory);
          final ownerGuild = system.getGuildForce(owner ?? '');

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
                          Text(territory,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('支配: ${ownerGuild?.guildName ?? "未支配"}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      if (control != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (control.isStableControl()
                                    ? Colors.green
                                    : Colors.orange)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            control.isStableControl()
                                ? '安定支配'
                                : '不安定',
                            style: TextStyle(
                              fontSize: 12,
                              color: control.isStableControl()
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (control != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('支配度: ${control.controlPercentage}%',
                            style: const TextStyle(fontSize: 12)),
                        Text('防御力: ${control.defensePower}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: control.controlPercentage / 100,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('支配期間: ${control.getControlDays()}日',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildContributionsTab() {
    final players = ['player_001', 'player_002', 'player_003'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('プレイヤー貢献度',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('戦争中の参加追跡',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...players.map((playerId) {
          final contributions = system.getPlayerContributions(playerId);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playerId,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (contributions.isEmpty)
                    Text('貢献記録がありません',
                        style: TextStyle(color: Colors.grey[600]))
                  else
                    ...contributions.map((contrib) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('戦争ID: ${contrib.warId}',
                                    style: const TextStyle(fontSize: 12)),
                                Text('スコア: ${contrib.score}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ダメージ: ${contrib.damageDealt}',
                                    style: const TextStyle(fontSize: 11, color: Colors.red)),
                                Text('回復: ${contrib.healingProvided}',
                                    style: const TextStyle(fontSize: 11, color: Colors.green)),
                              ],
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
    );
  }

  Widget _buildResultsTab() {
    const warResults = [
      {
        'warId': 'war_demo_001',
        'attacker': 'guild_adventurers',
        'defender': 'guild_merchants',
        'territory': 'commerce_harbor',
        'winner': 'guild_adventurers',
        'attackerScore': 850,
        'defenderScore': 620,
      },
      {
        'warId': 'war_demo_002',
        'attacker': 'guild_mage_tower',
        'defender': 'guild_adventurers',
        'territory': 'arcane_citadel',
        'winner': 'guild_mage_tower',
        'attackerScore': 920,
        'defenderScore': 780,
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
                const Text('戦争履歴',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${warResults.length}件の終了した戦争',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...warResults.map((result) {
          final winner = result['winner'];
          final attackerScore = int.parse(result['attackerScore'].toString());
          final defenderScore = int.parse(result['defenderScore'].toString());
          final totalScore = attackerScore + defenderScore;
          final attackerPercentage = (attackerScore / totalScore * 100).toInt();

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
                            Text('${result['attacker']} vs ${result['defender']}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('領域: ${result['territory']}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '終了',
                          style: TextStyle(
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
                      Text('$attackerScore',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const Text('vs'),
                      Text('$defenderScore',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: attackerPercentage / 100,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '勝者: ${result['winner']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
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
