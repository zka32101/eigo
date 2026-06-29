import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../data/stage_data.dart';

/// 問題ごとの回答記録
class QuestionRecord {
  final String questionId;
  final QuestionType type;
  final int attempts;
  final int correct;
  final int speakingScoreSum; // スピーキングのみ

  const QuestionRecord({
    required this.questionId,
    required this.type,
    required this.attempts,
    required this.correct,
    required this.speakingScoreSum,
  });

  double get accuracy => attempts == 0 ? 0 : correct / attempts;
  double get avgSpeakingScore => attempts == 0 ? 0 : speakingScoreSum / attempts;
  bool get isWeak => type == QuestionType.speaking
      ? avgSpeakingScore < 70
      : accuracy < 0.6;

  Map<String, dynamic> toJson() => {
    'id': questionId,
    'type': type.name,
    'attempts': attempts,
    'correct': correct,
    'speakingScoreSum': speakingScoreSum,
  };

  factory QuestionRecord.fromJson(Map<String, dynamic> j) => QuestionRecord(
    questionId: j['id'] as String,
    type: QuestionType.values.firstWhere((t) => t.name == j['type'], orElse: () => QuestionType.listening),
    attempts: (j['attempts'] as num).toInt(),
    correct: (j['correct'] as num).toInt(),
    speakingScoreSum: (j['speakingScoreSum'] as num).toInt(),
  );

  QuestionRecord addResult({required bool isCorrect, int speakingScore = 0}) {
    return QuestionRecord(
      questionId: questionId,
      type: type,
      attempts: attempts + 1,
      correct: correct + (isCorrect ? 1 : 0),
      speakingScoreSum: speakingScoreSum + speakingScore,
    );
  }
}

class WeaknessState {
  final Map<String, QuestionRecord> records; // questionId -> record

  const WeaknessState({this.records = const {}});

  List<QuestionRecord> get weakQuestions =>
      records.values.where((r) => r.attempts >= 1 && r.isWeak).toList()
        ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

  List<Question> get weakQuestionsAcrossAllStages {
    final weakIds = weakQuestions.map((r) => r.questionId).toSet();
    final result = <Question>[];
    for (final stage in allStages) {
      for (final q in stage.questions) {
        if (weakIds.contains(q.id)) result.add(q);
        if (result.length >= 20) return result;
      }
    }
    return result;
  }

  // ステージ別の弱点率
  double stageWeaknessRate(String stageId) {
    final stage = allStages.firstWhere(
      (s) => s.id == stageId,
      orElse: () => allStages.first,
    );
    final stageIds = stage.questions.map((q) => q.id).toSet();
    final stageRecords = records.values.where((r) => stageIds.contains(r.questionId)).toList();
    if (stageRecords.isEmpty) return 0;
    final weak = stageRecords.where((r) => r.isWeak).length;
    return weak / stageRecords.length;
  }

  // スキル別の弱点率
  double skillWeaknessRate(QuestionType type) {
    final typeRecords = records.values.where((r) => r.type == type && r.attempts >= 1).toList();
    if (typeRecords.isEmpty) return 0;
    final weak = typeRecords.where((r) => r.isWeak).length;
    return weak / typeRecords.length;
  }

  // リスニング平均正答率
  double get listeningAccuracy {
    final lr = records.values.where((r) => r.type == QuestionType.listening && r.attempts > 0).toList();
    if (lr.isEmpty) return 0;
    return lr.map((r) => r.accuracy).reduce((a, b) => a + b) / lr.length;
  }

  // スピーキング平均スコア
  double get speakingAvgScore {
    final sr = records.values.where((r) => r.type == QuestionType.speaking && r.attempts > 0).toList();
    if (sr.isEmpty) return 0;
    return sr.map((r) => r.avgSpeakingScore).reduce((a, b) => a + b) / sr.length;
  }
}

class WeaknessNotifier extends StateNotifier<WeaknessState> {
  WeaknessNotifier() : super(const WeaknessState()) {
    _load();
  }

  static const _key = 'question_records';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final records = map.map((k, v) =>
        MapEntry(k, QuestionRecord.fromJson(v as Map<String, dynamic>)));
      state = WeaknessState(records: records);
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.records.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_key, json);
  }

  Future<void> recordAnswer({
    required String questionId,
    required QuestionType type,
    required bool isCorrect,
    int speakingScore = 0,
  }) async {
    final existing = state.records[questionId] ??
        QuestionRecord(questionId: questionId, type: type, attempts: 0, correct: 0, speakingScoreSum: 0);
    final updated = existing.addResult(isCorrect: isCorrect, speakingScore: speakingScore);
    state = WeaknessState(records: {...state.records, questionId: updated});
    await _save();
  }

  Future<void> recordBatch(List<({String id, QuestionType type, bool correct, int speakingScore})> answers) async {
    var records = Map<String, QuestionRecord>.from(state.records);
    for (final a in answers) {
      final existing = records[a.id] ??
          QuestionRecord(questionId: a.id, type: a.type, attempts: 0, correct: 0, speakingScoreSum: 0);
      records[a.id] = existing.addResult(isCorrect: a.correct, speakingScore: a.speakingScore);
    }
    state = WeaknessState(records: records);
    await _save();
  }
}

final weaknessProvider = StateNotifierProvider<WeaknessNotifier, WeaknessState>(
  (ref) => WeaknessNotifier(),
);
