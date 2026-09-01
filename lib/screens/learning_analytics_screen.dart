import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../widgets/monthly_chart_widget.dart';
import '../widgets/learning_stats_card.dart';
import '../providers/analytics_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';
import '../widgets/educational_illustrations.dart';

class LearningAnalyticsScreen extends ConsumerWidget {
  final String userId;

  const LearningAnalyticsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('学習分析'),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '📊 統計'),
              Tab(text: '📅 月別学力'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStatisticsTab(),
            _buildMonthlyAnalyticsTab(context, ref),
          ],
        ),
      ),
    );
  }

  /// 統計タブ
  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学習スタイル別統計',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerMd,

          // Learning method breakdown
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    ProgressVisualization(
                      progress: 0.85,
                      label: 'リスニング',
                      color: kListeningColor,
                    ),
                    ProgressVisualization(
                      progress: 0.72,
                      label: 'スピーキング',
                      color: kSpeakingColor,
                    ),
                    ProgressVisualization(
                      progress: 0.68,
                      label: 'リーディング',
                      color: kReadingColor,
                    ),
                    ProgressVisualization(
                      progress: 0.81,
                      label: 'ライティング',
                      color: kWritingColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.verticalSpacerLg,
          Text(
            '学習方法別成果',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpacerMd,

          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              Flexible(
                flex: 1,
                child: LearningMethodCard(
                  emoji: '👂',
                  title: 'リスニング',
                  description: '聞く力を伸ばす',
                  color: kListeningColor,
                ),
              ),
              Flexible(
                flex: 1,
                child: LearningMethodCard(
                  emoji: '🎤',
                  title: 'スピーキング',
                  description: '話す自信を育てる',
                  color: kSpeakingColor,
                ),
              ),
              Flexible(
                flex: 1,
                child: LearningMethodCard(
                  emoji: '📖',
                  title: 'リーディング',
                  description: '読む理解力を高める',
                  color: kReadingColor,
                ),
              ),
              Flexible(
                flex: 1,
                child: LearningMethodCard(
                  emoji: '✏️',
                  title: 'ライティング',
                  description: '書く表現力を培う',
                  color: kWritingColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 月別学力タブ
  Widget _buildMonthlyAnalyticsTab(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    if (analytics == null || analytics.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, size: 64, color: Colors.grey),
              AppSpacing.verticalSpacerMd,
              const Text('月ごとのデータがまだありません'),
            ],
          ),
        ),
      );
    }

    // Convert DailyStats to MonthlyStats
    final monthlyList = _calculateMonthlyStats(analytics);

    if (monthlyList.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, size: 64, color: Colors.grey),
              AppSpacing.verticalSpacerMd,
              const Text('月ごとのデータがまだありません'),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 正答率推移グラフ
          MonthlyChartWidget(
            monthlyStatsList: monthlyList,
            title: '📊 月ごと正答率推移',
          ),
          AppSpacing.verticalSpacerLg,

          // 学習量グラフ
          MonthlyBarChartWidget(
            monthlyStatsList: monthlyList,
            title: '📝 月ごと問題数',
            metric: 'quests',
          ),
          AppSpacing.verticalSpacerLg,

          // 学習時間グラフ
          MonthlyBarChartWidget(
            monthlyStatsList: monthlyList,
            title: '⏱️ 月ごと学習時間',
            metric: 'minutes',
          ),
          AppSpacing.verticalSpacerLg,

          // 月別統計カード
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              '月別統計',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          AppSpacing.verticalSpacerXs,
          ...monthlyList.map((stats) => LearningStatsCard(monthlyStats: stats)),
          AppSpacing.verticalSpacerMd,
        ],
      ),
    );
  }

  List<MonthlyStats> _calculateMonthlyStats(List<DailyStats> dailyStats) {
    final monthlyMap = <String, MonthlyStats>{};

    for (final daily in dailyStats) {
      final date = DateTime.parse(daily.date);
      final monthStr = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      if (monthlyMap.containsKey(monthStr)) {
        final existing = monthlyMap[monthStr]!;
        monthlyMap[monthStr] = MonthlyStats(
          month: monthStr,
          totalQuestsCompleted: existing.totalQuestsCompleted + daily.questsCompleted,
          totalCorrectAnswers: existing.totalCorrectAnswers + daily.correctAnswers,
          totalAnswers: existing.totalAnswers + daily.totalAnswers,
          accuracyRate: 0, // Will be calculated below
          totalStudyMinutes: existing.totalStudyMinutes + daily.studyMinutes,
          totalCoinsEarned: existing.totalCoinsEarned + daily.coinsEarned,
          studyDaysCount: existing.studyDaysCount + 1,
          categoryStats: existing.categoryStats,
        );
      } else {
        monthlyMap[monthStr] = MonthlyStats(
          month: monthStr,
          totalQuestsCompleted: daily.questsCompleted,
          totalCorrectAnswers: daily.correctAnswers,
          totalAnswers: daily.totalAnswers,
          accuracyRate: daily.totalAnswers > 0 ? daily.correctAnswers / daily.totalAnswers : 0,
          totalStudyMinutes: daily.studyMinutes,
          totalCoinsEarned: daily.coinsEarned,
          studyDaysCount: 1,
          categoryStats: daily.categoryStats,
        );
      }
    }

    // Recalculate accuracy rates
    final result = monthlyMap.values.map((m) {
      final accuracy = m.totalAnswers > 0 ? m.totalCorrectAnswers / m.totalAnswers : 0.0;
      return MonthlyStats(
        month: m.month,
        totalQuestsCompleted: m.totalQuestsCompleted,
        totalCorrectAnswers: m.totalCorrectAnswers,
        totalAnswers: m.totalAnswers,
        accuracyRate: accuracy,
        totalStudyMinutes: m.totalStudyMinutes,
        totalCoinsEarned: m.totalCoinsEarned,
        studyDaysCount: m.studyDaysCount,
        categoryStats: m.categoryStats,
      );
    }).toList();

    // Sort by month descending
    result.sort((a, b) => b.month.compareTo(a.month));
    return result;
  }
}
