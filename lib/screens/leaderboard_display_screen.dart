import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../providers/leaderboard_provider.dart';

/// Display leaderboard rankings
class LeaderboardDisplayScreen extends ConsumerWidget {
  final LeaderboardGroupType groupType;
  final String groupName;
  final int? grade;
  final int? year;
  final int? month;

  const LeaderboardDisplayScreen({
    Key? key,
    required this.groupType,
    required this.groupName,
    this.grade,
    this.year,
    this.month,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select appropriate provider based on group type
    final leaderboardAsync = _getLeaderboardProvider(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        elevation: 0,
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('エラー: $error'),
            ],
          ),
        ),
        data: (leaderboard) {
          if (leaderboard.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ランキングデータがありません',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(overallLeaderboardProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: leaderboard.entries.length,
              itemBuilder: (context, index) {
                final entry = leaderboard.entries[index];
                final isTopThree = index < 3;

                return _LeaderboardEntryCard(
                  entry: entry,
                  isTopThree: isTopThree,
                  index: index,
                );
              },
            ),
          );
        },
      ),
    );
  }

  AsyncValue<GroupedLeaderboard> _getLeaderboardProvider(WidgetRef ref) {
    switch (groupType) {
      case LeaderboardGroupType.overall:
        return ref.watch(overallLeaderboardProvider);
      case LeaderboardGroupType.byGrade:
        return ref.watch(gradeLeaderboardProvider(grade ?? 5));
      case LeaderboardGroupType.byStartMonth:
        return ref.watch(
          startMonthLeaderboardProvider((year ?? DateTime.now().year, month ?? 1)),
        );
      case LeaderboardGroupType.combined:
        return ref.watch(
          combinedLeaderboardProvider(
            (grade ?? 5, year ?? DateTime.now().year, month ?? 1),
          ),
        );
    }
  }
}

/// Leaderboard entry card
class _LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isTopThree;
  final int index;

  const _LeaderboardEntryCard({
    required this.entry,
    required this.isTopThree,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final score = entry.getScore();
    final medal = _getMedalIcon(index);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: isTopThree ? 4 : 1,
      child: Container(
        decoration: isTopThree
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _getMedalColor(index),
                  width: 2,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getMedalColor(index).withOpacity(0.2),
                  border: Border.all(
                    color: _getMedalColor(index),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: medal != null
                      ? Text(
                          medal,
                          style: const TextStyle(fontSize: 24),
                        )
                      : Text(
                          '${index + 1}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.grade,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lv.${entry.level}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.school,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.grade}年',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getMedalColor(index),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'XP: ${entry.totalXp}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber[700]!;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.amber[600]!;
      default:
        return Colors.blue;
    }
  }

  String? _getMedalIcon(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return null;
    }
  }
}
