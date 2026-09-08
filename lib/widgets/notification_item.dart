import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../design_system/design_system.dart';

class NotificationItem extends StatelessWidget {
  final Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationItem({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.allPaddingSm,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(),
              AppSpacing.horizontalSpacerMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: notification.isRead ? AppColors.textMuted : AppColors.textPrimary,
                                ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      _formatTime(notification.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.challengeStarting:
        icon = Icons.lightning_bolt;
        color = Colors.yellow;
      case NotificationType.challengeEnding:
        icon = Icons.flag;
        color = Colors.orange;
      case NotificationType.challengeCompleted:
        icon = Icons.check_circle;
        color = Colors.green;
      case NotificationType.achievementUnlocked:
        icon = Icons.emoji_events;
        color = Colors.amber;
      case NotificationType.levelUp:
        icon = Icons.trending_up;
        color = Colors.cyan;
      case NotificationType.streakMilestone:
        icon = Icons.flame_free;
        color = Colors.red;
      case NotificationType.petEvolved:
        icon = Icons.pets;
        color = Colors.pink;
      case NotificationType.videoRecommended:
        icon = Icons.video_library;
        color = Colors.purple;
      case NotificationType.friendChallengeInvite:
        icon = Icons.person_add;
        color = Colors.blue;
      case NotificationType.friendChallengeCompleted:
        icon = Icons.group;
        color = Colors.teal;
      case NotificationType.dailyQuestReminder:
        icon = Icons.schedule;
        color = Colors.indigo;
      case NotificationType.shopItemNew:
        icon = Icons.shopping_bag;
        color = Colors.deepOrange;
      case NotificationType.custom:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${dateTime.month}/${dateTime.day}';
  }
}
