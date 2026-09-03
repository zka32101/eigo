import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pronunciation_video_model.dart';
import '../services/logger_service.dart';

// === Providers ===

/// アクティブな記録（30日未経過）
final activeRecordsProvider =
    StateNotifierProvider<ActiveRecordsNotifier, List<PronunciationVideoRecord>>(
  (ref) => ActiveRecordsNotifier(),
);

/// 完了した比較（30日経過・動画生成済み）
final completedComparisonsProvider =
    StateNotifierProvider<CompletedComparisonsNotifier, List<PronunciationVideoComparison>>(
  (ref) => CompletedComparisonsNotifier(),
);

/// 発音成長の進捗情報
final pronunciationProgressProvider =
    StateNotifierProvider<PronunciationProgressNotifier, PronunciationProgress?>(
  (ref) => PronunciationProgressNotifier(),
);

/// 発音動画の統計
final pronunciationVideoStatsProvider =
    StateNotifierProvider<PronunciationVideoStatsNotifier, PronunciationVideoStats>(
  (ref) => PronunciationVideoStatsNotifier(),
);

/// 利用可能なマイルストーン
final milestonesProvider = Provider<List<PronunciationMilestone>>((ref) {
  return _initializeMilestones();
});

/// 比較可能な記録（30日経過したもの）
final readyForComparisonProvider =
    FutureProvider.autoDispose<List<PronunciationVideoRecord>>((ref) async {
  final records = ref.watch(activeRecordsProvider);
  final now = DateTime.now();

  return records.where((record) {
    final daysPassed = now.difference(record.recordedAt).inDays;
    return daysPassed >= 30;
  }).toList();
});

// === State Notifiers ===

class ActiveRecordsNotifier extends StateNotifier<List<PronunciationVideoRecord>> {
  static const _storageKey = 'eigo_kore_active_pronunciation_records';

  ActiveRecordsNotifier() : super([]) {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        state = jsonList
            .map((e) => PronunciationVideoRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      LoggerService.error('Failed to load active records', tag: 'ActiveRecordsNotifier', exception: e);
    }
  }

  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      LoggerService.error('Failed to save active records', tag: 'ActiveRecordsNotifier', exception: e);
    }
  }

  /// 新しい記録を追加（学習後に自動的に呼び出される）
  Future<void> addRecord({
    required String phrase,
    required String meaning,
    required int initialScore,
    required String category,
    required String difficulty,
  }) async {
    final recordId = 'record_${DateTime.now().millisecondsSinceEpoch}';
    const audioReference = 'mock_audio_reference'; // 実運用時は音声ファイルパス

    final newRecord = PronunciationVideoRecord(
      recordId: recordId,
      userId: 'user_001', // 実運用時は実際のユーザーID
      phrase: phrase,
      meaning: meaning,
      initialScore: initialScore,
      audioReference: audioReference,
      recordedAt: DateTime.now(),
      category: category,
      difficulty: difficulty,
    );

    state = [...state, newRecord];
    await _saveRecords();
  }

  /// 比較完了後、記録を履歴に移動
  Future<void> removeRecord(String recordId) async {
    state = state.where((r) => r.recordId != recordId).toList();
    await _saveRecords();
  }

  /// 全記録をクリア（テスト用）
  Future<void> clearAll() async {
    state = [];
    await _saveRecords();
  }
}

class CompletedComparisonsNotifier extends StateNotifier<List<PronunciationVideoComparison>> {
  static const _storageKey = 'eigo_kore_completed_pronunciation_videos';

  CompletedComparisonsNotifier() : super([]) {
    _loadComparisons();
  }

  Future<void> _loadComparisons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        state = jsonList
            .map((e) => PronunciationVideoComparison.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      LoggerService.error('Failed to load completed comparisons', tag: 'CompletedComparisonsNotifier', exception: e);
    }
  }

  Future<void> _saveComparisons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      LoggerService.error('Failed to save completed comparisons', tag: 'CompletedComparisonsNotifier', exception: e);
    }
  }

  /// 30日後の比較を生成（初回記録とのスコア比較）
  Future<void> generateComparison(
    PronunciationVideoRecord originalRecord,
    int finalScore,
  ) async {
    final scoreImprovement = finalScore - originalRecord.initialScore;
    final improvementPercentage =
        (scoreImprovement / originalRecord.initialScore * 100).clamp(-100, 300).toDouble();

    // 成長レベルを判定
    String growthLevel;
    if (scoreImprovement >= 30) {
      growthLevel = 'excellent'; // 🌟
    } else if (scoreImprovement >= 20) {
      growthLevel = 'advanced'; // ⭐
    } else if (scoreImprovement >= 10) {
      growthLevel = 'intermediate'; // 📈
    } else if (scoreImprovement >= 0) {
      growthLevel = 'beginner'; // 📊
    } else {
      growthLevel = 'novice'; // 📉
    }

    // 各指標の改善度をシミュレート（実際は音声解析結果）
    final accuracyImprovement = (scoreImprovement / 100).clamp(0.0, 1.0);
    final speedImprovement = (scoreImprovement / 80).clamp(0.0, 1.0);
    final intonationImprovement = (scoreImprovement / 120).clamp(0.0, 1.0);

    // 30日間のデータ（実運用時はFirestoreから取得）
    const consistencyDays = 25; // モック：25日間継続学習
    const phrasesLearned = 45; // モック：45フレーズ学習

    // 報酬計算
    final rewardCoins = scoreImprovement ~/ 2 + 10; // 基本報酬

    final comparisonId = 'comparison_${DateTime.now().millisecondsSinceEpoch}';
    const audioReference = 'mock_audio_reference';

    final newComparison = PronunciationVideoComparison(
      comparisonId: comparisonId,
      recordId: originalRecord.recordId,
      userId: originalRecord.userId,
      finalScore: finalScore,
      finalAudioReference: audioReference,
      scoreImprovement: scoreImprovement,
      improvementPercentage: improvementPercentage,
      growthLevel: growthLevel,
      accuracyImprovement: accuracyImprovement,
      speedImprovement: speedImprovement,
      intonationImprovement: intonationImprovement,
      generatedAt: DateTime.now(),
      consistencyDays: consistencyDays,
      phrasesLearned: phrasesLearned,
      rewardCoins: rewardCoins,
      badgeUnlockedAt: scoreImprovement >= 25 ? DateTime.now() : null,
    );

    state = [...state, newComparison];
    await _saveComparisons();
  }
}

