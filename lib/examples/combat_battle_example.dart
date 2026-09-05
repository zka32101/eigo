/// 戦闘・バトルシステムの対話的な例
/// ターンベース戦闘、スキル選択、ダメージ計算

import 'package:flutter/material.dart';

/// 戦闘・バトルシステムの例
class CombatBattleExample extends StatefulWidget {
  const CombatBattleExample({Key? key}) : super(key: key);

  @override
  State<CombatBattleExample> createState() => _CombatBattleExampleState();
}

class _CombatBattleExampleState extends State<CombatBattleExample> {
  int _selectedTabIndex = 0;
  int _battleRound = 1;
  bool _battleActive = true;
  String _currentPhase = 'Player Turn';

  final List<String> _tabNames = [
    'Battle',
    'Party',
    'Skills',
    'Log',
    'Stats',
  ];

  // プレイヤーパーティ
  final List<Map<String, dynamic>> _players = [
    {
      'id': 'player_1',
      'name': 'Warrior',
      'level': 10,
      'health': 120,
      'maxHealth': 150,
      'mana': 30,
      'maxMana': 50,
      'stamina': 80,
      'maxStamina': 100,
      'attack': 25,
      'defense': 15,
      'position': 0,
      'status': [],
    },
    {
      'id': 'player_2',
      'name': 'Mage',
      'level': 9,
      'health': 70,
      'maxHealth': 80,
      'mana': 100,
      'maxMana': 120,
      'stamina': 50,
      'maxStamina': 70,
      'attack': 12,
      'defense': 5,
      'position': 1,
      'status': [],
    },
    {
      'id': 'player_3',
      'name': 'Rogue',
      'level': 8,
      'health': 60,
      'maxHealth': 75,
      'mana': 40,
      'maxMana': 60,
      'stamina': 120,
      'maxStamina': 150,
      'attack': 20,
      'defense': 8,
      'position': 2,
      'status': ['Poison'],
    },
  ];

  // 敵
  final List<Map<String, dynamic>> _enemies = [
    {
      'id': 'enemy_1',
      'name': 'Orc Warrior',
      'level': 7,
      'health': 100,
      'maxHealth': 120,
      'attack': 18,
      'defense': 10,
      'status': [],
    },
    {
      'id': 'enemy_2',
      'name': 'Fire Elemental',
      'level': 6,
      'health': 60,
      'maxHealth': 80,
      'attack': 15,
      'defense': 5,
      'status': [],
    },
  ];

  // スキルリスト
  final List<Map<String, dynamic>> _skills = [
    {
      'id': 'skill_basic_attack',
      'name': 'Basic Attack',
      'type': 'Physical',
      'cost': '10 Stamina',
      'damage': '25-35',
      'accuracy': '95%',
      'crit': '15%',
    },
    {
      'id': 'skill_power_strike',
      'name': 'Power Strike',
      'type': 'Physical',
      'cost': '25 Stamina',
      'damage': '40-50',
      'accuracy': '85%',
      'crit': '25%',
    },
    {
      'id': 'skill_fireball',
      'name': 'Fireball',
      'type': 'Magical',
      'cost': '40 Mana',
      'damage': '30-45',
      'accuracy': '90%',
      'crit': '10%',
    },
    {
      'id': 'skill_heal',
      'name': 'Heal',
      'type': 'Healing',
      'cost': '30 Mana',
      'effect': 'Restore 100 HP',
      'accuracy': '100%',
    },
    {
      'id': 'skill_defend',
      'name': 'Defend',
      'type': 'Defensive',
      'cost': '5 Stamina',
      'effect': 'Reduce damage by 50%',
      'duration': '1 turn',
    },
  ];

