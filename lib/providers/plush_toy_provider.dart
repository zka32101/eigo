import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/plush_toy_model.dart';
import '../services/logger_service.dart';

// === Providers ===

/// ユーザーのぬいぐるみキャラクター
final plushToyCharacterProvider =
    StateNotifierProvider<PlushToyCharacterNotifier, PlushToyCharacter?>(
  (ref) => PlushToyCharacterNotifier(),
);

/// 現在のセッション
final currentSessionProvider =
    StateNotifierProvider<CurrentSessionNotifier, PlushToySession?>(
  (ref) => CurrentSessionNotifier(),
);

/// 会話ログ
final conversationHistoryProvider =
    StateNotifierProvider<ConversationHistoryNotifier, List<PlushToyConversation>>(
  (ref) => ConversationHistoryNotifier(),
);

/// ぬいぐるみモード統計
final plushToyStatsProvider =
    StateNotifierProvider<PlushToyStatsNotifier, PlushToyStats>(
  (ref) => PlushToyStatsNotifier(),
);

/// プログレス情報
final plushToyProgressProvider =
    StateNotifierProvider<PlushToyProgressNotifier, PlushToyProgress?>(
  (ref) => PlushToyProgressNotifier(),
);

/// 利用可能なトピック
final availableTopicsProvider = Provider<List<PlushToyTopic>>((ref) {
  return _initializeTopics();
});

// === State Notifiers ===

class PlushToyCharacterNotifier extends StateNotifier<PlushToyCharacter?> {
  static const _storageKey = 'eigo_kore_plush_toy_character';

  PlushToyCharacterNotifier() : super(null) {
    _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        state = PlushToyCharacter.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      LoggerService.error('Failed to load plush toy character', tag: 'PlushToyCharacterNotifier', exception: e);
    }
  }

  Future<void> _saveCharacter() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state!.toJson()));
    } catch (e) {
      LoggerService.error('Failed to save plush toy character', tag: 'PlushToyCharacterNotifier', exception: e);
    }
  }

  /// 新しいキャラクターを作成
  Future<void> createCharacter({
    required PlushToySpecies species,
    required String customName,
    required String personality,
  }) async {
    final characterId = 'plush_toy_${DateTime.now().millisecondsSinceEpoch}';

    state = PlushToyCharacter(
      characterId: characterId,
      species: species,
      customName: customName,
      personality: personality,
      experiencePoints: 0,
      affectionLevel: 0,
      createdAt: DateTime.now(),
      lastConversationAt: null,
      unlockedSkills: [],
    );

    await _saveCharacter();
  }

  /// キャラクターの経験値を更新
  Future<void> addExperience(int points) async {
    if (state == null) return;

    state = PlushToyCharacter(
      characterId: state!.characterId,
      species: state!.species,
      customName: state!.customName,
      personality: state!.personality,
      experiencePoints: state!.experiencePoints + points,
      affectionLevel: state!.affectionLevel + 1,
      createdAt: state!.createdAt,
      lastConversationAt: DateTime.now(),
      unlockedSkills: state!.unlockedSkills,
    );

    await _saveCharacter();
  }

  /// スキルをアンロック
  Future<void> unlockSkill(String skillId) async {
    if (state == null) return;

    final updatedSkills = [...state!.unlockedSkills, skillId];

    state = PlushToyCharacter(
      characterId: state!.characterId,
      species: state!.species,
      customName: state!.customName,
      personality: state!.personality,
      experiencePoints: state!.experiencePoints,
      affectionLevel: state!.affectionLevel,
      createdAt: state!.createdAt,
      lastConversationAt: state!.lastConversationAt,
      unlockedSkills: updatedSkills,
    );

    await _saveCharacter();
  }
}

class CurrentSessionNotifier extends StateNotifier<PlushToySession?> {
  static const _storageKey = 'eigo_kore_current_plush_toy_session';

