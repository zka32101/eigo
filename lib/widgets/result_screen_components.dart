import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../models/stage.dart';
import '../theme/app_theme.dart';
import '../theme/component_styles.dart';
import '../theme/sizes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// 結果画面用の改善されたコンポーネント

// ─── 結果ヘッダー（改善版） ───

class ImprovedResultHeader extends StatelessWidget {
  final bool isPassed;
  final bool isExcellent;
  final double accuracy;
  final int score;
  final int xpGained;

  const ImprovedResultHeader({
    Key? key,
    required this.isPassed,
    required this.isExcellent,
    required this.accuracy,
    required this.score,
    this.xpGained = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emoji = isExcellent ? '🏆' : isPassed ? '⭐' : '💪';
    final message = isExcellent
        ? 'すばらしい！パーフェクトに近い！'
        : isPassed
            ? 'クリア！よくできました！'
            : 'もう少し！もう一度挑戦しよう！';
    final color = isPassed ? AppColors.accentGreen : AppColors.accentOrange;

    return Container(
      decoration: AppComponentStyles.cardDecoration,
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            AppSpacing.verticalSpacerMd,
            Text(
              message,
              style: AppTypography.headlineSmall.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpacerLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ImprovedResultStat(
                  label: 'スコア',
                  value: '$score点',
                  color: AppColors.primary,
                ),
                ImprovedResultStat(
                  label: '正解率',
                  value: '${(accuracy * 100).round()}%',
                  color: color,
                ),
                if (xpGained > 0)
                  ImprovedResultStat(
                    label: 'XP獲得',
                    value: '+$xpGained',
                    color: const Color(0xFFFFD700),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 結果統計（改善版） ───

class ImprovedResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ImprovedResultStat({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.numberDisplay.copyWith(
            color: color,
          ),
        ),
        AppSpacing.verticalSpacerXs,
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ─── スキル結果カード（改善版） ───

class ImprovedSkillResultCards extends StatelessWidget {
  final int speakingAvg;
  final int listeningAccuracy;
  final Duration duration;

  const ImprovedSkillResultCards({
    Key? key,
    required this.speakingAvg,
    required this.listeningAccuracy,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;

    return Row(
      children: [
        Expanded(
          child: ImprovedSkillResultCard(
            icon: '👂',
            label: 'リスニング',
            value: '$listeningAccuracy%',
            color: AppColors.listeningColor,
          ),
        ),
        AppSpacing.horizontalSpacerSm,
        Expanded(
          child: ImprovedSkillResultCard(
            icon: '🎤',
            label: 'スピーキング',
            value: '$speakingAvg点',
            color: AppColors.speakingColor,
          ),
        ),
        AppSpacing.horizontalSpacerSm,
        Expanded(
          child: ImprovedSkillResultCard(
            icon: '⏱️',
            label: '時間',
            value: '$mins:${secs.toString().padLeft(2, '0')}',
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }
}

// ─── スキル結果カード（個別、改善版） ───

class ImprovedSkillResultCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const ImprovedSkillResultCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppComponentStyles.cardDecoration,
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            AppSpacing.verticalSpacerSm,
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(color: color),
            ),
            AppSpacing.verticalSpacerXs,
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 新しいバッジカード（改善版） ───

class ImprovedNewBadgesCard extends StatelessWidget {
  final List<BadgeModel> badges;

  const ImprovedNewBadgesCard({
    Key? key,
    required this.badges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.accentOrange, width: 2),
      ),
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎉 新しいバッジ獲得！',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.accentOrange,
              ),
            ),
            AppSpacing.verticalSpacerMd,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: badges.map((b) => SizedBox(
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      b.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    AppSpacing.verticalSpacerSm,
                    Text(
                      b.title,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      b.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── レッスンコンテンツ表示（改善版） ───

class ImprovedContentBreakdown extends StatelessWidget {
  final Stage stage;

  const ImprovedContentBreakdown({
    Key? key,
    required this.stage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = stage.questions.length;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      decoration: AppComponentStyles.cardDecoration,
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'このレッスンの内容',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSpacerMd,
            Column(
              children: [
                _BuildContentRow(
                  label: '👂 リスニング',
                  count: stage.listeningCount,
                  total: total,
                  color: AppColors.listeningColor,
                ),
                AppSpacing.verticalSpacerSm,
                _BuildContentRow(
                  label: '🎤 スピーキング',
                  count: stage.speakingCount,
                  total: total,
                  color: AppColors.speakingColor,
                ),
                AppSpacing.verticalSpacerSm,
                _BuildContentRow(
                  label: '📖 リーディング',
                  count: stage.readingCount,
                  total: total,
                  color: AppColors.readingColor,
                ),
                AppSpacing.verticalSpacerSm,
                _BuildContentRow(
                  label: '✏️ ライティング',
                  count: stage.writingCount,
                  total: total,
                  color: AppColors.writingColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildContentRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _BuildContentRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count問 ($percentage%)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpacerXs,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          child: LinearProgressIndicator(
            value: count / total,
            minHeight: AppSizes.progressBarHeight,
            backgroundColor: color.withAlpha(51),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
