/// ギルド/ファクション展開システムの対話的な例
/// ギルド管理、テリトリー制御、ファクション戦争

import 'package:flutter/material.dart';

/// ギルド展開の例
class GuildExpansionExample extends StatefulWidget {
  const GuildExpansionExample({Key? key}) : super(key: key);

  @override
  State<GuildExpansionExample> createState() => _GuildExpansionExampleState();
}

class _GuildExpansionExampleState extends State<GuildExpansionExample> {
  int _selectedTabIndex = 0;

  final List<String> _tabNames = [
    'Guilds',
    'Territories',
    'Wars',
    'Members',
    'Stats',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guild & Faction Expansion System'),
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
                          ? Colors.blue
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
        return _buildGuildsTab();
      case 1:
        return _buildTerritoriesTab();
      case 2:
        return _buildWarsTab();
      case 3:
        return _buildMembersTab();
      case 4:
        return _buildStatsTab();
      default:
        return const SizedBox();
    }
  }

  /// ギルドタブ
  Widget _buildGuildsTab() {
    final guilds = [
      {
        'id': 'mage_tower',
        'name': 'Mage Tower Collective',
        'leader': 'Morvan',
        'level': 1,
        'members': 3,
        'capacity': 50,
        'treasury': 5000,
      },
      {
        'id': 'adventurers_guild',
        'name': 'Adventurers Guild',
        'leader': 'Kai',
        'level': 2,
        'members': 3,
        'capacity': 60,
        'treasury': 8000,
      },
      {
        'id': 'merchant_cartel',
        'name': 'Merchant Cartel',
        'leader': 'Mae',
        'level': 1,
        'members': 4,
        'capacity': 45,
        'treasury': 10000,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guilds.length,
      itemBuilder: (context, index) {
        final guild = guilds[index];
        final memberFill = (guild['members'] as int) / (guild['capacity'] as int);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ギルド名とリーダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      guild['name'] as String,
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
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Lv.${guild['level']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Leader: ${guild['leader']}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 12),
                // メンバー情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members: ${guild['members']}/${guild['capacity']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: memberFill as double,
                          minHeight: 8,
                          backgroundColor: Colors.grey[700],
                          valueColor: AlwaysStoppedAnimation(
                            memberFill > 0.8 ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // トレジャリー情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Treasury: ${guild['treasury']} Gold',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${guild['name']} upgraded to Level ${(guild['level'] as int) + 1}!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.upgrade),
                      label: const Text('Promote'),
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

  /// テリトリータブ
  Widget _buildTerritoriesTab() {
    final territories = [
      {
        'id': 'mage_tower_region',
        'name': 'Mage Tower Region',
        'controller': 'Mage Tower Collective',
        'type': 'Arcane',
        'level': 1,
        'bonus': 1.15,
        'population': 300,
        'resources': {'arcane_dust': 50, 'mana_crystal': 10},
      },
      {
        'id': 'adventurers_region',
        'name': 'Adventurers Village Region',
        'controller': 'Adventurers Guild',
        'type': 'Martial',
        'level': 2,
        'bonus': 1.20,
        'population': 400,
        'resources': {'iron_ore': 80, 'leather': 40},
      },
      {
        'id': 'merchant_region',
        'name': 'Merchants City Region',
        'controller': 'Merchant Cartel',
        'type': 'Commerce',
        'level': 1,
        'bonus': 1.25,
        'population': 500,
        'resources': {'gold': 500, 'trade_goods': 30},
      },
      {
        'id': 'forest_region',
        'name': 'Ancient Forest',
        'controller': 'Unclaimed',
        'type': 'Natural',
        'level': 1,
        'bonus': 1.10,
        'population': 100,
        'resources': {'herbs': 100, 'wood': 60},
      },
      {
        'id': 'mountain_region',
        'name': 'Crystal Mountains',
        'controller': 'Unclaimed',
        'type': 'Mineral',
        'level': 2,
        'bonus': 1.15,
        'population': 150,
        'resources': {'crystal': 150, 'gold_ore': 75},
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: territories.length,
      itemBuilder: (context, index) {
        final territory = territories[index];
        final isUnclaimed =
            territory['controller'] as String == 'Unclaimed';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: isUnclaimed ? Colors.grey[850] : Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      territory['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text('${territory['type']}'),
                      backgroundColor: _getTypeColor(territory['type'] as String),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Controller: ${territory['controller']}',
                  style: TextStyle(
                    color: isUnclaimed ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level: ${territory['level']}'),
                    Text('Population: ${territory['population']}'),
                    Text(
                      'Bonus: ×${territory['bonus']}',
                      style: const TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isUnclaimed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${territory['name']} claimed by your faction!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.flag),
                      label: const Text('Claim Territory'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

  /// 戦争タブ
  Widget _buildWarsTab() {
    final wars = [
      {
        'id': 'war_001',
        'name': 'Battle for Forest Territory',
        'status': 'ACTIVE',
        'participants': ['Mage Tower', 'Adventurers Guild', 'Merchant Cartel'],
        'scores': {'Mage Tower': 450, 'Adventurers Guild': 620, 'Merchant Cartel': 380},
        'timeRemaining': '12d 5h',
      },
      {
        'id': 'war_002',
        'name': 'Mountain Pass Supremacy',
        'status': 'PLANNING',
        'participants': ['Mage Tower', 'Adventurers Guild'],
        'scores': {'Mage Tower': 0, 'Adventurers Guild': 0},
        'timeRemaining': '5d 3h',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wars.length,
      itemBuilder: (context, index) {
        final war = wars[index];
        final isActive = war['status'] as String == 'ACTIVE';

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
                    Expanded(
                      child: Text(
                        war['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(war['status'] as String),
                      backgroundColor:
                          isActive ? Colors.red : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Time Remaining: ${war['timeRemaining']}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 12),
                // スコアボード
                ...(war['scores'] as Map<String, dynamic>)
                    .entries
                    .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                if (isActive)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Contributed 100 points to war!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.trending_up),
                      label: const Text('Contribute Points'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

  /// メンバータブ
  Widget _buildMembersTab() {
    final guildMembers = [
      {
        'guild': 'Adventurers Guild',
        'members': ['Kai', 'Eloise', 'Thorn']
      },
      {
        'guild': 'Mage Tower Collective',
        'members': ['Aria', 'Luna', 'Morvan']
      },
      {
        'guild': 'Merchant Cartel',
        'members': ['Zephyr', 'Mae', 'Oliver', 'Isabella']
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guildMembers.length,
      itemBuilder: (context, index) {
        final guildData = guildMembers[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guildData['guild'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (guildData['members'] as List<dynamic>)
                      .cast<String>()
                      .map((member) {
                    return Chip(
                      label: Text(member),
                      avatar: CircleAvatar(
                        child: Text(member[0]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Members: ${(guildData['members'] as List<dynamic>).length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
    final stats = [
      {
        'faction': 'Mage Tower Collective',
        'territories': 1,
        'members': 3,
        'treasury': 5000,
        'warScore': 450,
        'victories': 2,
      },
      {
        'faction': 'Adventurers Guild',
        'territories': 1,
        'members': 3,
        'treasury': 8500,
        'warScore': 1200,
        'victories': 5,
      },
      {
        'faction': 'Merchant Cartel',
        'territories': 1,
        'members': 4,
        'treasury': 11000,
        'warScore': 380,
        'victories': 1,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['faction'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Territories', stat['territories'].toString()),
                    _buildStatItem('Members', stat['members'].toString()),
                    _buildStatItem('Victories', stat['victories'].toString()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                        'Treasury', '${stat['treasury']}g', Colors.amber),
                    _buildStatItem(
                        'War Score', stat['warScore'].toString(), Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 統計アイテムを構築
  Widget _buildStatItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  /// タイプに応じた色を取得
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Arcane':
        return Colors.purple;
      case 'Martial':
        return Colors.red;
      case 'Commerce':
        return Colors.amber;
      case 'Natural':
        return Colors.green;
      case 'Mineral':
        return Colors.blue;
      case 'Maritime':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
