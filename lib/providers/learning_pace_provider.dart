import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/learning_pace_model.dart';
import 'progress_provider.dart';
import 'study_time_provider.dart';

final learningPaceProvider = FutureProvider.autoDispose<LearningPaceRecommendation?>((ref) async {
  final progress = ref.watch(progressProvider);
  final studyTime = ref.watch(studyTimeProvider);

  // 学習分析データを構築
  final analytics = StudyAnalytics(
    totalSessions: progress.totalLessons + progress.totalSpeakingPractice,
    averageSessionDuration: studyTime.dailyAverage > 0
        ? Duration(minutes: (studyTime.monthlyTotal ~/ (studyTime.dailyAverage / 60)).toInt())
        : const Duration(minutes: 15),
    studyHoursDistribution: _buildHoursDistribution(progress),
    dayOfWeekDistribution: _buildDaysDistribution(progress),
    averageAccuracy: 0.75, // デモ用
    completionRate: 0.85,
    streakDays: progress.streakDays,
    lastStudyTime: DateTime.now(),
  );

  return _recommendPace(analytics);
});

/// 推奨ペースを生成
LearningPaceRecommendation _recommendPace(StudyAnalytics analytics) {
  final activeHour = analytics.getMostActiveHour() ?? 19; // デフォルト19時
  final streakDays = analytics.streakDays;

  // ペースレベルの決定
  String paceLevel = 'normal';
  String reason = '';
  List<String> tips = [];
  int confidence = 75;

  if (streakDays >= 20) {
    paceLevel = 'fast';
    reason = '継続的な学習習慣が見られるため、高速ペースを推奨します';
    tips = [
      '💪 素晴らしい継続力です！',
      '🎯 さらに難しい問題に挑戦してみてください',
      '⏰ 1日40分の学習を目指しましょう',
    ];
    confidence = 85;
  } else if (streakDays >= 7) {
    paceLevel = 'normal';
    reason = '良好な学習習慣が形成されているため、標準ペースを推奨します';
    tips = [
      '✨ 1週間の連続学習、お疲れ様です！',
      '📈 1日15-20分の学習がちょうどいいペースです',
      '🎉 このペースを続けられています',
    ];
    confidence = 80;
  } else {
    paceLevel = 'slow';
    reason = '学習を始めたばかり、または習慣構築中のため、ゆっくりペースを推奨します';
    tips = [
      '👋 まずは毎日5-10分の学習から始めましょう',
      '🌱 短くても毎日続けることが大切です',
      '⭐ 継続は力なり。焦らず進めましょう',
    ];
    confidence = 70;
  }

  // 推奨開始時刻
  final recommendedStartHour = (activeHour >= 6 && activeHour <= 22) ? activeHour : 19;
  final recommendedStartTime = DateTime.now().copyWith(
    hour: recommendedStartHour,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );

  // ペースレベル設定から情報を取得
  final config = paceLevelConfigs[paceLevel]!;

  return LearningPaceRecommendation(
    userId: 'current_user',
    recommendedStartTime: recommendedStartTime,
    recommendedDuration: config.sessionDuration,
    dailyGoal: config.dailyGoal,
    paceLevel: paceLevel,
    reason: reason,
    tips: tips,
    confidenceScore: confidence,
  );
}

/// 時間帯別分布を構築
List<int> _buildHoursDistribution(ProgressState progress) {
  // シンプルなデモ用分布
  final distribution = List<int>.filled(24, 0);
  // 朝 (6-8時), 昼 (12-14時), 夜 (19-21時) をピークに
  distribution[7] = 5;
  distribution[13] = 8;
  distribution[19] = 10;
  distribution[20] = 8;
  return distribution;
}

/// 曜日別分布を構築
List<int> _buildDaysDistribution(ProgressState progress) {
  // シンプルなデモ用分布 (月-日)
  return [5, 6, 4, 7, 5, 8, 6]; // 金土が高い
}

/// ユーザーの学習ペース設定を管理
final userPacePreferenceProvider =
    StateNotifierProvider<UserPacePreferenceNotifier, UserPacePreference>((ref) {
  return UserPacePreferenceNotifier();
});

class UserPacePreference {
  final String preferredPaceLevel; // slow, normal, fast
  final int preferredStartHour;
  final int preferredStartMinute;
  final bool autoNotificationEnabled;
  final DateTime? lastUpdated;

  const UserPacePreference({
    this.preferredPaceLevel = 'normal',
    this.preferredStartHour = 19,
    this.preferredStartMinute = 0,
    this.autoNotificationEnabled = true,
    this.lastUpdated,
  });

  factory UserPacePreference.fromJson(Map<String, dynamic> json) {
    return UserPacePreference(
      preferredPaceLevel: json['preferredPaceLevel'] as String? ?? 'normal',
      preferredStartHour: json['preferredStartHour'] as int? ?? 19,
      preferredStartMinute: json['preferredStartMinute'] as int? ?? 0,
      autoNotificationEnabled: json['autoNotificationEnabled'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'preferredPaceLevel': preferredPaceLevel,
    'preferredStartHour': preferredStartHour,
    'preferredStartMinute': preferredStartMinute,
    'autoNotificationEnabled': autoNotificationEnabled,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };
}

class UserPacePreferenceNotifier extends StateNotifier<UserPacePreference> {
  static const String _storageKey = 'eigo_kore_pace_preference';

  UserPacePreferenceNotifier() : super(const UserPacePreference()) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      state = UserPacePreference.fromJson(json);
    }
  }

  Future<void> _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  Future<void> updatePaceLevel(String paceLevel) async {
    state = state.copyWith(
      preferredPaceLevel: paceLevel,
      lastUpdated: DateTime.now(),
    );
    await _savePreference();
  }

  Future<void> updateStartTime(int hour, int minute) async {
    state = state.copyWith(
      preferredStartHour: hour,
      preferredStartMinute: minute,
      lastUpdated: DateTime.now(),
    );
    await _savePreference();
  }

  Future<void> toggleNotification(bool enabled) async {
    state = state.copyWith(
      autoNotificationEnabled: enabled,
      lastUpdated: DateTime.now(),
    );
    await _savePreference();
  }

  UserPacePreference copyWith({
    String? preferredPaceLevel,
    int? preferredStartHour,
    int? preferredStartMinute,
    bool? autoNotificationEnabled,
    DateTime? lastUpdated,
  }) {
    return UserPacePreference(
      preferredPaceLevel: preferredPaceLevel ?? state.preferredPaceLevel,
      preferredStartHour: preferredStartHour ?? state.preferredStartHour,
      preferredStartMinute: preferredStartMinute ?? state.preferredStartMinute,
      autoNotificationEnabled: autoNotificationEnabled ?? state.autoNotificationEnabled,
      lastUpdated: lastUpdated ?? state.lastUpdated,
    );
  }
}
