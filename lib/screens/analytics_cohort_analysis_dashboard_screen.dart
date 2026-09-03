import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../providers/analytics_provider.dart';

/// Cohort analysis dashboard showing retention and progression
class AnalyticsCohortAnalysisDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsCohortAnalysisDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsCohortAnalysisDashboardScreen> createState() =>
      _AnalyticsCohortAnalysisDashboardScreenState();
}

class _AnalyticsCohortAnalysisDashboardScreenState
    extends ConsumerState<AnalyticsCohortAnalysisDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedCohortDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedCohortDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コーホート分析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'リテンション'),
            Tab(text: '進捗'),
            Tab(text: 'エンゲージメント'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RetentionCurveView(cohortDate: _selectedCohortDate),
          _ProgressionView(cohortDate: _selectedCohortDate),
          _EngagementTrendView(cohortDate: _selectedCohortDate),
        ],
      ),
    );
  }
}

/// Retention curve view
class _RetentionCurveView extends ConsumerWidget {
  final DateTime cohortDate;

  const _RetentionCurveView({required this.cohortDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cohortAsync = ref.watch(
      cohortAnalysisProvider(cohortDate),
    );

    return cohortAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (cohort) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CohortHeaderCard(
                cohortDate: cohort.cohortDate,
                cohortSize: cohort.cohortSize,
              ),
              const SizedBox(height: 24),
              _SectionTitle('週別リテンション曲線'),
              const SizedBox(height: 12),
              _RetentionCurveChart(
                retentionByWeek: cohort.retentionByWeek,
              ),
              const SizedBox(height: 24),
              _SectionTitle('リテンション統計'),
              const SizedBox(height: 12),
              _RetentionStatsCards(
                retentionByWeek: cohort.retentionByWeek,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Progression view
class _ProgressionView extends ConsumerWidget {
  final DateTime cohortDate;

  const _ProgressionView({required this.cohortDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cohortAsync = ref.watch(
      cohortAnalysisProvider(cohortDate),
    );

    return cohortAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (cohort) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CohortHeaderCard(
                cohortDate: cohort.cohortDate,
                cohortSize: cohort.cohortSize,
              ),
              const SizedBox(height: 24),
              _SectionTitle('レベル到達率'),
              const SizedBox(height: 12),
              _LevelProgressCard(
                label: 'レベル5',
                reachRate: cohort.lvl5ReachRate,
              ),
              const SizedBox(height: 12),
              _LevelProgressCard(
                label: 'レベル10',
                reachRate: cohort.lvl10ReachRate,
              ),
              const SizedBox(height: 12),
              _LevelProgressCard(
                label: 'レベル20',
                reachRate: cohort.lvl20ReachRate,
              ),
              const SizedBox(height: 24),
              _SectionTitle('レベル別到達率'),
              const SizedBox(height: 12),
              _LevelProgressionGrid(
                levelReachRates: cohort.levelReachRates,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Engagement trend view
class _EngagementTrendView extends ConsumerWidget {
  final DateTime cohortDate;

  const _EngagementTrendView({required this.cohortDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cohortAsync = ref.watch(
      cohortAnalysisProvider(cohortDate),
    );

    return cohortAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('エラー: $error'),
      ),
      data: (cohort) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CohortHeaderCard(
                cohortDate: cohort.cohortDate,
                cohortSize: cohort.cohortSize,
              ),
              const SizedBox(height: 24),
              _SectionTitle('日別エンゲージメント'),
              const SizedBox(height: 12),
              _EngagementTrendChart(
                engagementByDay: cohort.engagementByDay,
              ),
              const SizedBox(height: 24),
              _SectionTitle('エンゲージメント統計'),
              const SizedBox(height: 12),
              _EngagementStatsCards(
                engagementByDay: cohort.engagementByDay,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Cohort header card
class _CohortHeaderCard extends StatelessWidget {
  final DateTime cohortDate;
  final int cohortSize;

  const _CohortHeaderCard({
    required this.cohortDate,
    required this.cohortSize,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${cohortDate.year}年${cohortDate.month}月${cohortDate.day}日';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'コーホート情報',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '開始日',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'サイズ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cohortSize ユーザー',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Retention curve chart
class _RetentionCurveChart extends StatelessWidget {
  final Map<int, double> retentionByWeek;

  const _RetentionCurveChart({required this.retentionByWeek});

  @override
  Widget build(BuildContext context) {
    if (retentionByWeek.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'データなし',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: CustomPaint(
                painter: _RetentionCurvePainter(
                  data: retentionByWeek,
                  context: context,
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 16),
            _RetentionLegend(
              retentionByWeek: retentionByWeek,
            ),
          ],
        ),
      ),
    );
  }
}

/// Retention curve painter
class _RetentionCurvePainter extends CustomPainter {
  final Map<int, double> data;
  final BuildContext context;

  _RetentionCurvePainter({
    required this.data,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Theme.of(context).primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final padding = 40.0;
    final plotWidth = size.width - (padding * 2);
    final plotHeight = size.height - (padding * 2);

    // Draw axes
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      Paint()..color = Colors.grey[400]!,
    );
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      Paint()..color = Colors.grey[400]!,
    );

    // Draw grid
    for (int i = 0; i <= 10; i++) {
      final y = size.height - padding - (plotHeight / 10 * i);
      canvas.drawLine(
        Offset(padding - 5, y),
        Offset(size.width - padding, y),
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 0.5,
      );
    }

    // Draw data points
    final sortedKeys = data.keys.toList()..sort();
    if (sortedKeys.isEmpty) return;

    final maxWeek = sortedKeys.last.toDouble();
    final points = <Offset>[];

    for (final week in sortedKeys) {
      final x = padding + (plotWidth / maxWeek * week);
      final y = size.height - padding - (plotHeight * (data[week]! / 100));
      points.add(Offset(x, y));
    }

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = Theme.of(context).primaryColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Retention legend
class _RetentionLegend extends StatelessWidget {
  final Map<int, double> retentionByWeek;

  const _RetentionLegend({required this.retentionByWeek});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = retentionByWeek.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: sortedEntries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Week ${entry.key}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            Text(
              '${(entry.value * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Retention statistics cards
class _RetentionStatsCards extends StatelessWidget {
  final Map<int, double> retentionByWeek;

  const _RetentionStatsCards({required this.retentionByWeek});

  @override
  Widget build(BuildContext context) {
    if (retentionByWeek.isEmpty) {
      return const SizedBox.shrink();
    }

    final values = retentionByWeek.values.toList();
    final avgRetention = values.reduce((a, b) => a + b) / values.length;
    final minRetention = values.reduce((a, b) => a < b ? a : b);
    final maxRetention = values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        _StatCard(
          label: '平均リテンション',
          value: '${(avgRetention * 100).toStringAsFixed(1)}%',
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: '最小リテンション',
          value: '${(minRetention * 100).toStringAsFixed(1)}%',
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: '最大リテンション',
          value: '${(maxRetention * 100).toStringAsFixed(1)}%',
        ),
      ],
    );
  }
}

/// Level progress card
class _LevelProgressCard extends StatelessWidget {
  final String label;
  final double reachRate;

  const _LevelProgressCard({
    required this.label,
    required this.reachRate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(reachRate * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: reachRate,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Level progression grid
class _LevelProgressionGrid extends StatelessWidget {
  final Map<int, double> levelReachRates;

  const _LevelProgressionGrid({required this.levelReachRates});

  @override
  Widget build(BuildContext context) {
    if (levelReachRates.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'データなし',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final sortedEntries = levelReachRates.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lv.${entry.key}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(entry.value * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: entry.value,
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Engagement trend chart
class _EngagementTrendChart extends StatelessWidget {
  final Map<int, double> engagementByDay;

  const _EngagementTrendChart({required this.engagementByDay});

  @override
  Widget build(BuildContext context) {
    if (engagementByDay.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'データなし',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: CustomPaint(
            painter: _EngagementTrendPainter(
              data: engagementByDay,
              context: context,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// Engagement trend painter
class _EngagementTrendPainter extends CustomPainter {
  final Map<int, double> data;
  final BuildContext context;

  _EngagementTrendPainter({
    required this.data,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final padding = 40.0;
    final plotWidth = size.width - (padding * 2);
    final plotHeight = size.height - (padding * 2);

    // Draw axes
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      Paint()..color = Colors.grey[400]!,
    );
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      Paint()..color = Colors.grey[400]!,
    );

    // Draw data points
    final sortedKeys = data.keys.toList()..sort();
    if (sortedKeys.isEmpty) return;

    final maxDay = sortedKeys.last.toDouble();
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final points = <Offset>[];

    for (final day in sortedKeys) {
      final x = padding + (plotWidth / maxDay * day);
      final y = size.height - padding - (plotHeight * (data[day]! / maxValue));
      points.add(Offset(x, y));
    }

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Engagement statistics cards
class _EngagementStatsCards extends StatelessWidget {
  final Map<int, double> engagementByDay;

  const _EngagementStatsCards({required this.engagementByDay});

  @override
  Widget build(BuildContext context) {
    if (engagementByDay.isEmpty) {
      return const SizedBox.shrink();
    }

    final values = engagementByDay.values.toList();
    final avgEngagement = values.reduce((a, b) => a + b) / values.length;
    final minEngagement = values.reduce((a, b) => a < b ? a : b);
    final maxEngagement = values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        _StatCard(
          label: '平均エンゲージメント',
          value: '${avgEngagement.toStringAsFixed(2)}/100',
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: '最小エンゲージメント',
          value: '${minEngagement.toStringAsFixed(2)}/100',
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: '最大エンゲージメント',
          value: '${maxEngagement.toStringAsFixed(2)}/100',
        ),
      ],
    );
  }
}

/// Statistics card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
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
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
