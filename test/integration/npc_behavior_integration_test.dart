import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_behavior_service.dart';

void main() {
  group('NPC Behavior Integration Tests', () {
    late NPCBehaviorService service;

    setUp(() {
      service = NPCBehaviorService.getInstance();
    });

    test('realistic character should respond differently based on affection', () {
      final cheerfulTraits = PersonalityTraits(
        openness: 70,
        conscientiousness: 60,
        extraversion: 80,
        agreeableness: 75,
        neuroticism: 30,
      );

      var state = service.initializeBehaviorState('teacher-npc', cheerfulTraits);

      final lowAffectionReaction = service.getReactionToPlayer(state, 20, 'greeting');
      expect(lowAffectionReaction, contains('greeting'));

      state = state.copyWith(currentMood: NPCMood.happy);
      final highAffectionReaction = service.getReactionToPlayer(state, 90, 'greeting');

      expect(highAffectionReaction, contains('greeting'));
      expect(highAffectionReaction, contains('Very positive'));
    });

    test('should track mood changes over time', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      var state = service.initializeBehaviorState('npc-1', traits);
      expect(state.currentMood, NPCMood.neutral);

      // Morning: should be excited
      state = service.updateMoodByTime(state, DateTime(2026, 9, 7, 9, 0));
      expect(state.currentMood, NPCMood.excited);

      // Afternoon: back to neutral
      state = service.updateMoodByTime(state, DateTime(2026, 9, 7, 15, 0));
      expect(state.currentMood, NPCMood.neutral);

      // Night: should be tired
      state = service.updateMoodByTime(state, DateTime(2026, 9, 7, 23, 0));
      expect(state.currentMood, NPCMood.tired);
    });

    test('should build personality traits over interactions', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      var state = service.initializeBehaviorState('npc-1', traits);

      // Multiple positive interactions
      state = service.memorizeInteraction(state, 'greeting', 'Greeted warmly', 15);
      state = service.memorizeInteraction(state, 'dialogue', 'Had good conversation', 20);
      state = service.memorizeInteraction(state, 'gift', 'Gave thoughtful gift', 25);

      expect(state.memorizedInteractions.length, 3);
      expect(state.memorizedInteractions[0].value, 15);
      expect(state.memorizedInteractions[1].value, 20);
      expect(state.memorizedInteractions[2].value, 25);
    });

    test('should handle personality-based affection changes', () {
      // Test with an aggressive NPC (high neuroticism, low agreeableness)
      final aggressiveTraits = PersonalityTraits(
        openness: 40,
        conscientiousness: 50,
        extraversion: 60,
        agreeableness: 30,
        neuroticism: 80,
      );

      var state = service.initializeBehaviorState('aggressive-npc', aggressiveTraits);

      // Same interaction should have less positive effect
      final modifier = service.applyPersonalityModifier(20, aggressiveTraits, 'dialogue');

      // Should be reduced due to high neuroticism
      expect(modifier, lessThan(20));
    });

    test('should recommend dialogue based on personality', () {
      final cheerfulTraits = PersonalityTraits(
        openness: 70,
        conscientiousness: 60,
        extraversion: 80,
        agreeableness: 75,
        neuroticism: 30,
      );

      final state = service.initializeBehaviorState('cheerful-npc', cheerfulTraits);

      final baseOptions = ['Hello', 'How are you?'];
      final personalizedOptions =
          service.generatePersonalizedDialogueOptions(state, baseOptions);

      expect(personalizedOptions.length, greaterThan(baseOptions.length));
      expect(personalizedOptions, contains('Hello'));
    });

    test('should calculate compatibility with player', () {
      // Friendly NPC
      final friendlyNPC = PersonalityTraits(
        openness: 75,
        conscientiousness: 70,
        extraversion: 70,
        agreeableness: 80,
        neuroticism: 35,
      );

      // Friendly player
      final friendlyPlayer = PersonalityTraits(
        openness: 70,
        conscientiousness: 75,
        extraversion: 65,
        agreeableness: 75,
        neuroticism: 40,
      );

      // Hostile player
      final hostilePlayer = PersonalityTraits(
        openness: 40,
        conscientiousness: 40,
        extraversion: 50,
        agreeableness: 30,
        neuroticism: 75,
      );

      final friendlyMatch = service.calculatePersonalityMatch(friendlyNPC, friendlyPlayer);
      final hostileMatch = service.calculatePersonalityMatch(friendlyNPC, hostilePlayer);

      expect(friendlyMatch, greaterThan(hostileMatch));
    });

    test('should manage NPC habits and routines', () {
      final habit1 = Habit(
        habitId: 'habit-morning',
        name: 'Morning tea',
        description: 'Drink tea every morning',
        frequency: 'daily',
      );

      final habit2 = Habit(
        habitId: 'habit-reading',
        name: 'Reading books',
        description: 'Read books in the evening',
        frequency: 'daily',
      );

      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      var state = service.initializeBehaviorState('npc-1', traits)
          .copyWith(habits: [habit1, habit2]);

      expect(state.habits.length, 2);

      // Execute morning habit
      var updated = service.executHabit(state, 'habit-morning');
      expect(updated.habits[0].executionCount, 1);
      expect(updated.habits[1].executionCount, 0);

      // Execute reading habit
      updated = service.executHabit(updated, 'habit-reading');
      expect(updated.habits[0].executionCount, 1);
      expect(updated.habits[1].executionCount, 1);
    });

    test('should execute behavior patterns', () {
      final greetingPattern = BehaviorPattern(
        patternId: 'greet-1',
        name: 'Friendly greeting',
        description: 'Greet the player warmly',
        reaction: 'Hello! Nice to see you!',
        relatedPersonalities: [PersonalityType.cheerful, PersonalityType.kind],
        trigger: BehaviorTrigger(
          type: 'greeting',
          probability: 1.0,
        ),
        outcome: BehaviorOutcome(
          affectionChange: 5,
          moodChange: 'happy',
          xpReward: 10,
        ),
      );

      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      var state = service.initializeBehaviorState('npc-1', traits);
      state = service.executeBehaviorPattern(state, greetingPattern);

      expect(state.executedBehaviors.length, 1);
      expect(state.executedBehaviors[0].behaviorName, 'Friendly greeting');
      expect(state.executedBehaviors[0].result, 'Hello! Nice to see you!');
    });

    test('should handle topic preferences correctly', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );

      var state = service.initializeBehaviorState('npc-1', traits);
      state = state.copyWith(
        preferredTopics: ['books', 'music', 'nature'],
        dislikedTopics: ['violence', 'negativity'],
      );

      // Test preferred topics
      expect(service.isPreferredTopic(state, 'books'), true);
      expect(service.isPreferredTopic(state, 'music'), true);
      expect(service.getTopicModifier(state, 'nature'), 5);

      // Test disliked topics
      expect(service.isDislikedTopic(state, 'violence'), true);
      expect(service.getTopicModifier(state, 'negativity'), -5);

      // Test neutral topics
      expect(service.isPreferredTopic(state, 'weather'), false);
      expect(service.isDislikedTopic(state, 'weather'), false);
      expect(service.getTopicModifier(state, 'weather'), 0);
    });

    test('should generate realistic NPC summary', () {
      final traits = PersonalityTraits(
        openness: 60,
        conscientiousness: 70,
        extraversion: 75,
        agreeableness: 80,
        neuroticism: 40,
      );

      var state = service.initializeBehaviorState('teacher-npc', traits);

      // Add some history
      state = service.memorizeInteraction(state, 'greeting', 'Greeted', 10);
      state = service.memorizeInteraction(state, 'dialogue', 'Chatted', 15);

      state = state.copyWith(
        preferredTopics: ['education', 'learning'],
        dislikedTopics: ['rudeness'],
      );

      final summary = service.generateBehaviorSummary(state);

      expect(summary.npcId, 'teacher-npc');
      expect(summary.personality, isNotNull);
      expect(summary.memorizedInteractionCount, 2);
      expect(summary.getPersonalityDescription(), isNotEmpty);
      expect(summary.getMoodDescription(), isNotEmpty);
    });

    test('should track affection over time through multiple interactions', () {
      final traits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 70, // High agreeableness
        neuroticism: 50,
      );

      var state = service.initializeBehaviorState('npc-1', traits);
      var totalAffectionChange = 0;

      // Simulate player interactions
      final interactions = [
        ('greeting', 'Said hello', 5),
        ('dialogue', 'Had nice chat', 10),
        ('gift', 'Gave gift', 15),
      ];

      for (final (type, desc, value) in interactions) {
        state = service.memorizeInteraction(state, type, desc, value);
        final modifier = service.applyPersonalityModifier(value, traits, type);
        totalAffectionChange += modifier;
      }

      expect(state.memorizedInteractions.length, 3);
      expect(totalAffectionChange, greaterThan(0));
    });

    test('should handle contrasting personalities', () {
      // Introverted, sensitive NPC
      final introvertedTraits = PersonalityTraits(
        openness: 45,
        conscientiousness: 75,
        extraversion: 25,
        agreeableness: 70,
        neuroticism: 65,
      );

      // Extroverted, bold player
      final extrovertedPlayer = PersonalityTraits(
        openness: 80,
        conscientiousness: 50,
        extraversion: 85,
        agreeableness: 55,
        neuroticism: 30,
      );

      final state = service.initializeBehaviorState('introverted-npc', introvertedTraits);

      final compatibility =
          service.calculatePersonalityMatch(introvertedTraits, extrovertedPlayer);

      expect(compatibility, greaterThanOrEqualTo(0));
      expect(compatibility, lessThanOrEqualTo(100));
    });

    test('should reset behavior to initial state', () {
      var state = service.initializeBehaviorState(
        'npc-1',
        PersonalityTraits(
          openness: 50,
          conscientiousness: 50,
          extraversion: 50,
          agreeableness: 50,
          neuroticism: 50,
        ),
      );

      // Modify state
      state = state.copyWith(currentMood: NPCMood.angry);
      state = service.memorizeInteraction(state, 'greeting', 'Hello', 5);

      expect(state.currentMood, NPCMood.angry);
      expect(state.memorizedInteractions.length, 1);

      // Reset
      final reset = service.resetBehavior(state);

      expect(reset.currentMood, NPCMood.neutral);
      expect(reset.npcId, 'npc-1');
      expect(reset.personalityTraits, state.personalityTraits);
    });
  });
}
