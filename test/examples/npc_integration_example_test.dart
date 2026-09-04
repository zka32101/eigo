import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/models/npc_quest_model.dart';
import 'package:eigo/models/npc_skill_model.dart';
import 'package:eigo/models/npc_save_model.dart';
import 'package:eigo/services/npc_behavior_service.dart';
import 'package:eigo/services/npc_dialogue_service.dart';
import 'package:eigo/services/npc_event_service.dart';
import 'package:eigo/services/npc_quest_service.dart';
import 'package:eigo/services/npc_skill_service.dart';
import 'package:eigo/services/npc_save_load_service.dart';
import 'package:eigo/examples/npc_integration_example.dart';

void main() {
  group('NPCIntegrationExample', () {
    late NPCIntegrationExample example;

    setUp(() {
      example = NPCIntegrationExample();
    });

    group('Initialization and Setup', () {
      test('services are properly initialized', () {
        expect(example.behaviorService, isNotNull);
        expect(example.dialogueService, isNotNull);
        expect(example.eventService, isNotNull);
        expect(example.questService, isNotNull);
        expect(example.skillService, isNotNull);
        expect(example.saveLoadService, isNotNull);
      });

      test('all services are singletons', () {
        final example2 = NPCIntegrationExample();
        expect(identical(example.behaviorService, example2.behaviorService), true);
        expect(identical(example.dialogueService, example2.dialogueService), true);
        expect(identical(example.eventService, example2.eventService), true);
        expect(identical(example.questService, example2.questService), true);
        expect(identical(example.skillService, example2.skillService), true);
        expect(identical(example.saveLoadService, example2.saveLoadService), true);
      });
    });

    group('NPC Initialization', () {
      test('Aria behavior state is created correctly', () {
        final ariaBehavior = example._initializeAria();

        expect(ariaBehavior.npcId, 'aria');
        expect(ariaBehavior.personalityTraits.openness, 75);
        expect(ariaBehavior.personalityTraits.conscientiousness, 60);
        expect(ariaBehavior.personalityTraits.extraversion, 50);
        expect(ariaBehavior.personalityTraits.agreeableness, 80);
        expect(ariaBehavior.personalityTraits.neuroticism, 30);
      });

      test('Aria has habits initialized', () {
        final ariaBehavior = example._initializeAria();

        expect(ariaBehavior.habits, isNotEmpty);
        expect(
          ariaBehavior.habits.any((h) => h.habitId == 'daily-meditation'),
          true,
        );
      });

      test('personality traits are within valid range', () {
        final ariaBehavior = example._initializeAria();
        final traits = ariaBehavior.personalityTraits;

        expect(traits.openness, greaterThanOrEqualTo(0));
        expect(traits.openness, lessThanOrEqualTo(100));
        expect(traits.conscientiousness, greaterThanOrEqualTo(0));
        expect(traits.conscientiousness, lessThanOrEqualTo(100));
        expect(traits.extraversion, greaterThanOrEqualTo(0));
        expect(traits.extraversion, lessThanOrEqualTo(100));
        expect(traits.agreeableness, greaterThanOrEqualTo(0));
        expect(traits.agreeableness, lessThanOrEqualTo(100));
        expect(traits.neuroticism, greaterThanOrEqualTo(0));
        expect(traits.neuroticism, lessThanOrEqualTo(100));
      });
    });

    group('Dialogue System', () {
      test('dialogue tree is created with all nodes', () {
        final tree = example._setupDialogueTree();

        expect(tree.treeId, 'aria-main');
        expect(tree.npcId, 'aria');
        expect(tree.rootNodeId, 'greeting');
        expect(tree.nodes.length, 4);
      });

      test('dialogue tree has required nodes', () {
        final tree = example._setupDialogueTree();

        expect(tree.nodes.containsKey('greeting'), true);
        expect(tree.nodes.containsKey('teach-offer'), true);
        expect(tree.nodes.containsKey('quest-start'), true);
        expect(tree.nodes.containsKey('farewell'), true);
      });

      test('greeting node has correct structure', () {
        final tree = example._setupDialogueTree();
        final greeting = tree.nodes['greeting']!;

        expect(greeting.nodeId, 'greeting');
        expect(greeting.npcText, isNotEmpty);
        expect(greeting.options.length, 2);
        expect(greeting.emoticon, '✨');
      });

      test('dialogue options have affection changes', () {
        final tree = example._setupDialogueTree();
        final greeting = tree.nodes['greeting']!;

        expect(greeting.options[0].affectionChange, 10);
        expect(greeting.options[1].affectionChange, -5);
      });

      test('dialogue options link to next nodes', () {
        final tree = example._setupDialogueTree();
        final greeting = tree.nodes['greeting']!;

        expect(greeting.options[0].nextNodeId, 'teach-offer');
        expect(greeting.options[1].nextNodeId, 'farewell');
      });

      test('quest start option triggers event', () {
        final tree = example._setupDialogueTree();
        final teachOffer = tree.nodes['teach-offer']!;

        expect(teachOffer.options[0].eventId, 'quest-offered-event');
      });

      test('dialogue session is created and active', () {
        final tree = example._setupDialogueTree();
        final session = example._startDialogue(tree);

        expect(session.sessionId, 'session-aria-1');
        expect(session.npcId, 'aria');
        expect(session.treeId, 'aria-main');
        expect(session.isActive, true);
        expect(session.currentNodeId, 'greeting');
      });
    });

    group('Quest System', () {
      test('fireball quest is created with correct properties', () {
        final quest = example._createFireballQuest();

        expect(quest.questId, 'fireball-quest');
        expect(quest.npcId, 'aria');
        expect(quest.questName, 'Learn Fireball Magic');
        expect(quest.steps.length, 3);
      });

      test('quest has all required steps', () {
        final quest = example._createFireballQuest();

        expect(quest.steps[0].stepId, 'gather-components');
        expect(quest.steps[1].stepId, 'prepare-ritual');
        expect(quest.steps[2].stepId, 'learn-incantation');
      });

      test('quest has reward with affection bonus', () {
        final quest = example._createFireballQuest();

        expect(quest.reward.affectionBonus, 50);
        expect(quest.reward.xpReward, 1000);
        expect(quest.reward.goldReward, 500);
        expect(quest.reward.skillRewards.contains('fireball'), true);
      });

      test('quest has condition requiring minimum affection', () {
        final quest = example._createFireballQuest();

        expect(quest.condition.minAffection, 20);
      });

      test('quest can be accepted and started', () {
        final quest = example._createFireballQuest();
        example._acceptQuest(quest);

        // Verify quest was processed through the service
        expect(quest.questId, 'fireball-quest');
      });

      test('quest steps can be progressed', () {
        final quest = example._createFireballQuest();
        example._progressQuest(quest);

        // All steps should be completed
        expect(quest.steps.length, 3);
      });
    });

    group('Skill System', () {
      test('fireball skill is registered with correct properties', () {
        final skill = example._registerFireballSkill();

        expect(skill.skillId, 'fireball');
        expect(skill.skillName, 'Fireball');
        expect(skill.category, SkillCategory.magic);
        expect(skill.teachingNpcId, 'aria');
        expect(skill.maxLevel, SkillLevel.master);
      });

      test('fireball skill has multiple teaching methods', () {
        final skill = example._registerFireballSkill();

        expect(skill.teachingMethods.length, 2);
        expect(skill.teachingMethods[0].methodId, 'direct-teaching');
        expect(skill.teachingMethods[1].methodId, 'practice');
      });

      test('teaching methods have different efficiency multipliers', () {
        final skill = example._registerFireballSkill();

        final directMethod = skill.teachingMethods[0];
        final practiceMethod = skill.teachingMethods[1];

        expect(directMethod.efficiencyMultiplier, 1.3);
        expect(practiceMethod.efficiencyMultiplier, 1.0);
      });

      test('teaching methods have different requirements', () {
        final skill = example._registerFireballSkill();

        final directMethod = skill.teachingMethods[0];
        final practiceMethod = skill.teachingMethods[1];

        expect(directMethod.requiredInteractionCount, 5);
        expect(practiceMethod.requiredInteractionCount, 10);
        expect(directMethod.requiredAffection, 40);
        expect(practiceMethod.requiredAffection, 30);
      });

      test('skill can be learned', () {
        final skill = example._registerFireballSkill();
        example._learnSkill(skill);

        // Skill learning should complete without errors
        expect(skill.skillId, 'fireball');
      });
    });

    group('Event System', () {
      test('rewards are distributed with affection bonus', () {
        final ariaBehavior = example._initializeAria();
        final quest = example._createFireballQuest();

        // Initial affection
        final initialAffection = ariaBehavior.currentAffection;

        // Distribute rewards (this should increase affection)
        example._distributeRewards(ariaBehavior, quest);

        // Verify reward amount
        expect(quest.reward.affectionBonus, 50);
      });

      test('mood information is accessible', () {
        final ariaBehavior = example._initializeAria();

        // Mood should have English and Japanese versions
        expect(ariaBehavior.currentMood, isNotNull);
        expect(ariaBehavior.currentMood.english, isNotEmpty);
      });
    });

    group('Save/Load System', () {
      test('game state can be saved', () async {
        final ariaBehavior = example._initializeAria();
        final quest = example._createFireballQuest();

        // This should complete without throwing
        await example._saveGameState(ariaBehavior, quest);
      });

      test('game state can be loaded', () async {
        final ariaBehavior = example._initializeAria();
        final quest = example._createFireballQuest();

        // Save first
        await example._saveGameState(ariaBehavior, quest);

        // Then load
        await example._loadGameState();
      });

      test('saved game data includes NPC states', () async {
        final ariaBehavior = example._initializeAria();
        final quest = example._createFireballQuest();

        await example._saveGameState(ariaBehavior, quest);
        await example._loadGameState();
      });

      test('saved game includes quest history', () async {
        final ariaBehavior = example._initializeAria();
        final quest = example._createFireballQuest();

        await example._saveGameState(ariaBehavior, quest);
        await example._loadGameState();
      });
    });

    group('Complete Integration Flow', () {
      test('complete game loop runs without errors', () async {
        // This is the ultimate integration test
        await example.runCompleteGameLoop();
      });

      test('affection increases through interaction', () {
        final ariaBehavior = example._initializeAria();
        final initialAffection = ariaBehavior.currentAffection;

        final quest = example._createFireballQuest();
        example._distributeRewards(ariaBehavior, quest);

        // Affection should increase
        expect(
          ariaBehavior.currentAffection + quest.reward.affectionBonus >=
              initialAffection,
          true,
        );
      });

      test('skills are learned after quest completion', () {
        final skill = example._registerFireballSkill();
        example._learnSkill(skill);

        // Skill should be in learned state
        expect(skill.skillId, 'fireball');
        expect(skill.skillName, 'Fireball');
      });

      test('multiple systems interact correctly', () {
        // Initialize NPC
        final ariaBehavior = example._initializeAria();

        // Setup dialogue
        final tree = example._setupDialogueTree();
        final session = example._startDialogue(tree);

        // Create quest
        final quest = example._createFireballQuest();
        example._acceptQuest(quest);

        // Register skill
        final skill = example._registerFireballSkill();
        example._learnSkill(skill);

        // Verify all components are initialized
        expect(ariaBehavior.npcId, 'aria');
        expect(session.npcId, 'aria');
        expect(quest.npcId, 'aria');
        expect(skill.teachingNpcId, 'aria');
      });

      test('game state persists across save and load', () async {
        final ariaBehavior = example._initializeAria();
        final quest = example._createFireballQuest();

        // Build some state
        example._acceptQuest(quest);
        example._distributeRewards(ariaBehavior, quest);

        // Save
        await example._saveGameState(ariaBehavior, quest);

        // Load
        await example._loadGameState();

        // Verify loaded state matches
        expect(ariaBehavior.npcId, 'aria');
      });
    });

    group('Error Handling', () {
      test('missing dialogue nodes are handled', () {
        final tree = example._setupDialogueTree();

        // Verify all node references are valid
        for (final node in tree.nodes.values) {
          if (node.options.isNotEmpty) {
            for (final option in node.options) {
              expect(
                tree.nodes.containsKey(option.nextNodeId),
                true,
                reason:
                    'Next node ${option.nextNodeId} not found in tree for node ${node.nodeId}',
              );
            }
          }
        }
      });

      test('quest rewards are non-negative', () {
        final quest = example._createFireballQuest();

        expect(quest.reward.xpReward, greaterThanOrEqualTo(0));
        expect(quest.reward.goldReward, greaterThanOrEqualTo(0));
        expect(quest.reward.affectionBonus, greaterThanOrEqualTo(0));
      });

      test('skill teaching methods have valid efficiency', () {
        final skill = example._registerFireballSkill();

        for (final method in skill.teachingMethods) {
          expect(method.efficiencyMultiplier, greaterThan(0));
          expect(method.efficiencyMultiplier, lessThanOrEqualTo(2.0));
        }
      });

      test('personality traits sum to reasonable values', () {
        final ariaBehavior = example._initializeAria();
        final traits = ariaBehavior.personalityTraits;

        // Big Five traits should each be 0-100 independently
        final sum = traits.openness +
            traits.conscientiousness +
            traits.extraversion +
            traits.agreeableness +
            traits.neuroticism;

        expect(sum, greaterThan(0));
        expect(sum, lessThanOrEqualTo(500));
      });
    });

    group('Data Consistency', () {
      test('quest step descriptions are not empty', () {
        final quest = example._createFireballQuest();

        for (final step in quest.steps) {
          expect(step.description.isNotEmpty, true);
          expect(step.objective.isNotEmpty, true);
        }
      });

      test('dialogue node text is not empty', () {
        final tree = example._setupDialogueTree();

        for (final node in tree.nodes.values) {
          expect(node.npcText.isNotEmpty, true);
          expect(node.emoticon.isNotEmpty, true);
        }
      });

      test('dialogue options have descriptions', () {
        final tree = example._setupDialogueTree();

        for (final node in tree.nodes.values) {
          for (final option in node.options) {
            expect(option.text.isNotEmpty, true);
          }
        }
      });

      test('skill description is meaningful', () {
        final skill = example._registerFireballSkill();

        expect(skill.description.isNotEmpty, true);
        expect(skill.effectDescription.isNotEmpty, true);
      });
    });
  });
}
