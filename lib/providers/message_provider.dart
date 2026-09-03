import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

// Service provider
final messageServiceProvider = Provider((ref) {
  return MessageService();
});

// User conversations provider
final userConversationsProvider =
    FutureProvider.family<List<Conversation>, String>((ref, userId) async {
  final service = ref.watch(messageServiceProvider);
  return service.getUserConversations(userId);
});

// Conversation messages provider
final conversationMessagesProvider = FutureProvider.family<List<Message>, String>(
  (ref, conversationId) async {
    final service = ref.watch(messageServiceProvider);
    return service.getConversationMessages(conversationId);
  },
);

// Single conversation provider
final conversationProvider =
    FutureProvider.family<Conversation, String>((ref, conversationId) async {
  final service = ref.watch(messageServiceProvider);
  return service.getConversation(conversationId);
});

// Message search provider
final messageSearchProvider = FutureProvider.family<List<Message>, ({String conversationId, String query})>(
  (ref, params) async {
    if (params.query.isEmpty) return [];
    final service = ref.watch(messageServiceProvider);
    return service.searchMessages(params.conversationId, params.query);
  },
);

// Message thread provider
final messageThreadProvider =
    FutureProvider.family<List<Message>, ({String conversationId, String parentMessageId})>(
  (ref, params) async {
    final service = ref.watch(messageServiceProvider);
    return service.getMessageThreadReplies(params.conversationId, params.parentMessageId);
  },
);

// Messaging statistics provider
final messagingStatsProvider =
    FutureProvider.family<MessagingStats, String>((ref, userId) async {
  final service = ref.watch(messageServiceProvider);
  return service.getUserMessagingStats(userId);
});

// Send message action
class SendMessageParams {
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final MessageType messageType;
  final String? imageUrl;
  final String? replyToMessageId;

  SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    this.messageType = MessageType.text,
    this.imageUrl,
    this.replyToMessageId,
  });
}

final sendMessageActionProvider =
    FutureProvider.family<Message, SendMessageParams>(
  (ref, params) async {
    final service = ref.watch(messageServiceProvider);
    final message = await service.sendMessage(
      params.conversationId,
      params.senderId,
      params.senderName,
      params.senderAvatar,
      params.content,
      type: params.messageType,
      imageUrl: params.imageUrl,
      replyToMessageId: params.replyToMessageId,
    );

    ref.refresh(conversationMessagesProvider(params.conversationId));
    ref.refresh(userConversationsProvider(params.senderId));

    return message;
  },
);

// Get or create direct message
class DirectMessageParams {
  final String userId1;
  final String user1Name;
  final String user1Avatar;
  final String userId2;
  final String user2Name;
  final String user2Avatar;

  DirectMessageParams({
    required this.userId1,
    required this.user1Name,
    required this.user1Avatar,
    required this.userId2,
    required this.user2Name,
    required this.user2Avatar,
  });
}

final getOrCreateDirectMessageActionProvider =
    FutureProvider.family<Conversation, DirectMessageParams>(
  (ref, params) async {
    final service = ref.watch(messageServiceProvider);
    final conversation = await service.getOrCreateDirectMessage(
      params.userId1,
      params.user1Name,
      params.user1Avatar,
      params.userId2,
      params.user2Name,
      params.user2Avatar,
    );

    ref.refresh(userConversationsProvider(params.userId1));
    return conversation;
  },
);

// Mark as read action
class MarkAsReadParams {
  final String conversationId;
  final String userId;

  MarkAsReadParams({
    required this.conversationId,
    required this.userId,
  });
}

final markAsReadActionProvider =
    FutureProvider.family<void, MarkAsReadParams>(
  (ref, params) async {
    final service = ref.watch(messageServiceProvider);
    await service.markMessagesAsRead(params.conversationId, params.userId);
    ref.refresh(conversationMessagesProvider(params.conversationId));
    ref.refresh(userConversationsProvider(params.userId));
  },
);

// Delete message action
class DeleteMessageParams {
  final String conversationId;
  final String messageId;

  DeleteMessageParams({
    required this.conversationId,
    required this.messageId,
  });
}

final deleteMessageActionProvider =
    FutureProvider.family<void, DeleteMessageParams>(
  (ref, params) async {
    final service = ref.watch(messageServiceProvider);
    await service.deleteMessage(params.conversationId, params.messageId);
    ref.refresh(conversationMessagesProvider(params.conversationId));
  },
);

// Edit message action
class EditMessageParams {
  final String conversationId;
  final String messageId;
  final String newContent;

  EditMessageParams({
    required this.conversationId,
    required this.messageId,
    required this.newContent,
  });
}

final editMessageActionProvider =
    FutureProvider.family<void, EditMessageParams>(
  (ref, params) async {
    final service = ref.watch(messageServiceProvider);
    await service.editMessage(params.conversationId, params.messageId, params.newContent);
    ref.refresh(conversationMessagesProvider(params.conversationId));
  },
);

// Toggle mute
class ToggleMuteParams {
  final String conversationId;
  final bool isMuted;

  ToggleMuteParams({
    required this.conversationId,
    required this.isMuted,
  });
}

final toggleMuteActionProvider =
    FutureProvider.family<void, ToggleMuteParams>(
  (ref, params) async {
    final service = ref.watch(messageServiceProvider);
    await service.toggleConversationMute(params.conversationId, params.isMuted);
    ref.refresh(conversationProvider(params.conversationId));
  },
);

// Conversation search query state
final conversationSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Message search query state
final messageSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Selected conversation state
final selectedConversationProvider = StateProvider<String?>((ref) {
  return null;
});

// Chat input text state
final chatInputProvider = StateProvider<String>((ref) {
  return '';
});
