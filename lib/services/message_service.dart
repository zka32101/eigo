import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import 'logger_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();

  factory MessageService() {
    return _instance;
  }

  MessageService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _logger = LoggerService();

  // Send a message
  Future<Message> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String senderAvatar,
    String content, {
    MessageType type = MessageType.text,
    String? imageUrl,
    String? replyToMessageId,
  }) async {
    try {
      final message = Message(
        id: _firestore.collection('temp').doc().id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        type: type,
        content: content,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
        readBy: [senderId],
        imageUrl: imageUrl,
        replyToMessageId: replyToMessageId,
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());

      // Update conversation's last message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessageAt': DateTime.now(),
        'lastMessageContent': content,
        'lastMessageSenderId': senderId,
      });

      return message.copyWith(status: MessageStatus.sent);
    } catch (e) {
      _logger.error('Error sending message', e);
      rethrow;
    }
  }

  // Get conversation messages
  Future<List<Message>> getConversationMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      _logger.error('Error fetching messages', e);
      return [];
    }
  }

  // Get conversation by ID
  Future<Conversation> getConversation(String conversationId) async {
    try {
      final snapshot =
          await _firestore.collection('conversations').doc(conversationId).get();

      if (!snapshot.exists) {
        throw Exception('会話が見つかりません');
      }

      return Conversation.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Error fetching conversation', e);
      rethrow;
    }
  }

  // Get or create direct message conversation
  Future<Conversation> getOrCreateDirectMessage(
    String userId1,
    String user1Name,
    String user1Avatar,
    String userId2,
    String user2Name,
    String user2Avatar,
  ) async {
    try {
      // Check if conversation already exists
      final existingQuery = await _firestore
          .collection('conversations')
          .where('type', isEqualTo: 'direct')
          .where('participantIds', arrayContains: userId1)
          .get();

      for (final doc in existingQuery.docs) {
        final conv = Conversation.fromJson(doc.data());
        if (conv.participantIds.contains(userId2)) {
          return conv;
        }
      }

      // Create new conversation
      final convId = _firestore.collection('conversations').doc().id;
      final now = DateTime.now();

      final conversation = Conversation(
        id: convId,
        type: ConversationType.direct,
        participantIds: [userId1, userId2],
        participantNames: {userId1: user1Name, userId2: user2Name},
        participantAvatars: {userId1: user1Avatar, userId2: user2Avatar},
        createdAt: now,
        lastMessageAt: now,
      );

      await _firestore
          .collection('conversations')
          .doc(convId)
          .set(conversation.toJson());

      return conversation;
    } catch (e) {
      _logger.error('Error creating direct message', e);
      rethrow;
    }
  }

  // Get user conversations
  Future<List<Conversation>> getUserConversations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .where('isArchived', isEqualTo: false)
          .orderBy('lastMessageAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Conversation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error fetching conversations', e);
      return [];
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: 'read')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'status': 'read',
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }

      // Update conversation unread count
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'unreadCount': 0});
    } catch (e) {
      _logger.error('Error marking messages as read', e);
    }
  }

  // Search messages
  Future<List<Message>> searchMessages(
    String conversationId,
    String query,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: '${query}z')
          .get();

      return snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error searching messages', e);
      return [];
    }
  }

  // Delete message
  Future<void> deleteMessage(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isDeleted': true, 'content': '[削除されたメッセージ]'});
    } catch (e) {
      _logger.error('Error deleting message', e);
      rethrow;
    }
  }

  // Edit message
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newContent,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'editedAt': DateTime.now(),
      });
    } catch (e) {
      _logger.error('Error editing message', e);
      rethrow;
    }
  }

  // Mute/unmute conversation
  Future<void> toggleConversationMute(
    String conversationId,
    bool isMuted,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'isMuted': isMuted});
    } catch (e) {
      _logger.error('Error toggling mute', e);
      rethrow;
    }
  }

  // Archive/unarchive conversation
  Future<void> toggleConversationArchive(
    String conversationId,
    bool isArchived,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'isArchived': isArchived});
    } catch (e) {
      _logger.error('Error toggling archive', e);
      rethrow;
    }
  }

  // Get messaging statistics
  Future<MessagingStats> getUserMessagingStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('messaging_stats')
          .doc('stats')
          .get();

      if (!snapshot.exists) {
        return _createDefaultStats(userId);
      }

      return MessagingStats.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      _logger.error('Error fetching messaging stats', e);
      return _createDefaultStats(userId);
    }
  }

  // Get message threads
  Future<List<Message>> getMessageThreadReplies(
    String conversationId,
    String parentMessageId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('replyToMessageId', isEqualTo: parentMessageId)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error('Error fetching message thread', e);
      return [];
    }
  }

  // Helper method
  MessagingStats _createDefaultStats(String userId) {
    return MessagingStats(
      userId: userId,
      totalConversations: 0,
      totalMessages: 0,
      unreadMessages: 0,
      recentChatUserIds: [],
      lastActiveAt: DateTime.now(),
    );
  }
}
