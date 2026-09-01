import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../providers/notification_settings_provider.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class NotificationManagementScreen extends ConsumerWidget {
  const NotificationManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationHistoryProvider.select((n) => n.where((x) => !x.isRead).length));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🔔 通知'),
          backgroundColor: kPrimaryColor,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kAccentOrange,
            tabs: [
              const Tab(text: '設定'),
              Tab(
                child: Stack(
                  children: [
                    const Text('履歴'),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: kAccentRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 通知設定タブ
            _NotificationSettingsTab(),
            // 通知履歴タブ
            _NotificationHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _NotificationSettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本設定
          Text('通知について', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          Container(
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('音声', style: AppTypography.labelLarge),
                          AppSpacing.verticalSpacerXs,
                          Text(
                            '通知時に音が出ます',
                            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.soundEnabled,
                      onChanged: (value) {
                        ref.read(notificationSettingsProvider.notifier).setSoundEnabled(value);
                      },
                      activeColor: kAccentGreen,
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('振動', style: AppTypography.labelLarge),
                          AppSpacing.verticalSpacerXs,
                          Text(
                            '通知時に端末が振動します',
                            style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.vibrationEnabled,
                      onChanged: (value) {
                        ref.read(notificationSettingsProvider.notifier).setVibrationEnabled(value);
                      },
                      activeColor: kAccentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // 学習通知
          Text('学習通知', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          _NotificationToggleCard(
            title: '日常学習リマインダー',
            description: '毎日の学習をリマインドします',
            isEnabled: settings.dailyRemindersEnabled,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setDailyRemindersEnabled(value);
            },
            child: Column(
              children: [
                AppSpacing.verticalSpacerMd,
                _TimePickerRow(
                  label: 'リマインダー時刻',
                  hour: settings.dailyReminderHour,
                  onHourChanged: (hour) {
                    ref.read(notificationSettingsProvider.notifier).setDailyReminderHour(hour);
                  },
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerMd,
          _NotificationToggleCard(
            title: 'ストリークリマインダー',
            description: '連続学習記録を維持するようリマインドします',
            isEnabled: settings.streakRemindersEnabled,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setStreakRemindersEnabled(value);
            },
            child: Column(
              children: [
                AppSpacing.verticalSpacerMd,
                _TimePickerRow(
                  label: 'リマインダー時刻',
                  hour: settings.streakReminderHour,
                  onHourChanged: (hour) {
                    ref.read(notificationSettingsProvider.notifier).setStreakReminderHour(hour);
                  },
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpacerLg,

          // その他の通知
          Text('その他の通知', style: AppTypography.headlineSmall),
          AppSpacing.verticalSpacerMd,
          _NotificationToggleCard(
            title: 'アチーブメント通知',
            description: 'バッジやミッション達成時に通知します',
            isEnabled: settings.achievementNotifications,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setAchievementNotifications(value);
            },
          ),
          AppSpacing.verticalSpacerMd,
          _NotificationToggleCard(
            title: 'フレンド通知',
            description: 'フレンドリクエストなどをお知らせします',
            isEnabled: settings.friendNotifications,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setFriendNotifications(value);
            },
          ),
          AppSpacing.verticalSpacerMd,
          _NotificationToggleCard(
            title: 'キャンペーン通知',
            description: 'お得なキャンペーンをお知らせします',
            isEnabled: settings.promotionalNotifications,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setPromotionalNotifications(value);
            },
          ),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _NotificationHistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationHistoryProvider);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: kTextMuted),
            AppSpacing.verticalSpacerMd,
            const Text('通知がありません'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.allPaddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${notifications.length}件の通知', style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
              if (notifications.any((n) => !n.isRead))
                TextButton(
                  onPressed: () {
                    ref.read(notificationHistoryProvider.notifier).markAllAsRead();
                  },
                  child: const Text('すべて既読'),
                ),
            ],
          ),
          AppSpacing.verticalSpacerMd,
          ...notifications.asMap().entries.map((entry) {
            final notification = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _NotificationCard(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    ref.read(notificationHistoryProvider.notifier).markAsRead(notification.notificationId);
                  }
                },
                onDelete: () {
                  ref.read(notificationHistoryProvider.notifier).deleteNotification(notification.notificationId);
                },
              ),
            );
          }).toList(),
          AppSpacing.verticalSpacerXxl,
        ],
      ),
    );
  }
}

class _NotificationToggleCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  final Widget? child;

  const _NotificationToggleCard({
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.onChanged,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: isEnabled ? kAccentGreen.withAlpha(10) : Colors.grey[50],
        border: Border.all(
          color: isEnabled ? kAccentGreen.withAlpha(50) : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelLarge),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onChanged,
                activeColor: kAccentGreen,
              ),
            ],
          ),
          if (child != null && isEnabled) child!,
        ],
      ),
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  final String label;
  final int hour;
  final ValueChanged<int> onHourChanged;

  const _TimePickerRow({
    required this.label,
    required this.hour,
    required this.onHourChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        SizedBox(
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: hour > 0 ? () => onHourChanged(hour - 1) : null,
                iconSize: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                ),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: AppTypography.labelLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: hour < 23 ? () => onHourChanged(hour + 1) : null,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationRecord notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.dailyReminder:
        return '📚 リマインダー';
      case NotificationType.streakMaintenance:
        return '🔥 ストリーク';
      case NotificationType.achievement:
        return '🏆 アチーブメント';
      case NotificationType.levelUp:
        return '📈 レベルアップ';
      case NotificationType.friendRequest:
        return '👥 フレンド';
      case NotificationType.promotionalOffer:
        return '💰 キャンペーン';
      case NotificationType.systemMessage:
        return '📢 システム';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.allPaddingMd,
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : kPrimaryColor.withAlpha(10),
          border: Border.all(
            color: notification.isRead ? Colors.grey[300]! : kPrimaryColor.withAlpha(50),
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_getTypeLabel(notification.type), style: AppTypography.labelSmall.copyWith(color: kTextMuted)),
                      if (!notification.isRead)
                        Padding(
                          padding: EdgeInsets.only(left: AppSpacing.sm),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kAccentRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(notification.title, style: AppTypography.labelLarge),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    notification.message,
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpacerXs,
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTypography.bodySmall.copyWith(color: kTextMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }
}
