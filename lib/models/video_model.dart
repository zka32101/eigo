import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

/// Pronunciation video model
@JsonSerializable()
class PronunciationVideo {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final int lengthSeconds;
  final String category; // phonetics, words, sentences, stress, natives
  final int difficulty; // 1-5
  final List<String> tags;
  final DateTime publishedAt;
  final String instructor;
  final List<String> focusAreas;
  final double averageRating;
  final int viewCount;
  final int likes;
  final String? thumbnailUrl;

  PronunciationVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.lengthSeconds,
    required this.category,
    required this.difficulty,
    required this.tags,
    required this.publishedAt,
    required this.instructor,
    required this.focusAreas,
    this.averageRating = 0.0,
    this.viewCount = 0,
    this.likes = 0,
    this.thumbnailUrl,
  });

  factory PronunciationVideo.fromJson(Map<String, dynamic> json) =>
      _$PronunciationVideoFromJson(json);

  Map<String, dynamic> toJson() => _$PronunciationVideoToJson(this);

  /// Get formatted duration (e.g., "5:30")
  String get formattedDuration {
    final minutes = lengthSeconds ~/ 60;
    final seconds = lengthSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get difficulty label
  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return '初級';
      case 2:
        return '中級';
      case 3:
        return '上級';
      case 4:
        return 'アドバンス';
      case 5:
        return 'エキスパート';
      default:
        return '不明';
    }
  }

  /// Get category label
  String get categoryLabel {
    switch (category) {
      case 'phonetics':
        return '音素学習';
      case 'words':
        return '単語発音';
      case 'sentences':
        return '文の強調';
      case 'stress':
        return '話し方技法';
      case 'natives':
        return 'ネイティブ集';
      default:
        return category;
    }
  }

  /// Get difficulty color
  String get difficultyEmoji {
    switch (difficulty) {
      case 1:
        return '🟢';
      case 2:
        return '🟡';
      case 3:
        return '🟠';
      case 4:
        return '🔴';
      case 5:
        return '⚫';
      default:
        return '⭐';
    }
  }
}

/// User's video progress
@JsonSerializable()
class VideoProgress {
  final String userId;
  final String videoId;
  final int watchedSeconds;
  final bool isWatched; // > 90% watched
  final bool isLiked;
  final int rating; // 1-5, 0 = not rated
  final DateTime lastWatchedAt;
  final List<int> bookmarkedSeconds;

  VideoProgress({
    required this.userId,
    required this.videoId,
    required this.watchedSeconds,
    required this.isWatched,
    required this.isLiked,
    required this.rating,
    required this.lastWatchedAt,
    this.bookmarkedSeconds = const [],
  });

  factory VideoProgress.fromJson(Map<String, dynamic> json) =>
      _$VideoProgressFromJson(json);

  Map<String, dynamic> toJson() => _$VideoProgressToJson(this);

  /// Get watch percentage (0-100)
  int getWatchPercentage(int totalSeconds) {
    if (totalSeconds == 0) return 0;
    return ((watchedSeconds / totalSeconds) * 100).toInt();
  }

  /// Copy with
  VideoProgress copyWith({
    String? userId,
    String? videoId,
    int? watchedSeconds,
    bool? isWatched,
    bool? isLiked,
    int? rating,
    DateTime? lastWatchedAt,
    List<int>? bookmarkedSeconds,
  }) {
    return VideoProgress(
      userId: userId ?? this.userId,
      videoId: videoId ?? this.videoId,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      isWatched: isWatched ?? this.isWatched,
      isLiked: isLiked ?? this.isLiked,
      rating: rating ?? this.rating,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      bookmarkedSeconds: bookmarkedSeconds ?? this.bookmarkedSeconds,
    );
  }
}

/// Video quiz question
@JsonSerializable()
class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

/// Video quiz
@JsonSerializable()
class VideoQuiz {
  final String id;
  final String videoId;
  final List<QuizQuestion> questions;
  final int passingScore; // percentage
  final String? rewardBadge;

  VideoQuiz({
    required this.id,
    required this.videoId,
    required this.questions,
    this.passingScore = 70,
    this.rewardBadge,
  });

  factory VideoQuiz.fromJson(Map<String, dynamic> json) =>
      _$VideoQuizFromJson(json);

  Map<String, dynamic> toJson() => _$VideoQuizToJson(this);
}

/// User's quiz result
@JsonSerializable()
class VideoQuizResult {
  final String userId;
  final String videoId;
  final int score; // 0-100
  final bool passed;
  final int attemptCount;
  final DateTime lastAttemptAt;
  final List<String> badgesEarned;

  VideoQuizResult({
    required this.userId,
    required this.videoId,
    required this.score,
    required this.passed,
    required this.attemptCount,
    required this.lastAttemptAt,
    this.badgesEarned = const [],
  });

  factory VideoQuizResult.fromJson(Map<String, dynamic> json) =>
      _$VideoQuizResultFromJson(json);

  Map<String, dynamic> toJson() => _$VideoQuizResultToJson(this);

  /// Copy with
  VideoQuizResult copyWith({
    String? userId,
    String? videoId,
    int? score,
    bool? passed,
    int? attemptCount,
    DateTime? lastAttemptAt,
    List<String>? badgesEarned,
  }) {
    return VideoQuizResult(
      userId: userId ?? this.userId,
      videoId: videoId ?? this.videoId,
      score: score ?? this.score,
      passed: passed ?? this.passed,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      badgesEarned: badgesEarned ?? this.badgesEarned,
    );
  }
}

/// Video watch statistics
@JsonSerializable()
class VideoWatchStats {
  final String videoId;
  final int totalViews;
  final int completionCount; // fully watched
  final double avgWatchTime; // seconds
  final Map<String, int> hourlyViews; // hour -> count
  final int likeCount;
  final double averageRating;

  VideoWatchStats({
    required this.videoId,
    required this.totalViews,
    required this.completionCount,
    required this.avgWatchTime,
    this.hourlyViews = const {},
    this.likeCount = 0,
    this.averageRating = 0.0,
  });

  factory VideoWatchStats.fromJson(Map<String, dynamic> json) =>
      _$VideoWatchStatsFromJson(json);

  Map<String, dynamic> toJson() => _$VideoWatchStatsToJson(this);

  /// Get completion rate percentage
  double get completionRate {
    if (totalViews == 0) return 0.0;
    return (completionCount / totalViews) * 100;
  }
}
