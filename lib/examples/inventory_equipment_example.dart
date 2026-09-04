/// インベントリ・装備システムの対話的な例
/// アイテム管理、装備、クラフト、強化

import 'package:flutter/material.dart';

/// インベントリ・装備の例
class InventoryEquipmentExample extends StatefulWidget {
  const InventoryEquipmentExample({Key? key}) : super(key: key);

  @override
  State<InventoryEquipmentExample> createState() =>
      _InventoryEquipmentExampleState();
}

class _InventoryEquipmentExampleState extends State<InventoryEquipmentExample> {
  int _selectedTabIndex = 0;
  int _gold = 5000;
  int _inventoryCapacity = 30;

  final List<String> _tabNames = [
    'Inventory',
    'Equipment',
    'Crafting',
    'Enhancement',
    'Stats',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory & Equipment System'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ゴールド表示
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Gold: $_gold',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.backpack, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Capacity: 15/$_inventoryCapacity',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                          ? Colors.green
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

  /// タブコンテンツを構築
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInventoryTab();
      case 1:
        return _buildEquipmentTab();
      case 2:
        return _buildCraftingTab();
      case 3:
        return _buildEnhancementTab();
      case 4:
        return _buildStatsTab();
      default:
        return const SizedBox();
    }
  }

  /// インベントリタブ
  Widget _buildInventoryTab() {
    final items = [
      {
        'id': 'iron_sword',
        'name': 'Iron Sword',
        'rarity': 'Common',
        'type': 'Weapon',
        'quantity': 1,
        'value': 100,
      },
      {
        'id': 'health_potion',
        'name': 'Health Potion',
        'rarity': 'Common',
        'type': 'Consumable',
        'quantity': 5,
        'value': 25,
      },
      {
        'id': 'mana_potion',
        'name': 'Mana Potion',
        'rarity': 'Common',
        'type': 'Consumable',
        'quantity': 3,
        'value': 20,
      },
      {
        'id': 'leather_armor',
        'name': 'Leather Armor',
        'rarity': 'Common',
        'type': 'Armor',
        'quantity': 1,
        'value': 80,
      },
      {
        'id': 'ruby_ring',
        'name': 'Ruby Ring',
        'rarity': 'Rare',
        'type': 'Accessory',
        'quantity': 1,
        'value': 500,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final rarityColor = _getRarityColor(item['rarity'] as String);

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
                      Row(
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: rarityColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['rarity'] as String,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['type']} × ${item['quantity']}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item['value']} G',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} equipped!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Use'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
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

  /// 装備タブ
  Widget _buildEquipmentTab() {
    final equipmentSlots = [
      {'slot': 'Head', 'equipped': 'Iron Helmet', 'bonus': '+2 DEF'},
      {'slot': 'Neck', 'equipped': '---', 'bonus': 'Empty'},
      {'slot': 'Chest', 'equipped': 'Leather Armor', 'bonus': '+3 DEF, +20 HP'},
      {'slot': 'Hands', 'equipped': 'Leather Gloves', 'bonus': '+1 DEF, +2 ATK'},
      {'slot': 'Feet', 'equipped': 'Leather Boots', 'bonus': '+1 DEF'},
      {'slot': 'Weapon', 'equipped': 'Iron Sword', 'bonus': '+5 ATK'},
      {'slot': 'Shield', 'equipped': '---', 'bonus': 'Empty'},
      {'slot': 'Ring', 'equipped': 'Ruby Ring', 'bonus': '+5 MGC, +15 FIR'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: equipmentSlots.length,
      itemBuilder: (context, index) {
        final slot = equipmentSlots[index];
        final isEquipped = slot['equipped'] != '---';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isEquipped ? Colors.blue[900] : Colors.grey[850],
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
                        slot['slot'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slot['equipped'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isEquipped ? Colors.white : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slot['bonus'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isEquipped ? Colors.amber : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Changed ${slot['slot']} equipment'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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

  /// クラフトタブ
  Widget _buildCraftingTab() {
    final recipes = [
      {
        'name': 'Iron Sword',
        'output': '1',
        'time': '300s',
        'materials': ['5× Iron Ore', '2× Wood'],
        'cost': '50 Gold',
        'difficulty': 'Easy',
      },
      {
        'name': 'Steel Sword',
        'output': '1',
        'time': '600s',
        'materials': ['10× Iron Ore', '3× Steel Ingot', '3× Wood'],
        'cost': '150 Gold',
        'difficulty': 'Medium',
      },
      {
        'name': 'Leather Armor',
        'output': '1',
        'time': '400s',
        'materials': ['8× Leather', '2× Thread'],
        'cost': '40 Gold',
        'difficulty': 'Easy',
      },
      {
        'name': 'Health Potion',
        'output': '5',
        'time': '180s',
        'materials': ['3× Herbs', '1× Water', '5× Bottle'],
        'cost': '10 Gold',
        'difficulty': 'Easy',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final diffColor = recipe['difficulty'] == 'Easy'
            ? Colors.green
            : recipe['difficulty'] == 'Medium'
                ? Colors.orange
                : Colors.red;

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
                    Text(
                      recipe['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: diffColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe['difficulty'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Output: ${recipe['output']} | Time: ${recipe['time']} | ${recipe['cost']}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: (recipe['materials'] as List<dynamic>)
                      .cast<String>()
                      .map((material) {
                    return Chip(
                      label: Text(material),
                      labelStyle: const TextStyle(fontSize: 11),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Crafting ${recipe['name']}...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.build),
                    label: const Text('Craft'),
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

  /// 強化タブ
  Widget _buildEnhancementTab() {
    final items = [
      {
        'name': 'Iron Sword',
        'enhancement': '0',
        'durability': '100',
        'enchantments': 0,
      },
      {
        'name': 'Leather Armor',
        'enhancement': '2',
        'durability': '85',
        'enchantments': 1,
      },
      {
        'name': 'Ruby Ring',
        'enhancement': '5',
        'durability': '70',
        'enchantments': 2,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final durability = int.parse(item['durability'] as String);
        final durabilityColor =
            durability > 70 ? Colors.green : durability > 30 ? Colors.orange : Colors.red;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enhancement: +${item['enhancement']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enchantments: ${item['enchantments']}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Durability',
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: durabilityColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item['durability']}/100',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: durability / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation(durabilityColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_gold >= 100) {
                            _gold -= 100;
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Enhanced ${item['name']}!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.trending_up, size: 16),
                      label: const Text('Enhance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Repaired ${item['name']}!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.build, size: 16),
                      label: const Text('Repair'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 総合統計
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Equipment Stats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow('Attack Power', '28', Colors.red),
                    _buildStatRow('Defense Rating', '16', Colors.blue),
                    _buildStatRow('Max Health', '165', Colors.green),
                    _buildStatRow('Magic Power', '10', Colors.purple),
                    _buildStatRow('Fire Damage', '15', Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // アイテム統計
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Equipment Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow('Equipped Items', '8', Colors.white),
                    _buildStatRow('Total Enhancement', '+7', Colors.amber),
                    _buildStatRow('Total Enchantments', '3', Colors.cyan),
                    _buildStatRow('Average Durability', '85%', Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 装備セット
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Equipment Sets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSetItem(
                      'Novice Warrior',
                      'Basic starting equipment',
                      'Lv. 1',
                    ),
                    _buildSetItem(
                      'Veteran Warrior',
                      'Intermediate equipment set',
                      'Lv. 10',
                    ),
                    _buildSetItem(
                      'Dragon Slayer',
                      'Advanced equipment for dragon hunters',
                      'Lv. 35',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ステート行を構築
  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// セットアイテムを構築
  Widget _buildSetItem(String name, String description, String level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              level,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// レアリティ色を取得
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
