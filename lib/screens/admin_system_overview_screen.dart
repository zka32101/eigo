import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_dashboard_model.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin system overview dashboard
class AdminSystemOverviewScreen extends ConsumerWidget {
  const AdminSystemOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('システム概要'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'ヘルス'),
              Tab(text: 'アラート'),
              Tab(text: 'ユーザー'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SystemHealthView(),
            _ActiveAlertsView(),
            _UserStatsView(),
          ],
        ),
      ),
    );
  }
}

/// System health tab
class _SystemHealthView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(systemHealthProvider);

    return healthAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (health) {
        if (health == null) {
          return Center(
            child: Text(
              'ヘルスデータが利用できません',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HealthScoreCard(
                score: health.systemHealth,
                isHealthy: health.isHealthy,
              ),
              const SizedBox(height: 24),
              _SectionTitle('コンポーネントヘルス'),
              const SizedBox(height: 12),
              _ComponentHealthBar(
                name: 'Firestore',
                health: health.firestoreHealth,
              ),
              const SizedBox(height: 12),
              _ComponentHealthBar(
                name: '認証',
                health: health.authHealth,
              ),
              const SizedBox(height: 12),
              _ComponentHealthBar(
                name: 'アナリティクス',
                health: health.analyticsHealth,
              ),
              const SizedBox(height: 24),
              _SectionTitle('リアルタイムメトリクス'),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'アクティブユーザー',
                value: '${health.activeUsers}/${health.totalUsers}',
                icon: Icons.people,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: '平均エンゲージメント',
                value: '${health.avgEngagement.toStringAsFixed(1)}/100',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'イベント/時間',
                value: '${health.eventsPerHour}',
                icon: Icons.speed,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: '平均応答時間',
                value: '${health.avgResponseTime.toStringAsFixed(0)}ms',
                icon: Icons.timer,
              ),
              const SizedBox(height: 24),
              if (health.warnings.isNotEmpty) ...[
                _SectionTitle('警告'),
                const SizedBox(height: 12),
                ...health.warnings
                    .map((w) => _WarningCard(warning: w))
                    .toList(),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Active alerts tab
class _ActiveAlertsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(activeAlertsProvider);

    return alertsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (alerts) {
        if (alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'アラートなし',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            return _AlertCard(
              alert: alerts[index],
              onResolve: () => _resolveAlert(ref, alerts[index].id),
            );
          },
        );
      },
    );
  }

  Future<void> _resolveAlert(WidgetRef ref, String alertId) async {
    // TODO: Get current admin user
    await resolveSystemAlert(
      ref,
      alertId: alertId,
      resolvedBy: 'admin_user',
    );
  }
}

/// User statistics tab
class _UserStatsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userManagementStatsProvider);

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (stats) {
        if (stats == null) {
          return Center(
            child: Text(
              'ユーザーデータが利用できません',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('ユーザーサマリー'),
              const SizedBox(height: 12),
              _MetricTile(
                label: '総ユーザー数',
                value: '${stats.totalUsers}',
                icon: Icons.people,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'アクティブユーザー',
                value: '${stats.activeUsers}',
                icon: Icons.person_add,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'チャーンユーザー',
                value: '${stats.churned}',
                icon: Icons.person_remove,
              ),
              const SizedBox(height: 24),
              _SectionTitle('新規ユーザー'),
              const SizedBox(height: 12),
              _MetricTile(
                label: '今週',
                value: '${stats.newThisWeek}',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: '今月',
                value: '${stats.newThisMonth}',
                icon: Icons.calendar_month,
              ),
              const SizedBox(height: 24),
              _SectionTitle('エンゲージメント分布'),
              const SizedBox(height: 12),
              _EngagementDistribution(
                high: stats.highEngagement,
                medium: stats.mediumEngagement,
                low: stats.lowEngagement,
              ),
              const SizedBox(height: 24),
              _SectionTitle('その他メトリクス'),
              const SizedBox(height: 12),
              _MetricTile(
                label: '平均レベル',
                value: '${stats.averageLevel.toStringAsFixed(1)}',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: '平均セッション数',
                value: '${stats.avgSessionsPerUser.toStringAsFixed(1)}',
                icon: Icons.play_circle,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: '平均プレイ時間',
                value: '${stats.avgPlayTimePerUser.toStringAsFixed(0)}分',
                icon: Icons.timer,
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'コンバージョンレート',
                value: '${(stats.conversionRate * 100).toStringAsFixed(1)}%',
                icon: Icons.monetization_on,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Health score card
class _HealthScoreCard extends StatelessWidget {
  final double score;
  final bool isHealthy;

  const _HealthScoreCard({
    required this.score,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHealthy ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'システムヘルス',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: color.withOpacity(0.1),
                  ),
                ),
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Chip(
              label: Text(isHealthy ? '健全' : '警告'),
              backgroundColor: color.withOpacity(0.2),
              labelStyle: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Component health bar
class _ComponentHealthBar extends StatelessWidget {
  final String name;
  final double health;

  const _ComponentHealthBar({
    required this.name,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    final color = health >= 80 ? Colors.green : health >= 60 ? Colors.orange : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name),
                Text(
                  '${health.toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: health / 100,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Metric tile
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alert card
class _AlertCard extends StatelessWidget {
  final SystemAlert alert;
  final VoidCallback onResolve;

  const _AlertCard({
    required this.alert,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(alert.severity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(_getSeverityLabel(alert.severity)),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '作成: ${_formatDate(alert.createdAt)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                ElevatedButton(
                  onPressed: onResolve,
                  child: const Text('解決'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  String _getSeverityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return '重大';
      case AlertSeverity.warning:
        return '警告';
      case AlertSeverity.info:
        return '情報';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Warning card
class _WarningCard extends StatelessWidget {
  final String warning;

  const _WarningCard({required this.warning});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                warning,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Engagement distribution
class _EngagementDistribution extends StatelessWidget {
  final int high;
  final int medium;
  final int low;

  const _EngagementDistribution({
    required this.high,
    required this.medium,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    final total = high + medium + low;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DistributionRow(
              label: '高',
              count: high,
              total: total,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _DistributionRow(
              label: '中',
              count: medium,
              total: total,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _DistributionRow(
              label: '低',
              count: low,
              total: total,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

/// Distribution row
class _DistributionRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _DistributionRow({
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
        SizedBox(width: 30, child: Text(label)),
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
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Section title
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
