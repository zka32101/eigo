import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../design_system/design_system.dart';

/// Widget for displaying an achievement
class AchievementItem extends StatelessWidget {
  final UserAchievement userAchievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementItem({
    Key? key,
    required this.userAchievement,
    required this.isUnlocked,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final achievement = userAchievement.achievement;

    return Card(
      margin: AppSpacing.allPaddingSm,
      color: isUnlocked ? null : AppColors.surfaceVariant.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Row(
            children: [
              // Achievement icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getCategoryColor(achievement.category)
                      : AppColors.textMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              AppSpacing.horizontalSpacerMd,
              // Achievement info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                                ),
                          ),
                        ),
                        if (isUnlocked)
                          Icon(
                            Icons.check_circle,
                            color: _getCategoryColor(achievement.category),
                            size: 20,
                          ),
                      ],
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalSpacerXs,
                    if (!isUnlocked)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: userAchievement.progress / 100,
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(
                            _getCategoryColor(achievement.category),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${achievement.rewardPoints} pts',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _getCategoryColor(achievement.category),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (!isUnlocked)
                          Text(
                            '${userAchievement.progress}% complete',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(AchievementCategory category) {
    return switch (category) {
      AchievementCategory.milestone => const Color(0xFF4CAF50),
      AchievementCategory.streak => const Color(0xFFFF9800),
      AchievementCategory.accuracy => const Color(0xFF2196F3),
      AchievementCategory.social => const Color(0xFF9C27B0),
      AchievementCategory.challenge => const Color(0xFFF44336),
      AchievementCategory.collection => const Color(0xFF00BCD4),
    };
  }
}

class BadgeItem extends StatelessWidget {
  final UserBadge userBadge;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;
  final bool canEquip;

  const BadgeItem({
    Key? key,
    required this.userBadge,
    this.onTap,
    this.onEquip,
    required this.canEquip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badge = userBadge.badge;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getRarityColor(badge.rarity),
              shape: BoxShape.circle,
              border: userBadge.isEquipped
                  ? Border.all(color: AppColors.primary, width: 3)
                  : null,
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          AppSpacing.verticalSpacerSm,
          Text(
            badge.name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (canEquip && !userBadge.isEquipped)
            TextButton(
              onPressed: onEquip,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              child: Text(
                'Equip',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            )
          else if (userBadge.isEquipped)
            Text(
              'Equipped',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
        ],
      ),
    );
  }

  Color _getRarityColor(BadgeRarity rarity) {
    return switch (rarity) {
      BadgeRarity.common => AppColors.surfaceVariant,
      BadgeRarity.uncommon => const Color(0xFF4CAF50),
      BadgeRarity.rare => const Color(0xFF2196F3),
      BadgeRarity.epic => const Color(0xFF9C27B0),
      BadgeRarity.legendary => const Color(0xFFFFD700),
    };
  }
}
