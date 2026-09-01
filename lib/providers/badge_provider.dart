import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/badge_model.dart';
import 'progress_provider.dart';

class BadgeState {
  final List<EarnedBadge> earnedBadges;
  final List<BadgeModel> newlyEarned;

  const BadgeState({
    this.earnedBadges = const [],
    this.newlyEarned = const [],
  });

  Set<String> get earnedIds => earnedBadges.map((e) => e.badge.id).toSet();
}

class BadgeNotifier extends StateNotifier<BadgeState> {
  BadgeNotifier() : super(const BadgeState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final earnedKeys = prefs.getStringList('earned_badges') ?? [];
    final earned = eigoBadges
        .where((b) => earnedKeys.contains(b.id))
        .map((b) => EarnedBadge(badge: b, earnedAt: DateTime.now()))
        .toList();
    state = BadgeState(earnedBadges: earned);
  }

  Future<List<BadgeModel>> checkAndAward(
    ProgressState progress, {
    int? lessonScore,
    int? lessonTotal,
    double? speakingAvgScore,
    double? listeningAccuracy,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final earnedIds = state.earnedIds;
    final newlyEarned = <BadgeModel>[];
    final newEarned = List<EarnedBadge>.from(state.earnedBadges);

    void award(String id) {
      if (earnedIds.contains(id)) return;
      final badge = eigoBadges.firstWhere((b) => b.id == id, orElse: () => throw StateError('badge $id not found'));
      newEarned.add(EarnedBadge(badge: badge, earnedAt: DateTime.now()));
      newlyEarned.add(badge);
    }

    if (progress.totalLessons >= 1) award('firstLesson');
    if (progress.totalSpeakingPractice >= 30) award('wordMaster');
    if (progress.totalSpeakingPractice >= 70) award('phraseMaster');
    if (progress.totalConversations >= 20) award('conversationChamp');
    if (progress.streakDays >= 7) award('streakWeek');
    if (progress.streakDays >= 30) award('streakMonth');

    if (progress.clearedStages.contains('stage_1')) award('stage1Clear');
    if (progress.clearedStages.contains('stage_5')) award('stage5Clear');
    if (progress.clearedStages.contains('stage_10')) award('stage10Clear');

    if (lessonScore != null && lessonTotal != null && lessonTotal > 0) {
      if (lessonScore / lessonTotal >= 0.95) award('perfectScore');
    }
    if (speakingAvgScore != null && speakingAvgScore >= 85) award('speakingPro');
    if (listeningAccuracy != null && listeningAccuracy >= 0.90) award('listeningPro');

    if (newlyEarned.isNotEmpty) {
      state = BadgeState(earnedBadges: newEarned, newlyEarned: newlyEarned);
      await prefs.setStringList('earned_badges', newEarned.map((e) => e.badge.id).toList());
    }
    return newlyEarned;
  }

  void clearNewlyEarned() {
    state = BadgeState(earnedBadges: state.earnedBadges);
  }
}

final badgeProvider = StateNotifierProvider<BadgeNotifier, BadgeState>(
  (ref) => BadgeNotifier(),
);

// Additional badge progress tracking

/// バッジ進捗を管理
final badgeProgressProvider =
    StateNotifierProvider<BadgeProgressNotifier, List<BadgeProgress>>((ref) {
  return BadgeProgressNotifier();
});

class BadgeProgressNotifier extends StateNotifier<List<BadgeProgress>> {
  static const String _storageKey = 'eigo_kore_badge_progress';

  BadgeProgressNotifier() : super([]) {
    _loadProgress();
  }

  /// 進捗をロード
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final items = decoded
            .map((json) => BadgeProgress.fromJson(json as Map<String, dynamic>))
            .toList();
        state = items;
      } catch (e) {
        print('Error loading badge progress: $e');
      }
    } else {
      _initializeDefaultProgress();
    }
  }

  /// デフォルト進捗を初期化
  void _initializeDefaultProgress() {
    state = [
      BadgeProgress(
        badgeId: 'first_steps',
        title: 'はじめの一歩',
        icon: '🌱',
        rarity: BadgeRarity.common,
        currentValue: 0,
        targetValue: 1,
      ),
      BadgeProgress(
        badgeId: 'hot_streak',
        title: '熱いストリーク',
        icon: '🔥',
        rarity: BadgeRarity.uncommon,
        currentValue: 0,
        targetValue: 7,
      ),
      BadgeProgress(
        badgeId: 'legendary_streak',
        title: '伝説のストリーク',
        icon: '👑',
        rarity: BadgeRarity.legendary,
        currentValue: 0,
        targetValue: 30,
      ),
    ];
  }

  /// 進捗を保存
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// バッジの進捗を更新
  Future<void> updateProgress(String badgeId, int newValue) async {
    final index = state.indexWhere((b) => b.badgeId == badgeId);
    if (index >= 0) {
      final progress = state[index];
      final isNowUnlocked = newValue >= progress.targetValue;

      state = [
        ...state.sublist(0, index),
        progress.copyWith(
          currentValue: newValue,
          isUnlocked: isNowUnlocked,
          unlockedAt: isNowUnlocked && !progress.isUnlocked ? DateTime.now() : progress.unlockedAt,
        ),
        ...state.sublist(index + 1),
      ];
      await _saveProgress();
    }
  }

  /// アンロック済みバッジを取得
  List<BadgeProgress> getUnlockedBadges() {
    return state.where((b) => b.isUnlocked).toList();
  }

  /// 近日中にアンロック可能なバッジを取得
  List<BadgeProgress> getNearbyBadges() {
    return state.where((b) => !b.isUnlocked && b.progress >= 0.5).toList();
  }

  /// 全体の進捗を取得
  double getOverallProgress() {
    if (state.isEmpty) return 0.0;
    final totalProgress = state.fold<double>(0, (sum, badge) => sum + badge.progress);
    return totalProgress / state.length;
  }
}
