import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../data/english_town_data.dart';

/// ==================== TOWN MAP STATE ====================

/// Provides access to the complete English-Only Town map
final townMapProvider = StateProvider<TownMap>((ref) {
  return EnglishTownData.townMap;
});

/// Get all locations in the town
final townLocationsProvider = Provider<List<Location>>((ref) {
  final townMap = ref.watch(townMapProvider);
  return townMap.locations;
});

/// Get all NPCs in the town
final townNPCsProvider = Provider<List<NPC>>((ref) {
  final townMap = ref.watch(townMapProvider);
  return townMap.npcs;
});

/// Get all interaction scenes
final townScenesProvider = Provider<List<InteractionScene>>((ref) {
  final townMap = ref.watch(townMapProvider);
  return townMap.scenes;
});

/// Get a specific location by ID
final getLocationProvider = FutureProvider.family<Location?, String>((ref, locationId) async {
  final townMap = ref.watch(townMapProvider);
  return townMap.getLocation(locationId);
});

/// Get a specific NPC by ID
final getNPCProvider = FutureProvider.family<NPC?, String>((ref, npcId) async {
  final townMap = ref.watch(townMapProvider);
  return townMap.getNPC(npcId);
});

/// ==================== PLAYER PROGRESS ====================

/// Manages player's progress in English-Only Town
class TownProgressNotifier extends StateNotifier<TownProgress> {
  TownProgressNotifier() : super(_initialProgress());

  static TownProgress _initialProgress() {
    return TownProgress(
      userId: 'current_user', // TODO: Get from auth provider
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
      currentTimeOfDay: TimeOfDay.afternoon,
      currentWeather: WeatherType.sunny,
    );
  }

  /// Mark a location as visited
  void visitLocation(String locationId) {
    state = state.copyWith(
      visitedLocationIds: {...state.visitedLocationIds, locationId},
      lastPlayedAt: DateTime.now(),
    );
  }

  /// Record a conversation with an NPC
  void recordNPCConversation(String npcId, int xpReward, int coinReward) {
    final updatedCounts = Map<String, int>.from(state.npcConversationCounts);
    updatedCounts[npcId] = (updatedCounts[npcId] ?? 0) + 1;

    state = state.copyWith(
      npcConversationCounts: updatedCounts,
      totalConversations: state.totalConversations + 1,
      totalXpEarned: state.totalXpEarned + xpReward,
      totalCoinsEarned: state.totalCoinsEarned + coinReward,
      lastPlayedAt: DateTime.now(),
    );
  }

  /// Record scene completion
  void recordSceneCompletion(String sceneId, int xpReward, int coinReward) {
    final updatedCounts = Map<String, int>.from(state.sceneCompletionCounts);
    updatedCounts[sceneId] = (updatedCounts[sceneId] ?? 0) + 1;

    state = state.copyWith(
      sceneCompletionCounts: updatedCounts,
      totalXpEarned: state.totalXpEarned + xpReward,
      totalCoinsEarned: state.totalCoinsEarned + coinReward,
    );
  }

  /// Unlock an achievement
  void unlockAchievement(String achievementId) {
    state = state.copyWith(
      unlockedAchievements: {...state.unlockedAchievements, achievementId},
    );
  }

  /// Update time of day (affects NPC availability)
  void updateTimeOfDay(TimeOfDay newTime) {
    state = state.copyWith(
      currentTimeOfDay: newTime,
    );
  }

  /// Update weather (affects dialogue context)
  void updateWeather(WeatherType newWeather) {
    state = state.copyWith(
      currentWeather: newWeather,
    );
  }
}

final townProgressProvider =
    StateNotifierProvider<TownProgressNotifier, TownProgress>((ref) {
  return TownProgressNotifier();
});

/// ==================== NPC STATE ====================

/// Get conversations count for a specific NPC
final npcConversationCountProvider =
    Provider.family<int, String>((ref, npcId) {
  final progress = ref.watch(townProgressProvider);
  return progress.npcConversationCounts[npcId] ?? 0;
});

/// Get total locations visited
final visitedLocationsCountProvider = Provider<int>((ref) {
  final progress = ref.watch(townProgressProvider);
  return progress.visitedLocationIds.length;
});

/// Get total locations available
final totalLocationsProvider = Provider<int>((ref) {
  final locations = ref.watch(townLocationsProvider);
  return locations.length;
});

/// Get NPCs currently present at a location (based on time and preferences)
class LocationNPCsNotifier extends StateNotifier<List<NPC>> {
  LocationNPCsNotifier(this.ref, this.locationId)
      : super([]) {
    _updateNPCPresence();
  }

  final Ref ref;
  final String locationId;

