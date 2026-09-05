/// アチーブメント・進行度システム例

import 'package:flutter/material.dart';
import '../models/achievements_progression_system.dart';

void main() {
  runApp(const AchievementsProgressionExample());
}

class AchievementsProgressionExample extends StatefulWidget {
  const AchievementsProgressionExample({Key? key}) : super(key: key);

  @override
  State<AchievementsProgressionExample> createState() =>
      _AchievementsProgressionExampleState();
}

class _AchievementsProgressionExampleState
    extends State<AchievementsProgressionExample> {
  final system = AchievementsProgressionSystem.getInstance();
  int selectedTabIndex = 0;
  final playerId = 'player_001';

  @override
  void initState() {
    super.initState();
    system.initialize();
    _addDemoAchievements();
  }

  void _addDemoAchievements() {
    system.unlockAchievement(playerId, 'first_victory');
    system.unlockAchievement(playerId, 'explorer');
    system.unlockAchievement(playerId, 'merchant');
    system.updateProgress(playerId, 'battles', 35, 'combat');
    system.updateProgress(playerId, 'gold', 7500, 'economy');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Achievements & Progression System',
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('アチーブメント・進行度システム')),
        body: IndexedStack(
          index: selectedTabIndex,
          children: [
            _buildOverviewTab(),
            _buildAchievementsTab(),
            _buildMilestonesTab(),
            _buildProgressTab(),
            _buildStatsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => selectedTabIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '概要'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'アチーブ'),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'マイル'),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: '進行'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: '統計'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final stats = system.getStatistics(playerId);
    final achievements = system.getPlayerAchievements(playerId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('プレイヤー進行状況',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (stats != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ランク: ${stats.getRank()}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('レベル: ${stats.getLevel()}',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text('ポイント',
                                style: TextStyle(fontSize: 12)),
                            Text('${stats.totalPoints}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stats.completionPercentage / 100,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'アチーブメント: ${stats.totalAchievements}/11 (${stats.completionPercentage}%)',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 16),
                  Text('獲得したアチーブメント: ${achievements.length}',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: achievements
                        .take(5)
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.amber)),
                            ))
                        .toList(),
                  ),
                ] else
                  const Text('プレイヤーデータが見つかりません'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = system.getPlayerAchievements(playerId);
    final allAchievements = system._achievements.values.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アチーブメント',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('獲得: ${achievements.length}/${allAchievements.length}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...allAchievements.map((achievement) {
          final unlocked = achievements.contains(achievement);
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
                            Text(achievement.name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(achievement.description,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (unlocked
                                  ? Colors.green
                                  : Colors.grey)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          unlocked ? '獲得済み' : 'ロック中',
                          style: TextStyle(
                            fontSize: 12,
                            color: unlocked ? Colors.green : Colors.grey,
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
                      Text('${achievement.points}ポイント',
                          style: const TextStyle(fontSize: 12)),
                      Text('条件: ${achievement.requirement}',
                          style: const TextStyle(fontSize: 12)),
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

  Widget _buildMilestonesTab() {
    final playerMilestones = system.getPlayerMilestones(playerId);
    final allMilestones = system.getAllMilestones();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('マイルストーン',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('達成: ${playerMilestones.length}/${allMilestones.length}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...allMilestones.values.map((milestone) {
          final achieved = playerMilestones.contains(milestone);
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
                          Text(milestone.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(milestone.description,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      if (achieved)
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('報酬: ${milestone.reward}G',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.amber)),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProgressTab() {
    final progress = system.getPlayerProgress(playerId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('進行度追跡',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('追跡中: ${progress.length}項目',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (progress.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('進行度データがありません',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ),
          )
        else
          ...progress.map((tracker) {
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
                        Text(tracker.category,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('${tracker.currentValue}/${tracker.maxValue}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: tracker.getProgress() / 100,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${tracker.getProgress()}% • ${tracker.getDaysElapsed()}日経過',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildStatsTab() {
    final stats = system.getStatistics(playerId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (stats != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('統計情報',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatRow('ランク', stats.getRank()),
                  _buildStatRow('レベル', '${stats.getLevel()}'),
                  _buildStatRow(
                      'アチーブメント', '${stats.totalAchievements}/11'),
                  _buildStatRow(
                      'マイルストーン', '${stats.totalMilestones}/5'),
                  _buildStatRow('総ポイント', '${stats.totalPoints}'),
                  _buildStatRow('総報酬', '${stats.totalRewards}G'),
                  _buildStatRow('完了度', '${stats.completionPercentage}%'),
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
                  const Text('進行状況の詳細',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(system.getDetailedProgress(playerId),
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
