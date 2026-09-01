import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/parent_child_battle_model.dart';

/// Current parent-child battle session
final currentParentChildBattleProvider = StateNotifierProvider<ParentChildBattleNotifier, ParentChildBattle?>((ref) {
  return ParentChildBattleNotifier();
});

class ParentChildBattleNotifier extends StateNotifier<ParentChildBattle?> {
  static const String _storageKey = 'eigo_kore_current_pch_battle';
  
  ParentChildBattleNotifier() : super(null) {
    _loadBattle();
  }
  
  Future<void> _loadBattle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        state = ParentChildBattle.fromJson(json);
      }
    } catch (e) {
      print('Error loading battle: $e');
    }
  }
  
  Future<void> _saveBattle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state != null) {
        await prefs.setString(_storageKey, jsonEncode(state!.toJson()));
      } else {
        await prefs.remove(_storageKey);
      }
    } catch (e) {
      print('Error saving battle: $e');
    }
  }
  
  /// Start a new battle
  Future<void> startBattle(
    String parentId,
    String childId,
    String parentName,
    String childName,
    String phrase,
    String phraseMeaning,
  ) async {
    state = ParentChildBattle(
      battleId: DateTime.now().millisecondsSinceEpoch.toString(),
      parentId: parentId,
      childId: childId,
      parentName: parentName,
      childName: childName,
      phrase: phrase,
      phraseMeaning: phraseMeaning,
      parentScore: 0,
      childScore: 0,
      rounds: [],
      startedAt: DateTime.now(),
      winner: '',
      parentCoinsEarned: 0,
      childCoinsEarned: 0,
    );
    await _saveBattle();
  }
  
  /// Record a round result
  Future<void> completeRound(
    int roundNumber,
    int parentScore,
    int childScore,
    String parentResponse,
    String childResponse,
  ) async {
    if (state == null) return;
    
    final round = BattleRound(
      roundNumber: roundNumber,
      pronunciationChallenge: state!.phrase,
      parentScore: parentScore,
      childScore: childScore,
      parentResponse: parentResponse,
      childResponse: childResponse,
      completedAt: DateTime.now(),
    );
    
    final newRounds = [...state!.rounds, round];
    final newParentScore = state!.parentScore + parentScore;
    final newChildScore = state!.childScore + childScore;
    
    state = state!.copyWith(
      rounds: newRounds,
      parentScore: newParentScore,
      childScore: newChildScore,
    );
    
    await _saveBattle();
  }
  
  /// Complete battle and calculate winner
  Future<void> completeBattle() async {
    if (state == null) return;
    
    String winner;
    if (state!.parentScore > state!.childScore) {
      winner = 'parent';
    } else if (state!.childScore > state!.parentScore) {
      winner = 'child';
    } else {
      winner = 'tie';
    }
    
    // Calculate coin rewards
    final parentCoins = state!.parentScore ~/ 10; // 10 coins per 10 points
    final childCoins = state!.childScore ~/ 10;
    
    state = state!.copyWith(
      completedAt: DateTime.now(),
      winner: winner,
      parentCoinsEarned: parentCoins,
      childCoinsEarned: childCoins,
    );
    
    await _saveBattle();
  }
  
  /// Reset battle
  Future<void> resetBattle() async {
    state = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error resetting battle: $e');
    }
  }
}

/// Parent-child battle history
final parentChildBattleHistoryProvider = StateNotifierProvider<BattleHistoryNotifier, List<ParentChildBattle>>((ref) {
  return BattleHistoryNotifier();
});

class BattleHistoryNotifier extends StateNotifier<List<ParentChildBattle>> {
  static const String _storageKey = 'eigo_kore_pch_battle_history';
  
  BattleHistoryNotifier() : super([]) {
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((json) => ParentChildBattle.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }
  
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((b) => b.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving history: $e');
    }
  }
  
  /// Add battle to history
  Future<void> addBattleToHistory(ParentChildBattle battle) async {
    state = [battle, ...state];
    await _saveHistory();
  }
  
  /// Get battles for a specific family
  List<ParentChildBattle> getForFamily(String parentId, String childId) {
    return state.where((b) => b.parentId == parentId && b.childId == childId).toList();
  }
}

