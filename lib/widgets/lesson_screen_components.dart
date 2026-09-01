import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../theme/component_styles.dart';
import '../theme/sizes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// レッスン画面用の改善されたコンポーネント
/// 新しいデザイン設計トークンを全て活用

// ─── スキルバッジ（改善版） ───

class ImprovedSkillBadge extends StatelessWidget {
  final QuestionType type;

  const ImprovedSkillBadge({Key? key, required this.type}) : super(key: key);

  Color _getColor(QuestionType t) {
    switch (t) {
      case QuestionType.listening:
        return kListeningColor;
      case QuestionType.speaking:
        return kSpeakingColor;
      case QuestionType.reading:
        return kReadingColor;
      case QuestionType.writing:
        return kWritingColor;
    }
  }

  String _getLabel(QuestionType t) {
    switch (t) {
      case QuestionType.listening:
        return '👂 リスニング';
      case QuestionType.speaking:
        return '🎤 スピーキング';
      case QuestionType.reading:
        return '📖 リーディング';
      case QuestionType.writing:
        return '✏️ ライティング';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(type);
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSizes.badgeBorderRadius),
        border: Border.all(color: color, width: 2),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        _getLabel(type),
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── 問題カード（改善版） ───

class ImprovedQuestionCard extends ConsumerWidget {
  final Question question;
  final VoidCallback onPlay;
  final VoidCallback onPlaySlow;

  const ImprovedQuestionCard({
    Key? key,
    required this.question,
    required this.onPlay,
    required this.onPlaySlow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: AppComponentStyles.cardDecoration,
      child: Padding(
        padding: AppSpacing.allPaddingLg,
        child: Column(
          children: [
            // イメージ絵文字
            if (question.imageEmoji != null)
              Text(
                question.imageEmoji!,
                style: const TextStyle(fontSize: 56),
              ),

            if (question.imageEmoji != null) AppSpacing.verticalSpacerMd,

            // 英語テキスト（大きく目立つ）
            Text(
              question.text,
              style: AppTypography.displaySmall.copyWith(
                color: kTextDark,
              ),
              textAlign: TextAlign.center,
            ),

            AppSpacing.verticalSpacerMd,

            // 音声ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: AppSizes.buttonHeight,
                  height: AppSizes.buttonHeight,
                  child: FloatingActionButton(
                    mini: false,
                    backgroundColor: kPrimaryColor,
                    onPressed: onPlay,
                    child: const Icon(Icons.volume_up, color: Colors.white),
                  ),
                ),
                AppSpacing.horizontalSpacerLg,
                OutlinedButton.icon(
                  icon: const Icon(Icons.slow_motion_video, size: 18),
                  label: const Text('ゆっくり'),
                  onPressed: onPlaySlow,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: const BorderSide(color: kPrimaryColor, width: 2),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpacerMd,

            // 区切り線
            Divider(
              color: kBorderColor,
              thickness: 1,
            ),

            AppSpacing.verticalSpacerMd,

            // 音声転写（フォネティクス）
            if (question.phonetic != null) ...[
              Text(
                '発音',
                style: AppTypography.labelMedium.copyWith(
                  color: kTextMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                question.phonetic!,
                style: AppTypography.bodyLarge.copyWith(
                  color: kPrimaryColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpacerMd,
            ],

            // 日本語翻訳
            Text(
              '日本語',
              style: AppTypography.labelMedium.copyWith(
                color: kTextMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              question.textJa,
              style: AppTypography.bodyMedium.copyWith(
                color: kTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 選択肢エリア（改善版） ───

class ImprovedChoiceArea extends StatelessWidget {
  final Question question;
  final bool answered;
  final String? selectedAnswer;
  final void Function(String) onSelect;

  const ImprovedChoiceArea({
    Key? key,
    required this.question,
    required this.answered,
    required this.selectedAnswer,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        question.choices.length,
        (index) {
          final choice = question.choices[index];
          final isSelected = selectedAnswer == choice;
          final isCorrect = choice == question.correctAnswer;
          final isWrong = answered && isSelected && !isCorrect;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < question.choices.length - 1 ? AppSpacing.md : 0,
            ),
            child: GestureDetector(
              onTap: answered ? null : () => onSelect(choice),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(
                    color: isWrong
                        ? kErrorColor
                        : isCorrect && (answered && isSelected)
                            ? kAccentGreen
                            : isSelected
                                ? kPrimaryColor
                                : kBorderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? (isWrong ? kErrorColor : kPrimaryColor).withAlpha(51)
                          : Colors.transparent,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: AppSpacing.allPaddingMd,
                  child: Row(
                    children: [
                      // 選択肢番号
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isWrong ? kErrorColor : kPrimaryColor)
                              : kBgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            // A, B, C, D...
                            style: AppTypography.labelLarge.copyWith(
                              color: isSelected ? Colors.white : kTextMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSpacerMd,

                      // 選択肢テキスト
                      Expanded(
                        child: Text(
                          choice,
                          style: AppTypography.bodyLarge.copyWith(
                            color: kTextDark,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),

                      // ステータスアイコン
                      if (answered && isSelected)
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? kAccentGreen : kErrorColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── 解答説明カード（改善版） ───

class ImprovedAnswerExplanation extends StatelessWidget {
  final Question question;
  final bool isCorrect;
  final VoidCallback onPlayCorrect;

  const ImprovedAnswerExplanation({
    Key? key,
    required this.question,
    required this.isCorrect,
    required this.onPlayCorrect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCorrect
            ? kAccentGreen.withAlpha(25)
            : kErrorColor.withAlpha(25),
        border: Border.all(
          color: isCorrect ? kAccentGreen : kErrorColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Text(
                  isCorrect ? '✅ 正解！' : '❌ 不正解',
                  style: AppTypography.labelLarge.copyWith(
                    color: isCorrect ? kAccentGreen : kErrorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpacerMd,

            // 正解表示
            Text(
              '正解: ${question.correctAnswer}',
              style: AppTypography.bodyLarge.copyWith(
                color: isCorrect ? kAccentGreen : kTextDark,
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpacerSm,

            // 説明
            if (question.explanation != null && question.explanation!.isNotEmpty) ...[
              Text(
                '説明',
                style: AppTypography.labelMedium.copyWith(
                  color: kTextMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                question.explanation!,
                style: AppTypography.bodyMedium.copyWith(
                  color: kTextMuted,
                  height: 1.5,
                ),
              ),
              AppSpacing.verticalSpacerMd,
            ],

            // 音声再生ボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.volume_up),
                    label: const Text('正解を聞く'),
                    onPressed: onPlayCorrect,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isCorrect ? kAccentGreen : kErrorColor,
                      side: BorderSide(
                        color: isCorrect ? kAccentGreen : kErrorColor,
                      ),
                    ),
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

// ─── スコアバー（改善版） ───

class ImprovedScoreBar extends StatelessWidget {
  final int score;
  final int correct;
  final int total;

  const ImprovedScoreBar({
    Key? key,
    required this.score,
    required this.correct,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accuracy =
        total > 0 ? ((correct / total) * 100).toStringAsFixed(0) : '0';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: kBorderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'スコア',
                  style: AppTypography.labelMedium.copyWith(
                    color: kTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$score点',
                  style: AppTypography.numberDisplay.copyWith(
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: kBorderColor,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '正解',
                  style: AppTypography.labelMedium.copyWith(
                    color: kTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$correct/$total',
                  style: AppTypography.numberDisplay.copyWith(
                    color: kAccentGreen,
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: kBorderColor,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '正答率',
                  style: AppTypography.labelMedium.copyWith(
                    color: kTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$accuracy%',
                  style: AppTypography.numberDisplay.copyWith(
                    color: kAccentOrange,
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

// ─── 次へボタン（改善版） ───

class ImprovedNextButton extends StatelessWidget {
  final bool isLast;
  final int? score;
  final VoidCallback onNext;

  const ImprovedNextButton({
    Key? key,
    required this.isLast,
    this.score,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton.icon(
        icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
        label: Text(isLast ? '結果を見る' : '次へ'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLast ? kAccentGreen : kPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        onPressed: onNext,
      ),
    );
  }
}

// ─── プログレスバー（改善版） ───

class ImprovedProgressBar extends StatelessWidget {
  final double progress;
  final QuestionType questionType;

  const ImprovedProgressBar({
    Key? key,
    required this.progress,
    required this.questionType,
  }) : super(key: key);

  Color _getColor(QuestionType t) {
    switch (t) {
      case QuestionType.listening:
        return kListeningColor;
      case QuestionType.speaking:
        return kSpeakingColor;
      case QuestionType.reading:
        return kReadingColor;
      case QuestionType.writing:
        return kWritingColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: LinearProgressIndicator(
        value: progress,
        minHeight: AppSizes.progressBarHeightBold,
        backgroundColor: kBgLight,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getColor(questionType),
        ),
      ),
    );
  }
}
