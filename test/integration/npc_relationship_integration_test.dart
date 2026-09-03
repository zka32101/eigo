import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_relationship_model.dart';
import 'package:eigo/services/npc_relationship_service.dart';

void main() {
  group('NPC Relationship Integration Tests', () {
    late NPCRelationshipService service;

    setUp(() {
      service = NPCRelationshipService.getInstance();
    });

    group('Complete Relationship Progression', () {
      test('should progress through all relationship statuses', () {
        // Initialize relationship
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        expect(relationship.getStatus(), RelationshipStatus.stranger);

        // Progress to acquaintance (10+ points)
        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        expect(relationship.getStatus(), RelationshipStatus.acquaintance);

        // Progress to friend (50+ points)
        for (int i = 0; i < 5; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        }
        expect(relationship.getStatus(), RelationshipStatus.friend);

        // Progress to good friend (75+ points)
        for (int i = 0; i < 5; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        }
        expect(relationship.getStatus(), RelationshipStatus.goodFriend);

        // Progress to best friend (90+ points)
        for (int i = 0; i < 3; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        }
        expect(relationship.getStatus(), RelationshipStatus.bestFriend);

        // Progress to soulmate (100 points)
        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        expect(relationship.getStatus(), RelationshipStatus.soulmate);
      });

      test('should track interaction count through progression', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        expect(relationship.totalInteractions, 0);

        for (int i = 0; i < 10; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 80, null);
        }

        expect(relationship.totalInteractions, 10);
        expect(relationship.affectionScore, 70); // 7 points × 10 interactions
      });

      test('should record interaction times', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        expect(relationship.lastInteractionTime, isNull);

        relationship = service.updateAffectionAfterDialogue(relationship, 80, null);
        expect(relationship.lastInteractionTime, isNotNull);

        final firstTime = relationship.lastInteractionTime!;
        relationship = service.updateAffectionAfterDialogue(relationship, 80, null);
        final secondTime = relationship.lastInteractionTime!;

        expect(secondTime.isAfter(firstTime), true);
      });
    });

    group('Dialogue Chain Progression', () {
      test('should unlock dialogue chains based on affection level', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        final chains = [
          DialogueChain(
            chainId: 'chain-1',
            chainName: 'First Meeting',
            description: 'Initial greeting',
            requiredAffectionLevel: 10,
            dialogueSequence: ['dial-1', 'dial-2', 'dial-3'],
            branchPoints: {'dial-2': ['choice-a', 'choice-b']},
            reward: DialogueChainReward(
              xpEarned: 50,
              coinsEarned: 10,
            ),
          ),
          DialogueChain(
            chainId: 'chain-2',
            chainName: 'Growing Closer',
            description: 'Deeper conversation',
            requiredAffectionLevel: 50,
            dialogueSequence: ['dial-4', 'dial-5', 'dial-6'],
            branchPoints: {},
            reward: DialogueChainReward(
              xpEarned: 100,
              coinsEarned: 50,
            ),
          ),
        ];

        // Before unlocking
        expect(relationship.unlockedDialogues.isEmpty, true);

        // Unlock first chain
        relationship = service.unlockDialoguesForAffectionLevel(relationship, chains);
        expect(relationship.unlockedDialogues.isEmpty, true); // No chains unlocked yet

        // Increase affection to 10
        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        relationship = service.unlockDialoguesForAffectionLevel(relationship, chains);
        expect(relationship.unlockedDialogues.contains('chain-1'), true);

        // Increase to 50
        for (int i = 0; i < 5; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        }
        relationship = service.unlockDialoguesForAffectionLevel(relationship, chains);
        expect(relationship.unlockedDialogues.contains('chain-2'), true);
      });

      test('should calculate dialogue chain progress', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        final chain = DialogueChain(
          chainId: 'chain-1',
          chainName: 'Test Chain',
          description: 'Test',
          requiredAffectionLevel: 0,
          dialogueSequence: ['dial-1', 'dial-2', 'dial-3', 'dial-4'],
          branchPoints: {},
          reward: DialogueChainReward(
            xpEarned: 50,
            coinsEarned: 10,
          ),
        );

        // Initially no progress
        double progress = service.getDialogueChainProgress(relationship, chain);
        expect(progress, 0.0);

        // Unlock one dialogue
        relationship = service.unlockSpecialDialogue(relationship, 'dial-1');
        progress = service.getDialogueChainProgress(relationship, chain);
        expect(progress, 0.25);

        // Unlock more dialogues
        relationship = service.unlockSpecialDialogue(relationship, 'dial-2');
        relationship = service.unlockSpecialDialogue(relationship, 'dial-3');
        progress = service.getDialogueChainProgress(relationship, chain);
        expect(progress, 0.75);

        // Complete chain
        relationship = service.unlockSpecialDialogue(relationship, 'dial-4');
        progress = service.getDialogueChainProgress(relationship, chain);
        expect(progress, 1.0);
      });

      test('should record dialogue choices', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        relationship = service.recordDialogueChoice(
          relationship,
          'dial-1',
          'choice-a',
        );

        expect(relationship.chosenDialoguePaths['dial-1'], 'choice-a');

        relationship = service.recordDialogueChoice(
          relationship,
          'dial-2',
          'choice-b',
        );

        expect(relationship.chosenDialoguePaths['dial-1'], 'choice-a');
        expect(relationship.chosenDialoguePaths['dial-2'], 'choice-b');
      });
    });

    group('Milestone Achievement', () {
      test('should detect milestone achievements', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        final milestones = [
          RelationshipMilestone(
            milestoneId: 'milestone-1',
            name: 'First Contact',
            description: 'First interaction',
            requiredAffectionScore: 10,
            reward: RelationshipMilestoneReward(
              xp: 50,
              coins: 10,
            ),
          ),
          RelationshipMilestone(
            milestoneId: 'milestone-2',
            name: 'Good Friend',
            description: 'Reached good friend status',
            requiredAffectionScore: 75,
            reward: RelationshipMilestoneReward(
              xp: 200,
              coins: 100,
            ),
          ),
        ];

        // No milestones achieved initially
        var achieved = service.checkMilestones(relationship, milestones);
        expect(achieved.isEmpty, true);

        // Reach first milestone
        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        achieved = service.checkMilestones(relationship, milestones);
        expect(achieved.length, 1);
        expect(achieved[0].milestoneId, 'milestone-1');
        expect(achieved[0].isAchieved(), true);

        // Reach second milestone
        for (int i = 0; i < 8; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        }
        achieved = service.checkMilestones(relationship, milestones);
        expect(achieved.length, 1); // Only new milestones
        expect(achieved[0].milestoneId, 'milestone-2');
      });

      test('should not re-achieve already achieved milestones', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        final milestone = RelationshipMilestone(
          milestoneId: 'milestone-1',
          name: 'Test',
          description: 'Test milestone',
          requiredAffectionScore: 10,
          reward: RelationshipMilestoneReward(
            xp: 50,
            coins: 10,
          ),
        );

        // First check
        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        var achieved = service.checkMilestones(relationship, [milestone]);
        expect(achieved.length, 1);

        // Second check shouldn't re-achieve
        var milestone2 = milestone.copyWith(
          achievedAt: achieved[0].achievedAt,
        );
        achieved = service.checkMilestones(relationship, [milestone2]);
        expect(achieved.isEmpty, true);
      });
    });

    group('Bidirectional Affection', () {
      test('should track player affection separately', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        expect(relationship.playerAffectionLevel, 0);

        relationship = service.updatePlayerAffection(relationship, 25, 'Gave a gift');
        expect(relationship.playerAffectionLevel, 25);

        relationship = service.updatePlayerAffection(relationship, 50, 'Helped in quest');
        expect(relationship.playerAffectionLevel, 75);

        // Clamped at 100
        relationship = service.updatePlayerAffection(relationship, 50, 'More help');
        expect(relationship.playerAffectionLevel, 100);
      });

      test('should track NPC affection separately', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        expect(relationship.npcAffectionLevel, 0);

        relationship = service.updateNPCAffection(relationship, 30, 'Appreciated help');
        expect(relationship.npcAffectionLevel, 30);

        relationship = service.updateNPCAffection(relationship, 40, 'Enjoyed conversation');
        expect(relationship.npcAffectionLevel, 70);

        // Can decrease
        relationship = service.updateNPCAffection(relationship, -20, 'Disagreement');
        expect(relationship.npcAffectionLevel, 50);

        // Clamped at 0
        relationship = service.updateNPCAffection(relationship, -100, 'Major conflict');
        expect(relationship.npcAffectionLevel, 0);
      });

      test('should allow asymmetric relationships', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        // Player loves NPC, but NPC doesn't reciprocate
        relationship = service.updatePlayerAffection(relationship, 80, 'Admiring from afar');
        relationship = service.updateNPCAffection(relationship, 20, 'Aware of player');

        expect(relationship.playerAffectionLevel, 80);
        expect(relationship.npcAffectionLevel, 20);
      });
    });

    group('Affection Events', () {
      test('should track affection events', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        expect(relationship.affectionEvents.isEmpty, true);

        relationship =
            service.updateAffectionAfterDialogue(relationship, 90, 'Great dialogue');
        expect(relationship.affectionEvents.isNotEmpty, true);
        expect(relationship.affectionEvents.contains('Great dialogue'), true);
      });

      test('should add custom affection events', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        relationship = service.unlockSpecialDialogue(relationship, 'special-1');
        expect(relationship.affectionEvents.contains('Special dialogue unlocked: special-1'),
            true);

        relationship = service.updateNPCAffection(relationship, 10, 'Gave compliment');
        expect(relationship.affectionEvents.contains('NPC affection: Gave compliment'), true);
      });
    });

    group('Relationship Summary', () {
      test('should generate accurate relationship summary', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        // Add some interactions
        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        relationship = service.updateAffectionAfterDialogue(relationship, 80, null);
        relationship = service.unlockSpecialDialogue(relationship, 'dial-1');
        relationship = service.unlockSpecialDialogue(relationship, 'dial-2');

        final summary = service.generateRelationshipSummary(relationship);

        expect(summary.npcId, 'npc-1');
        expect(summary.affectionScore, relationship.affectionScore);
        expect(summary.totalInteractions, 2);
        expect(summary.unlockedDialoguesCount, 2);
      });

      test('should calculate progress percentage correctly', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        var summary = service.generateRelationshipSummary(relationship);
        expect(summary.getProgressPercentage(), 0.0);

        for (int i = 0; i < 5; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        }

        summary = service.generateRelationshipSummary(relationship);
        expect(summary.getProgressPercentage(), 0.5); // 50 points / 100
      });

      test('should calculate points to next status', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        var summary = service.generateRelationshipSummary(relationship);

        // At 0, next threshold is 10
        expect(summary.getPointsToNextStatus(), 10);

        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        summary = service.generateRelationshipSummary(relationship);
        expect(summary.getPointsToNextStatus(), 14); // 10 + 10 - 10 = 10, next is 25
      });
    });

    group('Multiple NPCs', () {
      test('should manage relationships with multiple NPCs', () {
        var rel1 = service.initializeRelationship('npc-1', 'user-1');
        var rel2 = service.initializeRelationship('npc-2', 'user-1');
        var rel3 = service.initializeRelationship('npc-3', 'user-1');

        // Build different relationship levels
        for (int i = 0; i < 3; i++) {
          rel1 = service.updateAffectionAfterDialogue(rel1, 90, null);
        }
        for (int i = 0; i < 7; i++) {
          rel2 = service.updateAffectionAfterDialogue(rel2, 90, null);
        }
        for (int i = 0; i < 1; i++) {
          rel3 = service.updateAffectionAfterDialogue(rel3, 90, null);
        }

        final sorted = service.rankRelationshipsByAffection([rel1, rel2, rel3]);

        expect(sorted[0].npcId, 'npc-2'); // 70 points
        expect(sorted[1].npcId, 'npc-1'); // 30 points
        expect(sorted[2].npcId, 'npc-3'); // 10 points
      });
    });

    group('Relationship Reset', () {
      test('should reset relationship completely', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');

        // Build up relationship
        for (int i = 0; i < 10; i++) {
          relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        }
        relationship = service.unlockSpecialDialogue(relationship, 'dial-1');

        expect(relationship.affectionScore, greaterThan(0));
        expect(relationship.unlockedDialogues.isNotEmpty, true);

        // Reset
        relationship = service.resetRelationship(relationship);

        expect(relationship.affectionScore, 0);
        expect(relationship.totalInteractions, 0);
        expect(relationship.unlockedDialogues.isEmpty, true);
        expect(relationship.npcId, 'npc-1');
        expect(relationship.userId, 'user-1');
      });
    });

    group('Dialogue Score to Affection Mapping', () {
      test('should award 10 points for score >= 90', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        relationship = service.updateAffectionAfterDialogue(relationship, 90, null);
        expect(relationship.affectionScore, 10);

        relationship = service.updateAffectionAfterDialogue(relationship, 100, null);
        expect(relationship.affectionScore, 20);
      });

      test('should award 7 points for score >= 80', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        relationship = service.updateAffectionAfterDialogue(relationship, 80, null);
        expect(relationship.affectionScore, 7);

        relationship = service.updateAffectionAfterDialogue(relationship, 89, null);
        expect(relationship.affectionScore, 14);
      });

      test('should award 5 points for score >= 70', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        relationship = service.updateAffectionAfterDialogue(relationship, 70, null);
        expect(relationship.affectionScore, 5);

        relationship = service.updateAffectionAfterDialogue(relationship, 79, null);
        expect(relationship.affectionScore, 10);
      });

      test('should award 3 points for score >= 60', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        relationship = service.updateAffectionAfterDialogue(relationship, 60, null);
        expect(relationship.affectionScore, 3);

        relationship = service.updateAffectionAfterDialogue(relationship, 69, null);
        expect(relationship.affectionScore, 6);
      });

      test('should award 1 point for score >= 50', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        relationship = service.updateAffectionAfterDialogue(relationship, 50, null);
        expect(relationship.affectionScore, 1);

        relationship = service.updateAffectionAfterDialogue(relationship, 59, null);
        expect(relationship.affectionScore, 2);
      });

      test('should award 0 points for score < 50', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        relationship = service.updateAffectionAfterDialogue(relationship, 49, null);
        expect(relationship.affectionScore, 0);

        relationship = service.updateAffectionAfterDialogue(relationship, 0, null);
        expect(relationship.affectionScore, 0);
      });
    });

    group('Relationship Events', () {
      test('should create relationship events', () {
        final event = service.createRelationshipEvent(
          'affection_increase',
          'npc-1',
          'Dialogue completed',
          affectionChange: 10,
          eventData: {'dialogueId': 'dial-1', 'score': 90},
        );

        expect(event.eventType, 'affection_increase');
        expect(event.npcId, 'npc-1');
        expect(event.description, 'Dialogue completed');
        expect(event.affectionChange, 10);
        expect(event.timestamp, isNotNull);
        expect(event.eventData['dialogueId'], 'dial-1');
      });
    });

    group('Special Events', () {
      test('should track special event achievements', () {
        var relationship = service.initializeRelationship('npc-1', 'user-1');
        expect(relationship.specialEventAchievements.isEmpty, true);

        // Simulate achieving special event
        relationship = relationship.copyWith(
          specialEventAchievements: [...relationship.specialEventAchievements, 'event-1'],
        );
        expect(relationship.specialEventAchievements.contains('event-1'), true);

        // Add another
        relationship = relationship.copyWith(
          specialEventAchievements: [...relationship.specialEventAchievements, 'event-2'],
        );
        expect(relationship.specialEventAchievements.length, 2);
      });
    });
  });
}