  // 戦闘ログ
  final List<String> _battleLog = [
    'Turn 1: Warrior attacks Orc Warrior for 28 damage!',
    'Turn 1: Mage casts Fireball on Fire Elemental for 38 damage!',
    'Turn 1: Orc Warrior attacks Warrior for 18 damage',
    'Turn 1: Fire Elemental attacks Mage, but Mage blocks!',
    'Turn 2: Rogue attacks Fire Elemental for 22 damage!',
    'Battle started...',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combat & Battle System'),
        centerTitle: true,
        actions: [
          if (_battleActive)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Round $_battleRound | $_currentPhase',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Chip(
                label: Text('Battle Ended'),
                backgroundColor: Colors.grey,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // タブナビゲーション
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabNames.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTabIndex == index
                          ? Colors.red
                          : Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Text(_tabNames[index]),
                  ),
                );
              }),
            ),
          ),
          // コンテンツ
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// タブコンテンツを構築
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildBattleTab();
      case 1:
        return _buildPartyTab();
      case 2:
        return _buildSkillsTab();
      case 3:
        return _buildLogTab();
      case 4:
        return _buildStatsTab();
      default:
        return const Text('Unknown Tab');
    }
  }

  /// 戦闘タブ
  Widget _buildBattleTab() {
    return Column(
      children: [
        const Text(
          'Enemy Party',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._enemies.map((enemy) {
          final healthPercent = enemy['health'] / enemy['maxHealth'];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                            '${enemy['name']} (Lv${enemy['level']})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ATK: ${enemy['attack']} | DEF: ${enemy['defense']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _battleActive
                            ? () => _showSkillSelection(enemy['id'])
                            : null,
                        child: const Text('Attack'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: healthPercent,
                      minHeight: 8,
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        healthPercent > 0.5 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${enemy['health']}/${enemy['maxHealth']} HP',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
        const Text(
          'Player Party',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._players.map((player) {
          final healthPercent = player['health'] / player['maxHealth'];
          final manaPercent = player['mana'] / player['maxMana'];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${player['name']} (Lv${player['level']})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // HP バー
                  Row(
                    children: [
                      const Text('HP: ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: healthPercent,
                            minHeight: 6,
                            backgroundColor: Colors.grey[700],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${player['health']}/${player['maxHealth']}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Mana バー
                  Row(
                    children: [
                      const Text('MP: ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: manaPercent,
                            minHeight: 6,
                            backgroundColor: Colors.grey[700],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${player['mana']}/${player['maxMana']}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  if ((player['status'] as List).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 4,
                        children: [
                          for (final status in (player['status'] as List))
                            Chip(
                              label: Text(status.toString()),
                              backgroundColor: Colors.orange,
                              labelStyle:
                                  const TextStyle(color: Colors.white),
                            ),
                        ],
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

  /// パーティタブ
  Widget _buildPartyTab() {
    return Column(
      children: [
        const Text(
          'Party Formation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Front Line'),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(_players[0]['name']),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Mid Line'),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(_players[1]['name']),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(_players[2]['name']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Party Statistics',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Level'),
                    Text('27'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Average Level'),
                    Text('9'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total HP'),
                    Text('305/250'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Battles'),
                    Text('12'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Win Rate'),
                    Text('75%'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// スキルタブ
  Widget _buildSkillsTab() {
    return Column(
      children: [
        const Text(
          'Available Skills',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._skills.map((skill) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                              skill['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Type: ${skill['type']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        skill['cost'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (skill.containsKey('damage'))
                    Text(
                      'Damage: ${skill['damage']} | Accuracy: ${skill['accuracy']} | Crit: ${skill['crit']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (skill.containsKey('effect'))
                    Text(
                      'Effect: ${skill['effect']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// ログタブ
  Widget _buildLogTab() {
    return Column(
      children: [
        const Text(
          'Battle Log',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._battleLog.map((log) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      log,
                      style: const TextStyle(fontSize: 12),
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

  /// 統計情報タブ
  Widget _buildStatsTab() {
    return Column(
      children: [
        const Text(
          'Battle Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Overall',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Battles'),
                    Text('24'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Victories'),
                    Text('18 (75%)'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Defeats'),
                    Text('6 (25%)'),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'This Battle',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Round'),
                    Text('1'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Damage Dealt'),
                    Text('88'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Damage Taken'),
                    Text('46'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// スキル選択ダイアログ
  void _showSkillSelection(String targetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Skill'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _skills.map((skill) {
              return ListTile(
                title: Text(skill['name']),
                subtitle: Text(skill['cost']),
                onTap: () {
                  setState(() {
                    _battleLog.insert(
                      0,
                      'Warrior used ${skill['name']} on Orc Warrior!',
                    );
                    _battleRound++;
                    _currentPhase = 'Enemy Turn';
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
