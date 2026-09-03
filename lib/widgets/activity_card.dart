import 'package:flutter/material.dart';
import '../models/social_model.dart';
import '../design_system/design_system.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final bool showUserAvatar;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.showUserAvatar = true,
  });

  Color get _activityColor {
    switch (activity.type) {
      case ActivityType.levelUp:
        return AppColors.accentPurple;
      case ActivityType.stageCompleted:
        return AppColors.primary;
      case ActivityType.challengeWon:
        return AppColors.accentOrange;
      case ActivityType.achievementUnlocked:
        return AppColors.accentGreen;
      case ActivityType.streakMilestone:
        return AppColors.accentRed;
      case ActivityType.purchaseMade:
        return AppColors.accentPink;
      case ActivityType.friendAdded:
        return AppColors.primary;
      case ActivityType.badgeEarned:
        return AppColors.accentGreen;
      case ActivityType.courseCompleted:
        return AppColors.primary;
      case ActivityType.scoreRecord:
        return AppColors.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Activity emoji/icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _activityColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    activity.emoji,
                    style: TextStyle(fontSize: AppTypography.headlineMedium.fontSize),
                  ),
                ),
              ),
              AppSpacing.horizontalSpacerMd,
              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          activity.typeLabel,
                          style: AppTypography.bodySmall.copyWith(
                            color: _activityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      activity.description,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      activity.timeAgo,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (showUserAvatar)
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        activity.userAvatar ?? '👤',
                        style: TextStyle(fontSize: AppTypography.displaySmall.fontSize),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
