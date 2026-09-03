import 'package:json_annotation/json_annotation.dart';

part 'challenge_model.g.dart';

enum ChallengeType {
  individual, // Solo challenges
  team, // Team-based challenges
  tournament, // Multi-team tournament
  timed, // Time-limited challenges
  streakBased, // Based on streak continuation
  skillFocused, // Focus on specific skill
}

enum ChallengeStatus {
  draft,
  active,
  paused,
  completed,
  cancelled,
}

enum ChallengeGoalMetric {
  totalScore,
  lessonsCompleted,
  xpEarned,
  streakDays,
  challengesWon,
  accuracyPercent,
  speedScore,
}

@JsonSerializable()
class SocialChallenge {
  final String id;
  final String creatorId;
  final String creatorName;
  final String creatorAvatar;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeStatus status;
  final ChallengeGoalMetric goalMetric;
  final int goalValue;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final int maxParticipants;
  final int currentParticipants;
  final bool isPublic;
  final List<String> invitedUserIds;
  final Map<String, int> participants; // userId -> score
  final String? winnerUserId;
  final List<String>? teamIds; // For team challenges
  final int? firstPlacePrize; // XP or coins
  final int? secondPlacePrize;
  final int? thirdPlacePrize;
  final List<String>? tags; // difficulty, language, skill type
  final String? imageUrl;
  final int viewCount;
  final int joinCount;

  SocialChallenge({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatar,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.goalMetric,
    required this.goalValue,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.isPublic,
    required this.invitedUserIds,
    required this.participants,
    this.winnerUserId,
    this.teamIds,
    this.firstPlacePrize,
    this.secondPlacePrize,
    this.thirdPlacePrize,
    this.tags,
    this.imageUrl,
    this.viewCount = 0,
    this.joinCount = 0,
  });

  bool get isActive => status == ChallengeStatus.active;
  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isFull => currentParticipants >= maxParticipants;

  String get typeLabel {
    switch (type) {
      case ChallengeType.individual:
        return '個人チャレンジ';
      case ChallengeType.team:
        return 'チームチャレンジ';
      case ChallengeType.tournament:
        return 'トーナメント';
      case ChallengeType.timed:
        return 'タイムチャレンジ';
      case ChallengeType.streakBased:
        return 'ストリークチャレンジ';
      case ChallengeType.skillFocused:
        return 'スキルチャレンジ';
    }
  }

  String get statusLabel {
    switch (status) {
      case ChallengeStatus.draft:
        return '下書き';
      case ChallengeStatus.active:
        return 'アクティブ';
      case ChallengeStatus.paused:
        return '一時停止';
      case ChallengeStatus.completed:
        return '完了';
      case ChallengeStatus.cancelled:
        return 'キャンセル';
    }
  }

  String get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    if (diff < 0) return '終了';
    if (diff == 0) return '今日終了';
    return '残り$diff日';
  }

  int? getUserRank(String userId) {
    if (!participants.containsKey(userId)) return null;
    final sortedEntries = participants.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.indexWhere((e) => e.key == userId) + 1;
  }

  int? getUserScore(String userId) {
    return participants[userId];
  }

  List<MapEntry<String, int>> getTopParticipants({int limit = 10}) {
    final sortedEntries = participants.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(limit).toList();
  }

  SocialChallenge copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeStatus? status,
    ChallengeGoalMetric? goalMetric,
    int? goalValue,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    int? maxParticipants,
    int? currentParticipants,
    bool? isPublic,
    List<String>? invitedUserIds,
    Map<String, int>? participants,
    String? winnerUserId,
    List<String>? teamIds,
    int? firstPlacePrize,
    int? secondPlacePrize,
    int? thirdPlacePrize,
    List<String>? tags,
    String? imageUrl,
    int? viewCount,
    int? joinCount,
  }) {
    return SocialChallenge(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      goalMetric: goalMetric ?? this.goalMetric,
      goalValue: goalValue ?? this.goalValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isPublic: isPublic ?? this.isPublic,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      participants: participants ?? this.participants,
      winnerUserId: winnerUserId ?? this.winnerUserId,
      teamIds: teamIds ?? this.teamIds,
      firstPlacePrize: firstPlacePrize ?? this.firstPlacePrize,
      secondPlacePrize: secondPlacePrize ?? this.secondPlacePrize,
      thirdPlacePrize: thirdPlacePrize ?? this.thirdPlacePrize,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      viewCount: viewCount ?? this.viewCount,
      joinCount: joinCount ?? this.joinCount,
    );
  }

  factory SocialChallenge.fromJson(Map<String, dynamic> json) =>
      _$SocialChallengeFromJson(json);
  Map<String, dynamic> toJson() => _$SocialChallengeToJson(this);
}

