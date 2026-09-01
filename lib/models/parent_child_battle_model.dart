import 'package:json_annotation/json_annotation.dart';

part 'parent_child_battle_model.g.dart';

/// Parent-child duo battle mode
@JsonSerializable()
class ParentChildBattle {
  final String battleId;
  final String parentId;
  final String childId;
  final String parentName;
  final String childName;
  final String phrase;
  final String phraseMeaning;
  
  // Round results
  final int parentScore; // 0-100
  final int childScore; // 0-100
  final List<BattleRound> rounds; // Individual round history
  
  // Metadata
  final DateTime startedAt;
  final DateTime? completedAt;
  final String winner; // 'parent', 'child', or 'tie'
  final int parentCoinsEarned;
  final int childCoinsEarned;

  const ParentChildBattle({
    required this.battleId,
    required this.parentId,
    required this.childId,
    required this.parentName,
    required this.childName,
    required this.phrase,
    required this.phraseMeaning,
    required this.parentScore,
    required this.childScore,
    required this.rounds,
    required this.startedAt,
    this.completedAt,
    required this.winner,
    required this.parentCoinsEarned,
    required this.childCoinsEarned,
  });

  factory ParentChildBattle.fromJson(Map<String, dynamic> json) =>
      _$ParentChildBattleFromJson(json);

  Map<String, dynamic> toJson() => _$ParentChildBattleToJson(this);

  ParentChildBattle copyWith({
    String? battleId,
    String? parentId,
    String? childId,
    String? parentName,
    String? childName,
    String? phrase,
    String? phraseMeaning,
    int? parentScore,
    int? childScore,
    List<BattleRound>? rounds,
    DateTime? startedAt,
    DateTime? completedAt,
    String? winner,
    int? parentCoinsEarned,
    int? childCoinsEarned,
  }) {
    return ParentChildBattle(
      battleId: battleId ?? this.battleId,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      parentName: parentName ?? this.parentName,
      childName: childName ?? this.childName,
      phrase: phrase ?? this.phrase,
      phraseMeaning: phraseMeaning ?? this.phraseMeaning,
      parentScore: parentScore ?? this.parentScore,
      childScore: childScore ?? this.childScore,
      rounds: rounds ?? this.rounds,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      winner: winner ?? this.winner,
      parentCoinsEarned: parentCoinsEarned ?? this.parentCoinsEarned,
      childCoinsEarned: childCoinsEarned ?? this.childCoinsEarned,
    );
  }

  /// Score difference (positive = child winning, negative = parent winning)
  int get scoreDifference => childScore - parentScore;

  /// Is battle completed
  bool get isCompleted => completedAt != null;
}

/// Individual round in a battle
@JsonSerializable()
class BattleRound {
  final int roundNumber;
  final String pronunciationChallenge; // The phrase being tested
  final int parentScore; // 0-100
  final int childScore; // 0-100
  final String parentResponse; // Text from speech recognition
  final String childResponse; // Text from speech recognition
  final DateTime completedAt;

  const BattleRound({
    required this.roundNumber,
    required this.pronunciationChallenge,
    required this.parentScore,
    required this.childScore,
    required this.parentResponse,
    required this.childResponse,
    required this.completedAt,
  });

  factory BattleRound.fromJson(Map<String, dynamic> json) =>
      _$BattleRoundFromJson(json);

  Map<String, dynamic> toJson() => _$BattleRoundToJson(this);

  /// Winner of this round ('parent', 'child', or 'tie')
  String get roundWinner {
    if (parentScore > childScore) return 'parent';
    if (childScore > parentScore) return 'child';
    return 'tie';
  }
}

/// Weekly family battle league leaderboard
@JsonSerializable()
class WeeklyFamilyLeague {
  final String leagueId; // Week identifier (YYYY-W##)
  final int weekNumber;
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final List<FamilyLeagueEntry> standings; // Sorted by points

  const WeeklyFamilyLeague({
    required this.leagueId,
    required this.weekNumber,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.standings,
  });

