import 'package:json_annotation/json_annotation.dart';

part 'teacher_mode_model.g.dart';

/// Teacher Mode難易度レベル
enum TeacherModeDifficulty {
  @JsonValue('easy')
  easy,
  @JsonValue('medium')
  medium,
  @JsonValue('hard')
  hard,
}

/// Teacher Mode習題タイプ
enum MistakeType {
  @JsonValue('pronunciation')
  pronunciation, // 発音ミス（速度、アクセント）
  @JsonValue('grammar')
  grammar, // 文法ミス（時制、三単現など）
  @JsonValue('meaning')
  meaning, // 意味ミス（似た単語の誤用）
}

/// AIが作成した意図的なミス
@JsonSerializable()
class AIStudentMistake {
  final String mistakeText; // AIが間違えた言い方
  final MistakeType mistakeType; // ミスのタイプ
  final String correctAnswer; // 正解
  final String explanation; // なぜこれが間違いかの説明
  final String encouragement; // 子どもが正解した時の返答

  const AIStudentMistake({
    required this.mistakeText,
    required this.mistakeType,
    required this.correctAnswer,
    required this.explanation,
    required this.encouragement,
  });

  factory AIStudentMistake.fromJson(Map<String, dynamic> json) =>
      _$AIStudentMistakeFromJson(json);

  Map<String, dynamic> toJson() => _$AIStudentMistakeToJson(this);

  AIStudentMistake copyWith({
    String? mistakeText,
    MistakeType? mistakeType,
    String? correctAnswer,
    String? explanation,
    String? encouragement,
  }) {
    return AIStudentMistake(
      mistakeText: mistakeText ?? this.mistakeText,
      mistakeType: mistakeType ?? this.mistakeType,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      encouragement: encouragement ?? this.encouragement,
    );
  }
}

/// Teacher Modeセッション
@JsonSerializable()
class TeacherModeSession {
  final String sessionId;
  final String phrase; // 学習中のフレーズ
  final String phraseMeaning; // フレーズの意味
  final TeacherModeDifficulty difficulty; // 難易度
  final AIStudentMistake? currentMistake; // 現在のミス
  final List<TeacherModeRound> completedRounds; // 完了した会話ラウンド
  final int correctAnswers; // 正解した数
  final int totalRounds; // 総ラウンド数
  final DateTime startedAt;
  final DateTime? completedAt;
  final int sessionScore; // このセッションのスコア（0-100）

  const TeacherModeSession({
    required this.sessionId,
    required this.phrase,
    required this.phraseMeaning,
    required this.difficulty,
    this.currentMistake,
    this.completedRounds = const [],
    this.correctAnswers = 0,
    this.totalRounds = 0,
    required this.startedAt,
    this.completedAt,
    this.sessionScore = 0,
  });

  factory TeacherModeSession.fromJson(Map<String, dynamic> json) =>
      _$TeacherModeSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModeSessionToJson(this);

  TeacherModeSession copyWith({
    String? sessionId,
    String? phrase,
    String? phraseMeaning,
    TeacherModeDifficulty? difficulty,
    AIStudentMistake? currentMistake,
    List<TeacherModeRound>? completedRounds,
    int? correctAnswers,
    int? totalRounds,
    DateTime? startedAt,
    DateTime? completedAt,
    int? sessionScore,
  }) {
    return TeacherModeSession(
      sessionId: sessionId ?? this.sessionId,
      phrase: phrase ?? this.phrase,
      phraseMeaning: phraseMeaning ?? this.phraseMeaning,
      difficulty: difficulty ?? this.difficulty,
      currentMistake: currentMistake ?? this.currentMistake,
      completedRounds: completedRounds ?? this.completedRounds,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalRounds: totalRounds ?? this.totalRounds,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      sessionScore: sessionScore ?? this.sessionScore,
    );
  }

  bool get isCompleted => completedAt != null;

  double get accuracyRate =>
      totalRounds > 0 ? (correctAnswers / totalRounds) * 100 : 0;
}

/// Teacher Modeの1ラウンド（1つの会話交換）
@JsonSerializable()
class TeacherModeRound {
  final int roundNumber;
  final AIStudentMistake mistake; // このラウンドでのAIのミス
  final String childResponse; // 子どもの応答（音声認識テキスト）
  final bool isCorrect; // 子どもが正しく訂正できたか
  final double accuracyScore; // 音声認識の正確性スコア（0-100）
  final DateTime completedAt;

  const TeacherModeRound({
    required this.roundNumber,
    required this.mistake,
    required this.childResponse,
    required this.isCorrect,
    required this.accuracyScore,
    required this.completedAt,
  });

  factory TeacherModeRound.fromJson(Map<String, dynamic> json) =>
      _$TeacherModeRoundFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModeRoundToJson(this);

  TeacherModeRound copyWith({
    int? roundNumber,
    AIStudentMistake? mistake,
    String? childResponse,
    bool? isCorrect,
    double? accuracyScore,
    DateTime? completedAt,
  }) {
    return TeacherModeRound(
      roundNumber: roundNumber ?? this.roundNumber,
      mistake: mistake ?? this.mistake,
      childResponse: childResponse ?? this.childResponse,
      isCorrect: isCorrect ?? this.isCorrect,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Teacher Mode統計
@JsonSerializable()
class TeacherModeStats {
  final int totalSessions; // 実施したセッション数
  final int totalCorrections; // 総正解数
  final double averageAccuracy; // 平均正解率
  final int totalCoinsEarned; // 獲得したコイン
  final List<String> phrasesLearned; // 学習したフレーズリスト
  final DateTime lastSessionAt; // 最後のセッション

  const TeacherModeStats({
    required this.totalSessions,
    required this.totalCorrections,
    required this.averageAccuracy,
    required this.totalCoinsEarned,
    required this.phrasesLearned,
    required this.lastSessionAt,
  });

  factory TeacherModeStats.fromJson(Map<String, dynamic> json) =>
      _$TeacherModeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModeStatsToJson(this);

  TeacherModeStats copyWith({
    int? totalSessions,
    int? totalCorrections,
    double? averageAccuracy,
    int? totalCoinsEarned,
    List<String>? phrasesLearned,
    DateTime? lastSessionAt,
  }) {
    return TeacherModeStats(
      totalSessions: totalSessions ?? this.totalSessions,
      totalCorrections: totalCorrections ?? this.totalCorrections,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      phrasesLearned: phrasesLearned ?? this.phrasesLearned,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
    );
  }
}
