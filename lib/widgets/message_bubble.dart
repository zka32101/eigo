import 'package:flutter/material.dart';
import '../models/message.dart';
import '../design_system/design_system.dart';

/// Widget for displaying a single message in a conversation
/// Shows different styling for sent vs received messages
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSent; // true if current user sent this message
  final VoidCallback? onLongPress;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isSent,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSent ? 64 : 8,
        right: isSent ? 8 : 64,
        top: 4,
        bottom: 4,
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Align(
          alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSent
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSent ? Colors.white : AppColors.textPrimary,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.sentAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    if (isSent && message.isRead) ...[
                      AppSpacing.horizontalSpacerXs,
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDay == today) {
      // Show time only if today
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      // Show "Yesterday" if yesterday
      return 'Yesterday';
    } else {
      // Show date
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
