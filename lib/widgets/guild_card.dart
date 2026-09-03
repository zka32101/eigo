import 'package:flutter/material.dart';
import '../models/guild.dart';
import '../design_system/design_system.dart';

/// Widget for displaying a guild card
class GuildCard extends StatelessWidget {
  final Guild guild;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool isJoined;

  const GuildCard({
    Key? key,
    required this.guild,
    this.onTap,
    this.onJoin,
    required this.isJoined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.allPaddingSm,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and tier
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    guild.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  _TierBadge(tier: guild.tier),
                ],
              ),
              AppSpacing.verticalSpacerMd,
              // Guild name and description
              Text(
                guild.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.verticalSpacerXs,
              Text(
                guild.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.verticalSpacerMd,
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    label: 'Level',
                    value: guild.level.toString(),
                    icon: Icons.trending_up,
                  ),
                  _StatItem(
                    label: 'Members',
                    value: guild.memberIds.length.toString(),
                    icon: Icons.people,
                  ),
                  _StatItem(
                    label: 'Score',
                    value: (guild.totalScore ~/ 1000).toString() + 'K',
                    icon: Icons.star,
                  ),
                ],
              ),
              AppSpacing.verticalSpacerMd,
              // Join button or joined indicator
              if (!isJoined && guild.settings.joinType == GuildJoinType.open)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Join Guild'),
                  ),
                )
              else if (isJoined)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Member',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Apply to Join',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textMuted,
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

class _TierBadge extends StatelessWidget {
  final GuildTier tier;

  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tier) {
      GuildTier.bronze => ('Bronze', const Color(0xFFCD7F32)),
      GuildTier.silver => ('Silver', const Color(0xFFC0C0C0)),
      GuildTier.gold => ('Gold', const Color(0xFFFFD700)),
      GuildTier.platinum => ('Platinum', const Color(0xFFE5E4E2)),
      GuildTier.diamond => ('Diamond', const Color(0xFF00D9FF)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tier == GuildTier.silver || tier == GuildTier.platinum
                  ? Colors.black
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
