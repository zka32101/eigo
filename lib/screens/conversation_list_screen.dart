import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../providers/message_provider.dart';
import '../providers/user_profile_provider.dart';
import '../design_system/design_system.dart';
import 'chat_screen.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider) ?? '';
    final conversationsAsync = ref.watch(userConversationsProvider(userId));
    final searchQuery = ref.watch(conversationSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('メッセージ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'チャットを検索...',
              onChanged: (value) {
                ref.read(conversationSearchQueryProvider.notifier).state = value;
              },
              leading: const Icon(Icons.search),
              trailing: _searchController.text.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(conversationSearchQueryProvider.notifier).state = '';
                        },
                      ),
                    ]
                  : [],
            ),
          ),
          Expanded(
            child: conversationsAsync.when(
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
                      'チャットの読み込みに失敗しました',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(userConversationsProvider(userId)),
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
              data: (conversations) {
                final filtered = conversations
                    .where((conv) =>
                        conv.displayName.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty ? 'チャットはまだありません' : 'チャットが見つかりません',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(userConversationsProvider(userId).future),
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversation = filtered[index];
                      return _ConversationTile(
                        conversation: conversation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                conversationId: conversation.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open new conversation dialog
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    Key? key,
    required this.conversation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showConversationMenu(context, ref),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Text(
                    conversation.displayIcon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                if (conversation.type == ConversationType.direct)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.displayName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageAt ?? DateTime.now()),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (conversation.isMuted)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.notifications_off, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                conversation.isMuted ? Icons.notifications : Icons.notifications_off,
              ),
              title: Text(conversation.isMuted ? 'ミュート解除' : 'ミュート'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Toggle mute
              },
            ),
            ListTile(
              leading: Icon(
                conversation.isArchived ? Icons.unarchive : Icons.archive,
              ),
              title: Text(conversation.isArchived ? 'アーカイブを解除' : 'アーカイブ'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Toggle archive
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('削除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete conversation
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
