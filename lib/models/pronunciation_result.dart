class PronunciationResult {
  final String word;
  final String userPronunciation;
  final double accuracy; // 0.0 - 1.0
  final String feedback;
  final bool isPassed; // accuracy >= 0.7

  const PronunciationResult({
    required this.word,
    required this.userPronunciation,
    required this.accuracy,
    required this.feedback,
    required this.isPassed,
  });

  String get accuracyPercentage => '${(accuracy * 100).toStringAsFixed(0)}%';

  String get feedbackEmoji {
    if (accuracy >= 0.9) return '🌟';
    if (accuracy >= 0.7) return '✅';
    if (accuracy >= 0.5) return '👍';
    return '💪';
  }
}
