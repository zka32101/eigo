import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../providers/notification_service_provider.dart';
import '../widgets/notification_item.dart';
import '../design_system/design_system.dart';

class NotificationsScreen extends ConsumerWidget {
  final String currentUserId;

  const NotificationsScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider(currentUserId));
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider(currentUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          unreadCountAsync.when(
            data: (count) {
              if (count == 0) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(markAllAsReadActionProvider.notifier).state = currentUserId;
                    },
                    child: Text(
                      'Mark all read',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading notifications',
                  style: Theme.of(context).textTheme.titleMedium),
              AppSpacing.verticalSpacerMd,
              ElevatedButton(
                onPressed: () => ref.refresh(notificationsStreamProvider(currentUserId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: AppColors.textMuted),
                  AppSpacing.verticalSpacerMd,
                  Text('No notifications', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationItem(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    ref.read(markNotificationAsReadActionProvider.notifier).state = notification.id;
                  }
                },
                onDelete: () {
                  ref.read(deleteNotificationActionProvider.notifier).state = notification.id;
                },
              );
            },
          );
        },
      ),
    );
  }
}