class PronunciationProgressNotifier extends StateNotifier<PronunciationProgress?> {
  static const _storageKey = 'eigo_kore_pronunciation_progress';

  PronunciationProgressNotifier() : super(null) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        state = PronunciationProgress.fromJson(jsonDecode(jsonString));
      } else {
        // 初期化
        state = PronunciationProgress(
          progressId: 'progress_initial',
          userId: 'user_001',
          totalRecords: 0,
          videosGenerated: 0,
          averageImprovement: 0.0,
          maxImprovement: 0,
          minImprovement: 0,
          activeRecords: [],
          completedComparisons: [],
          averageVideoScore: 0.0,
          averageInitialScore: 0.0,
          averageFinalScore: 0.0,
          lastUpdatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      LoggerService.error('Failed to load pronunciation progress', tag: 'PronunciationProgressNotifier', exception: e);
    }
  }

  Future<void> _saveProgress() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state!.toJson()));
    } catch (e) {
      LoggerService.error('Failed to save pronunciation progress', tag: 'PronunciationProgressNotifier', exception: e);
    }
  }

  /// 進捗情報を更新（記録と比較から自動計算）
  Future<void> updateProgress({
    required List<PronunciationVideoRecord> activeRecords,
    required List<PronunciationVideoComparison> completedComparisons,
  }) async {
    if (state == null) return;

    int totalRecords = activeRecords.length + completedComparisons.length;
    int videosGenerated = completedComparisons.length;

    double averageImprovement = 0.0;
    int maxImprovement = 0;
    int minImprovement = 0;

    if (completedComparisons.isNotEmpty) {
      final improvements = completedComparisons.map((c) => c.scoreImprovement).toList();
      averageImprovement = improvements.reduce((a, b) => a + b) / improvements.length;
      maxImprovement = improvements.reduce((a, b) => a > b ? a : b);
      minImprovement = improvements.reduce((a, b) => a < b ? a : b);
    }

    double averageVideoScore = 0.0;
    double averageInitialScore = 0.0;
    double averageFinalScore = 0.0;

    if (completedComparisons.isNotEmpty) {
      averageInitialScore = completedComparisons
              .map((c) => c.finalScore - c.scoreImprovement)
              .reduce((a, b) => a + b) /
          completedComparisons.length;
      averageFinalScore =
          completedComparisons.map((c) => c.finalScore).reduce((a, b) => a + b) /
              completedComparisons.length;
      averageVideoScore = (averageInitialScore + averageFinalScore) / 2;
    }

    state = PronunciationProgress(
      progressId: state!.progressId,
      userId: state!.userId,
      totalRecords: totalRecords,
      videosGenerated: videosGenerated,
      averageImprovement: averageImprovement,
      maxImprovement: maxImprovement,
      minImprovement: minImprovement,
      activeRecords: activeRecords,
      completedComparisons: completedComparisons,
      averageVideoScore: averageVideoScore,
      averageInitialScore: averageInitialScore,
      averageFinalScore: averageFinalScore,
      lastUpdatedAt: DateTime.now(),
    );

    await _saveProgress();
  }
}

class PronunciationVideoStatsNotifier extends StateNotifier<PronunciationVideoStats> {
  static const _storageKey = 'eigo_kore_pronunciation_video_stats';

