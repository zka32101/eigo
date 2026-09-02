import 'package:flutter/material.dart';

/// Difficulty level for conversations in English-Only Town
enum ConversationDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Mood states for NPCs that affect dialogue
enum NPCMood {
  happy,
  neutral,
  tired,
  excited,
  sad,
}

/// Time of day affects NPC locations and available dialogue
enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}

/// Weather conditions affect NPC behavior and dialogue context
enum WeatherType {
  sunny,
  rainy,
  cloudy,
  snowy,
}

/// Represents a single location in the English-Only Town
class Location {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Offset position; // x, y coordinates on the 2D map
  final List<String> npcIds; // IDs of NPCs present at this location
  final List<String> sceneIds; // IDs of available interaction scenes
  final String backgroundImage;
  final bool isUnlocked;
  final int requiredConversations; // How many conversations needed to unlock
  final int? unlockedAt; // Timestamp when this location was unlocked

  Location({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.position,
    required this.npcIds,
    required this.sceneIds,
    required this.backgroundImage,
    this.isUnlocked = true,
    this.requiredConversations = 0,
    this.unlockedAt,
  });

  Location copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    Offset? position,
    List<String>? npcIds,
    List<String>? sceneIds,
    String? backgroundImage,
    bool? isUnlocked,
    int? requiredConversations,
    int? unlockedAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      position: position ?? this.position,
      npcIds: npcIds ?? this.npcIds,
      sceneIds: sceneIds ?? this.sceneIds,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredConversations: requiredConversations ?? this.requiredConversations,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// Represents an NPC character in the town
class NPC {
  final String id;
  final String name;
  final String emoji;
  final String personality; // e.g., "Friendly", "Professional", "Intellectual"
  final String nativeLocation; // Primary location where NPC works
  final List<String> frequentLocations; // Other locations NPC visits
  final String backstory; // Brief background for contextual dialogue
  final ConversationDifficulty typicalDifficulty;
  final int conversationCount; // How many times player has talked to this NPC
  final NPCMood currentMood; // Affects dialogue tone
  final TimeOfDay? preferredTime; // NPC is most likely present at this time
  final Color characterColor; // For UI representation

  NPC({
    required this.id,
    required this.name,
    required this.emoji,
    required this.personality,
    required this.nativeLocation,
    required this.frequentLocations,
    required this.backstory,
    required this.typicalDifficulty,
    this.conversationCount = 0,
    this.currentMood = NPCMood.neutral,
    this.preferredTime,
    required this.characterColor,
  });

  NPC copyWith({
    String? id,
    String? name,
    String? emoji,
    String? personality,
    String? nativeLocation,
    List<String>? frequentLocations,
    String? backstory,
    ConversationDifficulty? typicalDifficulty,
    int? conversationCount,
    NPCMood? currentMood,
    TimeOfDay? preferredTime,
    Color? characterColor,
  }) {
    return NPC(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      personality: personality ?? this.personality,
      nativeLocation: nativeLocation ?? this.nativeLocation,
      frequentLocations: frequentLocations ?? this.frequentLocations,
      backstory: backstory ?? this.backstory,
      typicalDifficulty: typicalDifficulty ?? this.typicalDifficulty,
      conversationCount: conversationCount ?? this.conversationCount,
      currentMood: currentMood ?? this.currentMood,
      preferredTime: preferredTime ?? this.preferredTime,
      characterColor: characterColor ?? this.characterColor,
    );
  }
}

/// Represents a single conversation turn
class ConversationTurn {
  final String id;
  final String speaker; // 'NPC' or 'PLAYER'
  final String message;
  final int? expectedCorrectness; // 0-100 score if this is a player turn
  final String? feedback; // Optional feedback from AI

  ConversationTurn({
    required this.id,
    required this.speaker,
    required this.message,
    this.expectedCorrectness,
    this.feedback,
  });

  ConversationTurn copyWith({
    String? id,
    String? speaker,
    String? message,
    int? expectedCorrectness,
    String? feedback,
  }) {
    return ConversationTurn(
      id: id ?? this.id,
      speaker: speaker ?? this.speaker,
      message: message ?? this.message,
      expectedCorrectness: expectedCorrectness ?? this.expectedCorrectness,
      feedback: feedback ?? this.feedback,
    );
  }
}

/// Represents an interactive conversation scene in a location
class InteractionScene {
  final String id;
  final String npcId;
  final String locationId;
  final String title; // e.g., "Ordering Coffee"
  final String description;
  final String initialGreeting; // How the NPC starts the conversation
  final List<ConversationTurn> baseConversation; // Template conversation
  final ConversationDifficulty difficulty;
  final int xpReward;
  final int coinReward;
  final int conversationCount; // How many times this scene has been played
  final DateTime? lastPlayedAt;
  final List<String>? keywords; // Words/topics covered in this scene
  final bool isCompleted; // Whether player has completed this scene at least once

