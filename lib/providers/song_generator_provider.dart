import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song_generator_model.dart';
import '../providers/user_profile_provider.dart';

/// 童謡メロディプロバイダー
final melodyTemplatesProvider = Provider<List<TraditionalMelody>>((ref) {
  return TraditionalMelody.values.toList();
});

/// 歌生成リクエスト管理プロバイダー
final songGenerationRequestProvider = StateNotifierProvider<
    SongGenerationRequestNotifier,
    AsyncValue<SongGenerationRequest?>>((ref) {
  return SongGenerationRequestNotifier(ref);
});

class SongGenerationRequestNotifier
    extends StateNotifier<AsyncValue<SongGenerationRequest?>> {
  final Ref ref;

  SongGenerationRequestNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadLatestRequest();
  }

  Future<void> _loadLatestRequest() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final requestJson = prefs.getString('song_request_$userId');

      if (requestJson != null) {
        final request = SongGenerationRequest.fromJson(jsonDecode(requestJson));
        state = AsyncValue.data(request);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveRequest(SongGenerationRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'song_request_${request.userId}',
      jsonEncode(request.toJson()),
    );
  }

  Future<void> createRequest(
    List<String> vocabularyWords,
    String melodyType,
    String theme,
    String learningLevel,
  ) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final request = SongGenerationRequest(
      requestId: 'sr_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      vocabularyWords: vocabularyWords,
      melodyType: melodyType,
      theme: theme,
      learningLevel: learningLevel,
      lyricLanguage: 'en',
      createdAt: DateTime.now(),
    );

    await _saveRequest(request);
    state = AsyncValue.data(request);
  }
}

/// 生成された歌プロバイダー
final generatedSongsProvider = StateNotifierProvider<
    GeneratedSongsNotifier,
    AsyncValue<List<GeneratedSong>>>((ref) {
  return GeneratedSongsNotifier(ref);
});

class GeneratedSongsNotifier extends StateNotifier<AsyncValue<List<GeneratedSong>>> {
  final Ref ref;

  GeneratedSongsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final songsJson = prefs.getString('generated_songs_$userId');