/// Weekly family battle league
final weeklyFamilyLeagueProvider = FutureProvider.autoDispose<WeeklyFamilyLeague>((ref) async {
  // Mock data for current week
  final now = DateTime.now();
  final weekNumber = ((now.day - now.weekday) ~/ 7) + 1;
  
  return WeeklyFamilyLeague(
    leagueId: '${now.year}-W${weekNumber.toString().padLeft(2, '0')}',
    weekNumber: weekNumber,
    year: now.year,
    startDate: now.subtract(Duration(days: now.weekday - 1)),
    endDate: now.add(Duration(days: 8 - now.weekday)),
    standings: [
      FamilyLeagueEntry(
        familyId: 'family_1',
        parentName: '田中パパ',
        childName: 'りょう',
        rank: 1,
        weeklyBattles: 7,
        weeklyWins: 6,
        weeklyPoints: 580,
        winRate: 85.7,
        dailyScores: [95, 88, 92, 89, 91, 87, 90],
      ),
      FamilyLeagueEntry(
        familyId: 'family_2',
        parentName: '佐藤パパ',
        childName: 'ひかり',
        rank: 2,
        weeklyBattles: 6,
        weeklyWins: 5,
        weeklyPoints: 540,
        winRate: 83.3,
        dailyScores: [92, 85, 88, 91, 0, 86, 87],
      ),
      FamilyLeagueEntry(
        familyId: 'family_3',
        parentName: 'suzuki mom',
        childName: 'Taro',
        rank: 3,
        weeklyBattles: 5,
        weeklyWins: 3,
        weeklyPoints: 480,
        winRate: 60.0,
        dailyScores: [78, 82, 0, 85, 88, 0, 81],
      ),
    ],
  );
});

/// Parent battle pass subscription
final parentBattlePassProvider = StateNotifierProvider<ParentBattlePassNotifier, ParentBattlePass?>((ref) {
  return ParentBattlePassNotifier();
});

class ParentBattlePassNotifier extends StateNotifier<ParentBattlePass?> {
  static const String _storageKey = 'eigo_kore_parent_pass';
  
  ParentBattlePassNotifier() : super(null) {
    _loadPass();
  }
  
  Future<void> _loadPass() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        final pass = ParentBattlePass.fromJson(json);
        // Only show if still active
        if (pass.isActive) {
          state = pass;
        }
      }
    } catch (e) {
      print('Error loading pass: $e');
    }
  }
  
  Future<void> _savePass() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state != null) {
        await prefs.setString(_storageKey, jsonEncode(state!.toJson()));
      } else {
        await prefs.remove(_storageKey);
      }
    } catch (e) {
      print('Error saving pass: $e');
    }
  }
  
  /// Purchase a battle pass
  Future<void> purchasePass(String parentId, String passType) async {
    final now = DateTime.now();
    final expiresAt = passType == 'monthly_unlimited'
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 7));
    
    final maxBattles = passType.contains('unlimited') ? -1 : 15;
    
    state = ParentBattlePass(
      passId: DateTime.now().millisecondsSinceEpoch.toString(),
      parentId: parentId,
      passType: passType,
      maxBattlesPerWeek: maxBattles,
      unlimitedReplay: passType.contains('unlimited'),
      premiumPrizes: passType == 'premium_features',
      purchasedAt: now,
      expiresAt: expiresAt,
      costCoins: passType == 'monthly_unlimited' ? 500 : 200,
      renewalStatus: 'active',
    );
    
    await _savePass();
  }
  
  /// Cancel pass
  Future<void> cancelPass() async {
    if (state != null) {
      state = state!.copyWith(renewalStatus: 'cancelled');
      await _savePass();
    }
  }
}

/// Family battle statistics
final familyBattleStatsProvider = StateNotifierProvider<FamilyBattleStatsNotifier, ParentChildBattleStats>((ref) {
  return FamilyBattleStatsNotifier();
});

class FamilyBattleStatsNotifier extends StateNotifier<ParentChildBattleStats> {
  static const String _storageKey = 'eigo_kore_family_stats';
  
