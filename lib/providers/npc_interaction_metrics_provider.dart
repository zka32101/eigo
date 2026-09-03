import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/interaction_history_model.dart';
import 'package:eigo/providers/npc_firebase_provider.dart';
import 'package:eigo/providers/user_profile_provider.dart';

/// ==================== NPC INTERACTION METRICS STATE ====================

/// NPC インタラクションメトリクスを管理するStateNotifier
class NPCInteractionMetricsNotifier
    extends StateNotifier<List<NPCInteractionMetrics>> {
  NPCInteractionMetricsNotifier(
    this._firebaseService,
    this._userId,
  ) : super([]) {
    if (_userId != null) {
      _initializeMetrics();
    }
  }

  final NPCFirebaseService _firebaseService;
  final String? _userId;

  /// メトリクスを初期化
  Future<void> _initializeMetrics() async {
    if (_userId == null) return;
    try {
      final metrics = await _firebaseService.getUserAllNPCMetrics(_userId!);
      state = metrics;
    } catch (e) {
      print('Error initializing NPC metrics: $e');
      state = [];
    }
  }

  /// メトリクスを保存/更新
  Future<void> saveMetrics(NPCInteractionMetrics metrics) async {
    if (_userId == null) return;
    try {
      await _firebaseService.saveNPCInteractionMetrics(_userId!, metrics);
      state = [
        ...state.where((m) => m.npcId != metrics.npcId),
        metrics,
      ];
    } catch (e) {
      print('Error saving NPC metrics: $e');
      rethrow;
    }
  }

  /// 総インタラクション数を増加
  Future<void> incrementInteractionCount(String npcId) async {
    if (_userId == null) return;
    try {
      final metrics = await _firebaseService.getNPCInteractionMetrics(
        _userId!,
        npcId,
      );
      if (metrics != null) {
        final updated = metrics.copyWith(
          totalInteractions: metrics.totalInteractions + 1,
          lastInteractionAt: DateTime.now(),
        );
        await saveMetrics(updated);
      }
    } catch (e) {
      print('Error incrementing interaction count: $e');
      rethrow;
    }
  }

  /// 平均スコアを更新
  Future<void> updateAverageScore(String npcId, int newScore) async {
    if (_userId == null) return;
    try {
      final metrics = await _firebaseService.getNPCInteractionMetrics(
        _userId!,
        npcId,
      );
      if (metrics != null) {
        final totalScore = (metrics.averageScore * metrics.totalInteractions) +
            newScore;
        final newAverage = totalScore / (metrics.totalInteractions + 1);

        final updated = metrics.copyWith(
          averageScore: newAverage,
        );
        await saveMetrics(updated);
      }
    } catch (e) {
      print('Error updating average score: $e');
      rethrow;
    }
  }

  /// トピックを発見
  Future<void> addDiscoveredTopic(String npcId, String topic) async {
    if (_userId == null) return;
    try {
      final metrics = await _firebaseService.getNPCInteractionMetrics(
        _userId!,
        npcId,
      );
      if (metrics != null && !metrics.discoveredTopics.contains(topic)) {
        final updated = metrics.copyWith(
          discoveredTopics: [...metrics.discoveredTopics, topic],
        );
        await saveMetrics(updated);
      }
    } catch (e) {
      print('Error adding discovered topic: $e');
      rethrow;
    }
  }

  /// リロード
  Future<void> reload() async {
    await _initializeMetrics();
  }
}

/// NPC インタラクションメトリクスプロバイダー（ユーザーIDに基づく）
final npcInteractionMetricsProvider = StateNotifierProvider<
    NPCInteractionMetricsNotifier,
    List<NPCInteractionMetrics>>((ref) {
  final firebaseService = ref.watch(npcFirebaseServiceProvider);
  final userProfile = ref.watch(userProfileProvider);

  final userId = userProfile.when(
    data: (profile) => profile?['uid'] as String?,
    loading: () => null,
    error: (_, __) => null,
  );

  return NPCInteractionMetricsNotifier(firebaseService, userId);
});

/// 特定NPCのメトリクスを取得
final npcMetricsByIdProvider =
    Provider.family<NPCInteractionMetrics?, String>((ref, npcId) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  try {
    return metrics.firstWhere((m) => m.npcId == npcId);
  } catch (e) {
    return null;
  }
});

/// 平均スコアでソートされたメトリクス
final metricsByAverageScoreProvider = Provider<List<NPCInteractionMetrics>>(
    (ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.toList()
    ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
});

/// 総インタラクション数でソートされたメトリクス
final metricsByTotalInteractionsProvider = Provider<List<NPCInteractionMetrics>>(
    (ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.toList()
    ..sort((a, b) => b.totalInteractions.compareTo(a.totalInteractions));
});

/// 関係レベルでソートされたメトリクス
final metricsByRelationshipLevelProvider = Provider<List<NPCInteractionMetrics>>(
    (ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.toList()
    ..sort((a, b) => b.relationshipLevel.compareTo(a.relationshipLevel));
});

/// 総XP獲得でソートされたメトリクス
final metricsByTotalXPProvider = Provider<List<NPCInteractionMetrics>>(
    (ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.toList()
    ..sort((a, b) => b.totalXPEarned.compareTo(a.totalXPEarned));
});

/// 連続日数でソートされたメトリクス
final metricsByConsecutiveDaysProvider = Provider<List<NPCInteractionMetrics>>(
    (ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.toList()
    ..sort((a, b) =>
        b.currentConsecutiveDays.compareTo(a.currentConsecutiveDays));
});

/// 全体の平均スコア（全NPC）
final overallAverageScoreProvider = Provider<double>((ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  if (metrics.isEmpty) return 0.0;
  final sum = metrics.fold<double>(0, (sum, m) => sum + m.averageScore);
  return sum / metrics.length;
});

/// 全体の総インタラクション数
final overallTotalInteractionsProvider = Provider<int>((ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.fold<int>(0, (sum, m) => sum + m.totalInteractions);
});

/// 全体の総XP獲得
final overallTotalXPProvider = Provider<int>((ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.fold<int>(0, (sum, m) => sum + m.totalXPEarned);
});

/// 全体の総コイン獲得
final overallTotalCoinsProvider = Provider<int>((ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  return metrics.fold<int>(0, (sum, m) => sum + m.totalCoinsEarned);
});

/// 発見されたトピック数（ユニーク）
final uniqueDiscoveredTopicsProvider = Provider<int>((ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  final topics = <String>{};
  for (final metric in metrics) {
    topics.addAll(metric.discoveredTopics);
  }
  return topics.length;
});

/// 最高連続日数
final maxConsecutiveDaysProvider = Provider<int>((ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  if (metrics.isEmpty) return 0;
  return metrics.fold<int>(
    0,
    (max, m) => m.maxConsecutiveDays > max ? m.maxConsecutiveDays : max,
  );
});

/// 難易度別成功率をマージ（全NPC）
final mergedSuccessRateByDifficultyProvider =
    Provider<Map<String, double>>((ref) {
  final metrics = ref.watch(npcInteractionMetricsProvider);
  final merged = <String, List<double>>{};

  for (final metric in metrics) {
    metric.successRateByDifficulty.forEach((difficulty, rate) {
      merged.putIfAbsent(difficulty, () => []).add(rate);
    });
  }

  // 各難易度の平均成功率を計算
  final result = <String, double>{};
  merged.forEach((difficulty, rates) {
    if (rates.isNotEmpty) {
      result[difficulty] = rates.reduce((a, b) => a + b) / rates.length;
    }
  });

  return result;
});
