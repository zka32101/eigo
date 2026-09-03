import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

enum MessageType {
  text,
  image,
  emoji,
  audio,
  file,
  system, // System messages (user joined, left, etc.)
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum ConversationType {
  direct, // One-to-one chat
  group, // Group chat
  challenge, // Challenge-related messages
  team, // Team chat
}

@JsonSerializable()
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final MessageType type;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;
  final MessageStatus status;
  final List<String>? readBy; // User IDs who have read this message
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? fileName;
  final int? fileSizeBytes;
  final Map<String, dynamic>? metadata; // Additional data like emoji reactions
  final bool isDeleted;
  final String? replyToMessageId; // For message threading

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.type,
    required this.content,
    required this.createdAt,
    this.editedAt,
    required this.status,
    this.readBy,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.fileName,
    this.fileSizeBytes,
    this.metadata,
    this.isDeleted = false,
    this.replyToMessageId,
  });

  bool get isSent => status == MessageStatus.sent || status == MessageStatus.delivered || status == MessageStatus.read;
  bool get isRead => status == MessageStatus.read;

  String get typeEmoji {
    switch (type) {
      case MessageType.text:
        return '💬';
      case MessageType.image:
        return '🖼️';
      case MessageType.emoji:
        return '😊';
      case MessageType.audio:
        return '🎙️';
      case MessageType.file:
        return '📎';
      case MessageType.system:
        return 'ℹ️';
    }
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${createdAt.month}月${createdAt.day}日';
    }
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageType? type,
    String? content,
    DateTime? createdAt,
    DateTime? editedAt,
    MessageStatus? status,
    List<String>? readBy,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? fileName,
    int? fileSizeBytes,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
    String? replyToMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      status: status ?? this.status,
      readBy: readBy ?? this.readBy,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Conversation {
  final String id;
  final ConversationType type;
  final List<String> participantIds;
  final Map<String, String> participantNames; // userId -> name
  final Map<String, String> participantAvatars; // userId -> avatar
  final String? name; // For group chats
  final String? icon; // Group icon/emoji
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final int unreadCount;
  final bool isMuted;
  final bool isArchived;
  final String? challengeId; // If related to a challenge
  final DateTime? challengeEndDate;

  Conversation({
    required this.id,
    required this.type,
    required this.participantIds,
    required this.participantNames,
    required this.participantAvatars,
    this.name,
    this.icon,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isArchived = false,
    this.challengeId,
    this.challengeEndDate,
  });

  String get displayName {
    if (name != null) return name!; // Group chat name
    if (participantNames.isNotEmpty) {
      return participantNames.values.first; // Direct chat - other person's name
    }
    return 'Unknown';
  }

  String get displayIcon {
    if (icon != null) return icon!;
    return '👥'; // Default group icon
  }

  String get lastMessagePreview {
    if (lastMessageContent == null) return 'チャットを開始...';
    if (lastMessageContent!.length > 50) {
      return '${lastMessageContent!.substring(0, 50)}...';
    }
    return lastMessageContent!;
  }

  String get formattedLastMessageTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${lastMessageAt.month}月${lastMessageAt.day}日';
    }
  }

  Conversation copyWith({
    String? id,
    ConversationType? type,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantAvatars,
    String? name,
    String? icon,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    int? unreadCount,
    bool? isMuted,
    bool? isArchived,
    String? challengeId,
    DateTime? challengeEndDate,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      challengeId: challengeId ?? this.challengeId,
      challengeEndDate: challengeEndDate ?? this.challengeEndDate,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class DirectMessage extends Conversation {
  final String otherUserId;

  DirectMessage({
    required String id,
    required List<String> participantIds,
    required Map<String, String> participantNames,
    required Map<String, String> participantAvatars,
    required DateTime createdAt,
    required DateTime lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    int unreadCount = 0,
    bool isMuted = false,
    bool isArchived = false,
    required this.otherUserId,
  }) : super(
    id: id,
    type: ConversationType.direct,
    participantIds: participantIds,
    participantNames: participantNames,
    participantAvatars: participantAvatars,
    createdAt: createdAt,
    lastMessageAt: lastMessageAt,
    lastMessageContent: lastMessageContent,
    lastMessageSenderId: lastMessageSenderId,
    unreadCount: unreadCount,
    isMuted: isMuted,
    isArchived: isArchived,
  );

  factory DirectMessage.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageFromJson(json);
  Map<String, dynamic> toJson() => _$DirectMessageToJson(this);
}

@JsonSerializable()
class MessageThread {
  final String id;
  final String conversationId;
  final String parentMessageId;
  final List<Message> replies;
  final int replyCount;
  final DateTime createdAt;
  final DateTime lastReplyAt;

  MessageThread({
    required this.id,
    required this.conversationId,
    required this.parentMessageId,
    required this.replies,
    required this.replyCount,
    required this.createdAt,
    required this.lastReplyAt,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) =>
      _$MessageThreadFromJson(json);
  Map<String, dynamic> toJson() => _$MessageThreadToJson(this);
}

@JsonSerializable()
class MessagingStats {
  final String userId;
  final int totalConversations;
  final int totalMessages;
  final int unreadMessages;
  final List<String> recentChatUserIds;
  final DateTime lastActiveAt;
  final int? totalGroupChats;
  final int? totalDirectChats;

  MessagingStats({
    required this.userId,
    required this.totalConversations,
    required this.totalMessages,
    required this.unreadMessages,
    required this.recentChatUserIds,
    required this.lastActiveAt,
    this.totalGroupChats,
    this.totalDirectChats,
  });

  factory MessagingStats.fromJson(Map<String, dynamic> json) =>
      _$MessagingStatsFromJson(json);
  Map<String, dynamic> toJson() => _$MessagingStatsToJson(this);
}