  void _updateNPCPresence() {
    final townMap = ref.read(townMapProvider);
    final progress = ref.read(townProgressProvider);
    final currentTime = progress.currentTimeOfDay;

    // Get location
    final location = townMap.getLocation(locationId);
    if (location == null) return;

    // Get all NPCs and filter by location presence
    final presentNPCs = townMap.npcs
        .where((npc) {
          // NPC must be at this location or visiting it
          if (npc.nativeLocation == locationId) return true;
          if (npc.frequentLocations.contains(locationId)) {
            // Rough probability: 70% chance they're at frequent locations
            return DateTime.now().millisecondsSinceEpoch % 10 > 3;
          }
          return false;
        })
        .toList();

    state = presentNPCs;
  }

  /// Update when time changes
  void updateForTimeChange(TimeOfDay newTime) {
    _updateNPCPresence();
  }
}

final locationNPCsProvider =
    StateNotifierProvider.family<LocationNPCsNotifier, List<NPC>, String>(
        (ref, locationId) {
  return LocationNPCsNotifier(ref, locationId);
});

/// ==================== CONVERSATION STATE ====================

class CurrentConversationState {
  final String? sceneId;
  final String? npcId;
  final String? locationId;
  final List<ConversationTurn> conversationHistory;
  final bool isActive;
  final DateTime startedAt;

  CurrentConversationState({
    this.sceneId,
    this.npcId,
    this.locationId,
    this.conversationHistory = const [],
    this.isActive = false,
    required this.startedAt,
  });

