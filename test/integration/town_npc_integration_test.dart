import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_location_model.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/services/town_npc_location_service.dart';
import 'package:eigo/services/town_npc_dialogue_integration_service.dart';

void main() {
  group('Town NPC Integration Tests', () {
    late TownNPCLocationService locationService;
    late TownNPCDialogueIntegrationService integrationService;

    setUp(() {
      locationService = TownNPCLocationService.getInstance();
      integrationService =
          TownNPCDialogueIntegrationService.getInstance();
    });

    group('NPC Location Management', () {
      test('should initialize NPC locations in an area', () {
        final testNPCs = [
          NPC(
            npcId: 'alice',
            name: 'Alice',
            profession: 'teacher',
            emoji: '👩‍🏫',
            areaId: 'school',
            position: 'x:100,y:200',
            conversationPhrases: ['Hello'],
            learningTheme: 'Education',
            difficultyLevel: 1,
            vocabularyCount: 50,
            talkCount: 0,
          ),
          NPC(
            npcId: 'bob',
            name: 'Bob',
            profession: 'shopkeeper',
            emoji: '👨‍💼',
            areaId: 'school',
            position: 'x:250,y:300',
            conversationPhrases: ['How can I help?'],
            learningTheme: 'Shopping',
            difficultyLevel: 2,
            vocabularyCount: 75,
            talkCount: 0,
          ),
        ];

        final townMapData =
            locationService.initializeNPCLocations('school', testNPCs);

        expect(townMapData.npcLocations.length, 2);
        expect(townMapData.areaId, 'school');
        expect(townMapData.npcLocations[0].npcId, 'alice');
        expect(townMapData.npcLocations[1].npcId, 'bob');
      });

      test('should track NPC positions on map', () {
        final npc = NPCLocation(
          npcId: 'alice',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.4),
          isMovable: true,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final newCoord = NPCCoordinate(x: 0.5, y: 0.6);
        final movedNPC = locationService.moveNPC(npc, newCoord);

        expect(movedNPC.coordinate.x, 0.5);
        expect(movedNPC.coordinate.y, 0.6);
      });

      test('should identify NPCs in proximity to player', () {
        final npcs = [
          NPCLocation(
            npcId: 'alice',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.3, y: 0.3),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'bob',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.7, y: 0.7),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final playerPos = NPCCoordinate(x: 0.35, y: 0.35);
        final nearby = locationService.getNPCsInRange(npcs, playerPos, 0.25);

        expect(nearby.length, 1);
        expect(nearby[0].npcId, 'alice');
      });

      test('should arrange NPCs at spawn points', () {
        final npcs = [
          NPCLocation(
            npcId: 'alice',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'bob',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final spawnPoints = [
          NPCCoordinate(x: 0.2, y: 0.2),
          NPCCoordinate(x: 0.8, y: 0.8),
        ];

        final arranged =
            locationService.arrangeNPCsAtSpawnPoints(npcs, spawnPoints);

        expect(arranged.length, 2);
        expect(arranged[0].coordinate.x, 0.2);
        expect(arranged[1].coordinate.x, 0.8);
      });
    });

    group('Player Interaction with NPCs', () {
      test('should detect when player approaches NPC', () {
        final npc = NPCLocation(
          npcId: 'alice',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.3),
          isMovable: true,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final playerApproaching = NPCCoordinate(x: 0.32, y: 0.32);
        final distance = _calculateDistance(playerApproaching, npc.coordinate);

        expect(distance <= 0.1, true);
      });

      test('should find nearest NPC to player', () {
        final npcs = [
          NPCLocation(
            npcId: 'alice',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.2, y: 0.2),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'bob',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.8, y: 0.8),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final playerPos = NPCCoordinate(x: 0.3, y: 0.3);
        final nearest = locationService.getNearestNPC(npcs, playerPos, 0.3);

        expect(nearest?.npcId, 'alice');
      });

      test('should update NPC state during interaction', () {
        final npc = NPCLocation(
          npcId: 'alice',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.3),
          isMovable: true,
          profession: 'teacher',
          currentState: 'idle',
          lastUpdatedAt: DateTime.now(),
        );

        final talkingNPC = locationService.updateNPCState(npc, 'talking');
        expect(talkingNPC.currentState, 'talking');

        final idleNPC = locationService.updateNPCState(talkingNPC, 'idle');
        expect(idleNPC.currentState, 'idle');
      });
    });

    group('NPC Dialogue Integration', () {
      test('should create dialogue context for NPC interaction', () {
        final npcLocation = NPCLocation(
          npcId: 'alice',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.3),
          isMovable: true,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final npcExtended = NPCExtended(
          npcId: 'alice',
          personality: NPCPersonality(
            archetype: 'friendly',
            traits: ['helpful'],
            interests: ['education'],
            preferredTopics: ['school'],
            avoidedTopics: [],
            speakingStyle: ['formal'],
            biography: 'Alice is a teacher',
          ),
          currentMoodState: 'happy',
          availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
          lastInteractionTime: DateTime.now(),
          learningProgress: 0.5,
        );

        final context = integrationService.createDialogueContext(
          npcLocation,
          npcExtended,
          'Hello Alice',
        );

        expect(context.npcLocation.npcId, 'alice');
        expect(context.npcExtended.npcId, 'alice');
        expect(context.initialUserInput, 'Hello Alice');
        expect(context.interactionType, 'map_interaction');
      });

      test('should prepare NPC for dialogue interaction', () {
        final npc = NPCLocation(
          npcId: 'alice',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.3),
          isMovable: true,
          profession: 'teacher',
          currentState: 'idle',
          lastUpdatedAt: DateTime.now(),
        );

        final readyNPC = integrationService.prepareNPCForDialogue(npc);

        expect(readyNPC.currentState, 'talking');
        expect(readyNPC.npcId, 'alice');
      });

      test('should update NPC state after dialogue', () {
        final npc = NPCLocation(
          npcId: 'alice',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.3),
          isMovable: true,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final result = DialogueInteractionResult(
          score: 85,
          xpEarned: 100,
          coinsEarned: 50,
          feedback: 'Great job!',
          qualityBreakdown: {'grammar': 0.9, 'fluency': 0.8},
          userResponse: 'Hello Alice',
          npcResponse: 'Hello there!',
          success: true,
        );

        final updatedNPC = integrationService.updateNPCAfterDialogue(npc, result);

        expect(updatedNPC.currentState, 'happy');
      });
    });

    group('NPC Selection and Filtering', () {
      test('should select NPC based on player preference', () {
        final npcs = [
          NPCLocation(
            npcId: 'alice',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.3, y: 0.3),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'bob',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final selected =
            integrationService.selectBestNPCForInteraction(npcs, 'Alice');

        expect(selected?.npcId, 'alice');
      });

      test('should return first NPC if preference not found', () {
        final npcs = [
          NPCLocation(
            npcId: 'alice',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.3, y: 0.3),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'bob',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final selected =
            integrationService.selectBestNPCForInteraction(npcs, 'Charlie');

        expect(selected?.npcId, 'alice');
      });

      test('should return null for empty NPC list', () {
        final selected = integrationService
            .selectBestNPCForInteraction([], 'Alice');

        expect(selected, isNull);
      });
    });

    group('Interaction History Recording', () {
      test('should record NPC interaction history', () {
        final npc = NPCLocation(
          npcId: 'alice',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.3),
          isMovable: true,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final result = DialogueInteractionResult(
          score: 85,
          xpEarned: 100,
          coinsEarned: 50,
          feedback: 'Great job!',
          qualityBreakdown: {'grammar': 0.9},
          userResponse: 'Hello',
          npcResponse: 'Hi there',
          success: true,
        );

        final history =
            integrationService.recordInteraction(npc, result);

        expect(history.npcId, 'alice');
        expect(history.npcName, 'Alice');
        expect(history.score, 85);
        expect(history.xpEarned, 100);
        expect(history.coinsEarned, 50);
        expect(history.interactionType, 'dialogue');
      });
    });

    group('Multiple NPC Scenarios', () {
      test('should handle multiple NPCs in same area', () {
        final npcs = [
          NPC(
            npcId: 'alice',
            name: 'Alice',
            profession: 'teacher',
            emoji: '👩‍🏫',
            areaId: 'school',
            position: 'x:100,y:150',
            conversationPhrases: ['Hello'],
            learningTheme: 'Education',
            difficultyLevel: 1,
            vocabularyCount: 50,
            talkCount: 0,
          ),
          NPC(
            npcId: 'bob',
            name: 'Bob',
            profession: 'shopkeeper',
            emoji: '👨‍💼',
            areaId: 'school',
            position: 'x:250,y:300',
            conversationPhrases: ['How can I help?'],
            learningTheme: 'Shopping',
            difficultyLevel: 2,
            vocabularyCount: 75,
            talkCount: 0,
          ),
          NPC(
            npcId: 'charlie',
            name: 'Charlie',
            profession: 'chef',
            emoji: '👨‍🍳',
            areaId: 'school',
            position: 'x:400,y:250',
            conversationPhrases: ['Welcome to my restaurant'],
            learningTheme: 'Food',
            difficultyLevel: 2,
            vocabularyCount: 60,
            talkCount: 0,
          ),
        ];

        final townMapData =
            locationService.initializeNPCLocations('school', npcs);

        expect(townMapData.npcLocations.length, 3);

        // Check all NPCs are present
        final npcIds = townMapData.npcLocations.map((n) => n.npcId).toList();
        expect(npcIds.contains('alice'), true);
        expect(npcIds.contains('bob'), true);
        expect(npcIds.contains('charlie'), true);
      });

      test('should handle NPC proximity groups', () {
        final npcs = [
          NPCLocation(
            npcId: 'alice',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.2, y: 0.2),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'bob',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.22, y: 0.22),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'charlie',
            name: 'Charlie',
            emoji: '👨‍🍳',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.8, y: 0.8),
            isMovable: true,
            profession: 'chef',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final playerPos = NPCCoordinate(x: 0.3, y: 0.3);
        final nearby = locationService.getNPCsInRange(npcs, playerPos, 0.15);

        expect(nearby.length, 2); // Alice and Bob should be in range
        expect(nearby[0].npcId, 'alice'); // Closest first
        expect(nearby[1].npcId, 'bob');
      });
    });
  });
}

/// 2つの座標間の距離を計算
double _calculateDistance(NPCCoordinate a, NPCCoordinate b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return (dx * dx + dy * dy).toDouble().sqrt();
}
