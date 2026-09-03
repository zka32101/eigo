import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/notification_card.dart';
import '../design_system/design_system.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.id ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('📬 通知')),
        body: const Center(child: Text('ユーザーが見つかりません')),
      );
    }

    final notificationsAsync = ref.watch(userNotificationsProvider(userId));
    final unreadCountAsync = ref.watch(unreadCountProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('📬 通知'),
        elevation: 0,
        actions: [
          unreadCountAsync.when(
            data: (unreadCount) {
              if (unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    ref.read(markAllAsReadActionProvider(userId));
                  },
                  child: const Text('すべて読む'),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '📭',
                    style: TextStyle(fontSize: 64),
                  ),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    '通知はまだありません',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.allPaddingMd,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    ref.read(
                      markAsReadActionProvider(
                        MarkAsReadParams(
                          notificationId: notification.id,
                          userId: userId,
                        ),
                      ),
                    );
                  }
                  if (notification.actionRoute != null) {
                    Navigator.of(context).pushNamed(
                      notification.actionRoute!,
                      arguments: notification.actionData,
                    );
                  }
                },
                onDismiss: () {
                  ref.read(
                    deleteNotificationActionProvider(
                      DeleteNotificationParams(
                        notificationId: notification.id,
                        userId: userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }
}
