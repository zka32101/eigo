import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../services/leaderboard_service.dart';

// ===== Service Provider =====

/// Leaderboard service provider
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService();
});

// ===== Leaderboard Providers =====

/// Overall global leaderboard
final overallLeaderboardProvider = FutureProvider<GroupedLeaderboard>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getOverallLeaderboard(limit: 100);
});

/// Grade-specific leaderboard
final gradeLeaderboardProvider = FutureProvider.family<GroupedLeaderboard, int>(
  (ref, grade) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.getGradeLeaderboard(grade, limit: 100);
  },
);

/// Start month leaderboard
final startMonthLeaderboardProvider = FutureProvider.family<GroupedLeaderboard, (int, int)>(
  (ref, params) async {
    final (year, month) = params;
    final service = ref.watch(leaderboardServiceProvider);
    return service.getStartMonthLeaderboard(year, month, limit: 100);
  },
);

/// Combined leaderboard (grade × month)
final combinedLeaderboardProvider = FutureProvider.family<GroupedLeaderboard, (int, int, int)>(
  (ref, params) async {
    final (grade, year, month) = params;
    final service = ref.watch(leaderboardServiceProvider);
    return service.getCombinedLeaderboard(grade, year, month, limit: 100);
  },
);

// ===== User-Specific Providers =====

/// User's grade information
final userGradeInfoProvider = FutureProvider.family<UserGradeInfo?, String>(
  (ref, userId) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.getUserGradeInfo(userId);
  },
);

/// User's rank in a specific leaderboard
final userRankPositionProvider = FutureProvider.family<int?, (String, LeaderboardGroupType)>(
  (ref, params) async {
    final (userId, groupType) = params;
    final service = ref.watch(leaderboardServiceProvider);
    return service.getUserRankPosition(userId, groupType);
  },
);

/// User's promotion history
final userPromotionHistoryProvider = FutureProvider.family<List<GradePromotion>, String>(
  (ref, userId) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.getUserPromotionHistory(userId);
  },
);

// ===== Configuration Providers =====

/// Grade promotion configuration
final gradePromotionConfigProvider = FutureProvider<GradePromotionConfig>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getPromotionConfig();
});

// ===== Action Functions =====

/// Promote user to next grade
Future<bool> promoteUserAction(
  WidgetRef ref, {
  required String userId,
  required int newGrade,
  String reason = 'automatic',
  String? performedBy,
}) async {
  final service = ref.read(leaderboardServiceProvider);
  final success = await service.promoteUser(
    userId,
    newGrade,
    reason: reason,
    performedBy: performedBy,
  );

  if (success) {
    // Refresh grade info and promotion history
    ref.refresh(userGradeInfoProvider(userId));
    ref.refresh(userPromotionHistoryProvider(userId));
    
    // Refresh all leaderboards that might be affected
    ref.refresh(overallLeaderboardProvider);
    ref.refresh(gradeLeaderboardProvider(newGrade));
  }

  return success;
}

/// Check and process automatic promotions
Future<int> checkPromotionsAction(WidgetRef ref) async {
  final service = ref.read(leaderboardServiceProvider);
  final promotedCount = await service.checkAndPromoteUsers();

  if (promotedCount > 0) {
    // Refresh all leaderboards
    ref.refresh(overallLeaderboardProvider);
    ref.refresh(gradePromotionConfigProvider);
  }

  return promotedCount;
}

/// Get user's rank in leaderboard
Future<int?> getUserRankAction(
  WidgetRef ref, {
  required String userId,
  required LeaderboardGroupType groupType,
  int? grade,
  int? year,
  int? month,
}) async {
  final service = ref.read(leaderboardServiceProvider);
  return service.getUserRankPosition(
    userId,
    groupType,
    grade: grade,
    year: year,
    month: month,
  );
}
