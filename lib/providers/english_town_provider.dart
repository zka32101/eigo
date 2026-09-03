import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/english_town_model.dart';

// ========== State Notifiers ==========

class TownAreasNotifier extends StateNotifier<List<TownArea>> {
  TownAreasNotifier() : super(_initializeAreas());

  static List<TownArea> _initializeAreas() {
    return [
      TownArea(
        areaId: 'area_school',
        areaType: 'school',
        englishName: 'School',
        japaneseName: '🏫 学校',
        description: 'Learn classroom and educational phrases with teachers and students',
        backgroundTile: '🏫',
        npcIds: ['npc_teacher_1', 'npc_student_1', 'npc_principal'],
        learningThemes: ['classroom', 'education', 'subjects'],
        difficultyLevel: 1,
        progressPercentage: 0,
        wordsLearned: 0,
        coinsEarned: 0,
        isUnlocked: true,
      ),
      TownArea(
        areaId: 'area_market',
        areaType: 'market',
        englishName: 'Market',
        japaneseName: '🛒 市場',
        description: 'Practice shopping and transaction phrases with shopkeepers',
        backgroundTile: '🛒',
        npcIds: ['npc_shopkeeper_1', 'npc_shopkeeper_2', 'npc_customer'],
        learningThemes: ['shopping', 'numbers', 'money'],
        difficultyLevel: 2,
        progressPercentage: 0,
        wordsLearned: 0,
        coinsEarned: 0,
        isUnlocked: false,
      ),
      TownArea(
        areaId: 'area_park',
        areaType: 'park',
        englishName: 'Park',
        japaneseName: '🌳 公園',
        description: 'Learn outdoor and activity phrases with friends and families',
        backgroundTile: '🌳',
        npcIds: ['npc_friend_1', 'npc_friend_2', 'npc_parent'],
        learningThemes: ['activities', 'sports', 'nature'],
        difficultyLevel: 2,
        progressPercentage: 0,
        wordsLearned: 0,
        coinsEarned: 0,
        isUnlocked: false,
      ),
      TownArea(
        areaId: 'area_restaurant',
        areaType: 'restaurant',
        englishName: 'Restaurant',
        japaneseName: '🍽️ レストラン',
        description: 'Practice dining and food-related conversations with chefs and servers',
        backgroundTile: '🍽️',
        npcIds: ['npc_chef', 'npc_waiter', 'npc_foodcritic'],
        learningThemes: ['food', 'ordering', 'cooking'],
        difficultyLevel: 3,
        progressPercentage: 0,
        wordsLearned: 0,
        coinsEarned: 0,
        isUnlocked: false,
      ),
    ];
  }

  Future<void> visitArea(String areaId) async {
    state = state.map((area) {
      if (area.areaId == areaId) {
        return area.copyWith(
          lastVisitedAt: DateTime.now(),
          progressPercentage: (area.progressPercentage + 5).clamp(0, 100),
        );
      }
      return area;
    }).toList();
    await _saveTownAreas();
  }

  Future<void> unlockArea(String areaId) async {
    state = state.map((area) {
      if (area.areaId == areaId) {
        return area.copyWith(isUnlocked: true);
      }
      return area;
    }).toList();
    await _saveTownAreas();
  }

  Future<void> addCoinsToArea(String areaId, int coins) async {
    state = state.map((area) {
      if (area.areaId == areaId) {
        return area.copyWith(
          coinsEarned: area.coinsEarned + coins,
        );
      }
      return area;
    }).toList();
    await _saveTownAreas();
  }

  Future<void> _saveTownAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((a) => a.toJson()).toList();
    await prefs.setString('town_areas', jsonEncode(data));
  }

  TownArea? getAreaById(String areaId) {
    try {
      return state.firstWhere((area) => area.areaId == areaId);
    } catch (e) {
      return null;
    }
  }
}

class NPCsNotifier extends StateNotifier<List<NPC>> {
  NPCsNotifier() : super(_initializeNPCs());

  static List<NPC> _initializeNPCs() {
    return [
      NPC(
        npcId: 'npc_teacher_1',
        name: 'Mr. Smith',
        profession: 'teacher',
        emoji: '👨‍🏫',
        areaId: 'area_school',
        position: 'x:100,y:150',
        conversationPhrases: [
          'Good morning! How are you today?',
          'What is your name?',
          'Can you spell your name?',
          'Do you understand?',
        ],
        learningTheme: 'classroom',
        difficultyLevel: 1,
        vocabularyCount: 50,
        talkCount: 0,
      ),
      NPC(
        npcId: 'npc_student_1',
        name: 'Emma',
        profession: 'student',
        emoji: '👧',
        areaId: 'area_school',
        position: 'x:250,y:180',
        conversationPhrases: [
          'Hi! What\'s your name?',
          'Do you like English?',
          'Want to be friends?',
        ],
        learningTheme: 'greeting',
        difficultyLevel: 1,
        vocabularyCount: 30,
        talkCount: 0,
      ),
      NPC(
        npcId: 'npc_shopkeeper_1',
        name: 'Sarah',
        profession: 'shopkeeper',
        emoji: '👩‍💼',
        areaId: 'area_market',
        position: 'x:120,y:200',
        conversationPhrases: [
          'Welcome to the shop!',
          'How can I help you?',
          'How much is this?',
          'That will be 10 dollars',
        ],
        learningTheme: 'shopping',
        difficultyLevel: 2,
        vocabularyCount: 60,
        talkCount: 0,
      ),
      NPC(
        npcId: 'npc_chef',
        name: 'Marco',
        profession: 'chef',
        emoji: '👨‍🍳',
        areaId: 'area_restaurant',
        position: 'x:180,y:220',
        conversationPhrases: [
          'Welcome to our restaurant!',
          'What would you like to order?',
          'Do you have any allergies?',
          'Enjoy your meal!',
        ],
        learningTheme: 'dining',
        difficultyLevel: 3,
        vocabularyCount: 80,
        talkCount: 0,
      ),
    ];
  }

