import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/services/npc_event_service.dart';
import 'package:eigo/services/npc_behavior_service.dart';

void main() {
  group('NPCEventService', () {
    late NPCEventService eventService;
    late NPCBehaviorService behaviorService;
    late NPCBehaviorState testNPC;

    setUp(() {
      eventService = NPCEventService.getInstance();
      behaviorService = NPCBehaviorService.getInstance();
      testNPC = behaviorService.initializeBehaviorState(
        'test-npc',
        PersonalityTraits(
          openness: 50,
          conscientiousness: 50,
          extraversion: 50,
          agreeableness: 50,
          neuroticism: 50,
        ),
      );
    });

    test('should create event', () {
      final event = eventService.createEvent(
        'npc-1',
        EventType.dialogue_triggered,
        'Test Event',
        'Test Description',
        'dialogue',
      );

      expect(event.npcId, 'npc-1');
      expect(event.eventType, EventType.dialogue_triggered);
      expect(event.isProcessed, false);
    });

    test('should register and retrieve event', () {
      final event = eventService.createEvent(
        'npc-1',
        EventType.quest_given,
        'Quest Event',
        'A quest event',
        'dialogue',
      );

      final retrieved = eventService.getEvent(event.eventId);
      expect(retrieved, isNotNull);
      expect(retrieved!.eventId, event.eventId);
    });

    test('should process event', () {
      final event = eventService.createEvent(
        'npc-1',
        EventType.dialogue_triggered,
        'Test',
        'Test',
        'dialogue',
      );

      final processed = eventService.processEvent(event.eventId);

      expect(processed.isProcessed, true);
      expect(processed.completedAt, isNotNull);
    });

    test('should create trigger', () {
      final trigger = eventService.createTrigger(
        'npc-1',
        'dialogue',
        'event-1',
      );

      expect(trigger.npcId, 'npc-1');
      expect(trigger.isActive, true);
    });

    test('should check affection condition', () {
      final condition = EventCondition(minAffection: 50);

      expect(eventService.checkCondition(condition, 60, testNPC), true);
      expect(eventService.checkCondition(condition, 40, testNPC), false);
    });

    test('should check mood condition', () {
      final condition =
          EventCondition(requiredMoods: [NPCMood.happy, NPCMood.excited]);

      expect(eventService.checkCondition(condition, 50, testNPC), false);

      final happyNPC = testNPC.copyWith(currentMood: NPCMood.happy);
      expect(eventService.checkCondition(condition, 50, happyNPC), true);
    });

    test('should create event sequence', () {
      final sequence =
          eventService.createSequence('npc-1', ['event-1', 'event-2']);

      expect(sequence.npcId, 'npc-1');
      expect(sequence.eventIds.length, 2);
      expect(sequence.isComplete, false);
    });

    test('should execute next in sequence', () {
      final event1 = eventService.createEvent(
        'npc-1',
        EventType.quest_given,
        'Event 1',
        'First',
        'dialogue',
      );

      final event2 = eventService.createEvent(
        'npc-1',
        EventType.quest_completed,
        'Event 2',
        'Second',
        'dialogue',
      );

      final sequence = eventService.createSequence(
        'npc-1',
        [event1.eventId, event2.eventId],
      );

      final next = eventService.executeNextInSequence(sequence.sequenceId);

      expect(next, isNotNull);
      expect(next!.eventId, event1.eventId);
    });

    test('should generate event statistics', () {
      eventService.createEvent(
        'npc-1',
        EventType.dialogue_triggered,
        'Event 1',
        'Desc',
        'dialogue',
      );

      eventService.createEvent(
        'npc-1',
        EventType.quest_given,
        'Event 2',
        'Desc',
        'quest',
      );

      final stats = eventService.generateStatistics('npc-1');

      expect(stats.npcId, 'npc-1');
      expect(stats.totalEvents, 2);
    });

    test('should get pending events', () {
      final event1 = eventService.createEvent(
        'npc-1',
        EventType.dialogue_triggered,
        'Pending',
        'Desc',
        'dialogue',
      );

      final pending = eventService.getPendingEvents('npc-1');

      expect(pending.length, 1);
      expect(pending[0].eventId, event1.eventId);
    });

    test('should trigger event based on conditions', () {
      final event = eventService.createEvent(
        'npc-1',
        EventType.relationship_milestone,
        'Milestone',
        'Desc',
        'affection',
      );

      final trigger = eventService.createTrigger(
        'npc-1',
        'affection',
        event.eventId,
        condition: EventCondition(minAffection: 50),
      );

      final triggered = eventService.triggerEvent(trigger.triggerId, 60, testNPC);

      expect(triggered, isNotNull);
      expect(triggered!.eventId, event.eventId);
    });

    test('should sort events by priority', () {
      final lowEvent = eventService.createEvent(
        'npc-1',
        EventType.dialogue_triggered,
        'Low',
        'Desc',
        'dialogue',
        priority: EventPriority.low,
      );

      final criticalEvent = eventService.createEvent(
        'npc-1',
        EventType.dialogue_triggered,
        'Critical',
        'Desc',
        'dialogue',
        priority: EventPriority.critical,
      );

      final sorted = eventService.sortByPriority([lowEvent, criticalEvent]);

      expect(sorted[0].priority, EventPriority.critical);
      expect(sorted[1].priority, EventPriority.low);
    });

    test('should deactivate trigger', () {
      final trigger = eventService.createTrigger(
        'npc-1',
        'dialogue',
        'event-1',
      );

      eventService.deactivateTrigger(trigger.triggerId);

      final retrieved = eventService.getTrigger(trigger.triggerId);
      expect(retrieved!.isActive, false);
    });

    test('should remove event', () {
      final event = eventService.createEvent(
        'npc-1',
        EventType.dialogue_triggered,
        'Test',
        'Desc',
        'dialogue',
      );

      eventService.removeEvent(event.eventId);

      expect(eventService.getEvent(event.eventId), isNull);
    });
  });
}
