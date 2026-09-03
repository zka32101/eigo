import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../services/leaderboard_service.dart';

/// Singleton provider for LeaderboardService
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService();
});

/// Parameter class for update score action
class UpdateScoreParams {
  final String userId;
  final int pointsEarned;

  UpdateScoreParams({
    required this.userId,
    required this.pointsEarned,
  });
}

/// ==================== LEADERBOARD QUERY PROVIDERS ====================

/// Get global leaderboard
final globalLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getGlobalLeaderboard(limit: 100);
});

/// Stream global leaderboard for real-time updates
final globalLeaderboardStreamProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final service = ref.watch(leaderboardServiceProvider);
  return service.streamGlobalLeaderboard(limit: 100);
});

/// Get level-specific leaderboard
final levelLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, int>((ref, level) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getLevelLeaderboard(level, limit: 100);
});

/// Get weekly leaderboard
final weeklyLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getWeeklyLeaderboard(limit: 100);
});

/// Get friends leaderboard
final friendsLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, String>((ref, userId) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getFriendsLeaderboard(userId, limit: 100);
});

/// Get user's rank and position
final userRankProvider = FutureProvider.family<LeaderboardEntry?, String>((ref, userId) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getUserRank(userId);
});

/// ==================== ACTION PROVIDERS ====================

/// Update user score action
final updateScoreActionProvider = StateProvider<UpdateScoreParams?>((ref) => null);

final updateScoreProvider = FutureProvider<bool>((ref) async {
  final params = ref.watch(updateScoreActionProvider);
  if (params == null) return false;

  final service = ref.watch(leaderboardServiceProvider);
  final result = await service.updateUserScore(params.userId, params.pointsEarned);

  // Invalidate related providers
  if (result) {
    ref.invalidate(globalLeaderboardProvider);
    ref.invalidate(globalLeaderboardStreamProvider);
    ref.invalidate(userRankProvider(params.userId));
    ref.invalidate(weeklyLeaderboardProvider);
  }

  return result;
});

/// ==================== UI STATE PROVIDERS ====================

/// Current selected leaderboard type
final selectedLeaderboardTypeProvider = StateProvider<LeaderboardType>((ref) => LeaderboardType.global);

/// Selected level for level-based leaderboard
final selectedLevelProvider = StateProvider<int>((ref) => 1);

/// Search query for leaderboard
final leaderboardSearchQueryProvider = StateProvider<String>((ref) => '');
