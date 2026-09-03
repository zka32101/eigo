import 'package:flutter/material.dart';
import '../models/leaderboard.dart';
import '../design_system/design_system.dart';

/// Widget for displaying a leaderboard entry
class LeaderboardEntryItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const LeaderboardEntryItem({
    Key? key,
    required this.entry,
    this.isCurrentUser = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.allPaddingSm,
      color: isCurrentUser ? AppColors.primary.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getRankColor(entry.rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                          style: const TextStyle(fontSize: 24),
                        ),
                        AppSpacing.horizontalSpacerSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.userName,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Level ${entry.level} • ${entry.lessonsCompleted} lessons',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerXs,
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatChip(
                          label: 'Score',
                          value: entry.score.toString(),
                          icon: Icons.star,
                        ),
                        _StatChip(
                          label: 'Streak',
                          value: entry.streakCount.toString(),
                          icon: Icons.local_fire_department,
                        ),
                        _StatChip(
                          label: 'Accuracy',
                          value: '${entry.averageAccuracy}%',
                          icon: Icons.check_circle,
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

  Color _getRankColor(int rank) {
    if (rank == 1) {
      return const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      return const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      return const Color(0xFFCD7F32); // Bronze
    } else if (rank <= 10) {
      return AppColors.primary;
    } else {
      return AppColors.surfaceVariant;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: AppColors.primary,
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