@JsonSerializable()
class ChallengeParticipation {
  final String id;
  final String challengeId;
  final String userId;
  final String userName;
  final String userAvatar;
  final DateTime joinedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int currentScore;
  final int currentRank;
  final bool hasCompleted;
  final List<String> activityLog; // Track user's progress
  final Map<String, dynamic>? metadata;

  ChallengeParticipation({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.joinedAt,
    this.startedAt,
    this.completedAt,
    required this.currentScore,
    required this.currentRank,
    required this.hasCompleted,
    required this.activityLog,
    this.metadata,
  });

  factory ChallengeParticipation.fromJson(Map<String, dynamic> json) =>
      _$ChallengeParticipationFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeParticipationToJson(this);
}

@JsonSerializable()
class ChallengeResult {
  final String id;
  final String challengeId;
  final String userId;
  final String userName;
  final String userAvatar;
  final int finalScore;
  final int finalRank;
  final DateTime completedAt;
  final int xpEarned;
  final int coinsEarned;
  final bool isWinner;
  final bool isPrizeWon;
  final String? prizeType; // 'first', 'second', 'third'
  final int? prizeAmount;
  final List<String> badgesEarned;

  ChallengeResult({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.finalScore,
    required this.finalRank,
    required this.completedAt,
    required this.xpEarned,
    required this.coinsEarned,
    required this.isWinner,
    required this.isPrizeWon,
    this.prizeType,
    this.prizeAmount,
    required this.badgesEarned,
  });

  String get rankEmoji {
    switch (finalRank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🎖️';
    }
  }

  factory ChallengeResult.fromJson(Map<String, dynamic> json) =>
      _$ChallengeResultFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeResultToJson(this);
}

@JsonSerializable()
class ChallengeInvitation {
  final String id;
  final String challengeId;
  final String invitedUserId;
  final String invitedUserName;
  final String inviterUserId;
  final String inviterName;
  final DateTime invitedAt;
  final DateTime? respondedAt;
  final bool accepted;
  final String challengeTitle;
  final String challengeDescription;

  ChallengeInvitation({
    required this.id,
    required this.challengeId,
    required this.invitedUserId,
    required this.invitedUserName,
    required this.inviterUserId,
    required this.inviterName,
    required this.invitedAt,
    this.respondedAt,
    required this.accepted,
    required this.challengeTitle,
    required this.challengeDescription,
  });

  bool get isPending => respondedAt == null;

  factory ChallengeInvitation.fromJson(Map<String, dynamic> json) =>
      _$ChallengeInvitationFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeInvitationToJson(this);
}

@JsonSerializable()
class ChallengeStats {
  final String userId;
  final int totalChallengesCreated;
  final int totalChallengesJoined;
  final int totalChallengesWon;
  final int totalXpFromChallenges;
  final int totalCoinsFromChallenges;
  final int winRate; // percentage
  final int averageRank;
  final List<String> favoriteTypes; // Challenge types user likes
  final DateTime lastChallengeDate;

  ChallengeStats({
    required this.userId,
    required this.totalChallengesCreated,
    required this.totalChallengesJoined,
    required this.totalChallengesWon,
    required this.totalXpFromChallenges,
    required this.totalCoinsFromChallenges,
    required this.winRate,
    required this.averageRank,
    required this.favoriteTypes,
    required this.lastChallengeDate,
  });

  factory ChallengeStats.fromJson(Map<String, dynamic> json) =>
      _$ChallengeStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeStatsToJson(this);
}
