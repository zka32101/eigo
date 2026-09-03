import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_request.dart';
import '../design_system/design_system.dart';

/// Card widget for displaying a friend request
/// Shows sender info and accept/decline actions
class FriendRequestCard extends ConsumerWidget {
  final FriendRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const FriendRequestCard({
    Key? key,
    required this.request,
    this.onAccept,
    this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: AppSpacing.allPaddingSm,
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar and Name
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
                      request.senderAvatar,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                AppSpacing.horizontalSpacerMd,
                // Name and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.verticalSpacerXs,
                      Text(
                        _formatTime(request.sentAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpacerMd,

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline button
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),
                AppSpacing.horizontalSpacerMd,
                // Accept button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
