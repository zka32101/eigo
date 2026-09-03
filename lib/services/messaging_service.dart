import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import 'logger_service.dart';

/// Service for managing direct messages between users
/// Phase 14 Part 3: Messaging System
class MessagingService {
  static final MessagingService _instance = MessagingService._internal();

  factory MessagingService() {
    return _instance;
  }

  MessagingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  /// Send a message from sender to receiver
  Future<bool> sendMessage(
    String senderId,
    String senderName,
    String senderAvatar,
    String receiverId,
    String content,
  ) async {
    try {
      final messageId = _firestore.collection('messages').doc().id;
      final now = DateTime.now();

      // Add message to messages collection
      await _firestore
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'receiverId': receiverId,
        'content': content,
        'sentAt': now.toIso8601String(),
        'isRead': false,
        'readAt': null,
        'conversationId': _getConversationId(senderId, receiverId),
      });

      return true;
    } catch (e) {
      _logger.error('Failed to send message', e);
      return false;
    }
  }

  /// Get messages for a conversation (between two users)
  Future<List<Message>> getConversationMessages(
    String userId1,
    String userId2, {
    int limit = 50,
  }) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);

      final snapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .get();

      final messages = snapshot.docs
          .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Reverse to get chronological order (oldest first)
      return messages.reversed.toList();
    } catch (e) {
      _logger.error('Failed to fetch conversation messages', e);
      return [];
    }
  }

  /// Mark a message as read
  Future<bool> markMessageAsRead(String messageId, String userId) async {
    try {
      await _firestore
          .collection('messages')
          .doc(messageId)
          .update({
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.error('Failed to mark message as read', e);
      return false;
    }
  }

  /// Mark all messages in a conversation as read
  Future<bool> markConversationAsRead(String userId1, String userId2) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);
      final now = DateTime.now().toIso8601String();

      final unreadMessages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: userId1)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': now,
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      _logger.error('Failed to mark conversation as read', e);
      return false;
    }
  }

  /// Delete a message (soft delete - just mark as deleted)
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection('messages')
          .doc(messageId)
          .delete();

      return true;
    } catch (e) {
      _logger.error('Failed to delete message', e);
      return false;
    }
  }

  /// Get conversation list for a user (sorted by last message time)
  Future<List<Conversation>> getConversationList(String userId) async {
    try {
      // Get distinct users this user has messaged with
      final sentMessages = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(100)
          .get();

      final receivedMessages = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(100)
          .get();

      // Get all unique conversation partners
      final conversationPartners = <String, Conversation>{};

      // Process sent messages
      for (final doc in sentMessages.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final otherUserId = data['receiverId'] as String;

        if (!conversationPartners.containsKey(otherUserId)) {
          conversationPartners[otherUserId] = Conversation(
            otherUserId: otherUserId,
            otherUserName: data['senderName'] as String? ?? 'Unknown', // Note: This should ideally be fetched separately
            otherUserAvatar: data['senderAvatar'] as String? ?? '?',
            lastMessage: data['content'] as String? ?? '',
            lastMessageTime: DateTime.parse(data['sentAt'] as String),
          );
        }
      }

      // Process received messages
      for (final doc in receivedMessages.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final otherUserId = data['senderId'] as String;
        final isRead = data['isRead'] as bool? ?? false;

        if (conversationPartners.containsKey(otherUserId)) {
          // Update if this message is newer
          final existingTime = conversationPartners[otherUserId]!.lastMessageTime;
          final newTime = DateTime.parse(data['sentAt'] as String);

          if (newTime.isAfter(existingTime)) {
            conversationPartners[otherUserId] = Conversation(
              otherUserId: otherUserId,
              otherUserName: data['senderName'] as String? ?? 'Unknown',
              otherUserAvatar: data['senderAvatar'] as String? ?? '?',
              lastMessage: data['content'] as String? ?? '',
              lastMessageTime: newTime,
              isRead: isRead,
              unreadCount: !isRead ? 1 : 0,
            );
          }
        } else {
          conversationPartners[otherUserId] = Conversation(
            otherUserId: otherUserId,
            otherUserName: data['senderName'] as String? ?? 'Unknown',
            otherUserAvatar: data['senderAvatar'] as String? ?? '?',
            lastMessage: data['content'] as String? ?? '',
            lastMessageTime: DateTime.parse(data['sentAt'] as String),
            isRead: isRead,
            unreadCount: !isRead ? 1 : 0,
          );
        }
      }

      // Sort by last message time
      final conversations = conversationPartners.values.toList();
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return conversations;
    } catch (e) {
      _logger.error('Failed to fetch conversation list', e);
      return [];
    }
  }

  /// Get unread message count for a user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      _logger.error('Failed to fetch unread message count', e);
      return 0;
    }
  }

  /// Get unread count for a specific conversation
  Future<int> getUnreadConversationCount(String userId1, String userId2) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);

      final snapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: userId1)
          .where('isRead', isEqualTo: false)
          .count
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      _logger.error('Failed to fetch unread conversation count', e);
      return 0;
    }
  }

  /// Search messages in a conversation
  Future<List<Message>> searchMessages(
    String userId1,
    String userId2,
    String query,
  ) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);

      // Firestore doesn't have native text search, so we fetch all and filter
      final snapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('sentAt', descending: true)
          .get();

      final messages = snapshot.docs
          .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return messages
          .where((msg) => msg.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      _logger.error('Failed to search messages', e);
      return [];
    }
  }

  /// Helper to get consistent conversation ID for two users
  String _getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Stream messages for real-time updates
  Stream<List<Message>> streamConversationMessages(
    String userId1,
    String userId2,
  ) {
    try {
      final conversationId = _getConversationId(userId1, userId2);

      return _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('sentAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      _logger.error('Failed to stream conversation messages', e);
      return Stream.value([]);
    }
  }
}
