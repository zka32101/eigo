import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailySpeakingRecord {
  final DateTime date;
  final int wordCount;
  final int phraseCount;
  final int conversationCount;
  final double avgScore;

  const DailySpeakingRecord({
    required this.date,
    required this.wordCount,
    required this.phraseCount,
    required this.conversationCount,
    required this.avgScore,
  });

  int get totalCount => wordCount + phraseCount + conversationCount;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'wordCount': wordCount,
    'phraseCount': phraseCount,
    'conversationCount': conversationCount,
    'avgScore': avgScore,
  };

  factory DailySpeakingRecord.fromJson(Map<String, dynamic> j) => DailySpeakingRecord(
    date: DateTime.parse(j['date'] as String),
    wordCount: (j['wordCount'] as num).toInt(),
    phraseCount: (j['phraseCount'] as num).toInt(),
    conversationCount: (j['conversationCount'] as num).toInt(),
    avgScore: (j['avgScore'] as num).toDouble(),
  );
}

class SpeakingHistoryState {
  final List<DailySpeakingRecord> records; // 最新30日分

  const SpeakingHistoryState({this.records = const []});

  // 今週のレコード（直近7日）
  List<DailySpeakingRecord> get thisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return records.where((r) => r.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // 今週の平均スピーキングスコア
  double get weeklyAvgScore {
    final week = thisWeek;
    if (week.isEmpty) return 0;
    return week.map((r) => r.avgScore).reduce((a, b) => a + b) / week.length;
  }

  // 先週比
  double get scoreImprovement {
    final thisWeekRecords = thisWeek;
    final lastWeekCutoff = DateTime.now().subtract(const Duration(days: 14));
    final thisWeekCutoff = DateTime.now().subtract(const Duration(days: 7));
    final lastWeekRecords = records
        .where((r) => r.date.isAfter(lastWeekCutoff) && r.date.isBefore(thisWeekCutoff))
        .toList();

    if (thisWeekRecords.isEmpty || lastWeekRecords.isEmpty) return 0;
    final thisAvg = thisWeekRecords.map((r) => r.avgScore).reduce((a, b) => a + b) / thisWeekRecords.length;
    final lastAvg = lastWeekRecords.map((r) => r.avgScore).reduce((a, b) => a + b) / lastWeekRecords.length;
    return thisAvg - lastAvg;
  }

  // 今週の単語練習数
  int get weeklyWordCount => thisWeek.fold(0, (sum, r) => sum + r.wordCount);
  int get weeklyPhraseCount => thisWeek.fold(0, (sum, r) => sum + r.phraseCount);
  int get weeklyConversationCount => thisWeek.fold(0, (sum, r) => sum + r.conversationCount);
}

class SpeakingHistoryNotifier extends StateNotifier<SpeakingHistoryState> {
  SpeakingHistoryNotifier() : super(const SpeakingHistoryState()) {
    _load();
  }

  static const _key = 'speaking_history';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) { _initDemoData(); return; }
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => DailySpeakingRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      state = SpeakingHistoryState(records: list);
    } catch (_) {
      _initDemoData();
    }
  }

  // デモデータ（初回起動時）
  void _initDemoData() {
    final now = DateTime.now();
    final demo = List.generate(14, (i) {
      final date = now.subtract(Duration(days: 13 - i));
      final baseScore = 62.0 + i * 2.0 + (i % 3 == 0 ? -3 : 2);
      return DailySpeakingRecord(
        date: date,
        wordCount: 5 + (i % 4) * 2,
        phraseCount: 3 + (i % 3),
        conversationCount: i > 6 ? 1 + (i % 2) : 0,
        avgScore: baseScore.clamp(50, 95),
      );
    });
    state = SpeakingHistoryState(records: demo);
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.records.map((r) => r.toJson()).toList());
    await prefs.setString(_key, json);
  }

  Future<void> addRecord({
    required int wordCount,
    required int phraseCount,
    required int conversationCount,
    required double avgScore,
  }) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final existing = state.records.where((r) =>
      r.date.year == today.year && r.date.month == today.month && r.date.day == today.day
    ).toList();

    List<DailySpeakingRecord> updated;
    if (existing.isNotEmpty) {
      final old = existing.first;
      final merged = DailySpeakingRecord(
        date: today,
        wordCount: old.wordCount + wordCount,
        phraseCount: old.phraseCount + phraseCount,
        conversationCount: old.conversationCount + conversationCount,
        avgScore: (old.avgScore + avgScore) / 2,
      );
      updated = state.records.where((r) =>
        !(r.date.year == today.year && r.date.month == today.month && r.date.day == today.day)
      ).toList()..add(merged);
    } else {
      updated = [...state.records, DailySpeakingRecord(
        date: today,
        wordCount: wordCount,
        phraseCount: phraseCount,
        conversationCount: conversationCount,
        avgScore: avgScore,
      )];
    }

    // 30日分のみ保持
    updated.sort((a, b) => a.date.compareTo(b.date));
    if (updated.length > 30) {
      updated = updated.sublist(updated.length - 30);
    }

    state = SpeakingHistoryState(records: updated);
    await _save();
  }
}

final speakingHistoryProvider = StateNotifierProvider<SpeakingHistoryNotifier, SpeakingHistoryState>(
  (ref) => SpeakingHistoryNotifier(),
);
