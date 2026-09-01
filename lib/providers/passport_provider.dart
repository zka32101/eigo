import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/passport_model.dart';
import '../providers/user_profile_provider.dart';

/// パスポートプロフィールProvider（ユーザーの統合プロフィール）
final passportProfileProvider =
    StateNotifierProvider<PassportProfileNotifier, AsyncValue<PassportProfile?>>((ref) {
  return PassportProfileNotifier(ref);
});

class PassportProfileNotifier extends StateNotifier<AsyncValue<PassportProfile?>> {
  final Ref ref;

  PassportProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('passport_profile_$userId');

      if (profileJson != null) {
        final profile = PassportProfile.fromJson(jsonDecode(profileJson));
        state = AsyncValue.data(profile);
      } else {
        // 初期プロフィール作成
        final newProfile = PassportProfile(
          passportId: 'pp_${userId}_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          userName: ref.read(currentUserProvider)?.name ?? 'ユーザー',
          overallGrade: 1,
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          connectedApps: {
            'eigo-kore': true,
            'kokugo-kore': false,
            'sansu-kore': false,
          },
        );
        await _saveProfile(newProfile);
        state = AsyncValue.data(newProfile);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveProfile(PassportProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'passport_profile_${profile.userId}',
      jsonEncode(profile.toJson()),
    );
  }

  Future<void> connectApp(String appId) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = PassportProfile(
      passportId: currentProfile.passportId,
      userId: currentProfile.userId,
      userName: currentProfile.userName,
      profileImageUrl: currentProfile.profileImageUrl,
      overallGrade: currentProfile.overallGrade,
      createdAt: currentProfile.createdAt,
      lastUpdatedAt: DateTime.now(),
      connectedApps: {
        ...currentProfile.connectedApps,
        appId: true,
      },
    );

    await _saveProfile(updatedProfile);
    state = AsyncValue.data(updatedProfile);
  }

  Future<void> updateOverallGrade(int newGrade) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = PassportProfile(
      passportId: currentProfile.passportId,
      userId: currentProfile.userId,
      userName: currentProfile.userName,
      profileImageUrl: currentProfile.profileImageUrl,
      overallGrade: newGrade.clamp(1, 6),
      createdAt: currentProfile.createdAt,
      lastUpdatedAt: DateTime.now(),
      connectedApps: currentProfile.connectedApps,
    );

    await _saveProfile(updatedProfile);
    state = AsyncValue.data(updatedProfile);
  }
}

/// アプリ別統計Provider
final appStatisticsProvider = StateNotifierProvider.family<
    AppStatisticsNotifier,
    AsyncValue<AppStatistics?>,
    String>((ref, appId) {
  return AppStatisticsNotifier(ref, appId);
});

class AppStatisticsNotifier extends StateNotifier<AsyncValue<AppStatistics?>> {
  final Ref ref;
  final String appId;

