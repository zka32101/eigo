import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_challenge_model.dart';

/// Mock database of daily challenges (180+ phrases)
final _challengeDatabase = [
  DailyChallenge(
    challengeId: '2026-09-01',
    phrase: 'What is your name?',
    phraseMeaning: 'あなたの名前は何ですか？',
    phrasePronunciation: 'wɑt ɪz jɔr neɪm',
    audioUrl: '',
    releaseTime: DateTime.utc(2026, 9, 1, 7, 0),
    expiresAt: DateTime.utc(2026, 9, 2, 7, 0),
  ),
  DailyChallenge(
    challengeId: '2026-09-02',
    phrase: 'Nice to meet you!',
    phraseMeaning: 'お会いして光栄です！',
    phrasePronunciation: 'naɪs tu mit ju',
    audioUrl: '',
    releaseTime: DateTime.utc(2026, 9, 2, 7, 0),
    expiresAt: DateTime.utc(2026, 9, 3, 7, 0),
  ),
  DailyChallenge(
    challengeId: '2026-09-03',
    phrase: 'How are you today?',
    phraseMeaning: '今日はお元気ですか？',
    phrasePronunciation: 'haʊ ar ju təˈdeɪ',
    audioUrl: '',
    releaseTime: DateTime.utc(2026, 9, 3, 7, 0),
    expiresAt: DateTime.utc(2026, 9, 4, 7, 0),
  ),
  DailyChallenge(
    challengeId: '2026-09-04',
    phrase: 'Where do you live?',
    phraseMeaning: 'どこに住んでいますか？',
    phrasePronunciation: 'wɛr du ju lɪv',
    audioUrl: '',
    releaseTime: DateTime.utc(2026, 9, 4, 7, 0),
    expiresAt: DateTime.utc(2026, 9, 5, 7, 0),
  ),
  DailyChallenge(
    challengeId: '2026-09-05',
    phrase: 'What do you like?',
    phraseMeaning: '何が好きですか？',
    phrasePronunciation: 'wɑt du ju laɪk',
    audioUrl: '',
    releaseTime: DateTime.utc(2026, 9, 5, 7, 0),
    expiresAt: DateTime.utc(2026, 9, 6, 7, 0),
  ),
];

/// Get today's daily challenge
final todaysChallengeProvider = FutureProvider.autoDispose<DailyChallenge>((ref) async {
  final today = DateTime.now();
  final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  
  // In production, fetch from Firestore. For now, return from mock database
  try {
    return _challengeDatabase.firstWhere((c) => c.challengeId == dateStr);
  } catch (e) {
    // If today's challenge not found, return the latest one
    return _challengeDatabase.last;
  }
});

/// User's current attempt for today's challenge
final userTodaysAttemptProvider = StateNotifierProvider<UserChallengeAttemptNotifier, ChallengeAttempt?>((ref) {
  return UserChallengeAttemptNotifier();
});

class UserChallengeAttemptNotifier extends StateNotifier<ChallengeAttempt?> {
  static const String _storageKey = 'eigo_kore_challenge_attempt';
  
  UserChallengeAttemptNotifier() : super(null) {
    _loadAttempt();
  }
  
  Future<void> _loadAttempt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        state = ChallengeAttempt.fromJson(json);
      }
    } catch (e) {
      print('Error loading attempt: $e');
    }
  }
  
  Future<void> _saveAttempt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state != null) {
        await prefs.setString(_storageKey, jsonEncode(state!.toJson()));
      }
    } catch (e) {
      print('Error saving attempt: $e');
    }
  }
  
  /// Submit user's attempt for today's challenge
  Future<void> submitAttempt(
    String challengeId,
    String userResponse,
    int scorePoints,
    double accuracyScore,
  ) async {
    final attempt = ChallengeAttempt(
      attemptId: DateTime.now().millisecondsSinceEpoch.toString(),
      challengeId: challengeId,
      userId: 'user_001', // Will be replaced with actual user ID
      userResponse: userResponse,
      scorePoints: scorePoints,
      accuracyScore: accuracyScore,
      attemptedAt: DateTime.now(),
      isCorrect: scorePoints >= 75, // 75+ is considered correct
    );
    
    state = attempt;
    await _saveAttempt();
  }
  
  /// Reset attempt (for new day)
  Future<void> resetAttempt() async {
    state = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error resetting attempt: $e');
    }
  }
}

