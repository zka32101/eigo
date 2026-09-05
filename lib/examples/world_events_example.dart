/// ワールドイベントシステム例
/// 動的ワールドイベント、季節変化、ランダムエンカウント

import 'package:flutter/material.dart';
import '../models/world_events_system.dart';

void main() {
  runApp(const WorldEventsExample());
}

class WorldEventsExample extends StatefulWidget {
  const WorldEventsExample({Key? key}) : super(key: key);

  @override
  State<WorldEventsExample> createState() => _WorldEventsExampleState();
}

class _WorldEventsExampleState extends State<WorldEventsExample> {
  final eventsSystem = WorldEventsSystem.getInstance();
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    eventsSystem.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Events System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ワールドイベントシステム'),
          elevation: 0,
        ),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildEventsTab(),
            _buildSeasonsTab(),
            _buildTerritoriesTab(),
            _buildEncountersTab(),
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
              icon: Icon(Icons.warning),
              label: 'イベント',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny),
              label: '季節',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.public),
              label: '領域',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'エンカウント',
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

  Widget _buildEventsTab() {
    final activeEvents = eventsSystem.getActiveEvents();

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
                  'アクティブなワールドイベント',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '発生中: ${activeEvents.length}件',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (activeEvents.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'アクティブなイベントはありません',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...activeEvents.map((event) {
            final color = _getEventColor(event.type);
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
                                _getEventTypeName(event.type),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '場所: ${event.territory}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '強度: ${event.intensity}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 1.0 - (event.getRemainingDays() / event.duration),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '残り日数: ${event.getRemainingDays()}/${event.duration}日',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (event.affectedNPCs.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '影響を受けたNPC: ${event.affectedNPCs.join(", ")}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSeasonsTab() {
    final season = eventsSystem.getCurrentSeason();
    final progress = eventsSystem.getSeasonProgress();
    final day = eventsSystem.getCurrentDay();

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
                  '季節システム',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSeasonInfo('現在の季節', _getSeasonName(season),
                    _getSeasonIcon(season), _getSeasonColor(season)),
                const SizedBox(height: 16),
                Text(
                  '日数: $day日',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '季節進行: $progress%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '季節の特性',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSeasonalEffect(season),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerritoriesTab() {
    final territories = eventsSystem.getAllTerritoryStates();

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
                  '領域の状態',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '監視中: ${territories.length}領域',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...territories.entries.map((entry) {
          final state = entry.value;
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
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ステータス: ${state.getStatus()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '安全性: ${state.getSafetyScore()}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatBar('安定性', state.stability, Colors.blue),
                  const SizedBox(height: 8),
                  _buildStatBar('繁栄', state.prosperity, Colors.green),
                  const SizedBox(height: 8),
                  _buildStatBar('士気', state.populationMorale, Colors.orange),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEncountersTab() {
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
                  'ランダムエンカウント',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final encounter = eventsSystem.generateRandomEncounter('arcane_citadel');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${encounter.getName()}\n難易度: ${encounter.difficulty}/5\n報酬: ${encounter.reward}G',
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('エンカウントを生成'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildEncounterCard(
          'EncounterType.wildBeast',
          '野獣との遭遇',
          '野生の獣があなたに近づいてきた',
          2,
          200,
        ),
        _buildEncounterCard(
          'EncounterType.bandits',
          '盗賊との遭遇',
          '盗賊集団があなたを襲った',
          3,
          300,
        ),
        _buildEncounterCard(
          'EncounterType.magicalBeast',
          '魔獣との遭遇',
          '魔獣があなたの前に現れた',
          4,
          400,
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final history = eventsSystem.getEventHistory();

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
                  'イベント履歴',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '記録済みイベント: ${history.length}件',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'イベント履歴がありません',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...history.map((result) {
            final color = _getEventColor(result.eventType);
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
                              _getEventTypeName(result.eventType),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '場所: ${result.territory}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '強度: ${result.intensity}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '継続期間: ${result.getDurationDays()}日',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (result.affectedNPCs.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '影響を受けたNPC: ${result.affectedNPCs.length}名',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                    if (result.consequences.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '影響: ${result.consequences.length}項目',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  String _getSeasonName(Season season) {
    const names = {
      Season.spring: '春',
      Season.summer: '夏',
      Season.autumn: '秋',
      Season.winter: '冬',
    };
    return names[season] ?? '不明';
  }

  String _getEventTypeName(WorldEventType type) {
    const names = {
      WorldEventType.invasion: '侵略',
      WorldEventType.disaster: '自然災害',
      WorldEventType.celebration: 'お祭り',
      WorldEventType.epidemic: '疫病',
      WorldEventType.migration: 'NPC移動',
    };
    return names[type] ?? '不明';
  }

  Color _getEventColor(WorldEventType type) {
    switch (type) {
      case WorldEventType.invasion:
        return Colors.red;
      case WorldEventType.disaster:
        return Colors.orange;
      case WorldEventType.celebration:
        return Colors.green;
      case WorldEventType.epidemic:
        return Colors.purple;
      case WorldEventType.migration:
        return Colors.blue;
    }
  }

  Color _getSeasonColor(Season season) {
    switch (season) {
      case Season.spring:
        return Colors.green;
      case Season.summer:
        return Colors.orange;
      case Season.autumn:
        return Colors.brown;
      case Season.winter:
        return Colors.blue;
    }
  }

  IconData _getSeasonIcon(Season season) {
    switch (season) {
      case Season.spring:
        return Icons.flower;
      case Season.summer:
        return Icons.wb_sunny;
      case Season.autumn:
        return Icons.grain;
      case Season.winter:
        return Icons.ac_unit;
    }
  }

  Widget _buildSeasonInfo(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalEffect(Season season) {
    String effect;
    switch (season) {
      case Season.spring:
        effect = '繁栄+10 士気+5\nイベント発生率: 通常';
        break;
      case Season.summer:
        effect = '繁栄+15 士気-5\nイベント発生率: 低下';
        break;
      case Season.autumn:
        effect = '繁栄+5 士気+10\nイベント発生率: 高い';
        break;
      case Season.winter:
        effect = '繁栄-10 士気-15\nイベント発生率: 非常に低い';
        break;
    }

    return Text(
      effect,
      style: const TextStyle(fontSize: 14, height: 1.8),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value/100',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildEncounterCard(
    String type,
    String name,
    String description,
    int difficulty,
    int reward,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('難易度: $difficulty/5'),
                Text('報酬: ${reward}G'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