  InteractionScene({
    required this.id,
    required this.npcId,
    required this.locationId,
    required this.title,
    required this.description,
    required this.initialGreeting,
    required this.baseConversation,
    required this.difficulty,
    required this.xpReward,
    required this.coinReward,
    this.conversationCount = 0,
    this.lastPlayedAt,
    this.keywords,
    this.isCompleted = false,
  });

  InteractionScene copyWith({
    String? id,
    String? npcId,
    String? locationId,
    String? title,
    String? description,
    String? initialGreeting,
    List<ConversationTurn>? baseConversation,
    ConversationDifficulty? difficulty,
    int? xpReward,
    int? coinReward,
    int? conversationCount,
    DateTime? lastPlayedAt,
    List<String>? keywords,
    bool? isCompleted,
  }) {
    return InteractionScene(
      id: id ?? this.id,
      npcId: npcId ?? this.npcId,
      locationId: locationId ?? this.locationId,
      title: title ?? this.title,
      description: description ?? this.description,
      initialGreeting: initialGreeting ?? this.initialGreeting,
      baseConversation: baseConversation ?? this.baseConversation,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      conversationCount: conversationCount ?? this.conversationCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      keywords: keywords ?? this.keywords,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Represents the complete English-Only Town
class TownMap {
  final String id;
  final String name;
  final List<Location> locations;
  final List<NPC> npcs;
  final List<InteractionScene> scenes;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;

  TownMap({
    required this.id,
    required this.name,
    required this.locations,
    required this.npcs,
    required this.scenes,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  TownMap copyWith({
    String? id,
    String? name,
    List<Location>? locations,
    List<NPC>? npcs,
    List<InteractionScene>? scenes,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return TownMap(
      id: id ?? this.id,
      name: name ?? this.name,
      locations: locations ?? this.locations,
      npcs: npcs ?? this.npcs,
      scenes: scenes ?? this.scenes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Get location by ID
  Location? getLocation(String locationId) {
    try {
      return locations.firstWhere((loc) => loc.id == locationId);
    } catch (e) {
      return null;
    }
  }

  /// Get NPC by ID
  NPC? getNPC(String npcId) {
    try {
      return npcs.firstWhere((npc) => npc.id == npcId);
    } catch (e) {
      return null;
    }
  }

  /// Get scenes for a specific location
  List<InteractionScene> getLocationScenes(String locationId) {
    return scenes.where((scene) => scene.locationId == locationId).toList();
  }

  /// Get scenes for a specific NPC
  List<InteractionScene> getNPCScenes(String npcId) {
    return scenes.where((scene) => scene.npcId == npcId).toList();
  }
}

/// Represents player's progress in the English-Only Town
class TownProgress {
  final String userId;
  final Set<String> visitedLocationIds;
  final Map<String, int> npcConversationCounts; // npcId -> count
  final Map<String, int> sceneCompletionCounts; // sceneId -> count
  final Set<String> unlockedAchievements;
  final int totalXpEarned;
  final int totalCoinsEarned;
  final int totalConversations;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final TimeOfDay? currentTimeOfDay;
  final WeatherType? currentWeather;

  TownProgress({
    required this.userId,
    this.visitedLocationIds = const {},
    this.npcConversationCounts = const {},
    this.sceneCompletionCounts = const {},
    this.unlockedAchievements = const {},
    this.totalXpEarned = 0,
    this.totalCoinsEarned = 0,
    this.totalConversations = 0,
    required this.createdAt,
    required this.lastPlayedAt,
    this.currentTimeOfDay = TimeOfDay.afternoon,
    this.currentWeather = WeatherType.sunny,
  });

  TownProgress copyWith({
    String? userId,
    Set<String>? visitedLocationIds,
    Map<String, int>? npcConversationCounts,
    Map<String, int>? sceneCompletionCounts,
    Set<String>? unlockedAchievements,
    int? totalXpEarned,
    int? totalCoinsEarned,
    int? totalConversations,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    TimeOfDay? currentTimeOfDay,
    WeatherType? currentWeather,
  }) {
    return TownProgress(
      userId: userId ?? this.userId,
      visitedLocationIds: visitedLocationIds ?? this.visitedLocationIds,
      npcConversationCounts: npcConversationCounts ?? this.npcConversationCounts,
      sceneCompletionCounts: sceneCompletionCounts ?? this.sceneCompletionCounts,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalConversations: totalConversations ?? this.totalConversations,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      currentTimeOfDay: currentTimeOfDay ?? this.currentTimeOfDay,
      currentWeather: currentWeather ?? this.currentWeather,
    );
  }

  /// Calculate progress percentage (0-100)
  int getProgressPercentage(int totalScenes) {
    if (totalScenes == 0) return 0;
    return ((totalConversations / (totalScenes * 2)) * 100).toInt().clamp(0, 100);
  }
}
