import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

enum NotificationType {
  challengeStarting,
  challengeEnding,
  challengeCompleted,
  petEvolved,
  videoRecommended,
  friendChallengeInvite,
  friendChallengeCompleted,
  achievementUnlocked,
  dailyQuestReminder,
  streakMilestone,
  levelUp,
  shopItemNew,
  custom,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

@JsonSerializable()
class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? icon;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? actionData;
  final DateTime? expiresAt;
  final NotificationPriority priority;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.icon,
    this.imageUrl,
    required this.createdAt,
    required this.isRead,
    this.actionRoute,
    this.actionData,
    this.expiresAt,
    required this.priority,
  });

  String get typeLabel {
    switch (type) {
      case NotificationType.challengeStarting:
        return 'チャレンジ開始';
      case NotificationType.challengeEnding:
        return 'チャレンジ終了';
      case NotificationType.challengeCompleted:
        return 'チャレンジ完了';
      case NotificationType.petEvolved:
        return 'ペット進化';
      case NotificationType.videoRecommended:
        return 'ビデオ推奨';
      case NotificationType.friendChallengeInvite:
        return 'フレンドチャレンジ招待';
      case NotificationType.friendChallengeCompleted:
        return 'フレンドチャレンジ完了';
      case NotificationType.achievementUnlocked:
        return 'アチーブメント解除';
      case NotificationType.dailyQuestReminder:
        return 'デイリークエスト';
      case NotificationType.streakMilestone:
        return 'ストリークマイルストーン';
      case NotificationType.levelUp:
        return 'レベルアップ';
      case NotificationType.shopItemNew:
        return 'ショップ新商品';
      case NotificationType.custom:
        return 'カスタム';
    }
  }

  String get typeEmoji {
    switch (type) {
      case NotificationType.challengeStarting:
        return '🚀';
      case NotificationType.challengeEnding:
        return '⏰';
      case NotificationType.challengeCompleted:
        return '🎉';
      case NotificationType.petEvolved:
        return '✨';
      case NotificationType.videoRecommended:
        return '🎬';
      case NotificationType.friendChallengeInvite:
        return '👋';
      case NotificationType.friendChallengeCompleted:
        return '🏆';
      case NotificationType.achievementUnlocked:
        return '🏅';
      case NotificationType.dailyQuestReminder:
        return '📋';
      case NotificationType.streakMilestone:
        return '🔥';
      case NotificationType.levelUp:
        return '⭐';
      case NotificationType.shopItemNew:
        return '🛍️';
      case NotificationType.custom:
        return '📢';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case NotificationPriority.low:
        return '低';
      case NotificationPriority.normal:
        return '通常';
      case NotificationPriority.high:
        return '高';
      case NotificationPriority.urgent:
        return '緊急';
    }
  }

  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? icon,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
    String? actionRoute,
    Map<String, dynamic>? actionData,
    DateTime? expiresAt,
    NotificationPriority? priority,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionData: actionData ?? this.actionData,
      expiresAt: expiresAt ?? this.expiresAt,
      priority: priority ?? this.priority,
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}

@JsonSerializable()
class NotificationPreference {
  final String userId;
  final bool enableChallengeReminders;
  final bool enablePetNotifications;
  final bool enableVideoRecommendations;
  final bool enableFriendChallenges;
  final bool enableAchievements;
  final bool enableDailyQuests;
  final bool enableStreakMilestones;
  final bool enableShopUpdates;
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableSoundNotifications;
  final bool enableVibrationNotifications;
  final String? quietHoursStartTime;
  final String? quietHoursEndTime;
  final DateTime lastUpdatedAt;

  NotificationPreference({
    required this.userId,
    required this.enableChallengeReminders,
    required this.enablePetNotifications,
    required this.enableVideoRecommendations,
    required this.enableFriendChallenges,
    required this.enableAchievements,
    required this.enableDailyQuests,
    required this.enableStreakMilestones,
    required this.enableShopUpdates,
    required this.enablePushNotifications,
    required this.enableEmailNotifications,
    required this.enableSoundNotifications,
    required this.enableVibrationNotifications,
    this.quietHoursStartTime,
    this.quietHoursEndTime,
    required this.lastUpdatedAt,
  });

