/// ダンジョン探索システムの対話的な例
/// ダンジョン管理、敵エンカウンター、報酬表示

import 'package:flutter/material.dart';

/// ダンジョン探索の例
class DungeonExplorationExample extends StatefulWidget {
  const DungeonExplorationExample({Key? key}) : super(key: key);

  @override
  State<DungeonExplorationExample> createState() =>
      _DungeonExplorationExampleState();
}

class _DungeonExplorationExampleState extends State<DungeonExplorationExample> {
  int _selectedTabIndex = 0;
  int _currentFloor = 1;
  bool _inCombat = false;
  int _playerHealth = 100;
  int _enemyHealth = 50;

  final List<String> _tabNames = [
    'Dungeons',
    'Current',
    'Enemies',
    'Rewards',
    'Stats',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dungeon Exploration System'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // タブバー
          Container(
            color: Colors.grey[900],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _tabNames.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      color: _selectedTabIndex == index
                          ? Colors.purple
                          : Colors.transparent,
                      child: Text(
                        _tabNames[index],
                        style: TextStyle(
                          color: _selectedTabIndex == index
                              ? Colors.white
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // コンテンツエリア
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  /// タブのコンテンツを構築
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDungeonsTab();
      case 1:
        return _buildCurrentTab();
      case 2:
        return _buildEnemiesTab();
      case 3:
        return _buildRewardsTab();
      case 4:
        return _buildStatsTab();
      default:
        return const SizedBox();
    }
  }

  /// ダンジョンタブ
  Widget _buildDungeonsTab() {
    final dungeons = [
      {
        'name': 'Arcane Research Facility',
        'difficulty': 'Easy',
        'level': 5,
        'floors': 5,
        'reward': 500,
        'region': 'Mage Tower',
      },
      {
        'name': 'Crystal Mines',
        'difficulty': 'Medium',
        'level': 15,
        'floors': 8,
        'reward': 1200,
        'region': 'Crystal Mountains',
      },
      {
        'name': 'Ancient Forest Ruins',
        'difficulty': 'Hard',
        'level': 25,
        'floors': 10,
        'reward': 2000,
        'region': 'Ancient Forest',
      },
      {
        'name': 'Shattered Fortress',
        'difficulty': 'Legendary',
        'level': 40,
        'floors': 15,
        'reward': 5000,
        'region': 'Neutral Zone',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dungeons.length,
      itemBuilder: (context, index) {
        final dungeon = dungeons[index];
        final difficultyColor = _getDifficultyColor(dungeon['difficulty'] as String);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dungeon['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dungeon['difficulty'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        Text(
                          'Recommended Level: ${dungeon['level']}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          'Region: ${dungeon['region']}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Floors: ${dungeon['floors']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Reward: ${dungeon['reward']} Gold',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentFloor = 1;
                        _playerHealth = 100;
                        _inCombat = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Entered ${dungeon['name']}!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Enter Dungeon'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 現在のダンジョンタブ
  Widget _buildCurrentTab() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // フロア情報
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Current Floor',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Floor $_currentFloor / 5',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 進捗バー
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _currentFloor / 5,
                          minHeight: 12,
                          backgroundColor: Colors.grey[700],
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // プレイヤーステータス
              _buildStatusCard(
                'Your Status',
                _playerHealth,
                100,
                Colors.green,
                ['Health: $_playerHealth / 100'],
              ),
              const SizedBox(height: 16),
              // アクション
              if (!_inCombat)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_currentFloor < 5) {
                            _currentFloor++;
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Advanced to next floor')),
                        );
                      },
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text('Next Floor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _inCombat = true;
                          _enemyHealth = 50;
                        });
                      },
                      icon: const Icon(Icons.sports_mma),
                      label: const Text('Encounter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              if (_inCombat)
                Column(
                  children: [
                    _buildStatusCard(
                      'Enemy',
                      _enemyHealth,
                      50,
                      Colors.red,
                      ['Weak Golem', 'Level 3'],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _enemyHealth -= 15;
                              if (_enemyHealth <= 0) {
                                _inCombat = false;
                                _enemyHealth = 0;
                              }
                            });
                          },
                          icon: const Icon(Icons.favorite),
                          label: const Text('Attack'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _playerHealth =
                                  (_playerHealth + 20).clamp(0, 100);
                            });
                          },
                          icon: const Icon(Icons.local_hospital),
                          label: const Text('Heal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _inCombat = false;
                            });
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Flee'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 敵タブ
  Widget _buildEnemiesTab() {
    final enemies = [
      {
        'name': 'Weak Golem',
        'level': 3,
        'health': 30,
        'attack': 5,
        'exp': 50,
        'gold': 25,
      },
      {
        'name': 'Arcane Imp',
        'level': 4,
        'health': 20,
        'attack': 8,
        'exp': 75,
        'gold': 40,
      },
      {
        'name': 'Strong Golem',
        'level': 8,
        'health': 60,
        'attack': 12,
        'exp': 200,
        'gold': 100,
      },
      {
        'name': 'Arcane Construct (Boss)',
        'level': 8,
        'health': 200,
        'attack': 15,
        'exp': 500,
        'gold': 300,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enemies.length,
      itemBuilder: (context, index) {
        final enemy = enemies[index];
        final isBoss = enemy['name'].toString().contains('Boss');

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: isBoss ? Colors.red[900] : Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      enemy['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isBoss ? Colors.amber : Colors.white,
                      ),
                    ),
                    Chip(
                      label: Text('Lv.${enemy['level']}'),
                      backgroundColor: isBoss ? Colors.amber : Colors.blue,
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
                        Text('HP: ${enemy['health']}'),
                        Text('ATK: ${enemy['attack']}'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXP: ${enemy['exp']}',
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Gold: ${enemy['gold']}',
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 報酬タブ
  Widget _buildRewardsTab() {
    final rewards = [
      {
        'item': 'Arcane Tome',
        'rarity': 'Uncommon',
        'value': 200,
        'type': 'Equipment',
      },
      {
        'item': 'Crystal Ore',
        'rarity': 'Common',
        'value': 100,
        'type': 'Material',
      },
      {
        'item': 'Legendary Sword',
        'rarity': 'Legendary',
        'value': 1000,
        'type': 'Weapon',
      },
      {
        'item': 'Mana Crystal',
        'rarity': 'Rare',
        'value': 500,
        'type': 'Consumable',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final rarityColor = _getRarityColor(reward['rarity'] as String);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reward['item'] as String,
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
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        reward['rarity'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Type: ${reward['type']}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      '${reward['value']} Gold',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 統計タブ
  Widget _buildStatsTab() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatRow('Total Dungeons Completed', '12'),
                      const Divider(),
                      _buildStatRow('Total Gold Earned', '15,450'),
                      const Divider(),
                      _buildStatRow('Total Enemies Defeated', '847'),
                      const Divider(),
                      _buildStatRow('Floors Cleared', '94'),
                      const Divider(),
                      _buildStatRow('Boss Defeats', '8'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements Unlocked',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAchievementBadge('First Blood', 'Defeat 10 enemies'),
                      _buildAchievementBadge('Monster Hunter', 'Defeat 500 enemies'),
                      _buildAchievementBadge('Boss Slayer', 'Defeat 5 bosses'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ステータスカードを構築
  Widget _buildStatusCard(
    String title,
    int current,
    int max,
    Color barColor,
    List<String> info,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: current / max,
                minHeight: 20,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 8),
            for (final detail in info)
              Text(
                detail,
                style: TextStyle(color: Colors.grey[300]),
              ),
          ],
        ),
      ),
    );
  }

  /// ステート行を構築
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// 成就バッジを構築
  Widget _buildAchievementBadge(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.star, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                desc,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 難易度に応じた色を取得
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      case 'Legendary':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// レアリティに応じた色を取得
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common':
        return Colors.grey;
      case 'Uncommon':
        return Colors.green;
      case 'Rare':
        return Colors.blue;
      case 'Epic':
        return Colors.purple;
      case 'Legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
