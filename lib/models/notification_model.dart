/// 通知タイプ
enum NotificationType {
  dailyReminder, // 日常学習リマインダー
  streakMaintenance, // ストリーク維持リマインダー
  achievement, // アチーブメント獲得
  levelUp, // レベルアップ
  friendRequest, // フレンドリクエスト
  promotionalOffer, // キャンペーン
  systemMessage, // システムメッセージ
}

/// 通知設定
class NotificationSettings {
  final bool dailyRemindersEnabled;
  final int dailyReminderHour; // 0-23
  final bool streakRemindersEnabled;
  final int streakReminderHour;
  final bool achievementNotifications;
  final bool friendNotifications;
  final bool promotionalNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime lastUpdated;

  const NotificationSettings({
    this.dailyRemindersEnabled = true,
    this.dailyReminderHour = 19, // デフォルト19時
    this.streakRemindersEnabled = true,
    this.streakReminderHour = 21, // デフォルト21時
    this.achievementNotifications = true,
    this.friendNotifications = true,
    this.promotionalNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    required this.lastUpdated,
  });

  NotificationSettings copyWith({
    bool? dailyRemindersEnabled,
    int? dailyReminderHour,
    bool? streakRemindersEnabled,
    int? streakReminderHour,
    bool? achievementNotifications,
    bool? friendNotifications,
    bool? promotionalNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? lastUpdated,
  }) {
    return NotificationSettings(
      dailyRemindersEnabled: dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      streakRemindersEnabled: streakRemindersEnabled ?? this.streakRemindersEnabled,
      streakReminderHour: streakReminderHour ?? this.streakReminderHour,
      achievementNotifications: achievementNotifications ?? this.achievementNotifications,
      friendNotifications: friendNotifications ?? this.friendNotifications,
      promotionalNotifications: promotionalNotifications ?? this.promotionalNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyRemindersEnabled': dailyRemindersEnabled,
        'dailyReminderHour': dailyReminderHour,
        'streakRemindersEnabled': streakRemindersEnabled,
        'streakReminderHour': streakReminderHour,
        'achievementNotifications': achievementNotifications,
        'friendNotifications': friendNotifications,
        'promotionalNotifications': promotionalNotifications,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        dailyRemindersEnabled: json['dailyRemindersEnabled'] as bool? ?? true,
        dailyReminderHour: json['dailyReminderHour'] as int? ?? 19,
        streakRemindersEnabled: json['streakRemindersEnabled'] as bool? ?? true,
        streakReminderHour: json['streakReminderHour'] as int? ?? 21,
        achievementNotifications: json['achievementNotifications'] as bool? ?? true,
        friendNotifications: json['friendNotifications'] as bool? ?? true,
        promotionalNotifications: json['promotionalNotifications'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String? ?? DateTime.now().toIso8601String()),
      );
}

/// 通知記録
class NotificationRecord {
  final String notificationId;
  final NotificationType type;
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const NotificationRecord({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  NotificationRecord copyWith({
    String? notificationId,
    NotificationType? type,
    String? title,
    String? message,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationRecord(
      notificationId: notificationId ?? this.notificationId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'type': type.toString(),
        'title': title,
        'message': message,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'metadata': metadata,
      };

  factory NotificationRecord.fromJson(Map<String, dynamic> json) =>
      NotificationRecord(
        notificationId: json['notificationId'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => NotificationType.systemMessage,
        ),
        title: json['title'] as String,
        message: json['message'] as String,
        imageUrl: json['imageUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

/// スケジュール済み通知
class ScheduledNotification {
  final String notificationId;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final bool isRecurring; // 定期通知かどうか
  final String? recurringPattern; // 'daily', 'weekly', など
  final bool isEnabled;

  const ScheduledNotification({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.isRecurring = false,
    this.recurringPattern,
    this.isEnabled = true,
  });

  ScheduledNotification copyWith({
    String? notificationId,
    String? title,
    String? message,
    DateTime? scheduledTime,
    bool? isRecurring,
    String? recurringPattern,
    bool? isEnabled,
  }) {
    return ScheduledNotification(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'title': title,
        'message': message,
        'scheduledTime': scheduledTime.toIso8601String(),
        'isRecurring': isRecurring,
        'recurringPattern': recurringPattern,
        'isEnabled': isEnabled,
      };

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) =>
      ScheduledNotification(
        notificationId: json['notificationId'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        scheduledTime: DateTime.parse(json['scheduledTime'] as String),
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringPattern: json['recurringPattern'] as String?,
        isEnabled: json['isEnabled'] as bool? ?? true,
      );
}
