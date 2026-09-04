import 'package:flutter/material.dart';
import 'package:eigo/models/npc_registry.dart';
import 'package:eigo/models/quest_progression_system.dart';
import 'package:eigo/models/quest_branching_system.dart';
import 'package:eigo/models/event_system.dart';

/// クエスト進行システムのデモンストレーション
/// マルチステップクエスト、ブランチング、リワードシステムを展示
class QuestProgressionExample extends StatefulWidget {
  const QuestProgressionExample({Key? key}) : super(key: key);

  @override
  State<QuestProgressionExample> createState() =>
      _QuestProgressionExampleState();
}

class _QuestProgressionExampleState extends State<QuestProgressionExample> {
  late NPCRegistry _npcRegistry;
  late QuestProgressionSystem _questSystem;
  late QuestBranchingSystem _branchingSystem;
  late GameEventSystem _eventSystem;

  String? _selectedQuestId;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _npcRegistry = NPCRegistry.getInstance();
    _questSystem = QuestProgressionSystem.getInstance();
    _branchingSystem = QuestBranchingSystem.getInstance();
    _eventSystem = GameEventSystem.getInstance();

    // システムを初期化
    _npcRegistry.initializeAllNPCs();
    _questSystem.initialize();
    _branchingSystem.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Progression System'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Column(
        children: [
          // タブバー
          Container(
            color: Colors.teal.shade50,
            child: Row(
              children: [
                _buildTab(0, 'Available', Icons.list),
                _buildTab(1, 'Active', Icons.play_circle),
                _buildTab(2, 'Completed', Icons.check_circle),
                _buildTab(3, 'Progression', Icons.trending_up),
              ],
            ),
          ),
          // コンテンツエリア
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildAvailableTab(),
                _buildActiveTab(),
                _buildCompletedTab(),
                _buildProgressionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.teal.shade50,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.teal : Colors.transparent,
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

  /// 利用可能なクエストタブ
  Widget _buildAvailableTab() {
    final available = _questSystem.getAvailableQuests();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Quests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (available.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'All quests completed! Check back later for more.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...available.map((quest) {
              final npc = _npcRegistry.getNPC(quest.giverNPCId);
              return _buildQuestCard(quest, npc, isAvailable: true);
            }),
        ],
      ),
    );
  }

  /// アクティブなクエストタブ
  Widget _buildActiveTab() {
    final active = _questSystem.getAllActiveQuests();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Quests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (active.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No active quests. Accept a quest to get started!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...active.map((progress) {
              final npc = _npcRegistry.getNPC(progress.questDefinition.giverNPCId);
              return _buildActiveQuestCard(progress, npc);
            }),
        ],
      ),
    );
  }

  /// 完了したクエストタブ
  Widget _buildCompletedTab() {
    final count = _questSystem.getCompletedQuestCount();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed Quests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: $count quests completed',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quest Completion Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildStatRow('Total Completed', '$count', Colors.green),
                _buildStatRow('Estimated XP Gained', '${count * 300}', Colors.blue),
                _buildStatRow('Quest Chains Completed', '${(count / 3).toStringAsFixed(1)}', Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// クエスト進行タブ
  Widget _buildProgressionTab() {
    final active = _questSystem.getAllActiveQuests();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quest Progression Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (active.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No active quests to show progress for.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...active.map((progress) {
              return _buildProgressionCard(progress);
            }),
        ],
      ),
    );
  }

  /// クエストカードを構築
  Widget _buildQuestCard(
    QuestDefinition quest,
    NPCData? npc, {
    required bool isAvailable,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
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
                      quest.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From: ${npc?.name ?? quest.giverNPCId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(quest.difficultyLevel),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quest.getDifficultyText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quest.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.steps, size: 16, color: Colors.teal),
              const SizedBox(width: 4),
              Text(
                '${quest.steps.length} steps',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Icon(Icons.timer, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                '~${quest.getEstimatedMinutes()} min',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _questSystem.acceptQuest(quest.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${quest.title} accepted!'),
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() => _selectedTabIndex = 1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
            ),
            child: const Text(
              'Accept Quest',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// アクティブなクエストカードを構築
  Widget _buildActiveQuestCard(QuestProgress progress, NPCData? npc) {
    final currentStep = progress.getCurrentStep();
    final branches = _branchingSystem.getQuestBranches(progress.questDefinition.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress.questDefinition.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress.getProgressPercentage() * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.getProgressPercentage(),
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Colors.orange),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${currentStep.title}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentStep.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          if (branches.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quest Approach:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ...branches.map((branch) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        _branchingSystem.chooseBranch(
                          progress.questDefinition.id,
                          branch.id,
                        );
                        _questSystem.completeStep(
                          progress.questDefinition.id,
                          currentStep.id,
                        );

                        final reward = _branchingSystem
                            .calculateReward(progress.questDefinition.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${branch.title}: ${reward.getResultText()}',
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );

                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            branch.choice,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            )
          else
            ElevatedButton(
              onPressed: () {
                _questSystem.completeStep(
                  progress.questDefinition.id,
                  currentStep.id,
                );
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
              ),
              child: const Text(
                'Complete Step',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// 進行状況カードを構築
  Widget _buildProgressionCard(QuestProgress progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progress.questDefinition.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Steps Completed: ${progress.completedSteps.length} / ${progress.questDefinition.steps.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...progress.questDefinition.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = progress.completedSteps.contains(step.id);
            final isCurrent = index == progress.currentStepIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? Colors.orange
                              : Colors.grey,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isCompleted
                                ? Colors.green
                                : isCurrent
                                    ? Colors.orange
                                    : Colors.grey,
                          ),
                        ),
                        Text(
                          step.getTypeText(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 統計行を構築
  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 難易度から色を取得
  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
