import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyTimeState {
  final int todaySeconds; // 今日の学習時間（秒）
  final DateTime lastSessionStart;
  final bool isSessionActive;

  const StudyTimeState({
    this.todaySeconds = 0,
    required this.lastSessionStart,
    this.isSessionActive = false,
  });

  String get todayDisplay {
    final minutes = todaySeconds ~/ 60;
    final seconds = todaySeconds % 60;
    if (minutes == 0) return '${seconds}秒';
    return '${minutes}分${seconds}秒';
  }

  StudyTimeState copyWith({
    int? todaySeconds,
    DateTime? lastSessionStart,
    bool? isSessionActive,
  }) {
    return StudyTimeState(
      todaySeconds: todaySeconds ?? this.todaySeconds,
      lastSessionStart: lastSessionStart ?? this.lastSessionStart,
      isSessionActive: isSessionActive ?? this.isSessionActive,
    );
  }
}

class StudyTimeNotifier extends StateNotifier<StudyTimeState> {
  StudyTimeNotifier() : super(StudyTimeState(lastSessionStart: DateTime.now())) {
    _load();
  }

  static const _todaySecondsKey = 'study_time_today_seconds';
  static const _lastDateKey = 'study_time_last_date';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastDateStr = prefs.getString(_lastDateKey);

    int todaySeconds = 0;
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      // 同じ日付なら前回の記録を復元
      if (lastDate.year == today.year && lastDate.month == today.month && lastDate.day == today.day) {
        todaySeconds = prefs.getInt(_todaySecondsKey) ?? 0;
      }
    }

    state = state.copyWith(todaySeconds: todaySeconds);
  }

  Future<void> addStudyTime(int seconds) async {
    final newTotal = state.todaySeconds + seconds;
    state = state.copyWith(todaySeconds: newTotal);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todaySecondsKey, newTotal);
    await prefs.setString(_lastDateKey, DateTime.now().toIso8601String());
  }

  void startSession() {
    state = state.copyWith(
      lastSessionStart: DateTime.now(),
      isSessionActive: true,
    );
  }

  Future<void> endSession() async {
    if (!state.isSessionActive) return;

    final elapsed = DateTime.now().difference(state.lastSessionStart).inSeconds;
    await addStudyTime(elapsed);

    state = state.copyWith(isSessionActive: false);
  }

  Future<void> resetToday() async {
    state = state.copyWith(todaySeconds: 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todaySecondsKey, 0);
  }
}

final studyTimeProvider = StateNotifierProvider<StudyTimeNotifier, StudyTimeState>(
  (ref) => StudyTimeNotifier(),
);
