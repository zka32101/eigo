import 'package:flutter/material.dart';
import '../models/friend_request.dart';
import '../design_system/design_system.dart';

/// List item widget for displaying a friend
/// Shows friend info with optional action buttons
class FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onBlock;

  const FriendListItem({
    Key? key,
    required this.friend,
    this.onTap,
    this.onRemove,
    this.onBlock,
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
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        friend.avatar,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSpacerMd,
                  // Name, Level, Grade
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppSpacing.verticalSpacerXs,
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Lv. ${friend.level}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ),
                            AppSpacing.horizontalSpacerSm,
                            Text(
                              'Grade ${friend.grade}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Online indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: friend.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              // Action buttons (if provided)
              if (onRemove != null || onBlock != null) ...[
                AppSpacing.verticalSpacerMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onRemove != null)
                      TextButton.icon(
                        onPressed: onRemove,
                        icon: const Icon(Icons.person_remove),
                        label: const Text('Remove'),
                      ),
                    if (onBlock != null)
                      TextButton.icon(
                        onPressed: onBlock,
                        icon: const Icon(Icons.block),
                        label: const Text('Block'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
