import 'package:flutter/material.dart';
import 'package:eigo/models/npc_registry.dart';
import 'package:eigo/models/npc_relationship_system.dart';
import 'package:eigo/models/faction_system.dart';
import 'package:eigo/models/event_system.dart';
import 'package:eigo/data/npc_events.dart';

/// NPC関係・イベントシステムのデモンストレーション
/// - NPC間の相互作用
/// - ファクション評判システム
/// - イベントトリガーシステム
/// - マルチNPC対話
class NPCRelationshipsExample extends StatefulWidget {
  const NPCRelationshipsExample({Key? key}) : super(key: key);

  @override
  State<NPCRelationshipsExample> createState() =>
      _NPCRelationshipsExampleState();
}

class _NPCRelationshipsExampleState extends State<NPCRelationshipsExample> {
  late NPCRegistry _npcRegistry;
  late NPCRelationshipSystem _relationshipSystem;
  late FactionSystem _factionSystem;
  late GameEventSystem _eventSystem;

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _npcRegistry = NPCRegistry.getInstance();
    _relationshipSystem = NPCRelationshipSystem.getInstance();
    _factionSystem = FactionSystem.getInstance();
    _eventSystem = GameEventSystem.getInstance();

    // システムを初期化
    _npcRegistry.initializeAllNPCs();
    _relationshipSystem.initialize();
    _factionSystem.initialize();

    // イベントリスナーを登録
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventSystem.addEventListener(
      EventType.affectionMilestone,
      (event) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Milestone: ${event.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );

    _eventSystem.addEventListener(
      EventType.relationshipChanged,
      (event) {
        setState(() {}); // UI更新
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NPC Relationships & Events'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Column(
        children: [
          // タブバー
          Container(
            color: Colors.deepPurple.shade50,
            child: Row(
              children: [
                _buildTab(0, 'Relationships', Icons.people),
                _buildTab(1, 'Factions', Icons.shield),
                _buildTab(2, 'Events', Icons.event),
                _buildTab(3, 'Multi-NPC', Icons.group),
              ],
            ),
          ),
          // コンテンツエリア
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildRelationshipsTab(),
                _buildFactionsTab(),
                _buildEventsTab(),
                _buildMultiNPCTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// タブボタンを構築
  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.deepPurple : Colors.deepPurple.shade50,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.deepPurple : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 関係タブ
  Widget _buildRelationshipsTab() {
    final closestPairs = _relationshipSystem.getClosestPairs(limit: 10);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NPC Relationships',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...closestPairs.map((pair) {
            final npc1 = _npcRegistry.getNPC(pair.npcId1);
            final npc2 = _npcRegistry.getNPC(pair.npcId2);

            if (npc1 == null || npc2 == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${npc1.name} ↔ ${npc2.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRelationshipColor(pair.relationship),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pair.relationship.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pair.relationship / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        _getRelationshipColor(pair.relationship),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${pair.getStatusText()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _relationshipSystem.updateRelationship(
                            pair.npcId1,
                            pair.npcId2,
                            10,
                          );
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          '+10',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _relationshipSystem.updateRelationship(
                            pair.npcId1,
                            pair.npcId2,
                            -10,
                          );
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          '-10',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// ファクションタブ
  Widget _buildFactionsTab() {
    final factions = _factionSystem.getAllFactions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Faction Reputation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...factions.map((faction) {
            final status = _factionSystem.getFactionStatus(faction.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faction.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    faction.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reputation: ${status.reputation}/100',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getReputationColor(status.reputation),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (status.reputation + 100) / 200,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        _getReputationColor(status.reputation),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (status.availablePerks.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Perks:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...status.availablePerks.map((perk) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    perk.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    perk.description,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _factionSystem.updateReputation(faction.id, 20);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          '+20',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _factionSystem.updateReputation(faction.id, -20);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          '-20',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// イベントタブ
  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events System',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Events',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final event =
                        NPCEventRegistry.createAffectionMilestoneEvent(
                      'aria_001',
                      80,
                      'Aria',
                    );
                    _eventSystem.fireEvent(event);
                    setState(() {});
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('Trigger Affection Milestone'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    final event =
                        NPCEventRegistry.createRelationshipChangedEvent(
                      'aria_001',
                      'luna_002',
                      70,
                      'neutral',
                    );
                    _eventSystem.fireEvent(event);
                    setState(() {});
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Trigger Relationship Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    final event = NPCEventRegistry.createNPCMeetingEvent(
                      ['aria_001', 'luna_002'],
                      'Knowledge Exchange',
                    );
                    _eventSystem.fireEvent(event);
                    setState(() {});
                  },
                  icon: const Icon(Icons.meeting_room),
                  label: const Text('Trigger NPC Meeting'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recent Events',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final history = _eventSystem.getEventHistory();
              if (history.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No events yet. Trigger events above to see them here.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return Column(
                children: history.reversed.take(5).map((event) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// マルチNPCタブ
  Widget _buildMultiNPCTab() {
    final scenes = [
      MultiNPCDialogueExamples.ariaMeetsLuna,
      MultiNPCDialogueExamples.kaiMeetsEloise,
      MultiNPCDialogueExamples.thornMeetsZephyr,
      MultiNPCDialogueExamples.isabellaGroups,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Multi-NPC Interactions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...scenes.map((scene) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: scene.participantNpcIds.map((npcId) {
                      final npc = _npcRegistry.getNPC(npcId);
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            npc?.name ?? npcId,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  ...scene.exchanges.map((exchange) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exchange.speakerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.indigo,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              exchange.dialogue,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final event = NPCEventRegistry.createNPCMeetingEvent(
                        scene.participantNpcIds,
                        scene.title,
                      );
                      _eventSystem.fireEvent(event);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Scene triggered: ${scene.title}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                    ),
                    child: const Text(
                      'Trigger Scene',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 関係スコアから色を取得
  Color _getRelationshipColor(int value) {
    if (value >= 80) return Colors.red;
    if (value >= 60) return Colors.orange;
    if (value >= 40) return Colors.amber;
    if (value >= 20) return Colors.blue;
    return Colors.grey;
  }

  /// 評判スコアから色を取得
  Color _getReputationColor(int value) {
    if (value >= 80) return Colors.deepPurple;
    if (value >= 40) return Colors.blue;
    if (value >= 0) return Colors.green;
    if (value >= -40) return Colors.orange;
    return Colors.red;
  }
}
