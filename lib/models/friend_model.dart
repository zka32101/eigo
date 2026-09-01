/// フレンド管理モデル
class Friend {
  final String userId;
  final String name;
  final String avatar;
  final int level;
  final int coinsEarned;
  final int totalStudyMinutes;
  final DateTime addedAt;
  final bool isFavorite;

  const Friend({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.level,
    required this.coinsEarned,
    required this.totalStudyMinutes,
    required this.addedAt,
    this.isFavorite = false,
  });

  Friend copyWith({
    String? userId,
    String? name,
    String? avatar,
    int? level,
    int? coinsEarned,
    int? totalStudyMinutes,
    DateTime? addedAt,
    bool? isFavorite,
  }) {
    return Friend(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      addedAt: addedAt ?? this.addedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'avatar': avatar,
        'level': level,
        'coinsEarned': coinsEarned,
        'totalStudyMinutes': totalStudyMinutes,
        'addedAt': addedAt.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        userId: json['userId'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String,
        level: json['level'] as int,
        coinsEarned: json['coinsEarned'] as int,
        totalStudyMinutes: json['totalStudyMinutes'] as int,
        addedAt: DateTime.parse(json['addedAt'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}

/// フレンドリクエスト
class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String fromUserName;
  final String fromUserAvatar;
  final DateTime requestedAt;
  final FriendRequestStatus status;

  const FriendRequest({
    required this.requestId,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserAvatar,
    required this.requestedAt,
    this.status = FriendRequestStatus.pending,
  });

  FriendRequest copyWith({
    String? requestId,
    String? fromUserId,
    String? fromUserName,
    String? fromUserAvatar,
    DateTime? requestedAt,
    FriendRequestStatus? status,
  }) {
    return FriendRequest(
      requestId: requestId ?? this.requestId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserAvatar: fromUserAvatar ?? this.fromUserAvatar,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'fromUserAvatar': fromUserAvatar,
        'requestedAt': requestedAt.toIso8601String(),
        'status': status.toString(),
      };

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
        requestId: json['requestId'] as String,
        fromUserId: json['fromUserId'] as String,
        fromUserName: json['fromUserName'] as String,
        fromUserAvatar: json['fromUserAvatar'] as String,
        requestedAt: DateTime.parse(json['requestedAt'] as String),
        status: FriendRequestStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => FriendRequestStatus.pending,
        ),
      );
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  canceled,
}
