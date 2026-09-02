import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📊 学習分析'),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.7),
            indicatorColor: AppColors.accentOrange,
            tabs: [
              Tab(text: '進度'),
              Tab(text: '週間'),
              Tab(text: '月間'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 進度タブ
            _ProgressTab(),
            // 週間タブ
            _WeeklyTab(),
            // 月間タブ
            _MonthlyTab(),
          ],
        ),
      ),
    );
  }
}

class _ProgressTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Center(child: Text('ユーザー情報が見つかりません'));
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // レベルとプログレス
          Text('レベル進度', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('現在のレベル', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    Text('Lv.25', style: AppTypography.labelLarge),
                  ],
                ),
                AppSpacing.verticalSpacerMd,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 12,
                    backgroundColor: AppColors.bgLight,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentOrange),
                  ),
                ),
                AppSpacing.verticalSpacerMd,
                Text('65% 進捗', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // 主要統計
          Text('学習統計', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                icon: '📚',
                label: 'レッスン完了',
                value: '${currentUser.stageProgress.length}',
                color: AppColors.primary,
              ),
              _StatCard(
                icon: '⏱️',
                label: '総勉強時間',
                value: '${currentUser.totalStudyMinutes}分',
                color: AppColors.accentOrange,
              ),
              _StatCard(
                icon: '🪙',
                label: '獲得コイン',
                value: '${currentUser.coinsEarned}',
                color: AppColors.accentGreen,
              ),
              _StatCard(
                icon: '🔥',
                label: '最長連続',
                value: '${currentUser.longestStreak}日',
                color: AppColors.error,
              ),
            ],
          ),
          AppSpacing.verticalSpacerLg,

          // 正解率
          Text('理解度', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('全体正解率', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    Text('82%', style: AppTypography.labelLarge.copyWith(color: AppColors.accentGreen)),
                  ],
                ),
                AppSpacing.verticalSpacerMd,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                  child: LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 12,
                    backgroundColor: AppColors.bgLight,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentGreen),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _WeeklyTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 週間情報
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.accentOrange.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.accentOrange),
                AppSpacing.horizontalSpacerMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('今週の学習', style: AppTypography.labelLarge),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        '2026年9月1日 - 9月7日',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // 週間統計
          Text('今週の統計', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                icon: '📚',
                label: 'レッスン',
                value: '12',
                color: AppColors.primary,
              ),
              _StatCard(
                icon: '⏱️',
                label: '勉強時間',
                value: '480分',
                color: AppColors.accentOrange,
              ),
              _StatCard(
                icon: '🪙',
                label: 'コイン獲得',
                value: '2,400',
                color: AppColors.accentGreen,
              ),
              _StatCard(
                icon: '✅',
                label: '学習日数',
                value: '5日',
                color: AppColors.error,
              ),
            ],
          ),
          AppSpacing.verticalSpacerLg,

          // 日別パフォーマンス
          Text('日別パフォーマンス', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          ..._buildDailyPerformanceList(),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }

  List<Widget> _buildDailyPerformanceList() {
    final days = ['月', '火', '水', '木', '金', '土', '日'];
    final minutes = [120, 0, 90, 80, 100, 45, 45];

    return List.generate(
      days.length,
      (index) {
        final isActive = minutes[index] > 0;
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withAlpha(10) : Colors.grey[50],
              border: Border.all(
                color: isActive ? AppColors.primary.withAlpha(50) : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${days[index]}曜日', style: AppTypography.labelLarge),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      isActive ? '${minutes[index]}分学習' : '未学習',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.close, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthlyTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月間情報
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primary),
                AppSpacing.horizontalSpacerMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2026年9月', style: AppTypography.labelLarge),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        '今月の進捗を表示',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // 月間統計
          Text('今月の統計', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                icon: '📚',
                label: 'レッスン',
                value: '48',
                color: AppColors.primary,
              ),
              _StatCard(
                icon: '⏱️',
                label: '勉強時間',
                value: '1,920分',
                color: AppColors.accentOrange,
              ),
              _StatCard(
                icon: '🪙',
                label: 'コイン獲得',
                value: '9,600',
                color: AppColors.accentGreen,
              ),
              _StatCard(
                icon: '📅',
                label: '学習日数',
                value: '22日',
                color: AppColors.error,
              ),
            ],
          ),
          AppSpacing.verticalSpacerLg,

          // 目標達成状況
          Text('目標達成状況', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          _GoalProgressCard(
            title: '月間学習目標',
            target: '1,800分',
            current: '1,920分',
            progress: 0.96,
            achieved: true,
          ),
          AppSpacing.verticalSpacerMd,
          _GoalProgressCard(
            title: '月間コイン獲得目標',
            target: '9,000',
            current: '9,600',
            progress: 1.0,
            achieved: true,
          ),
          AppSpacing.verticalSpacerMd,
          _GoalProgressCard(
            title: '連続学習記録目標',
            target: '25日',
            current: '22日',
            progress: 0.88,
            achieved: false,
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              AppSpacing.verticalSpacerXs,
              Text(value, style: AppTypography.headlineSmall.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final String title;
  final String target;
  final String current;
  final double progress;
  final bool achieved;

  const _GoalProgressCard({
    required this.title,
    required this.target,
    required this.current,
    required this.progress,
    required this.achieved,
  });

  @override
  Widget build(BuildContext context) {
    final color = achieved ? AppColors.accentGreen : AppColors.accentOrange;

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              if (achieved)
                const Text('✓ 達成', style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold))
              else
                Text('${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            '$current / $target',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