/// Global leaderboard for today's challenge
final todaysChallengeLeaderboardProvider = FutureProvider.autoDispose<List<ChallengeLeaderboardEntry>>((ref) async {
  // Mock leaderboard data
  return [
    ChallengeLeaderboardEntry(
      rank: 1,
      userId: 'user_sample_1',
      userName: '英語太郎',
      score: 98,
      userRegion: '東京',
      userLevel: '小6',
      isMedalEarned: true,
      achievedAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    ChallengeLeaderboardEntry(
      rank: 2,
      userId: 'user_sample_2',
      userName: 'めぐみ',
      score: 95,
      userRegion: '大阪',
      userLevel: '小5',
      isMedalEarned: true,
      achievedAt: DateTime.now().subtract(Duration(hours: 1)),
    ),
    ChallengeLeaderboardEntry(
      rank: 3,
      userId: 'user_sample_3',
      userName: 'ひかり',
      score: 92,
      userRegion: '京都',
      userLevel: '小6',
      isMedalEarned: true,
      achievedAt: DateTime.now().subtract(Duration(minutes: 30)),
    ),
    ChallengeLeaderboardEntry(
      rank: 4,
      userId: 'user_sample_4',
      userName: 'たろう',
      score: 88,
      userRegion: '福岡',
      userLevel: '小4',
      isMedalEarned: false,
      achievedAt: DateTime.now().subtract(Duration(minutes: 15)),
    ),
    ChallengeLeaderboardEntry(
      rank: 5,
      userId: 'user_sample_5',
      userName: 'さくら',
      score: 85,
      userRegion: '神奈川',
      userLevel: '小5',
      isMedalEarned: false,
      achievedAt: DateTime.now().subtract(Duration(minutes: 5)),
    ),
  ];
});

/// User's challenge statistics
final userChallengeStatsProvider = StateNotifierProvider<UserChallengeStatsNotifier, ChallengeStat>((ref) {
  return UserChallengeStatsNotifier();
});

class UserChallengeStatsNotifier extends StateNotifier<ChallengeStat> {
  static const String _storageKey = 'eigo_kore_challenge_stats';
  
  UserChallengeStatsNotifier() : super(
    ChallengeStat(
      userId: 'user_001',
      totalAttempts: 0,
      consecutiveDays: 0,
      averageScore: 0,
      bestScore: 0,
      lastAttemptAt: DateTime.now(),
      earnedBadges: [],
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
        state = ChallengeStat.fromJson(json);
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
  
  /// Record a new attempt (updates statistics)
  Future<void> recordAttempt(int score) async {
    final now = DateTime.now();
    final lastAttempt = state.lastAttemptAt;
    
    // Check if consecutive day (within 24 hours from last attempt)
    final isConsecutive = now.difference(lastAttempt).inHours < 24;
    
    // Calculate new average
    final newTotal = state.totalAttempts + 1;
    final newAverage = ((state.averageScore * state.totalAttempts) + score) / newTotal;
    
    // Update consecutive days
    final newConsecutiveDays = isConsecutive ? state.consecutiveDays + 1 : 1;
    
    // Check for streak badges
    final newBadges = [...state.earnedBadges];
    if (newConsecutiveDays == 3 && !newBadges.contains('3day_streak')) {
      newBadges.add('3day_streak');
    }
    if (newConsecutiveDays == 7 && !newBadges.contains('7day_streak')) {
      newBadges.add('7day_streak');
    }
    if (newConsecutiveDays == 30 && !newBadges.contains('30day_streak')) {
      newBadges.add('30day_streak');
    }
    
    state = ChallengeStat(
      userId: state.userId,
      totalAttempts: newTotal,
      consecutiveDays: newConsecutiveDays,
      averageScore: newAverage,
      bestScore: score > state.bestScore ? score : state.bestScore,
      lastAttemptAt: now,
      earnedBadges: newBadges,
    );
    
    await _saveStats();
  }
  
  /// Reset stats (for debugging)
  Future<void> resetStats() async {
    state = ChallengeStat(
      userId: 'user_001',
      totalAttempts: 0,
      consecutiveDays: 0,
      averageScore: 0,
      bestScore: 0,
      lastAttemptAt: DateTime.now(),
      earnedBadges: [],
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error resetting stats: $e');
    }
  }
}

/// Friend's current challenge data (for comparison)
final friendChallengeProvider = FutureProvider.family.autoDispose<ChallengeLeaderboardEntry?, String>((ref, friendId) async {
  final leaderboard = await ref.watch(todaysChallengeLeaderboardProvider.future);
  try {
    return leaderboard.firstWhere((entry) => entry.userId == friendId);
  } catch (e) {
    return null;
  }
});
