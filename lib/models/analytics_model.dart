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
