import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../providers/analytics_provider.dart';

/// Player stats dashboard showing individual analytics metrics
class AnalyticsPlayerStatsDashboardScreen extends ConsumerWidget {
  final String userId;

  const AnalyticsPlayerStatsDashboardScreen({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('マイ統計'),
          bottom: TabBar(
            tabs: const [
              Tab(text: '日次'),
              Tab(text: '週次'),
              Tab(text: '月次'),
              Tab(text: 'すべて'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DailyStatsView(userId: userId),
            _WeeklyStatsView(userId: userId),
            _MonthlyStatsView(userId: userId),
            _AllTimeStatsView(userId: userId),
          ],
        ),
      ),
    );
  }
}

/// Daily statistics view
class _DailyStatsView extends ConsumerWidget {
  final String userId;

  const _DailyStatsView({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(
      playerAnalyticsProvider(userId),
    );

    return analyticsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (analytics) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricCard(
                title: '会話スコア',
                value: '${analytics.totalConversations}',
                subtitle: '成功率: ${(analytics.conversionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.chat,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'XP獲得',
                value: '${analytics.xpGained}',
                icon: Icons.star,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'コイン獲得',
                value: '${analytics.coinsGained}',
                icon: Icons.monetization_on,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'ストリーク',
                value: '${analytics.currentStreak}日',
                subtitle: '最長: ${analytics.longestStreak}日',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'アチーブメント',
                value: '${analytics.achievementsUnlocked}',
                subtitle: '進捗: ${analytics.totalAchievementProgress}%',
                icon: Icons.emoji_events,
              ),
              const SizedBox(height: 12),
              _EngagementScoreWidget(userId: userId),
            ],
          ),
        );
      },
    );
  }
}

/// Weekly statistics view
class _WeeklyStatsView extends ConsumerWidget {
  final String userId;

  const _WeeklyStatsView({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(
      playerAnalyticsProvider(userId),
    );

    return analyticsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (analytics) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricCard(
                title: '平均セッション時間',
                value: '${analytics.averageSessionDuration}分',
                icon: Icons.schedule,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'セッション数',
                value: '${analytics.sessionCount}',
                icon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'チャレンジ完了',
                value: '${analytics.challengesCompleted}',
                subtitle: '勝率: ${analytics.challengeWinRate}%',
                icon: Icons.local_play,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: '友人インタラクション',
                value: '${analytics.totalFriendInteractions}',
                icon: Icons.people,
              ),
              const SizedBox(height: 12),
              _EngagementScoreWidget(userId: userId),
            ],
          ),
        );
      },
    );
  }
}

/// Monthly statistics view
class _MonthlyStatsView extends ConsumerWidget {
  final String userId;

  const _MonthlyStatsView({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(
      playerAnalyticsProvider(userId),
    );

    return analyticsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (analytics) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricCard(
                title: 'アクティブ日数',
                value: '${analytics.daysActive}日',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'レベルアップ',
                value: '${analytics.levelGains}',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'ランク',
                value: '#${analytics.currentRank}',
                subtitle: 'ベスト: #${analytics.bestRankAchieved}',
                icon: Icons.leaderboard,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'ランク変動',
                value: '${analytics.rankChanges}',
                icon: Icons.swap_vert,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'プレイ時間',
                value: '${(analytics.totalPlayTime / 60).toStringAsFixed(1)}時間',
                icon: Icons.timer,
              ),
              const SizedBox(height: 12),
              _EngagementScoreWidget(userId: userId),
            ],
          ),
        );
      },
    );
  }
}

/// All-time statistics view
class _AllTimeStatsView extends ConsumerWidget {
  final String userId;

  const _AllTimeStatsView({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(
      playerAnalyticsProvider(userId),
    );

    return analyticsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (analytics) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('学習進捗'),
              const SizedBox(height: 12),
              _MetricCard(
                title: '総会話数',
                value: '${analytics.totalConversations}',
                subtitle: '成功率: ${(analytics.conversionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.chat,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: '総XP',
                value: '${analytics.xpGained}',
                icon: Icons.star,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: '総コイン',
                value: '${analytics.coinsGained}',
                icon: Icons.monetization_on,
              ),
              const SizedBox(height: 24),
              _SectionTitle('社会的活動'),
              const SizedBox(height: 12),
              _MetricCard(
                title: '友人追加',
                value: '${analytics.friendsAdded}',
                icon: Icons.person_add,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'チャレンジ作成',
                value: '${analytics.challengesCreated}',
                icon: Icons.add_circle_outline,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'チャレンジ完了',
                value: '${analytics.challengesCompleted}',
                subtitle: '勝率: ${analytics.challengeWinRate}%',
                icon: Icons.local_play,
              ),
              const SizedBox(height: 24),
              _SectionTitle('エンゲージメント'),
              const SizedBox(height: 12),
              _MetricCard(
                title: '総セッション数',
                value: '${analytics.sessionCount}',
                icon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: '総プレイ時間',
                value: '${(analytics.totalPlayTime / 60).toStringAsFixed(1)}時間',
                icon: Icons.timer,
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: '最長ストリーク',
                value: '${analytics.longestStreak}日',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 12),
              _EngagementScoreWidget(userId: userId),
            ],
          ),
        );
      },
    );
  }
}

/// Metric display card
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

/// Engagement score display
class _EngagementScoreWidget extends ConsumerWidget {
  final String userId;

  const _EngagementScoreWidget({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engagementAsync = ref.watch(
      engagementScoreProvider(userId),
    );

    return engagementAsync.when(
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'エンゲージメント',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('エラー: $error'),
        ),
      ),
      data: (engagement) {
        final tierColor = _getTierColor(engagement.tier, context);
        final tierLabel = _getTierLabel(engagement.tier);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 32,
                      color: tierColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'エンゲージメント',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${engagement.score.toStringAsFixed(1)}/100',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Chip(
                  label: Text(tierLabel),
                  backgroundColor: tierColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: tierColor),
                ),
                const SizedBox(height: 12),
                _EngagementComponentBar(
                  label: '会話',
                  value: engagement.conversationScore,
                ),
                const SizedBox(height: 8),
                _EngagementComponentBar(
                  label: '社会',
                  value: engagement.socialScore,
                ),
                const SizedBox(height: 8),
                _EngagementComponentBar(
                  label: '進捗',
                  value: engagement.progressionScore,
                ),
                const SizedBox(height: 8),
                _EngagementComponentBar(
                  label: '一貫性',
                  value: engagement.consistencyScore,
                ),
                const SizedBox(height: 8),
                _EngagementComponentBar(
                  label: 'リテンション',
                  value: engagement.retentionScore,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTierColor(EngagementTier tier, BuildContext context) {
    switch (tier) {
      case EngagementTier.churned:
        return Colors.grey;
      case EngagementTier.low:
        return Colors.orange;
      case EngagementTier.medium:
        return Colors.blue;
      case EngagementTier.high:
        return Colors.green;
      case EngagementTier.hardcore:
        return Colors.red;
    }
  }

  String _getTierLabel(EngagementTier tier) {
    switch (tier) {
      case EngagementTier.churned:
        return '休止中';
      case EngagementTier.low:
        return '低';
      case EngagementTier.medium:
        return '中';
      case EngagementTier.high:
        return '高';
      case EngagementTier.hardcore:
        return 'ハードコア';
    }
  }
}

/// Component score progress bar
class _EngagementComponentBar extends StatelessWidget {
  final String label;
  final double value;

  const _EngagementComponentBar({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '${value.toStringAsFixed(0)}',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
