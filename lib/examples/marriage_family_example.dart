/// NPC 結婚・家族システムの対話的な例
/// 結婚、子供、家族進行

import 'package:flutter/material.dart';

/// 結婚・家族システムの例
class MarriageFamilyExample extends StatefulWidget {
  const MarriageFamilyExample({Key? key}) : super(key: key);

  @override
  State<MarriageFamilyExample> createState() => _MarriageFamilyExampleState();
}

class _MarriageFamilyExampleState extends State<MarriageFamilyExample> {
  int _selectedTabIndex = 0;
  int _playerLevel = 15;
  int _playerGold = 10000;
  bool _isMarried = false;
  String _spouseName = '';
  int _marriedDays = 0;
  int _familyLevel = 1;
  int _generationCount = 1;

  final List<String> _tabNames = [
    'NPCs',
    'Marriage',
    'Children',
    'Family',
    'Inheritance',
  ];

  final List<Map<String, dynamic>> _npcList = [
    {
      'id': 'npc_serena',
      'name': 'Serena',
      'gender': 'Female',
      'age': 24,
      'affinity': 75,
      'personality': 'Gentle',
      'traits': ['caring', 'intelligent'],
      'available': true,
    },
    {
      'id': 'npc_luna',
      'name': 'Luna',
      'gender': 'Female',
      'age': 22,
      'affinity': 65,
      'personality': 'Energetic',
      'traits': ['brave', 'adventurous'],
      'available': true,
    },
    {
      'id': 'npc_iris',
      'name': 'Iris',
      'gender': 'Female',
      'age': 26,
      'affinity': 80,
      'personality': 'Mysterious',
      'traits': ['mysterious', 'wise'],
      'available': true,
    },
    {
      'id': 'npc_aldric',
      'name': 'Aldric',
      'gender': 'Male',
      'age': 28,
      'affinity': 70,
      'personality': 'Stoic',
      'traits': ['strong', 'loyal'],
      'available': true,
    },
    {
      'id': 'npc_kael',
      'name': 'Kael',
      'gender': 'Male',
      'age': 25,
      'affinity': 55,
      'personality': 'Mischievous',
      'traits': ['charming', 'witty'],
      'available': true,
    },
  ];