  CurrentSessionNotifier() : super(null) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        state = PlushToySession.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      LoggerService.error('Failed to load current session', tag: 'CurrentSessionNotifier', exception: e);
    }
  }

  Future<void> _saveSession() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state!.toJson()));
    } catch (e) {
      LoggerService.error('Failed to save current session', tag: 'CurrentSessionNotifier', exception: e);
    }
  }

  /// セッションを開始
  Future<void> startSession({
    required String characterId,
    required String topic,
  }) async {
    const userId = 'user_001'; // 実運用時は実際のユーザーID

    state = PlushToySession(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      characterId: characterId,
      userId: userId,
      startedAt: DateTime.now(),
      turnCount: 0,
      topic: topic,
      phrasesLearned: 0,
      pronunciationChecks: 0,
      averageScore: 0,
      sessionQuality: 0.0,
      rewardCoins: 0,
      earnedXP: 0,
    );

    await _saveSession();
  }

  /// ターンを追加
  Future<void> addTurn({
    required int pronunciationScore,
    required int phrasesLearned,
  }) async {
    if (state == null) return;

    final newTurnCount = state!.turnCount + 1;
    final newPronunciationChecks = state!.pronunciationChecks + 1;
    final totalScore = (state!.averageScore * state!.turnCount + pronunciationScore);
    final newAverageScore = (totalScore / newTurnCount).toInt();
    final newPhrasesLearned = state!.phrasesLearned + phrasesLearned;

    state = PlushToySession(
      sessionId: state!.sessionId,
      characterId: state!.characterId,
      userId: state!.userId,
      startedAt: state!.startedAt,
      turnCount: newTurnCount,
      topic: state!.topic,
      phrasesLearned: newPhrasesLearned,
      pronunciationChecks: newPronunciationChecks,
      averageScore: newAverageScore,
      sessionQuality: state!.sessionQuality,
      rewardCoins: state!.rewardCoins,
      earnedXP: state!.earnedXP,
    );

    await _saveSession();
  }

  /// セッションを終了
  Future<void> endSession({
    required String? userMood,
    required double sessionQuality,
  }) async {
    if (state == null) return;

    // 報酬計算
    final rewardCoins = state!.averageScore ~/ 10 + 15;
    final earnedXP = state!.turnCount * 5;

    state = PlushToySession(
      sessionId: state!.sessionId,
      characterId: state!.characterId,
      userId: state!.userId,
      startedAt: state!.startedAt,
      endedAt: DateTime.now(),
      turnCount: state!.turnCount,
      topic: state!.topic,
      phrasesLearned: state!.phrasesLearned,
      pronunciationChecks: state!.pronunciationChecks,
      averageScore: state!.averageScore,
      userMood: userMood,
      sessionQuality: sessionQuality,
      rewardCoins: rewardCoins,
      earnedXP: earnedXP,
    );

    await _saveSession();
  }

  /// セッションをリセット
  Future<void> clearSession() async {
    state = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      LoggerService.error('Failed to clear session', tag: 'CurrentSessionNotifier', exception: e);
    }
  }
}

class ConversationHistoryNotifier extends StateNotifier<List<PlushToyConversation>> {
  static const _storageKey = 'eigo_kore_conversation_history';

  ConversationHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        state = jsonList
            .map((e) => PlushToyConversation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      LoggerService.error('Failed to load conversation history', tag: 'ConversationHistoryNotifier', exception: e);
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      LoggerService.error('Failed to save conversation history', tag: 'ConversationHistoryNotifier', exception: e);
    }
  }

  /// 会話を記録
  Future<void> recordConversation({
    required String sessionId,
    required List<PlushToyMessage> messages,
    required String theme,
    required List<String> learningPoints,
    required bool challengeCompleted,
    required int durationSeconds,
  }) async {
    // 会話の自然さを計算（ここではモック）
    final naturalness = (0.7 + (learningPoints.length / 10)).clamp(0.0, 1.0);

    final conversation = PlushToyConversation(
      conversationId: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      messages: messages,
      theme: theme,
      learningPoints: learningPoints,
      challengeCompleted: challengeCompleted,
      naturalness: naturalness,
      durationSeconds: durationSeconds,
    );

    state = [...state, conversation];
    await _saveHistory();
  }
}

class PlushToyStatsNotifier extends StateNotifier<PlushToyStats> {
  static const _storageKey = 'eigo_kore_plush_toy_stats';

