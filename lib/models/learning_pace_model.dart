/// 学習ペース推奨モデル
class LearningPaceRecommendation {
  final String userId;
  final DateTime recommendedStartTime; // 推奨開始時刻
  final Duration recommendedDuration; // 推奨学習時間
  final int dailyGoal; // 1日の目標問題数
  final String paceLevel; // fast, normal, slow
  final String reason; // 推奨理由
  final List<String> tips; // アドバイス
  final int confidenceScore; // 信頼度スコア (0-100)

  const LearningPaceRecommendation({
    required this.userId,
    required this.recommendedStartTime,
    required this.recommendedDuration,
    required this.dailyGoal,
    required this.paceLevel,
    required this.reason,
    required this.tips,
    required this.confidenceScore,
  });

  factory LearningPaceRecommendation.fromJson(Map<String, dynamic> json) {
    return LearningPaceRecommendation(
      userId: json['userId'] as String,
      recommendedStartTime: DateTime.parse(json['recommendedStartTime'] as String),
      recommendedDuration: Duration(minutes: json['recommendedDurationMinutes'] as int),
      dailyGoal: json['dailyGoal'] as int,
      paceLevel: json['paceLevel'] as String,
      reason: json['reason'] as String,
      tips: List<String>.from(json['tips'] as List? ?? []),
      confidenceScore: json['confidenceScore'] as int? ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'recommendedStartTime': recommendedStartTime.toIso8601String(),
    'recommendedDurationMinutes': recommendedDuration.inMinutes,
    'dailyGoal': dailyGoal,
    'paceLevel': paceLevel,
    'reason': reason,
    'tips': tips,
    'confidenceScore': confidenceScore,
  };
}

/// 学習分析データ
class StudyAnalytics {
  final int totalSessions; // 総セッション数
  final Duration averageSessionDuration; // 平均セッション時間
  final List<int> studyHoursDistribution; // 時間帯別の学習数 (0-23)
  final List<int> dayOfWeekDistribution; // 曜日別の学習数 (0-6)
  final double averageAccuracy; // 平均正答率
  final double completionRate; // 完了率
  final int streakDays; // 連続学習日数
  final DateTime lastStudyTime; // 最後の学習時刻

  const StudyAnalytics({
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.studyHoursDistribution,
    required this.dayOfWeekDistribution,
    required this.averageAccuracy,
    required this.completionRate,
    required this.streakDays,
    required this.lastStudyTime,
  });

  factory StudyAnalytics.fromJson(Map<String, dynamic> json) {
    return StudyAnalytics(
      totalSessions: json['totalSessions'] as int? ?? 0,
      averageSessionDuration: Duration(
        minutes: json['averageSessionDurationMinutes'] as int? ?? 15,
      ),
      studyHoursDistribution: List<int>.from(
        json['studyHoursDistribution'] as List? ?? List<int>.filled(24, 0),
      ),
      dayOfWeekDistribution: List<int>.from(
        json['dayOfWeekDistribution'] as List? ?? List<int>.filled(7, 0),
      ),
      averageAccuracy: json['averageAccuracy'] as double? ?? 0.7,
      completionRate: json['completionRate'] as double? ?? 0.8,
      streakDays: json['streakDays'] as int? ?? 0,
      lastStudyTime: DateTime.parse(
        json['lastStudyTime'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalSessions': totalSessions,
    'averageSessionDurationMinutes': averageSessionDuration.inMinutes,
    'studyHoursDistribution': studyHoursDistribution,
    'dayOfWeekDistribution': dayOfWeekDistribution,
    'averageAccuracy': averageAccuracy,
    'completionRate': completionRate,
    'streakDays': streakDays,
    'lastStudyTime': lastStudyTime.toIso8601String(),
  };

  /// 最も活発な学習時間帯を取得 (0-23)
  int? getMostActiveHour() {
    if (studyHoursDistribution.isEmpty) return null;
    var maxIndex = 0;
    for (var i = 1; i < studyHoursDistribution.length; i++) {
      if (studyHoursDistribution[i] > studyHoursDistribution[maxIndex]) {
        maxIndex = i;
      }
    }
    return studyHoursDistribution[maxIndex] > 0 ? maxIndex : null;
  }

  /// 最も活発な曜日を取得 (0=Monday, 6=Sunday)
  int? getMostActiveDay() {
    if (dayOfWeekDistribution.isEmpty) return null;
    var maxIndex = 0;
    for (var i = 1; i < dayOfWeekDistribution.length; i++) {
      if (dayOfWeekDistribution[i] > dayOfWeekDistribution[maxIndex]) {
        maxIndex = i;
      }
    }
    return dayOfWeekDistribution[maxIndex] > 0 ? maxIndex : null;
  }
}

/// ペースレベル別の推奨値
class PaceLevelConfig {
  final String level;
  final int dailyGoal;
  final Duration sessionDuration;
  final int sessionsPerDay;

  const PaceLevelConfig({
    required this.level,
    required this.dailyGoal,
    required this.sessionDuration,
    required this.sessionsPerDay,
  });
}

/// ペースレベル設定
final Map<String, PaceLevelConfig> paceLevelConfigs = {
  'slow': const PaceLevelConfig(
    level: 'slow',
    dailyGoal: 5,
    sessionDuration: Duration(minutes: 10),
    sessionsPerDay: 1,
  ),
  'normal': const PaceLevelConfig(
    level: 'normal',
    dailyGoal: 15,
    sessionDuration: Duration(minutes: 20),
    sessionsPerDay: 2,
  ),
  'fast': const PaceLevelConfig(
    level: 'fast',
    dailyGoal: 30,
    sessionDuration: Duration(minutes: 40),
    sessionsPerDay: 3,
  ),
};
