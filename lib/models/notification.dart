/// Notification model for system notifications
/// Phase 14 Part 4: Notifications System
class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? relatedUserId; // For friend requests, messages, etc.
  final String? relatedUserName;
  final String? relatedUserAvatar;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata; // For additional data

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedUserId,
    this.relatedUserName,
    this.relatedUserAvatar,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.metadata,
  });

  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? relatedUserId,
    String? relatedUserName,
    String? relatedUserAvatar,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      relatedUserName: relatedUserName ?? this.relatedUserName,
      relatedUserAvatar: relatedUserAvatar ?? this.relatedUserAvatar,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.toString().split('.').last,
    'title': title,
    'message': message,
    'relatedUserId': relatedUserId,
    'relatedUserName': relatedUserName,
    'relatedUserAvatar': relatedUserAvatar,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'readAt': readAt?.toIso8601String(),
    'metadata': metadata,
  };

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: _typeFromString(json['type'] as String? ?? 'message'),
      title: json['title'] as String,
      message: json['message'] as String,
      relatedUserId: json['relatedUserId'] as String?,
      relatedUserName: json['relatedUserName'] as String?,
      relatedUserAvatar: json['relatedUserAvatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static NotificationType _typeFromString(String type) {
    switch (type) {
      case 'friendRequest':
        return NotificationType.friendRequest;
      case 'friendAccepted':
        return NotificationType.friendAccepted;
      case 'message':
        return NotificationType.message;
      case 'achievement':
        return NotificationType.achievement;
      case 'levelUp':
        return NotificationType.levelUp;
      case 'streakMilestone':
        return NotificationType.streakMilestone;
      default:
        return NotificationType.message;
    }
  }
}

enum NotificationType {
  friendRequest,
  friendAccepted,
  message,
  achievement,
  levelUp,
  streakMilestone,
}
