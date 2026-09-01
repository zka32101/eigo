class DailyStats {
  final String date; // YYYY-MM-DD
  final int questsCompleted;
  final int correctAnswers;
  final int totalAnswers;
  final int coinsEarned;
  final int studyMinutes;
  final Map<String, dynamic> categoryStats; // {categoryId: {correct, total}}

  const DailyStats({
    required this.date,
    required this.questsCompleted,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.coinsEarned,
    required this.studyMinutes,
    required this.categoryStats,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
        date: json['date'] as String,
        questsCompleted: json['questsCompleted'] as int,
        correctAnswers: json['correctAnswers'] as int,
        totalAnswers: json['totalAnswers'] as int,
        coinsEarned: json['coinsEarned'] as int,
        studyMinutes: json['studyMinutes'] as int,
        categoryStats: Map<String, dynamic>.from(json['categoryStats'] as Map),
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'questsCompleted': questsCompleted,
        'correctAnswers': correctAnswers,
        'totalAnswers': totalAnswers,
        'coinsEarned': coinsEarned,
        'studyMinutes': studyMinutes,
        'categoryStats': categoryStats,
      };
}

class MonthlyStats {
  final String month; // YYYY-MM
  final int totalQuestsCompleted;
  final int totalCorrectAnswers;
  final int totalAnswers;
  final double accuracyRate; // 0.0 ~ 1.0
  final int totalStudyMinutes;
  final int totalCoinsEarned;
  final int studyDaysCount; // 学習した日数
  final Map<String, dynamic> categoryStats; // {categoryId: {correct, total, accuracy}}

  const MonthlyStats({
    required this.month,
    required this.totalQuestsCompleted,
    required this.totalCorrectAnswers,
    required this.totalAnswers,
    required this.accuracyRate,
    required this.totalStudyMinutes,
    required this.totalCoinsEarned,
    required this.studyDaysCount,
    required this.categoryStats,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) => MonthlyStats(
        month: json['month'] as String,
        totalQuestsCompleted: json['totalQuestsCompleted'] as int,
        totalCorrectAnswers: json['totalCorrectAnswers'] as int,
        totalAnswers: json['totalAnswers'] as int,
        accuracyRate: (json['accuracyRate'] as num).toDouble(),
        totalStudyMinutes: json['totalStudyMinutes'] as int,
        totalCoinsEarned: json['totalCoinsEarned'] as int,
        studyDaysCount: json['studyDaysCount'] as int,
        categoryStats: Map<String, dynamic>.from(json['categoryStats'] as Map),
      );

  Map<String, dynamic> toJson() => {
        'month': month,
        'totalQuestsCompleted': totalQuestsCompleted,
        'totalCorrectAnswers': totalCorrectAnswers,
        'totalAnswers': totalAnswers,
        'accuracyRate': accuracyRate,
        'totalStudyMinutes': totalStudyMinutes,
        'totalCoinsEarned': totalCoinsEarned,
        'studyDaysCount': studyDaysCount,
        'categoryStats': categoryStats,
      };

  double get accuracyPercentage => accuracyRate * 100;
}

/// 週間レポート
class WeeklyReport {
  final DateTime weekStartDate;
  final int totalMinutesStudied;
  final int totalLessonsCompleted;
  final int totalCoinsEarned;
  final int averageMinutesPerDay;
  final int daysActive;
  final List<DailyStudyRecord> dailyRecords;
  final List<String> topTopics;
  final bool weeklyGoalAchieved;

  const WeeklyReport({
    required this.weekStartDate,
    required this.totalMinutesStudied,
    required this.totalLessonsCompleted,
    required this.totalCoinsEarned,
    required this.averageMinutesPerDay,
    required this.daysActive,
    required this.dailyRecords,
    this.topTopics = const [],
    this.weeklyGoalAchieved = false,
  });

  Map<String, dynamic> toJson() => {
        'weekStartDate': weekStartDate.toIso8601String(),
        'totalMinutesStudied': totalMinutesStudied,
        'totalLessonsCompleted': totalLessonsCompleted,
        'totalCoinsEarned': totalCoinsEarned,
        'averageMinutesPerDay': averageMinutesPerDay,
        'daysActive': daysActive,
        'dailyRecords': dailyRecords.map((r) => r.toJson()).toList(),
        'topTopics': topTopics,
        'weeklyGoalAchieved': weeklyGoalAchieved,
      };

  factory WeeklyReport.fromJson(Map<String, dynamic> json) => WeeklyReport(
        weekStartDate: DateTime.parse(json['weekStartDate'] as String),
        totalMinutesStudied: json['totalMinutesStudied'] as int,
        totalLessonsCompleted: json['totalLessonsCompleted'] as int,
        totalCoinsEarned: json['totalCoinsEarned'] as int,
        averageMinutesPerDay: json['averageMinutesPerDay'] as int,
        daysActive: json['daysActive'] as int,
        dailyRecords: (json['dailyRecords'] as List<dynamic>)
            .map((r) => DailyStudyRecord.fromJson(r as Map<String, dynamic>))
            .toList(),
        topTopics: List<String>.from(json['topTopics'] as List? ?? []),
        weeklyGoalAchieved: json['weeklyGoalAchieved'] as bool? ?? false,
      );
}

/// 日次学習データ
class DailyStudyRecord {
  final DateTime date;
  final int minutesStudied;
  final int lessonsCompleted;
  final int coinsEarned;
  final bool streakMaintained;
  final List<String> topicsStudied;

  const DailyStudyRecord({
    required this.date,
    required this.minutesStudied,
    required this.lessonsCompleted,
    required this.coinsEarned,
    required this.streakMaintained,
    this.topicsStudied = const [],
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'minutesStudied': minutesStudied,
        'lessonsCompleted': lessonsCompleted,
        'coinsEarned': coinsEarned,
        'streakMaintained': streakMaintained,
        'topicsStudied': topicsStudied,
      };

  factory DailyStudyRecord.fromJson(Map<String, dynamic> json) =>
      DailyStudyRecord(
        date: DateTime.parse(json['date'] as String),
        minutesStudied: json['minutesStudied'] as int,
        lessonsCompleted: json['lessonsCompleted'] as int,
        coinsEarned: json['coinsEarned'] as int,
        streakMaintained: json['streakMaintained'] as bool,
        topicsStudied: List<String>.from(json['topicsStudied'] as List? ?? []),
      );
}

/// 学習進度統計
class LearningProgressStats {
  final int totalLessonsCompleted;
  final int totalMinutesStudied;
  final int currentLevel;
  final double levelProgress; // 0.0 - 1.0
  final int totalCoinsEarned;
  final int currentStreak;
  final int longestStreak;
  final double accuracyRate; // 0.0 - 100.0
  final List<String> completedTopics;

  const LearningProgressStats({
    required this.totalLessonsCompleted,
    required this.totalMinutesStudied,
    required this.currentLevel,
    required this.levelProgress,
    required this.totalCoinsEarned,
    required this.currentStreak,
    required this.longestStreak,
    required this.accuracyRate,
    this.completedTopics = const [],
  });

  Map<String, dynamic> toJson() => {
        'totalLessonsCompleted': totalLessonsCompleted,
        'totalMinutesStudied': totalMinutesStudied,
        'currentLevel': currentLevel,
        'levelProgress': levelProgress,
        'totalCoinsEarned': totalCoinsEarned,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'accuracyRate': accuracyRate,
        'completedTopics': completedTopics,
      };

  factory LearningProgressStats.fromJson(Map<String, dynamic> json) =>
      LearningProgressStats(
        totalLessonsCompleted: json['totalLessonsCompleted'] as int,
        totalMinutesStudied: json['totalMinutesStudied'] as int,
        currentLevel: json['currentLevel'] as int,
        levelProgress: (json['levelProgress'] as num).toDouble(),
        totalCoinsEarned: json['totalCoinsEarned'] as int,
        currentStreak: json['currentStreak'] as int,
        longestStreak: json['longestStreak'] as int,
        accuracyRate: (json['accuracyRate'] as num).toDouble(),
        completedTopics: List<String>.from(json['completedTopics'] as List? ?? []),
      );
}

/// 勉強成果ログ
class AchievementLog {
  final String achievementId;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final int rarity; // 1-5, 5 = 最もレア

  const AchievementLog({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.rarity,
  });

  Map<String, dynamic> toJson() => {
        'achievementId': achievementId,
        'title': title,
        'description': description,
        'icon': icon,
        'unlockedAt': unlockedAt.toIso8601String(),
        'rarity': rarity,
      };

  factory AchievementLog.fromJson(Map<String, dynamic> json) =>
      AchievementLog(
        achievementId: json['achievementId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        unlockedAt: DateTime.parse(json['unlockedAt'] as String),
        rarity: json['rarity'] as int,
      );
}
