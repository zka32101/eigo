import 'package:flutter/material.dart';
import '../models/challenge_model.dart';
import '../design_system/design_system.dart';

class ChallengeCard extends StatelessWidget {
  final SocialChallenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool showJoinButton;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.onJoin,
    this.showJoinButton = true,
  });

  Color get _typeColor {
    switch (challenge.type) {
      case ChallengeType.individual:
        return AppColors.primary;
      case ChallengeType.team:
        return AppColors.accentGreen;
      case ChallengeType.tournament:
        return AppColors.accentPurple;
      case ChallengeType.timed:
        return AppColors.accentOrange;
      case ChallengeType.streakBased:
        return AppColors.accentRed;
      case ChallengeType.skillFocused:
        return AppColors.accentPink;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and creator
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: _typeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      challenge.typeLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: _typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    challenge.daysRemaining,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,
              // Title
              Text(
                challenge.title,
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.verticalSpacerXs,
              // Description
              Text(
                challenge.description,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.verticalSpacerMd,
              // Creator info
              Row(
                children: [
                  Text(
                    challenge.creatorAvatar,
                    style: TextStyle(fontSize: 20),
                  ),
                  AppSpacing.horizontalSpacerSm,
                  Expanded(
                    child: Text(
                      'by ${challenge.creatorName}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,
              // Participants and prize info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👥 ${challenge.currentParticipants}/${challenge.maxParticipants}',
                        style: AppTypography.bodySmall,
                      ),
                      if (challenge.firstPlacePrize != null)
                        Text(
                          '🏆 ${challenge.firstPlacePrize}XP',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.accentOrange),
                        ),
                    ],
                  ),
                  if (showJoinButton)
                    ElevatedButton(
                      onPressed: challenge.isFull ? null : onJoin,
                      child: Text(challenge.isFull ? '満員' : '参加'),
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
