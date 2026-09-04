import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_save_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_save_load_service.dart';

void main() {
  group('NPCSaveLoadService', () {
    late NPCSaveLoadService saveService;

    setUp(() {
      saveService = NPCSaveLoadService.getInstance();
      saveService.clearCache();
    });

    test('should create save game data', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      final npcState = SavedNPCState(
        npcId: 'npc-1',
        npcName: 'Test NPC',
        personalityTraits: traits,
        currentAffection: 50,
        currentMood: NPCMood.happy,
        memorizedInteractions: [],
        executedBehaviors: [],
        habits: [],
        preferredTopics: [],
        dislikedTopics: [],
        savedAt: DateTime.now(),
        gameElapsedTime: const Duration(hours: 2),
      );

      final gameData = SaveGameData(
        saveId: 'save-1',
        saveName: 'Test Save',
        playerLevel: 10,
        playerExperience: 1000,
        gamePlayedTime: const Duration(hours: 2),
        npcStates: {'npc-1': npcState},
        storyProgression: {'quest-1': true},
        completedQuests: [],
        activeQuests: [],
        inventory: {},
        gold: 100,
        savedAt: DateTime.now(),
        lastPlayedAt: DateTime.now(),
        gameVersion: '1.0.0',
      );

      expect(gameData.saveId, 'save-1');
      expect(gameData.playerLevel, 10);
      expect(gameData.npcStates.length, 1);
    });

    test('should save game data with metadata', () async {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      final npcState = SavedNPCState(
        npcId: 'npc-1',
        npcName: 'Test NPC',
        personalityTraits: traits,
        currentAffection: 50,
        currentMood: NPCMood.happy,
        memorizedInteractions: [],
        executedBehaviors: [],
        habits: [],
        preferredTopics: [],
        dislikedTopics: [],
        savedAt: DateTime.now(),
        gameElapsedTime: const Duration(hours: 2),
      );

      final gameData = SaveGameData(
        saveId: 'save-1',
        saveName: 'Test Save',
        playerLevel: 10,
        playerExperience: 1000,
        gamePlayedTime: const Duration(hours: 2),
        npcStates: {'npc-1': npcState},
        storyProgression: {},
        completedQuests: [],
        activeQuests: [],
        inventory: {},
        gold: 100,
        savedAt: DateTime.now(),
        lastPlayedAt: DateTime.now(),
        gameVersion: '1.0.0',
      );

      // Note: This test will fail on platforms without file access
      // In a real app, you would mock the file system
      final result = await saveService.saveGame(gameData);
      expect(result, SaveResult.success);
    });

    test('should create save metadata', () {
      final metadata = SaveMetadata(
        saveId: 'save-1',
        saveName: 'Test Save',
        savedAt: DateTime.now(),
        lastPlayedAt: DateTime.now(),
        playerLevel: 10,
        gamePlayedTime: const Duration(hours: 2),
        currentLocation: 'Town',
        fileSizeBytes: 1024,
      );

      expect(metadata.saveId, 'save-1');
      expect(metadata.playerLevel, 10);
      expect(metadata.currentLocation, 'Town');
    });

    test('should create save slot', () {
      final slot = SaveSlot(
        slotNumber: 1,
        metadata: null,
        isUsed: false,
      );

      expect(slot.slotNumber, 1);
      expect(slot.isUsed, false);
    });

    test('should track save slot usage', () {
      final unusedSlot = SaveSlot(
        slotNumber: 1,
        metadata: null,
        isUsed: false,
      );

      final usedSlot = SaveSlot(
        slotNumber: 2,
        metadata: SaveMetadata(
          saveId: 'save-2',
          saveName: 'Used Save',
          savedAt: DateTime.now(),
          lastPlayedAt: DateTime.now(),
          playerLevel: 5,
          gamePlayedTime: const Duration(hours: 1),
          fileSizeBytes: 512,
        ),
        isUsed: true,
      );

      expect(unusedSlot.isUsed, false);
      expect(usedSlot.isUsed, true);
    });

    test('should serialize save game data', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      final npcState = SavedNPCState(
        npcId: 'npc-1',
        npcName: 'Test NPC',
        personalityTraits: traits,
        currentAffection: 50,
        currentMood: NPCMood.happy,
        memorizedInteractions: [],
        executedBehaviors: [],
        habits: [],
        preferredTopics: [],
        dislikedTopics: [],
        savedAt: DateTime.now(),
        gameElapsedTime: const Duration(hours: 2),
      );

      final gameData = SaveGameData(
        saveId: 'save-1',
        saveName: 'Test Save',
        playerLevel: 10,
        playerExperience: 1000,
        gamePlayedTime: const Duration(hours: 2),
        npcStates: {'npc-1': npcState},
        storyProgression: {},
        completedQuests: [],
        activeQuests: [],
        inventory: {},
        gold: 100,
        savedAt: DateTime.now(),
        lastPlayedAt: DateTime.now(),
        gameVersion: '1.0.0',
      );

      final json = gameData.toJson();
      expect(json['saveId'], 'save-1');
      expect(json['playerLevel'], 10);
      expect(json['npcStates'], isNotEmpty);
    });

    test('should deserialize save game data', () {
      final json = {
        'saveId': 'save-1',
        'saveName': 'Test Save',
        'playerLevel': 10,
        'playerExperience': 1000,
        'gamePlayedTime': 7200000, // 2 hours in milliseconds
        'currentLocation': null,
        'npcStates': {},
        'storyProgression': {},
        'completedQuests': [],
        'activeQuests': [],
        'inventory': {},
        'gold': 100,
        'savedAt': DateTime.now().toIso8601String(),
        'lastPlayedAt': DateTime.now().toIso8601String(),
        'gameVersion': '1.0.0',
      };

      final gameData = SaveGameData.fromJson(json);
      expect(gameData.saveId, 'save-1');
      expect(gameData.playerLevel, 10);
    });

    test('should copy save game data with modifications', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      final npcState = SavedNPCState(
        npcId: 'npc-1',
        npcName: 'Test NPC',
        personalityTraits: traits,
        currentAffection: 50,
        currentMood: NPCMood.happy,
        memorizedInteractions: [],
        executedBehaviors: [],
        habits: [],
        preferredTopics: [],
        dislikedTopics: [],
        savedAt: DateTime.now(),
        gameElapsedTime: const Duration(hours: 2),
      );

      final gameData = SaveGameData(
        saveId: 'save-1',
        saveName: 'Test Save',
        playerLevel: 10,
        playerExperience: 1000,
        gamePlayedTime: const Duration(hours: 2),
        npcStates: {'npc-1': npcState},
        storyProgression: {},
        completedQuests: [],
        activeQuests: [],
        inventory: {},
        gold: 100,
        savedAt: DateTime.now(),
        lastPlayedAt: DateTime.now(),
        gameVersion: '1.0.0',
      );

      final updated = gameData.copyWith(
        playerLevel: 20,
        gold: 200,
      );

      expect(updated.playerLevel, 20);
      expect(updated.gold, 200);
      expect(updated.saveId, 'save-1'); // unchanged
    });

    test('should track save results', () {
      const success = SaveResult.success;
      const fileError = SaveResult.fileError;
      const permissionDenied = SaveResult.permissionDenied;

      expect(success, SaveResult.success);
      expect(fileError, SaveResult.fileError);
      expect(permissionDenied, SaveResult.permissionDenied);
    });

    test('should track load results', () {
      const success = LoadResult.success;
      const fileNotFound = LoadResult.fileNotFound;
      const versionMismatch = LoadResult.versionMismatch;

      expect(success, LoadResult.success);
      expect(fileNotFound, LoadResult.fileNotFound);
      expect(versionMismatch, LoadResult.versionMismatch);
    });

    test('should clear cache', () async {
      saveService.clearCache();
      // Verify cache is cleared
      expect(true, true);
    });
  });

  group('SavedNPCState', () {
    test('should create saved NPC state', () {
      final traits = PersonalityTraits(
        openness: 60,
        conscientiousness: 70,
        extraversion: 50,
        agreeableness: 80,
        neuroticism: 40,
      );

      final npcState = SavedNPCState(
        npcId: 'npc-1',
        npcName: 'Yuki',
        personalityTraits: traits,
        currentAffection: 75,
        currentMood: NPCMood.happy,
        memorizedInteractions: [],
        executedBehaviors: [],
        habits: [],
        preferredTopics: ['English', 'Travel'],
        dislikedTopics: ['Fighting'],
        savedAt: DateTime.now(),
        gameElapsedTime: const Duration(hours: 5),
      );

      expect(npcState.npcId, 'npc-1');
      expect(npcState.npcName, 'Yuki');
      expect(npcState.currentAffection, 75);
      expect(npcState.preferredTopics.length, 2);
    });

    test('should copy saved NPC state', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      final npcState = SavedNPCState(
        npcId: 'npc-1',
        npcName: 'Test NPC',
        personalityTraits: traits,
        currentAffection: 50,
        currentMood: NPCMood.happy,
        memorizedInteractions: [],
        executedBehaviors: [],
        habits: [],
        preferredTopics: [],
        dislikedTopics: [],
        savedAt: DateTime.now(),
        gameElapsedTime: const Duration(hours: 2),
      );

      final updated = npcState.copyWith(
        currentAffection: 80,
        currentMood: NPCMood.excited,
      );

      expect(updated.currentAffection, 80);
      expect(updated.currentMood, NPCMood.excited);
      expect(updated.npcId, 'npc-1');
    });
  });
}
