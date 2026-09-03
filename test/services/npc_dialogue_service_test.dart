import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_dialogue_service.dart';
import 'package:eigo/services/npc_behavior_service.dart';

void main() {
  group('NPCDialogueService', () {
    late NPCDialogueService dialogueService;
    late NPCBehaviorService behaviorService;
    late DialogueTree testTree;
    late NPCBehaviorState testNPC;

    setUp(() {
      dialogueService = NPCDialogueService.getInstance();
      behaviorService = NPCBehaviorService.getInstance();

      // Create test nodes
      final greetingNode = DialogueNode(
        nodeId: 'greeting',
        npcText: 'Hello there!',
        npcTextJa: 'こんにちは！',
        dialogueType: DialogueType.greeting,
        emoticon: '😊',
        options: [
          DialogueOption(
            optionId: 'opt-1',
            text: 'Hi! How are you?',
            textJa: 'こんにちは、元気ですか？',
            affectionChange: 5,
            nextNodeId: 'response',
          ),
          DialogueOption(
            optionId: 'opt-2',
            text: 'Leave me alone',
            textJa: 'ほっておいてくれ',
            affectionChange: -10,
          ),
        ],
      );

      final responseNode = DialogueNode(
        nodeId: 'response',
        npcText: 'I am doing well, thank you!',
        npcTextJa: '元気です、ありがとう！',
        dialogueType: DialogueType.small_talk,
        autoNextNodeId: null,
        options: [
          DialogueOption(
            optionId: 'opt-3',
            text: 'That is great!',
            textJa: 'それは素晴らしい！',
            affectionChange: 5,
          ),
        ],
      );

      // Create test tree
      testTree = DialogueTree(
        treeId: 'test-tree',
        npcId: 'test-npc',
        title: 'Test Dialogue',
        description: 'A test dialogue tree',
        rootNodeId: 'greeting',
        nodes: {
          'greeting': greetingNode,
          'response': responseNode,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create test NPC
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );
      testNPC = behaviorService.initializeBehaviorState('test-npc', traits);

      // Register tree
      dialogueService.registerTree(testTree);
    });

    test('should start dialogue session', () {
      final session = dialogueService.startDialogue(testTree, 'test-npc');

      expect(session.treeId, 'test-tree');
      expect(session.npcId, 'test-npc');
      expect(session.currentNodeId, 'greeting');
      expect(session.isComplete, false);
      expect(session.history.isEmpty, true);
    });

    test('should retrieve registered tree', () {
      final retrieved = dialogueService.getTree('test-tree');

      expect(retrieved, isNotNull);
      expect(retrieved!.treeId, 'test-tree');
      expect(retrieved.nodes.length, 2);
    });

    test('should check affection condition', () {
      final conditionPass = DialogueCondition(
        minAffection: 10,
        maxAffection: 100,
      );

      final conditionFail = DialogueCondition(
        minAffection: 100,
      );

      expect(dialogueService.checkCondition(conditionPass, 50, testNPC), true);
      expect(dialogueService.checkCondition(conditionFail, 50, testNPC), false);
    });

    test('should check mood condition', () {
      final condition = DialogueCondition(
        requiredMoods: [NPCMood.happy, NPCMood.excited],
      );

      expect(dialogueService.checkCondition(condition, 50, testNPC), false);

      final happyNPC = testNPC.copyWith(currentMood: NPCMood.happy);
      expect(dialogueService.checkCondition(condition, 50, happyNPC), true);
    });

    test('should check personality condition', () {
      final condition = DialogueCondition(
        requiredPersonalities: [PersonalityType.cheerful],
      );

      final cheerfulTraits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 80,
        agreeableness: 75,
        neuroticism: 30,
      );

      final cheerfulNPC =
          behaviorService.initializeBehaviorState('cheerful', cheerfulTraits);

      expect(dialogueService.checkCondition(condition, 50, testNPC), false);
      expect(dialogueService.checkCondition(condition, 50, cheerfulNPC), true);
    });

    test('should check personality trait condition', () {
      final condition = DialogueCondition(
        minAgreeableness: 60,
      );

      expect(dialogueService.checkCondition(condition, 50, testNPC), false);

      final agreeableTraits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 70,
        neuroticism: 50,
      );

      final agreeableNPC =
          behaviorService.initializeBehaviorState('agreeable', agreeableTraits);

      expect(dialogueService.checkCondition(condition, 50, agreeableNPC), true);
    });

    test('should select dialogue option', () {
      final session = dialogueService.startDialogue(testTree, 'test-npc');

      final updated = dialogueService.selectOption(
        session,
        'opt-1',
        testTree,
        50,
        testNPC,
      );

      expect(updated.history.length, 1);
      expect(updated.history[0].chosenOptionId, 'opt-1');
      expect(updated.history[0].playerChoice, 'Hi! How are you?');
      expect(updated.currentNodeId, 'response');
    });

    test('should render dialogue with mood emoticon', () {
      final node = testTree.getNode('greeting')!;
      final rendered = dialogueService.renderDialogueNode(node, testNPC);

      expect(rendered, contains('😊'));
      expect(rendered, contains('Hello there!'));
    });

    test('should render dialogue with personality emoticon', () {
      final cheerfulTraits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 80,
        agreeableness: 75,
        neuroticism: 30,
      );

      final cheerfulNPC =
          behaviorService.initializeBehaviorState('cheerful', cheerfulTraits);

      final node = testTree.getNode('greeting')!;
      final rendered = dialogueService.renderDialogueNode(node, cheerfulNPC);

      expect(rendered, contains('😊'));
    });

    test('should get session affection change', () {
      var session = dialogueService.startDialogue(testTree, 'test-npc');

      session = dialogueService.selectOption(
        session,
        'opt-1',
        testTree,
        50,
        testNPC,
      );

      final affectionChange =
          dialogueService.getSessionAffectionChange(session);

      expect(affectionChange, 5);
    });

    test('should continue dialogue', () {
      var session = dialogueService.startDialogue(testTree, 'test-npc');

      session = dialogueService.selectOption(
        session,
        'opt-1',
        testTree,
        50,
        testNPC,
      );

      final nextNode = dialogueService.continueDialogue(session, testTree);

      expect(nextNode, isNotNull);
      expect(nextNode!.nodeId, 'response');
    });

    test('should end dialogue and generate statistics', () {
      var session = dialogueService.startDialogue(testTree, 'test-npc');

      session = dialogueService.selectOption(
        session,
        'opt-1',
        testTree,
        50,
        testNPC,
      );

      final stats = dialogueService.endDialogue(session, testNPC, 50);

      expect(stats.npcId, 'test-npc');
      expect(stats.totalConversations, 1);
      expect(stats.totalAffectionChange, 5);
    });

    test('should get recommended dialogue types for personality', () {
      final sarcastic = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 80,
        agreeableness: 30,
        neuroticism: 50,
      );

      final sarcasticNPC =
          behaviorService.initializeBehaviorState('sarcastic', sarcastic);

      final types = dialogueService.getRecommendedDialogueTypes(sarcasticNPC);

      expect(types, contains(DialogueType.small_talk));
      expect(types, contains(DialogueType.custom));
    });

    test('should create dialogue flow', () {
      final flow = dialogueService.createDialogueFlow(
        'flow-1',
        'test-npc',
        ['tree-1', 'tree-2'],
        'tree-1',
      );

      expect(flow.flowId, 'flow-1');
      expect(flow.npcId, 'test-npc');
      expect(flow.treeIds.length, 2);
      expect(flow.defaultTreeId, 'tree-1');
      expect(flow.isActive, true);
    });

    test('should filter dialogue options based on conditions', () {
      final node = testTree.getNode('greeting')!;
      final filtered = dialogueService.filterOptions(node, 50, testNPC);

      expect(filtered.length, 2);
    });

    test('should clone dialogue tree', () {
      final cloned = dialogueService.cloneTree(testTree, 'cloned-tree');

      expect(cloned.treeId, 'cloned-tree');
      expect(cloned.npcId, testTree.npcId);
      expect(cloned.nodes.length, testTree.nodes.length);
    });

    test('should generate session statistics', () {
      final session1 = dialogueService.startDialogue(testTree, 'test-npc');
      final session2 = dialogueService.startDialogue(testTree, 'test-npc');

      final stats = dialogueService.generateSessionStatistics(
        'test-npc',
        [session1, session2],
      );

      expect(stats.npcId, 'test-npc');
      expect(stats.totalConversations, 2);
      expect(stats.uniqueTreesUsed, 1);
    });

    test('should modify option by personality', () {
      final option = DialogueOption(
        optionId: 'opt-test',
        text: 'This is friendly',
        affectionChange: 10,
      );

      final agreeableTraits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 80,
        neuroticism: 50,
      );

      final agreeableNPC =
          behaviorService.initializeBehaviorState('agreeable', agreeableTraits);

      final modified =
          dialogueService.modifyOptionByPersonality(option, agreeableNPC);

      expect(modified.affectionChange, greaterThan(option.affectionChange));
    });

    test('should check node availability', () {
      final conditionNode = DialogueNode(
        nodeId: 'conditional',
        npcText: 'You are special to me',
        dialogueType: DialogueType.romance,
        condition: DialogueCondition(minAffection: 80),
        options: [],
      );

      expect(
          dialogueService.isNodeAvailable(conditionNode, 100, testNPC), true);
      expect(dialogueService.isNodeAvailable(conditionNode, 50, testNPC),
          false);
    });
  });
}
