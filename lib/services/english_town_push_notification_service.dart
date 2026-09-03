import 'package:flutter/material.dart';

/// Push notification payload structure
class PushNotificationPayload {
  final String notificationId;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, String> data;
  final DateTime createdAt;
  final String? actionUrl;
  final int priority; // 0-10 for priority ordering

  PushNotificationPayload({
    required this.notificationId,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.createdAt,
    this.actionUrl,
    this.priority = 5,
  });

  /// Convert to Firebase Cloud Messaging format
  Map<String, dynamic> toFCMPayload() {
    return {
      'notification': {
        'title': title,
        'body': body,
        'image': imageUrl,
      },
      'data': {
        ...data,
        'notificationId': notificationId,
        'createdAt': createdAt.toIso8601String(),
        'actionUrl': actionUrl ?? '',
        'priority': priority.toString(),
      },
    };
  }

  /// Create from FCM payload
  factory PushNotificationPayload.fromFCM(Map<String, dynamic> payload) {
    final notification = payload['notification'] ?? {};
    final data = Map<String, String>.from(payload['data'] ?? {});

    return PushNotificationPayload(
      notificationId: data['notificationId'] ?? '',
      title: notification['title'] ?? '',
      body: notification['body'] ?? '',
      imageUrl: notification['image'] as String?,
      data: data,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      actionUrl: data['actionUrl'],
      priority: int.tryParse(data['priority'] ?? '5') ?? 5,
    );
  }
}

/// Represents a scheduled push notification
class ScheduledPushNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime scheduledFor;
  final bool repeating;
  final String? recurrencePattern; // cron-like pattern
  final bool sent;
  final DateTime createdAt;

  ScheduledPushNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.scheduledFor,
    this.repeating = false,
    this.recurrencePattern,
    this.sent = false,
    required this.createdAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'scheduledFor': scheduledFor.toIso8601String(),
      'repeating': repeating,
      'recurrencePattern': recurrencePattern,
      'sent': sent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory ScheduledPushNotification.fromFirestore(Map<String, dynamic> doc) {
    return ScheduledPushNotification(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      title: doc['title'] as String,
      body: doc['body'] as String,
      scheduledFor: DateTime.parse(doc['scheduledFor'] as String),
      repeating: doc['repeating'] as bool? ?? false,
      recurrencePattern: doc['recurrencePattern'] as String?,
      sent: doc['sent'] as bool? ?? false,
      createdAt: DateTime.parse(doc['createdAt'] as String),
    );
  }
}

/// Service for managing push notifications via Firebase Cloud Messaging
class EnglishTownPushNotificationService {
  static final EnglishTownPushNotificationService _instance =
      EnglishTownPushNotificationService._internal();

  factory EnglishTownPushNotificationService() {
    return _instance;
  }

  EnglishTownPushNotificationService._internal();

  // Track sent notifications to avoid duplicates
  final Set<String> _sentNotificationIds = {};

  // Store for pending notifications (to be sent)
  final List<PushNotificationPayload> _pendingNotifications = [];

  /// Get pending notifications count
  int get pendingNotificationsCount => _pendingNotifications.length;

  /// Get sent notification IDs
  Set<String> get sentNotificationIds => Set.unmodifiable(_sentNotificationIds);

  /// Check if notification was already sent
  bool isNotificationSent(String notificationId) {
    return _sentNotificationIds.contains(notificationId);
  }

  /// Register sent notification
  void markNotificationSent(String notificationId) {
    _sentNotificationIds.add(notificationId);
  }

  /// Queue a push notification for sending
  void queuePushNotification(PushNotificationPayload payload) {
    if (!_sentNotificationIds.contains(payload.notificationId)) {
      _pendingNotifications.add(payload);
    }
  }

  /// Get pending notifications
  List<PushNotificationPayload> getPendingNotifications() {
    return List.unmodifiable(_pendingNotifications);
  }

  /// Remove notification from pending queue
  void removePendingNotification(String notificationId) {
    _pendingNotifications
        .removeWhere((n) => n.notificationId == notificationId);
  }

  /// Clear all pending notifications
  void clearPendingNotifications() {
    _pendingNotifications.clear();
  }

