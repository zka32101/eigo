import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../design_system/design_system.dart';

class AchievementCard extends ConsumerWidget {
  final Achievement achievement;
  final UserAchievement? userAchievement;
  final AchievementProgress? progress;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final bool showDetails;

  const AchievementCard({
    Key? key,
    required this.achievement,
    this.userAchievement,
    this.progress,
    required this.isUnlocked,
    this.onTap,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: isUnlocked ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isUnlocked
          ? Colors.white
          : AppColors.surfaceVariant.withOpacity(0.5),
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Achievement icon and tier badge
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? _getAchievementColor()
                          : AppColors.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.primary : AppColors.textMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      achievement.tierLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Name and description
              Text(
                achievement.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? AppColors.textMuted : AppColors.textMuted.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Progress bar (if available)
              if (progress != null && !isUnlocked)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress!.progressPercent / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress!.progressDisplay,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              if (isUnlocked) const SizedBox(height: 8),
              // Rewards
              if (showDetails)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.textMuted.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RewardBadge(
                        icon: '⭐',
                        value: achievement.rewardXp,
                        label: 'XP',
                        isActive: isUnlocked,
                      ),
                      _RewardBadge(
                        icon: '💰',
                        value: achievement.rewardCoins,
                        label: 'Coins',
                        isActive: isUnlocked,
                      ),
                      if (achievement.rewardBadges.isNotEmpty)
                        _RewardBadge(
                          icon: '🏅',
                          value: achievement.rewardBadges.length,
                          label: 'Badges',
                          isActive: isUnlocked,
                        ),
                    ],
                  ),
                ),
              // Status badge
              if (isUnlocked && userAchievement != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _AchievementStatusBadge(userAchievement: userAchievement!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAchievementColor() {
    switch (achievement.tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32).withOpacity(0.2);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0).withOpacity(0.2);
      case AchievementTier.gold:
        return const Color(0xFFFFD700).withOpacity(0.2);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2).withOpacity(0.2);
      case AchievementTier.legendary:
        return const Color(0xFFFF6B6B).withOpacity(0.2);
    }
  }
}

class _RewardBadge extends StatelessWidget {
  final String icon;
  final int value;
  final String label;
  final bool isActive;

  const _RewardBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : AppColors.textMuted,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _AchievementStatusBadge extends StatelessWidget {
  final UserAchievement userAchievement;

  const _AchievementStatusBadge({required this.userAchievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: userAchievement.isRewarded ? AppColors.accentGreen : AppColors.accentOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            userAchievement.isRewarded ? '✓ 報酬受取済み' : '🎁 報酬待機中',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            userAchievement.timeAgo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