  PlushToyStatsNotifier()
      : super(
          PlushToyStats(
            statsId: 'stats_initial',
            userId: 'user_001',
            totalSessions: 0,
            totalTurns: 0,
            totalPhrasesLearned: 0,
            averageSessionDuration: 0.0,
            averageScore: 0.0,
            consecutiveDays: 0,
            longestStreak: 0,
            preferredTimeSlots: {},
            favoriteTopics: [],
            screenTimeReduction: 0.0,
            parentalSatisfaction: 0.0,
            totalRewardCoins: 0,
            unlockedBadges: [],
            lastUpdatedAt: DateTime.now(),
          ),
        ) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        state = PlushToyStats.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      LoggerService.error('Failed to load plush toy stats', tag: 'PlushToyStatsNotifier', exception: e);
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      LoggerService.error('Failed to save plush toy stats', tag: 'PlushToyStatsNotifier', exception: e);
    }
  }

  /// セッション終了時に統計を更新
  Future<void> updateStatsAfterSession({
    required PlushToySession session,
  }) async {
    int durationSeconds = session.endedAt?.difference(session.startedAt).inSeconds ?? 0;

    // 時間帯を記録
    final hour = session.startedAt.hour;
    final timeSlot = _getTimeSlot(hour);
    final updatedTimeSlots = Map<String, int>.from(state.preferredTimeSlots);
    updatedTimeSlots[timeSlot] = (updatedTimeSlots[timeSlot] ?? 0) + 1;

    // トピック追跡
    final updatedTopics = Set<String>.from(state.favoriteTopics);
    updatedTopics.add(session.topic);

    // 連日ストリーク計算（簡略版：デモ用）
    int newConsecutiveDays = state.consecutiveDays + 1;
    int newLongestStreak = newConsecutiveDays > state.longestStreak
        ? newConsecutiveDays
        : state.longestStreak;

    // スクリーンタイム削減率（ハンズフリー比率）
    double screenTimeReduction = 0.95; // デモ：95%ハンズフリー

    // 親満足度スコア計算
    // 継続性 + セッション品質 + 学習量で計算
    double parentSatisfaction =
        ((state.consecutiveDays / 30) * 0.3 +
                (session.sessionQuality) * 0.5 +
                (session.phrasesLearned / 10) * 0.2)
            .clamp(0.0, 1.0);

    // バッジ判定
    List<String> updatedBadges = List.from(state.unlockedBadges);
    if (state.totalSessions == 0) updatedBadges.add('first_session');
    if (newLongestStreak >= 7) updatedBadges.add('week_warrior');
    if (newLongestStreak >= 30) updatedBadges.add('month_master');

    final newStats = PlushToyStats(
      statsId: state.statsId,
      userId: state.userId,
      totalSessions: state.totalSessions + 1,
      totalTurns: state.totalTurns + session.turnCount,
      totalPhrasesLearned: state.totalPhrasesLearned + session.phrasesLearned,
      averageSessionDuration: (state.averageSessionDuration * state.totalSessions +
              durationSeconds) /
          (state.totalSessions + 1),
      averageScore: ((state.averageScore * state.totalSessions + session.averageScore) /
              (state.totalSessions + 1))
          .toDouble(),
      consecutiveDays: newConsecutiveDays,
      longestStreak: newLongestStreak,
      preferredTimeSlots: updatedTimeSlots,
      favoriteTopics: updatedTopics.toList(),
      screenTimeReduction: screenTimeReduction,
      parentalSatisfaction: parentSatisfaction,
      totalRewardCoins: state.totalRewardCoins + session.rewardCoins,
      unlockedBadges: updatedBadges,
      lastUpdatedAt: DateTime.now(),
    );

    state = newStats;
    await _saveStats();
  }

  String _getTimeSlot(int hour) {
    if (hour < 6) return '深夜';
    if (hour < 12) return '朝';
    if (hour < 18) return '午後';
    return '夜';
  }
}

class PlushToyProgressNotifier extends StateNotifier<PlushToyProgress?> {
  static const _storageKey = 'eigo_kore_plush_toy_progress';

