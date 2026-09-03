/// Guild/Team models for collaborative learning
/// Phase 15 Part 2: Guilds/Teams System

class Guild {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String leaderId;
  final List<String> memberIds;
  final int level; // Guild level based on collective progress
  final int totalScore; // Combined score of all members
  final GuildTier tier;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GuildSettings settings;

  const Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.leaderId,
    required this.memberIds,
    required this.level,
    required this.totalScore,
    required this.tier,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
  });

  Guild copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? leaderId,
    List<String>? memberIds,
    int? level,
    int? totalScore,
    GuildTier? tier,
    DateTime? createdAt,
    DateTime? updatedAt,
    GuildSettings? settings,
  }) {
    return Guild(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      leaderId: leaderId ?? this.leaderId,
      memberIds: memberIds ?? this.memberIds,
      level: level ?? this.level,
      totalScore: totalScore ?? this.totalScore,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'leaderId': leaderId,
    'memberIds': memberIds,
    'level': level,
    'totalScore': totalScore,
    'tier': tier.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'settings': settings.toJson(),
  };

  factory Guild.fromJson(Map<String, dynamic> json) {
    return Guild(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      leaderId: json['leaderId'] as String,
      memberIds: List<String>.from(json['memberIds'] as List? ?? []),
      level: json['level'] as int? ?? 1,
      totalScore: json['totalScore'] as int? ?? 0,
      tier: _tierFromString(json['tier'] as String? ?? 'bronze'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      settings: GuildSettings.fromJson(json['settings'] as Map<String, dynamic>? ?? {}),
    );
  }

  static GuildTier _tierFromString(String tier) {
    switch (tier) {
      case 'bronze':
        return GuildTier.bronze;
      case 'silver':
        return GuildTier.silver;
      case 'gold':
        return GuildTier.gold;
      case 'platinum':
        return GuildTier.platinum;
      case 'diamond':
        return GuildTier.diamond;
      default:
        return GuildTier.bronze;
    }
  }
}

class GuildMember {
  final String userId;
  final String userName;
  final String userAvatar;
  final GuildRole role;
  final int contributionScore;
  final DateTime joinedAt;
  final bool isActive;

  const GuildMember({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.role,
    required this.contributionScore,
    required this.joinedAt,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'role': role.toString().split('.').last,
    'contributionScore': contributionScore,
    'joinedAt': joinedAt.toIso8601String(),
    'isActive': isActive,
  };

  factory GuildMember.fromJson(Map<String, dynamic> json) {
    return GuildMember(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      role: _roleFromString(json['role'] as String? ?? 'member'),
      contributionScore: json['contributionScore'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static GuildRole _roleFromString(String role) {
    switch (role) {
      case 'leader':
        return GuildRole.leader;
      case 'officer':
        return GuildRole.officer;
      case 'member':
        return GuildRole.member;
      default:
        return GuildRole.member;
    }
  }
}

class GuildSettings {
  final bool isPublic;
  final int maxMembers;
  final GuildJoinType joinType;
  final String? description;

  const GuildSettings({
    required this.isPublic,
    required this.maxMembers,
    required this.joinType,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'isPublic': isPublic,
    'maxMembers': maxMembers,
    'joinType': joinType.toString().split('.').last,
    'description': description,
  };

  factory GuildSettings.fromJson(Map<String, dynamic> json) {
    return GuildSettings(
      isPublic: json['isPublic'] as bool? ?? true,
      maxMembers: json['maxMembers'] as int? ?? 50,
      joinType: _joinTypeFromString(json['joinType'] as String? ?? 'open'),
      description: json['description'] as String?,
    );
  }

  static GuildJoinType _joinTypeFromString(String type) {
    switch (type) {
      case 'open':
        return GuildJoinType.open;
      case 'apply':
        return GuildJoinType.apply;
      case 'invite':
        return GuildJoinType.invite;
      default:
        return GuildJoinType.open;
    }
  }
}

enum GuildTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

enum GuildRole {
  leader,
  officer,
  member,
}

enum GuildJoinType {
  open,
  apply,
  invite,
}
