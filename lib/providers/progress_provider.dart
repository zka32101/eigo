import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

class ProgressState {
  final Set<String> clearedStages;
  final int streakDays;
  final int totalLessons;
  final int totalSpeakingPractice;
  final int totalConversations;
  final Map<String, int> stageBestScores;
  final Map<String, double> stageSpeakingAvg;
  final DateTime? lastPlayedDate;

  const ProgressState({
    this.clearedStages = const {},
    this.streakDays = 0,
    this.totalLessons = 0,
    this.totalSpeakingPractice = 0,
    this.totalConversations = 0,
    this.stageBestScores = const {},
    this.stageSpeakingAvg = const {},
    this.lastPlayedDate,
  });

  bool isCleared(String stageId) => clearedStages.contains(stageId);

  ProgressState copyWith({
    Set<String>? clearedStages,
    int? streakDays,
    int? totalLessons,
    int? totalSpeakingPractice,
    int? totalConversations,
    Map<String, int>? stageBestScores,
    Map<String, double>? stageSpeakingAvg,
    DateTime? lastPlayedDate,
  }) {
    return ProgressState(
      clearedStages: clearedStages ?? this.clearedStages,
      streakDays: streakDays ?? this.streakDays,
      totalLessons: totalLessons ?? this.totalLessons,
      totalSpeakingPractice: totalSpeakingPractice ?? this.totalSpeakingPractice,
      totalConversations: totalConversations ?? this.totalConversations,
      stageBestScores: stageBestScores ?? this.stageBestScores,
      stageSpeakingAvg: stageSpeakingAvg ?? this.stageSpeakingAvg,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressState &&
          runtimeType == other.runtimeType &&
          clearedStages == other.clearedStages &&
          streakDays == other.streakDays &&
          totalLessons == other.totalLessons &&
          totalSpeakingPractice == other.totalSpeakingPractice &&
          totalConversations == other.totalConversations &&
          stageBestScores == other.stageBestScores &&
          stageSpeakingAvg == other.stageSpeakingAvg &&
          lastPlayedDate == other.lastPlayedDate;

  @override
  int get hashCode =>
      clearedStages.hashCode ^
      streakDays.hashCode ^
      totalLessons.hashCode ^
      totalSpeakingPractice.hashCode ^
      totalConversations.hashCode ^
      stageBestScores.hashCode ^
      stageSpeakingAvg.hashCode ^
      lastPlayedDate.hashCode;
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(const ProgressState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cleared = prefs.getStringList('cleared_stages') ?? [];
    final streak = prefs.getInt('streak_days') ?? 0;
    final lessons = prefs.getInt('total_lessons') ?? 0;
    final speaking = prefs.getInt('total_speaking') ?? 0;
    final conversations = prefs.getInt('total_conversations') ?? 0;

    state = state.copyWith(
      clearedStages: cleared.toSet(),
      streakDays: streak,
      totalLessons: lessons,
      totalSpeakingPractice: speaking,
      totalConversations: conversations,
    );
  }

  /// ステージ完了を記録し、獲得コイン数を返す
  Future<int> completeStage(String stageId, int score, double speakingAvg) async {
    final prefs = await SharedPreferences.getInstance();
    final cleared = {...state.clearedStages, stageId};
    final bestScores = Map<String, int>.from(state.stageBestScores);
    final speakingAvgs = Map<String, double>.from(state.stageSpeakingAvg);

    final prev = bestScores[stageId] ?? 0;
    if (score > prev) bestScores[stageId] = score;
    speakingAvgs[stageId] = speakingAvg;

    final newLessons = state.totalLessons + 1;
    final today = DateTime.now();
    int newStreak = state.streakDays;

    if (state.lastPlayedDate != null) {
      final diff = today.difference(state.lastPlayedDate!).inDays;
      if (diff == 1) {
        newStreak++;
      } else if (diff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    state = state.copyWith(
      clearedStages: cleared,
      stageBestScores: bestScores,
      stageSpeakingAvg: speakingAvgs,
      totalLessons: newLessons,
      streakDays: newStreak,
      lastPlayedDate: today,
    );

    await prefs.setStringList('cleared_stages', cleared.toList());
    await prefs.setInt('streak_days', newStreak);
    await prefs.setInt('total_lessons', newLessons);

    final coinsEarned = (score ~/ 10) + 5;

    FirebaseService().syncProgress(
      clearedStages: cleared,
      streakDays: newStreak,
      totalLessons: newLessons,
      totalSpeakingPractice: state.totalSpeakingPractice,
      stageBestScores: bestScores,
    );

    return coinsEarned;
  }

  Future<void> addSpeakingPractice(int count, {bool isConversation = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final newSpeaking = state.totalSpeakingPractice + count;
    final newConv = isConversation ? state.totalConversations + 1 : state.totalConversations;

    state = state.copyWith(
      totalSpeakingPractice: newSpeaking,
      totalConversations: newConv,
    );
    await prefs.setInt('total_speaking', newSpeaking);
    await prefs.setInt('total_conversations', newConv);
  }
}

/// 学習進捗状態管理プロバイダ
///
/// 最適化:
/// - .autoDispose: ウィジェットが利用されなくなると自動的にリソースを解放
///   メモリ使用量を削減し、アプリのパフォーマンスを向上
/// - ProgressState に == と hashCode を実装
///   進捗データの比較を正確に行い、不要なリビルドを削減
///   特にMap型フィールド(stageBestScores, stageSpeakingAvg)の比較が最適化される
///
/// 使用例:
/// - final progress = ref.watch(progressProvider);
/// - final streak = ref.watch(progressProvider.select((p) => p.streakDays));
/// - final isStageCleared = ref.watch(progressProvider.select((p) => p.isCleared(stageId)));
final progressProvider =
    StateNotifierProvider.autoDispose<ProgressNotifier, ProgressState>(
  (ref) => ProgressNotifier(),
);