  PlushToyProgressNotifier() : super(null) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        state = PlushToyProgress.fromJson(jsonDecode(jsonString));
      } else {
        // 初期化
        state = PlushToyProgress(
          progressId: 'progress_initial',
          userId: 'user_001',
          level: 1,
          experienceToNextLevel: 100,
          masteredTopics: 0,
          topicMastery: {},
          handsfreeRatio: 0.0,
          pronunciationImprovement: 0.0,
          parentFeedbackCount: 0,
          parentRating: 0.0,
          lastUpdatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      LoggerService.error('Failed to load plush toy progress', tag: 'PlushToyProgressNotifier', exception: e);
    }
  }

  Future<void> _saveProgress() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state!.toJson()));
    } catch (e) {
      LoggerService.error('Failed to save plush toy progress', tag: 'PlushToyProgressNotifier', exception: e);
    }
  }

  /// プログレスを更新（セッション終了後）
  Future<void> updateProgress({
    required int averageScore,
    required String topic,
    required double handsfreeRatio,
  }) async {
    if (state == null) return;

    // トピック習得度を更新
    final updatedMastery = Map<String, double>.from(state!.topicMastery);
    updatedMastery[topic] =
        ((averageScore / 100) * 100).clamp(0.0, 100.0);

    // マスター判定
    int masteredCount = updatedMastery.values
        .where((v) => v >= 80.0)
        .length;

    // レベルアップ判定（簡略版）
    int expToNextLevel = state!.experienceToNextLevel - (averageScore ~/ 10);
    int newLevel = state!.level;
    if (expToNextLevel <= 0) {
      newLevel += 1;
      expToNextLevel = 100;
    }

    state = PlushToyProgress(
      progressId: state!.progressId,
      userId: state!.userId,
      level: newLevel,
      experienceToNextLevel: expToNextLevel.clamp(0, 100),
      masteredTopics: masteredCount,
      topicMastery: updatedMastery,
      handsfreeRatio: handsfreeRatio,
      pronunciationImprovement: ((averageScore / 100) * 0.5).clamp(0.0, 1.0),
      parentFeedbackCount: state!.parentFeedbackCount,
      parentRating: state!.parentRating,
      lastUpdatedAt: DateTime.now(),
    );

    await _saveProgress();
  }
}

// === Mock Data ===

List<PlushToyTopic> _initializeTopics() {
  return [
    PlushToyTopic(
      topicId: 'topic_greeting',
      name: 'Greetings & Introductions',
      difficulty: 'beginner',
      description: 'Learn how to greet and introduce yourself',
      suggestedPhrases: 5,
      initialPrompt: 'Hello! What is your name?',
      vocabularyKeywords: ['hello', 'hi', 'nice', 'meet', 'name', 'introduce'],
      learningOutcomes: [
        'Greet in English',
        'Introduce yourself',
        'Ask someone\'s name',
      ],
      gradeLevel: 'elementary',
    ),
    PlushToyTopic(
      topicId: 'topic_daily_life',
      name: 'Daily Life & Activities',
      difficulty: 'beginner',
      description: 'Talk about your daily routines and activities',
      suggestedPhrases: 8,
      initialPrompt: 'What did you do today?',
      vocabularyKeywords: [
        'morning',
        'breakfast',
        'school',
        'friend',
        'play',
        'homework',
        'sleep'
      ],
      learningOutcomes: [
        'Describe daily activities',
        'Use past tense',
        'Talk about routines',
      ],
      gradeLevel: 'elementary',
    ),
    PlushToyTopic(
      topicId: 'topic_emotions',
      name: 'Feelings & Emotions',
      difficulty: 'intermediate',
      description: 'Express how you feel in various situations',
      suggestedPhrases: 10,
      initialPrompt: 'How are you feeling today?',
      vocabularyKeywords: [
        'happy',
        'sad',
        'excited',
        'tired',
        'angry',
        'scared',
        'surprised'
      ],
      learningOutcomes: [
        'Express emotions',
        'Use adjectives',
        'Explain reasons',
      ],
      gradeLevel: 'junior_high',
    ),
    PlushToyTopic(
      topicId: 'topic_hobbies',
      name: 'Hobbies & Interests',
      difficulty: 'intermediate',
      description: 'Talk about your favorite hobbies and interests',
      suggestedPhrases: 10,
      initialPrompt: 'What are your hobbies?',
      vocabularyKeywords: [
        'hobby',
        'sport',
        'music',
        'reading',
        'game',
        'art',
        'favorite'
      ],
      learningOutcomes: [
        'Describe hobbies',
        'Explain preferences',
        'Ask about interests',
      ],
      gradeLevel: 'junior_high',
    ),
    PlushToyTopic(
      topicId: 'topic_travel',
      name: 'Travel & Adventures',
      difficulty: 'advanced',
      description: 'Discuss travel experiences and dream destinations',
      suggestedPhrases: 12,
      initialPrompt: 'Where would you like to travel?',
      vocabularyKeywords: [
        'travel',
        'country',
        'visit',
        'airport',
        'hotel',
        'culture',
        'experience'
      ],
      learningOutcomes: [
        'Discuss travel plans',
        'Describe places',
        'Use conditional tense',
      ],
      gradeLevel: 'high_school',
    ),
  ];
}
