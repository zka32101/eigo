import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../models/progress.dart';
import '../theme/app_theme.dart';
import '../theme/component_styles.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

/// ホーム画面用の改善されたカードコンポーネント
/// 新しいデザイン設計トークンを使用

// ─── 日次ミッションカード（改善版） ───

class ImprovedDailyMissionCard extends StatelessWidget {
  final Stage? nextStage;
  final VoidCallback? onStart;

  const ImprovedDailyMissionCard({
    Key? key,
    required this.nextStage,
    this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allPaddingLg,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPrimaryColor, kPrimaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withAlpha(76),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: AppSpacing.allPaddingLg,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日のレッスン',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    AppSpacing.verticalSpacerSm,
                    Text(
                      nextStage != null
                          ? '${nextStage!.emoji} ${nextStage!.titleJa}'
                          : '🎉 全ステージクリア！',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    AppSpacing.verticalSpacerMd,
                    if (nextStage != null)
                      SizedBox(
                        height: AppSizes.buttonHeightSmall,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadius,
                              ),
                            ),
                          ),
                          onPressed: onStart,
                          child: const Text(
                            'スタート！',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (nextStage != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  child: Text(
                    nextStage!.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 統計カード（改善版） ───

class ImprovedStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const ImprovedStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: AppComponentStyles.cardDecoration,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              AppSpacing.verticalSpacerSm,
              Text(
                value,
                style: AppTypography.labelLarge.copyWith(color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: kTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 統計行（改善版） ───

class ImprovedStatsRow extends StatelessWidget {
  final int lessonsCount;
  final int speakingCount;
  final int badgeCount;

  const ImprovedStatsRow({
    Key? key,
    required this.lessonsCount,
    required this.speakingCount,
    required this.badgeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalPaddingLg,
      child: Row(
        children: [
          ImprovedStatCard(
            label: 'レッスン',
            value: '$lessonsCount回',
            emoji: '📚',
            color: kPrimaryColor,
          ),
          AppSpacing.horizontalSpacerSm,
          ImprovedStatCard(
            label: 'スピーキング',
            value: '$speakingCount個',
            emoji: '🎤',
            color: kSpeakingColor,
          ),
          AppSpacing.horizontalSpacerSm,
          ImprovedStatCard(
            label: 'バッジ',
            value: '$badgeCount個',
            emoji: '🏆',
            color: kAccentOrange,
          ),
        ],
      ),
    );
  }
}

// ─── クイックアクションボタン（改善版） ───

class ImprovedQuickActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlighted;

  const ImprovedQuickActionButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: color.withAlpha(isHighlighted ? 255 : 230),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(isHighlighted ? 76 : 51),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isHighlighted
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── スキル別進捗カード（改善版） ───

class ImprovedSkillProgressCard extends StatelessWidget {
  final String skillName;
  final double progress;
  final Color skillColor;
  final int questions;

  const ImprovedSkillProgressCard({
    Key? key,
    required this.skillName,
    required this.progress,
    required this.skillColor,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppComponentStyles.cardDecoration,
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  skillName,
                  style: AppTypography.labelLarge.copyWith(
                    color: skillColor,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: skillColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerSm,
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: AppSizes.progressBarHeight,
                backgroundColor: skillColor.withAlpha(51),
                valueColor: AlwaysStoppedAnimation<Color>(skillColor),
              ),
            ),
            AppSpacing.verticalSpacerSm,
            Text(
              '$questions 問',
              style: AppTypography.bodySmall.copyWith(
                color: kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 弱点カード（改善版） ───

class ImprovedWeaknessCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const ImprovedWeaknessCard({
    Key? key,
    required this.title,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allPaddingLg,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: kErrorColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kErrorColor.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: AppSpacing.allPaddingMd,
            child: Row(
              children: [
                const Text(
                  '⚠️',
                  style: TextStyle(fontSize: 28),
                ),
                AppSpacing.horizontalSpacerMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'つまずいた問題',
                        style: AppTypography.bodySmall.copyWith(
                          color: kTextMuted,
                        ),
                      ),
                      Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          color: kErrorColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kErrorColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppSizes.badgeBorderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    '$count個',
                    style: AppTypography.labelMedium.copyWith(
                      color: kErrorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── セクションタイトル（改善版） ───

class ImprovedSectionTitle extends StatelessWidget {
  final String title;
  final String? emoji;

  const ImprovedSectionTitle({
    Key? key,
    required this.title,
    this.emoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 24)),
            AppSpacing.horizontalSpacerSm,
          ],
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }
}
