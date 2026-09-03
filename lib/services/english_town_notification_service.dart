import 'package:flutter/material.dart';

/// Notification types for the app
enum NotificationType {
  rankChanged,
  achievementUnlocked,
  streakMilestone,
  dailyChallenge,
  friendActivity,
  leaderboardTop,
}

/// Notification payload structure
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
    };
  }

  /// Create from Firestore document
  factory AppNotification.fromFirestore(Map<String, dynamic> doc) {
    return AppNotification(
      id: doc['id'] as String,
      type: _parseNotificationType(doc['type'] as String),
      title: doc['title'] as String,
      body: doc['body'] as String,
      imageUrl: doc['imageUrl'] as String?,
      data: Map<String, dynamic>.from(doc['data'] as Map? ?? {}),
      createdAt: DateTime.parse(doc['createdAt'] as String),
      isRead: doc['isRead'] as bool? ?? false,
      actionUrl: doc['actionUrl'] as String?,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => NotificationType.dailyChallenge,
    );
  }

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}

/// Service for managing notifications
class EnglishTownNotificationService {
  static final EnglishTownNotificationService _instance =
      EnglishTownNotificationService._internal();

  factory EnglishTownNotificationService() {
    return _instance;
  }

  EnglishTownNotificationService._internal();

  // Notification store (in-memory for now, can be persisted to local storage)
  final List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  /// Get all notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get unread count
  int get unreadCount => _unreadCount;

  /// Get emoji for notification type
  String getNotificationEmoji(NotificationType type) {
    switch (type) {
      case NotificationType.rankChanged:
        return '📈';
      case NotificationType.achievementUnlocked:
        return '🏆';
      case NotificationType.streakMilestone:
        return '🔥';
      case NotificationType.dailyChallenge:
        return '⭐';
      case NotificationType.friendActivity:
        return '👥';
      case NotificationType.leaderboardTop:
        return '👑';
    }
  }

  /// Get color for notification type
  Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.rankChanged:
        return Colors.blue;
      case NotificationType.achievementUnlocked:
        return Colors.purple;
      case NotificationType.streakMilestone:
        return Colors.orange;
      case NotificationType.dailyChallenge:
        return Colors.green;
      case NotificationType.friendActivity:
        return Colors.pink;
      case NotificationType.leaderboardTop:
        return Colors.amber;
    }
  }

  /// Create rank change notification
  AppNotification createRankChangeNotification({
    required int previousRank,
    required int currentRank,
    required String playerName,
  }) {
    final improved = currentRank < previousRank;
    final rankDiff = (previousRank - currentRank).abs();

    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.rankChanged,
      title: improved
          ? 'You climbed $rankDiff positions! 🚀'
          : 'You dropped $rankDiff positions',
      body: 'Your rank: #$currentRank',
      data: {
        'previousRank': previousRank,
        'currentRank': currentRank,
        'improved': improved,
      },
      createdAt: DateTime.now(),
      actionUrl: '/leaderboard',
    );
  }

  /// Create achievement notification
  AppNotification createAchievementNotification({
    required String achievementTitle,
    required int rewardXp,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.achievementUnlocked,
      title: 'Achievement Unlocked!',
      body: '$achievementTitle (+$rewardXp XP)',
      data: {
        'achievementTitle': achievementTitle,
        'rewardXp': rewardXp,
      },
      createdAt: DateTime.now(),
      actionUrl: '/achievements',
    );
  }

  /// Create streak milestone notification
  AppNotification createStreakNotification({
    required int streakDays,
    required int milestone,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.streakMilestone,
      title: 'Streak Milestone! 🔥',
      body: 'You\'ve maintained a $streakDays day streak!',
      data: {
        'streakDays': streakDays,
        'milestone': milestone,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Create daily challenge notification
  AppNotification createDailyChallengeNotification({
    required String challengeTitle,
    required int xpReward,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.dailyChallenge,
      title: 'New Daily Challenge!',
      body: '$challengeTitle (⭐ $xpReward XP)',
      data: {
        'challengeTitle': challengeTitle,
        'xpReward': xpReward,
      },
      createdAt: DateTime.now(),
      actionUrl: '/hub',
    );
  }

  /// Create top 10 notification
  AppNotification createTopLeaderboardNotification({
    required int rank,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.leaderboardTop,
      title: 'You\'re in the Top 10! 👑',
      body: 'You\'re now ranked #$rank globally',
      data: {
        'rank': rank,
      },
      createdAt: DateTime.now(),
      actionUrl: '/leaderboard',
    );
  }

  /// Add notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount++;

    // Keep only last 50 notifications in memory
    if (_notifications.length > 50) {
      _notifications.removeAt(_notifications.length - 1);
    }
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index =
        _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      if (!notification.isRead) {
        _notifications[index] = notification.copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
      }
    }
  }

  /// Mark all as read
  void markAllAsRead() {
    _notifications.removeWhere((n) => !n.isRead);
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }
}
