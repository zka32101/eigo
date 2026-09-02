import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/english_town_notification_provider.dart';
import '../design_system/design_system.dart';

/// Notifications center and settings screen
class EnglishTownNotificationsScreen extends ConsumerWidget {
  const EnglishTownNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(allNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          title: Text(
            '🔔 Notifications',
            style: AppTypography.titleLarge.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Inbox'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationsList(context, ref, notifications),
            _buildNotificationSettings(context, ref),
          ],
        ),
      ),
    );
  }

  /// Build notifications inbox
  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppNotification>> notifications,
  ) {
    return notifications.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '⚠️',
              style: const TextStyle(fontSize: 48),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load notifications',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
      data: (notifs) {
        if (notifs.isEmpty) {
          return Center(
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
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Mark all as read button
              if (notifs.any((n) => !n.isRead))
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        markAllNotificationsAsRead(ref);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        'Mark all as read',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              // Notifications list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifs.length,
                itemBuilder: (context, index) {
                  final notification = notifs[index];
                  return _buildNotificationCard(context, ref, notification);
                },
              ),

              SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  /// Build notification card
  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    final service = ref.watch(notificationServiceProvider);
    final emoji = service.getNotificationEmoji(notification.type);
    final color = service.getNotificationColor(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      onDismissed: (_) {
        markNotificationAsRead(ref, notification.id);
      },
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
                markNotificationAsRead(ref, notification.id);
              }
            },
          ),
        ),
      ),
    );
  }

  /// Build notification settings
  Widget _buildNotificationSettings(BuildContext context, WidgetRef ref) {
    final enableRankNotifications = ref.watch(enableRankChangeNotificationsProvider);
    final enableAchievementNotifications = ref.watch(enableAchievementNotificationsProvider);
    final enableStreakNotifications = ref.watch(enableStreakNotificationsProvider);
    final enableChallengeNotifications = ref.watch(enableDailyChallengeNotificationsProvider);
    final enableTopLeaderboardNotifications = ref.watch(enableTopLeaderboardNotificationsProvider);
    final rankThreshold = ref.watch(rankChangeNotificationThresholdProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: AppSpacing.lg),

          // Notification types section
          Text(
            'Notification Types',
            style: AppTypography.headlineSmall,
          ),
          SizedBox(height: AppSpacing.md),

          // Rank change notification
          Card(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ListTile(
              title: Text(
                '📈 Rank Changes',
                style: AppTypography.bodyMedium,
              ),
              subtitle: Text(
                'Get notified when your rank changes',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: Switch(
                value: enableRankNotifications,
                onChanged: (value) {
                  ref
                      .read(enableRankChangeNotificationsProvider.notifier)
                      .state = value;
                },
              ),
            ),
          ),

          // Achievement notification
          Card(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ListTile(
              title: Text(
                '🏆 Achievements',
                style: AppTypography.bodyMedium,
              ),
              subtitle: Text(
                'Get notified when you unlock achievements',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: Switch(
                value: enableAchievementNotifications,
                onChanged: (value) {
                  ref
                      .read(enableAchievementNotificationsProvider.notifier)
                      .state = value;
                },
              ),
            ),
          ),

          // Streak notification
          Card(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ListTile(
              title: Text(
                '🔥 Streaks',
                style: AppTypography.bodyMedium,
              ),
              subtitle: Text(
                'Get notified when you reach streak milestones',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: Switch(
                value: enableStreakNotifications,
                onChanged: (value) {
                  ref
                      .read(enableStreakNotificationsProvider.notifier)
                      .state = value;
                },
              ),
            ),
          ),

          // Daily challenge notification
          Card(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ListTile(
              title: Text(
                '⭐ Daily Challenges',
                style: AppTypography.bodyMedium,
              ),
              subtitle: Text(
                'Get notified about daily challenges',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: Switch(
                value: enableChallengeNotifications,
                onChanged: (value) {
                  ref
                      .read(enableDailyChallengeNotificationsProvider.notifier)
                      .state = value;
                },
              ),
            ),
          ),

          // Top leaderboard notification
          Card(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ListTile(
              title: Text(
                '👑 Top 10 Achievement',
                style: AppTypography.bodyMedium,
              ),
              subtitle: Text(
                'Get notified when you enter the top 10',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: Switch(
                value: enableTopLeaderboardNotifications,
                onChanged: (value) {
                  ref
                      .read(enableTopLeaderboardNotificationsProvider.notifier)
                      .state = value;
                },
              ),
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Threshold settings
          Text(
            'Notification Thresholds',
            style: AppTypography.headlineSmall,
          ),
          SizedBox(height: AppSpacing.md),

          // Rank change threshold
          Card(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rank Change Threshold',
                        style: AppTypography.bodyMedium,
                      ),
                      Text(
                        '$rankThreshold positions',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Slider(
                    value: rankThreshold.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: rankThreshold.toString(),
                    onChanged: (value) {
                      ref
                          .read(rankChangeNotificationThresholdProvider.notifier)
                          .state = value.toInt();
                    },
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Only notify me when my rank changes by $rankThreshold or more positions',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Clear notifications button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  clearAllNotifications(ref);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications cleared'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                ),
                child: Text(
                  'Clear All Notifications',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.lg),
        ],
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
