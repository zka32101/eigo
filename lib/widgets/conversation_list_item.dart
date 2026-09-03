import 'package:flutter/material.dart';
import '../models/message.dart';
import '../design_system/design_system.dart';

/// List item widget for displaying a conversation in the conversation list
class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ConversationListItem({
    Key? key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.allPaddingSm,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        conversation.otherUserAvatar,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  // Online indicator
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.horizontalSpacerMd,
              // Message content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.otherUserName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          _formatTime(conversation.lastMessageTime),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpacerXs,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: conversation.isRead
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  fontWeight: conversation.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                          ),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          AppSpacing.horizontalSpacerSm,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (messageDay.year == today.year) {
      return '${dateTime.month}/${dateTime.day}';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }
}
