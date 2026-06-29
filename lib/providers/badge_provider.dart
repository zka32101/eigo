import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
