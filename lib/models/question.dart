enum QuestionType { listening, speaking, reading, writing }
enum DifficultyLevel { beginner, intermediate, advanced }

class Question {
  final String id;
  final QuestionType type;
  final DifficultyLevel difficulty;
  final String text;        // 問題テキスト（英語）
  final String textJa;      // 日本語説明
  final String? imageEmoji; // 絵文字イラスト
  final List<String> choices; // 選択肢（リスニング・リーディング用）
  final String correctAnswer;
  final String? phonetic;   // 発音記号
  final int points;

  const Question({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.text,
    required this.textJa,
    this.imageEmoji,
    this.choices = const [],
    required this.correctAnswer,
    this.phonetic,
    this.points = 10,
  });
}

class SpeakingResult {
  final String questionId;
  final int score;          // 0-100
  final String? feedback;
  final DateTime timestamp;

  const SpeakingResult({
    required this.questionId,
    required this.score,
    this.feedback,
    required this.timestamp,
  });

  bool get isGood => score >= 80;
  bool get isOk => score >= 60;
}

class LessonResult {
  final String stageId;
  final int totalQuestions;
  final int correctAnswers;
  final int totalPoints;
  final int speakingAvgScore;
  final int listeningAccuracy;
  final Duration duration;
  final DateTime completedAt;

  const LessonResult({
    required this.stageId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalPoints,
    required this.speakingAvgScore,
    required this.listeningAccuracy,
    required this.duration,
    required this.completedAt,
  });

  double get accuracyRate => correctAnswers / totalQuestions;
  bool get isPassed => accuracyRate >= 0.6;
  bool get isExcellent => accuracyRate >= 0.9;
}
