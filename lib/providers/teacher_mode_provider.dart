import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/teacher_mode_model.dart';
import '../services/logger_service.dart';

/// Teacher Modeプロバイダー：現在のセッション管理
final teacherModeSessionProvider =
    StateNotifierProvider<TeacherModeSessionNotifier, TeacherModeSession?>((ref) {
  return TeacherModeSessionNotifier();
});

/// Teacher Mode統計プロバイダー
final teacherModeStatsProvider =
    StateNotifierProvider<TeacherModeStatsNotifier, TeacherModeStats>((ref) {
  return TeacherModeStatsNotifier();
});

/// AI生成プロバイダー
final aiMistakeGeneratorProvider =
    FutureProvider.autoDispose.family<AIStudentMistake, (String, TeacherModeDifficulty)>((ref, params) async {
  final (phrase, difficulty) = params;
  return _generateAIMistake(phrase, difficulty);
});

class TeacherModeSessionNotifier extends StateNotifier<TeacherModeSession?> {
  TeacherModeSessionNotifier() : super(null);

  /// 新しいセッションを開始
  Future<void> startSession(
    String phrase,
    String phraseMeaning,
    TeacherModeDifficulty difficulty,
  ) async {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    state = TeacherModeSession(
      sessionId: sessionId,
      phrase: phrase,
      phraseMeaning: phraseMeaning,
      difficulty: difficulty,
      startedAt: DateTime.now(),
      totalRounds: 3,
    );
  }

  /// AIのミスをセット
  Future<void> setCurrentMistake(AIStudentMistake mistake) async {
    if (state == null) return;
    state = state!.copyWith(currentMistake: mistake);
  }

  /// ラウンドを完了
  Future<void> completeRound(
    String childResponse,
    double accuracyScore,
  ) async {
    if (state == null || state!.currentMistake == null) return;

    final mistake = state!.currentMistake!;
    final isCorrect = _evaluateChildResponse(
      childResponse,
      mistake.correctAnswer,
    );

    final round = TeacherModeRound(
      roundNumber: state!.completedRounds.length + 1,
      mistake: mistake,
      childResponse: childResponse,
      isCorrect: isCorrect,
      accuracyScore: accuracyScore,
      completedAt: DateTime.now(),
    );

    final newCompletedRounds = [...state!.completedRounds, round];
    final newCorrectAnswers = state!.correctAnswers + (isCorrect ? 1 : 0);

    state = state!.copyWith(
      completedRounds: newCompletedRounds,
      correctAnswers: newCorrectAnswers,
      currentMistake: null,
    );
  }

  /// セッションを終了
  Future<void> completeSession() async {
    if (state == null) return;

    final accuracy = state!.accuracyRate;
    final sessionScore = (accuracy * 100).toInt();

    state = state!.copyWith(
      completedAt: DateTime.now(),
      sessionScore: sessionScore,
    );

    await _saveSessionHistory(state!);
  }

  /// セッションをリセット
  void resetSession() {
    state = null;
  }

  bool _evaluateChildResponse(String childResponse, String correctAnswer) {
    final childLower = childResponse.toLowerCase().trim();
    final correctLower = correctAnswer.toLowerCase().trim();
    return childLower == correctLower ||
           childLower.contains(correctLower) ||
           correctLower.contains(childLower);
  }

  Future<void> _saveSessionHistory(TeacherModeSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'eigo_kore_teacher_mode_sessions';
      final existingList = prefs.getStringList(key) ?? [];
      existingList.add(jsonEncode(session.toJson()));
      await prefs.setStringList(key, existingList);
    } catch (e) {
      LoggerService.error('Error saving session history', tag: 'TeacherModeSessionNotifier', exception: e);
    }
  }
}

class TeacherModeStatsNotifier extends StateNotifier<TeacherModeStats> {
  static const String _storageKey = 'eigo_kore_teacher_mode_stats';

