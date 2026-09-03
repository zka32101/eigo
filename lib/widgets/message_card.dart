import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../design_system/design_system.dart';

class MessageCard extends ConsumerWidget {
  final Message message;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final bool showAvatar;
  final String? replyToAuthor;

  const MessageCard({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.showAvatar = true,
    this.replyToAuthor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (message.isDeleted) {
      return _buildDeletedMessage();
    }

    return GestureDetector(
      onLongPress: isCurrentUser ? () => _showMessageMenu(context) : null,
      child: Padding(
        padding: EdgeInsets.only(
          left: isCurrentUser ? 48 : 8,
          right: isCurrentUser ? 8 : 48,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser && showAvatar) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceVariant,
                child: Text(
                  message.senderAvatar ?? '👤',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 8),
            ] else if (!isCurrentUser)
              const SizedBox(width: 40),
            Flexible(
              child: Column(
                crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text(
                        message.senderName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  if (replyToAuthor != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surfaceVariant,
                        borderLeft: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Reply to $replyToAuthor',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: isCurrentUser ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: _buildMessageContent(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Text(
                          message.formattedTime,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 4),
                          _buildStatusIndicator(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    final textColor = isCurrentUser ? Colors.white : AppColors.textPrimary;

    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(color: textColor),
          maxLines: null,
        );

      case MessageType.emoji:
        return Text(
          message.content,
          style: const TextStyle(fontSize: 48),
        );

      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.imageUrl ?? '',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: AppColors.surfaceVariant,
                child: Icon(Icons.image_not_supported, color: textColor),
              );
            },
          ),
        );

      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_filled, color: textColor),
            const SizedBox(width: 8),
            Text(
              'Audio message',
              style: TextStyle(color: textColor),
            ),
          ],
        );

      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_file, color: textColor),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'File',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatFileSize(message.fileSizeBytes ?? 0),
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );

      case MessageType.system:
        return Text(
          message.content,
          style: TextStyle(
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  Widget _buildStatusIndicator() {
    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textMuted),
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: AppColors.textMuted);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: AppColors.textMuted);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 14, color: AppColors.primary);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 14, color: Colors.red);
    }
  }

  Widget _buildDeletedMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          '[削除されたメッセージ]',
          style: TextStyle(
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showMessageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('返信'),
                onTap: () {
                  Navigator.pop(context);
                  onReply!();
                },
              ),
            if (onEdit != null && message.type == MessageType.text)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('編集'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('削除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
