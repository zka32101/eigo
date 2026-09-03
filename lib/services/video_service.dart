import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_model.dart';
import 'logger_service.dart';

/// Service for managing pronunciation videos and learning progress
class VideoService {
  static final VideoService _instance = VideoService._internal();

  factory VideoService() {
    return _instance;
  }

  VideoService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== Video Management =====

  /// Get all available videos with optional filters
  Future<List<PronunciationVideo>> getAllVideos({
    String? category,
    int? maxDifficulty,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore.collection('videos').collection('pronunciation');

      // Filter by category
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      // Filter by max difficulty
      if (maxDifficulty != null) {
        query = query.where('difficulty', isLessThanOrEqualTo: maxDifficulty);
      }

      final snapshot = await query.get();
      var videos = snapshot.docs
          .map((doc) => PronunciationVideo.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by search query (client-side)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        videos = videos.where((video) {
          return video.title.toLowerCase().contains(query) ||
              video.description.toLowerCase().contains(query) ||
              video.tags.any((tag) => tag.toLowerCase().contains(query));
        }).toList();
      }

      return videos;
    } catch (e) {
      LoggerService.error(
        'Error fetching all videos',
        tag: 'VideoService',
        exception: e,
      );
      return [];
    }
  }

  /// Get specific video by ID
  Future<PronunciationVideo?> getVideo(String videoId) async {
    try {
      final doc = await _firestore
          .collection('videos')
          .collection('pronunciation')
          .doc(videoId)
          .get();

      if (!doc.exists) return null;

      return PronunciationVideo.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching video',
        tag: 'VideoService',
        exception: e,
      );
      return null;
    }
  }

  /// Get videos by category
  Future<List<PronunciationVideo>> getVideosByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('videos')
          .collection('pronunciation')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => PronunciationVideo.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching videos by category',
        tag: 'VideoService',
        exception: e,
      );
      return [];
    }
  }

  /// Get top-rated videos
  Future<List<PronunciationVideo>> getTopRatedVideos({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('videos')
          .collection('pronunciation')
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PronunciationVideo.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching top-rated videos',
        tag: 'VideoService',
        exception: e,
      );
      return [];
    }
  }

  // ===== Progress Tracking =====

  /// Update user's video progress
  Future<void> updateVideoProgress(VideoProgress progress) async {
    try {
      await _firestore
          .collection('videoProgress')
          .doc(progress.userId)
          .collection('videos')
          .doc(progress.videoId)
          .set(progress.toJson(), SetOptions(merge: true));

      LoggerService.info(
        'Video progress updated: ${progress.videoId}',
        tag: 'VideoService',
      );
    } catch (e) {
      LoggerService.error(
        'Error updating video progress',
        tag: 'VideoService',
        exception: e,
      );
    }
  }

  /// Get user's progress for specific video
  Future<VideoProgress?> getUserVideoProgress(String userId, String videoId) async {
    try {
      final doc = await _firestore
          .collection('videoProgress')
          .doc(userId)
          .collection('videos')
          .doc(videoId)
          .get();

      if (!doc.exists) return null;

      return VideoProgress.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching user video progress',
        tag: 'VideoService',
        exception: e,
      );
      return null;
    }
  }

  /// Get user's watch history
  Future<List<VideoProgress>> getUserWatchHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('videoProgress')
          .doc(userId)
          .collection('videos')
          .orderBy('lastWatchedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => VideoProgress.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching watch history',
        tag: 'VideoService',
        exception: e,
      );
      return [];
    }
  }

  /// Get user's watched videos
  Future<List<VideoProgress>> getWatchedVideos(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('videoProgress')
          .doc(userId)
          .collection('videos')
          .where('isWatched', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => VideoProgress.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error fetching watched videos',
        tag: 'VideoService',
        exception: e,
      );
      return [];
    }
  }

  // ===== Ratings & Engagement =====

  /// Rate a video
  Future<void> rateVideo(String userId, String videoId, int rating) async {
    if (rating < 1 || rating > 5) {
      LoggerService.error(
        'Invalid rating: $rating',
        tag: 'VideoService',
      );
      return;
    }

    try {
      // Update user progress
      final progress = await getUserVideoProgress(userId, videoId);
      if (progress != null) {
        await updateVideoProgress(progress.copyWith(rating: rating));
      }

      // Update video's average rating
      await _updateVideoRating(videoId);

      LoggerService.info(
        'Video rated: $videoId, rating: $rating',
        tag: 'VideoService',
      );
    } catch (e) {
      LoggerService.error(
        'Error rating video',
        tag: 'VideoService',
        exception: e,
      );
    }
  }

  /// Like/unlike a video
  Future<void> toggleLikeVideo(String userId, String videoId) async {
    try {
      final progress = await getUserVideoProgress(userId, videoId);
      if (progress != null) {
        await updateVideoProgress(progress.copyWith(isLiked: !progress.isLiked));
      }

      // Update like count
      await _updateVideoLikeCount(videoId);

      LoggerService.info(
        'Video like toggled: $videoId',
        tag: 'VideoService',
      );
    } catch (e) {
      LoggerService.error(
        'Error toggling like',
        tag: 'VideoService',
        exception: e,
      );
    }
  }

  /// Get average rating for video
  Future<double> getAverageRating(String videoId) async {
    try {
      final doc = await _firestore
          .collection('videos')
          .collection('pronunciation')
          .doc(videoId)
          .get();

      if (!doc.exists) return 0.0;

      final data = doc.data() as Map<String, dynamic>;
      return (data['averageRating'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      LoggerService.error(
        'Error fetching average rating',
        tag: 'VideoService',
        exception: e,
      );
      return 0.0;
    }
  }

  // ===== Quizzes =====

  /// Get quiz for video
  Future<VideoQuiz?> getVideoQuiz(String videoId) async {
    try {
      final doc = await _firestore
          .collection('videoQuizzes')
          .doc(videoId)
          .get();

      if (!doc.exists) return null;

      return VideoQuiz.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching video quiz',
        tag: 'VideoService',
        exception: e,
      );
      return null;
    }
  }

  /// Submit quiz answers and get result
  Future<VideoQuizResult?> submitQuizAnswers(
    String userId,
    String videoId,
    List<String> answers,
  ) async {
    try {
      final quiz = await getVideoQuiz(videoId);
      if (quiz == null) return null;

      // Calculate score
      int correctCount = 0;
      for (int i = 0; i < answers.length && i < quiz.questions.length; i++) {
        if (answers[i] == quiz.questions[i].correctAnswer) {
          correctCount++;
        }
      }

      final score = ((correctCount / quiz.questions.length) * 100).toInt();
      final passed = score >= quiz.passingScore;

      // Get previous result or create new
      final existingResult = await getQuizResult(userId, videoId);
      final attemptCount = (existingResult?.attemptCount ?? 0) + 1;
      var badgesEarned = existingResult?.badgesEarned ?? [];

      // Award badge if passed
      if (passed && (existingResult?.passed != true)) {
        badgesEarned = [...badgesEarned, quiz.rewardBadge ?? 'video_quiz_passed'];
      }

      final result = VideoQuizResult(
        userId: userId,
        videoId: videoId,
        score: score,
        passed: passed,
        attemptCount: attemptCount,
        lastAttemptAt: DateTime.now(),
        badgesEarned: badgesEarned,
      );

      // Save result
      await _firestore
          .collection('userVideoQuizResults')
          .doc(userId)
          .collection('quizzes')
          .doc(videoId)
          .set(result.toJson(), SetOptions(merge: true));

      LoggerService.info(
        'Quiz submitted: $videoId, score: $score, passed: $passed',
        tag: 'VideoService',
      );

      return result;
    } catch (e) {
      LoggerService.error(
        'Error submitting quiz',
        tag: 'VideoService',
        exception: e,
      );
      return null;
    }
  }

  /// Get user's quiz result
  Future<VideoQuizResult?> getQuizResult(String userId, String videoId) async {
    try {
      final doc = await _firestore
          .collection('userVideoQuizResults')
          .doc(userId)
          .collection('quizzes')
          .doc(videoId)
          .get();

      if (!doc.exists) return null;

      return VideoQuizResult.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching quiz result',
        tag: 'VideoService',
        exception: e,
      );
      return null;
    }
  }

  // ===== Recommendations =====

  /// Get recommended videos for user based on watch history
  Future<List<PronunciationVideo>> getRecommendedVideos(
    String userId, {
    int limit = 10,
  }) async {
    try {
      // Get user's watch history
      final watchHistory = await getUserWatchHistory(userId);
      if (watchHistory.isEmpty) {
        // Return top-rated videos if no history
        return getTopRatedVideos(limit: limit);
      }

      // Get all videos watched by user
      final watchedVideoIds = watchHistory.map((p) => p.videoId).toSet();

      // Get user's preferred categories
      final videos = await getAllVideos();
      final watchedVideos = videos
          .where((v) => watchedVideoIds.contains(v.id))
          .toList();

      if (watchedVideos.isEmpty) {
        return getTopRatedVideos(limit: limit);
      }

      final preferredCategories = watchedVideos
          .map((v) => v.category)
          .toSet()
          .toList();

      // Get videos from preferred categories
      final recommendedVideos = videos
          .where((v) =>
              !watchedVideoIds.contains(v.id) &&
              preferredCategories.contains(v.category))
          .toList();

      // Sort by rating
      recommendedVideos.sort((a, b) => b.averageRating.compareTo(a.averageRating));

      return recommendedVideos.take(limit).toList();
    } catch (e) {
      LoggerService.error(
        'Error getting recommended videos',
        tag: 'VideoService',
        exception: e,
      );
      return [];
    }
  }

  /// Get continue watching videos (partially watched)
  Future<List<PronunciationVideo>> getContinueWatchingVideos(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final watchHistory = await getUserWatchHistory(userId, limit: 50);

      // Filter partially watched
      final partiallyWatched = watchHistory
          .where((p) => !p.isWatched && p.watchedSeconds > 0)
          .toList();

      if (partiallyWatched.isEmpty) return [];

      // Get video details
      final videos = <PronunciationVideo>[];
      for (final progress in partiallyWatched.take(limit)) {
        final video = await getVideo(progress.videoId);
        if (video != null) {
          videos.add(video);
        }
      }

      return videos;
    } catch (e) {
      LoggerService.error(
        'Error getting continue watching videos',
        tag: 'VideoService',
        exception: e,
      );
      return [];
    }
  }

  // ===== Statistics =====

  /// Get watch statistics for a video
  Future<VideoWatchStats?> getVideoWatchStats(String videoId) async {
    try {
      final doc = await _firestore
          .collection('videoStats')
          .doc(videoId)
          .get();

      if (!doc.exists) return null;

      return VideoWatchStats.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error(
        'Error fetching video stats',
        tag: 'VideoService',
        exception: e,
      );
      return null;
    }
  }

  /// Get user's video learning statistics
  Future<Map<String, dynamic>> getUserVideoStats(String userId) async {
    try {
      final watchHistory = await getUserWatchHistory(userId, limit: 1000);
      final watchedVideos = watchHistory.where((p) => p.isWatched).length;
      final totalWatchTime = watchHistory.fold<int>(0, (sum, p) => sum + p.watchedSeconds);

      // Get quiz statistics
      final quizSnapshot = await _firestore
          .collection('userVideoQuizResults')
          .doc(userId)
          .collection('quizzes')
          .get();

      final quizResults = quizSnapshot.docs
          .map((doc) => VideoQuizResult.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      final quizzesCompleted = quizResults.where((r) => r.passed).length;
      final avgQuizScore = quizResults.isNotEmpty
          ? quizResults.fold<int>(0, (sum, r) => sum + r.score) ~/ quizResults.length
          : 0;

      return {
        'videosWatched': watchedVideos,
        'totalWatchTime': totalWatchTime,
        'totalVideos': watchHistory.length,
        'quizzesCompleted': quizzesCompleted,
        'avgQuizScore': avgQuizScore,
        'lastWatched': watchHistory.isNotEmpty ? watchHistory.first.lastWatchedAt : null,
      };
    } catch (e) {
      LoggerService.error(
        'Error fetching user video stats',
        tag: 'VideoService',
        exception: e,
      );
      return {};
    }
  }

  // ===== Private Helpers =====

  /// Update video's average rating
  Future<void> _updateVideoRating(String videoId) async {
    try {
      final videosSnapshot = await _firestore
          .collection('videoProgress')
          .get();

      int totalRatings = 0;
      int ratingSum = 0;

      for (final userDoc in videosSnapshot.docs) {
        final videoProgress = await _firestore
            .collection('videoProgress')
            .doc(userDoc.id)
            .collection('videos')
            .doc(videoId)
            .get();

        if (videoProgress.exists) {
          final data = videoProgress.data() as Map<String, dynamic>;
          final rating = (data['rating'] as num?)?.toInt() ?? 0;
          if (rating > 0) {
            ratingSum += rating;
            totalRatings++;
          }
        }
      }

      final averageRating = totalRatings > 0 ? ratingSum / totalRatings : 0.0;

      await _firestore
          .collection('videos')
          .collection('pronunciation')
          .doc(videoId)
          .update({'averageRating': averageRating});
    } catch (e) {
      LoggerService.error(
        'Error updating video rating',
        tag: 'VideoService',
        exception: e,
      );
    }
  }

  /// Update video's like count
  Future<void> _updateVideoLikeCount(String videoId) async {
    try {
      final videosSnapshot = await _firestore
          .collection('videoProgress')
          .get();

      int likeCount = 0;

      for (final userDoc in videosSnapshot.docs) {
        final videoProgress = await _firestore
            .collection('videoProgress')
            .doc(userDoc.id)
            .collection('videos')
            .doc(videoId)
            .get();

        if (videoProgress.exists) {
          final data = videoProgress.data() as Map<String, dynamic>;
          final isLiked = (data['isLiked'] as bool?) ?? false;
          if (isLiked) {
            likeCount++;
          }
        }
      }

      await _firestore
          .collection('videos')
          .collection('pronunciation')
          .doc(videoId)
          .update({'likes': likeCount});
    } catch (e) {
      LoggerService.error(
        'Error updating like count',
        tag: 'VideoService',
        exception: e,
      );
    }
  }
}