  AppStatisticsNotifier(this.ref, this.appId)
      : super(const AsyncValue.loading()) {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('app_stats_${userId}_$appId');

      if (statsJson != null) {
        final stats = AppStatistics.fromJson(jsonDecode(statsJson));
        state = AsyncValue.data(stats);
      } else {
        // デフォルト統計
        final newStats = AppStatistics(
          statsId: 'as_${userId}_${appId}_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          appId: appId,
          totalXP: 0,
          totalLevel: 1,
          totalBadges: 0,
          unlockedBadgeIds: [],
          consecutiveStreak: 0,
          longestStreak: 0,
          normalizedScore: 0,
        );
        await _saveStatistics(newStats);
        state = AsyncValue.data(newStats);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveStatistics(AppStatistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'app_stats_${stats.userId}_$appId',
      jsonEncode(stats.toJson()),
    );
  }

  Future<void> syncXPFromApp(int xpAmount) async {
    final currentStats = state.value;
    if (currentStats == null) return;

    final newLevel = (currentStats.totalXP + xpAmount) ~/ 100 + 1;
    final updatedStats = AppStatistics(
      statsId: currentStats.statsId,
      userId: currentStats.userId,
      appId: currentStats.appId,
      totalXP: currentStats.totalXP + xpAmount,
      totalLevel: newLevel,
      totalBadges: currentStats.totalBadges,
      unlockedBadgeIds: currentStats.unlockedBadgeIds,
      lastPlayedAt: DateTime.now(),
      consecutiveStreak: currentStats.consecutiveStreak,
      longestStreak: currentStats.longestStreak,
      normalizedScore: ((currentStats.totalXP + xpAmount) / 1000 * 100)
          .toInt()
          .clamp(0, 100),
    );

    await _saveStatistics(updatedStats);
    state = AsyncValue.data(updatedStats);
  }

  Future<void> unlockBadge(String badgeId) async {
    final currentStats = state.value;
    if (currentStats == null) return;

    if (currentStats.unlockedBadgeIds.contains(badgeId)) return;

    final updatedStats = AppStatistics(
      statsId: currentStats.statsId,
      userId: currentStats.userId,
      appId: currentStats.appId,
      totalXP: currentStats.totalXP,
      totalLevel: currentStats.totalLevel,
      totalBadges: currentStats.totalBadges + 1,
      unlockedBadgeIds: [...currentStats.unlockedBadgeIds, badgeId],
      lastPlayedAt: currentStats.lastPlayedAt,
      consecutiveStreak: currentStats.consecutiveStreak,
      longestStreak: currentStats.longestStreak,
      normalizedScore: currentStats.normalizedScore,
    );

    await _saveStatistics(updatedStats);
    state = AsyncValue.data(updatedStats);
  }

  Future<void> updateConsecutiveStreak(int newStreak, int longestStreak) async {
    final currentStats = state.value;
    if (currentStats == null) return;

    final updatedStats = AppStatistics(
      statsId: currentStats.statsId,
      userId: currentStats.userId,
      appId: currentStats.appId,
      totalXP: currentStats.totalXP,
      totalLevel: currentStats.totalLevel,
      totalBadges: currentStats.totalBadges,
      unlockedBadgeIds: currentStats.unlockedBadgeIds,
      lastPlayedAt: DateTime.now(),
      consecutiveStreak: newStreak,
      longestStreak: longestStreak,
      normalizedScore: currentStats.normalizedScore,
    );

    await _saveStatistics(updatedStats);
    state = AsyncValue.data(updatedStats);
  }
}

/// グローバルバッジProvider
final globalBadgesProvider = Provider<List<GlobalBadge>>((ref) {
  return _initializeGlobalBadges();
});

List<GlobalBadge> _initializeGlobalBadges() {
  return [
    GlobalBadge(
      badgeId: 'gb_eigo_starter',
      name: 'リスニング開始',
      emoji: '🎧',
      description: '英語コレで初めてのレッスンを完了した',
      criteria: 'Complete first lesson in eigo-kore',
      requiredXP: 0,
      appId: 'eigo-kore',
      seriesNumber: 1,
      rarity: 1,
      parentalAppeal: 0.7,
      releasedAt: DateTime(2024, 1, 1),
    ),
    GlobalBadge(
      badgeId: 'gb_eigo_pro',
      name: 'スピーキング達人',
      emoji: '🗣️',
      description: '発音スコア平均80点以上を達成',
      criteria: 'Average pronunciation score >= 80',
      requiredXP: 500,
      appId: 'eigo-kore',
      seriesNumber: 1,
      rarity: 3,
      parentalAppeal: 0.85,
      releasedAt: DateTime(2024, 1, 1),
    ),
    GlobalBadge(
      badgeId: 'gb_cross_app_learner',
      name: '全教科マスター',
      emoji: '📚',
      description: '複数のアプリで学習した',
      criteria: 'Connect to 2+ sister apps',
      requiredXP: 1000,
      appId: 'eigo-kore',
      seriesNumber: 1,
      rarity: 4,
      parentalAppeal: 0.9,
      releasedAt: DateTime(2024, 6, 1),
    ),
    GlobalBadge(
      badgeId: 'gb_streak_30',
      name: '30日連続',
      emoji: '🔥',
      description: '30日連続学習に成功した',
      criteria: '30 consecutive days learning',
      requiredXP: 2000,
      appId: 'eigo-kore',
      seriesNumber: 1,
      rarity: 5,
      parentalAppeal: 0.95,
      releasedAt: DateTime(2024, 1, 1),
    ),
    GlobalBadge(
      badgeId: 'gb_passport_ambassador',
      name: 'パスポート大使',
      emoji: '🌍',
      description: '3つのアプリをすべてマスターした',
      criteria: 'Unlock all badges in 3+ apps',
      requiredXP: 5000,
      appId: 'eigo-kore',
      seriesNumber: 1,
      rarity: 5,
      parentalAppeal: 0.98,
      releasedAt: DateTime(2024, 6, 1),
    ),
  ];
}

/// ユーザーバッジ獲得履歴Provider
final userBadgeAchievementsProvider = StateNotifierProvider<
    UserBadgeAchievementsNotifier,
    AsyncValue<List<UserBadgeAchievement>>>((ref) {
  return UserBadgeAchievementsNotifier(ref);
});

class UserBadgeAchievementsNotifier
    extends StateNotifier<AsyncValue<List<UserBadgeAchievement>>> {
  final Ref ref;

  UserBadgeAchievementsNotifier(this.ref)
      : super(const AsyncValue.loading()) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString('badge_achievements_$userId');

      if (achievementsJson != null) {
        final achievements =
            (jsonDecode(achievementsJson) as List)
                .map((e) => UserBadgeAchievement.fromJson(e))
                .toList();
        state = AsyncValue.data(achievements);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveAchievements(List<UserBadgeAchievement> achievements) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'badge_achievements_$userId',
      jsonEncode(achievements.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> unlockBadge(String badgeId, String acquiredFromApp) async {
    final currentList = state.value ?? [];
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    // Check if already unlocked
    if (currentList.any((a) => a.badgeId == badgeId)) return;

    final newAchievement = UserBadgeAchievement(
      achievementId: 'ba_${userId}_${badgeId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      badgeId: badgeId,
      unlockedAt: DateTime.now(),
      acquiredFromApp: acquiredFromApp,
      shared: false,
    );

    final updated = [...currentList, newAchievement];
    await _saveAchievements(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> shareBadge(String achievementId) async {
    final currentList = state.value ?? [];
    final updated = currentList.map((a) {
      if (a.achievementId == achievementId) {
        return UserBadgeAchievement(
          achievementId: a.achievementId,
          userId: a.userId,
          badgeId: a.badgeId,
          unlockedAt: a.unlockedAt,
          acquiredFromApp: a.acquiredFromApp,
          shared: true,
          sharedAt: DateTime.now(),
        );
      }
      return a;
    }).toList();

    await _saveAchievements(updated);
    state = AsyncValue.data(updated);
  }
}

/// クロスアプリチャレンジProvider
final crossAppChallengesProvider = Provider<List<CrossAppChallenge>>((ref) {
  return _initializeCrossAppChallenges();
});

List<CrossAppChallenge> _initializeCrossAppChallenges() {
  final now = DateTime.now();
  return [
    CrossAppChallenge(
      challengeId: 'cac_trio_master_1',
      name: '三教科マスターチャレンジ',
      description: '英語・国語・算数で全員レベル5に到達しよう',
      participatingAppIds: ['eigo-kore', 'kokugo-kore', 'sansu-kore'],
      conditionJson: jsonEncode({
        'type': 'level_threshold',
        'requiredLevel': 5,
        'apps': ['eigo-kore', 'kokugo-kore', 'sansu-kore'],
      }),
      totalXPReward: 500,
      bonusBadgeId: 'gb_cross_app_learner',
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
      leaderboard: {},
    ),
    CrossAppChallenge(
      challengeId: 'cac_daily_ritual',
      name: '毎日学習の儀式',
      description: '3つのアプリで毎日1回以上プレイしよう（7日間）',
      participatingAppIds: ['eigo-kore', 'kokugo-kore', 'sansu-kore'],
      conditionJson: jsonEncode({
        'type': 'daily_play_streak',
        'days': 7,
        'apps': ['eigo-kore', 'kokugo-kore', 'sansu-kore'],
      }),
      totalXPReward: 200,
      bonusBadgeId: null,
      startDate: now,
      endDate: now.add(const Duration(days: 14)),
      leaderboard: {},
    ),
  ];
}

/// パスポート統計サマリーProvider
final passportSummaryProvider =
    FutureProvider.autoDispose<PassportSummary?>((ref) async {
  try {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return null;

    final eigoStats = ref.watch(appStatisticsProvider('eigo-kore')).value;
    final kokugoStats = ref.watch(appStatisticsProvider('kokugo-kore')).value;
    final sansuStats = ref.watch(appStatisticsProvider('sansu-kore')).value;

    final totalXP = (eigoStats?.totalXP ?? 0) +
        (kokugoStats?.totalXP ?? 0) +
        (sansuStats?.totalXP ?? 0);

    final prefs = await SharedPreferences.getInstance();
    final summaryJson = prefs.getString('passport_summary_$userId');

    if (summaryJson != null) {
      return PassportSummary.fromJson(jsonDecode(summaryJson));
    }

    // デフォルトサマリー
    return PassportSummary(
      summaryId: 'ps_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      totalXP: totalXP,
      globalRank: 1000,
      friendsRank: 50,
      totalBadgesUnlocked:
          (eigoStats?.totalBadges ?? 0) +
          (kokugoStats?.totalBadges ?? 0) +
          (sansuStats?.totalBadges ?? 0),
      completionPercentage: (totalXP / 5000 * 100).toInt().clamp(0, 100),
      lastSyncedAt: DateTime.now(),
      monthlyXPGrowth: (totalXP * 0.1).toInt(),
      xpByApp: {
        'eigo-kore': eigoStats?.totalXP ?? 0,
        'kokugo-kore': kokugoStats?.totalXP ?? 0,
        'sansu-kore': sansuStats?.totalXP ?? 0,
      },
      totalStudyMinutes: (totalXP ~/ 10), // 推定: XP÷10で学習時間
    );
  } catch (e) {
    return null;
  }
});

/// XP同期ログProvider（監査用）
final xpSyncLogsProvider = StateNotifierProvider<
    XPSyncLogsNotifier,
    AsyncValue<List<XPSyncLog>>>((ref) {
  return XPSyncLogsNotifier(ref);
});

class XPSyncLogsNotifier extends StateNotifier<AsyncValue<List<XPSyncLog>>> {
  final Ref ref;

  XPSyncLogsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString('xp_sync_logs_$userId');

      if (logsJson != null) {
        final logs =
            (jsonDecode(logsJson) as List)
                .map((e) => XPSyncLog.fromJson(e))
                .toList();
        state = AsyncValue.data(logs);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveLogs(List<XPSyncLog> logs) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'xp_sync_logs_$userId',
      jsonEncode(logs.map((l) => l.toJson()).toList()),
    );
  }

  Future<void> addSyncLog(
    String sourceApp,
    List<String> destinationApps,
    int xpAmount,
  ) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final currentLogs = state.value ?? [];
    final newLog = XPSyncLog(
      logId: 'xsl_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      sourceApp: sourceApp,
      destinationApps: destinationApps,
      syncedXP: xpAmount,
      syncedAt: DateTime.now(),
      status: 'success',
    );

    final updated = [...currentLogs, newLog];
    await _saveLogs(updated);
    state = AsyncValue.data(updated);
  }
}

/// パスポート通知Provider
final passportNotificationsProvider = StateNotifierProvider<
    PassportNotificationsNotifier,
    AsyncValue<List<PassportNotification>>>((ref) {
  return PassportNotificationsNotifier(ref);
});

class PassportNotificationsNotifier
    extends StateNotifier<AsyncValue<List<PassportNotification>>> {
  final Ref ref;

  PassportNotificationsNotifier(this.ref)
      : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('passport_notifications_$userId');

      if (notificationsJson != null) {
        final notifications =
            (jsonDecode(notificationsJson) as List)
                .map((e) => PassportNotification.fromJson(e))
                .toList();
        state = AsyncValue.data(notifications);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveNotifications(
      List<PassportNotification> notifications) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'passport_notifications_$userId',
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> addNotification(
    String type,
    String title,
    String message,
    String relatedAppId,
    Map<String, dynamic> payload,
  ) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final currentList = state.value ?? [];
    final newNotification = PassportNotification(
      notificationId: 'pn_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      title: title,
      message: message,
      relatedAppId: relatedAppId,
      payload: payload,
      createdAt: DateTime.now(),
      isRead: false,
    );

    final updated = [newNotification, ...currentList];
    await _saveNotifications(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> markAsRead(String notificationId) async {
    final currentList = state.value ?? [];
    final updated = currentList.map((n) {
      if (n.notificationId == notificationId) {
        return PassportNotification(
          notificationId: n.notificationId,
          userId: n.userId,
          type: n.type,
          title: n.title,
          message: n.message,
          relatedAppId: n.relatedAppId,
          payload: n.payload,
          createdAt: n.createdAt,
          isRead: true,
          readAt: DateTime.now(),
        );
      }
      return n;
    }).toList();

    await _saveNotifications(updated);
    state = AsyncValue.data(updated);
  }
}
