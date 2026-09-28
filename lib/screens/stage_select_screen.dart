import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stage_data.dart';
import '../design_system/design_system.dart';
import '../models/stage.dart';
import '../providers/progress_provider.dart';

/// ステージ一覧の絞り込み条件。学年別、または英検5級対策（Stage61-80）で絞る。
/// StageCategory はほぼステージ1つにつき1カテゴリの粒度で、フィルタには
/// 細かすぎるため、フィルタ軸としては学年とレベル区分を使う。
enum StageFilter { all, grade1, grade2, grade3, grade4, grade5, grade6, eikenPrep }

String _stageFilterLabel(StageFilter f) {
  switch (f) {
    case StageFilter.all: return 'すべて';
    case StageFilter.grade1: return '1年生';
    case StageFilter.grade2: return '2年生';
    case StageFilter.grade3: return '3年生';
    case StageFilter.grade4: return '4年生';
    case StageFilter.grade5: return '5年生';
    case StageFilter.grade6: return '6年生';
    case StageFilter.eikenPrep: return '英検5級対策';
  }
}

bool _matchesFilter(Stage stage, StageFilter filter) {
  switch (filter) {
    case StageFilter.all: return true;
    case StageFilter.grade1: return stage.grade == 1;
    case StageFilter.grade2: return stage.grade == 2;
    case StageFilter.grade3: return stage.grade == 3;
    case StageFilter.grade4: return stage.grade == 4;
    case StageFilter.grade5: return stage.grade == 5;
    case StageFilter.grade6: return stage.grade == 6;
    case StageFilter.eikenPrep: return stage.stageNumber >= 61;
  }
}

final stageFilterProvider = StateProvider<StageFilter>((ref) => StageFilter.all);

class StageSelectScreen extends ConsumerWidget {
  const StageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final isMobile = context.isMobile;
    final crossAxisCount = isMobile ? 2 : 3;
    final filter = ref.watch(stageFilterProvider);
    final filteredStages =
        allStages.where((s) => _matchesFilter(s, filter)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🇬🇧 ステージ選択'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // ステージ統計バー
          SliverToBoxAdapter(
            child: _StageStatsBar(progress: progress),
          ),

          // 絞り込みフィルタ
          SliverToBoxAdapter(
            child: _StageFilterBar(selected: filter),
          ),

          // ステージグリッド
          if (filteredStages.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: Text('このカテゴリのステージはありません')),
              ),
            )
          else
            SliverPadding(
              padding: AppSpacing.allPaddingLg,
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: isMobile ? 0.85 : 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final stage = filteredStages[index];
                    // ロック判定は全体の並び順（allStages）を基準に行う。
                    // フィルタで絞り込んでも、前のステージ未クリアならロックしたまま。
                    final overallIndex = allStages.indexOf(stage);
                    final isCleared = progress.isCleared(stage.id);
                    final isLocked = overallIndex > 0 &&
                        !progress.isCleared(allStages[overallIndex - 1].id);
                    final bestScore = progress.stageBestScores[stage.id];
                    final speakingAvg = progress.stageSpeakingAvg[stage.id];

                    return ImprovedStageCard(
                      stage: stage,
                      isCleared: isCleared,
                      isLocked: isLocked,
                      bestScore: bestScore,
                      speakingAvg: speakingAvg,
                      onTap: isLocked
                          ? null
                          : () => Navigator.of(context).pushNamed(
                                '/stage-intro',
                                arguments: stage,
                              ),
                      onReview: isCleared
                          ? () => Navigator.of(context).pushNamed(
                                '/word-review',
                                arguments: stage,
                              )
                          : null,
                    );
                  },
                  childCount: filteredStages.length,
                ),
              ),
            ),

          // 下部スペーサー
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }
}

// ─── ステージ絞り込みフィルタバー ───

class _StageFilterBar extends ConsumerWidget {
  final StageFilter selected;
  const _StageFilterBar({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: StageFilter.values.length,
        separatorBuilder: (_, __) => AppSpacing.horizontalSpacerXs,
        itemBuilder: (context, index) {
          final filter = StageFilter.values[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(_stageFilterLabel(filter)),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(stageFilterProvider.notifier).state = filter,
            selectedColor: AppColors.primary,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: AppColors.bgLight,
          );
        },
      ),
    );
  }
}

// ─── ステージ統計バー ───

