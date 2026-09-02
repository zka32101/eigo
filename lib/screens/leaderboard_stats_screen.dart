import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';

/// Display leaderboard statistics and analytics
class LeaderboardStatsScreen extends ConsumerWidget {
  const LeaderboardStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(overallLeaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング統計'),
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
        data: (leaderboard) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top stats
                _TopStatsRow(leaderboard: leaderboard),
                const SizedBox(height: 24),

                // Top performers
                _TopPerformers(leaderboard: leaderboard),
                const SizedBox(height: 24),

                // Grade distribution
                _GradeDistribution(leaderboard: leaderboard),
                const SizedBox(height: 24),

                // Score distribution
                _ScoreDistribution(leaderboard: leaderboard),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Top stats row
class _TopStatsRow extends StatelessWidget {
  final GroupedLeaderboard leaderboard;

  const _TopStatsRow({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: '総エントリー',
            value: leaderboard.entryCount.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'トップスコア',
            value: leaderboard.topScore.toStringAsFixed(0),
            icon: Icons.emoji_events,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }
}

/// Stat card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Top performers section
class _TopPerformers extends StatelessWidget {
  final GroupedLeaderboard leaderboard;

  const _TopPerformers({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    final topThree = leaderboard.entries.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'トップ3',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < topThree.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _TopPerformerCard(
              entry: topThree[i],
              rank: i + 1,
            ),
          ),
      ],
    );
  }
}

/// Top performer card
class _TopPerformerCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _TopPerformerCard({
    required this.entry,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final medal = ['🥇', '🥈', '🥉'][rank - 1];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(medal, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.userName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Lv.${entry.level} · ${entry.grade}年',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Text(
              entry.getScore().toStringAsFixed(0),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grade distribution
class _GradeDistribution extends StatelessWidget {
  final GroupedLeaderboard leaderboard;

  const _GradeDistribution({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    // Count users by grade
    final gradeCounts = <int, int>{};
    for (final entry in leaderboard.entries) {
      gradeCounts[entry.grade] = (gradeCounts[entry.grade] ?? 0) + 1;
    }

    final sortedGrades = gradeCounts.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学年別分布',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        for (final grade in sortedGrades)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _DistributionBar(
              label: '$grade年生',
              count: gradeCounts[grade] ?? 0,
              total: leaderboard.entryCount,
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}

/// Distribution bar
class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _DistributionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 24,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '$count (${(percentage * 100).toStringAsFixed(0)}%)',
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Score distribution
class _ScoreDistribution extends StatelessWidget {
  final GroupedLeaderboard leaderboard;

  const _ScoreDistribution({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    if (leaderboard.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate statistics
    final scores = leaderboard.entries.map((e) => e.getScore()).toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'スコア統計',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _ScoreStat(
              label: '最高スコア',
              value: maxScore.toStringAsFixed(0),
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _ScoreStat(
              label: '平均スコア',
              value: avgScore.toStringAsFixed(0),
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _ScoreStat(
              label: '最低スコア',
              value: minScore.toStringAsFixed(0),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Score stat
class _ScoreStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ),
      ],
    );
  }
}
