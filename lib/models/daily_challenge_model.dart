import 'package:json_annotation/json_annotation.dart';

part 'daily_challenge_model.g.dart';

/// Daily challenge entry in the database
@JsonSerializable()
class DailyChallenge {
  final String challengeId; // Date-based ID (YYYY-MM-DD)
  final String phrase; // Today's challenge phrase
  final String phraseMeaning; // Japanese meaning
  final String phrasePronunciation; // Pronunciation guide
  final String audioUrl; // URL to native speaker audio
  final DateTime releaseTime; // When phrase was released (7:00 UTC)
  final DateTime expiresAt; // When challenge expires (next day 7:00 UTC)

  const DailyChallenge({
    required this.challengeId,
    required this.phrase,
    required this.phraseMeaning,
    required this.phrasePronunciation,
    required this.audioUrl,
    required this.releaseTime,
    required this.expiresAt,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) =>
      _$DailyChallengeFromJson(json);

  Map<String, dynamic> toJson() => _$DailyChallengeToJson(this);
}

/// User's attempt at today's challenge
@JsonSerializable()
class ChallengeAttempt {
  final String attemptId;
  final String challengeId; // Reference to DailyChallenge
  final String userId;
  final String userResponse; // User's spoken phrase (from speech-to-text)
  final int scorePoints; // 0-100 score
  final double accuracyScore; // Speech recognition accuracy
  final DateTime attemptedAt;
  final bool isCorrect; // Whether pronunciation matches

  const ChallengeAttempt({
    required this.attemptId,
    required this.challengeId,
    required this.userId,
    required this.userResponse,
    required this.scorePoints,
    required this.accuracyScore,
    required this.attemptedAt,
    required this.isCorrect,
  });

  factory ChallengeAttempt.fromJson(Map<String, dynamic> json) =>
      _$ChallengeAttemptFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeAttemptToJson(this);
}

/// Leaderboard entry for current day's challenge
@JsonSerializable()
class ChallengeLeaderboardEntry {
  final int rank; // 1st, 2nd, 3rd...
  final String userId;
  final String userName;
  final int score; // 0-100
  final String userRegion; // Prefecture/Region
  final String userLevel; // Grade level (小6, etc)
  final bool isMedalEarned; // 🥇🥈🥉 for top 3
  final DateTime achievedAt;

  const ChallengeLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.score,
    required this.userRegion,
    required this.userLevel,
    required this.isMedalEarned,
    required this.achievedAt,
  });

  factory ChallengeLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$ChallengeLeaderboardEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeLeaderboardEntryToJson(this);

  /// Medal emoji based on rank
  String get medalEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
}

/// User's daily challenge statistics
@JsonSerializable()
class ChallengeStat {
  final String userId;
  final int totalAttempts; // How many days participated
  final int consecutiveDays; // Streak
  final double averageScore; // Average score across attempts
  final int bestScore; // Personal best
  final DateTime lastAttemptAt; // Last day participated
  final List<String> earnedBadges; // Special badges for streaks

  const ChallengeStat({
    required this.userId,
    required this.totalAttempts,
    required this.consecutiveDays,
    required this.averageScore,
    required this.bestScore,
    required this.lastAttemptAt,
    required this.earnedBadges,
  });

  factory ChallengeStat.fromJson(Map<String, dynamic> json) =>
      _$ChallengeStatFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeStatToJson(this);
}

/// Reward earned from challenge completion
@JsonSerializable()
class ChallengeReward {
  final String rewardId;
  final String challengeId;
  final int coinsAwarded; // Coins for participating
  final int bonusCoins; // Bonus coins for top rankings
  final String badgeEarned; // Badge ID if applicable (3-day streak, etc)
  final String petDecoration; // Pet decoration for 30-day streak
  final DateTime awardedAt;

  const ChallengeReward({
    required this.rewardId,
    required this.challengeId,
    required this.coinsAwarded,
    required this.bonusCoins,
    required this.badgeEarned,
    required this.petDecoration,
    required this.awardedAt,
  });

  factory ChallengeReward.fromJson(Map<String, dynamic> json) =>
      _$ChallengeRewardFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeRewardToJson(this);

  /// Total coins including bonus
  int get totalCoins => coinsAwarded + bonusCoins;
}

/// Share card data for social media
@JsonSerializable()
class ChallengeShareCard {
  final String challengeId;
  final String phrase;
  final int userScore;
  final int userRank;
  final DateTime createdAt;
  final String shareImageUrl; // Generated share image

  const ChallengeShareCard({
    required this.challengeId,
    required this.phrase,
    required this.userScore,
    required this.userRank,
    required this.createdAt,
    required this.shareImageUrl,
  });

  factory ChallengeShareCard.fromJson(Map<String, dynamic> json) =>
      _$ChallengeShareCardFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeShareCardToJson(this);

  /// Social media share text
  String get shareText => '$userScore点🥇 eigo-kore 1日1フレーズチャレンジ';
}
