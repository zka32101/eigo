import 'package:cloud_firestore/cloud_firestore.dart';

// ===== Enums =====

/// Leaderboard grouping types
enum LeaderboardGroupType {
  overall,      // All users globally
  byGrade,      // Separate by grade level
  byStartMonth, // Separate by cohort month
  combined,     // Grade × Start month combinations
}

// ===== Leaderboard Entry =====

/// Single entry in a leaderboard ranking
class LeaderboardEntry {
  final String userId;
  final String userName;
  final int rank;
  final int totalXp;
  final int achievementScore;
  final int level;
  final int grade;
  final DateTime startDate;
  final int streak;
  final DateTime lastActivityAt;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.totalXp,
    required this.achievementScore,
    required this.level,
    required this.grade,
    required this.startDate,
    required this.streak,
    required this.lastActivityAt,
  });

  /// Calculate combined score (70% XP + 30% Achievements)
  double getScore() {
    return (totalXp * 0.7) + (achievementScore * 0.3);
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'rank': rank,
      'totalXp': totalXp,
      'achievementScore': achievementScore,
      'level': level,
      'grade': grade,
      'startDate': Timestamp.fromDate(startDate),
      'streak': streak,
      'score': getScore(),
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
    };
  }

  /// Create from Firestore document
  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      rank: data['rank'] as int,
      totalXp: data['totalXp'] as int,
      achievementScore: data['achievementScore'] as int,
      level: data['level'] as int,
      grade: data['grade'] as int,
      startDate: (data['startDate'] as Timestamp).toDate(),
      streak: data['streak'] as int,
      lastActivityAt: (data['lastActivityAt'] as Timestamp).toDate(),
    );
  }

  LeaderboardEntry copyWith({
    String? userId,
    String? userName,
    int? rank,
    int? totalXp,
    int? achievementScore,
    int? level,
    int? grade,
    DateTime? startDate,
    int? streak,
    DateTime? lastActivityAt,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rank: rank ?? this.rank,
      totalXp: totalXp ?? this.totalXp,
      achievementScore: achievementScore ?? this.achievementScore,
      level: level ?? this.level,
      grade: grade ?? this.grade,
      startDate: startDate ?? this.startDate,
      streak: streak ?? this.streak,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

// ===== Grouped Leaderboard =====

/// Leaderboard for a specific grouping
class GroupedLeaderboard {
  final LeaderboardGroupType groupType;
  final String groupName;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final DateTime updatedAt;

  const GroupedLeaderboard({
    required this.groupType,
    required this.groupName,
    required this.entries,
    this.currentUserEntry,
    required this.updatedAt,
  });

  /// Get top score in this leaderboard
  double get topScore => entries.isNotEmpty ? entries.first.getScore() : 0;

  /// Get user's rank position (1-based)
  int? getUserRank(String userId) {
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].userId == userId) {
        return i + 1;
      }
    }
    return null;
  }

  /// Get number of entries
  int get entryCount => entries.length;

  /// Check if user is in top 10
  bool isUserInTop10(String userId) {
    final rank = getUserRank(userId);
    return rank != null && rank <= 10;
  }

  GroupedLeaderboard copyWith({
    LeaderboardGroupType? groupType,
    String? groupName,
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? currentUserEntry,
    DateTime? updatedAt,
  }) {
    return GroupedLeaderboard(
      groupType: groupType ?? this.groupType,
      groupName: groupName ?? this.groupName,
      entries: entries ?? this.entries,
      currentUserEntry: currentUserEntry ?? this.currentUserEntry,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ===== Grade Information =====

/// Grade promotion record
class GradePromotion {
  final DateTime promotionDate;
  final int previousGrade;
  final int newGrade;
  final String reason;
  final String? performedBy;

  const GradePromotion({
    required this.promotionDate,
    required this.previousGrade,
    required this.newGrade,
    required this.reason,
    this.performedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'promotionDate': Timestamp.fromDate(promotionDate),
      'previousGrade': previousGrade,
      'newGrade': newGrade,
      'reason': reason,
      'performedBy': performedBy,
    };
  }

  factory GradePromotion.fromMap(Map<String, dynamic> map) {
    return GradePromotion(
      promotionDate: (map['promotionDate'] as Timestamp).toDate(),
      previousGrade: map['previousGrade'] as int,
      newGrade: map['newGrade'] as int,
      reason: map['reason'] as String,
      performedBy: map['performedBy'] as String?,
    );
  }
}

/// User grade information and history
class UserGradeInfo {
  final String userId;
  final int currentGrade;
  final DateTime startDate;
  final List<GradePromotion> promotionHistory;
  final DateTime? nextPromotionDate;

  const UserGradeInfo({
    required this.userId,
    required this.currentGrade,
    required this.startDate,
    required this.promotionHistory,
    this.nextPromotionDate,
  });

  bool canPromote(int maxGrade) => currentGrade < maxGrade;

  bool shouldPromoteToday(DateTime today) {
    if (nextPromotionDate == null) return false;
    return today.year > nextPromotionDate!.year ||
        (today.year == nextPromotionDate!.year &&
            today.month == nextPromotionDate!.month &&
            today.day >= nextPromotionDate!.day);
  }

  GradePromotion? get lastPromotion =>
      promotionHistory.isNotEmpty ? promotionHistory.first : null;

  int? getDaysUntilPromotion(DateTime now) {
    if (nextPromotionDate == null) return null;
    return nextPromotionDate!.difference(now).inDays;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'currentGrade': currentGrade,
      'startDate': Timestamp.fromDate(startDate),
      'promotionHistory': promotionHistory.map((p) => p.toMap()).toList(),
      'nextPromotionDate': nextPromotionDate != null
          ? Timestamp.fromDate(nextPromotionDate!)
          : null,
    };
  }

  factory UserGradeInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserGradeInfo(
      userId: doc.id,
      currentGrade: data['currentGrade'] as int,
      startDate: (data['startDate'] as Timestamp).toDate(),
      promotionHistory: (data['promotionHistory'] as List<dynamic>?)
              ?.map((p) => GradePromotion.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      nextPromotionDate: data['nextPromotionDate'] != null
          ? (data['nextPromotionDate'] as Timestamp).toDate()
          : null,
    );
  }

  UserGradeInfo copyWith({
    String? userId,
    int? currentGrade,
    DateTime? startDate,
    List<GradePromotion>? promotionHistory,
    DateTime? nextPromotionDate,
  }) {
    return UserGradeInfo(
      userId: userId ?? this.userId,
      currentGrade: currentGrade ?? this.currentGrade,
      startDate: startDate ?? this.startDate,
      promotionHistory: promotionHistory ?? this.promotionHistory,
      nextPromotionDate: nextPromotionDate ?? this.nextPromotionDate,
    );
  }
}

/// Global grade promotion configuration
class GradePromotionConfig {
  final String promotionDateStr;
  final bool isEnabled;
  final int maxGrade;
  final DateTime? lastCheckDate;

  const GradePromotionConfig({
    required this.promotionDateStr,
    required this.isEnabled,
    required this.maxGrade,
    this.lastCheckDate,
  });

  DateTime nextPromotionDate(DateTime currentDate) {
    final parts = promotionDateStr.split('-');
    final promotionMonth = int.parse(parts[0]);
    final promotionDay = int.parse(parts[1]);

    final current = DateTime(currentDate.year, promotionMonth, promotionDay);
    if (currentDate.isBefore(current)) {
      return current;
    } else {
      return DateTime(currentDate.year + 1, promotionMonth, promotionDay);
    }
  }

  bool shouldPromoteToday(DateTime today) {
    if (!isEnabled) return false;
    final parts = promotionDateStr.split('-');
    final promotionMonth = int.parse(parts[0]);
    final promotionDay = int.parse(parts[1]);

    return today.month == promotionMonth && today.day == promotionDay;
  }

  bool isPromotionDay(DateTime date) {
    final parts = promotionDateStr.split('-');
    final promotionMonth = int.parse(parts[0]);
    final promotionDay = int.parse(parts[1]);

    return date.month == promotionMonth && date.day == promotionDay;
  }

  Map<String, dynamic> toMap() {
    return {
      'promotionDateStr': promotionDateStr,
      'isEnabled': isEnabled,
      'maxGrade': maxGrade,
      'lastCheckDate':
          lastCheckDate != null ? Timestamp.fromDate(lastCheckDate!) : null,
    };
  }

  factory GradePromotionConfig.fromMap(Map<String, dynamic> map) {
    return GradePromotionConfig(
      promotionDateStr: map['promotionDateStr'] as String,
      isEnabled: map['isEnabled'] as bool? ?? true,
      maxGrade: map['maxGrade'] as int? ?? 6,
      lastCheckDate: map['lastCheckDate'] != null
          ? (map['lastCheckDate'] as Timestamp).toDate()
          : null,
    );
  }

  GradePromotionConfig copyWith({
    String? promotionDateStr,
    bool? isEnabled,
    int? maxGrade,
    DateTime? lastCheckDate,
  }) {
    return GradePromotionConfig(
      promotionDateStr: promotionDateStr ?? this.promotionDateStr,
      isEnabled: isEnabled ?? this.isEnabled,
      maxGrade: maxGrade ?? this.maxGrade,
      lastCheckDate: lastCheckDate ?? this.lastCheckDate,
    );
  }
}
