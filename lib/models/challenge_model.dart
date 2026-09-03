import 'package:json_annotation/json_annotation.dart';

part 'challenge_model.g.dart';

/// Challenge type enumeration
enum ChallengeType {
  daily,
  weekly,
  community,
  friend,
}

/// Challenge difficulty level
enum ChallengeDifficulty {
  easy,
  normal,
  hard,
  expert,
}

/// Challenge objective type
enum ObjectiveType {
  completeLessons,
  achieveScore,
  earnXP,
  improveScore,
  playStreak,
  watchVideos,
  completeQuiz,
  custom,
}

/// Social challenge model
@JsonSerializable()
class SocialChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final ObjectiveType objectiveType;
  final int targetValue; // lessons count, score, XP, etc.
  final int currentValue; // for user progress
  final DateTime startDate;
  final DateTime endDate;
  final int participantCount;
  final List<String> participantIds;
  final bool isActive;
  final String? theme; // "Week of Phonetics", etc.
  final List<ChallengeReward> rewards;
  final Map<String, int> leaderboard; // userId -> score
  final String? bannerUrl;
  final int viewCount;

  SocialChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.objectiveType,
    required this.targetValue,
    this.currentValue = 0,
    required this.startDate,
    required this.endDate,
    this.participantCount = 0,
    this.participantIds = const [],
    this.isActive = true,
    this.theme,
    this.rewards = const [],
    this.leaderboard = const {},
    this.bannerUrl,
    this.viewCount = 0,
  });

  factory SocialChallenge.fromJson(Map<String, dynamic> json) =>
      _$SocialChallengeFromJson(json);

  Map<String, dynamic> toJson() => _$SocialChallengeToDynamicJson(this);

  /// Get progress percentage (0-100)
  int get progressPercentage {
    if (targetValue == 0) return 0;
    return ((currentValue / targetValue) * 100).toInt().clamp(0, 100);
  }

  /// Check if challenge is completed
  bool get isCompleted => currentValue >= targetValue;

  /// Get time remaining
  Duration get timeRemaining => endDate.difference(DateTime.now());

  /// Get formatted time remaining
  String get formattedTimeRemaining {
    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}日残り';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}時間残り';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}分残り';
    }
    return '終了間近';
  }

  /// Get difficulty emoji
  String get difficultyEmoji {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return '🟢';
      case ChallengeDifficulty.normal:
        return '🟡';
      case ChallengeDifficulty.hard:
        return '🟠';
      case ChallengeDifficulty.expert:
        return '🔴';
    }
  }

  /// Get type label
  String get typeLabel {
    switch (type) {
      case ChallengeType.daily:
        return '日間チャレンジ';
      case ChallengeType.weekly:
        return '週間チャレンジ';
      case ChallengeType.community:
        return 'コミュニティチャレンジ';
      case ChallengeType.friend:
        return 'フレンドチャレンジ';
    }
  }

  /// Copy with
  SocialChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeDifficulty? difficulty,
    ObjectiveType? objectiveType,
    int? targetValue,
    int? currentValue,
    DateTime? startDate,
    DateTime? endDate,
    int? participantCount,
    List<String>? participantIds,
    bool? isActive,
    String? theme,
    List<ChallengeReward>? rewards,
    Map<String, int>? leaderboard,
    String? bannerUrl,
    int? viewCount,
  }) {
    return SocialChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      objectiveType: objectiveType ?? this.objectiveType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantCount: participantCount ?? this.participantCount,
      participantIds: participantIds ?? this.participantIds,
      isActive: isActive ?? this.isActive,
      theme: theme ?? this.theme,
      rewards: rewards ?? this.rewards,
      leaderboard: leaderboard ?? this.leaderboard,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}

/// Challenge reward tier
@JsonSerializable()
class ChallengeReward {
  final String id;
  final int tier; // 1-5 (bronze to legendary)
  final String tierLabel; // ブロンズ, シルバー, ゴールド, etc.
  final int minProgress; // % to achieve (0-100)
  final int coinReward;
  final int xpReward;
  final String? badgeId;
  final String? specialItem;
  final String? icon;

  ChallengeReward({
    required this.id,
    required this.tier,
    required this.tierLabel,
    required this.minProgress,
    required this.coinReward,
    required this.xpReward,
    this.badgeId,
    this.specialItem,
    this.icon,
  });

  factory ChallengeReward.fromJson(Map<String, dynamic> json) =>
      _$ChallengeRewardFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeRewardToJson(this);
}

/// User's challenge participation
@JsonSerializable()
class UserChallengeProgress {
  final String userId;
  final String challengeId;
  final int progress; // current value
  final bool isCompleted;
  final DateTime joinedAt;
  final DateTime? completedAt;
  final List<String> earnedRewardIds; // reward IDs earned
  final bool isAchieved; // at least one reward earned

