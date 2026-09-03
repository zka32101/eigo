/// Friend request model for tracking friend request status
/// Phase 14 Part 2: Friend System
class FriendRequest {
  final String id; // unique ID for this request (e.g., senderId_receiverId)
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String receiverId;
  final DateTime sentAt;
  final FriendRequestStatus status; // pending, accepted, declined

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.receiverId,
    required this.sentAt,
    this.status = FriendRequestStatus.pending,
  });

  FriendRequest copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    DateTime? sentAt,
    FriendRequestStatus? status,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'receiverId': receiverId,
    'sentAt': sentAt.toIso8601String(),
    'status': status.toString().split('.').last,
  };

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String,
      receiverId: json['receiverId'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      status: _statusFromString(json['status'] as String? ?? 'pending'),
    );
  }

  static FriendRequestStatus _statusFromString(String status) {
    switch (status) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'declined':
        return FriendRequestStatus.declined;
      default:
        return FriendRequestStatus.pending;
    }
  }
}

/// Friend relationship model
class Friend {
  final String userId; // friend's user ID
  final String name; // friend's name
  final String avatar; // friend's avatar
  final int grade; // friend's grade
  final int level; // friend's level
  final bool isOnline; // friend's online status
  final DateTime? lastSeenAt; // when friend was last seen
  final DateTime addedAt; // when they became friends

  const Friend({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.grade,
    required this.level,
    this.isOnline = false,
    this.lastSeenAt,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'avatar': avatar,
    'grade': grade,
    'level': level,
    'isOnline': isOnline,
    'lastSeenAt': lastSeenAt?.toIso8601String(),
    'addedAt': addedAt.toIso8601String(),
  };

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['userId'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      grade: json['grade'] as int,
      level: json['level'] as int,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt'] as String) : null,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

enum FriendRequestStatus {
  pending,
  accepted,
  declined,
}
