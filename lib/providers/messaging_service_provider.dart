import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';

/// Singleton provider for MessagingService
final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService();
});

/// Parameter classes for actions
class SendMessageParams {
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String receiverId;
  final String content;

  SendMessageParams({
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.receiverId,
    required this.content,
  });
}

/// ==================== MESSAGE QUERY PROVIDERS ====================

/// Get messages for a specific conversation
final conversationMessagesProvider = FutureProvider.family<List<Message>, ({String user1, String user2})>((ref, params) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getConversationMessages(params.user1, params.user2, limit: 100);
});

/// Stream messages for real-time conversation updates
final conversationMessagesStreamProvider = StreamProvider.family<List<Message>, ({String user1, String user2})>((ref, params) {
  final service = ref.watch(messagingServiceProvider);
  return service.streamConversationMessages(params.user1, params.user2);
});

/// Get conversation list for a user
final conversationListProvider = FutureProvider.family<List<Conversation>, String>((ref, userId) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getConversationList(userId);
});

/// Get unread message count for a user
final unreadMessageCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getUnreadMessageCount(userId);
});

/// Get unread count for a specific conversation
final unreadConversationCountProvider = FutureProvider.family<int, ({String user1, String user2})>((ref, params) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getUnreadConversationCount(params.user1, params.user2);
});

/// Search messages in a conversation
final messageSearchProvider = FutureProvider.family<List<Message>, ({String user1, String user2, String query})>((ref, params) async {
  final service = ref.watch(messagingServiceProvider);
  return service.searchMessages(params.user1, params.user2, params.query);
});

/// ==================== ACTION PROVIDERS ====================

/// Send message action
final sendMessageActionProvider = StateProvider<SendMessageParams?>((ref) => null);

final sendMessageProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(sendMessageActionProvider);
  if (params == null) return false;

  final service = ref.watch(messagingServiceProvider);
  final result = await service.sendMessage(
    params.senderId,
    params.senderName,
    params.senderAvatar,
    params.receiverId,
    params.content,
  );

  // Invalidate related providers
  if (result) {
    ref.invalidate(conversationMessagesProvider(
      (user1: params.senderId, user2: params.receiverId),
    ));
    ref.invalidate(conversationListProvider(params.senderId));
    ref.invalidate(conversationListProvider(params.receiverId));
    ref.invalidate(unreadMessageCountProvider(params.receiverId));
  }

  return result;
});

/// Mark message as read action
final markMessageAsReadActionProvider = StateProvider<({String messageId, String userId})?>((ref) => null);

final markMessageAsReadProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(markMessageAsReadActionProvider);
  if (params == null) return false;

  final service = ref.watch(messagingServiceProvider);
  return service.markMessageAsRead(params.messageId, params.userId);
});

/// Mark conversation as read action
final markConversationAsReadActionProvider = StateProvider<({String user1, String user2})?>((ref) => null);

final markConversationAsReadProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(markConversationAsReadActionProvider);
  if (params == null) return false;

  final service = ref.watch(messagingServiceProvider);
  final result = await service.markConversationAsRead(params.user1, params.user2);

  // Invalidate related providers
  if (result) {
    ref.invalidate(conversationListProvider(params.user1));
    ref.invalidate(unreadConversationCountProvider(
      (user1: params.user1, user2: params.user2),
    ));
  }

  return result;
});

/// Delete message action
final deleteMessageActionProvider = StateProvider<String?>((ref) => null);

final deleteMessageProvider = FutureProvider<bool>((ref) async {
  final messageId = ref.watch(deleteMessageActionProvider);
  if (messageId == null) return false;

  final service = ref.watch(messagingServiceProvider);
  return service.deleteMessage(messageId);
});

/// ==================== UI STATE PROVIDERS ====================

/// Selected conversation (pair of user IDs)
final selectedConversationProvider = StateProvider<({String user1, String user2})?>>((ref) => null);

/// Message search query
final messageSearchQueryProvider = StateProvider<String>((ref) => '');

/// Current chat view (conversation vs list view)
final chatViewModeProvider = StateProvider<ChatViewMode>((ref) => ChatViewMode.conversationList);

enum ChatViewMode {
  conversationList,
  conversation,
}
