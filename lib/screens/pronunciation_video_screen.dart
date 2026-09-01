import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pronunciation_video_model.dart';
import '../providers/pronunciation_video_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class PronunciationVideoScreen extends ConsumerStatefulWidget {
  const PronunciationVideoScreen({super.key});

  @override
  ConsumerState<PronunciationVideoScreen> createState() =>
      _PronunciationVideoScreenState();
}

class _PronunciationVideoScreenState extends ConsumerState<PronunciationVideoScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Mock data for demonstration
    await ref.read(activeRecordsProvider.notifier).addRecord(
      phrase: 'What is your name?',
      meaning: 'あなたの名前は何ですか？',
      initialScore: 72,
      category: 'greeting',
      difficulty: 'beginner',
    );

    await ref.read(activeRecordsProvider.notifier).addRecord(
      phrase: 'How are you today?',
      meaning: 'お元気ですか？',
      initialScore: 68,
      category: 'greeting',
      difficulty: 'beginner',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎬 発音成長動画'),
          backgroundColor: kPrimaryColor,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kAccentOrange,
            tabs: const [
              Tab(text: '進行中'),
              Tab(text: '完了'),
              Tab(text: '統計'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Active recordings
            _ActiveRecordingsTab(),
            // Tab 2: Completed videos
            _CompletedVideosTab(),
            // Tab 3: Statistics
            _StatisticsTab(),
          ],
        ),
      ),
    );
  }
}

