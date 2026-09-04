import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_schedule_model.dart';
import 'package:eigo/services/npc_schedule_service.dart';

void main() {
  group('NPC Schedule Integration Tests', () {
    late NPCScheduleService service;

    setUp(() {
      service = NPCScheduleService.getInstance();
    });

    test('realistic teacher schedule should work', () {
      final teacherHours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['school', 'office'],
          activity: 'Teaching',
        ),
        NPCBusinessHours(
          timeOfDay: TimeOfDay.afternoon,
          availableLocationIds: ['school', 'cafeteria'],
          activity: 'Grading',
        ),
      ];

      final weekDays = List.generate(5, (i) {
        return DayPattern(
          dayOfWeek: DayOfWeek.values[i],
          hoursPattern: teacherHours,
        );
      });

      weekDays.addAll([
        DayPattern(
          dayOfWeek: DayOfWeek.saturday,
          hoursPattern: [],
          isActive: false,
        ),
        DayPattern(
          dayOfWeek: DayOfWeek.sunday,
          hoursPattern: [],
          isActive: false,
        ),
      ]);

      final schedule = service.initializeSchedule(
        'npc-teacher',
        weekDays,
        [],
        teacherHours,
      );

      final monday9am = DateTime(2026, 9, 7, 9, 0);
      expect(service.isAvailableAt(schedule, monday9am), true);

      final sunday = DateTime(2026, 9, 13, 10, 0);
      expect(service.isAvailableAt(schedule, sunday), false);
    });

    test('should find NPC at preferred location', () {
      final hours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['shop'],
          activity: 'Opening',
        ),
        NPCBusinessHours(
          timeOfDay: TimeOfDay.afternoon,
          availableLocationIds: ['shop', 'home'],
          activity: 'Working',
        ),
      ];

      final pattern = DayPattern(
        dayOfWeek: DayOfWeek.monday,
        hoursPattern: hours,
      );

      final schedule = service.initializeSchedule(
        'npc-shopkeeper',
        [pattern],
        [],
        hours,
      );

      final nextMeet = service.getNextMeetTime(
        schedule,
        DateTime(2026, 9, 7, 9, 0),
        'shop',
      );

      expect(nextMeet, isNotNull);
    });

    test('should track weekly schedule patterns', () {
      final baseHours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Activity',
        ),
      ];

      final weekPattern = [
        DayPattern(
          dayOfWeek: DayOfWeek.monday,
          hoursPattern: baseHours,
        ),
        DayPattern(
          dayOfWeek: DayOfWeek.tuesday,
          hoursPattern: baseHours,
        ),
        DayPattern(
          dayOfWeek: DayOfWeek.wednesday,
          hoursPattern: [],
          isActive: false, // Day off
        ),
        DayPattern(
          dayOfWeek: DayOfWeek.thursday,
          hoursPattern: baseHours,
        ),
        DayPattern(
          dayOfWeek: DayOfWeek.friday,
          hoursPattern: baseHours,
        ),
        DayPattern(
          dayOfWeek: DayOfWeek.saturday,
          hoursPattern: baseHours,
        ),
        DayPattern(
          dayOfWeek: DayOfWeek.sunday,
          hoursPattern: [],
          isActive: false,
        ),
      ];

      final schedule = service.initializeSchedule(
        'npc-variable',
        weekPattern,
        [],
        baseHours,
      );

      final weekly = service.getWeeklySchedule(schedule);
      expect(weekly.length, 7);
      expect(weekly[DayOfWeek.wednesday]!.isEmpty, true);
      expect(weekly[DayOfWeek.thursday]!.isNotEmpty, true);
    });

    test('should record visit history', () {
      final visitTime = DateTime(2026, 9, 7, 9, 30);
      final record = service.recordVisit(
        'npc-1',
        visitTime,
        'school',
        'teaching',
        true,
        'Had great dialogue',
      );

      expect(record.visitedAt, visitTime);
      expect(record.hadDialogue, true);
    });

    test('should calculate availability probability', () {
      final hours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['school'],
          activity: 'Teaching',
          absentProbability: 0.1,
        ),
      ];

      final pattern = DayPattern(
        dayOfWeek: DayOfWeek.monday,
        hoursPattern: hours,
      );

      final schedule = service.initializeSchedule(
        'npc-1',
        [pattern],
        [],
        hours,
      );

      final probability = service.getProbabilityAtLocation(
        schedule,
        'school',
        TimeOfDay.morning,
      );

      expect(probability, greaterThan(0.0));
      expect(probability, lessThanOrEqualTo(1.0));
    });

    test('should create and manage routines', () {
      final items = [
        service.createRoutineItem(
          TimeOfDay.morning,
          'spot-1',
          'Teaching',
          180,
        ),
        service.createRoutineItem(
          TimeOfDay.afternoon,
          'spot-2',
          'Grading',
          120,
        ),
      ];

      final routine = service.createRoutine(
        'routine-1',
        'npc-1',
        DayOfWeek.monday,
        items,
      );

      expect(routine.items.length, 2);
      expect(routine.items[0].activity, 'Teaching');
    });

    test('should apply seasonal adjustments', () {
      final baseHours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Working',
        ),
      ];

      final springPattern = SeasonalPattern(
        season: Season.spring,
        closedDays: [DayOfWeek.sunday],
        seasonalEvent: 'Festival',
      );

      final schedule = service.initializeSchedule(
        'npc-1',
        [DayPattern(dayOfWeek: DayOfWeek.monday, hoursPattern: baseHours)],
        [springPattern],
        baseHours,
      );

      final updated = service.applySeasonalAdjustments(
        schedule,
        Season.spring,
      );

      expect(updated.npcId, schedule.npcId);
    });

    test('should generate schedule summary with forecast', () {
      final hours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Open',
        ),
      ];

      final weekPattern = List.generate(5, (i) {
        return DayPattern(
          dayOfWeek: DayOfWeek.values[i],
          hoursPattern: hours,
        );
      });

      weekPattern.addAll([
        DayPattern(dayOfWeek: DayOfWeek.saturday, hoursPattern: [], isActive: false),
        DayPattern(dayOfWeek: DayOfWeek.sunday, hoursPattern: [], isActive: false),
      ]);

      final schedule = service.initializeSchedule(
        'npc-1',
        weekPattern,
        [],
        hours,
      );

      final summary = service.generateSummary(schedule);

      expect(summary.npcId, 'npc-1');
      expect(summary.closedDays, 2);
      expect(summary.getAvailabilityPercentage(), greaterThan(0.0));
      expect(summary.getScheduleForecast().isNotEmpty, true);
    });

    test('should rank NPCs by availability', () {
      final busyHours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Open',
        ),
        NPCBusinessHours(
          timeOfDay: TimeOfDay.afternoon,
          availableLocationIds: ['loc-1'],
          activity: 'Open',
        ),
      ];

      final sparseHours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.afternoon,
          availableLocationIds: ['loc-1'],
          activity: 'Open',
        ),
      ];

      final busySchedule = service.initializeSchedule(
        'npc-busy',
        [DayPattern(dayOfWeek: DayOfWeek.monday, hoursPattern: busyHours)],
        [],
        busyHours,
      );

      final sparseSchedule = service.initializeSchedule(
        'npc-sparse',
        [DayPattern(dayOfWeek: DayOfWeek.monday, hoursPattern: sparseHours)],
        [],
        sparseHours,
      );

      final comparison = service.compareAvailability(
        [busySchedule, sparseSchedule],
        DateTime.now(),
      );

      expect(comparison[0].$1, 'npc-busy');
      expect(comparison[0].$2, greaterThan(comparison[1].$2));
    });

    test('should handle absence probability correctly', () {
      final hoursWithAbsence = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Work',
          absentProbability: 0.7,
        ),
      ];

      final pattern = DayPattern(
        dayOfWeek: DayOfWeek.tuesday,
        hoursPattern: hoursWithAbsence,
      );

      final schedule = service.initializeSchedule(
        'npc-1',
        [pattern],
        [],
        hoursWithAbsence,
      );

      final availability = service.getAvailability(
        schedule,
        DateTime(2026, 9, 8, 9, 0),
      );

      expect(availability.isAvailable, false);
    });
  });
}