  final List<Map<String, dynamic>> _childrenList = [
    {
      'id': 'child_1',
      'name': 'Aria',
      'ageInYears': 8,
      'happiness': 85,
      'health': 95,
      'educationLevel': 60,
      'parentNpc': 'Serena',
    },
    {
      'id': 'child_2',
      'name': 'Marcus',
      'ageInYears': 5,
      'happiness': 80,
      'health': 90,
      'educationLevel': 30,
      'parentNpc': 'Serena',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marriage & Family System'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ステータスバー
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Family Lvl: $_familyLevel | Generations: $_generationCount',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text('Lvl $_playerLevel | $_playerGold G'),
              ],
            ),
          ),
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
                          ? Colors.purple
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
        return _buildNPCsTab();
      case 1:
        return _buildMarriageTab();
      case 2:
        return _buildChildrenTab();
      case 3:
        return _buildFamilyTab();
      case 4:
        return _buildInheritanceTab();
      default:
        return const Text('Unknown Tab');
    }
  }

  /// NPCs タブ
  Widget _buildNPCsTab() {
    return Column(
      children: [
        const Text(
          'Available Marriage Candidates',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._npcList.map((npc) {
          final affinityLevel =
              npc['affinity'] < 40 ? 'Friend' : 'Love Interest';
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
                              '${npc['name']} (${npc['gender']})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Age: ${npc['age']} | ${npc['personality']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (npc['available'])
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _showProposalDialog(npc);
                          },
                          child: const Text('Propose'),
                        )
                      else
                        const Chip(
                          label: Text('Married'),
                          backgroundColor: Colors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // アフィニティバー
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: npc['affinity'] / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[700],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              npc['affinity'] < 40
                                  ? Colors.green
                                  : Colors.pink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${npc['affinity']}/100'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Affinity: $affinityLevel',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final trait in (npc['traits'] as List<dynamic>))
                        Chip(label: Text(trait.toString())),
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

  /// 結婚タブ
  Widget _buildMarriageTab() {
    return Column(
      children: [
        if (_isMarried)
          Column(
            children: [
              const Text(
                'Marriage Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Married to $_spouseName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Days Married: $_marriedDays days',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _marriedDays += 1;
                              });
                            },
                            child: const Text('Spend Time'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              _showDivorceDialog();
                            },
                            child: const Text('Divorce'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ボーナス表示
              const Text(
                'Marriage Bonuses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Intelligence'),
                          Text('+10'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mana'),
                          Text('+50'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Magic Affinity'),
                          Text('+15'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.sentiment_dissatisfied,
                      size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text(
                    'Not Married Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find a marriage candidate and build up affinity!',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 子供タブ
  Widget _buildChildrenTab() {
    return Column(
      children: [
        const Text(
          'Children',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (!_isMarried)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Marry first to have children',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else if (_childrenList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ElevatedButton(
                onPressed: () {
                  _showBirthDialog();
                },
                child: const Text('Have a Child'),
              ),
            ),
          )
        else
          Column(
            children: [
              ..._childrenList.map((child) {
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
                                    child['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Age: ${child['ageInYears']} | Parent: ${child['parentNpc']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Manage'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // ステータスバー
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Happiness',
                                    style: TextStyle(fontSize: 12)),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value:
                                              child['happiness'] / 100,
                                          minHeight: 6,
                                          backgroundColor: Colors.grey[700],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.green),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${child['happiness']}'),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Health',
                                    style: TextStyle(fontSize: 12)),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: child['health'] / 100,
                                          minHeight: 6,
                                          backgroundColor: Colors.grey[700],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.red),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${child['health']}'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: child['educationLevel'] / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey[700],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Education: ${child['educationLevel']}/100',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _showBirthDialog();
                },
                child: const Text('Have Another Child'),
              ),
            ],
          ),
      ],
    );
  }

  /// 家族タブ
  Widget _buildFamilyTab() {
    return Column(
      children: [
        const Text(
          'Family Progression',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Family Level',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$_familyLevel'),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 8,
                    backgroundColor: Colors.grey[700],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.purple),
                  ),
                ),
                const SizedBox(height: 4),
                const Text('6500 / 10000 XP',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Generations',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('$_generationCount'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lineage Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Chip(label: Text('Warrior Bloodline')),
                const SizedBox(height: 16),
                const Text(
                  'Unlocked Skills',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Chip(
                      label: Text('Warrior Legacy'),
                      backgroundColor: Colors.green,
                    ),
                    SizedBox(height: 8),
                    Chip(
                      label: Text('Adventurer Legacy'),
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Family Bonuses',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attack'),
                    Text('+25'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Defense'),
                    Text('+15'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Health'),
                    Text('+100'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('XP Multiplier'),
                    Text('×1.15'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 相続タブ
  Widget _buildInheritanceTab() {
    return Column(
      children: [
        const Text(
          'Inheritance & Legacy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_childrenList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Have children to prepare for inheritance',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              const Text(
                'Possible Heirs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._childrenList.map((child) {
                final canInherit = child['ageInYears'] >= 18 &&
                    child['happiness'] > 40 &&
                    child['health'] > 50;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Age: ${child['ageInYears']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (!canInherit)
                                Text(
                                  'Not ready to inherit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[300],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canInherit ? () {} : null,
                          child: const Text('Inherit'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  /// プロポーザルダイアログ
  void _showProposalDialog(Map<String, dynamic> npc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Propose to ${npc['name']}?'),
        content: Text(
          'Affinity: ${npc['affinity']}/100\nRequired: 60\nLevel Required: 10\nGold Cost: 5000 G',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isMarried = true;
                _spouseName = npc['name'];
                _marriedDays = 0;
                _playerGold -= 5000;
                npc['available'] = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Married to ${npc['name']}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Propose'),
          ),
        ],
      ),
    );
  }

  /// 離婚ダイアログ
  void _showDivorceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Divorce?'),
        content: Text('Are you sure you want to divorce $_spouseName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isMarried = false;
                _spouseName = '';
                _marriedDays = 0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Divorce complete'),
                  backgroundColor: Colors.grey,
                ),
              );
            },
            child: const Text('Divorce'),
          ),
        ],
      ),
    );
  }

  /// 出産ダイアログ
  void _showBirthDialog() {
    final childNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Have a Child'),
        content: TextField(
          controller: childNameController,
          decoration: const InputDecoration(
            hintText: 'Enter child name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (childNameController.text.isNotEmpty) {
                setState(() {
                  _childrenList.add({
                    'id': 'child_${_childrenList.length + 1}',
                    'name': childNameController.text,
                    'ageInYears': 0,
                    'happiness': 80,
                    'health': 95,
                    'educationLevel': 0,
                    'parentNpc': _spouseName,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${childNameController.text} was born!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Have Child'),
          ),
        ],
      ),
    );
  }
}
