import 'package:flutter/material.dart';
import '../models/leaderboard_model.dart';
import '../design_system/design_system.dart';

class LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final VoidCallback? onTap;
  final bool showMetricDetail;

  const LeaderboardEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.showMetricDetail = true,
  });

  Color get _rankColor {
    if (entry.rank == 1) return const Color(0xFFFFD700); // Gold
    if (entry.rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (entry.rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.textMuted;
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
              // Rank badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _rankColor.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: _rankColor, width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (entry.rank <= 3)
                        Text(
                          entry.rankDisplay,
                          style: TextStyle(fontSize: 20),
                        )
                      else
                        Text(
                          '${entry.rank}',
                          style: AppTypography.labelSmall.copyWith(
                            color: _rankColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              AppSpacing.horizontalSpacerMd,
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.userAvatar,
                          style: TextStyle(fontSize: 20),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.userName,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (entry.isFriend)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen.withAlpha(30),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '👥 フレンド',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.accentGreen,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              if (entry.isCurrentUser)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '✨ あなた',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerXs,
                    Row(
                      children: [
                        Text(
                          'Lv${entry.level}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        Text(
                          '🔥 ${entry.streakDays}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        Text(
                          '⭐ ${entry.badgesEarned}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.scoreLabel,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (showMetricDetail)
                    Text(
                      'スコア',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    '${entry.lessonsCompleted} レッスン',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