  CurrentConversationState copyWith({
    String? sceneId,
    String? npcId,
    String? locationId,
    List<ConversationTurn>? conversationHistory,
    bool? isActive,
    DateTime? startedAt,
  }) {
    return CurrentConversationState(
      sceneId: sceneId ?? this.sceneId,
      npcId: npcId ?? this.npcId,
      locationId: locationId ?? this.locationId,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

class CurrentConversationNotifier
    extends StateNotifier<CurrentConversationState> {
  CurrentConversationNotifier()
      : super(CurrentConversationState(startedAt: DateTime.now()));

  /// Start a new conversation with an NPC
  void startConversation({
    required String sceneId,
    required String npcId,
    required String locationId,
  }) {
    state = CurrentConversationState(
      sceneId: sceneId,
      npcId: npcId,
      locationId: locationId,
      isActive: true,
      startedAt: DateTime.now(),
    );
  }

  /// Add a turn to the conversation
  void addTurn(ConversationTurn turn) {
    state = state.copyWith(
      conversationHistory: [...state.conversationHistory, turn],
    );
  }

  /// End the current conversation
  void endConversation() {
    state = state.copyWith(
      isActive: false,
    );
  }

  /// Clear conversation state
  void clearConversation() {
    state = CurrentConversationState(startedAt: DateTime.now());
  }
}

final currentConversationProvider =
    StateNotifierProvider<CurrentConversationNotifier, CurrentConversationState>(
        (ref) {
  return CurrentConversationNotifier();
});

/// ==================== PROGRESS TRACKING ====================

/// Get progress percentage (0-100)
final townProgressPercentageProvider = Provider<int>((ref) {
  final progress = ref.watch(townProgressProvider);
  final totalScenes = ref.watch(townScenesProvider).length;
  return progress.getProgressPercentage(totalScenes);
});

/// Get total XP earned in town
final totalXpEarnedProvider = Provider<int>((ref) {
  final progress = ref.watch(townProgressProvider);
  return progress.totalXpEarned;
});

/// Get total coins earned in town
final totalCoinsEarnedProvider = Provider<int>((ref) {
  final progress = ref.watch(townProgressProvider);
  return progress.totalCoinsEarned;
});

/// Get achievement count
final unlockedAchievementsCountProvider = Provider<int>((ref) {
  final progress = ref.watch(townProgressProvider);
  return progress.unlockedAchievements.length;
});

/// ==================== SCENE PROVIDERS ====================

/// Get scenes for a specific location
final locationScenesProvider =
    Provider.family<List<InteractionScene>, String>((ref, locationId) {
  final townMap = ref.watch(townMapProvider);
  return townMap.getLocationScenes(locationId);
});

/// Get scenes for a specific NPC
final npcScenesProvider =
    Provider.family<List<InteractionScene>, String>((ref, npcId) {
  final townMap = ref.watch(townMapProvider);
  return townMap.getNPCScenes(npcId);
});

/// Get a specific scene by ID
final getSceneProvider =
    Provider.family<InteractionScene?, String>((ref, sceneId) {
  final scenes = ref.watch(townScenesProvider);
  try {
    return scenes.firstWhere((scene) => scene.id == sceneId);
  } catch (e) {
    return null;
  }
});

/// ==================== ANALYTICS ====================

/// Get stats for NPC interactions
class NPCStatsNotifier extends StateNotifier<Map<String, int>> {
  NPCStatsNotifier(this.ref) : super({}) {
    _loadStats();
  }

  final Ref ref;

  void _loadStats() {
    final progress = ref.read(townProgressProvider);
    state = Map<String, int>.from(progress.npcConversationCounts);
  }

  void refreshStats() {
    _loadStats();
  }
}

final npcStatsProvider =
    StateNotifierProvider<NPCStatsNotifier, Map<String, int>>((ref) {
  return NPCStatsNotifier(ref);
});

/// Get most talked-to NPC
final mostTalkedToNPCProvider = Provider<NPC?>((ref) {
  final stats = ref.watch(npcStatsProvider);
  final npcs = ref.watch(townNPCsProvider);

  if (stats.isEmpty) return null;

  final maxEntry = stats.entries.reduce(
    (a, b) => a.value > b.value ? a : b,
  );

  return npcs.firstWhereOrNull((npc) => npc.id == maxEntry.key);
});

/// Get least talked-to NPC (for recommendations)
final leastTalkedToNPCProvider = Provider<NPC?>((ref) {
  final stats = ref.watch(npcStatsProvider);
  final npcs = ref.watch(townNPCsProvider);
  final progress = ref.watch(townProgressProvider);

  if (npcs.isEmpty) return null;

  // Find NPC with fewest conversations
  NPC? leastTalked;
  int minConversations = int.maxFinite;

  for (final npc in npcs) {
    final count = progress.npcConversationCounts[npc.id] ?? 0;
    if (count < minConversations) {
      minConversations = count;
      leastTalked = npc;
    }
  }

  return leastTalked;
});

/// ==================== DAILIES & CHALLENGES ====================

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final int xpReward;
  final int coinReward;
  final bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    required this.xpReward,
    required this.coinReward,
    this.isCompleted = false,
  });

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    int? targetCount,
    int? currentCount,
    int? xpReward,
    int? coinReward,
    bool? isCompleted,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class DailyChallengesNotifier extends StateNotifier<List<DailyChallenge>> {
  DailyChallengesNotifier()
      : super([
          DailyChallenge(
            id: 'daily_1',
            title: 'Talk to 3 NPCs',
            description: 'Have conversations with 3 different NPCs',
            targetCount: 3,
            xpReward: 100,
            coinReward: 50,
          ),
          DailyChallenge(
            id: 'daily_2',
            title: 'Visit all Locations',
            description: 'Visit all 8 locations in town',
            targetCount: 8,
            xpReward: 250,
            coinReward: 100,
          ),
          DailyChallenge(
            id: 'daily_3',
            title: 'Have 5 Conversations',
            description: 'Complete 5 conversation scenes',
            targetCount: 5,
            xpReward: 150,
            coinReward: 75,
          ),
        ]);

  void updateChallengeProgress(String challengeId, int newCount) {
    state = state.map((challenge) {
      if (challenge.id == challengeId) {
        final isCompleted = newCount >= challenge.targetCount;
        return challenge.copyWith(
          currentCount: newCount,
          isCompleted: isCompleted,
        );
      }
      return challenge;
    }).toList();
  }

  void resetDaily() {
    state = state
        .map((challenge) => challenge.copyWith(currentCount: 0, isCompleted: false))
        .toList();
  }
}

final dailyChallengesProvider =
    StateNotifierProvider<DailyChallengesNotifier, List<DailyChallenge>>((ref) {
  return DailyChallengesNotifier();
});

/// Get completed challenges count
final completedChallengesCountProvider = Provider<int>((ref) {
  final challenges = ref.watch(dailyChallengesProvider);
  return challenges.where((c) => c.isCompleted).length;
});

/// ==================== CONVERSATION ENGINE (Phase 3) ====================

/// Generate NPC dialogue based on player input
/// Uses Claude API with context about NPC, location, time of day, and difficulty
final npcDialogueProvider =
    FutureProvider.family<String, ({
      NPC npc,
      Location location,
      TimeOfDay timeOfDay,
      ConversationDifficulty difficulty,
      String playerMessage,
      List<ConversationTurn> history,
    })>((ref, params) async {
  // This provider will be implemented in Phase 3 with actual Claude API integration
  // For now, returns a placeholder response
  await Future.delayed(const Duration(milliseconds: 500));
  return "That's interesting! Can you tell me more?";
});

/// Evaluate player's response for correctness and provide feedback
final responseEvaluationProvider =
    FutureProvider.family<({
      int score,
      String feedback,
      List<String> vocabulary,
      bool passed,
    }), ({
      String playerResponse,
      NPC npc,
      ConversationDifficulty difficulty,
      String npcExpectation,
    })>((ref, params) async {
  // This provider will be implemented in Phase 3 with actual evaluation logic
  // For now, returns a placeholder evaluation
  await Future.delayed(const Duration(milliseconds: 300));
  return (
    score: 75,
    feedback: "Good job! Keep practicing.",
    vocabulary: [],
    passed: true,
  );
});

/// Get speech-to-text input (will be integrated with speech_provider)
final playerSpeechInputProvider =
    StateProvider<String>((ref) => '');

/// Track conversation XP earned
final conversationXpProvider = StateProvider<int>((ref) => 0);

/// Track conversation coins earned
final conversationCoinsProvider = StateProvider<int>((ref) => 0);
