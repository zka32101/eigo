import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_pace_model.dart';
import '../providers/learning_pace_provider.dart';
import '../design_system/design_system.dart';

class LearningPaceScreen extends ConsumerWidget {
  const LearningPaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paceRecommendation = ref.watch(learningPaceProvider);
    final userPreference = ref.watch(userPacePreferenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 学習ペース設定'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: paceRecommendation.when(
        data: (recommendation) {
          if (recommendation == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up, size: 64, color: AppColors.textMuted),
                  AppSpacing.verticalSpacerMd,
                  const Text('学習データを分析中...'),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: AppSpacing.allPaddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 推奨ペース情報カード
                _RecommendationCard(recommendation: recommendation),
                AppSpacing.verticalSpacerLg,

                // ペースレベル選択
                Text('希望する学習ペース', style: AppTypography.headlineSmall),
                AppSpacing.verticalSpacerMd,
                _PaceLevelSelector(
                  currentLevel: userPreference.preferredPaceLevel,
                  onLevelChanged: (level) {
                    ref
                        .read(userPacePreferenceProvider.notifier)
                        .updatePaceLevel(level);
                  },
                ),
                AppSpacing.verticalSpacerLg,

                // 推奨開始時刻
                Text('推奨学習開始時刻', style: AppTypography.headlineSmall),
                AppSpacing.verticalSpacerMd,
                _StartTimeSelector(
                  hour: userPreference.preferredStartHour,
                  minute: userPreference.preferredStartMinute,
                  onTimeChanged: (hour, minute) {
                    ref
                        .read(userPacePreferenceProvider.notifier)
                        .updateStartTime(hour, minute);
                  },
                ),
                AppSpacing.verticalSpacerLg,

                // 通知設定
                Text('自動通知', style: AppTypography.headlineSmall),
                AppSpacing.verticalSpacerMd,
                _NotificationToggle(
                  enabled: userPreference.autoNotificationEnabled,
                  onToggled: (enabled) {
                    ref
                        .read(userPacePreferenceProvider.notifier)
                        .toggleNotification(enabled);
                  },
                ),
                AppSpacing.verticalSpacerXxl,
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              AppSpacing.verticalSpacerMd,
              const Text('学習ペースを分析中...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.accentRed),
              AppSpacing.verticalSpacerMd,
              Text('エラーが発生しました: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final LearningPaceRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final paceEmoji = _getPaceEmoji(recommendation.paceLevel);
    final paceLabel = _getPaceLabel(recommendation.paceLevel);

    return Container(
      padding: AppSpacing.allPaddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withAlpha(20), AppColors.primary.withAlpha(5)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ペースレベル表示
          Row(
            children: [
              Text(paceEmoji, style: TextStyle(fontSize: AppTypography.displayLarge.fontSize! * 1.5)),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('推奨ペース', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    Text(paceLabel, style: AppTypography.headlineMedium),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,

          // 推奨理由
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('推奨理由', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                AppSpacing.verticalSpacerSm,
                Text(recommendation.reason, style: AppTypography.bodyMedium),
              ],
            ),
          ),
          AppSpacing.verticalSpacerMd,

          // 推奨セッション情報
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: '推奨時間',
                  value: '${recommendation.recommendedDuration.inMinutes}分',
                  icon: '⏱️',
                ),
              ),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: _InfoBox(
                  label: '1日の目標',
                  value: '${recommendation.dailyGoal}問',
                  icon: '🎯',
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,

          // 信頼度スコア
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('信頼度', style: AppTypography.labelSmall),
                  Text('${recommendation.confidenceScore}%', style: AppTypography.labelSmall),
                ],
              ),
              AppSpacing.verticalSpacerSm,
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: recommendation.confidenceScore / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.bgLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getConfidenceColor(recommendation.confidenceScore),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,

          // アドバイス
          if (recommendation.tips.isNotEmpty) ...[
            Text('💡 アドバイス', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
            AppSpacing.verticalSpacerSm,
            ...recommendation.tips.map((tip) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(tip, style: AppTypography.bodySmall),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  String _getPaceEmoji(String level) {
    switch (level) {
      case 'fast':
        return '🚀';
      case 'normal':
        return '⚡';
      case 'slow':
        return '🌱';
      default:
        return '📊';
    }
  }

  String _getPaceLabel(String level) {
    switch (level) {
      case 'fast':
        return '高速ペース';
      case 'normal':
        return '標準ペース';
      case 'slow':
        return 'ゆっくりペース';
      default:
        return '未決定';
    }
  }

  Color _getConfidenceColor(int score) {
    if (score >= 80) return AppColors.accentGreen;
    if (score >= 70) return AppColors.accentOrange;
    return AppColors.accentRed;
  }
}

class _PaceLevelSelector extends StatelessWidget {
  final String currentLevel;
  final Function(String) onLevelChanged;

  const _PaceLevelSelector({
    required this.currentLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaceButton(
          emoji: '🌱',
          label: 'ゆっくり',
          description: '1日5-10分\n短くても毎日続ける',
          isSelected: currentLevel == 'slow',
          onTap: () => onLevelChanged('slow'),
        ),
        AppSpacing.verticalSpacerMd,
        _PaceButton(
          emoji: '⚡',
          label: '標準',
          description: '1日15-20分\nバランス重視',
          isSelected: currentLevel == 'normal',
          onTap: () => onLevelChanged('normal'),
        ),
        AppSpacing.verticalSpacerMd,
        _PaceButton(
          emoji: '🚀',
          label: '高速',
          description: '1日40分以上\nガンガン進める',
          isSelected: currentLevel == 'fast',
          onTap: () => onLevelChanged('fast'),
        ),
      ],
    );
  }
}

class _PaceButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaceButton({
    required this.emoji,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
      child: Container(
        padding: AppSpacing.allPaddingMd,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.bgLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: AppTypography.displayMedium.fontSize! * 1.43)),
            AppSpacing.horizontalSpacerMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.labelLarge),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.textWhite, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _StartTimeSelector extends StatefulWidget {
  final int hour;
  final int minute;
  final Function(int, int) onTimeChanged;

  const _StartTimeSelector({
    required this.hour,
    required this.minute,
    required this.onTimeChanged,
  });

  @override
  State<_StartTimeSelector> createState() => _StartTimeSelectorState();
}

class _StartTimeSelectorState extends State<_StartTimeSelector> {
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.hour;
    selectedMinute = widget.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.bgLight.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.bgLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 時間選択
              _TimePickerColumn(
                label: '時間',
                value: selectedHour,
                min: 0,
                max: 23,
                onChanged: (value) {
                  setState(() => selectedHour = value);
                  widget.onTimeChanged(selectedHour, selectedMinute);
                },
              ),
              Text(':', style: AppTypography.headlineSmall),
              // 分選択
              _TimePickerColumn(
                label: '分',
                value: selectedMinute,
                min: 0,
                max: 59,
                step: 5,
                onChanged: (value) {
                  setState(() => selectedMinute = value);
                  widget.onTimeChanged(selectedHour, selectedMinute);
                },
              ),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            '毎日 ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} に学習開始',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _TimePickerColumn extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final Function(int) onChanged;

  const _TimePickerColumn({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_drop_up),
            onPressed: value < max ? () => onChanged(value + step) : null,
          ),
          Text(
            value.toString().padLeft(2, '0'),
            style: AppTypography.headlineMedium,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: value > min ? () => onChanged(value - step) : null,
          ),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final bool enabled;
  final Function(bool) onToggled;

  const _NotificationToggle({
    required this.enabled,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: enabled ? AppColors.accentGreen.withAlpha(20) : AppColors.bgLight.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          color: enabled ? AppColors.accentGreen : AppColors.bgLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔔 毎日の学習リマインダー',
                  style: AppTypography.labelLarge,
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  enabled ? '通知が有効です' : '通知が無効です',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggled,
            activeColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.bgLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: AppTypography.displaySmall.fontSize)),
          AppSpacing.verticalSpacerXs,
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