  TeacherModeStatsNotifier() : super(
    const TeacherModeStats(
      totalSessions: 0,
      totalCorrections: 0,
      averageAccuracy: 0.0,
      totalCoinsEarned: 0,
      phrasesLearned: [],
      lastSessionAt: DateTime.epoch,
    ),
  ) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        state = TeacherModeStats.fromJson(json);
      }
    } catch (e) {
      LoggerService.error('Error loading teacher mode stats', tag: 'TeacherModeStatsNotifier', exception: e);
    }
  }

  Future<void> updateStatsFromSession(TeacherModeSession session) async {
    if (!session.isCompleted) return;

    final newPhrasesLearned = [...state.phrasesLearned];
    if (!newPhrasesLearned.contains(session.phrase)) {
      newPhrasesLearned.add(session.phrase);
    }

    final coinsEarned = session.correctAnswers * 10;
    final totalTests = state.totalSessions + 1;
    final newAverageAccuracy =
        ((state.averageAccuracy * state.totalSessions) + session.accuracyRate) / totalTests;

    state = TeacherModeStats(
      totalSessions: state.totalSessions + 1,
      totalCorrections: state.totalCorrections + session.correctAnswers,
      averageAccuracy: newAverageAccuracy,
      totalCoinsEarned: state.totalCoinsEarned + coinsEarned,
      phrasesLearned: newPhrasesLearned,
      lastSessionAt: DateTime.now(),
    );

    await _saveStats();
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      LoggerService.error('Error saving stats', tag: 'TeacherModeStatsNotifier', exception: e);
    }
  }

  Future<void> resetStats() async {
    state = const TeacherModeStats(
      totalSessions: 0,
      totalCorrections: 0,
      averageAccuracy: 0.0,
      totalCoinsEarned: 0,
      phrasesLearned: [],
      lastSessionAt: DateTime.epoch,
    );
    await _saveStats();
  }
}

Future<AIStudentMistake> _generateAIMistake(
  String phrase,
  TeacherModeDifficulty difficulty,
) async {
  final mistakeDatabase = _getMistakeDatabaseForPhrase(phrase, difficulty);

  if (mistakeDatabase.isEmpty) {
    return AIStudentMistake(
      mistakeText: 'I am... erm... sorry?',
      mistakeType: MistakeType.pronunciation,
      correctAnswer: phrase,
      explanation: 'That was a bit unclear. Can you say that again?',
      encouragement: 'Thank you for teaching me! You are a great teacher!',
    );
  }

  mistakeDatabase.shuffle();
  return mistakeDatabase.first;
}

List<AIStudentMistake> _getMistakeDatabaseForPhrase(
  String phrase,
  TeacherModeDifficulty difficulty,
) {
  final mistakeMap = {
    'What is your name?': [
      AIStudentMistake(
        mistakeText: 'What is you name?',
        mistakeType: MistakeType.grammar,
        correctAnswer: 'What is your name?',
        explanation: 'I forgot to use "your" - a grammar mistake!',
        encouragement: 'Perfect! You caught my mistake! You are a wonderful teacher!',
      ),
      AIStudentMistake(
        mistakeText: 'Whaaaat eeees yoooor naaame?',
        mistakeType: MistakeType.pronunciation,
        correctAnswer: 'What is your name?',
        explanation: 'I said it too slowly and with strange pronunciation.',
        encouragement: 'Great job correcting me! Thank you, teacher!',
      ),
    ],
    'My name is...': [
      AIStudentMistake(
        mistakeText: 'My names are...',
        mistakeType: MistakeType.grammar,
        correctAnswer: 'My name is...',
        explanation: 'I used plural "names" but should use singular.',
        encouragement: 'Excellent! You found my grammar mistake!',
      ),
    ],
    'Nice to meet you': [
      AIStudentMistake(
        mistakeText: 'Nice to meet him',
        mistakeType: MistakeType.meaning,
        correctAnswer: 'Nice to meet you',
        explanation: 'I said "him" instead of "you" - wrong meaning!',
        encouragement: 'You are so smart! Thank you for the lesson!',
      ),
    ],
  };

  return mistakeMap[phrase] ?? [];
}
