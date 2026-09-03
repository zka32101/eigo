import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../providers/messaging_service_provider.dart';
import '../providers/user_profile_service_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/conversation_list_item.dart';
import '../design_system/design_system.dart';

/// Main messaging screen with conversation list and chat view
/// Phase 14 Part 3: Messaging System
class MessagingScreen extends ConsumerStatefulWidget {
  final String currentUserId;

  const MessagingScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  late TextEditingController _messageController;
  late TextEditingController _searchController;
  late ScrollController _messagesScrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _searchController = TextEditingController();
    _messagesScrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedConversation = ref.watch(selectedConversationProvider);

    if (selectedConversation != null) {
      return _buildConversationView(selectedConversation);
    } else {
      return _buildConversationListView();
    }
  }

  Widget _buildConversationListView() {
    final conversationsAsync = ref.watch(conversationListProvider(widget.currentUserId));
    final currentUserAsync = ref.watch(userProfileProvider(widget.currentUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorWidget(() => ref.refresh(conversationListProvider(widget.currentUserId))),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  AppSpacing.verticalSpacerMd,
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    'Start chatting with your friends!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            );
          }

          return currentUserAsync.when(
            data: (currentUser) {
              if (currentUser == null) return const SizedBox();

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ConversationListItem(
                    conversation: conversation,
                    onTap: () {
                      ref.read(selectedConversationProvider.notifier).state = (
                        user1: widget.currentUserId,
                        user2: conversation.otherUserId,
                      );
                      // Mark conversation as read when opened
                      ref.read(markConversationAsReadActionProvider.notifier).state = (
                        user1: widget.currentUserId,
                        user2: conversation.otherUserId,
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => _buildErrorWidget(() => ref.refresh(userProfileProvider(widget.currentUserId))),
          );
        },
      ),
    );
  }

  Widget _buildConversationView(({String user1, String user2}) conversation) {
    final messagesAsync = ref.watch(conversationMessagesStreamProvider(conversation));
    final otherUserAsync = ref.watch(userProfileProvider(conversation.user2));
    final currentUserAsync = ref.watch(userProfileProvider(conversation.user1));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(selectedConversationProvider.notifier).state = null;
          },
        ),
        title: otherUserAsync.when(
          data: (profile) {
            if (profile == null) return const Text('Chat');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name),
                Text(
                  profile.isOnline ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: profile.isOnline ? Colors.green : AppColors.textMuted,
                      ),
                ),
              ],
            );
          },
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Chat'),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorWidget(() => ref.refresh(conversationMessagesStreamProvider(conversation))),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _messagesScrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSent = message.senderId == widget.currentUserId;

                    return MessageBubble(
                      message: message,
                      isSent: isSent,
                      onLongPress: isSent
                          ? () => _showMessageOptions(context, message, conversation)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInputBar(currentUserAsync, conversation),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar(
    AsyncValue<UserProfile?> currentUserAsync,
    ({String user1, String user2}) conversation,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _sendMessage(currentUserAsync, conversation);
                }
              },
            ),
          ),
          AppSpacing.horizontalSpacerMd,
          FloatingActionButton(
            mini: true,
            onPressed: () => _sendMessage(currentUserAsync, conversation),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage(
    AsyncValue<UserProfile?> currentUserAsync,
    ({String user1, String user2}) conversation,
  ) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUser = currentUserAsync.whenData((user) => user).value;
    if (currentUser == null) return;

    ref.read(sendMessageActionProvider.notifier).state = SendMessageParams(
      senderId: widget.currentUserId,
      senderName: currentUser.name,
      senderAvatar: currentUser.avatar,
      receiverId: conversation.user2,
      content: content,
    );

    final result = await ref.read(sendMessageProvider.future);
    if (result && mounted) {
      _messageController.clear();
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messagesScrollController.animateTo(
          _messagesScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showMessageOptions(
    BuildContext context,
    Message message,
    ({String user1, String user2}) conversation,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                ref.read(deleteMessageActionProvider.notifier).state = message.id;
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error loading messages',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppSpacing.verticalSpacerMd,
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
