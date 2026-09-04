import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_schedule_model.dart';
import 'package:eigo/services/npc_schedule_service.dart';

void main() {
  group('NPCScheduleService', () {
    late NPCScheduleService service;

    setUp(() {
      service = NPCScheduleService.getInstance();
    });

    test('should create a new schedule', () {
      final schedule = service.initializeSchedule('npc-1', [], [], []);
      expect(schedule.npcId, 'npc-1');
    });

    test('should check availability at time', () {
      final hours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Open',
        ),
      ];
      final pattern = DayPattern(
        dayOfWeek: DayOfWeek.monday,
        hoursPattern: hours,
      );
      final schedule = service.initializeSchedule('npc-1', [pattern], [], hours);

      final mondayMorning = DateTime(2026, 9, 7, 9, 0);
      expect(service.isAvailableAt(schedule, mondayMorning), true);
    });

    test('should return available locations', () {
      final hours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['school', 'park'],
          activity: 'Teaching',
        ),
      ];
      final pattern = DayPattern(
        dayOfWeek: DayOfWeek.tuesday,
        hoursPattern: hours,
      );
      final schedule = service.initializeSchedule('npc-1', [pattern], [], hours);

      final locations = schedule.getAvailableLocations(DateTime(2026, 9, 8, 10, 0));
      expect(locations.length, 2);
      expect(locations.contains('school'), true);
    });

    test('should record visit', () {
      final record = service.recordVisit(
        'npc-1',
        DateTime.now(),
        'school',
        'talking',
        true,
        'Good conversation',
      );

      expect(record.npcId, 'npc-1');
      expect(record.hadDialogue, true);
    });

    test('should generate summary', () {
      final hours = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Open',
        ),
      ];
      final pattern = DayPattern(
        dayOfWeek: DayOfWeek.wednesday,
        hoursPattern: hours,
      );
      final schedule = service.initializeSchedule('npc-1', [pattern], [], hours);

      final summary = service.generateSummary(schedule);
      expect(summary.npcId, 'npc-1');
      expect(summary.averageAvailability, greaterThanOrEqualTo(0.0));
    });

    test('should compare availability of multiple NPCs', () {
      final hours1 = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: ['loc-1'],
          activity: 'Open',
        ),
      ];
      final hours2 = [
        NPCBusinessHours(
          timeOfDay: TimeOfDay.morning,
          availableLocationIds: [],
          activity: 'Closed',
        ),
      ];

      final schedule1 = service.initializeSchedule(
        'npc-available',
        [DayPattern(dayOfWeek: DayOfWeek.thursday, hoursPattern: hours1)],
        [],
        hours1,
      );
      final schedule2 = service.initializeSchedule(
        'npc-unavailable',
        [DayPattern(dayOfWeek: DayOfWeek.thursday, hoursPattern: hours2)],
        [],
        hours2,
      );

      final comparison = service.compareAvailability([schedule1, schedule2], DateTime.now());
      expect(comparison[0].$1, 'npc-available');
      expect(comparison[0].$2, greaterThan(comparison[1].$2));
    });

    test('DayOfWeek should convert from DateTime', () {
      final monday = DateTime(2026, 9, 7);
      expect(DayOfWeek.fromDateTime(monday), DayOfWeek.monday);
    });

    test('Season should convert from month', () {
      expect(Season.fromMonth(3), Season.spring);
      expect(Season.fromMonth(6), Season.summer);
      expect(Season.fromMonth(9), Season.autumn);
      expect(Season.fromMonth(12), Season.winter);
    });

    test('TimeOfDay should convert from hour', () {
      expect(TimeOfDay.fromHour(7), TimeOfDay.earlyMorning);
      expect(TimeOfDay.fromHour(9), TimeOfDay.morning);
      expect(TimeOfDay.fromHour(14), TimeOfDay.afternoon);
      expect(TimeOfDay.fromHour(19), TimeOfDay.evening);
      expect(TimeOfDay.fromHour(22), TimeOfDay.night);
    });
  });
}
