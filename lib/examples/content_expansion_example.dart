/// コンテンツ拡張システム例

import 'package:flutter/material.dart';
import '../models/content_expansion_system.dart';

void main() {
  runApp(const ContentExpansionExample());
}

class ContentExpansionExample extends StatefulWidget {
  const ContentExpansionExample({Key? key}) : super(key: key);

  @override
  State<ContentExpansionExample> createState() =>
      _ContentExpansionExampleState();
}

class _ContentExpansionExampleState extends State<ContentExpansionExample> {
  final system = ContentExpansionSystem.getInstance();
  int selectedTabIndex = 0;
  int playerLevel = 25;

  @override
  void initState() {
    super.initState();
    system.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Content Expansion System',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('コンテンツ拡張システム')),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildAreasTab(),
            _buildSkillsTab(),
            _buildEquipmentTab(),
            _buildNPCsTab(),
            _buildItemsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => selectedTabIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.terrain), label: '領域'),
            BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'スキル'),
            BottomNavigationBarItem(icon: Icon(Icons.shield), label: '装備'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'NPC'),
            BottomNavigationBarItem(icon: Icon(Icons.backpack), label: 'アイテム'),
          ],
        ),
      ),
    );
  }

  Widget _buildAreasTab() {
    final areas = system.getAvailableAreas(playerLevel);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('利用可能な領域',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('プレイヤーレベル: $playerLevel',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...areas.map((area) {
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
                      Text(area.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Lvl ${area.difficulty}/5',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('必要レベル: ${area.minLevel}+',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: area.features
                        .map((f) => Chip(
                              label: Text(f, style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.purple.withOpacity(0.1),
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

  Widget _buildSkillsTab() {
    final skills = system.getAvailableSkills(playerLevel);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('習得可能なスキル',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('合計: ${skills.length}スキル',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...skills.map((skill) {
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
                        child: Text(skill.name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(skill.type.toString().split('.').last,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatTile('ダメージ', skill.damage),
                      _buildStatTile('マナ', skill.manaCost),
                      _buildStatTile('クールダウン', skill.cooldown),
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

  Widget _buildEquipmentTab() {
    final equipment = system._equipment.values.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('装備アイテム',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('合計: ${equipment.length}アイテム',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...equipment.map((item) {
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
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRarityColor(item.rarity).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_getRarityName(item.rarity),
                            style: TextStyle(
                                fontSize: 11,
                                color: _getRarityColor(item.rarity),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('レベル: ${item.level}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatTile('攻撃', item.attack),
                      _buildStatTile('防御', item.defense),
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

  Widget _buildNPCsTab() {
    final npcs = system._npcs.values.toList();
    final marriageable = system.getMarriageableNPCs();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('新規NPC',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('合計: ${npcs.length}名 (結婚可能: ${marriageable.length}名)',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...npcs.map((npc) {
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
                      Text(npc.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      if (npc.marriageable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('結婚可能',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('レベル: ${npc.level}',
                      style: const TextStyle(fontSize: 12)),
                  Text('特技: ${npc.specialty}',
                      style: const TextStyle(fontSize: 12)),
                  Text('場所: ${npc.location}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildItemsTab() {
    final items = system._items.values.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アイテム',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('合計: ${items.length}アイテム',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('値段: ${item.value}G',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRarityColor(item.rarity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_getRarityName(item.rarity),
                        style: TextStyle(
                            fontSize: 11,
                            color: _getRarityColor(item.rarity),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatTile(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.uncommon:
        return Colors.green;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.epic:
        return Colors.purple;
      case Rarity.legendary:
        return Colors.amber;
    }
  }

  String _getRarityName(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return 'コモン';
      case Rarity.uncommon:
        return 'アンコモン';
      case Rarity.rare:
        return 'レア';
      case Rarity.epic:
        return 'エピック';
      case Rarity.legendary:
        return 'レジェンダリー';
    }
  }
}
