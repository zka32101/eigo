import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leaderboard_model.dart';
import '../services/leaderboard_service.dart';

final leaderboardServiceProvider = Provider((ref) {
  return LeaderboardService();
});

// Global leaderboard provider
final globalLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getGlobalLeaderboardRanking();
});

// Weekly leaderboard provider
final weeklyLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getWeeklyLeaderboardRanking();
});

// Monthly leaderboard provider
final monthlyLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getMonthlyLeaderboardRanking();
});

// Friend leaderboard provider
final friendsLeaderboardProvider =
    FutureProvider.family<Leaderboard, String>((ref, userId) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getFriendsLeaderboardRanking(userId);
});

// Player rank statistics provider
final playerRankStatsProvider =
    FutureProvider.family<PlayerRankStats, String>((ref, userId) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getPlayerRankStats(userId);
});

// NOTE: skillLeaderboardProvider / leaderboardStatsProvider / searchLeaderboardProvider /
// compareRankingsProvider / entriesAroundRankProvider were removed here. They called
// LeaderboardService methods (getSkillLeaderboard, getLeaderboardStats, searchLeaderboard,
// comparePlayerRankings, getEntriesAroundRank) that never existed in leaderboard_service.dart,
// and a repo-wide grep found no screen or provider referencing these providers by name
// (only this now-removed declaration site used them). They were dead code, not a reachable
// feature, so removed instead of building out unused RankingComparison/LeaderboardStats/
// search/around-rank query logic. See PR description for details.

// Refresh action for global leaderboard
final refreshGlobalLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  ref.refresh(globalLeaderboardProvider);
  return ref.watch(globalLeaderboardProvider.future);
});

// Refresh action for weekly leaderboard
final refreshWeeklyLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  ref.refresh(weeklyLeaderboardProvider);
  return ref.watch(weeklyLeaderboardProvider.future);
});

// Refresh action for monthly leaderboard
final refreshMonthlyLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  ref.refresh(monthlyLeaderboardProvider);
  return ref.watch(monthlyLeaderboardProvider.future);
});

// Leaderboard type state for UI
final leaderboardTypeProvider = StateProvider<LeaderboardType>((ref) {
  return LeaderboardType.global;
});

// Search query state for leaderboard search
final leaderboardSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Metric selection state
final rankingMetricProvider = StateProvider<RankingMetric>((ref) {
  return RankingMetric.totalScore;
});
