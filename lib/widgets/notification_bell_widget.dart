import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/english_town_notification_provider.dart';
import '../design_system/design_system.dart';

/// Notification bell widget for app bar
class NotificationBell extends ConsumerWidget {
  final VoidCallback? onPressed;

  const NotificationBell({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return unreadCount.when(
      loading: () => const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: onPressed,
      ),
      data: (count) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: onPressed,
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Notification item widget
class NotificationItemWidget extends ConsumerWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationItemWidget({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(notificationServiceProvider);
    final emoji = service.getNotificationEmoji(notification.type);
    final color = service.getNotificationColor(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      onDismissed: (_) => onDismiss?.call(),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: notification.isRead ? AppColors.border : color,
              width: notification.isRead ? 1 : 2,
            ),
            color: notification.isRead
                ? AppColors.surfaceLight
                : color.withOpacity(0.05),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              notification.title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: notification.isRead
                    ? FontWeight.normal
                    : FontWeight.bold,
                color: notification.isRead
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.xs),
                Text(
                  notification.body,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  _formatTime(notification.createdAt),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            trailing: notification.isRead
                ? null
                : Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
            onTap: () {
              if (!notification.isRead) {
                ref
                    .read(notificationServiceProvider)
                    .markAsRead(notification.id);
              }
              onTap?.call();
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Notification center dialog
class NotificationCenter extends ConsumerWidget {
  const NotificationCenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(allNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🔔 Notifications',
                  style: AppTypography.headlineSmall,
                ),
                Tooltip(
                  message: 'Mark all as read',
                  child: GestureDetector(
                    onTap: () {
                      markAllNotificationsAsRead(ref);
                    },
                    child: Text(
                      'Clear',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: notifications.when(
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: const CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Failed to load notifications',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ),
              data: (notifs) {
                if (notifs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎉',
                            style: const TextStyle(fontSize: 48),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'No notifications yet',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifs.length,
                  itemBuilder: (context, index) {
                    final notification = notifs[index];
                    return NotificationItemWidget(
                      notification: notification,
                      onTap: () {
                        if (notification.actionUrl != null) {
                          // Handle navigation based on actionUrl
                          Navigator.pop(context);
                          _navigateToNotificationTarget(
                            context,
                            notification.actionUrl!,
                          );
                        }
                      },
                      onDismiss: () {
                        ref
                            .read(notificationServiceProvider)
                            .markAsRead(notification.id);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNotificationTarget(
    BuildContext context,
    String actionUrl,
  ) {
    // TODO: Implement navigation based on actionUrl
    // Examples:
    // /leaderboard -> Navigate to leaderboard
    // /achievements -> Navigate to achievements
    // /hub -> Navigate to hub
  }
}
