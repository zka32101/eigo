import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_relationship_model.dart';
import 'package:eigo/services/npc_relationship_service.dart';

void main() {
  group('NPCRelationshipService', () {
    late NPCRelationshipService service;

    setUp(() {
      service = NPCRelationshipService.getInstance();
    });

    group('initializeRelationship', () {
      test('should create new relationship with default values', () {
        final rel = service.initializeRelationship('alice', 'user123');

        expect(rel.npcId, 'alice');
        expect(rel.userId, 'user123');
        expect(rel.affectionScore, 0);
        expect(rel.totalInteractions, 0);
        expect(rel.affectionEvents.isEmpty, true);
      });
    });

    group('updateAffectionAfterDialogue', () {
      test('should increase affection based on score', () {
        final rel = service.initializeRelationship('alice', 'user123');

        final updated = service.updateAffectionAfterDialogue(rel, 90, null);

        expect(updated.affectionScore, greaterThan(rel.affectionScore));
        expect(updated.totalInteractions, 1);
      });

      test('should give more affection for higher scores', () {
        final rel = service.initializeRelationship('alice', 'user123');

        final high = service.updateAffectionAfterDialogue(rel, 95, null);
        final low = service.updateAffectionAfterDialogue(rel, 60, null);

        expect(high.affectionScore, greaterThan(low.affectionScore));
      });

      test('should not increase affection for low scores', () {
        final rel = service.initializeRelationship('alice', 'user123');

        final updated = service.updateAffectionAfterDialogue(rel, 40, null);

        expect(updated.affectionScore, 0);
      });
    });

    group('getRelationshipStatus', () {
      test('should return stranger for new relationship', () {
        final rel = service.initializeRelationship('alice', 'user123');
        expect(service.getRelationshipStatus(rel), RelationshipStatus.stranger);
      });

      test('should return correct status based on affection score', () {
        var rel = service.initializeRelationship('alice', 'user123');

        rel.increaseAffection(25);
        expect(service.getRelationshipStatus(rel),
            RelationshipStatus.acquaintance);

        rel.increaseAffection(30);
        expect(service.getRelationshipStatus(rel), RelationshipStatus.friend);
      });
    });

    group('unlockDialoguesForAffectionLevel', () {
      test('should unlock dialogues at appropriate affection level', () {
        var rel = service.initializeRelationship('alice', 'user123');

        final chains = [
          DialogueChain(
            chainId: 'chain1',
            chainName: 'First Meeting',
            description: 'First conversation',
            requiredAffectionLevel: 0,
            dialogueSequence: ['d1', 'd2'],
            branchPoints: {},
            reward: DialogueChainReward(xpEarned: 100, coinsEarned: 50),
          ),
          DialogueChain(
            chainId: 'chain2',
            chainName: 'Getting Closer',
            description: 'Closer relationship',
            requiredAffectionLevel: 30,
            dialogueSequence: ['d3', 'd4'],
            branchPoints: {},
            reward: DialogueChainReward(xpEarned: 200, coinsEarned: 100),
          ),
        ];

        rel = service.unlockDialoguesForAffectionLevel(rel, chains);
        expect(rel.unlockedDialogues.contains('chain1'), true);

        rel.increaseAffection(35);
        rel = service.unlockDialoguesForAffectionLevel(rel, chains);
        expect(rel.unlockedDialogues.contains('chain2'), true);
      });
    });

    group('checkMilestones', () {
      test('should detect achieved milestones', () {
        var rel = service.initializeRelationship('alice', 'user123');

        final milestones = [
          RelationshipMilestone(
            milestoneId: 'm1',
            name: 'First Friend',
            description: 'Reach friend status',
            requiredAffectionScore: 25,
            reward:
                RelationshipMilestoneReward(xp: 500, coins: 200, badge: '🌟'),
          ),
          RelationshipMilestone(
            milestoneId: 'm2',
            name: 'Best Friend',
            description: 'Reach best friend status',
            requiredAffectionScore: 75,
            reward:
                RelationshipMilestoneReward(xp: 1000, coins: 500, badge: '💎'),
          ),
        ];

        rel.increaseAffection(30);
        var achieved = service.checkMilestones(rel, milestones);
        expect(achieved.length, 1);
        expect(achieved.first.milestoneId, 'm1');

        rel.increaseAffection(50);
        achieved = service.checkMilestones(rel, milestones);
        expect(achieved.length, greaterThanOrEqualTo(1));
      });
    });

    group('unlockSpecialDialogue', () {
      test('should unlock special dialogue', () {
        var rel = service.initializeRelationship('alice', 'user123');

        rel = service.unlockSpecialDialogue(rel, 'special_dlg_1');

        expect(rel.unlockedDialogues.contains('special_dlg_1'), true);
        expect(rel.affectionEvents.isNotEmpty, true);
      });
    });

    group('recordDialogueChoice', () {
      test('should record player choice', () {
        var rel = service.initializeRelationship('alice', 'user123');

        rel = service.recordDialogueChoice(rel, 'dlg1', 'path_honest');

        expect(rel.chosenDialoguePaths['dlg1'], 'path_honest');
      });
    });

    group('updateAffection', () {
      test('should update NPC affection', () {
        var rel = service.initializeRelationship('alice', 'user123');

        rel = service.updateNPCAffection(rel, 20, 'Player was kind');

        expect(rel.npcAffectionLevel, 20);
      });

      test('should update player affection', () {
        var rel = service.initializeRelationship('alice', 'user123');

        rel = service.updatePlayerAffection(rel, 30, 'NPC helped player');

        expect(rel.playerAffectionLevel, 30);
      });
    });

    group('generateRelationshipSummary', () {
      test('should generate correct summary', () {
        var rel = service.initializeRelationship('alice', 'user123');
        rel.increaseAffection(50);
        rel.totalInteractions = 10;
        rel.unlockedDialogues.add('dlg1');

        final summary = service.generateRelationshipSummary(rel);

        expect(summary.npcId, 'alice');
        expect(summary.affectionScore, 50);
        expect(summary.totalInteractions, 10);
        expect(summary.unlockedDialoguesCount, 1);
      });
    });

    group('rankRelationshipsByAffection', () {
      test('should sort by affection score descending', () {
        var rel1 = service.initializeRelationship('alice', 'user123');
        var rel2 = service.initializeRelationship('bob', 'user123');
        var rel3 = service.initializeRelationship('charlie', 'user123');

        rel1.increaseAffection(50);
        rel2.increaseAffection(80);
        rel3.increaseAffection(30);

        final ranked =
            service.rankRelationshipsByAffection([rel1, rel2, rel3]);

        expect(ranked.first.npcId, 'bob');
        expect(ranked.last.npcId, 'charlie');
      });
    });

    group('resetRelationship', () {
      test('should reset relationship to initial state', () {
        var rel = service.initializeRelationship('alice', 'user123');
        rel.increaseAffection(50);
        rel.totalInteractions = 10;

        final reset = service.resetRelationship(rel);

        expect(reset.affectionScore, 0);
        expect(reset.totalInteractions, 0);
        expect(reset.npcId, 'alice');
      });
    });
  });

  group('RelationshipStatus', () {
    test('fromAffectionScore should return correct status', () {
      expect(RelationshipStatus.fromAffectionScore(5),
          RelationshipStatus.stranger);
      expect(RelationshipStatus.fromAffectionScore(20),
          RelationshipStatus.acquaintance);
      expect(RelationshipStatus.fromAffectionScore(40), RelationshipStatus.friend);
      expect(
          RelationshipStatus.fromAffectionScore(60), RelationshipStatus.goodFriend);
      expect(RelationshipStatus.fromAffectionScore(80),
          RelationshipStatus.bestFriend);
      expect(RelationshipStatus.fromAffectionScore(95),
          RelationshipStatus.soulmate);
    });
  });

  group('RelationshipSummary', () {
    test('getProgressPercentage should calculate correctly', () {
      final summary = RelationshipSummary(
        npcId: 'alice',
        status: RelationshipStatus.friend,
        affectionScore: 50,
        totalInteractions: 10,
        unlockedDialoguesCount: 5,
        achievementsCount: 2,
      );

      expect(summary.getProgressPercentage(), 0.5);
    });

    test('getPointsToNextStatus should calculate remaining points', () {
      final summary = RelationshipSummary(
        npcId: 'alice',
        status: RelationshipStatus.acquaintance,
        affectionScore: 15,
        totalInteractions: 5,
        unlockedDialoguesCount: 2,
        achievementsCount: 0,
      );

      expect(summary.getPointsToNextStatus(), 10);
    });
  });
}
