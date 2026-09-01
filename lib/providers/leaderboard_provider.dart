import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../models/user_profile.dart';
import 'user_profile_provider.dart';
import 'friend_provider.dart';

/// グローバルランキングを取得
final globalLeaderboardProvider =
    FutureProvider.autoDispose<LeaderboardData>((ref) async {
  final currentUser = ref.watch(currentUserProvider);

  // サンプルデータを生成（実装時はAPIから取得）
  final entries = [
    LeaderboardEntry(
      rank: 1,
      userId: 'user_001',
      name: '太郎',
      avatar: '👨',
      score: 15000,
      level: 25,
      totalStudyMinutes: 5400,
      longestStreak: 45,
      lastActiveAt: DateTime.now(),
      isCurrentUser: currentUser?.id == 'user_001',
    ),
    LeaderboardEntry(
      rank: 2,
      userId: 'user_002',
      name: '花子',
      avatar: '👩',
      score: 14500,
      level: 24,
      totalStudyMinutes: 5200,
      longestStreak: 42,
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
      isCurrentUser: currentUser?.id == 'user_002',
    ),
    LeaderboardEntry(
      rank: 3,
      userId: 'user_003',
      name: '次郎',
      avatar: '👨',
      score: 14000,
      level: 23,
      totalStudyMinutes: 5000,
      longestStreak: 40,
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 5)),
      isCurrentUser: currentUser?.id == 'user_003',
    ),
  ];

  return LeaderboardData(
    type: LeaderboardType.global,
    entries: entries,
    currentUserEntry: entries.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => LeaderboardEntry(
        rank: 999,
        userId: currentUser?.id ?? 'unknown',
        name: currentUser?.name ?? 'ユーザー',
        avatar: currentUser?.avatar ?? '👤',
        score: currentUser?.coinsEarned ?? 0,
        level: 1,
        totalStudyMinutes: currentUser?.totalStudyMinutes ?? 0,
        longestStreak: currentUser?.longestStreak ?? 0,
        lastActiveAt: currentUser?.lastAccessedAt ?? DateTime.now(),
        isCurrentUser: true,
      ),
    ),
    updatedAt: DateTime.now(),
  );
});

/// フレンドランキングを取得
final friendLeaderboardProvider =
    FutureProvider.autoDispose<LeaderboardData>((ref) async {
  final friends = ref.watch(friendListProvider);
  final currentUser = ref.watch(currentUserProvider);

  // フレンドのランキングエントリーを作成
  final friendEntries = friends
      .asMap()
      .entries
      .map((entry) {
        final index = entry.key;
        final friend = entry.value;
        return LeaderboardEntry(
          rank: index + 1,
          userId: friend.userId,
          name: friend.name,
          avatar: friend.avatar,
          score: friend.coinsEarned,
          level: 1,
          totalStudyMinutes: friend.totalStudyMinutes,
          longestStreak: 0,
          lastActiveAt: DateTime.now(),
          isCurrentUser: false,
        );
      })
      .toList();

  return LeaderboardData(
    type: LeaderboardType.friends,
    entries: friendEntries,
    currentUserEntry: currentUser != null
        ? LeaderboardEntry(
            rank: 0,
            userId: currentUser.id,
            name: currentUser.name,
            avatar: currentUser.avatar,
            score: currentUser.coinsEarned,
            level: 1,
            totalStudyMinutes: currentUser.totalStudyMinutes,
            longestStreak: currentUser.longestStreak,
            lastActiveAt: currentUser.lastAccessedAt,
            isCurrentUser: true,
          )
        : null,
    updatedAt: DateTime.now(),
  );
});

/// 週間ランキングを取得
final weeklyLeaderboardProvider =
    FutureProvider.autoDispose<LeaderboardData>((ref) async {
  final currentUser = ref.watch(currentUserProvider);

  // サンプル週間ランキングデータ
  final entries = [
    LeaderboardEntry(
      rank: 1,
      userId: 'week_user_001',
      name: '学太',
      avatar: '📚',
      score: 3500,
      level: 1,
      totalStudyMinutes: 720,
      longestStreak: 7,
      lastActiveAt: DateTime.now(),
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 2,
      userId: 'week_user_002',
      name: '英子',
      avatar: '📖',
      score: 3200,
      level: 1,
      totalStudyMinutes: 680,
      longestStreak: 7,
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 1)),
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 3,
      userId: 'week_user_003',
      name: '文男',
      avatar: '✏️',
      score: 2800,
      level: 1,
      totalStudyMinutes: 600,
      longestStreak: 6,
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 3)),
      isCurrentUser: false,
    ),
  ];

  return LeaderboardData(
    type: LeaderboardType.weekly,
    entries: entries,
    currentUserEntry: LeaderboardEntry(
      rank: 5,
      userId: currentUser?.id ?? 'unknown',
      name: currentUser?.name ?? 'ユーザー',
      avatar: currentUser?.avatar ?? '👤',
      score: currentUser?.coinsEarned ?? 0,
      level: 1,
      totalStudyMinutes: currentUser?.totalStudyMinutes ?? 0,
      longestStreak: currentUser?.longestStreak ?? 0,
      lastActiveAt: currentUser?.lastAccessedAt ?? DateTime.now(),
      isCurrentUser: true,
    ),
    updatedAt: DateTime.now(),
  );
});

/// ユーザー比較データプロバイダー
final userComparisonProvider =
    FutureProvider.family<UserComparison?, (String, String)>((ref, userIds) async {
  final (userId1, userId2) = userIds;

  // サンプル比較データ
  return UserComparison(
    userId1: userId1,
    name1: '太郎',
    avatar1: '👨',
    level1: 25,
    score1: 15000,
    studyMinutes1: 5400,
    userId2: userId2,
    name2: '花子',
    avatar2: '👩',
    level2: 24,
    score2: 14500,
    studyMinutes2: 5200,
  );
});