  FamilyBattleStatsNotifier() : super(
    ParentChildBattleStats(
      familyId: 'family_default',
      totalBattles: 0,
      parentWins: 0,
      childWins: 0,
      ties: 0,
      parentWinRate: 0,
      childWinRate: 0,
      averageParentScore: 0,
      averageChildScore: 0,
      lastBattleAt: DateTime.now(),
      recentBattles: [],
    ),
  ) {
    _loadStats();
  }
  
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        state = ParentChildBattleStats.fromJson(json);
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }
  
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving stats: $e');
    }
  }
  
  /// Record completed battle in statistics
  Future<void> recordBattle(ParentChildBattle battle) async {
    final newTotal = state.totalBattles + 1;
    int newParentWins = state.parentWins;
    int newChildWins = state.childWins;
    int newTies = state.ties;
    
    if (battle.winner == 'parent') {
      newParentWins++;
    } else if (battle.winner == 'child') {
      newChildWins++;
    } else {
      newTies++;
    }
    
    final newAvgParentScore = ((state.averageParentScore * state.totalBattles) + battle.parentScore) / newTotal;
    final newAvgChildScore = ((state.averageChildScore * state.totalBattles) + battle.childScore) / newTotal;
    
    final newRecentBattles = [battle, ...state.recentBattles].take(5).toList();
    
    state = ParentChildBattleStats(
      familyId: state.familyId,
      totalBattles: newTotal,
      parentWins: newParentWins,
      childWins: newChildWins,
      ties: newTies,
      parentWinRate: (newParentWins / newTotal * 100),
      childWinRate: (newChildWins / newTotal * 100),
      averageParentScore: newAvgParentScore,
      averageChildScore: newAvgChildScore,
      lastBattleAt: battle.completedAt ?? DateTime.now(),
      recentBattles: newRecentBattles,
    );
    
    await _saveStats();
  }
}

/// Family battle achievements
final familyBattleAchievementsProvider = StateNotifierProvider<FamilyBattleAchievementsNotifier, List<FamilyBattleAchievement>>((ref) {
  return FamilyBattleAchievementsNotifier();
});

class FamilyBattleAchievementsNotifier extends StateNotifier<List<FamilyBattleAchievement>> {
  static const String _storageKey = 'eigo_kore_family_achievements';
  
  FamilyBattleAchievementsNotifier() : super(_initializeAchievements()) {
    _loadAchievements();
  }
  
  static List<FamilyBattleAchievement> _initializeAchievements() {
    return [
      FamilyBattleAchievement(
        achievementId: 'first_family_battle',
        title: '家族対戦デビュー',
        description: 'はじめての親子対戦',
        icon: '👨‍👩‍👧‍👦',
        type: 'family',
        targetCount: 1,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        rewardCoins: 100,
      ),
      FamilyBattleAchievement(
        achievementId: 'parent_wins_10',
        title: 'パパはチャンピオン',
        description: 'パパが10回勝利',
        icon: '🏆',
        type: 'parent',
        targetCount: 10,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        rewardCoins: 200,
      ),
      FamilyBattleAchievement(
        achievementId: 'child_wins_10',
        title: 'こどもチャレンジャー',
        description: 'こどもが10回勝利',
        icon: '⭐',
        type: 'child',
        targetCount: 10,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        rewardCoins: 200,
      ),
      FamilyBattleAchievement(
        achievementId: 'family_battles_50',
        title: '家族対戦マスター',
        description: '合計50回の対戦',
        icon: '👑',
        type: 'family',
        targetCount: 50,
        currentCount: 0,
        isUnlocked: false,
        unlockedAt: null,
        rewardCoins: 500,
      ),
    ];
  }
  
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        state = decoded.map((json) => FamilyBattleAchievement.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }
  
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving achievements: $e');
    }
  }
  
  /// Update achievement progress
  Future<void> updateProgress(String achievementId, int newCount) async {
    state = state.map((achievement) {
      if (achievement.achievementId == achievementId) {
        final isNowUnlocked = newCount >= achievement.targetCount && !achievement.isUnlocked;
        return achievement.copyWith(
          currentCount: newCount,
          isUnlocked: isNowUnlocked ? true : achievement.isUnlocked,
          unlockedAt: isNowUnlocked ? DateTime.now() : achievement.unlockedAt,
        );
      }
      return achievement;
    }).toList();
    await _saveAchievements();
  }
}