  /// Create push payload from notification data
  PushNotificationPayload createPushPayload({
    required String notificationId,
    required String title,
    required String body,
    required Map<String, String> data,
    String? imageUrl,
    String? actionUrl,
    int priority = 5,
  }) {
    return PushNotificationPayload(
      notificationId: notificationId,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      createdAt: DateTime.now(),
      actionUrl: actionUrl,
      priority: priority,
    );
  }

  /// Create rank change push notification
  PushNotificationPayload createRankChangePushNotification({
    required int previousRank,
    required int currentRank,
    required String playerName,
  }) {
    final improved = currentRank < previousRank;
    final rankDiff = (previousRank - currentRank).abs();

    return createPushPayload(
      notificationId: 'rank_change_${DateTime.now().millisecondsSinceEpoch}',
      title: improved
          ? '🚀 You climbed $rankDiff positions!'
          : '📍 Your rank changed',
      body: 'New rank: #$currentRank',
      data: {
        'type': 'rankChanged',
        'previousRank': previousRank.toString(),
        'currentRank': currentRank.toString(),
        'improved': improved.toString(),
      },
      actionUrl: '/leaderboard',
      priority: 7,
    );
  }

  /// Create achievement push notification
  PushNotificationPayload createAchievementPushNotification({
    required String achievementTitle,
    required int rewardXp,
  }) {
    return createPushPayload(
      notificationId:
          'achievement_${DateTime.now().millisecondsSinceEpoch}',
      title: '🏆 Achievement Unlocked!',
      body: '$achievementTitle (+$rewardXp XP)',
      data: {
        'type': 'achievementUnlocked',
        'achievementTitle': achievementTitle,
        'rewardXp': rewardXp.toString(),
      },
      actionUrl: '/achievements',
      priority: 8,
    );
  }

  /// Create streak milestone push notification
  PushNotificationPayload createStreakMilestonePushNotification({
    required int streakDays,
  }) {
    return createPushPayload(
      notificationId: 'streak_${DateTime.now().millisecondsSinceEpoch}',
      title: '🔥 Streak Milestone!',
      body: 'You\'ve maintained a $streakDays day streak!',
      data: {
        'type': 'streakMilestone',
        'streakDays': streakDays.toString(),
      },
      priority: 6,
    );
  }

  /// Create top 10 push notification
  PushNotificationPayload createTop10PushNotification({
    required int rank,
  }) {
    return createPushPayload(
      notificationId: 'top10_${DateTime.now().millisecondsSinceEpoch}',
      title: '👑 You\'re in the Top 10!',
      body: 'You\'re now ranked #$rank globally',
      data: {
        'type': 'leaderboardTop',
        'rank': rank.toString(),
      },
      actionUrl: '/leaderboard',
      priority: 9,
    );
  }

  /// Create daily reminder push notification
  PushNotificationPayload createDailyReminderPushNotification({
    required String playerName,
    int? conversationsToday = 0,
  }) {
    return createPushPayload(
      notificationId: 'daily_reminder_${DateTime.now().day}',
      title: '💬 Time to practice!',
      body: conversationsToday == 0
          ? 'Start your first conversation today'
          : 'You\'ve had $conversationsToday conversations. Keep it up!',
      data: {
        'type': 'dailyReminder',
        'conversationsToday': (conversationsToday ?? 0).toString(),
      },
      actionUrl: '/hub',
      priority: 3,
    );
  }

  /// Handle incoming push notification from FCM
  Future<void> handleIncomingPushNotification(
      Map<String, dynamic> payload) async {
    final pushNotification = PushNotificationPayload.fromFCM(payload);

    // Mark as sent
    markNotificationSent(pushNotification.notificationId);

    // Log for analytics (TODO: send to Firebase Analytics)
    print(
        'Push notification received: ${pushNotification.title} at ${pushNotification.createdAt}');
  }

  /// Get notification delivery status
  Map<String, dynamic> getDeliveryStatus() {
    return {
      'totalSent': _sentNotificationIds.length,
      'pending': _pendingNotifications.length,
      'lastNotificationTime': _sentNotificationIds.isNotEmpty
          ? DateTime.now()
          : null,
    };
  }

  /// Clear old notification records (older than 30 days)
  void clearOldNotificationRecords() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    // In production, this would query Firestore and delete old records
    // For now, just clear the in-memory set
    _sentNotificationIds.clear();
  }
}