  Future<void> recordTalk(String npcId) async {
    state = state.map((npc) {
      if (npc.npcId == npcId) {
        return NPC(
          npcId: npc.npcId,
          name: npc.name,
          profession: npc.profession,
          emoji: npc.emoji,
          areaId: npc.areaId,
          position: npc.position,
          conversationPhrases: npc.conversationPhrases,
          learningTheme: npc.learningTheme,
          difficultyLevel: npc.difficultyLevel,
          vocabularyCount: npc.vocabularyCount,
          talkCount: npc.talkCount + 1,
          lastTalkedAt: DateTime.now(),
        );
      }
      return npc;
    }).toList();
    await _saveNPCs();
  }

  Future<void> _saveNPCs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((n) => n.toJson()).toList();
    await prefs.setString('town_npcs', jsonEncode(data));
  }

  NPC? getNPCById(String npcId) {
    try {
      return state.firstWhere((npc) => npc.npcId == npcId);
    } catch (e) {
      return null;
    }
  }

  List<NPC> getNPCsByArea(String areaId) {
    return state.where((npc) => npc.areaId == areaId).toList();
  }
}

class ConversationsNotifier extends StateNotifier<List<Conversation>> {
  ConversationsNotifier() : super([]);

  Future<void> addConversation(Conversation conversation) async {
    state = [...state, conversation];
    await _saveConversations();
  }

  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((c) => c.toJson()).toList();
    await prefs.setString('town_conversations', jsonEncode(data));
  }

  List<Conversation> getConversationsByNPC(String npcId) {
    return state.where((conv) => conv.npcId == npcId).toList();
  }

  int getCorrectConversationCount() {
    return state.where((conv) => conv.isResponseCorrect).length;
  }

  double getAverageScore() {
    if (state.isEmpty) return 0;
    final sum = state.fold<int>(0, (sum, conv) => sum + conv.responseScore);
    return sum / state.length;
  }
}

class TownProgressNotifier extends StateNotifier<TownProgress> {
  TownProgressNotifier()
      : super(
          TownProgress(
            progressId: 'progress_001',
            userId: 'user_001',
            totalAreas: 4,
            unlockedAreas: 1,
            visitedAreas: 0,
            totalConversations: 0,
            correctConversations: 0,
            averageScore: 0,
            totalLearningPoints: 0,
            totalCoinsEarned: 0,
            lastUpdatedAt: DateTime.now(),
          ),
        );

  Future<void> updateProgress({
    String? currentAreaId,
    String? currentNPCId,
    int? coinsEarned,
    int? learningPoints,
    int? responseScore,
    bool? isCorrect,
  }) async {
    final newCorrect =
        state.correctConversations + (isCorrect == true ? 1 : 0);
    final newTotal = state.totalConversations + 1;

    state = state.copyWith(
      currentAreaId: currentAreaId ?? state.currentAreaId,
      currentNPCId: currentNPCId ?? state.currentNPCId,
      totalConversations: newTotal,
      correctConversations: newCorrect,
      averageScore: (state.averageScore * (newTotal - 1) + (responseScore ?? 0)) / newTotal,
      totalLearningPoints: state.totalLearningPoints + (learningPoints ?? 0),
      totalCoinsEarned: state.totalCoinsEarned + (coinsEarned ?? 0),
      lastUpdatedAt: DateTime.now(),
    );
    await _saveProgress();
  }

  Future<void> visitArea(String areaId) async {
    state = state.copyWith(
      currentAreaId: areaId,
      visitedAreas: state.visitedAreas + 1,
      lastVisitedAt: DateTime.now(),
    );
    await _saveProgress();
  }

  Future<void> unlockNewArea() async {
    state = state.copyWith(
      unlockedAreas: state.unlockedAreas + 1,
    );
    await _saveProgress();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('town_progress', jsonEncode(state.toJson()));
  }
}

class TownPlayerProfileNotifier extends StateNotifier<TownPlayerProfile> {
  TownPlayerProfileNotifier()
      : super(
          TownPlayerProfile(
            profileId: 'profile_001',
            userId: 'user_001',
            playerCharacter: '🧒',
            level: 1,
            experience: 0,
            totalCoinsEarned: 0,
            currentCoins: 0,
            uniqueWordsLearned: 0,
            milestonesClaimed: [],
            badgesEarned: [],
            lastUpdatedAt: DateTime.now(),
          ),
        );