/// === Tab 1: 進行中（30日トラッキング） ===
class _ActiveRecordingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(activeRecordsProvider);

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎤 まだ記録がありません',
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.verticalSpacerMd,
            Text(
              '発音問題に正解して、成長を記録しましょう！',
              style: AppTypography.bodySmall.copyWith(color: kTextMuted),
            ),
            AppSpacing.verticalSpacerLg,
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ステージを選んでください')),
                );
              },
              child: const Text('学習を始める'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSpacerMd,

          Container(
            margin: AppSpacing.allPaddingLg,
            padding: AppSpacing.allPaddingLg,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 30日間の成長トラッキング',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.blue.shade900,
                  ),
                ),
                AppSpacing.verticalSpacerMd,
                Text(
                  '記録された日から30日後に、成長を比較する動画が自動生成されます。',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: AppSpacing.allPaddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '進行中の記録',
                  style: AppTypography.headlineSmall,
                ),
                AppSpacing.verticalSpacerMd,
                ...records.map((record) {
                  return _ActiveRecordCard(record: record);
                }).toList(),
              ],
            ),
          ),

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _ActiveRecordCard extends StatelessWidget {
  final PronunciationVideoRecord record;

  const _ActiveRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysPassed = now.difference(record.recordedAt).inDays;
    final daysRemaining = 30 - daysPassed;
    final progressPercent = daysPassed / 30;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phrase and score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.phrase,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      record.meaning,
                      style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Text(
                  '${record.initialScore}点',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpacerMd,

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '記録から$daysPassed日経過',
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                  ),
                  Text(
                    'あと$daysRemaining日',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerXs,
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                child: LinearProgressIndicator(
                  value: progressPercent.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpacerMd,

          // Status message
          if (daysPassed < 30)
            Container(
              padding: AppSpacing.allPaddingSm,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.blue),
                  AppSpacing.horizontalSpacerSm,
                  Expanded(
                    child: Text(
                      '30日後に自動的に成長動画が生成されます。',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: AppSpacing.allPaddingSm,
              decoration: BoxDecoration(
                color: kAccentGreen.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: kAccentGreen),
                  AppSpacing.horizontalSpacerSm,
                  Expanded(
                    child: Text(
                      '動画生成準備完了！',
                      style: AppTypography.bodySmall.copyWith(
                        color: kAccentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// === Tab 2: 完了（成長動画） ===
class _CompletedVideosTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisons = ref.watch(completedComparisonsProvider);

    if (comparisons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎬 成長動画がまだありません',
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.verticalSpacerMd,
            Text(
              '30日後に最初の動画が生成されます',
              style: AppTypography.bodySmall.copyWith(color: kTextMuted),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSpacerMd,

          Container(
            margin: AppSpacing.allPaddingLg,
            padding: AppSpacing.allPaddingLg,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kAccentGreen, kAccentGreen.withAlpha(150)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ 成長動画',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                AppSpacing.verticalSpacerMd,
                Text(
                  '${comparisons.length}本の成長動画が生成されました。',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: AppSpacing.allPaddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...comparisons.map((comparison) {
                  return _ComparisonVideoCard(comparison: comparison);
                }).toList(),
              ],
            ),
          ),

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _ComparisonVideoCard extends ConsumerStatefulWidget {
  final PronunciationVideoComparison comparison;

  const _ComparisonVideoCard({required this.comparison});

  @override
  ConsumerState<_ComparisonVideoCard> createState() => _ComparisonVideoCardState();
}

class _ComparisonVideoCardState extends ConsumerState<_ComparisonVideoCard> {
  bool _expanded = false;

  String _getGrowthLevelEmoji(String level) {
    switch (level) {
      case 'excellent':
        return '🌟';
      case 'advanced':
        return '⭐';
      case 'intermediate':
        return '📈';
      case 'beginner':
        return '📊';
      default:
        return '📉';
    }
  }

  String _getGrowthLevelText(String level) {
    switch (level) {
      case 'excellent':
        return '大きな成長！';
      case 'advanced':
        return '素晴らしい';
      case 'intermediate':
        return '良い成長';
      case 'beginner':
        return '順調';
      default:
        return 'チャレンジ中';
    }
  }

  @override
  Widget build(BuildContext context) {
    final comparison = widget.comparison;
    final emoji = _getGrowthLevelEmoji(comparison.growthLevel);
    final levelText = _getGrowthLevelText(comparison.growthLevel);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kPrimaryColor.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: kPrimaryColor.withAlpha(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        levelText,
                        style: AppTypography.labelLarge.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${comparison.scoreImprovement}点アップ',
                      style: AppTypography.headlineSmall.copyWith(
                        color: kAccentGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      '(${comparison.improvementPercentage.toStringAsFixed(0)}%)',
                      style: AppTypography.bodySmall.copyWith(
                        color: kTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score comparison
          Container(
            padding: AppSpacing.allPaddingMd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('📊 初回', style: AppTypography.bodySmall),
                    AppSpacing.verticalSpacerSm,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                      child: Text(
                        '${comparison.finalScore - comparison.scoreImprovement}点',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.arrow_forward, color: kAccentGreen),
                    AppSpacing.verticalSpacerSm,
                    const SizedBox(width: 30),
                  ],
                ),
                Column(
                  children: [
                    Text('🎉 現在', style: AppTypography.bodySmall),
                    AppSpacing.verticalSpacerSm,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: kAccentGreen.withAlpha(30),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                      child: Text(
                        '${comparison.finalScore}点',
                        style: AppTypography.headlineSmall.copyWith(
                          color: kAccentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Improvement details (expandable)
          if (_expanded) ...[
            Divider(color: Colors.grey.shade200),
            Container(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('改善詳細', style: AppTypography.labelLarge),
                  AppSpacing.verticalSpacerMd,
                  _ImprovementMetric(
                    label: '発音精度',
                    value: comparison.accuracyImprovement,
                  ),
                  AppSpacing.verticalSpacerSm,
                  _ImprovementMetric(
                    label: 'スピード',
                    value: comparison.speedImprovement,
                  ),
                  AppSpacing.verticalSpacerSm,
                  _ImprovementMetric(
                    label: 'イントネーション',
                    value: comparison.intonationImprovement,
                  ),
                  AppSpacing.verticalSpacerMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '30日間継続学習: ${comparison.consistencyDays}日',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        '${comparison.phrasesLearned}フレーズ学習',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Rewards
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.borderRadiusSmall),
                bottomRight: Radius.circular(AppSizes.borderRadiusSmall),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('🪙', style: const TextStyle(fontSize: 24)),
                    AppSpacing.horizontalSpacerSm,
                    Text(
                      '${comparison.rewardCoins}コイン獲得',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _expanded = !_expanded);
                      },
                      icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      label: Text(_expanded ? '折りたたむ' : '詳細'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpacerSm,
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('動画をシェアしました！')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImprovementMetric extends StatelessWidget {
  final String label;
  final double value;

  const _ImprovementMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: AppTypography.labelSmall.copyWith(
                color: kAccentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpacerXs,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(kAccentGreen),
          ),
        ),
      ],
    );
  }
}

/// === Tab 3: 統計とマイルストーン ===
class _StatisticsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(pronunciationVideoStatsProvider);
    final progress = ref.watch(pronunciationProgressProvider);
    final milestones = ref.watch(milestonesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSpacerMd,

          // Overall stats header
          _StatsHeader(stats: stats),
          AppSpacing.verticalSpacerLg,

          // Progress overview
          if (progress != null) _ProgressOverview(progress: progress),
          AppSpacing.verticalSpacerLg,

          // Milestones
          _MilestonesSection(
            stats: stats,
            milestones: milestones,
          ),

          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final PronunciationVideoStats stats;

  const _StatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withAlpha(150)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 成長統計',
            style: AppTypography.headlineSmall.copyWith(color: Colors.white),
          ),
          AppSpacing.verticalSpacerLg,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('📈', style: const TextStyle(fontSize: 28)),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    '総改善',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${stats.totalImprovement}点',
                    style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('🎥', style: const TextStyle(fontSize: 28)),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    '成長動画',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${stats.specialBadgesEarned}本',
                    style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('🪙', style: const TextStyle(fontSize: 28)),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    '報酬',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${stats.totalRewardCoins}コイン',
                    style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressOverview extends StatelessWidget {
  final PronunciationProgress progress;

  const _ProgressOverview({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kPrimaryColor.withAlpha(50)),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '進捗情報',
            style: AppTypography.labelLarge,
          ),
          AppSpacing.verticalSpacerMd,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('平均スコア改善:', style: AppTypography.bodySmall),
              Text(
                '${progress.averageImprovement.toStringAsFixed(1)}点',
                style: AppTypography.labelLarge.copyWith(
                  color: kAccentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerSm,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('最大改善:', style: AppTypography.bodySmall),
              Text(
                '${progress.maxImprovement}点',
                style: AppTypography.labelLarge.copyWith(
                  color: kAccentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerSm,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('初回平均スコア:', style: AppTypography.bodySmall),
              Text(
                '${progress.averageInitialScore.toStringAsFixed(0)}点',
                style: AppTypography.labelLarge,
              ),
            ],
          ),
          AppSpacing.verticalSpacerSm,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('現在の平均スコア:', style: AppTypography.bodySmall),
              Text(
                '${progress.averageFinalScore.toStringAsFixed(0)}点',
                style: AppTypography.labelLarge.copyWith(
                  color: kAccentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestonesSection extends StatelessWidget {
  final PronunciationVideoStats stats;
  final List<PronunciationMilestone> milestones;

  const _MilestonesSection({
    required this.stats,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 マイルストーン',
            style: AppTypography.headlineSmall,
          ),
          AppSpacing.verticalSpacerMd,

          ...milestones.map((milestone) {
            final isUnlocked = stats.unlockedMilestones.contains(milestone.milestoneId);

            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              padding: AppSpacing.allPaddingMd,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade50,
                border: Border.all(
                  color: isUnlocked ? Colors.amber : Colors.grey.shade300!,
                ),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  Text(
                    milestone.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.name,
                          style: AppTypography.labelLarge.copyWith(
                            color: isUnlocked ? Colors.black : Colors.grey,
                          ),
                        ),
                        AppSpacing.verticalSpacerXs,
                        Text(
                          milestone.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: isUnlocked ? kTextMuted : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade200,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                      child: Text(
                        '${milestone.rewardCoins}🪙',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
