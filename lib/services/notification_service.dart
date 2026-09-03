import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import 'logger_service.dart';

/// Service for managing user notifications
/// Phase 14 Part 4: Notifications System
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  /// Send a notification to a user
  Future<bool> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? relatedUserId,
    String? relatedUserName,
    String? relatedUserAvatar,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final now = DateTime.now();

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set({
        'id': notificationId,
        'userId': userId,
        'type': type.toString().split('.').last,
        'title': title,
        'message': message,
        'relatedUserId': relatedUserId,
        'relatedUserName': relatedUserName,
        'relatedUserAvatar': relatedUserAvatar,
        'createdAt': now.toIso8601String(),
        'isRead': false,
        'readAt': null,
        'metadata': metadata,
      });

      return true;
    } catch (e) {
      _logger.error('Failed to send notification', e);
      return false;
    }
  }

  /// Get notifications for a user
  Future<List<Notification>> getUserNotifications(
    String userId, {
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Notification.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch notifications', e);
      return [];
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.error('Failed to mark notification as read', e);
      return false;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': now,
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      _logger.error('Failed to mark all notifications as read', e);
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();

      return true;
    } catch (e) {
      _logger.error('Failed to delete notification', e);
      return false;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      _logger.error('Failed to fetch unread count', e);
      return 0;
    }
  }

  /// Stream notifications for real-time updates
  Stream<List<Notification>> streamUserNotifications(String userId) {
    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Notification.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      _logger.error('Failed to stream notifications', e);
      return Stream.value([]);
    }
  }

  /// Delete all read notifications for a user
  Future<bool> deleteReadNotifications(String userId) async {
    try {
      final readNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: true)
          .get();

      final batch = _firestore.batch();

      for (final doc in readNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      _logger.error('Failed to delete read notifications', e);
      return false;
    }
  }
}
