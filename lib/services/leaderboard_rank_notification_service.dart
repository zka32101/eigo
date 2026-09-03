import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';

/// Service for managing leaderboard rank change notifications
class LeaderboardRankNotificationService {
  static final LeaderboardRankNotificationService _instance =
      LeaderboardRankNotificationService._internal();

  factory LeaderboardRankNotificationService() {
    return _instance;
  }

  LeaderboardRankNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a rank change notification
  ///
  /// Notifies user when their rank changes significantly
  Future<void> notifyRankChange({
    required String userId,
    required int previousRank,
    required int newRank,
    required String groupType,
    required String? groupName,
  }) async {
    try {
      final rankImprovement = previousRank - newRank;
      final shouldNotify = rankImprovement > 0; // Only notify on improvements

      if (!shouldNotify) return;

      final notificationId = 'rank_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('notifications').doc(notificationId).set({
        'userId': userId,
        'type': 'rankImprovement',
        'previousRank': previousRank,
        'newRank': newRank,
        'rankImprovement': rankImprovement,
        'groupType': groupType,
        'groupName': groupName,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
      });
    } catch (e) {
      print('Error creating rank change notification: $e');
    }
  }

  /// Create a milestone rank notification (top 10, top 50, etc.)
  Future<void> notifyRankMilestone({
    required String userId,
    required int currentRank,
    required String milestone, // 'top_10', 'top_50', 'top_100'
    required String groupType,
    required String? groupName,
  }) async {
    try {
      final notificationId =
          'milestone_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('notifications').doc(notificationId).set({
        'userId': userId,
        'type': 'rankMilestone',
        'milestone': milestone,
        'currentRank': currentRank,
        'groupType': groupType,
        'groupName': groupName,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
      });
    } catch (e) {
      print('Error creating milestone notification: $e');
    }
  }

  /// Notify user of reaching a new top position
  Future<void> notifyTopPosition({
    required String userId,
    required String groupType,
    required String? groupName,
  }) async {
    try {
      final notificationId =
          'top1_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('notifications').doc(notificationId).set({
        'userId': userId,
        'type': 'topPosition',
        'groupType': groupType,
        'groupName': groupName,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
      });
    } catch (e) {
      print('Error creating top position notification: $e');
    }
  }

  /// Send push notification for rank change
  ///
  /// Integrates with Firebase Cloud Messaging (FCM)
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      // Get user's FCM tokens
      final userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return;

      final fcmTokens =
          List<String>.from(userDoc.data()?['fcmTokens'] ?? []);

      if (fcmTokens.isEmpty) return;

      // TODO: Integrate with Firebase Cloud Messaging
      // This would typically call a Cloud Function to send FCM messages
      print(
          'Would send push notification to user $userId: $title - $body');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  /// Get user's unread rank notifications
  Future<List<Map<String, dynamic>>> getUnreadNotifications(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Delete old notifications (cleanup)
  Future<void> deleteExpiredNotifications() async {
    try {
      final batch = _firestore.batch();
      const maxBatchSize = 500;
      int batchSize = 0;

      final snapshot = await _firestore
          .collection('notifications')
          .where('expiresAt', isLessThan: Timestamp.now())
          .limit(500)
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        batchSize++;

        if (batchSize >= maxBatchSize) {
          await batch.commit();
          batchSize = 0;
        }
      }

      if (batchSize > 0) {
        await batch.commit();
      }
    } catch (e) {
      print('Error deleting expired notifications: $e');
    }
  }

  /// Get notification statistics for a user
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    try {
      final unreadSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      final allSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return {
        'unreadCount': unreadSnapshot.count,
        'totalCount': allSnapshot.count,
      };
    } catch (e) {
      print('Error getting notification stats: $e');
      return {'unreadCount': 0, 'totalCount': 0};
    }
  }

  /// Notify about upcoming grade promotion (1 week before)
  Future<void> notifyUpcomingPromotion({
    required String userId,
    required DateTime promotionDate,
    required int currentGrade,
    required int newGrade,
  }) async {
    try {
      final notificationId =
          'promo_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('notifications').doc(notificationId).set({
        'userId': userId,
        'type': 'upcomingPromotion',
        'currentGrade': currentGrade,
        'newGrade': newGrade,
        'promotionDate': Timestamp.fromDate(promotionDate),
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'expiresAt': Timestamp.fromDate(promotionDate),
      });
    } catch (e) {
      print('Error creating promotion notification: $e');
    }
  }

  /// Notify user that grade promotion has occurred
  Future<void> notifyGradePromotion({
    required String userId,
    required int previousGrade,
    required int newGrade,
  }) async {
    try {
      final notificationId =
          'promoted_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('notifications').doc(notificationId).set({
        'userId': userId,
        'type': 'gradePromotion',
        'previousGrade': previousGrade,
        'newGrade': newGrade,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
      });
    } catch (e) {
      print('Error creating grade promotion notification: $e');
    }
  }
}
