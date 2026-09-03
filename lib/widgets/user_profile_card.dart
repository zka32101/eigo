import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../design_system/design_system.dart';

/// User profile card widget
/// Displays user info, stats, and social metrics
class UserProfileCard extends ConsumerWidget {
  final UserProfile profile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onViewFriends;
  final VoidCallback? onViewFollowers;
  final bool isCurrentUser;

  const UserProfileCard({
    Key? key,
    required this.profile,
    this.onEditProfile,
    this.onViewFriends,
    this.onViewFollowers,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Level
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      profile.avatar,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                AppSpacing.horizontalSpacerMd,
                // Name, Title, Level
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (profile.title != null)
                        Text(
                          profile.title!,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      AppSpacing.verticalSpacerSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Lv. ${profile.level}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditProfile,
                  ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            // Bio
            if (profile.bio != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.bio!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppSpacing.verticalSpacerMd,
                ],
              ),

            // XP Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XP Progress',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    Text(
                      '${profile.currentXP}/1000',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: profile.currentXP / 1000,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Friends',
                  value: profile.friendCount.toString(),
                  onTap: onViewFriends,
                ),
                _StatItem(
                  label: 'Followers',
                  value: profile.followerCount.toString(),
                  onTap: onViewFollowers,
                ),
                _StatItem(
                  label: 'Following',
                  value: profile.followingCount.toString(),
                ),
                _StatItem(
                  label: 'Grade',
                  value: profile.grade.toString(),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            // Online Status
            if (!isCurrentUser)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: profile.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.horizontalSpacerSm,
                  Text(
                    profile.isOnline
                        ? 'Online'
                        : 'Last seen ${_formatLastSeen(profile.lastSeenAt)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'never';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${lastSeen.month}/${lastSeen.day}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatItem({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.verticalSpacerXs,
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}