  PronunciationVideoStatsNotifier()
      : super(
          PronunciationVideoStats(
            statsId: 'stats_initial',
            userId: 'user_001',
            totalImprovement: 0,
            averageConsistencyDays: 0.0,
            unlockedMilestones: [],
            totalRewardCoins: 0,
            specialBadgesEarned: 0,
            subscriptionRetentionScore: 0.0,
            updatedAt: DateTime.now(),
          ),
        ) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        state = PronunciationVideoStats.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      LoggerService.error('Failed to load pronunciation video stats', tag: 'PronunciationVideoStatsNotifier', exception: e);
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      LoggerService.error('Failed to save pronunciation video stats', tag: 'PronunciationVideoStatsNotifier', exception: e);
    }
  }

  /// 統計を更新（比較生成時に呼び出す）
  Future<void> updateStats({
    required List<PronunciationVideoComparison> comparisons,
  }) async {
    if (comparisons.isEmpty) return;

    int totalImprovement = 0;
    String? bestImprovementPhrase;
    int? bestImprovementValue;
    double totalConsistencyDays = 0;

    for (var comparison in comparisons) {
      totalImprovement += comparison.scoreImprovement;
      totalConsistencyDays += comparison.consistencyDays;

      if (bestImprovementValue == null || comparison.scoreImprovement > bestImprovementValue) {
        bestImprovementValue = comparison.scoreImprovement;
        bestImprovementPhrase = 'Phrase from ${comparison.comparisonId}';
      }
    }

    double averageConsistencyDays = totalConsistencyDays / comparisons.length;

    // マイルストーン判定（実装例）
    List<String> unlockedMilestones = [];
    if (comparisons.isNotEmpty) {
      unlockedMilestones.add('first_video');
    }
    if (comparisons.length >= 10) {
      unlockedMilestones.add('10_videos_milestone');
    }
    if (averageConsistencyDays >= 30) {
      unlockedMilestones.add('consistency_30days');
    }
    if (totalImprovement >= 100) {
      unlockedMilestones.add('total_improvement_100');
    }

    int totalRewardCoins = 0;
    int specialBadgesEarned = 0;
    for (var comparison in comparisons) {
      totalRewardCoins += comparison.rewardCoins;
      if (comparison.badgeUnlockedAt != null) {
        specialBadgesEarned++;
      }
    }

    // 親向け課金インセンティブスコア計算
    // 動画数、平均改善、継続性から計算
    double retentionScore = (comparisons.length / 10 * 0.3 + // 動画数
            totalImprovement / 200 * 0.4 + // 改善度
            averageConsistencyDays / 30 * 0.3) // 継続性
        .clamp(0.0, 1.0);

    state = PronunciationVideoStats(
      statsId: state.statsId,
      userId: state.userId,
      totalImprovement: totalImprovement,
      bestImprovementPhrase: bestImprovementPhrase,
      bestImprovementValue: bestImprovementValue,
      averageConsistencyDays: averageConsistencyDays,
      unlockedMilestones: unlockedMilestones,
      totalRewardCoins: totalRewardCoins,
      specialBadgesEarned: specialBadgesEarned,
      subscriptionRetentionScore: retentionScore,
      lastSuccessfulComparisonAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveStats();
  }
}

// === Mock Data ===

List<PronunciationMilestone> _initializeMilestones() {
  return [
    PronunciationMilestone(
      milestoneId: 'milestone_first_video',
      name: '初回の成長動画',
      description: '30日後に初めての成長動画を生成しました',
      icon: '🎬',
      conditionType: 'first_video',
      conditionValue: 1,
      rewardCoins: 50,
      specialBadge: 'first_video_badge',
      parental_appealScore: 0.8,
    ),
    PronunciationMilestone(
      milestoneId: 'milestone_10_videos',
      name: '10本の成長動画',
      description: '10本の成長動画を生成しました',
      icon: '🎥',
      conditionType: 'total_videos',
      conditionValue: 10,
      rewardCoins: 200,
      specialBadge: '10_videos_badge',
      parental_appealScore: 0.7,
    ),
    PronunciationMilestone(
      milestoneId: 'milestone_30_improvement',
      name: '30点以上の改善',
      description: 'ある1つの発音で30点以上改善しました',
      icon: '📈',
      conditionType: 'improvement_threshold',
      conditionValue: 30,
      rewardCoins: 150,
      specialBadge: 'improvement_30_badge',
      parental_appealScore: 0.9,
    ),
    PronunciationMilestone(
      milestoneId: 'milestone_consistency_30',
      name: '30日間の継続学習',
      description: '30日間連続で学習記録を作成しました',
      icon: '🔥',
      conditionType: 'consistency',
      conditionValue: 30,
      rewardCoins: 300,
      specialBadge: 'consistency_badge',
      parental_appealScore: 0.95,
    ),
    PronunciationMilestone(
      milestoneId: 'milestone_total_improvement',
      name: '累計100点改善',
      description: '全動画の累計改善点が100を超えました',
      icon: '🌟',
      conditionType: 'total_improvement',
      conditionValue: 100,
      rewardCoins: 500,
      specialBadge: 'master_badge',
      parental_appealScore: 0.85,
    ),
  ];
}

// Mock database for comparison simulation
Map<String, dynamic> _generateMockComparison(
  PronunciationVideoRecord record,
  int finalScore,
) {
  return {
    'finalScore': finalScore,
    'audioReference': 'mock_audio_comparison',
    'accuracy': (finalScore / 100).clamp(0.0, 1.0),
  };
}
