import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'logger_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  // Send a notification
  Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? icon,
    String? imageUrl,
    String? actionRoute,
    Map<String, dynamic>? actionData,
    DateTime? expiresAt,
    required NotificationPriority priority,
  }) async {
    try {
      final notificationId =
          _firestore.collection('notifications').doc().id;
      final notification = Notification(
        id: notificationId,
        userId: userId,
        type: type,
        title: title,
        message: message,
        icon: icon,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        isRead: false,
        actionRoute: actionRoute,
        actionData: actionData,
        expiresAt: expiresAt,
        priority: priority,
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());

      _logger.info(
        'Notification sent to $userId',
        'NotificationService',
      );
    } catch (e) {
      _logger.error(
        'Failed to send notification: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Get user notifications
  Future<List<Notification>> getUserNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .offset(offset)
          .get();

      return snapshot.docs
          .map((doc) => Notification.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error(
        'Failed to get user notifications: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Get unread notifications
  Future<List<Notification>> getUnreadNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Notification.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.error(
        'Failed to get unread notifications: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count;
    } catch (e) {
      _logger.error(
        'Failed to get unread count: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      _logger.info(
        'Notification marked as read: $notificationId',
        'NotificationService',
      );
    } catch (e) {
      _logger.error(
        'Failed to mark notification as read: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      _logger.info(
        'All notifications marked as read for $userId',
        'NotificationService',
      );
    } catch (e) {
      _logger.error(
        'Failed to mark all notifications as read: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();

      _logger.info(
        'Notification deleted: $notificationId',
        'NotificationService',
      );
    } catch (e) {
      _logger.error(
        'Failed to delete notification: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Get notification preferences
  Future<NotificationPreference> getPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('notificationPreferences')
          .doc(userId)
          .get();

      if (doc.exists) {
        return NotificationPreference.fromJson(doc.data()!);
      } else {
        final defaultPrefs = NotificationPreference.defaultPreference(userId);
        await setPreferences(userId, defaultPrefs);
        return defaultPrefs;
      }
    } catch (e) {
      _logger.error(
        'Failed to get notification preferences: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Set notification preferences
  Future<void> setPreferences(
    String userId,
    NotificationPreference preferences,
  ) async {
    try {
      await _firestore
          .collection('notificationPreferences')
          .doc(userId)
          .set(preferences.toJson());

      _logger.info(
        'Notification preferences updated for $userId',
        'NotificationService',
      );
    } catch (e) {
      _logger.error(
        'Failed to set notification preferences: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Get notification statistics
  Future<NotificationStats> getStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final notifications = snapshot.docs
          .map((doc) => Notification.fromJson(doc.data()))
          .toList();

      final unreadCount =
          notifications.where((n) => !n.isRead).length;
      final readCount = notifications.where((n) => n.isRead).length;

      final notificationsByType = <String, int>{};
      for (final notif in notifications) {
        final typeKey = notif.type.toString().split('.').last;
        notificationsByType[typeKey] =
            (notificationsByType[typeKey] ?? 0) + 1;
      }

      final lastNotification = notifications.isNotEmpty
          ? notifications.reduce(
              (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
            )
          : null;

      return NotificationStats(
        userId: userId,
        totalNotifications: notifications.length,
        unreadNotifications: unreadCount,
        readNotifications: readCount,
        deletedNotifications: 0,
        notificationsByType: notificationsByType,
        lastNotificationAt: lastNotification?.createdAt,
      );
    } catch (e) {
      _logger.error(
        'Failed to get notification stats: $e',
        'NotificationService',
      );
      rethrow;
    }
  }

  // Clean up expired notifications
  Future<void> cleanupExpiredNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isLessThan: DateTime.now())
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _logger.info(
        'Expired notifications cleaned up for $userId',
        'NotificationService',
      );
    } catch (e) {
      _logger.error(
        'Failed to cleanup expired notifications: $e',
        'NotificationService',
      );
      rethrow;
    }
  }
}
