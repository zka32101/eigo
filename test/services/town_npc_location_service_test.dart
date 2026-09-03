import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_location_model.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/services/town_npc_location_service.dart';

void main() {
  group('TownNPCLocationService', () {
    late TownNPCLocationService service;

    setUp(() {
      service = TownNPCLocationService.getInstance();
    });

    group('initializeNPCLocations', () {
      test('should initialize NPC locations from NPC data', () {
        final testNPCs = [
          NPC(
            npcId: 'npc-1',
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
            npcId: 'npc-2',
            name: 'Bob',
            profession: 'shopkeeper',
            emoji: '👨‍💼',
            areaId: 'school',
            position: 'x:150,y:250',
            conversationPhrases: ['How can I help?'],
            learningTheme: 'Shopping',
            difficultyLevel: 2,
            vocabularyCount: 75,
            talkCount: 0,
          ),
        ];

        final townMapData =
            service.initializeNPCLocations('school', testNPCs);

        expect(townMapData.npcLocations.length, 2);
        expect(townMapData.areaId, 'school');
        expect(townMapData.npcLocations[0].name, 'Alice');
        expect(townMapData.npcLocations[1].name, 'Bob');
        expect(townMapData.spawnPoints.isNotEmpty, true);
      });

      test('should handle empty NPC list', () {
        final townMapData = service.initializeNPCLocations('school', []);

        expect(townMapData.npcLocations.isEmpty, true);
        expect(townMapData.spawnPoints.isNotEmpty, true);
      });
    });

    group('moveNPC', () {
      test('should move NPC to new coordinate', () {
        final npc = NPCLocation(
          npcId: 'npc-1',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.4),
          isMovable: true,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final newCoord = NPCCoordinate(x: 0.5, y: 0.6);
        final movedNPC = service.moveNPC(npc, newCoord);

        expect(movedNPC.coordinate.x, 0.5);
        expect(movedNPC.coordinate.y, 0.6);
        expect(movedNPC.npcId, 'npc-1');
      });

      test('should not move immovable NPC', () {
        final npc = NPCLocation(
          npcId: 'npc-1',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.4),
          isMovable: false,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final newCoord = NPCCoordinate(x: 0.5, y: 0.6);
        final result = service.moveNPC(npc, newCoord);

        expect(result.coordinate.x, 0.3);
        expect(result.coordinate.y, 0.4);
      });

      test('should clamp coordinates to valid range', () {
        final npc = NPCLocation(
          npcId: 'npc-1',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.5, y: 0.5),
          isMovable: true,
          profession: 'teacher',
          lastUpdatedAt: DateTime.now(),
        );

        final outOfBoundsCoord = NPCCoordinate(x: 1.5, y: -0.5);
        final movedNPC = service.moveNPC(npc, outOfBoundsCoord);

        expect(movedNPC.coordinate.x, 1.0);
        expect(movedNPC.coordinate.y, 0.0);
      });
    });

    group('updateNPCState', () {
      test('should update NPC state', () {
        final npc = NPCLocation(
          npcId: 'npc-1',
          name: 'Alice',
          emoji: '👩‍🏫',
          areaId: 'school',
          coordinate: NPCCoordinate(x: 0.3, y: 0.4),
          isMovable: true,
          profession: 'teacher',
          currentState: 'idle',
          lastUpdatedAt: DateTime.now(),
        );

        final updatedNPC = service.updateNPCState(npc, 'talking');

        expect(updatedNPC.currentState, 'talking');
        expect(updatedNPC.npcId, 'npc-1');
      });
    });

    group('getNearestNPC', () {
      test('should return nearest NPC within range', () {
        final npcs = [
          NPCLocation(
            npcId: 'npc-1',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.3, y: 0.3),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'npc-2',
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
        final nearest = service.getNearestNPC(npcs, playerPos, 0.15);

        expect(nearest?.npcId, 'npc-1');
      });

      test('should return null if no NPC in range', () {
        final npcs = [
          NPCLocation(
            npcId: 'npc-1',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.1, y: 0.1),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final playerPos = NPCCoordinate(x: 0.9, y: 0.9);
        final nearest = service.getNearestNPC(npcs, playerPos, 0.05);

        expect(nearest, isNull);
      });
    });

    group('getNPCsInRange', () {
      test('should return all NPCs in range sorted by distance', () {
        final npcs = [
          NPCLocation(
            npcId: 'npc-1',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.3, y: 0.3),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'npc-2',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'npc-3',
            name: 'Charlie',
            emoji: '👨‍🍳',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.8, y: 0.8),
            isMovable: true,
            profession: 'chef',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final playerPos = NPCCoordinate(x: 0.4, y: 0.4);
        final inRange = service.getNPCsInRange(npcs, playerPos, 0.25);

        expect(inRange.length, 2);
        expect(inRange[0].npcId, 'npc-1'); // Closest
        expect(inRange[1].npcId, 'npc-2');
      });

      test('should return empty list if no NPCs in range', () {
        final npcs = [
          NPCLocation(
            npcId: 'npc-1',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.1, y: 0.1),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final playerPos = NPCCoordinate(x: 0.9, y: 0.9);
        final inRange = service.getNPCsInRange(npcs, playerPos, 0.05);

        expect(inRange.isEmpty, true);
      });
    });

    group('arrangeNPCsAtSpawnPoints', () {
      test('should arrange NPCs at spawn points', () {
        final npcs = [
          NPCLocation(
            npcId: 'npc-1',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'npc-2',
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
            service.arrangeNPCsAtSpawnPoints(npcs, spawnPoints);

        expect(arranged.length, 2);
        expect(arranged[0].coordinate.x, 0.2);
        expect(arranged[0].coordinate.y, 0.2);
        expect(arranged[1].coordinate.x, 0.8);
        expect(arranged[1].coordinate.y, 0.8);
      });

      test('should handle more NPCs than spawn points', () {
        final npcs = [
          NPCLocation(
            npcId: 'npc-1',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'npc-2',
            name: 'Bob',
            emoji: '👨‍💼',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'shopkeeper',
            lastUpdatedAt: DateTime.now(),
          ),
          NPCLocation(
            npcId: 'npc-3',
            name: 'Charlie',
            emoji: '👨‍🍳',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.3, y: 0.4),
            isMovable: true,
            profession: 'chef',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final spawnPoints = [
          NPCCoordinate(x: 0.2, y: 0.2),
        ];

        final arranged =
            service.arrangeNPCsAtSpawnPoints(npcs, spawnPoints);

        expect(arranged.length, 3);
        expect(arranged[0].coordinate.x, 0.2); // First at spawn point
        expect(arranged[2].coordinate.x, 0.3); // Third keeps original position
      });
    });

    group('createInteractionEvent', () {
      test('should create NPC interaction event', () {
        final event = service.createInteractionEvent('talk', 'npc-1');

        expect(event.eventType, 'talk');
        expect(event.npcId, 'npc-1');
        expect(event.timestamp, isNotNull);
      });
    });

    group('updateTownMapNPCData', () {
      test('should update town map NPC data', () {
        final originalData = TownMapNPCData(
          mapId: 'map-1',
          areaId: 'school',
          npcLocations: [
            NPCLocation(
              npcId: 'npc-1',
              name: 'Alice',
              emoji: '👩‍🏫',
              areaId: 'school',
              coordinate: NPCCoordinate(x: 0.3, y: 0.3),
              isMovable: true,
              profession: 'teacher',
              lastUpdatedAt: DateTime.now(),
            ),
          ],
          spawnPoints: [],
          lastUpdatedAt: DateTime.now(),
        );

        final updatedNPCs = [
          NPCLocation(
            npcId: 'npc-1',
            name: 'Alice',
            emoji: '👩‍🏫',
            areaId: 'school',
            coordinate: NPCCoordinate(x: 0.5, y: 0.5),
            isMovable: true,
            profession: 'teacher',
            lastUpdatedAt: DateTime.now(),
          ),
        ];

        final updatedData =
            service.updateTownMapNPCData(originalData, updatedNPCs);

        expect(updatedData.npcLocations[0].coordinate.x, 0.5);
        expect(updatedData.npcLocations[0].coordinate.y, 0.5);
      });
    });
  });
}