  UserChallengeProgress({
    required this.userId,
    required this.challengeId,
    required this.progress,
    this.isCompleted = false,
    required this.joinedAt,
    this.completedAt,
    this.earnedRewardIds = const [],
    this.isAchieved = false,
  });

  factory UserChallengeProgress.fromJson(Map<String, dynamic> json) =>
      _$UserChallengeProgressFromJson(json);

  Map<String, dynamic> toJson() => _$UserChallengeProgressToJson(this);

  /// Copy with
  UserChallengeProgress copyWith({
    String? userId,
    String? challengeId,
    int? progress,
    bool? isCompleted,
    DateTime? joinedAt,
    DateTime? completedAt,
    List<String>? earnedRewardIds,
    bool? isAchieved,
  }) {
    return UserChallengeProgress(
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      joinedAt: joinedAt ?? this.joinedAt,
      completedAt: completedAt ?? this.completedAt,
      earnedRewardIds: earnedRewardIds ?? this.earnedRewardIds,
      isAchieved: isAchieved ?? this.isAchieved,
    );
  }
}

/// Friend challenge (head-to-head)
@JsonSerializable()
class FriendChallenge {
  final String id;
  final String initiatorId;
  final String opponentId;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int initiatorProgress;
  final int opponentProgress;
  final int targetValue;
  final bool isCompleted;
  final String? winnerId; // user ID of winner

  FriendChallenge({
    required this.id,
    required this.initiatorId,
    required this.opponentId,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.initiatorProgress = 0,
    this.opponentProgress = 0,
    required this.targetValue,
    this.isCompleted = false,
    this.winnerId,
  });

  factory FriendChallenge.fromJson(Map<String, dynamic> json) =>
      _$FriendChallengeFromJson(json);

  Map<String, dynamic> toJson() => _$FriendChallengeToJson(this);

  /// Get current leader
  String? get currentLeader {
    if (initiatorProgress > opponentProgress) return initiatorId;
    if (opponentProgress > initiatorProgress) return opponentId;
    return null;
  }

  /// Get lead amount
  int get leadAmount => (initiatorProgress - opponentProgress).abs();

  /// Copy with
  FriendChallenge copyWith({
    String? id,
    String? initiatorId,
    String? opponentId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? initiatorProgress,
    int? opponentProgress,
    int? targetValue,
    bool? isCompleted,
    String? winnerId,
  }) {
    return FriendChallenge(
      id: id ?? this.id,
      initiatorId: initiatorId ?? this.initiatorId,
      opponentId: opponentId ?? this.opponentId,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      initiatorProgress: initiatorProgress ?? this.initiatorProgress,
      opponentProgress: opponentProgress ?? this.opponentProgress,
      targetValue: targetValue ?? this.targetValue,
      isCompleted: isCompleted ?? this.isCompleted,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}

/// Challenge statistics
@JsonSerializable()
class ChallengeStats {
  final String challengeId;
  final int totalParticipants;
  final int completionCount;
  final double avgProgress;
  final int totalCoinsAwarded;
  final int totalXpAwarded;
  final List<String> topParticipants; // user IDs

  ChallengeStats({
    required this.challengeId,
    required this.totalParticipants,
    required this.completionCount,
    required this.avgProgress,
    required this.totalCoinsAwarded,
    required this.totalXpAwarded,
    this.topParticipants = const [],
  });

  factory ChallengeStats.fromJson(Map<String, dynamic> json) =>
      _$ChallengeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeStatsToJson(this);

  /// Get completion rate percentage
  double get completionRate {
    if (totalParticipants == 0) return 0.0;
    return (completionCount / totalParticipants) * 100;
  }
}

/// Daily challenge template
class DailyChallengeTemplate {
  static const List<String> descriptions = [
    '5つのレッスンを完了する',
    '3つのレッスンで90%以上のスコアを獲得する',
    '500 XPを獲得する',
    '10個の単語を学ぶ',
    '発音動画を3つ視聴する',
  ];

  static const List<int> targetValues = [5, 3, 500, 10, 3];

  static const List<int> coinRewards = [100, 150, 200, 80, 120];

  static const List<int> xpRewards = [50, 75, 100, 40, 60];
}

/// Weekly challenge template
class WeeklyChallengeTemplate {
  static const List<String> descriptions = [
    '30個のレッスンを完了する',
    '5日連続でアクティブになる',
    '発音スコアを50ポイント改善する',
    'マルチプレイヤーマッチに参加する',
    '合計3,000 XPを獲得する',
  ];

  static const List<int> targetValues = [30, 5, 50, 1, 3000];

  static const List<int> coinRewards = [500, 600, 700, 400, 800];

  static const List<int> xpRewards = [300, 400, 500, 200, 600];
}
