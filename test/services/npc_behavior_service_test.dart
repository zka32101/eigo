import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_behavior_service.dart';

void main() {
  group('NPCBehaviorService', () {
    late NPCBehaviorService service;
    late PersonalityTraits defaultTraits;

    setUp(() {
      service = NPCBehaviorService.getInstance();
      defaultTraits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 50,
      );
    });

    test('should initialize behavior state', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      expect(state.npcId, 'npc-1');
      expect(state.personalityTraits, defaultTraits);
      expect(state.currentMood, NPCMood.neutral);
    });

    test('should get reaction to player', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);
      final reaction = service.getReactionToPlayer(state, 75, 'greeting');

      expect(reaction, isNotEmpty);
      expect(reaction, contains('greeting'));
    });

    test('should update mood by time - night should be tired', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);
      final nightTime = DateTime(2026, 9, 7, 22, 0);

      final updated = service.updateMoodByTime(state, nightTime);

      expect(updated.currentMood, NPCMood.tired);
    });

    test('should update mood by time - morning should be excited', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);
      final morningTime = DateTime(2026, 9, 7, 9, 0);

      final updated = service.updateMoodByTime(state, morningTime);

      expect(updated.currentMood, NPCMood.excited);
    });

    test('should update mood by time - afternoon should be neutral', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);
      final afternoonTime = DateTime(2026, 9, 7, 14, 0);

      final updated = service.updateMoodByTime(state, afternoonTime);

      expect(updated.currentMood, NPCMood.neutral);
    });

    test('should update mood by interaction - positive should make happy', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      final updated = service.updateMoodByInteraction(state, 75);

      expect(updated.currentMood, NPCMood.happy);
    });

    test('should update mood by interaction - negative should make angry', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      final updated = service.updateMoodByInteraction(state, -75);

      expect(updated.currentMood, NPCMood.angry);
    });

    test('should apply personality modifier - high agreeableness increases affection', () {
      final highAgreeable = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 80,
        neuroticism: 50,
      );

      final modified = service.applyPersonalityModifier(10, highAgreeable, 'dialogue');

      expect(modified, greaterThan(10));
    });

    test('should apply personality modifier - high neuroticism decreases affection', () {
      final highNeurotic = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 50,
        neuroticism: 70,
      );

      final modified = service.applyPersonalityModifier(10, highNeurotic, 'dialogue');

      expect(modified, lessThan(10));
    });

    test('should apply personality modifier - high extraversion boosts social interactions', () {
      final highExtravert = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 80,
        agreeableness: 50,
        neuroticism: 50,
      );

      final modified = service.applyPersonalityModifier(10, highExtravert, 'greeting');

      expect(modified, greaterThan(10));
    });

    test('should memorize interaction', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      final updated = service.memorizeInteraction(state, 'greeting', 'Said hello', 10);

      expect(updated.memorizedInteractions.length, 1);
      expect(updated.memorizedInteractions[0].type, 'greeting');
      expect(updated.memorizedInteractions[0].value, 10);
    });

    test('should generate personalized dialogue for cheerful personality', () {
      final cheerfulTraits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 80,
        agreeableness: 70,
        neuroticism: 30,
      );

      final state = service.initializeBehaviorState('npc-cheerful', cheerfulTraits);
      final options = service.generatePersonalizedDialogueOptions(state, ['Hello']);

      expect(options.length, greaterThan(1));
    });

    test('should generate personalized dialogue for kind personality', () {
      final kindTraits = PersonalityTraits(
        openness: 50,
        conscientiousness: 50,
        extraversion: 50,
        agreeableness: 80,
        neuroticism: 40,
      );

      final state = service.initializeBehaviorState('npc-kind', kindTraits);
      final options = service.generatePersonalizedDialogueOptions(state, ['Hello']);

      expect(options.length, greaterThan(1));
    });

    test('should calculate personality match - same traits should have high match', () {
      final traits = PersonalityTraits(
        openness: 70,
        conscientiousness: 70,
        extraversion: 70,
        agreeableness: 70,
        neuroticism: 50,
      );

      final match = service.calculatePersonalityMatch(traits, traits);

      expect(match, greaterThan(50));
    });

    test('should execute habit and increase count', () {
      final habit = Habit(
        habitId: 'habit-1',
        name: 'Morning exercise',
        description: 'Exercise in the morning',
        frequency: 'daily',
      );

      final state = service.initializeBehaviorState('npc-1', defaultTraits);
      final withHabit = state.copyWith(habits: [habit]);

      final updated = service.executHabit(withHabit, 'habit-1');

      expect(updated.habits[0].executionCount, 1);
      expect(updated.habits[0].lastExecutedAt, isNotNull);
    });

    test('should execute behavior pattern', () {
      final pattern = BehaviorPattern(
        patternId: 'pattern-1',
        name: 'Friendly greeting',
        description: 'Greet the player warmly',
        reaction: 'Hello there!',
        relatedPersonalities: [PersonalityType.cheerful],
        trigger: BehaviorTrigger(
          type: 'greeting',
          probability: 1.0,
        ),
        outcome: BehaviorOutcome(
          affectionChange: 5,
          xpReward: 10,
        ),
      );

      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      final updated = service.executeBehaviorPattern(state, pattern);

      expect(updated.executedBehaviors.length, 1);
      expect(updated.executedBehaviors[0].behaviorName, 'Friendly greeting');
    });

    test('should get recent interaction count', () {
      var state = service.initializeBehaviorState('npc-1', defaultTraits);

      state = service.memorizeInteraction(state, 'greeting', 'Hello', 5);
      state = service.memorizeInteraction(state, 'dialogue', 'Chat', 10);

      final count = service.getRecentInteractionCount(
        state,
        const Duration(days: 1),
      );

      expect(count, 2);
    });

    test('should get time since last interaction', () {
      var state = service.initializeBehaviorState('npc-1', defaultTraits);
      state = service.memorizeInteraction(state, 'greeting', 'Hello', 5);

      final duration = service.getTimeSinceLastInteraction(state);

      expect(duration, isNotNull);
      expect(duration!.inSeconds, greaterThanOrEqualTo(0));
    });

    test('should return null for time since last interaction when no interactions', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      final duration = service.getTimeSinceLastInteraction(state);

      expect(duration, isNull);
    });

    test('should check if topic is preferred', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits)
          .copyWith(preferredTopics: ['music', 'art']);

      expect(service.isPreferredTopic(state, 'music'), true);
      expect(service.isPreferredTopic(state, 'sports'), false);
    });

    test('should check if topic is disliked', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits)
          .copyWith(dislikedTopics: ['violence', 'negativity']);

      expect(service.isDislikedTopic(state, 'violence'), true);
      expect(service.isDislikedTopic(state, 'music'), false);
    });

    test('should get topic modifier for preferred topic', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits)
          .copyWith(preferredTopics: ['music']);

      final modifier = service.getTopicModifier(state, 'music');

      expect(modifier, 5);
    });

    test('should get negative topic modifier for disliked topic', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits)
          .copyWith(dislikedTopics: ['violence']);

      final modifier = service.getTopicModifier(state, 'violence');

      expect(modifier, -5);
    });

    test('should get zero modifier for neutral topic', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      final modifier = service.getTopicModifier(state, 'weather');

      expect(modifier, 0);
    });

    test('should generate behavior summary', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);

      final summary = service.generateBehaviorSummary(state);

      expect(summary.npcId, 'npc-1');
      expect(summary.personality, isNotNull);
      expect(summary.currentMood, NPCMood.neutral);
    });

    test('should generate personality description', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);
      final summary = service.generateBehaviorSummary(state);

      final description = summary.getPersonalityDescription();

      expect(description, isNotEmpty);
    });

    test('should generate mood description', () {
      final state = service.initializeBehaviorState('npc-1', defaultTraits);
      final summary = service.generateBehaviorSummary(state);

      final description = summary.getMoodDescription();

      expect(description, isNotEmpty);
    });

    test('should reset behavior', () {
      var state = service.initializeBehaviorState('npc-1', defaultTraits);
      state = service.memorizeInteraction(state, 'greeting', 'Hello', 5);

      expect(state.memorizedInteractions.length, 1);

      final reset = service.resetBehavior(state);

      expect(reset.npcId, state.npcId);
      expect(reset.currentMood, NPCMood.neutral);
      expect(reset.personalityTraits, state.personalityTraits);
    });
  });
}
