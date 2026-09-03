import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_dialogue_service.dart';
import 'package:eigo/services/npc_behavior_service.dart';

void main() {
  group('NPC Dialogue Integration Tests', () {
    late NPCDialogueService dialogueService;
    late NPCBehaviorService behaviorService;

    setUp(() {
      dialogueService = NPCDialogueService.getInstance();
      behaviorService = NPCBehaviorService.getInstance();
    });

    test('realistic character should have personality-based dialogue', () {
      // Create a cheerful merchant NPC
      final cheerfulMerchant = PersonalityTraits(
        openness: 70,
        conscientiousness: 75,
        extraversion: 80,
        agreeableness: 75,
        neuroticism: 30,
      );

      final npc = behaviorService.initializeBehaviorState(
        'merchant',
        cheerfulMerchant,
      );

      // Create greeting dialogue
      final greetingNode = DialogueNode(
        nodeId: 'greeting',
        npcText: 'Welcome to my shop! I am so glad you came by!',
        npcTextJa: 'ようこそ！来てくれて本当に嬉しいです！',
        dialogueType: DialogueType.greeting,
        emoticon: '😊',
        options: [
          DialogueOption(
            optionId: 'friendly-response',
            text: 'Your shop is amazing!',
            affectionChange: 10,
            nextNodeId: 'shop_intro',
          ),
          DialogueOption(
            optionId: 'neutral-response',
            text: 'I am just looking around',
            affectionChange: 0,
            nextNodeId: 'shop_intro',
          ),
        ],
      );

      final shopIntroNode = DialogueNode(
        nodeId: 'shop_intro',
        npcText: 'Let me show you our finest wares!',
        npcTextJa: '一番いい品をお見せします！',
        dialogueType: DialogueType.shop,
        options: [
          DialogueOption(
            optionId: 'buy-something',
            text: 'I would love to buy something',
            affectionChange: 15,
          ),
          DialogueOption(
            optionId: 'browse',
            text: 'I will browse for now',
            affectionChange: 5,
          ),
        ],
      );

      final tree = DialogueTree(
        treeId: 'merchant-greeting',
        npcId: 'merchant',
        title: 'Merchant Greeting',
        description: 'Initial greeting dialogue with merchant',
        rootNodeId: 'greeting',
        nodes: {
          'greeting': greetingNode,
          'shop_intro': shopIntroNode,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dialogueService.registerTree(tree);

      // Start dialogue
      var session = dialogueService.startDialogue(tree, 'merchant');
      expect(session.currentNodeId, 'greeting');

      // Player chooses friendly response
      session = dialogueService.selectOption(
        session,
        'friendly-response',
        tree,
        50,
        npc,
      );

      final affectionGain =
          dialogueService.getSessionAffectionChange(session);

      expect(affectionGain, 10);
      expect(session.currentNodeId, 'shop_intro');
    });

    test('should handle affection-gated dialogue', () {
      // Create a romance dialogue that requires high affection
      final romanticNode = DialogueNode(
        nodeId: 'romantic',
        npcText: 'You mean the world to me...',
        npcTextJa: 'あなたは私にとって全てです...',
        dialogueType: DialogueType.romance,
        condition: DialogueCondition(minAffection: 80),
        options: [],
      );

      expect(
        dialogueService.isNodeAvailable(romanticNode, 100,
          behaviorService.initializeBehaviorState('npc', PersonalityTraits(
            openness: 50, conscientiousness: 50, extraversion: 50,
            agreeableness: 50, neuroticism: 50
          ))
        ),
        true,
      );

      expect(
        dialogueService.isNodeAvailable(romanticNode, 30,
          behaviorService.initializeBehaviorState('npc', PersonalityTraits(
            openness: 50, conscientiousness: 50, extraversion: 50,
            agreeableness: 50, neuroticism: 50
          ))
        ),
        false,
      );
    });

    test('should adapt dialogue based on NPC mood', () {
      final traits = PersonalityTraits(
        openness: 50, conscientiousness: 50, extraversion: 50,
        agreeableness: 50, neuroticism: 50,
      );

      var npc = behaviorService.initializeBehaviorState('npc', traits);

      // Create mood-dependent nodes
      final happyNode = DialogueNode(
        nodeId: 'happy',
        npcText: 'I am having a wonderful day!',
        dialogueType: DialogueType.small_talk,
        condition: DialogueCondition(requiredMoods: [NPCMood.happy]),
        options: [],
      );

      final tiredNode = DialogueNode(
        nodeId: 'tired',
        npcText: 'I am so exhausted...',
        dialogueType: DialogueType.small_talk,
        condition: DialogueCondition(requiredMoods: [NPCMood.tired]),
        options: [],
      );

      expect(dialogueService.isNodeAvailable(happyNode, 50, npc), false);

      npc = npc.copyWith(currentMood: NPCMood.happy);
      expect(dialogueService.isNodeAvailable(happyNode, 50, npc), true);

      npc = npc.copyWith(currentMood: NPCMood.tired);
      expect(dialogueService.isNodeAvailable(tiredNode, 50, npc), true);
    });

    test('should chain multiple dialogue nodes', () {
      // Build a multi-step conversation
      final nodes = {
        'start': DialogueNode(
          nodeId: 'start',
          npcText: 'Hello! How are you today?',
          dialogueType: DialogueType.greeting,
          options: [
            DialogueOption(
              optionId: 'opt1',
              text: 'I am doing well!',
              affectionChange: 5,
              nextNodeId: 'response1',
            ),
            DialogueOption(
              optionId: 'opt2',
              text: 'I am tired',
              affectionChange: 0,
              nextNodeId: 'response2',
            ),
          ],
        ),
        'response1': DialogueNode(
          nodeId: 'response1',
          npcText: 'That is wonderful to hear!',
          dialogueType: DialogueType.small_talk,
          options: [
            DialogueOption(
              optionId: 'opt3',
              text: 'Thank you for asking',
              affectionChange: 5,
              nextNodeId: 'end',
            ),
          ],
        ),
        'response2': DialogueNode(
          nodeId: 'response2',
          npcText: 'You should rest then',
          dialogueType: DialogueType.small_talk,
          options: [
            DialogueOption(
              optionId: 'opt4',
              text: 'Good advice',
              affectionChange: 5,
              nextNodeId: 'end',
            ),
          ],
        ),
        'end': DialogueNode(
          nodeId: 'end',
          npcText: 'Goodbye!',
          dialogueType: DialogueType.farewell,
          options: [],
        ),
      };

      final tree = DialogueTree(
        treeId: 'conversation-chain',
        npcId: 'npc-friend',
        title: 'Friendship Conversation',
        description: 'A multi-step conversation',
        rootNodeId: 'start',
        nodes: nodes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dialogueService.registerTree(tree);

      final npc = behaviorService.initializeBehaviorState(
        'npc-friend',
        PersonalityTraits(
          openness: 50, conscientiousness: 50, extraversion: 50,
          agreeableness: 50, neuroticism: 50,
        ),
      );

      // Start conversation
      var session = dialogueService.startDialogue(tree, 'npc-friend');
      expect(session.currentNodeId, 'start');

      // Player chooses first option
      session = dialogueService.selectOption(
        session,
        'opt1',
        tree,
        50,
        npc,
      );
      expect(session.currentNodeId, 'response1');
      expect(session.history.length, 1);

      // Player continues conversation
      session = dialogueService.selectOption(
        session,
        'opt3',
        tree,
        55, // Affection increased
        npc,
      );
      expect(session.currentNodeId, 'end');
      expect(session.history.length, 2);

      final totalAffectionChange =
          dialogueService.getSessionAffectionChange(session);
      expect(totalAffectionChange, 10);
    });

    test('should personalize dialogue based on topic preferences', () {
      final npc = behaviorService.initializeBehaviorState(
        'bookworm',
        PersonalityTraits(
          openness: 80, conscientiousness: 70, extraversion: 40,
          agreeableness: 65, neuroticism: 35,
        ),
      ).copyWith(
        preferredTopics: ['books', 'literature', 'reading'],
        dislikedTopics: ['violence', 'hunting'],
      );

      // Create dialogue options for different topics
      final literatureOption = DialogueOption(
        optionId: 'talk-books',
        text: 'I love reading books too!',
        affectionChange: 10,
      );

      final huntingOption = DialogueOption(
        optionId: 'talk-hunting',
        text: 'Have you been hunting lately?',
        affectionChange: 5,
      );

      // Modify options based on preferences
      final modifiedLiterature =
          dialogueService.modifyOptionByPersonality(literatureOption, npc);
      final modifiedHunting =
          dialogueService.modifyOptionByPersonality(huntingOption, npc);

      // Literature should get bonus, hunting should get penalty or stay low
      expect(
        modifiedLiterature.affectionChange,
        greaterThanOrEqualTo(literatureOption.affectionChange),
      );
    });

    test('should handle dialogue flow with multiple trees', () {
      // Create first dialogue tree (greeting)
      final greetingTree = DialogueTree(
        treeId: 'greet-tree',
        npcId: 'friend',
        title: 'Greeting',
        description: 'Greeting dialogue',
        rootNodeId: 'greet',
        nodes: {
          'greet': DialogueNode(
            nodeId: 'greet',
            npcText: 'Hi there!',
            dialogueType: DialogueType.greeting,
            options: [],
          ),
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create second dialogue tree (quest)
      final questTree = DialogueTree(
        treeId: 'quest-tree',
        npcId: 'friend',
        title: 'Quest Offer',
        description: 'Quest dialogue',
        rootNodeId: 'offer',
        nodes: {
          'offer': DialogueNode(
            nodeId: 'offer',
            npcText: 'I need your help with something',
            dialogueType: DialogueType.quest_offer,
            options: [],
          ),
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create dialogue flow
      final flow = dialogueService.createDialogueFlow(
        'friend-flow',
        'friend',
        ['greet-tree', 'quest-tree'],
        'greet-tree',
      );

      expect(flow.treeIds.length, 2);
      expect(flow.defaultTreeId, 'greet-tree');

      dialogueService.registerTree(greetingTree);
      dialogueService.registerTree(questTree);

      // Both trees should be available
      expect(dialogueService.getTree('greet-tree'), isNotNull);
      expect(dialogueService.getTree('quest-tree'), isNotNull);
    });

    test('should generate dialogue statistics', () {
      final npc = behaviorService.initializeBehaviorState(
        'npc-stats',
        PersonalityTraits(
          openness: 50, conscientiousness: 50, extraversion: 50,
          agreeableness: 50, neuroticism: 50,
        ),
      );

      // Create test tree
      final tree = DialogueTree(
        treeId: 'stats-tree',
        npcId: 'npc-stats',
        title: 'Test',
        description: 'Test',
        rootNodeId: 'node1',
        nodes: {
          'node1': DialogueNode(
            nodeId: 'node1',
            npcText: 'Hello',
            dialogueType: DialogueType.greeting,
            options: [
              DialogueOption(
                optionId: 'opt',
                text: 'Hi',
                affectionChange: 10,
              ),
            ],
          ),
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      dialogueService.registerTree(tree);

      // Simulate multiple conversations
      final sessions = [
        dialogueService.startDialogue(tree, 'npc-stats'),
        dialogueService.startDialogue(tree, 'npc-stats'),
        dialogueService.startDialogue(tree, 'npc-stats'),
      ];

      final stats =
          dialogueService.generateSessionStatistics('npc-stats', sessions);

      expect(stats.npcId, 'npc-stats');
      expect(stats.totalConversations, 3);
      expect(stats.uniqueTreesUsed, 1);
    });

    test('should recommend dialogue types by personality', () {
      // Test ambitious NPC
      final ambitiousNPC = behaviorService.initializeBehaviorState(
        'ambitious',
        PersonalityTraits(
          openness: 80, conscientiousness: 75, extraversion: 70,
          agreeableness: 60, neuroticism: 40,
        ),
      );

      final recommendedTypes =
          dialogueService.getRecommendedDialogueTypes(ambitiousNPC);

      expect(
        recommendedTypes,
        contains(DialogueType.quest_offer),
      );

      // Test kind NPC
      final kindNPC = behaviorService.initializeBehaviorState(
        'kind',
        PersonalityTraits(
          openness: 60, conscientiousness: 70, extraversion: 75,
          agreeableness: 85, neuroticism: 40,
        ),
      );

      final kindRecommended =
          dialogueService.getRecommendedDialogueTypes(kindNPC);

      expect(kindRecommended, contains(DialogueType.greeting));
      expect(kindRecommended, contains(DialogueType.small_talk));
    });

    test('should render emoticons based on mood', () {
      final npc = behaviorService.initializeBehaviorState(
        'emotional',
        PersonalityTraits(
          openness: 50, conscientiousness: 50, extraversion: 50,
          agreeableness: 50, neuroticism: 50,
        ),
      ).copyWith(currentMood: NPCMood.angry);

      final node = DialogueNode(
        nodeId: 'angry',
        npcText: 'You really upset me!',
        dialogueType: DialogueType.angry,
        options: [],
      );

      final rendered = dialogueService.renderDialogueNode(node, npc);

      expect(rendered, contains('😠'));
    });
  });
}
