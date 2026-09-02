import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_data.dart';
import '../models/stage.dart';
import '../providers/progress_provider.dart';

/// 改善されたステージ選択画面
/// GridView を使用した 2 列/3 列レスポンシブレイアウト
class ImprovedStageSelectScreen extends ConsumerWidget {
  const ImprovedStageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final isMobile = context.isMobile;
    final crossAxisCount = isMobile ? 2 : 3;

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

          // ステージグリッド
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
                  final stage = allStages[index];
                  final isCleared = progress.isCleared(stage.id);
                  final isLocked =
                      index > 0 && !progress.isCleared(allStages[index - 1].id);
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
                childCount: allStages.length,
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
            color: widget.isLocked ? AppColors.bgLight :AppColors.textWhite,
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
                        :AppColors.textPrimary.withAlpha(13)),
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
                    color: widget.isLocked ? Colors.grey : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                AppSpacing.verticalSpacerSm,

                // ステージタイトル
                Text(
                  widget.stage.titleJa,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: widget.isLocked ? Colors.grey : AppColors.textPrimary,
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
