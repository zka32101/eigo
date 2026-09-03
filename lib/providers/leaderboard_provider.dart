import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../services/leaderboard_service.dart';

// Service provider
final leaderboardServiceProvider = Provider((ref) {
  return LeaderboardService();
});

// Global leaderboard provider
final globalLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getGlobalLeaderboard();
});

// Weekly leaderboard provider
final weeklyLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getWeeklyLeaderboard();
});

// Monthly leaderboard provider
final monthlyLeaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getMonthlyLeaderboard();
});

// Friend leaderboard provider
final friendsLeaderboardProvider =
    FutureProvider.family<Leaderboard, String>((ref, userId) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getFriendsLeaderboard(userId);
});

// Skill leaderboard provider
final skillLeaderboardProvider =
    FutureProvider.family<Leaderboard, String>((ref, skill) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getSkillLeaderboard(skill);
});

// Player rank statistics provider
final playerRankStatsProvider =
    FutureProvider.family<PlayerRankStats, String>((ref, userId) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getPlayerRankStats(userId);
});

// Leaderboard statistics provider
final leaderboardStatsProvider = FutureProvider<LeaderboardStats>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getLeaderboardStats();
});

// Search leaderboard provider
final searchLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final service = ref.watch(leaderboardServiceProvider);
    return service.searchLeaderboard(query);
  },
);

// Compare rankings provider
class CompareRankingsParams {
  final String userId1;
  final String userId2;

  CompareRankingsParams({
    required this.userId1,
    required this.userId2,
  });
}

final compareRankingsProvider = FutureProvider.family<RankingComparison, CompareRankingsParams>(
  (ref, params) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.comparePlayerRankings(params.userId1, params.userId2);
  },
);

// Entries around rank provider
class EntriesAroundRankParams {
  final String userId;
  final LeaderboardType type;

  EntriesAroundRankParams({
    required this.userId,
    required this.type,
  });
}

final entriesAroundRankProvider =
    FutureProvider.family<List<LeaderboardEntry>, EntriesAroundRankParams>(
  (ref, params) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.getEntriesAroundRank(params.userId, params.type);
  },
);

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