  Future<void> earnCoins(int coins) async {
    state = state.copyWith(
      currentCoins: state.currentCoins + coins,
      totalCoinsEarned: state.totalCoinsEarned + coins,
    );
    await _saveProfile();
  }

  Future<void> spendCoins(int coins) async {
    if (state.currentCoins >= coins) {
      state = state.copyWith(
        currentCoins: state.currentCoins - coins,
      );
      await _saveProfile();
    }
  }

  Future<void> earnExperience(int exp) async {
    var newExp = state.experience + exp;
    var newLevel = state.level;

    // Level up every 500 XP
    while (newExp >= 500) {
      newExp -= 500;
      newLevel++;
    }

    state = state.copyWith(
      experience: newExp,
      level: newLevel,
    );
    await _saveProfile();
  }

  Future<void> learnWord(String word) async {
    state = state.copyWith(
      uniqueWordsLearned: state.uniqueWordsLearned + 1,
    );
    await _saveProfile();
  }

  Future<void> claimBadge(String badgeId) async {
    if (!state.badgesEarned.contains(badgeId)) {
      state = state.copyWith(
        badgesEarned: [...state.badgesEarned, badgeId],
      );
      await _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('town_player_profile', jsonEncode(state.toJson()));
  }
}

class TownStatsNotifier extends StateNotifier<TownStats> {
  TownStatsNotifier()
      : super(
          TownStats(
            statsId: 'stats_001',
            userId: 'user_001',
            totalPlayTime: 0,
            totalConversations: 0,
            averageScore: 0,
            highScore: 0,
            visitDays: 0,
            consecutiveVisitDays: 0,
            totalWordsLearned: 0,
            totalCoinsEarned: 0,
            badgesCount: 0,
            milestonesCount: 0,
            lastUpdatedAt: DateTime.now(),
          ),
        );

  Future<void> recordSession({
    required int playTime,
    required int conversations,
    required double averageScore,
    required int wordsLearned,
    required int coinsEarned,
  }) async {
    final newHighScore = (averageScore * 100).toInt();
    final existingHighScore = state.highScore;

    state = state.copyWith(
      totalPlayTime: state.totalPlayTime + playTime,
      totalConversations: state.totalConversations + conversations,
      averageScore:
          (state.averageScore * state.totalConversations + averageScore) /
              (state.totalConversations + conversations),
      highScore: newHighScore > existingHighScore ? newHighScore : existingHighScore,
      totalWordsLearned: state.totalWordsLearned + wordsLearned,
      totalCoinsEarned: state.totalCoinsEarned + coinsEarned,
      lastUpdatedAt: DateTime.now(),
    );
    await _saveStats();
  }

  Future<void> updateVisitStreak(int days) async {
    state = state.copyWith(
      visitDays: state.visitDays + 1,
      consecutiveVisitDays: days,
    );
    await _saveStats();
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('town_stats', jsonEncode(state.toJson()));
  }
}

// ========== Providers ==========

final townAreasProvider = StateNotifierProvider<TownAreasNotifier, List<TownArea>>((ref) {
  return TownAreasNotifier();
});

final npcsProvider = StateNotifierProvider<NPCsNotifier, List<NPC>>((ref) {
  return NPCsNotifier();
});

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, List<Conversation>>((ref) {
  return ConversationsNotifier();
});

final townProgressProvider =
    StateNotifierProvider<TownProgressNotifier, TownProgress>((ref) {
  return TownProgressNotifier();
});

final townPlayerProfileProvider =
    StateNotifierProvider<TownPlayerProfileNotifier, TownPlayerProfile>((ref) {
  return TownPlayerProfileNotifier();
});

final townStatsProvider =
    StateNotifierProvider<TownStatsNotifier, TownStats>((ref) {
  return TownStatsNotifier();
});

// ========== Computed Providers ==========

final areaProgressProvider = Provider.family<TownArea?, String>((ref, areaId) {
  final areas = ref.watch(townAreasProvider);
  return areas.firstWhere((area) => area.areaId == areaId);
});

final npcsByAreaProvider =
    Provider.family<List<NPC>, String>((ref, areaId) {
  final npcs = ref.watch(npcsProvider);
  return npcs.where((npc) => npc.areaId == areaId).toList();
});

final conversationHistoryProvider = Provider<List<Conversation>>((ref) {
  return ref.watch(conversationsProvider);
});

final playerLevelProvider = Provider<int>((ref) {
  return ref.watch(townPlayerProfileProvider).level;
});

final playerCoinsProvider = Provider<int>((ref) {
  return ref.watch(townPlayerProfileProvider).currentCoins;
});

final overallProgressPercentage = Provider<double>((ref) {
  final progress = ref.watch(townProgressProvider);
  if (progress.totalAreas == 0) return 0;
  return (progress.visitedAreas / progress.totalAreas) * 100;
});