  factory WeeklyFamilyLeague.fromJson(Map<String, dynamic> json) =>
      _$WeeklyFamilyLeagueFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyFamilyLeagueToJson(this);
}

/// Entry in family battle league
@JsonSerializable()
class FamilyLeagueEntry {
  final String familyId; // parent-child pair ID
  final String parentName;
  final String childName;
  final int rank; // 1st, 2nd, 3rd...
  final int weeklyBattles; // How many battles this week
  final int weeklyWins; // How many wins
  final int weeklyPoints; // Calculated from wins and scores
  final double winRate; // Percentage
  final List<int> dailyScores; // Score history (7 days)

  const FamilyLeagueEntry({
    required this.familyId,
    required this.parentName,
    required this.childName,
    required this.rank,
    required this.weeklyBattles,
    required this.weeklyWins,
    required this.weeklyPoints,
    required this.winRate,
    required this.dailyScores,
  });

  factory FamilyLeagueEntry.fromJson(Map<String, dynamic> json) =>
      _$FamilyLeagueEntryFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyLeagueEntryToJson(this);
}

/// Parent-focused subscription/pass
@JsonSerializable()
class ParentBattlePass {
  final String passId;
  final String parentId;
  final String passType; // 'weekly_unlimited', 'monthly_unlimited', 'premium_features'
  final int maxBattlesPerWeek; // -1 for unlimited
  final bool unlimitedReplay; // Can replay same phrase
  final bool premiumPrizes; // Access to special rewards
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final int costCoins;
  final String renewalStatus; // 'active', 'expired', 'cancelled'

  const ParentBattlePass({
    required this.passId,
    required this.parentId,
    required this.passType,
    required this.maxBattlesPerWeek,
    required this.unlimitedReplay,
    required this.premiumPrizes,
    required this.purchasedAt,
    required this.expiresAt,
    required this.costCoins,
    required this.renewalStatus,
  });

  factory ParentBattlePass.fromJson(Map<String, dynamic> json) =>
      _$ParentBattlePassFromJson(json);

  Map<String, dynamic> toJson() => _$ParentBattlePassToJson(this);

  /// Check if pass is currently active
  bool get isActive => DateTime.now().isBefore(expiresAt) && renewalStatus == 'active';
  
  /// Days remaining until expiry
  int get daysRemaining => expiresAt.difference(DateTime.now()).inDays;
}

/// Parent-child battle statistics
@JsonSerializable()
class ParentChildBattleStats {
  final String familyId; // parent-child pair
  final int totalBattles;
  final int parentWins;
  final int childWins;
  final int ties;
  final double parentWinRate;
  final double childWinRate;
  final double averageParentScore;
  final double averageChildScore;
  final DateTime lastBattleAt;
  final List<ParentChildBattle> recentBattles; // Last 5 battles

  const ParentChildBattleStats({
    required this.familyId,
    required this.totalBattles,
    required this.parentWins,
    required this.childWins,
    required this.ties,
    required this.parentWinRate,
    required this.childWinRate,
    required this.averageParentScore,
    required this.averageChildScore,
    required this.lastBattleAt,
    required this.recentBattles,
  });

  factory ParentChildBattleStats.fromJson(Map<String, dynamic> json) =>
      _$ParentChildBattleStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ParentChildBattleStatsToJson(this);
}

/// Achievement for family battles
@JsonSerializable()
class FamilyBattleAchievement {
  final String achievementId;
  final String title;
  final String description;
  final String icon; // Emoji
  final String type; // 'parent', 'child', or 'family'
  final int targetCount; // What they need to achieve
  final int currentCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int rewardCoins;

  const FamilyBattleAchievement({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetCount,
    required this.currentCount,
    required this.isUnlocked,
    required this.unlockedAt,
    required this.rewardCoins,
  });

  factory FamilyBattleAchievement.fromJson(Map<String, dynamic> json) =>
      _$FamilyBattleAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyBattleAchievementToJson(this);

  /// Progress as percentage (0-100)
  double get progress => (currentCount / targetCount * 100).clamp(0, 100);
}
