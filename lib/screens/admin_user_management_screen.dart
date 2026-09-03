import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_dashboard_model.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin user management screen
class AdminUserManagementScreen extends ConsumerWidget {
  const AdminUserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ユーザー管理'),
          bottom: TabBar(
            tabs: const [
              Tab(text: '統計'),
              Tab(text: 'アクティブユーザー'),
              Tab(text: '非アクティブ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UserStatsTab(),
            _ActiveUsersTab(),
            _InactiveUsersTab(),
          ],
        ),
      ),
    );
  }
}

/// User statistics tab
class _UserStatsTab extends ConsumerWidget {
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
              _StatCard(
                title: '総ユーザー数',
                value: stats.totalUsers.toString(),
                color: Colors.blue,
                icon: Icons.people,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'アクティブユーザー',
                value: stats.activeUsers.toString(),
                color: Colors.green,
                icon: Icons.person_add,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: '非アクティブユーザー',
                value: stats.inactiveUsers.toString(),
                color: Colors.orange,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'チャーンユーザー',
                value: stats.churned.toString(),
                color: Colors.red,
                icon: Colors.person_remove,
              ),
              const SizedBox(height: 24),
              _SectionTitle('新規ユーザー'),
              const SizedBox(height: 12),
              _InfoRow(
                label: '今週',
                value: stats.newThisWeek.toString(),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: '今月',
                value: stats.newThisMonth.toString(),
              ),
              const SizedBox(height: 24),
              _SectionTitle('エンゲージメント'),
              const SizedBox(height: 12),
              _EngagementBreakdown(
                high: stats.highEngagement,
                medium: stats.mediumEngagement,
                low: stats.lowEngagement,
              ),
              const SizedBox(height: 24),
              _SectionTitle('プレイ統計'),
              const SizedBox(height: 12),
              _InfoRow(
                label: '平均レベル',
                value: stats.averageLevel.toStringAsFixed(1),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: '平均セッション数',
                value: stats.avgSessionsPerUser.toStringAsFixed(1),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: '平均プレイ時間',
                value: '${stats.avgPlayTimePerUser.toStringAsFixed(0)}分',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'コンバージョンレート',
                value: '${(stats.conversionRate * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Active users tab
class _ActiveUsersTab extends ConsumerWidget {
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
            child: Text('データなし'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'アクティブユーザー',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stats.activeUsers.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: stats.activeUsers / stats.totalUsers,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '総ユーザーの ${((stats.activeUsers / stats.totalUsers) * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'エンゲージメント分布',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _UserTile(
              label: '高エンゲージメント',
              count: stats.highEngagement,
              color: Colors.green,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 8),
            _UserTile(
              label: '中エンゲージメント',
              count: stats.mediumEngagement,
              color: Colors.blue,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 8),
            _UserTile(
              label: '低エンゲージメント',
              count: stats.lowEngagement,
              color: Colors.orange,
              icon: Icons.trending_down,
            ),
          ],
        );
      },
    );
  }
}

/// Inactive users tab
class _InactiveUsersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inactiveAsync = ref.watch(inactiveUsersProvider(30));

    return inactiveAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (inactiveUsers) {
        if (inactiveUsers.isEmpty) {
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
                  '非アクティブなユーザーなし',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inactiveUsers.length,
          itemBuilder: (context, index) {
            final user = inactiveUsers[index];
            return _InactiveUserCard(
              userId: user['userId'],
              email: user['email'] ?? 'N/A',
              lastActive: user['lastActiveAt'] != null
                  ? DateTime.parse(user['lastActiveAt'])
                  : null,
              level: user['level'] ?? 0,
            );
          },
        );
      },
    );
  }
}

/// Stat card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
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
              color: color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
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

/// Info row
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Engagement breakdown
class _EngagementBreakdown extends StatelessWidget {
  final int high;
  final int medium;
  final int low;

  const _EngagementBreakdown({
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
          children: [
            _EngagementBar(
              label: '高',
              count: high,
              total: total,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _EngagementBar(
              label: '中',
              count: medium,
              total: total,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _EngagementBar(
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

/// Engagement bar
class _EngagementBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _EngagementBar({
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
        SizedBox(width: 40, child: Text(label)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// User tile
class _UserTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _UserTile({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inactive user card
class _InactiveUserCard extends StatelessWidget {
  final String userId;
  final String email;
  final DateTime? lastActive;
  final int level;

  const _InactiveUserCard({
    required this.userId,
    required this.email,
    required this.lastActive,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final daysInactive = lastActive != null
        ? DateTime.now().difference(lastActive!).inDays
        : 0;

    return Card(
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
                        email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $userId',
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text('Lv.$level'),
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$daysInactive日間非アクティブ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('ユーザーデータをエクスポート'),
                      onTap: () {},
                    ),
                    PopupMenuItem(
                      child: const Text('アカウント削除'),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
