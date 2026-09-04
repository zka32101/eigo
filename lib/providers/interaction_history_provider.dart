import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/interaction_history_model.dart';
import 'package:eigo/providers/npc_firebase_provider.dart';
import 'package:eigo/providers/user_profile_provider.dart';

/// ==================== INTERACTION HISTORY STATE ====================

/// インタラクション履歴を管理するStateNotifier
class InteractionHistoryNotifier extends StateNotifier<List<InteractionRecord>> {
  InteractionHistoryNotifier(
    this._firebaseService,
    this._userId,
  ) : super([]) {
    if (_userId != null) {
      _initializeHistory();
    }
  }

  final NPCFirebaseService _firebaseService;
  final String? _userId;

  /// 履歴を初期化
  Future<void> _initializeHistory() async {
    if (_userId == null) return;
    try {
      final history =
          await _firebaseService.getUserInteractionHistory(_userId!);
      state = history;
    } catch (e) {
      print('Error initializing interaction history: $e');
      state = [];
    }
  }

  /// インタラクションレコードを保存
  Future<void> saveRecord(InteractionRecord record) async {
    if (_userId == null) return;
    try {
      await _firebaseService.saveInteractionRecord(_userId!, record);
      state = [record, ...state];
    } catch (e) {
      print('Error saving interaction record: $e');
      rethrow;
    }
  }

  /// 複数のレコードをバッチ保存
  Future<void> batchSaveRecords(List<InteractionRecord> records) async {
    if (_userId == null) return;
    try {
      await _firebaseService.batchSaveInteractionRecords(_userId!, records);
      state = [...records, ...state];
    } catch (e) {
      print('Error batch saving records: $e');
      rethrow;
    }
  }

  /// 日付範囲で履歴をロード
  Future<void> loadHistoryByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_userId == null) return;
    try {
      final history = await _firebaseService.getInteractionHistoryByDateRange(
        _userId!,
        startDate,
        endDate,
      );
      state = history;
    } catch (e) {
      print('Error loading history by date range: $e');
      rethrow;
    }
  }

  /// NPCの履歴をロード
  Future<void> loadHistoryByNPC(String npcId) async {
    if (_userId == null) return;
    try {
      final history =
          await _firebaseService.getInteractionHistoryByNPC(_userId!, npcId);
      state = history;
    } catch (e) {
      print('Error loading history by NPC: $e');
      rethrow;
    }
  }

  /// リロード
  Future<void> reload() async {
    await _initializeHistory();
  }
}

/// インタラクション履歴プロバイダー（ユーザーIDに基づく）
final interactionHistoryProvider =
    StateNotifierProvider<InteractionHistoryNotifier, List<InteractionRecord>>(
        (ref) {
  final firebaseService = ref.watch(npcFirebaseServiceProvider);
  final userProfile = ref.watch(userProfileProvider);

  final userId = userProfile.when(
    data: (profile) => profile?['uid'] as String?,
    loading: () => null,
    error: (_, __) => null,
  );

  return InteractionHistoryNotifier(firebaseService, userId);
});

/// 特定NPCのインタラクション履歴を取得
final interactionHistoryByNPCProvider =
    Provider.family<List<InteractionRecord>, String>((ref, npcId) {
  final history = ref.watch(interactionHistoryProvider);
  return history.where((record) => record.npcId == npcId).toList();
});

/// 特定トピックのインタラクション履歴を取得
final interactionHistoryByTopicProvider =
    Provider.family<List<InteractionRecord>, String>((ref, topic) {
  final history = ref.watch(interactionHistoryProvider);
  return history.where((record) => record.conversationTopic == topic).toList();
});

/// 特定難易度のインタラクション履歴を取得
final interactionHistoryByDifficultyProvider =
    Provider.family<List<InteractionRecord>, String>((ref, difficulty) {
  final history = ref.watch(interactionHistoryProvider);
  return history.where((record) => record.difficulty == difficulty).toList();
});

/// 成功したインタラクションのみをフィルタ
final successfulInteractionsProvider = Provider<List<InteractionRecord>>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  return history.where((record) => record.wasSuccessful).toList();
});

/// 失敗したインタラクションをフィルタ
final failedInteractionsProvider = Provider<List<InteractionRecord>>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  return history.where((record) => !record.wasSuccessful).toList();
});

/// 今週のインタラクション
final thisWeekInteractionsProvider = Provider<List<InteractionRecord>>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  final now = DateTime.now();
  final weekAgo = now.subtract(Duration(days: 7));
  return history.where((r) => r.timestamp.isAfter(weekAgo)).toList();
});

/// 今日のインタラクション
final todayInteractionsProvider = Provider<List<InteractionRecord>>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return history.where((r) => r.timestamp.isAfter(today)).toList();
});

/// 平均スコア
final averageScoreProvider = Provider<double>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  if (history.isEmpty) return 0.0;
  final sum = history.fold<int>(0, (sum, r) => sum + r.responseScore);
  return sum / history.length;
});

/// 総XP獲得
final totalXPEarnedProvider = Provider<int>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  return history.fold<int>(0, (sum, r) => sum + r.xpEarned);
});

/// 総コイン獲得
final totalCoinsEarnedProvider = Provider<int>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  return history.fold<int>(0, (sum, r) => sum + r.coinsEarned);
});

/// 成功率
final successRateProvider = Provider<double>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  if (history.isEmpty) return 0.0;
  final successful = history.where((r) => r.wasSuccessful).length;
  return (successful / history.length) * 100;
});

/// 最新のインタラクション
final latestInteractionProvider = Provider<InteractionRecord?>((ref) {
  final history = ref.watch(interactionHistoryProvider);
  return history.isNotEmpty ? history.first : null;
});

/// インタラクション数
final totalInteractionsProvider = Provider<int>((ref) {
  return ref.watch(interactionHistoryProvider).length;
});
