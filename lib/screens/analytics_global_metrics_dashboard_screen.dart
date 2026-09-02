import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../providers/analytics_provider.dart';

/// Global metrics dashboard for administrators
class AnalyticsGlobalMetricsDashboardScreen extends ConsumerWidget {
  const AnalyticsGlobalMetricsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('グローバルメトリクス'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'ゲーム全体'),
              Tab(text: 'プレイヤー'),
              Tab(text: 'エンゲージメント'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GameMetricsView(date: DateTime.now()),
            _PlayerMetricsView(),
            _EngagementMetricsView(),
          ],
        ),
      ),
    );
  }
}

/// Game-wide metrics view
class _GameMetricsView extends ConsumerWidget {
  final DateTime date;

  const _GameMetricsView({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyMetricsAsync = ref.watch(
      dailyMetricsProvider(date),
    );

    return dailyMetricsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (metrics) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('ユーザーメトリクス'),
              const SizedBox(height: 12),
              _KPICard(
                title: '日次アクティブユーザー (DAU)',
                value: '${metrics.dailyActiveUsers}',
                icon: Icons.people,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: '月次アクティブユーザー (MAU)',
                value: '${metrics.monthlyActiveUsers}',
                icon: Icons.groups,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: '新規ユーザー',
                value: '${metrics.newUsersToday}',
                icon: Icons.person_add,
              ),
              const SizedBox(height: 24),
              _SectionTitle('セッションメトリクス'),
              const SizedBox(height: 12),
              _KPICard(
                title: '総セッション数',
                value: '${metrics.totalSessions}',
                icon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: '平均セッション時間',
                value: '${metrics.averageSessionDuration}分',
                icon: Icons.schedule,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: '平均セッション数',
                value: '${metrics.avgSessionsPerUser.toStringAsFixed(2)}',
                subtitle: 'ユーザーあたり',
                icon: Icons.bar_chart,
              ),
              const SizedBox(height: 24),
              _SectionTitle('学習メトリクス'),
              const SizedBox(height: 12),
              _KPICard(
                title: '総会話数',
                value: '${metrics.totalConversations}',
                icon: Icons.chat,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: '会話成功率',
                value: '${(metrics.conversationSuccessRate * 100).toStringAsFixed(1)}%',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: 'XP総獲得',
                value: '${metrics.totalXpAwarded}',
                icon: Icons.star,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Player retention and progression view
class _PlayerMetricsView extends ConsumerWidget {
  const _PlayerMetricsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyMetricsAsync = ref.watch(
      dailyMetricsProvider(DateTime.now()),
    );

    return dailyMetricsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (metrics) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('リテンションメトリクス'),
              const SizedBox(height: 12),
              _KPICard(
                title: 'Day 1 リテンション',
                value: '${(metrics.day1Retention * 100).toStringAsFixed(1)}%',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: 'Day 7 リテンション',
                value: '${(metrics.day7Retention * 100).toStringAsFixed(1)}%',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: 'Day 30 リテンション',
                value: '${(metrics.day30Retention * 100).toStringAsFixed(1)}%',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 24),
              _SectionTitle('チャーンメトリクス'),
              const SizedBox(height: 12),
              _KPICard(
                title: '日次チャーンレート',
                value: '${(metrics.dailyChurnRate * 100).toStringAsFixed(1)}%',
                icon: Icons.trending_down,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: '休止ユーザー',
                value: '${metrics.churnedUsers}',
                subtitle: '30日未活動',
                icon: Icons.person_off,
              ),
              const SizedBox(height: 24),
              _SectionTitle('進捗メトリクス'),
              const SizedBox(height: 12),
              _KPICard(
                title: '平均レベル',
                value: '${metrics.averagePlayerLevel.toStringAsFixed(1)}',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: 'アチーブメント完了率',
                value: '${(metrics.achievementCompletionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.emoji_events,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Engagement and competition view
class _EngagementMetricsView extends ConsumerWidget {
  const _EngagementMetricsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyMetricsAsync = ref.watch(
      dailyMetricsProvider(DateTime.now()),
    );

    return dailyMetricsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (metrics) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('エンゲージメントスコア'),
              const SizedBox(height: 12),
              _KPICard(
                title: '平均エンゲージメント',
                value: '${metrics.averageEngagementScore.toStringAsFixed(1)}/100',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _EngagementDistributionCard(
                highEngagementUsers: metrics.highEngagementUsers,
                mediumEngagementUsers: metrics.mediumEngagementUsers,
                lowEngagementUsers: metrics.lowEngagementUsers,
              ),
              const SizedBox(height: 24),
              _SectionTitle('社会的メトリクス'),
              const SizedBox(height: 12),
              _KPICard(
                title: '友人リクエスト送信',
                value: '${metrics.friendRequestsSent}',
                icon: Icons.person_add,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: 'チャレンジ実施',
                value: '${metrics.challengesInitiated}',
                icon: Icons.local_play,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: 'チャレンジ完了率',
                value: '${(metrics.challengeCompletionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.check_circle,
              ),
              const SizedBox(height: 24),
              _SectionTitle('ストリーク'),
              const SizedBox(height: 12),
              _KPICard(
                title: 'アクティブストリーク',
                value: '${metrics.activeStreakUsers}',
                subtitle: 'ユーザー数',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 12),
              _KPICard(
                title: '平均ストリーク',
                value: '${metrics.averageStreakDays.toStringAsFixed(1)}日',
                icon: Icons.show_chart,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// KPI card for displaying key metrics
class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;

  const _KPICard({
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

/// Engagement distribution chart
class _EngagementDistributionCard extends StatelessWidget {
  final int highEngagementUsers;
  final int mediumEngagementUsers;
  final int lowEngagementUsers;

  const _EngagementDistributionCard({
    required this.highEngagementUsers,
    required this.mediumEngagementUsers,
    required this.lowEngagementUsers,
  });

  @override
  Widget build(BuildContext context) {
    final total = highEngagementUsers + mediumEngagementUsers + lowEngagementUsers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'エンゲージメント分布',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _DistributionBar(
              label: '高',
              count: highEngagementUsers,
              total: total,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _DistributionBar(
              label: '中',
              count: mediumEngagementUsers,
              total: total,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _DistributionBar(
              label: '低',
              count: lowEngagementUsers,
              total: total,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

/// Distribution bar for engagement visualization
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(label),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 20,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count users',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
