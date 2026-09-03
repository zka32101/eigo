import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../services/logger_service.dart';

/// Video Service instance provider
final videoServiceProvider = Provider((ref) {
  return VideoService();
});

/// All available videos provider
final allVideosProvider = FutureProvider<List<PronunciationVideo>>((ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getAllVideos();
});

/// Filtered videos provider
final filteredVideosProvider = FutureProvider.family<List<PronunciationVideo>, VideoFilterParams>(
  (ref, params) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getAllVideos(
      category: params.category,
      maxDifficulty: params.maxDifficulty,
      searchQuery: params.searchQuery,
    );
  },
);

/// Videos by category provider
final videosByCategoryProvider = FutureProvider.family<List<PronunciationVideo>, String>(
  (ref, category) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getVideosByCategory(category);
  },
);

/// Top-rated videos provider
final topRatedVideosProvider = FutureProvider<List<PronunciationVideo>>((ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getTopRatedVideos(limit: 10);
});

/// Specific video provider
final videoProvider = FutureProvider.family<PronunciationVideo?, String>((ref, videoId) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getVideo(videoId);
});

/// User's watch history provider
final userWatchHistoryProvider = FutureProvider.family<List<VideoProgress>, String>(
  (ref, userId) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getUserWatchHistory(userId, limit: 20);
  },
);

/// User's watched videos provider
final userWatchedVideosProvider = FutureProvider.family<List<VideoProgress>, String>(
  (ref, userId) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getWatchedVideos(userId);
  },
);

/// User's video progress provider
final userVideoProgressProvider = FutureProvider.family<VideoProgress?, String>(
  (ref, params) async {
    final parts = params.split(':');
    if (parts.length != 2) return null;

    final userId = parts[0];
    final videoId = parts[1];

    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getUserVideoProgress(userId, videoId);
  },
);

/// Recommended videos provider
final recommendedVideosProvider = FutureProvider.family<List<PronunciationVideo>, String>(
  (ref, userId) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getRecommendedVideos(userId, limit: 10);
  },
);

/// Continue watching videos provider
final continueWatchingProvider = FutureProvider.family<List<PronunciationVideo>, String>(
  (ref, userId) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getContinueWatchingVideos(userId, limit: 5);
  },
);

/// Video quiz provider
final videoQuizProvider = FutureProvider.family<VideoQuiz?, String>((ref, videoId) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getVideoQuiz(videoId);
});

/// User's quiz result provider
final userQuizResultProvider = FutureProvider.family<VideoQuizResult?, String>(
  (ref, params) async {
    final parts = params.split(':');
    if (parts.length != 2) return null;

    final userId = parts[0];
    final videoId = parts[1];

    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getQuizResult(userId, videoId);
  },
);

/// User's video statistics provider
final userVideoStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getUserVideoStats(userId);
  },
);

/// Video watch statistics provider
final videoWatchStatsProvider = FutureProvider.family<VideoWatchStats?, String>(
  (ref, videoId) async {
    final videoService = ref.watch(videoServiceProvider);
    return await videoService.getVideoWatchStats(videoId);
  },
);

/// Average rating provider
final videoAverageRatingProvider = FutureProvider.family<double, String>((ref, videoId) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.getAverageRating(videoId);
});

// ===== Action Providers =====

/// Update video progress action
final updateVideoProgressProvider = FutureProvider.family<void, VideoProgress>(
  (ref, progress) async {
    final videoService = ref.watch(videoServiceProvider);
    await videoService.updateVideoProgress(progress);
    // Invalidate related providers
    ref.invalidate(userVideoProgressProvider('${progress.userId}:${progress.videoId}'));
    ref.invalidate(userWatchHistoryProvider(progress.userId));
  },
);

/// Rate video action
final rateVideoActionProvider = FutureProvider.family<void, RateVideoParams>(
  (ref, params) async {
    final videoService = ref.watch(videoServiceProvider);
    await videoService.rateVideo(params.userId, params.videoId, params.rating);
    // Invalidate related providers
    ref.invalidate(videoAverageRatingProvider(params.videoId));
    ref.invalidate(userVideoProgressProvider('${params.userId}:${params.videoId}'));
  },
);

/// Like video action
final likeVideoActionProvider = FutureProvider.family<void, LikeVideoParams>(
  (ref, params) async {
    final videoService = ref.watch(videoServiceProvider);
    await videoService.toggleLikeVideo(params.userId, params.videoId);
    // Invalidate related providers
    ref.invalidate(userVideoProgressProvider('${params.userId}:${params.videoId}'));
  },
);

/// Submit quiz action
final submitQuizActionProvider = FutureProvider.family<VideoQuizResult?, SubmitQuizParams>(
  (ref, params) async {
    final videoService = ref.watch(videoServiceProvider);
    final result = await videoService.submitQuizAnswers(
      params.userId,
      params.videoId,
      params.answers,
    );

    if (result != null) {
      // Invalidate related providers
      ref.invalidate(userQuizResultProvider('${params.userId}:${params.videoId}'));
      ref.invalidate(userVideoStatsProvider(params.userId));
    }

    return result;
  },
);

// ===== Parameter Classes =====

class VideoFilterParams {
  final String? category;
  final int? maxDifficulty;
  final String? searchQuery;

  VideoFilterParams({
    this.category,
    this.maxDifficulty,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoFilterParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          maxDifficulty == other.maxDifficulty &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => category.hashCode ^ maxDifficulty.hashCode ^ searchQuery.hashCode;
}

class RateVideoParams {
  final String userId;
  final String videoId;
  final int rating;

  RateVideoParams({
    required this.userId,
    required this.videoId,
    required this.rating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateVideoParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          videoId == other.videoId &&
          rating == other.rating;

  @override
  int get hashCode => userId.hashCode ^ videoId.hashCode ^ rating.hashCode;
}

class LikeVideoParams {
  final String userId;
  final String videoId;

  LikeVideoParams({
    required this.userId,
    required this.videoId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikeVideoParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          videoId == other.videoId;

  @override
  int get hashCode => userId.hashCode ^ videoId.hashCode;
}

class SubmitQuizParams {
  final String userId;
  final String videoId;
  final List<String> answers;

  SubmitQuizParams({
    required this.userId,
    required this.videoId,
    required this.answers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitQuizParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          videoId == other.videoId &&
          answers == other.answers;

  @override
  int get hashCode => userId.hashCode ^ videoId.hashCode ^ answers.hashCode;
}