class _StageStatsBar extends StatelessWidget {
  final ProgressState progress;

  const _StageStatsBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final totalStages = allStages.length;
    final clearedStages = allStages.where((s) => progress.isCleared(s.id)).length;
    final percentage = (clearedStages / totalStages * 100).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25).withAlpha(25),
        border: const Border(
          bottom: BorderSide(color: AppColors.bgLight, width: 1),
        ),
      ),
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ステージ進捗',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$clearedStages/$totalStages (${percentage}%)',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              child: LinearProgressIndicator(
                value: clearedStages / totalStages,
                minHeight: AppSizes.progressBarHeightBold,
                backgroundColor: AppColors.bgLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 改善されたステージカード ───

class ImprovedStageCard extends StatefulWidget {
  final Stage stage;
  final bool isCleared;
  final bool isLocked;
  final int? bestScore;
  final double? speakingAvg;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const ImprovedStageCard({
    Key? key,
    required this.stage,
    required this.isCleared,
    required this.isLocked,
    this.bestScore,
    this.speakingAvg,
    this.onTap,
    this.onReview,
  }) : super(key: key);

  @override
  State<ImprovedStageCard> createState() => _ImprovedStageCardState();
}

class _ImprovedStageCardState extends State<ImprovedStageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isLocked ? AppColors.bgLight : AppColors.textWhite,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            border: Border.all(
              color: _isHovered && !widget.isLocked
                  ? AppColors.primary
                  : AppColors.bgLight,
              width: _isHovered && !widget.isLocked ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isLocked
                    ? Colors.transparent
                    : (_isHovered
                        ? AppColors.primary.withAlpha(76)
                        : AppColors.textPrimary.withAlpha(13)),
                blurRadius: _isHovered ? 8 : 4,
                offset: _isHovered ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // エモジ＆ロック表示
                Container(
                  width: AppSizes.iconSizeLarge + 16,
                  height: AppSizes.iconSizeLarge + 16,
                  decoration: BoxDecoration(
                    color: widget.isLocked
                        ? AppColors.bgLight
                        : (widget.isCleared
                            ? AppColors.accentGreen.withAlpha(25)
                            : AppColors.primary.withAlpha(25)),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  child: Center(
                    child: widget.isLocked
                        ? const Icon(Icons.lock, color: AppColors.textMuted, size: 20)
                        : Text(
                            widget.stage.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                  ),
                ),

                AppSpacing.verticalSpacerMd,

                // ステージ番号
                Text(
                  'Stage ${widget.stage.stageNumber}',
                  style: AppTypography.labelMedium.copyWith(
                    color: widget.isLocked ? AppColors.textMuted : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                AppSpacing.verticalSpacerSm,

                // ステージタイトル
                Text(
                  widget.stage.titleJa,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: widget.isLocked ? AppColors.textMuted : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                AppSpacing.verticalSpacerMd,

                // スキル表示
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CompactSkillPill(
                      icon: '👂',
                      count: widget.stage.listeningCount,
                      color: AppColors.listeningColor,
                    ),
                    AppSpacing.horizontalSpacerSm,
                    _CompactSkillPill(
                      icon: '🎤',
                      count: widget.stage.speakingCount,
                      color: AppColors.speakingColor,
                    ),
                  ],
                ),

                AppSpacing.verticalSpacerMd,

                // スコア＆ボタン表示
                if (widget.isCleared)
                  Column(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.accentGreen, size: 20),
                      AppSpacing.verticalSpacerSm,
                      if (widget.onReview != null)
                        GestureDetector(
                          onTap: widget.onReview,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withAlpha(25),
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadius,
                              ),
                            ),
                            child: Text(
                              '復習',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                else if (!widget.isLocked && widget.bestScore != null)
                  Column(
                    children: [
                      Text(
                        '${widget.bestScore}',
                        style: AppTypography.numberDisplay.copyWith(
                          color: AppColors.accentOrange,
                        ),
                      ),
                      Text(
                        '点',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  )
                else if (!widget.isLocked)
                  const Icon(
                    Icons.play_circle_filled,
                    color: AppColors.primary,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── コンパクトスキルピル ───

class _CompactSkillPill extends StatelessWidget {
  final String icon;
  final int count;
  final Color color;

  const _CompactSkillPill({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
      ),
      child: Text(
        '$icon$count',
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