  bool isInQuietHours() {
    if (quietHoursStartTime == null || quietHoursEndTime == null) {
      return false;
    }
    final now = TimeOfDay.now();
    final parts = quietHoursStartTime!.split(':');
    final startHour = int.parse(parts[0]);
    final startMinute = int.parse(parts[1]);
    final start = TimeOfDay(hour: startHour, minute: startMinute);

    final endParts = quietHoursEndTime!.split(':');
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);
    final end = TimeOfDay(hour: endHour, minute: endMinute);

    if (start.hour < end.hour) {
      return now.hour >= start.hour && now.hour < end.hour;
    } else {
      return now.hour >= start.hour || now.hour < end.hour;
    }
  }

  NotificationPreference copyWith({
    String? userId,
    bool? enableChallengeReminders,
    bool? enablePetNotifications,
    bool? enableVideoRecommendations,
    bool? enableFriendChallenges,
    bool? enableAchievements,
    bool? enableDailyQuests,
    bool? enableStreakMilestones,
    bool? enableShopUpdates,
    bool? enablePushNotifications,
    bool? enableEmailNotifications,
    bool? enableSoundNotifications,
    bool? enableVibrationNotifications,
    String? quietHoursStartTime,
    String? quietHoursEndTime,
    DateTime? lastUpdatedAt,
  }) {
    return NotificationPreference(
      userId: userId ?? this.userId,
      enableChallengeReminders:
          enableChallengeReminders ?? this.enableChallengeReminders,
      enablePetNotifications:
          enablePetNotifications ?? this.enablePetNotifications,
      enableVideoRecommendations:
          enableVideoRecommendations ?? this.enableVideoRecommendations,
      enableFriendChallenges:
          enableFriendChallenges ?? this.enableFriendChallenges,
      enableAchievements: enableAchievements ?? this.enableAchievements,
      enableDailyQuests: enableDailyQuests ?? this.enableDailyQuests,
      enableStreakMilestones:
          enableStreakMilestones ?? this.enableStreakMilestones,
      enableShopUpdates: enableShopUpdates ?? this.enableShopUpdates,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableEmailNotifications:
          enableEmailNotifications ?? this.enableEmailNotifications,
      enableSoundNotifications:
          enableSoundNotifications ?? this.enableSoundNotifications,
      enableVibrationNotifications:
          enableVibrationNotifications ?? this.enableVibrationNotifications,
      quietHoursStartTime: quietHoursStartTime ?? this.quietHoursStartTime,
      quietHoursEndTime: quietHoursEndTime ?? this.quietHoursEndTime,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationPreferenceToJson(this);

  static NotificationPreference defaultPreference(String userId) {
    return NotificationPreference(
      userId: userId,
      enableChallengeReminders: true,
      enablePetNotifications: true,
      enableVideoRecommendations: true,
      enableFriendChallenges: true,
      enableAchievements: true,
      enableDailyQuests: true,
      enableStreakMilestones: true,
      enableShopUpdates: true,
      enablePushNotifications: true,
      enableEmailNotifications: false,
      enableSoundNotifications: true,
      enableVibrationNotifications: true,
      quietHoursStartTime: '22:00',
      quietHoursEndTime: '08:00',
      lastUpdatedAt: DateTime.now(),
    );
  }
}

@JsonSerializable()
class NotificationStats {
  final String userId;
  final int totalNotifications;
  final int unreadNotifications;
  final int readNotifications;
  final int deletedNotifications;
  final Map<String, int> notificationsByType;
  final DateTime? lastNotificationAt;

  NotificationStats({
    required this.userId,
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.readNotifications,
    required this.deletedNotifications,
    required this.notificationsByType,
    this.lastNotificationAt,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationStatsToJson(this);
}