      if (songsJson != null) {
        final songs =
            (jsonDecode(songsJson) as List)
                .map((e) => GeneratedSong.fromJson(e))
                .toList();
        state = AsyncValue.data(songs);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveSongs(List<GeneratedSong> songs) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'generated_songs_$userId',
      jsonEncode(songs.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> addGeneratedSong(GeneratedSong song) async {
    final currentSongs = state.value ?? [];
    final updated = [song, ...currentSongs];

    await _saveSongs(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> rateSong(String songId, int rating) async {
    final currentSongs = state.value ?? [];
    final updated = currentSongs.map((s) {
      if (s.songId == songId) {
        return GeneratedSong(
          songId: s.songId,
          userId: s.userId,
          requestId: s.requestId,
          melodyType: s.melodyType,
          englishLyrics: s.englishLyrics,
          japaneseTranslation: s.japaneseTranslation,
          lyricSections: s.lyricSections,
          audioUrl: s.audioUrl,
          bpm: s.bpm,
          musicalKey: s.musicalKey,
          ageGroup: s.ageGroup,
          learningEffectiveness: s.learningEffectiveness,
          parentalAppeal: s.parentalAppeal,
          generatedAt: s.generatedAt,
          playCount: s.playCount,
          userRating: rating,
          shared: s.shared,
          sharedAt: s.sharedAt,
        );
      }
      return s;
    }).toList();

    await _saveSongs(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> shareSong(String songId) async {
    final currentSongs = state.value ?? [];
    final updated = currentSongs.map((s) {
      if (s.songId == songId) {
        return GeneratedSong(
          songId: s.songId,
          userId: s.userId,
          requestId: s.requestId,
          melodyType: s.melodyType,
          englishLyrics: s.englishLyrics,
          japaneseTranslation: s.japaneseTranslation,
          lyricSections: s.lyricSections,
          audioUrl: s.audioUrl,
          bpm: s.bpm,
          musicalKey: s.musicalKey,
          ageGroup: s.ageGroup,
          learningEffectiveness: s.learningEffectiveness,
          parentalAppeal: s.parentalAppeal,
          generatedAt: s.generatedAt,
          playCount: s.playCount,
          userRating: s.userRating,
          shared: true,
          sharedAt: DateTime.now(),
        );
      }
      return s;
    }).toList();

    await _saveSongs(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> incrementPlayCount(String songId) async {
    final currentSongs = state.value ?? [];
    final updated = currentSongs.map((s) {
      if (s.songId == songId) {
        return GeneratedSong(
          songId: s.songId,
          userId: s.userId,
          requestId: s.requestId,
          melodyType: s.melodyType,
          englishLyrics: s.englishLyrics,
          japaneseTranslation: s.japaneseTranslation,
          lyricSections: s.lyricSections,
          audioUrl: s.audioUrl,
          bpm: s.bpm,
          musicalKey: s.musicalKey,
          ageGroup: s.ageGroup,
          learningEffectiveness: s.learningEffectiveness,
          parentalAppeal: s.parentalAppeal,
          generatedAt: s.generatedAt,
          playCount: s.playCount + 1,
          userRating: s.userRating,
          shared: s.shared,
          sharedAt: s.sharedAt,
        );
      }
      return s;
    }).toList();

    await _saveSongs(updated);
    state = AsyncValue.data(updated);
  }
}

/// ユーザーの歌ライブラリプロバイダー
final songLibraryProvider = StateNotifierProvider<
    SongLibraryNotifier,
    AsyncValue<SongLibrary?>>((ref) {
  return SongLibraryNotifier(ref);
});

class SongLibraryNotifier extends StateNotifier<AsyncValue<SongLibrary?>> {
  final Ref ref;

  SongLibraryNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final libraryJson = prefs.getString('song_library_$userId');

      if (libraryJson != null) {
        final library = SongLibrary.fromJson(jsonDecode(libraryJson));
        state = AsyncValue.data(library);
      } else {
        // 初期ライブラリ作成
        final now = DateTime.now();
        final newLibrary = SongLibrary(
          libraryId: 'sl_${userId}_${now.millisecondsSinceEpoch}',
          userId: userId,
          savedSongIds: [],
          favoriteSongIds: [],
          playHistory: [],
          firstSongGeneratedAt: now,
          totalSongsGenerated: 0,
          totalPlayTime: 0,
          lastUpdatedAt: now,
        );
        await _saveLibrary(newLibrary);
        state = AsyncValue.data(newLibrary);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveLibrary(SongLibrary library) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'song_library_${library.userId}',
      jsonEncode(library.toJson()),
    );
  }

  Future<void> saveSong(String songId) async {
    final currentLibrary = state.value;
    if (currentLibrary == null) return;

    if (currentLibrary.savedSongIds.contains(songId)) return;

    final updated = SongLibrary(
      libraryId: currentLibrary.libraryId,
      userId: currentLibrary.userId,
      savedSongIds: [...currentLibrary.savedSongIds, songId],
      favoriteSongIds: currentLibrary.favoriteSongIds,
      playHistory: currentLibrary.playHistory,
      firstSongGeneratedAt: currentLibrary.firstSongGeneratedAt,
      lastSongGeneratedAt: DateTime.now(),
      totalSongsGenerated: currentLibrary.totalSongsGenerated + 1,
      totalPlayTime: currentLibrary.totalPlayTime,
      lastUpdatedAt: DateTime.now(),
    );

    await _saveLibrary(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> toggleFavoriteSong(String songId) async {
    final currentLibrary = state.value;
    if (currentLibrary == null) return;

    final isFavorite = currentLibrary.favoriteSongIds.contains(songId);
    final updated = SongLibrary(
      libraryId: currentLibrary.libraryId,
      userId: currentLibrary.userId,
      savedSongIds: currentLibrary.savedSongIds,
      favoriteSongIds: isFavorite
          ? currentLibrary.favoriteSongIds.where((id) => id != songId).toList()
          : [...currentLibrary.favoriteSongIds, songId],
      playHistory: currentLibrary.playHistory,
      firstSongGeneratedAt: currentLibrary.firstSongGeneratedAt,
      lastSongGeneratedAt: currentLibrary.lastSongGeneratedAt,
      totalSongsGenerated: currentLibrary.totalSongsGenerated,
      totalPlayTime: currentLibrary.totalPlayTime,
      lastUpdatedAt: DateTime.now(),
    );

    await _saveLibrary(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> addToPlayHistory(String songId) async {
    final currentLibrary = state.value;
    if (currentLibrary == null) return;

    final updated = SongLibrary(
      libraryId: currentLibrary.libraryId,
      userId: currentLibrary.userId,
      savedSongIds: currentLibrary.savedSongIds,
      favoriteSongIds: currentLibrary.favoriteSongIds,
      playHistory: [songId, ...currentLibrary.playHistory.take(49)].toList(),
      firstSongGeneratedAt: currentLibrary.firstSongGeneratedAt,
      lastSongGeneratedAt: currentLibrary.lastSongGeneratedAt,
      totalSongsGenerated: currentLibrary.totalSongsGenerated,
      totalPlayTime: currentLibrary.totalPlayTime + 60, // 推定1分追加
      lastUpdatedAt: DateTime.now(),
    );

    await _saveLibrary(updated);
    state = AsyncValue.data(updated);
  }
}

/// 歌生成統計プロバイダー
final songGenerationStatsProvider = StateNotifierProvider<
    SongGenerationStatsNotifier,
    AsyncValue<SongGenerationStats?>>((ref) {
  return SongGenerationStatsNotifier(ref);
});

class SongGenerationStatsNotifier
    extends StateNotifier<AsyncValue<SongGenerationStats?>> {
  final Ref ref;

  SongGenerationStatsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('song_stats_$userId');

      if (statsJson != null) {
        final stats = SongGenerationStats.fromJson(jsonDecode(statsJson));
        state = AsyncValue.data(stats);
      } else {
        // デフォルト統計
        final now = DateTime.now();
        final newStats = SongGenerationStats(
          statsId: 'sgs_${userId}_${now.millisecondsSinceEpoch}',
          userId: userId,
          totalSongsGenerated: 0,
          averageQualityScore: 0.0,
          mostUsedMelody: 'twinkleTwinkleLittleStar',
          mostUsedTheme: 'animals',
          totalVocabularyLearned: 0,
          totalSingPracticeTime: 0,
          averageSongDuration: 120,
          estimatedLearningEffectiveness: 0.0,
          lastUpdatedAt: now,
        );
        await _saveStats(newStats);
        state = AsyncValue.data(newStats);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveStats(SongGenerationStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'song_stats_${stats.userId}',
      jsonEncode(stats.toJson()),
    );
  }

  Future<void> recordSongGeneration(
    String melodyType,
    String theme,
    int vocabularyCount,
    double qualityScore,
  ) async {
    final currentStats = state.value;
    if (currentStats == null) return;

    final updated = SongGenerationStats(
      statsId: currentStats.statsId,
      userId: currentStats.userId,
      totalSongsGenerated: currentStats.totalSongsGenerated + 1,
      averageQualityScore:
          (currentStats.averageQualityScore * currentStats.totalSongsGenerated +
                  qualityScore) /
              (currentStats.totalSongsGenerated + 1),
      mostUsedMelody: melodyType,
      mostUsedTheme: theme,
      totalVocabularyLearned:
          currentStats.totalVocabularyLearned + vocabularyCount,
      totalSingPracticeTime: currentStats.totalSingPracticeTime,
      averageSongDuration: 120,
      estimatedLearningEffectiveness:
          (currentStats.totalSongsGenerated * currentStats.estimatedLearningEffectiveness +
                  qualityScore * 0.8) /
              (currentStats.totalSongsGenerated + 1),
      firstGenerationAt: currentStats.firstGenerationAt ?? DateTime.now(),
      lastGenerationAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );

    await _saveStats(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> updatePracticeTime(int addedSeconds) async {
    final currentStats = state.value;
    if (currentStats == null) return;

    final updated = SongGenerationStats(
      statsId: currentStats.statsId,
      userId: currentStats.userId,
      totalSongsGenerated: currentStats.totalSongsGenerated,
      averageQualityScore: currentStats.averageQualityScore,
      mostUsedMelody: currentStats.mostUsedMelody,
      mostUsedTheme: currentStats.mostUsedTheme,
      totalVocabularyLearned: currentStats.totalVocabularyLearned,
      totalSingPracticeTime: currentStats.totalSingPracticeTime + addedSeconds,
      averageSongDuration: currentStats.averageSongDuration,
      estimatedLearningEffectiveness: currentStats.estimatedLearningEffectiveness,
      firstGenerationAt: currentStats.firstGenerationAt,
      lastGenerationAt: currentStats.lastGenerationAt,
      lastUpdatedAt: DateTime.now(),
    );

    await _saveStats(updated);
    state = AsyncValue.data(updated);
  }
}

/// 歌学習進捗プロバイダー
final songLearningProgressProvider = StateNotifierProvider.family<
    SongLearningProgressNotifier,
    AsyncValue<SongLearningProgress?>,
    String>((ref, songId) {
  return SongLearningProgressNotifier(ref, songId);
});

class SongLearningProgressNotifier
    extends StateNotifier<AsyncValue<SongLearningProgress?>> {
  final Ref ref;
  final String songId;

  SongLearningProgressNotifier(this.ref, this.songId)
      : super(const AsyncValue.loading()) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('song_progress_${userId}_$songId');

      if (progressJson != null) {
        final progress = SongLearningProgress.fromJson(jsonDecode(progressJson));
        state = AsyncValue.data(progress);
      } else {
        // デフォルト進捗
        final now = DateTime.now();
        final newProgress = SongLearningProgress(
          progressId:
              'slp_${userId}_${songId}_${now.millisecondsSinceEpoch}',
          userId: userId,
          songId: songId,
          totalPlays: 0,
          completeListenings: 0,
          singPracticeCount: 0,
          averageSingScore: 0,
          pronunciationImprovement: 0.0,
          lyricComprehension: 0.0,
          isLearned: false,
          lastUpdatedAt: now,
        );
        await _saveProgress(newProgress);
        state = AsyncValue.data(newProgress);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveProgress(SongLearningProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'song_progress_${progress.userId}_$songId',
      jsonEncode(progress.toJson()),
    );
  }

  Future<void> recordPlay(bool isComplete) async {
    final currentProgress = state.value;
    if (currentProgress == null) return;

    final updated = SongLearningProgress(
      progressId: currentProgress.progressId,
      userId: currentProgress.userId,
      songId: currentProgress.songId,
      totalPlays: currentProgress.totalPlays + 1,
      completeListenings:
          isComplete ? currentProgress.completeListenings + 1 : currentProgress.completeListenings,
      singPracticeCount: currentProgress.singPracticeCount,
      averageSingScore: currentProgress.averageSingScore,
      pronunciationImprovement: currentProgress.pronunciationImprovement,
      lyricComprehension: currentProgress.lyricComprehension,
      lastPlayedAt: DateTime.now(),
      firstPlayedAt: currentProgress.firstPlayedAt ?? DateTime.now(),
      isLearned: currentProgress.isLearned,
      lastUpdatedAt: DateTime.now(),
    );

    await _saveProgress(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> recordSingScore(int score) async {
    final currentProgress = state.value;
    if (currentProgress == null) return;

    final newAverage =
        (currentProgress.averageSingScore * currentProgress.singPracticeCount +
                score) /
            (currentProgress.singPracticeCount + 1);

    final updated = SongLearningProgress(
      progressId: currentProgress.progressId,
      userId: currentProgress.userId,
      songId: currentProgress.songId,
      totalPlays: currentProgress.totalPlays,
      completeListenings: currentProgress.completeListenings,
      singPracticeCount: currentProgress.singPracticeCount + 1,
      averageSingScore: newAverage.toInt(),
      pronunciationImprovement: currentProgress.pronunciationImprovement,
      lyricComprehension: currentProgress.lyricComprehension,
      lastPlayedAt: currentProgress.lastPlayedAt,
      firstPlayedAt: currentProgress.firstPlayedAt,
      isLearned: currentProgress.isLearned,
      lastUpdatedAt: DateTime.now(),
    );

    await _saveProgress(updated);
    state = AsyncValue.data(updated);
  }
}
