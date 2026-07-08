import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../services/claude_api_service.dart';
import 'ai_api_key_provider.dart';

/// 先生ごっこセッション状態
class TeacherModeState {
  final List<Question> questions;
  final int currentIndex;
  final Map<int, TeacherModeQuestion> generatedQuestions;
  final int correctAnswers;
  final bool isLoading;

  TeacherModeState({
    required this.questions,
    this.currentIndex = 0,
    this.generatedQuestions = const {},
    this.correctAnswers = 0,
    this.isLoading = false,
  });

  TeacherModeState copyWith({
    List<Question>? questions,
    int? currentIndex,
    Map<int, TeacherModeQuestion>? generatedQuestions,
    int? correctAnswers,
    bool? isLoading,
  }) {
    return TeacherModeState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      generatedQuestions: generatedQuestions ?? this.generatedQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 先生ごっこ問題（Claude で生成）
class TeacherModeQuestion {
  final String correctPhrase;
  final String wrongPhrase;
  final String mistakeType;
  final String explanation;
  final String japaneseTranslation;
  final String teachingTip;

  TeacherModeQuestion({
    required this.correctPhrase,
    required this.wrongPhrase,
    required this.mistakeType,
    required this.explanation,
    required this.japaneseTranslation,
    required this.teachingTip,
  });
}

/// 先生ごっこ Notifier
class TeacherModeNotifier extends StateNotifier<TeacherModeState> {
  final ClaudeApiService _claudeService;
  final String _userLevel;

  TeacherModeNotifier({
    required ClaudeApiService claudeService,
    required String userLevel,
    required List<Question> questions,
  })  : _claudeService = claudeService,
        _userLevel = userLevel,
        super(TeacherModeState(questions: questions));

  /// 次の問題を生成
  Future<TeacherModeQuestion?> generateNextQuestion() async {
    if (state.currentIndex >= state.questions.length) return null;

    final question = state.questions[state.currentIndex];

    // キャッシュ確認
    if (state.generatedQuestions.containsKey(state.currentIndex)) {
      return state.generatedQuestions[state.currentIndex];
    }

    // Claude API で生成
    state = state.copyWith(isLoading: true);

    try {
      final difficulty = _mapDifficulty(question.difficulty);
      final response = await _claudeService.generateWrongPhrase(
        correctPhrase: question.text,
        japaneseTranslation: question.meaning ?? '意味不明',
        difficulty: difficulty,
        userLevel: int.tryParse(_userLevel) ?? 15,
      );

      final generated = TeacherModeQuestion(
        correctPhrase: question.text,
        wrongPhrase: response.mistake,
        mistakeType: response.mistakeType,
        explanation: response.explanation,
        japaneseTranslation: question.meaning ?? '',
        teachingTip: response.teachingTip,
      );

      // キャッシュに保存
      final updated = {...state.generatedQuestions};
      updated[state.currentIndex] = generated;

      state = state.copyWith(
        generatedQuestions: updated,
        isLoading: false,
      );

      return generated;
    } catch (e) {
      print('Generate question error: $e');
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  /// 正解を記録して次へ
  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// 正解数を増やす
  void recordCorrectAnswer() {
    state = state.copyWith(correctAnswers: state.correctAnswers + 1);
  }

  /// セッション終了
  Map<String, dynamic> finishSession() {
    final total = state.questions.length;
    final accuracy = total > 0 ? (state.correctAnswers / total * 100).toInt() : 0;
    final coinsEarned = state.correctAnswers * 10;

    return {
      'correctAnswers': state.correctAnswers,
      'totalQuestions': total,
      'accuracy': accuracy,
      'coinsEarned': coinsEarned,
    };
  }

  String _mapDifficulty(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'beginner';
      case DifficultyLevel.intermediate:
        return 'intermediate';
      case DifficultyLevel.advanced:
        return 'advanced';
    }
  }
}

/// Provider: 先生ごっこ State
final teacherModeProvider =
    StateNotifierProvider.family<TeacherModeNotifier, TeacherModeState, List<Question>>((ref, questions) {
  final apiKey = ref.watch(aiApiKeyProvider);
  final userLevel = ref.watch(userProfileProvider).asData?.value?.level.toString() ?? '15';

  final claudeService = ClaudeApiService(
    apiKey: apiKey ?? '',
    userGrade: userLevel,
  );

  return TeacherModeNotifier(
    claudeService: claudeService,
    userLevel: userLevel,
    questions: questions,
  );
});
