import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../providers/message_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';
import '../widgets/message_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  String? _replyToMessageId;
  String? _replyToAuthor;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationProvider(widget.conversationId));
    final messagesAsync = ref.watch(conversationMessagesProvider(widget.conversationId));
    final chatInput = ref.watch(chatInputProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: conversationAsync.when(
          data: (conversation) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conversation.displayName),
              Text(
                conversation.type == ConversationType.direct
                    ? 'オンライン'
                    : '${conversation.participantIds.length}人のメンバー',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          loading: () => const Text('読込中...'),
          error: (error, stackTrace) => const Text('エラー'),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'メッセージの読み込みに失敗しました',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.refresh(conversationMessagesProvider(widget.conversationId)),
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return CustomScrollView(
                  reverse: true,
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final message = messages[index];
                            final isCurrentUser = message.senderId == currentUserId;
                            String? replyAuthor;

                            if (message.replyToMessageId != null) {
                              final replyTo = messages.firstWhere(
                                (m) => m.id == message.replyToMessageId,
                                orElse: () => message,
                              );
                              replyAuthor = replyTo.senderName;
                            }

                            return MessageCard(
                              message: message,
                              isCurrentUser: isCurrentUser,
                              replyToAuthor: replyAuthor,
                              onEdit: isCurrentUser
                                  ? () => _editMessage(message)
                                  : null,
                              onDelete: isCurrentUser
                                  ? () => _deleteMessage(message)
                                  : null,
                              onReply: () => _replyToMessage(message),
                            );
                          },
                          childCount: messages.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_replyToMessageId != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.surfaceVariant,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_replyToAuthorへの返信',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'メッセージを入力...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _replyToMessageId = null;
                        _replyToAuthor = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          _buildMessageInput(ref, currentUserId),
        ],
      ),
    );
  }

  Widget _buildMessageInput(WidgetRef ref, String currentUserId) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Show attachment menu
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'メッセージを入力...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  ref.read(chatInputProvider.notifier).state = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            if (_messageController.text.isNotEmpty)
              FloatingActionButton(
                mini: true,
                onPressed: () => _sendMessage(ref, currentUserId),
                child: const Icon(Icons.send),
              )
            else
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: () {
                  // TODO: Show emoji picker
                },
              ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(WidgetRef ref, String currentUserId) {
    if (_messageController.text.isEmpty) return;

    final messageContent = _messageController.text;
    _messageController.clear();

    ref.read(sendMessageActionProvider.notifier).state = SendMessageParams(
      conversationId: widget.conversationId,
      senderId: currentUserId,
      senderName: 'Current User', // TODO: Get from user profile
      senderAvatar: '👤', // TODO: Get from user profile
      content: messageContent,
      messageType: MessageType.text,
      replyToMessageId: _replyToMessageId,
    );

    setState(() {
      _replyToMessageId = null;
      _replyToAuthor = null;
    });

    _scrollToBottom();
  }

  void _editMessage(Message message) {
    _messageController.text = message.content;
    // TODO: Implement edit functionality
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メッセージを削除'),
        content: const Text('このメッセージを削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(deleteMessageActionProvider.notifier).state = DeleteMessageParams(
                conversationId: widget.conversationId,
                messageId: message.id,
              );
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(Message message) {
    setState(() {
      _replyToMessageId = message.id;
      _replyToAuthor = message.senderName;
    });
    _messageController.requestFocus();
  }
}
