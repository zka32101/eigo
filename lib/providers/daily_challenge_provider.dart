import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/stage_data.dart';
import '../models/question.dart';

class DailyChallengeState {
  final List<Question> questions;   // 今日の5問
  final bool isCompleted;           // 今日クリア済み
  final int bonusCoins;             // ボーナスコイン
  final String dateKey;             // YYYY-MM-DD

  const DailyChallengeState({
    required this.questions,
    required this.isCompleted,
    required this.bonusCoins,
    required this.dateKey,
  });

  DailyChallengeState copyWith({
    List<Question>? questions,
    bool? isCompleted,
    int? bonusCoins,
    String? dateKey,
  }) => DailyChallengeState(
    questions: questions ?? this.questions,
    isCompleted: isCompleted ?? this.isCompleted,
    bonusCoins: bonusCoins ?? this.bonusCoins,
    dateKey: dateKey ?? this.dateKey,
  );
}

class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  DailyChallengeNotifier() : super(DailyChallengeState(
    questions: [],
    isCompleted: false,
    bonusCoins: 30,
    dateKey: '',
  )) {
    _load();
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final completedDate = prefs.getString('daily_challenge_completed') ?? '';

    // 今日の問題を決定論的に選択（日付ベースのシード）
    final questions = _selectQuestions(today);

    state = state.copyWith(
      questions: questions,
      isCompleted: completedDate == today,
      dateKey: today,
    );
  }

  List<Question> _selectQuestions(String dateKey) {
    // 全問題をフラット化
    final all = allStages.expand((s) => s.questions).toList();

    // dateKey からシード値を生成
    int seed = dateKey.replaceAll('-', '').codeUnits.fold(0, (prev, c) => prev + c);

    // シードを使って5問選択
    final result = <Question>[];
    final used = <int>{};
    int idx = seed % all.length;
    while (result.length < 5) {
      if (!used.contains(idx)) {
        used.add(idx);
        final q = all[idx];
        // スピーキング問題のみ（デイリーチャレンジはスピーキング特化）
        if (q.type == QuestionType.speaking) {
          result.add(q);
        }
      }
      idx = (idx + 7) % all.length; // 7ステップで分散
    }
    return result;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    await prefs.setString('daily_challenge_completed', today);
    state = state.copyWith(isCompleted: true);
  }
}

final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>(
  (ref) => DailyChallengeNotifier(),
);
